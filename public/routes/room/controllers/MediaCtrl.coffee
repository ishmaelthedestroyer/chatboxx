app.controller 'MediaCtrl', [
  '$scope', '$rootScope', '$modal', '$state', '$q',
  'noLogger', 'noSocket', 'noQueue', 'noNotify', 'RTC'
  ($scope, $rootScope, $modal, $state, $q,
  Logger, Socket, Queue, Notify, RTC) ->
    $scope.requestingCamera = false
    $scope.requestingScreen = false

    $scope.streamingCamera = false
    $scope.streamingScreen = false
    $scope.muted = false

    streamCamera = null
    streamScreen = null
    supported = null

    n = navigator
    n.getUserMedia = n.getUserMedia || n.webkitGetUserMedia ||
      n.mozGetUserMedia || n.msGetUserMedia

    $rootScope.$on 'initialize', () ->
      # $scope.toggleCamera() # get camera on initialization

      Socket.on 'users:enter', (data) ->  # user entered room
        Notify.push 'A user has entered the room.', 'success', 4000
        RTC.call data.message, 'camera' # if $scope.streamingCamera
        RTC.call data.message, 'screen' # if $scope.streamingScreen

      # # # # # # # # # #

      Socket.on 'users:exit', (data) -> # user left the room
        Logger.debug 'A user left the room.', data
        Notify.push 'A user has left the room.', 'danger', 4000

        RTC.hangup data.message, 'camera', false
        RTC.hangup data.message, 'screen', false

    # # # # # # # # # #

    $rootScope.$on 'RTC:addstream', (e, data) ->
      Logger.debug 'MediaCtrl got request to attach stream from RTC.'
      attachStream data.src, data.user, data.type

    $rootScope.$on 'RTC:removestream', (e, data) ->
      Logger.debug 'MediaCtrl got request to detach stream from RTC.'
      detachStream data.user, data.type

    checkSupport = () ->
      Logger.debug 'Checking support....'

      return true if supported is true
      return false if supported is false

      supported = n.userAgent.match("Chrome") and
        parseInt(n.userAgent.match(/Chrome\/(.*) /)[1]) >= 26

      return supported

    alertNotSupported = () ->
      modal = do -> $modal.open
        backdrop: true
        keyboard: false
        backdropClick: false
        templateUrl: '/routes/modals/views/notSupported.html'
        windowClass: 'modal'
        controller: window.NotSupportedCtrl

    attachStream = (stream, user, type) ->
      if window.URL
        src = window.URL.createObjectURL stream
      else if webkitURL
        src = webkitURL.createObjectURL stream

      $rootScope.$broadcast 'stream:attach',
        user: user
        type: type
        src: src

    detachStream = (user, type) ->
      $rootScope.$broadcast 'stream:detach',
        user: user
        type: type

    $scope.toggleCamera = () ->
      return alertNotSupported() if !checkSupport()

      Logger.debug 'Toggled camera.', $scope.streamingCamera

      if !$scope.streamingCamera
        return false if $scope.requestingStream

        deferred = $q.defer()
        Queue.push deferred.promise
        $scope.requestingCamera = true

        n.getUserMedia
          video: true
          audio: true
        , (stream) -> # success callback
          return false if $scope.streamingCamera

          $scope.requestingCamera = false if $scope.requestingCamera
          $scope.streamingCamera = true if !$scope.streamingCamera

          deferred.resolve true

          streamCamera = stream
          window.streamCamera = stream
          mute() if $scope.muted

          RTC.refresh stream, 'camera' # add stream to RTC
          attachStream stream, null, 'camera'
        , (err) -> # error callback
          return alertNotSupported()
      else # turn off camera
        streamCamera.stop()

        streamCamera.stop() if streamCamera.stop
        streamCamera.mozSrcObject.stop() if streamCamera.mozSrcObject
        streamCamera = null
        $scope.streamingCamera = false

        RTC.refresh null, 'camera'
        detachStream null, 'camera'

    $scope.toggleScreen = () ->
      return alertNotSupported() if !checkSupport()

      Logger.debug 'Toggled screen share.', $scope.streamingScreen

      if !$scope.streamingScreen
        return false if $scope.requestingScreen

        deferred = $q.defer()
        Queue.push deferred.promise
        $scope.requestingScreen = true

        n.getUserMedia
          video:
            mandatory:
              chromeMediaSource: 'screen'
        , (stream) -> # success callback
          return false if $scope.streamingScreen

          $scope.requestingScreen = false if $scope.requestingScreen
          $scope.streamingScreen = true if !$scope.streamingScreen

          deferred.resolve true

          streamScreen = stream
          window.streamScreen = stream

          RTC.refresh stream, 'screen' # add stream to RTC
          attachStream stream, null, 'screen'
        , (err) -> # error callback
          return alertNotSupported()
      else # turn off camera
        streamScreen.stop()

        streamScreen.stop() if streamScreen.stop
        streamScreen.mozSrcObject.stop() if streamScreen.mozSrcObject
        streamScreen = null
        $scope.streamingScreen = false

        RTC.refresh null, 'screen'
        detachStream null, 'screen'

    $scope.toggleMute = () ->
      $scope.muted = !$scope.muted
      $rootScope.$broadcast 'mute', $scope.muted

      if $scope.muted
        unMute() if streamingCamera
      else
        mute() if streamingCamera

    mute = () ->
      tracks = streamCamera.getAudioTracks()
      i = 0
      while i < tracks.length
        tracks[i].enabled = false
        ++i

    unMute = () ->
      tracks = streamCamera.getAudioTracks()
      i = 0
      while i < tracks.length
        tracks[i].enabled = true
        ++i
]