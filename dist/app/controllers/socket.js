var $q, EventEmitter, Logger, Server, fs, redisCONFIG, ss, util;

EventEmitter = require('events').EventEmitter;

ss = require('socket.io-stream');

$q = require('q');

fs = require('fs');

redisCONFIG = require('../../config/app/redis');

util = require('../../lib/util');

Logger = new (require('../../lib/logger'));

Server = function(io) {
  if (!(this instanceof Server)) {
    return new Server(io);
  }
  EventEmitter.call(this);
  this.io = io || null;
  this.init();
  util.extend(this, Logger);
  util.inherits(this, EventEmitter);
  return this;
};

Server.prototype.init = function() {
  var _this = this;
  return this.io.sockets.on('connection', function(socket) {
    var hs;
    hs = socket.handshake;
    _this.debug('Socket connected to server.');
    return _this.notify(socket.id, 'server:handshake', 'Successfully connected to the server.');
  });
};

Server.prototype.notify = function(id, e, data) {
  this.debug('Notifying socket.', {
    id: id,
    e: e
  });
  return this.io.sockets.socket(id).emit(e, data);
};

Server.prototype.toArrayBuffer = function(buffer) {
  var ab, i, view;
  ab = new ArrayBuffer(buffer.length);
  view = new Uint8Array(ab);
  i = 0;
  while (i < buffer.length) {
    view[i] = buffer[i];
    ++i;
  }
  return view;
};

Server.prototype.close = function(socket) {};

module.exports = function(io) {
  return Server(io);
};
