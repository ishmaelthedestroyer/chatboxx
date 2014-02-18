app.controller 'AppCtrl', [
  '$scope', '$modal', 'noLogger', ($scope, $modal, Logger) ->

    $scope.contact = ($e) ->
      $e.preventDefault()
      $e.stopPropagation()

      Logger.debug 'Opening contact modal.'

      $modal.open
        backdrop: true
        keyboard: false
        backdropClick: false
        templateUrl: '/routes/modals/views/contact.html'
        windowClass: 'modal'
        controller: window.ContactModalCtrl
]