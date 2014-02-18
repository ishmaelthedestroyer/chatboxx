var __indexOf = [].indexOf || function(item) { for (var i = 0, l = this.length; i < l; i++) { if (i in this && this[i] === item) return i; } return -1; };

angular.module('bxLogger', []).service('bxLogger', [
  '$http', function($http) {
    var config, notify, setMode, setSentry;
    config = {
      mode: 'development',
      sentry: '/api/sentry',
      output: null,
      notify: null
    };
    /* Logic below defaults to:
    mode: 'development'
    sentry: '/api/sentry'
    output: [ 'debug', 'info', 'warn', 'error']
    notify: [ 'warn', 'error', 'global' ]
    */

    notify = function(type, message, info) {
      return $http.post(config.sentry, {
        mode: config.mode,
        type: type,
        message: message,
        info: info || {}
      });
    };
    window.onerror = function(msg, url, line) {
      if ((config.notify instanceof Array && __indexOf.call(config.notify, 'global') >= 0) || (!config.output && config.mode === 'production')) {
        return notify('global', 'An unhandled error occured.', {
          msg: msg,
          url: url,
          line: line
        });
      }
    };
    setMode = function(m) {
      return config.mode = m;
    };
    setSentry = function(s) {
      return config.sentry = s;
    };
    return {
      debug: function(msg, info) {
        var color;
        color = 'color: #333; background-color: #fff;';
        if ((config.output instanceof Array && __indexOf.call(config.output, 'debug') >= 0) || (!config.output && config.mode === 'development')) {
          console.log('%c DEBUG >> ' + msg, color, info || '');
        }
        if (config.notify instanceof Array && __indexOf.call(config.notify, 'debug') >= 0) {
          return notify('debug', msg, info);
        }
      },
      info: function(msg, info) {
        var color;
        color = 'color: #5E9CD2; background-color: #fff;';
        if ((config.output instanceof Array && __indexOf.call(config.output, 'info') >= 0) || (!config.output && config.mode === 'development')) {
          console.log('%c INFO >> ' + msg, color, info || '');
        }
        if (config.notify instanceof Array && __indexOf.call(config.notify, 'info') >= 0) {
          return notify('debug', msg, info);
        }
      },
      warn: function(msg, info) {
        var color;
        color = 'color: #FF9900; background-color: #fff;';
        if ((config.output instanceof Array && __indexOf.call(config.output, 'warn') >= 0) || (!config.output && config.mode === 'development')) {
          console.log('%c WARNING >> ' + msg, color, info || '');
        }
        if ((config.notify instanceof Array && __indexOf.call(config.notify, 'warn') >= 0) || (!config.notify && config.mode === 'production')) {
          return notify('warn', msg, info);
        }
      },
      error: function(msg, info) {
        var color;
        color = 'color: #f00; background-color: #fff;';
        if ((config.output instanceof Array && __indexOf.call(config.output, 'error') >= 0) || (!config.output && config.mode === 'development')) {
          console.log('%c ERROR >> ' + msg, color, info || '');
        }
        if ((config.notify instanceof Array && __indexOf.call(config.notify, 'error') >= 0) || (!config.notify && config.mode === 'production')) {
          return notify('error', msg, info);
        }
      }
    };
  }
]);
