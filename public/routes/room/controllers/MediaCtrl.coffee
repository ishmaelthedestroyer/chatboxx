app.controller 'MediaCtrl', [
  '$scope', '$state', 'noLogger', 'noSocket'
  ($scope, $state, Logger, Socket) ->
    $scope.requestingCamera = false
    $scope.requestingScreen = false

    $scope.streamingCamera = false
    $scope.streamingScreen = false
    $scope.muted = false

    $scope.toggleCamera = () ->
      Logger.debug 'Toggled camera.', $scope.streamingCamera
      $scope.streamingCamera = !$scope.streamingCamera

    $scope.toggleScreen = () ->
      Logger.debug 'Toggled screen.', $scope.streamingScreen
      $scope.streamingScreen = !$scope.streamingScreen

    $scope.toggleMute = () ->
      Logger.debug 'Toggled muted.', $scope.muted
      $scope.muted = !$scope.muted
]