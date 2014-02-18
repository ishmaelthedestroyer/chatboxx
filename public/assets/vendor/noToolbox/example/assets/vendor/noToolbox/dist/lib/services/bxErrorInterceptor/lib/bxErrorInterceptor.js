angular.module('bxErrorInterceptor', ['bxNotify']).factory('bxErrorInterceptor', [
  '$rootScope', '$location', '$q', 'bxNotify', function($rootScope, $location, $q, Notify) {
    return function(promise) {
      return promise.then(function(response) {
        return response;
      }, function(response) {
        Notify.push(response.data, 'danger', 5000);
        if (response.status === 401) {
          $rootScope.$emit('401');
        }
        return $q.reject(response);
      });
    };
  }
]).config(function($httpProvider) {
  return $httpProvider.responseInterceptors.push('bxErrorInterceptor');
});
