angular.module('bxCtrl', ['bxNotify', 'bxQueue', 'bxSession']).controller('bxCtrl', [
  '$scope', '$rootScope', '$state', '$location', '$q', 'bxNotify', 'bxQueue', 'bxSession', 'bxLogger', function($scope, $rootScope, $state, $location, $q, Notify, Queue, Session, Logger) {
    var apply;
    Notify.setScope($scope);
    Queue.setScope($scope);
    $scope.session = {};
    $scope.notifications = Notify.list();
    $scope.queue = Queue.list();
    $scope.bxState = $state;
    $scope.loadSession = function() {
      var deferred;
      deferred = $q.defer();
      deferred = $q.defer();
      Queue.push(deferred.promise);
      return Session.refresh().then(function(data) {
        return deferred.resolve(true);
      });
    };
    $rootScope.$on('session:loaded', function(event, data) {
      Logger.debug('Updated session.', data);
      return $scope.session = data;
    });
    $scope.logout = function($e, location) {
      var deferred;
      $e.preventDefault();
      deferred = $q.defer();
      Queue.push(deferred.promise);
      return Session.logout().then(function(data) {
        $location.path('/' || location);
        return deferred.resolve(true);
      });
    };
    $scope.removeNotification = function(index) {
      return Notify.remove(index);
    };
    return apply = function(scope, fn) {
      if (scope.$$phase || scope.$root.$$phase) {
        return fn();
      } else {
        return scope.$apply(fn);
      }
    };
  }
]);
