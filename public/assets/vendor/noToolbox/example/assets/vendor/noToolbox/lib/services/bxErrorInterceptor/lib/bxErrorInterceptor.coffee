angular.module('bxErrorInterceptor', ['bxNotify'])

.factory('bxErrorInterceptor', [
  '$rootScope', '$location', '$q', 'bxNotify'
  ($rootScope, $location, $q, Notify) ->
    (promise) ->
      promise.then (response) ->
        response # success handler
      , (response) -> # notify
        Notify.push response.data, 'danger', 5000

        if response.status == 401 # handle unauthorized
          $rootScope.$emit '401'

        $q.reject response
])

.config ($httpProvider) ->
  $httpProvider.responseInterceptors.push 'bxErrorInterceptor'
