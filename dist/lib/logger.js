var EventEmitter, Logger, colors, defaults, util;

EventEmitter = require('events').EventEmitter;

util = require('../lib/util');

colors = require('colors');

defaults = {};

if (!process.env.NODE_ENV || process.env.NODE_ENV === 'development') {
  defaults.level = 3;
} else {
  defaults.level = 0;
}

defaults["catch"] = true;

Logger = function(options) {
  var key, val;
  if (!(this instanceof Logger)) {
    return new Logger(options);
  }
  EventEmitter.call(this);
  util.extend(defaults, options || {});
  for (key in defaults) {
    val = defaults[key];
    this[key] = val;
  }
  return this;
};

util.inherits(Logger, EventEmitter);

Logger.prototype.debug = function(msg, info) {
  if (this.level < 3) {
    return;
  }
  console.log(colors.blue('DEBUG >> ') + msg, info || {});
  if (this.emit) {
    return this.emit('debug', msg, info || {});
  }
};

Logger.prototype.info = function(msg, info) {
  if (this.level < 2) {
    return;
  }
  console.log(colors.green('INFO >> ') + msg, info || {});
  if (this.emit) {
    return this.emit('info', msg, info || {});
  }
};

Logger.prototype.warn = function(msg, info) {
  if (this.level < 1) {
    return;
  }
  console.log(colors.yellow('WARN >> ') + msg, info || {});
  if (this.emit) {
    return this.emit('warn', msg, info || {});
  }
};

Logger.prototype.error = function(msg, info) {
  console.log(colors.red('ERROR >> ') + msg, info || {});
  if (!this["catch"] && this.emit) {
    return this.emit('error', msg, info || {});
  }
};

Logger.prototype.patch = function(msg, info) {
  console.log(colors.cyan('PATCH >> ') + msg, info || {});
  if (this.emit) {
    return this.emit('patch', msg, info || {});
  }
};

module.exports = Logger;
