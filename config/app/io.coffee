module.exports = (server) ->
  util = require '../../lib/util'
  Logger = new (require '../../lib/logger')

  redisCONFIG = require '../../config/app/redis'

  socketRedisStore = require 'socket.io/lib/stores/redis'
  connect = require 'express/node_modules/connect'
  cookie = require 'cookie'
  parse = connect.utils.parseSignedCookie

  io = require('socket.io').listen(server)

  io.configure () ->
    io.enable 'browser client minification' # send minified client
    io.enable 'browser client etag' # apply etag caching l
    io.enable 'browser client gzip' # gzip the file
    io.set 'log level', 1 # reduce logging

    io.set 'store', new socketRedisStore
      redis: redisCONFIG.redis
      redisPub: redisCONFIG.createClient()
      redisSub: redisCONFIG.createClient()
      redisClient: redisCONFIG.createClient()

    io.set 'logger',
      debug: Logger.debug
      info: Logger.info
      error: Logger.error
      warn: Logger.warn

    io.set 'authorization', (handshakeData, accept) ->
      hs = handshakeData

      if hs.headers.cookie?
        hs.cookie = cookie.parse hs.headers.cookie
        hs.sessionID = parse hs.cookie['connect.sid'], redisCONFIG.secret

        redisCONFIG.sessionStore.get hs.sessionID, (err, session) ->
          if err or !session?
            Logger.warn 'No cookie submitted on connection.'
            accept 'No cookie submitted on connection.', false
          else
            Logger.debug 'Authorized session found.'

            # find or generate uuid + username
            hs.uuid = session.uuid || util.uuid()
            hs.name = session.name || 'user-' + util.random 15

            accept null, true # forward valid connection.
      else
        Logger.debug 'Error. No cookie transmitted.'
        return accept 'No cookie transmitted.', false

  return io
