app.service 'RTC', [
  '$rootScope', 'noLogger', 'noNotify', 'noSocket'
  ($rootScope, Logger, Notify, Socket) ->
    connections = []
    streamCamera = null
    streamScreen = null
    useOpus = true
    socket = null

    if navigator.mozGetUserMedia # if firefox
      pcConfig =
        iceServers: [
          url: 'stun:23.21.150.121'
        ]
    else
      pcConfig =
        iceServers: [
          url: 'stun:stun.l.google.com:19302'
        ]

    pcConstraints =
      optional: [
          DtlsSrtpKeyAgreement: true
        ,
          RtpDataChannels: true
      ]
    sdpConstraints =
      mandatory:
        OfferToReceiveAudio: true
        OfferToReceiveVideo: true
    offerConstraints =
      optional: []
      mandatory: {}
    dataConstraints =
      reliable: false

    # cross-browser adaptions
    RTCPC = window.mozRTCPeerConnection || window.webkitRTCPeerConnection ||
      window.RTCPeerConnection
    RTCSD = window.mozRTCSessionDescription || window.RTCSessionDescription
    RTCIC = window.mozRTCIceCandidate || window.RTCIceCandidate

    users = []
    getRoommates = () ->
      roommates = []
      roommates.push user for user in users when user.socket isnt socket
      return roommates

    merge = (one, two, key) ->
      merged = one
      if key then merged[key][k] = two[key][k] for k of two[key]
      else merged[k] = two[k] for k of two
      return merged

    createPC = (partner, type) ->
      try
        pc = new RTCPC pcConfig, pcConstraints
        pc.onsignalingstatechange = (e) ->
          Logger.debug 'Signal state change occured.', e
        pc.oniceconnectionstatechange = (e) ->
          Logger.debug 'Ice connection state change occured.', e
      catch e
        # TODO: notify of error
        Logger.error 'createPC() error', e
        return null

      pc.onaddstream = (e) ->
        Logger.info 'Remote stream added.'
        $rootScope.$broadcast 'RTC:addstream',
          user: partner
          type: type
          src: e.stream

      pc.onremovestream = (e) ->
        Logger.info 'Remote stream removed.'
        $rootScope.$broadcast 'RTC:removestream',
          user: partner
          type: type

      pc.onicecandidate = (e) ->
        if e.candidate
          Socket.emit 'users:message',
            to: [ partner ]
            from: socket
            type: 'candidate'
            id: e.candidate.sdpMid
            label: e.candidate.sdpMLineIndex
            candidate: e.candidate.candidate

      Logger.info 'Created Peer Connection.'
      conn =
        partner: partner
        type: type
        pc: pc

      connections.push conn
      return conn

    call = (partner, type) ->
      Logger.debug 'Preparing to make call.', partner, type
      return Logger.warn 'No id sent to RTC.call' if !partner
      return Logger.warn 'Can\'t call self.' if partner is socket

      for conn in connections when conn.partner is partner and conn.type is type
        return Logger.warn 'Already connected.'

      Logger.info 'Sending offer to peer...', partner

      conn = createPC partner, type

      if !conn
        return Notify.push 'Uh-oh. An error occured trying ' +
          'to connect to another user.', 'danger', 4000

      conn.pc.addStream streamCamera if streamCamera and type is 'camera'
      conn.pc.addStream streamScreen if streamScreen and type is 'screen'

      constraints = merge offerConstraints, sdpConstraints, 'mandatory'
      conn.pc.createOffer (description) ->
        description.sdp = preferOpus description.sdp
        conn.pc.setLocalDescription description
        Socket.emit 'users:message',
          to: [ partner ]
          from: socket
          streamType: type
          type: 'offer'
          sdp: description
      , (err) -> # on session description err
        Logger.error 'An error occured setting local description on call.', err
      , constraints

    answer = (data) ->
      Logger.info 'Sending answer to peer.', data
      conn = createPC data.from, data.streamType

      if !conn
        return Notify.push 'Uh-oh. An error occured trying to connect ' +
          ' to another user.', 'danger', 4000

      conn.pc.setRemoteDescription new RTCSD data.sdp

      if streamCamera and data.streamType is 'camera'
        conn.pc.addStream streamCamera
      else if streamScreen and data.streamType is 'screen'
        conn.pc.addStream streamScreen

      conn.pc.createAnswer (description) ->
        description.sdp = preferOpus description.sdp
        conn.pc.setLocalDescription description
        Socket.emit 'users:message',
          to: [ data.from ]
          from: socket
          streamType: data.streamType
          type: 'answer'
          sdp: description
      , (err) -> # on session description err
        Logger.error 'An error occured setting local description ' +
          'on answer.', err
      , sdpConstraints

    hangup = (partner, type, callback) ->
      Logger.info 'Hanging up connection:' + partner + '.'
      for conn, i in connections
        if conn.partner is partner and conn.type is type
          if conn.type is 'camera' and streamCamera
            conn.pc.removeStream streamCamera
          else if conn.type is 'screen' and streamScreen
            conn.pc.removeStream streamScreen

          conn.pc.close()
          connections.splice i, 1

          $rootScope.$broadcast 'RTC:removestream',
            user: partner
            type: conn.type

          Socket.emit 'users:message',
            to: [ conn.partner ]
            from: socket
            streamType: type
            type: if callback then 'callback' else 'hangup'

          return true
      return false # return false if not found

    handle = (message) ->
      Logger.debug 'RTC handling message.'

      if message.type is 'offer' then answer message
      else if message.type is 'answer'
        for conn in connections when conn.partner is message.from
            Logger.debug 'Setting remote description.'
            conn.pc.setRemoteDescription new RTCSD message.sdp
      else if message.type is 'hangup'
        hangup message.from, message.streamType, false
      else if message.type is 'callback'
        hangup message.from, message.streamType, false
        call message.from, message.streamType
      else if message.type is 'candidate'
        for conn in connections when conn.partner is message.from
          candidate = new RTCIC
            sdpMLineIndex: message.label
            candidate: message.candidate
          conn.pc.addIceCandidate candidate
      else
        Logger.error 'Unidentified message sent.', message

    # # # # # # # # # # # # # # # # # # # #
    # # # # # # # # # # # # # # # # # # # #

    preferOpus = (sdp) -> # set opus as default audio codec if present
      return sdp if !useOpus

      sdpLines = sdp.split '\r\n'
      mLineIndex = null
      i = 0
      while i < sdpLines.length # search for m line
        if sdpLines[i].search('m=audio') != -1
          mLineIndex = i
          break
        ++i

      return sdp if !mLineIndex

      i = 0
      while i < sdp.length  # if opus available, set as default in m line
        if sdpLines[i].search('opus/48000') != -1
          opusPayload = extractSdp(sdpLines[i], /:(\d+) opus\/48000/i)
          if opusPayload
            sdpLines[mLineIndex] = setDefaultCodec(sdpLines[mLineIndex],
              opusPayload)
          break
        ++i

      return sdpLines.join('\r\n')

    extractSdp = (sdpLine, pattern) ->
      result = sdpLine.match(pattern)
      if result && result.length == 2
        return result[1]
      else
        return null

    setDefaultCodec = (mLine, payload) ->
      elements = mLine.split(' ')
      newLine = []
      index = 0; i = 0
      while i < elements.length
        if index == 3 # format of media starts from the fourth
          newLine[index++] = payload

        if elements[i] != payload
          newLine[index++] = elements[i]

        ++i

      return newLine.join(' ')

    removeCN = (sdpLines, mLineIndex) ->
      # strip CN from sdp before CN constraints ready
      mLineElements = sdpLines[mLineIndex].split(' ')
      i = sdpLines.length - 1
      while i >= 0 # scan from end for convenience of removing an item
        payload = extractSdp(sdpLines[i], /a=rtpmap:(\d+) CN\/\d+/i)
        if payload
          cnPos = mLineElements.indexOf(payload)

          if cnPos != -1
            mLineElements.splice(cnPos, 1)

          sdpLines.splice(i, 1) # remove CN line in sdp
        --i

      sdpLines[mLineIndex] = mLineElements.join(' ')
      return sdpLines

    # # # # # # # # # # # # # # # # # # # #
    # # # # # # # # # # # # # # # # # # # #

    # exposed methods
    updateUsers: (x) -> users = x # update users
    setSocket: (x) -> socket = x # set socket id
    refresh: (stream, type) -> # refresh peer connection with stream
      streamCamera = stream if type is 'camera'
      streamScreen = stream if type is 'screen'

      if connections.length > 0
        i = connections.length - 1
        while i >= 0
          hangup connections[i].partner, type, true
          --i
    call: (x, type) -> call x, type # call user
    answer: (data) -> answer data # answer message
    disconnect: () -> # end all calls
      for conn in connections
        hangup conn.partner, 'camera', false
        hangup conn.partner, 'screen', false
    handle: handle # route message
    hangup: hangup # end peer connection
]