angular.module('bxSocket', [])

.service 'bxSocket', [
  '$rootScope', '$http', '$q', '$timeout', 'bxLogger'
  ($rootScope, $http, $q, $timeout, Logger) ->
    scope = null
    socket = null
    initialized = false
    open = false
    listeners = {}



    host = location.protocol + '//' + location.hostname
    if location.port then host += ':' + location.port

    load = (url) ->
      # create async promise
      deferred = $q.defer()
      promise = deferred.promise

      if window.io # if loaded, return resolved promise
        deferred.resolve true
        return promise

      # create script tag, config
      sio = document.createElement 'script'
      sio.type = 'text/javascript'
      sio.async = true

      # set script to url or relative socket.io link
      sio.src = url || '/socket.io/socket.io.js'

      # append to body
      _s = document.getElementsByTagName('script')[0]
      _s.parentNode.insertBefore sio, _s

      # recursive function to check if socket.io loaded
      wait = () ->
        setTimeout ->
          if window.io # if socket.io loaded
            return deferred.resolve true

          # else, call self
          wait()
        , 50 # fire every 0.05 seconds

      wait()
      return promise

    wrap = (cb) ->
      # TODO: *.apply arguments
      return (data) ->
        apply scope || $rootScope, ->
          cb && cb data

    isListening = (e, cb) ->
      # return false if no listeners for event exist
      return false if !listeners || !listeners[e]

      # loop through, return true if callback matches function
      for func in listeners[e]
        Logger.debug 'Debugging isListening func.',
          func: func
          cb: cb
        return true if func.toString() is cb.toString()

      # return false if couldn't find
      return false

    apply = (scope, fn) ->
      if scope.$$phase or scope.$root.$$phase
        fn()
      else
        scope.$apply fn

    # return methods
    get: () ->
      return socket

    isOpen: () ->
      return open

    setScope: (s) ->
      scope = s

    emit: (e, data, cb) ->
      if !socket or !open
        throw new Error 'Socket closed!'
        return false

      socket.emit e, data, ->
        apply scope || $rootScope, ->
          cb && cb()

    on: (e, cb) ->
      # if already callback already attached to event
      # return false if isListening e, cb

      socket.removeListener e, wrap cb
      socket.on e, wrap cb

      # add to listeners
      if !listeners[e]
        # if listeners for event don't exist, initialize array of listeners
        listeners[e] = [ cb ]
      else
        # else, add to array of listeners
        listeners[e].push cb

      ###
      socket.on e, (data) ->
        apply scope || $rootScope, ->
          cb && cb(data)
      ###

    isListening: (e, cb) ->
      return isListening e, cb

    removeListener: (e, cb) ->
      socket.removeListener e, wrap cb

      if listeners[e] && typeof listeners[e] is 'array'
        listeners[e].splice i, 1 for func, i in listeners[e] when cb is func

    removeAllListeners: ->
      socket.removeAllListeners()
      listeners = {}

    close: () ->
      if socket
        socket.disconnect()
        open = false

    open: (url, wait) ->
      deferred = $q.defer()

      # return resolved promise if open
      if open || (socket and socket.socket and socket.socket.connected)
        open = true if !open
        promise = deferred.promise
        deferred.resolve true
        return promise

      load(url).then () -> # call function to load script
        waiting = false; timedOut = false; delay = 0

        count = (max, deferred) -> # recursive timeout func
          Logger.debug 'Counting to ' + max + '... currently at ' +
            delay + '...'
          $timeout ->
            return false if !waiting
            if ++delay >= max
              timedOut = true
              Logger.error 'Socket.open() request timed out.'
              deferred.reject null
              return false
            else
              count max, deferred
          , 1000

        if !initialized
          socket = io.connect host
          initialized = true
        else
          # deferred.resolve true
          socket.socket.connect()

        # set socket error callback
        cb = (err) ->
          delay = 0; open = false; waiting = false
          deferred.reject err if deferred

        # set socket err callback
        socket.on 'uncaughtException', cb
        socket.on 'error', cb

        waiting = true; count wait || 10, deferred
        socket.on 'server:handshake', (data) ->
          return false if timedOut
          return false if !waiting

          delay = 0; open = true; waiting = false
          Logger.info 'Handshake successful.'

          # remove error callbacks
          socket.removeListener 'uncaughtException', cb
          socket.removeListener 'error', cb

          deferred.resolve data


        return deferred.promise
]
