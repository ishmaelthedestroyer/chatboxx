angular.module('bxPreserveQuery', []).run([
  '$rootScope', '$location', function($rootScope, $location) {
    $rootScope.$on('$stateChangeStart', function(event, toState, toParams, fromState, fromParams) {
      return this.locationSearch = $location.search();
    });
    return $rootScope.$on('$stateChangeSuccess', function(event, toState, toParams, fromState, fromParams) {
      return $location.search(this.locationSearch);
    });
  }
]);
