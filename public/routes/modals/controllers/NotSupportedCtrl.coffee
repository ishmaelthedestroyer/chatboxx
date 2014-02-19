window.NotSupportedCtrl = [
  '$scope', '$rootScope', '$modalInstance', '$state',
  '$stateParams', '$location', 'noNotify', 'noLogger', 'noUtil'
  ($s, $rootScope, $m, $state,
  $stateParams, $location, Notify, Logger, Util) ->

    $s.close = () ->
      $m.dismiss 'cancel'
]
