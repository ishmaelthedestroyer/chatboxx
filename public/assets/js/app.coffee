app = angular.module 'App', [
  'ui.router'
  'ui.bootstrap'
  'noToolbox'
]

app.run [
  '$rootScope'
  '$state'
  '$stateParams'
  ($rootScope, $state, $stateParams) ->
    $rootScope.$state = $state
    $rootScope.$stateParams = $stateParams
]
