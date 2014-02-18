angular.module('bxStream', [ 'bxUtil', 'bxEventEmitter' ])

.service 'bxStream', [ 'bxUtil', 'bxEventEmitter',  (util, EventEmitter) ->
  EE = EventEmitter.get()

  Stream = ->
    EE.call this

  util.inherits Stream, EE

  Stream::pipe = (dest, options) ->
    ondata = (chunk) ->
      if dest.writable
        source.pause()  if false is dest.write(chunk) and source.pause

    ondrain = ->
      source.resume()  if source.readable and source.resume

    # If the 'end' option is not supplied, dest.end() will be called when
    # source gets the 'end' or 'close' events.  Only dest.end() once.
    onend = ->
      return  if didOnEnd
      didOnEnd = true
      dest.end()

    onclose = ->
      return  if didOnEnd
      didOnEnd = true
      dest.destroy()  if typeof dest.destroy is "function"

    # don't leave dangling pipes when there are errors.
    onerror = (er) ->
      cleanup()
      # Unhandled stream error in pipe.
      throw er  if EE.listenerCount(this, "error") is 0

    # remove all the event listeners that were added.
    cleanup = ->
      source.removeListener "data", ondata
      dest.removeListener "drain", ondrain
      source.removeListener "end", onend
      source.removeListener "close", onclose
      source.removeListener "error", onerror
      dest.removeListener "error", onerror
      source.removeListener "end", cleanup
      source.removeListener "close", cleanup
      dest.removeListener "close", cleanup

    source = this
    source.on "data", ondata
    dest.on "drain", ondrain

    if not dest._isStdio and (not options or options.end isnt false)
      source.on "end", onend
      source.on "close", onclose

    didOnEnd = false
    source.on "error", onerror
    dest.on "error", onerror
    source.on "end", cleanup
    source.on "close", cleanup
    dest.on "close", cleanup
    dest.emit "pipe", source

    # Allow for unix-like usage: A.pipe(B).pipe(C)
    dest

  ref = new Stream

  # return methods
  create: () ->
    return new Stream
  get: () ->
    return Stream
  pipe: ref.pipe
]
