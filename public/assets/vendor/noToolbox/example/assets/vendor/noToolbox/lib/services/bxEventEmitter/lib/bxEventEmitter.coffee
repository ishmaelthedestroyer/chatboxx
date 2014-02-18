angular.module('bxEventEmitter', [ 'bxUtil' ])

.service 'bxEventEmitter', [ 'bxUtil', (util) ->
  EventEmitter = ->
    @_events = @_events or {}
    @_maxListeners = @_maxListeners or 'undefined'

  # Backwards-compat with node 0.10.x
  EventEmitter.EventEmitter = EventEmitter
  EventEmitter::_events = 'undefined'
  EventEmitter::_maxListeners = 'undefined'

  # By default EventEmitters will print a warning if more than 10 listeners are
  # added to it. This is a useful default which helps finding memory leaks.
  EventEmitter.defaultMaxListeners = 10

  # Obviously not all Emitters should be limited to 10. This function allows
  # that to be increased. Set to zero for unlimited.
  EventEmitter::setMaxListeners = (n) ->
    if not util.isNumber(n) or n < 0
      throw TypeError("n must be a positive number")

    @_maxListeners = n
    this

  EventEmitter::emit = (type) ->
    er = undefined
    handler = undefined
    len = undefined
    args = undefined
    i = undefined
    listeners = undefined
    @_events = {}  unless @_events

    # If there is no 'error' event listener then throw.
    if type is "error"
      if not @_events.error or (util.isObject(@_events.error) and
      not @_events.error.length)
        er = arguments_[1]
        if er instanceof Error
          throw er # Unhandled 'error' event
        else
          throw TypeError("Uncaught, unspecified \"error\" event.")
        return false
    handler = @_events[type]
    return false  if util.isUndefined(handler)
    if util.isFunction(handler)
      switch arguments_.length

        # fast cases
        when 1
          handler.call this
        when 2
          handler.call this, arguments_[1]
        when 3
          handler.call this, arguments_[1], arguments_[2]

        # slower
        else
          len = arguments_.length
          args = new Array(len - 1)
          i = 1
          while i < len
            args[i - 1] = arguments_[i]
            i++
          handler.apply this, args
    else if util.isObject(handler)
      len = arguments_.length
      args = new Array(len - 1)
      i = 1
      while i < len
        args[i - 1] = arguments_[i]
        i++
      listeners = handler.slice()
      len = listeners.length
      i = 0
      while i < len
        listeners[i].apply this, args
        i++
    true

  EventEmitter::addListener = (type, listener) ->
    m = undefined

    if !util.isFunction(listener)
      throw TypeError("listener must be a function")

    @_events = {}  unless @_events

    # To avoid recursion in the case that type === "newListener"! Before
    # adding it to the listeners, first emit "newListener".
    if @_events.newListener
      if util.isFunction listener.listener
        l = listener.listener
      else
        l = listener
      @emit "newListener", type, l

    unless @_events[type]

      # Optimize the case of one listener. Don't need the extra array object.
      @_events[type] = listener
    else if util.isObject(@_events[type])

      # If we've already got an array, just append.
      @_events[type].push listener

    # Adding the second element, need to change to array.
    else
      @_events[type] = [@_events[type], listener]

    # Check for listener leak
    if util.isObject(@_events[type]) and not @_events[type].warned
      m = undefined
      unless util.isUndefined(@_maxListeners)
        m = @_maxListeners
      else
        m = EventEmitter.defaultMaxListeners
      if m and m > 0 and @_events[type].length > m
        @_events[type].warned = true
        console.error "(node) warning: possible EventEmitter memory " +
          "leak detected. %d listeners added. " +
          "Use emitter.setMaxListeners() to increase limit.",
          @_events[type].length
        console.trace()
    this

  EventEmitter::on = EventEmitter::addListener
  EventEmitter::once = (type, listener) ->
    g = ->
      @removeListener type, g
      listener.apply this, arguments_
    if !util.isFunction(listener)
      throw TypeError("listener must be a function")
    g.listener = listener
    @on type, g
    this


  # emits a 'removeListener' event iff the listener was removed
  EventEmitter::removeListener = (type, listener) ->
    list = undefined
    position = undefined
    length = undefined
    i = undefined
    if !util.isFunction(listener)
      throw TypeError("listener must be a function")

    return this  if not @_events or not @_events[type]
    list = @_events[type]
    length = list.length
    position = -1
    if list is listener or
    (util.isFunction(list.listener) and list.listener is listener)
      delete @_events[type]

      @emit "removeListener", type, listener  if @_events.removeListener
    else if util.isObject(list)
      i = length
      while i-- > 0
        if list[i] is listener or (list[i].listener and
        list[i].listener is listener)
          position = i
          break
      return this  if position < 0
      if list.length is 1
        list.length = 0
        delete @_events[type]
      else
        list.splice position, 1
      @emit "removeListener", type, listener  if @_events.removeListener
    this

  EventEmitter::removeAllListeners = (type) ->
    key = undefined
    listeners = undefined
    return this  unless @_events

    # not listening for removeListener, no need to emit
    unless @_events.removeListener
      if arguments_.length is 0
        @_events = {}
      else delete @_events[type]  if @_events[type]
      return this

    # emit removeListener for all listeners on all events
    if arguments_.length is 0
      for key of @_events
        continue  if key is "removeListener"
        @removeAllListeners key
      @removeAllListeners "removeListener"
      @_events = {}
      return this
    listeners = @_events[type]
    if util.isFunction(listeners)
      @removeListener type, listeners
    else

      # LIFO order
      while listeners.length
        @removeListener type, listeners[listeners.length - 1]
    delete @_events[type]

    this

  EventEmitter::listeners = (type) ->
    ret = undefined
    if not @_events or not @_events[type]
      ret = []
    else if util.isFunction(@_events[type])
      ret = [@_events[type]]
    else
      ret = @_events[type].slice()
    ret

  EventEmitter.listenerCount = (emitter, type) ->
    ret = undefined
    if not emitter._events or not emitter._events[type]
      ret = 0
    else if util.isFunction(emitter._events[type])
      ret = 1
    else
      ret = emitter._events[type].length
    ret

  ref = new EventEmitter

  # return methods
  create: () ->
    return new EventEmitter
  get: () ->
    return EventEmitter
  setMaxListeners: ref.setMaxListeners
  emit: ref.emit
  addListener: ref.addListener
  on: ref.on
  once: ref.once
  removeListener: ref.removeListener
  removeAllListeners: ref.removeAllListeners
  listeners: ref.listeners
]
