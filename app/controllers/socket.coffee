EventEmitter = require('events').EventEmitter
_ = require 'underscore'
$q = require 'q'

redisCONFIG = require '../../config/app/redis'
util = require '../../lib/util'

Logger = new (require '../../lib/logger')

# # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #

Server = (io) ->
  if !(@ instanceof Server)
    return new Server io

  EventEmitter.call @

  util.extend @, util
  util.extend @, Logger
  util.inherits @, EventEmitter

  @rclient = redisCONFIG.createClient()
  @io = io || null
  @init()

  return @

# # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #

Server::init = () ->
  @io.sockets.on 'connection', (socket) =>
    # get session data, add username to socket if doesn't exist
    # TODO: lowercase username only, sluggify
    hs = socket.handshake
    name = hs.name
    uuid = hs.uuid

    @debug 'Socket connected to server.',
      uuid: hs.uuid
      name: name

    $q.fcall =>
      @debug 'Preparing multi().'
      deferred = $q.defer()

      # create user hash, set name, add to list of users
      multi = @rclient.multi()
      multi.hset 'users:user:' + socket.id, 'socket', socket.id
      multi.hset 'users:user:' + socket.id, 'uuid', uuid
      multi.hset 'users:user:' + socket.id, 'name', name
      multi.sadd 'users:all', socket.id

      @debug 'Multi prepared... executing...'

      multi.exec (err, result) =>
        if err
          # TODO: disconnect socket connection on error
          @error 'An error happened initializing the user.'
          return deferred.reject err
        return deferred.resolve result
      return deferred.promise
    .then (result) =>
      @debug 'Successfully added user to db.', result

      # attach event listeners
      socket.on 'rooms:enter', (data) => @enter socket.id, data
      socket.on 'users:update', (data) => @update socket.id, 'name', data
      socket.on 'users:message', (data) => @message socket.id, data
      socket.on 'disconnect', () => @close socket.id

      # notify accepted connection, send data about socket
      @notify socket.id, 'server:handshake',
        name: name
        socket: socket.id
    , (err) ->
      @error 'An error occurred adding the user to the db.', err

# # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #

# user sent message
Server::message = (id, data) ->
  # TODO: validate message
  _.each data.to, (x) => # loop through recipients
    @notify x, 'users:message', data  # send

# # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #

Server::notify = (id, e, data) ->
  # @debug 'Arguments.', arguments

  @debug 'Notifying socket.',
    id: id
    e: e
    # data: data

  @io.sockets.socket(id).emit e,
    date: new Date()
    message: data

# # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #

Server::update = (id, attr, data) -> # update socket
  # TODO: filter name; verify `typeof string`, sluggify
  multi = @rclient.multi()
  multi.hset 'users:user:' + id, attr, data # update user's hash
  multi.hgetall 'users:user:' + id  # get full hash
  multi.exec (err, result) =>
    if err
      @error 'An error occured at @::update()',
        id: id
        attr: attr
        data: data
        err: err
    else
      update = result[1]
      @notify id, 'users:self', update # send back new socket info

      # get room
      @rclient.smembers 'rooms:room:' + result[1].room, (err, users) =>
        if err
          @error 'An error occured get room members at @::update()',
            id: id
            attr: attr
            data: data
            err: err
        else
          @debug 'Sending users updated info.',
            users: users
            results: result
            update: update
          _.each users, (x) =>
            @notify x, 'users:update', update # notify sockets

# # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #

Server::enter = (id, room) ->
  @debug 'Attempting to enter room.', room

  MAX_USERS = 8

  # validate params
  if !room.name || !room.password || !room.confirm
    return @notify id, 'rooms:enter',
      result: 'fail'
      message: 'Missing information.'
  else if room.password != room.confirm
    return @notify id, 'rooms:enter',
      result: 'fail'
      message: 'Passwords don\'t match.'

  roomHash = 'ROOM' + room.name + 'PASS' + room.password

  # check if room exists
  @rclient.smembers 'rooms:room:' + roomHash, (err, result) =>
    if err
      return @error 'Uh-oh. An error occured entering the room.',
        err: err

    @debug 'Got room hash.', result

    if result.length >= MAX_USERS
      return @notify id, 'rooms:enter',
        result: 'fail'
        message: 'Sorry, the room is full. Upto ' + MAX_USERS +
          ' users allowed per room.'

    multi = @rclient.multi()
    multi.hset 'users:user:' + id, 'room', roomHash # add room to socket's hash
    multi.sadd 'rooms:room:' + roomHash, id # add socket to room
    multi.smembers 'rooms:room:' + roomHash # get members of room
    multi.exec (err, result) =>
      if err
        # TODO: handle error
        @error 'An error occured.',
          err: err
          result: result
      else
        @debug 'A user entered a room.',
          id: id
          room: room

        @notify id, 'rooms:enter',
          result: 'success'
          room: room # notify socket

        promises = []
        _.each result[2], (x) => # loop through ids of connected users
          deferred = $q.defer()
          promises.push deferred.promise
          @rclient.hgetall 'users:user:' + x, (err, result) => # get user hash
            if err
              # TODO: handle err
              @error 'An error occured retrieving user hashes at @::close()',
                err: err
                result: result
            else
              deferred.resolve result

        $q.all(promises)
        .then (users) =>
          _.each result[2], (x) =>
            @notify x, 'users:enter', id if x isnt id # notify entry
            @notify x, 'users:all', users # send remaining users

# # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #

Server::close = (id) ->
  @debug 'Attemping to close socket.'
  @rclient.hget 'users:user:' + id, 'room', (err, result) =>
    if err
      # TODO: handle err
    else
      # @io.sockets.sockets[id]
      multi = @rclient.multi()
      multi.del 'users:user:' + id # delete user hash
      multi.srem 'users:all', id # remove from list of connected users
      multi.srem 'rooms:room:' + result, id # remove from list of rooms
      multi.smembers 'rooms:room:' + result # get remaining members
      multi.exec (err, result) =>
        if err
          # TODO: handle err
          @debug 'Uh-oh. An error occured closing the socket.',
            err: err
            result: result
        else
          @debug 'Closed socket.',
            err: err
            result: result

          promises = []
          _.each result[3], (x) => # loop through ids of connected users
            deferred = $q.defer()
            promises.push deferred.promise
            @rclient.hgetall 'users:user:' + x, (err, result) => # get user hash
              if err
                @error 'An error occured retrieving user hashes at @::close()',
                  err: err
                  result: result
              else
                deferred.resolve result

          $q.all(promises)
          .then (users) =>
            _.each result[3], (x) =>
              # notify exit to rest of users
              @notify x, 'users:exit', id if x isnt id
              @notify x, 'users:all', users # send remaining users

# # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # #

module.exports = (io) ->
  return Server io