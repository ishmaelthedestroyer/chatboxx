angular.module('bxNotify', []).service('bxNotify', [
  '$rootScope', '$timeout', function($rootScope, $timeout) {
    var apply, notifications, remove, scope;
    notifications = [];
    scope = $rootScope;
    apply = function(scope, fn) {
      if (scope.$$phase || scope.$root.$$phase) {
        return fn();
      } else {
        return scope.$apply(fn);
      }
    };
    remove = function(notif) {
      return apply(scope, function() {
        var i, n, _i, _len;
        if (typeof notif === 'object') {
          for (i = _i = 0, _len = notifications.length; _i < _len; i = ++_i) {
            n = notifications[i];
            if (n === notif) {
              return notifications.splice(i, 1);
            }
          }
        } else {
          return notifications.splice(notif, 1);
        }
      });
    };
    return {
      setScope: function(s) {
        return scope = s;
      },
      list: function() {
        return notifications;
      },
      remove: function(notif) {
        return remove(notif);
      },
      push: function(message, type, timeout) {
        var notif;
        if (type == null) {
          type = 'success';
        }
        notif = {
          message: message,
          type: type
        };
        apply(scope, function() {
          notifications.unshift(notif);
          if (notifications.length > 10) {
            return notifications.pop();
          }
        });
        if (timeout) {
          $timeout(function() {
            return remove(notif);
          }, timeout);
        }
        return notif;
      }
    };
  }
]);
