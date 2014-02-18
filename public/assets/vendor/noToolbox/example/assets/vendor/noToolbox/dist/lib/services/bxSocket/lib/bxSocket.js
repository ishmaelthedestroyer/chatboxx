angular.module('bxSocket', []).service('bxSocket', [
  '$rootScope', '$http', '$q', '$timeout', 'bxLogger', function($rootScope, $http, $q, $timeout, Logger) {
    var apply, host, initialized, isListening, listeners, load, open, scope, socket, wrap;
    scope = null;
    socket = null;
    initialized = false;
    open = false;
    listeners = {};
    host = location.protocol + '//' + location.hostname;
    if (location.port) {
      host += ':' + location.port;
    }
    load = function(url) {
      var deferred, promise, sio, wait, _s;
      deferred = $q.defer();
      promise = deferred.promise;
      if (window.io) {
        deferred.resolve(true);
        return promise;
      }
      sio = document.createElement('script');
      sio.type = 'text/javascript';
      sio.async = true;
      sio.src = url || '/socket.io/socket.io.js';
      _s = document.getElementsByTagName('script')[0];
      _s.parentNode.insertBefore(sio, _s);
      wait = function() {
        return setTimeout(function() {
          if (window.io) {
            return deferred.resolve(true);
          }
          return wait();
        }, 50);
      };
      wait();
      return promise;
    };
    wrap = function(cb) {
      return function(data) {
        return apply(scope || $rootScope, function() {
          return cb && cb(data);
        });
      };
    };
    isListening = function(e, cb) {
      var func, _i, _len, _ref;
      if (!listeners || !listeners[e]) {
        return false;
      }
      _ref = listeners[e];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        func = _ref[_i];
        Logger.debug('Debugging isListening func.', {
          func: func,
          cb: cb
        });
        if (func.toString() === cb.toString()) {
          return true;
        }
      }
      return false;
    };
    apply = function(scope, fn) {
      if (scope.$$phase || scope.$root.$$phase) {
        return fn();
      } else {
        return scope.$apply(fn);
      }
    };
    return {
      get: function() {
        return socket;
      },
      isOpen: function() {
        return open;
      },
      setScope: function(s) {
        return scope = s;
      },
      emit: function(e, data, cb) {
        if (!socket || !open) {
          throw new Error('Socket closed!');
          return false;
        }
        return socket.emit(e, data, function() {
          return apply(scope || $rootScope, function() {
            return cb && cb();
          });
        });
      },
      on: function(e, cb) {
        socket.removeListener(e, wrap(cb));
        socket.on(e, wrap(cb));
        if (!listeners[e]) {
          return listeners[e] = [cb];
        } else {
          return listeners[e].push(cb);
        }
        /*
        socket.on e, (data) ->
          apply scope || $rootScope, ->
            cb && cb(data)
        */

      },
      isListening: function(e, cb) {
        return isListening(e, cb);
      },
      removeListener: function(e, cb) {
        var func, i, _i, _len, _ref, _results;
        socket.removeListener(e, wrap(cb));
        if (listeners[e] && typeof listeners[e] === 'array') {
          _ref = listeners[e];
          _results = [];
          for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
            func = _ref[i];
            if (cb === func) {
              _results.push(listeners[e].splice(i, 1));
            }
          }
          return _results;
        }
      },
      removeAllListeners: function() {
        socket.removeAllListeners();
        return listeners = {};
      },
      close: function() {
        if (socket) {
          socket.disconnect();
          return open = false;
        }
      },
      open: function(url, wait) {
        var deferred, promise;
        deferred = $q.defer();
        if (open || (socket && socket.socket && socket.socket.connected)) {
          if (!open) {
            open = true;
          }
          promise = deferred.promise;
          deferred.resolve(true);
          return promise;
        }
        return load(url).then(function() {
          var cb, count, delay, timedOut, waiting;
          waiting = false;
          timedOut = false;
          delay = 0;
          count = function(max, deferred) {
            Logger.debug('Counting to ' + max + '... currently at ' + delay + '...');
            return $timeout(function() {
              if (!waiting) {
                return false;
              }
              if (++delay >= max) {
                timedOut = true;
                Logger.error('Socket.open() request timed out.');
                deferred.reject(null);
                return false;
              } else {
                return count(max, deferred);
              }
            }, 1000);
          };
          if (!initialized) {
            socket = io.connect(host);
            initialized = true;
          } else {
            socket.socket.connect();
          }
          cb = function(err) {
            delay = 0;
            open = false;
            waiting = false;
            if (deferred) {
              return deferred.reject(err);
            }
          };
          socket.on('uncaughtException', cb);
          socket.on('error', cb);
          waiting = true;
          count(wait || 10, deferred);
          socket.on('server:handshake', function(data) {
            if (timedOut) {
              return false;
            }
            if (!waiting) {
              return false;
            }
            delay = 0;
            open = true;
            waiting = false;
            Logger.info('Handshake successful.');
            socket.removeListener('uncaughtException', cb);
            socket.removeListener('error', cb);
            return deferred.resolve(data);
          });
          return deferred.promise;
        });
      }
    };
  }
]);
