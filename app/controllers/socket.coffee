EventEmitter = require('events').EventEmitter
ss = require 'socket.io-stream'
$q = require 'q'
fs = require 'fs'

redisCONFIG = require '../../config/app/redis'
util = require '../../lib/util'

Logger = new (require '../../lib/logger')

# # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #

Server = (io) ->
  if !(@ instanceof Server)
    return new Server io

  EventEmitter.call @

  @io = io || null
  @init()

  util.extend @, Logger
  util.inherits @, EventEmitter

  return @

# # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #

Server::init = () ->
  @io.sockets.on 'connection', (socket) =>
    hs = socket.handshake
    @debug 'Socket connected to server.'
    @notify socket.id, 'server:handshake',
      'Successfully connected to the server.'

# # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #

Server::notify = (id, e, data) ->
  # @debug 'Arguments.', arguments

  @debug 'Notifying socket.',
    id: id
    e: e
    # data: data

  @io.sockets.socket(id).emit e, data

# # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #

Server::toArrayBuffer = (buffer) ->
  ab = new ArrayBuffer buffer.length
  view = new Uint8Array ab
  i = 0
  while i < buffer.length
    view[i] = buffer[i]
    ++i
  return view

# # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #

Server::close = (socket) ->
  # TODO: ...

# # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #

module.exports = (io) ->
  return Server io
