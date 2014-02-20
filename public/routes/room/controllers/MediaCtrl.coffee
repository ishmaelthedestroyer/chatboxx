app.controller 'MediaCtrl', [
  '$scope', '$rootScope', '$modal', '$state', '$q',
  'noLogger', 'noSocket', 'noQueue'
  ($scope, $rootScope, $modal, $state, $q,
  Logger, Socket, Queue) ->
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
      $scope.toggleCamera() # get camera on initialization

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

          attachStream stream, null, 'camera'
        , (err) -> # error callback
          return alertNotSupported()
      else # turn off camera
        streamCamera.stop()

        streamCamera.stop() if streamCamera.stop
        streamCamera.mozSrcObject.stop() if streamCamera.mozSrcObject
        streamCamera = null
        $scope.streamingCamera = false
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

          attachStream stream, null, 'screen'
        , (err) -> # error callback
          return alertNotSupported()
      else # turn off camera
        streamScreen.stop()

        streamScreen.stop() if streamScreen.stop
        streamScreen.mozSrcObject.stop() if streamScreen.mozSrcObject
        streamScreen = null
        $scope.streamingScreen = false
        detachStream null, 'screen'

    $scope.toggleMute = () ->
      $scope.muted = !$scope.muted
      $rootScope.$broadcast 'mute', $scope.muted

      if $scope.muted
        unMute() if streamCamera
      else
        mute() if streamCamera

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