module.exports = function(server) {
  var Logger, connect, cookie, io, parse, redisCONFIG, socketRedisStore, util;
  util = require('../../lib/util');
  Logger = new (require('../../lib/logger'));
  redisCONFIG = require('../../config/app/redis');
  socketRedisStore = require('socket.io/lib/stores/redis');
  connect = require('express/node_modules/connect');
  cookie = require('cookie');
  parse = connect.utils.parseSignedCookie;
  io = require('socket.io').listen(server);
  io.configure(function() {
    io.enable('browser client minification');
    io.enable('browser client etag');
    io.enable('browser client gzip');
    io.set('log level', 1);
    io.set('store', new socketRedisStore({
      redis: redisCONFIG.redis,
      redisPub: redisCONFIG.createClient(),
      redisSub: redisCONFIG.createClient(),
      redisClient: redisCONFIG.createClient()
    }));
    io.set('logger', {
      debug: Logger.debug,
      info: Logger.info,
      error: Logger.error,
      warn: Logger.warn
    });
    return io.set('authorization', function(handshakeData, accept) {
      var hs;
      hs = handshakeData;
      if (hs.headers.cookie != null) {
        hs.cookie = cookie.parse(hs.headers.cookie);
        hs.sessionID = parse(hs.cookie['connect.sid'], redisCONFIG.secret);
        return redisCONFIG.sessionStore.get(hs.sessionID, function(err, session) {
          if (err || (session == null)) {
            Logger.warn('No cookie submitted on connection.');
            return accept('No cookie submitted on connection.', false);
          } else {
            Logger.debug('Authorized session found.');
            hs.uuid = session.uuid || util.uuid();
            hs.name = session.name || 'user-' + util.random(15);
            return accept(null, true);
          }
        });
      } else {
        Logger.debug('Error. No cookie transmitted.');
        return accept('No cookie transmitted.', false);
      }
    });
  });
  return io;
};
