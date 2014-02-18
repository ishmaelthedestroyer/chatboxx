angular.module('bxEventEmitter', ['bxUtil']).service('bxEventEmitter', [
  'bxUtil', function(util) {
    var EventEmitter, ref;
    EventEmitter = function() {
      this._events = this._events || {};
      return this._maxListeners = this._maxListeners || 'undefined';
    };
    EventEmitter.EventEmitter = EventEmitter;
    EventEmitter.prototype._events = 'undefined';
    EventEmitter.prototype._maxListeners = 'undefined';
    EventEmitter.defaultMaxListeners = 10;
    EventEmitter.prototype.setMaxListeners = function(n) {
      if (!util.isNumber(n) || n < 0) {
        throw TypeError("n must be a positive number");
      }
      this._maxListeners = n;
      return this;
    };
    EventEmitter.prototype.emit = function(type) {
      var args, er, handler, i, len, listeners;
      er = void 0;
      handler = void 0;
      len = void 0;
      args = void 0;
      i = void 0;
      listeners = void 0;
      if (!this._events) {
        this._events = {};
      }
      if (type === "error") {
        if (!this._events.error || (util.isObject(this._events.error) && !this._events.error.length)) {
          er = arguments_[1];
          if (er instanceof Error) {
            throw er;
          } else {
            throw TypeError("Uncaught, unspecified \"error\" event.");
          }
          return false;
        }
      }
      handler = this._events[type];
      if (util.isUndefined(handler)) {
        return false;
      }
      if (util.isFunction(handler)) {
        switch (arguments_.length) {
          case 1:
            handler.call(this);
            break;
          case 2:
            handler.call(this, arguments_[1]);
            break;
          case 3:
            handler.call(this, arguments_[1], arguments_[2]);
            break;
          default:
            len = arguments_.length;
            args = new Array(len - 1);
            i = 1;
            while (i < len) {
              args[i - 1] = arguments_[i];
              i++;
            }
            handler.apply(this, args);
        }
      } else if (util.isObject(handler)) {
        len = arguments_.length;
        args = new Array(len - 1);
        i = 1;
        while (i < len) {
          args[i - 1] = arguments_[i];
          i++;
        }
        listeners = handler.slice();
        len = listeners.length;
        i = 0;
        while (i < len) {
          listeners[i].apply(this, args);
          i++;
        }
      }
      return true;
    };
    EventEmitter.prototype.addListener = function(type, listener) {
      var l, m;
      m = void 0;
      if (!util.isFunction(listener)) {
        throw TypeError("listener must be a function");
      }
      if (!this._events) {
        this._events = {};
      }
      if (this._events.newListener) {
        if (util.isFunction(listener.listener)) {
          l = listener.listener;
        } else {
          l = listener;
        }
        this.emit("newListener", type, l);
      }
      if (!this._events[type]) {
        this._events[type] = listener;
      } else if (util.isObject(this._events[type])) {
        this._events[type].push(listener);
      } else {
        this._events[type] = [this._events[type], listener];
      }
      if (util.isObject(this._events[type]) && !this._events[type].warned) {
        m = void 0;
        if (!util.isUndefined(this._maxListeners)) {
          m = this._maxListeners;
        } else {
          m = EventEmitter.defaultMaxListeners;
        }
        if (m && m > 0 && this._events[type].length > m) {
          this._events[type].warned = true;
          console.error("(node) warning: possible EventEmitter memory " + "leak detected. %d listeners added. " + "Use emitter.setMaxListeners() to increase limit.", this._events[type].length);
          console.trace();
        }
      }
      return this;
    };
    EventEmitter.prototype.on = EventEmitter.prototype.addListener;
    EventEmitter.prototype.once = function(type, listener) {
      var g;
      g = function() {
        this.removeListener(type, g);
        return listener.apply(this, arguments_);
      };
      if (!util.isFunction(listener)) {
        throw TypeError("listener must be a function");
      }
      g.listener = listener;
      this.on(type, g);
      return this;
    };
    EventEmitter.prototype.removeListener = function(type, listener) {
      var i, length, list, position;
      list = void 0;
      position = void 0;
      length = void 0;
      i = void 0;
      if (!util.isFunction(listener)) {
        throw TypeError("listener must be a function");
      }
      if (!this._events || !this._events[type]) {
        return this;
      }
      list = this._events[type];
      length = list.length;
      position = -1;
      if (list === listener || (util.isFunction(list.listener) && list.listener === listener)) {
        delete this._events[type];
        if (this._events.removeListener) {
          this.emit("removeListener", type, listener);
        }
      } else if (util.isObject(list)) {
        i = length;
        while (i-- > 0) {
          if (list[i] === listener || (list[i].listener && list[i].listener === listener)) {
            position = i;
            break;
          }
        }
        if (position < 0) {
          return this;
        }
        if (list.length === 1) {
          list.length = 0;
          delete this._events[type];
        } else {
          list.splice(position, 1);
        }
        if (this._events.removeListener) {
          this.emit("removeListener", type, listener);
        }
      }
      return this;
    };
    EventEmitter.prototype.removeAllListeners = function(type) {
      var key, listeners;
      key = void 0;
      listeners = void 0;
      if (!this._events) {
        return this;
      }
      if (!this._events.removeListener) {
        if (arguments_.length === 0) {
          this._events = {};
        } else {
          if (this._events[type]) {
            delete this._events[type];
          }
        }
        return this;
      }
      if (arguments_.length === 0) {
        for (key in this._events) {
          if (key === "removeListener") {
            continue;
          }
          this.removeAllListeners(key);
        }
        this.removeAllListeners("removeListener");
        this._events = {};
        return this;
      }
      listeners = this._events[type];
      if (util.isFunction(listeners)) {
        this.removeListener(type, listeners);
      } else {
        while (listeners.length) {
          this.removeListener(type, listeners[listeners.length - 1]);
        }
      }
      delete this._events[type];
      return this;
    };
    EventEmitter.prototype.listeners = function(type) {
      var ret;
      ret = void 0;
      if (!this._events || !this._events[type]) {
        ret = [];
      } else if (util.isFunction(this._events[type])) {
        ret = [this._events[type]];
      } else {
        ret = this._events[type].slice();
      }
      return ret;
    };
    EventEmitter.listenerCount = function(emitter, type) {
      var ret;
      ret = void 0;
      if (!emitter._events || !emitter._events[type]) {
        ret = 0;
      } else if (util.isFunction(emitter._events[type])) {
        ret = 1;
      } else {
        ret = emitter._events[type].length;
      }
      return ret;
    };
    ref = new EventEmitter;
    return {
      create: function() {
        return new EventEmitter;
      },
      get: function() {
        return EventEmitter;
      },
      setMaxListeners: ref.setMaxListeners,
      emit: ref.emit,
      addListener: ref.addListener,
      on: ref.on,
      once: ref.once,
      removeListener: ref.removeListener,
      removeAllListeners: ref.removeAllListeners,
      listeners: ref.listeners
    };
  }
]);
