angular.module('bxQueue', []).factory('bxQueue', [
  '$rootScope', '$timeout', function($rootScope, $timeout) {
    var apply, queue, remove, scope;
    queue = [];
    scope = $rootScope;
    apply = function(scope, fn) {
      if (scope.$$phase || scope.$root.$$phase) {
        return fn();
      } else {
        return scope.$apply(fn);
      }
    };
    remove = function(promise, callback) {
      return apply(scope, function() {
        var i, _results;
        i = 0;
        _results = [];
        while (i < queue.length) {
          if (queue[i] === promise) {
            queue.splice(i, 1);
            if (typeof callback === "function") {
              callback(callback());
            }
            break;
          }
          _results.push(++i);
        }
        return _results;
      });
    };
    return {
      setScope: function(s) {
        return scope = s;
      },
      list: function() {
        return queue;
      },
      push: function(promise, timeout, callback) {
        apply(scope, function() {
          return queue.push(promise);
        });
        promise.then(function() {
          return remove(promise, callback);
        }, function(err) {
          return remove(promise, callback);
        });
        if (timeout) {
          return $timeout(function() {
            return remove(promise, callback);
          }, timeout);
        }
      },
      remove: function(promise) {
        return remove(promise);
      },
      clear: function() {
        var promise, _i, _len, _results;
        _results = [];
        for (_i = 0, _len = queue.length; _i < _len; _i++) {
          promise = queue[_i];
          _results.push(remove(promise));
        }
        return _results;
        /*
        apply scope, () ->
          queue = []
        */

      }
    };
  }
]);
