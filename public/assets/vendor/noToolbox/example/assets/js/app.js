var app = angular.module('App', ['ui.router', 'ui.bootstrap', 'noToolbox'])

app.controller('AppCtrl', [
  '$scope', '$state', '$q', 'noResource', 'noNotify', 'noQueue', 'noLogger',
  function($scope, $state, $q, Resource, Notify, Queue, Logger) {

    $scope.notify = function() {
      Notify.push('This is a push notification.', 'success', 3000);
    }

    $scope.notifyWarning = function() {
      Notify.push('This is a WARNING push notification.', 'warning', 3000);
    }

    $scope.notifyDanger = function() {
      Notify.push('This is a DANGER push notification.', 'danger', 3000);
    }

    /* * * * * * * * * * * */

    $scope.logDebug = function() {
      Logger.debug('Logging data.', {
        foo: 'bar',
        bar: 'baz'
      })
    }

    $scope.logInfo = function() {
      Logger.info('Logging data.', {
        foo: 'bar',
        bar: 'baz'
      })
    }

    $scope.logWarning = function() {
      Logger.warn('Logging data.', {
        foo: 'bar',
        bar: 'baz'
      })
    }

    $scope.logError = function() {
      Logger.error('Logging data.', {
        foo: 'bar',
        bar: 'baz'
      })
    }

    /* * * * * * * * * * * */

    $scope.pushQueue = function () {
      var deferred = $q.defer();

      Queue.push(deferred.promise);

      setTimeout(function() {
        deferred.resolve(true);
      }, 500);
    }
  }
]);

angular.element(document).ready(function() {
  return angular.bootstrap(document, ['App']);
});