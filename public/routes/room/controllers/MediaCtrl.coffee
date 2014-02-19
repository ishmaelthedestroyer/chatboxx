app.controller 'MediaCtrl', [
  '$scope', '$rootScope', '$modal', '$state', 'noLogger', 'noSocket'
  ($scope, $rootScope, $modal, $state, Logger, Socket) ->
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
      $scope.streamingCamera = !$scope.streamingCamera

      $rootScope.$broadcast 'stream:attach',
        user: 'asdf'
        type: 'asdf'
        src: 'asdf'

    $scope.toggleScreen = () ->
      return alertNotSupported() if !checkSupport()

      Logger.debug 'Toggled screen.', $scope.streamingScreen
      $scope.streamingScreen = !$scope.streamingScreen

    $scope.toggleMute = () ->
      Logger.debug 'Toggled muted.', $scope.muted
      $scope.muted = !$scope.muted
]