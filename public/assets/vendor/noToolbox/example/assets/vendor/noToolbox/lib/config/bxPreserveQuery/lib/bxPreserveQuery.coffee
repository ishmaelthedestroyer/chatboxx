angular.module('bxPreserveQuery', [])

.run ['$rootScope', '$location', ($rootScope, $location) ->
  $rootScope.$on '$stateChangeStart',
  (event, toState, toParams, fromState, fromParams) ->
    # save location.search to add after transition
    @locationSearch = $location.search()

  $rootScope.$on '$stateChangeSuccess',
  (event, toState, toParams, fromState, fromParams) ->
    # restore all query string parameters
    $location.search @locationSearch
]