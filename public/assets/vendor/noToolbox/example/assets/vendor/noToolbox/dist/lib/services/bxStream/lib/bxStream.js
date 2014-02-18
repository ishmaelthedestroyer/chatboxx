angular.module('bxStream', ['bxUtil', 'bxEventEmitter']).service('bxStream', [
  'bxUtil', 'bxEventEmitter', function(util, EventEmitter) {
    var EE, Stream, ref;
    EE = EventEmitter.get();
    Stream = function() {
      return EE.call(this);
    };
    util.inherits(Stream, EE);
    Stream.prototype.pipe = function(dest, options) {
      var cleanup, didOnEnd, onclose, ondata, ondrain, onend, onerror, source;
      ondata = function(chunk) {
        if (dest.writable) {
          if (false === dest.write(chunk) && source.pause) {
            return source.pause();
          }
        }
      };
      ondrain = function() {
        if (source.readable && source.resume) {
          return source.resume();
        }
      };
      onend = function() {
        var didOnEnd;
        if (didOnEnd) {
          return;
        }
        didOnEnd = true;
        return dest.end();
      };
      onclose = function() {
        var didOnEnd;
        if (didOnEnd) {
          return;
        }
        didOnEnd = true;
        if (typeof dest.destroy === "function") {
          return dest.destroy();
        }
      };
      onerror = function(er) {
        cleanup();
        if (EE.listenerCount(this, "error") === 0) {
          throw er;
        }
      };
      cleanup = function() {
        source.removeListener("data", ondata);
        dest.removeListener("drain", ondrain);
        source.removeListener("end", onend);
        source.removeListener("close", onclose);
        source.removeListener("error", onerror);
        dest.removeListener("error", onerror);
        source.removeListener("end", cleanup);
        source.removeListener("close", cleanup);
        return dest.removeListener("close", cleanup);
      };
      source = this;
      source.on("data", ondata);
      dest.on("drain", ondrain);
      if (!dest._isStdio && (!options || options.end !== false)) {
        source.on("end", onend);
        source.on("close", onclose);
      }
      didOnEnd = false;
      source.on("error", onerror);
      dest.on("error", onerror);
      source.on("end", cleanup);
      source.on("close", cleanup);
      dest.on("close", cleanup);
      dest.emit("pipe", source);
      return dest;
    };
    ref = new Stream;
    return {
      create: function() {
        return new Stream;
      },
      get: function() {
        return Stream;
      },
      pipe: ref.pipe
    };
  }
]);
