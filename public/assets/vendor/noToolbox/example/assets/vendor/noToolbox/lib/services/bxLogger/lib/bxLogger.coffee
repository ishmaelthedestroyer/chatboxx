angular.module('bxLogger', [])

.service 'bxLogger', [
  '$http',
  ($http) ->
    config =
      mode: 'development' # || production
      sentry: '/api/sentry' # destination URL
      output: null # array to output [ 'debug', 'info' ... ]
      notify: null # array to notify [ 'warn', 'error', 'global' ... ]

    ### Logic below defaults to:
    mode: 'development'
    sentry: '/api/sentry'
    output: [ 'debug', 'info', 'warn', 'error']
    notify: [ 'warn', 'error', 'global' ]
    ###

    notify = (type, message, info) ->
      $http.post config.sentry,
        mode: config.mode
        type: type
        message: message
        info: info || {}

    window.onerror = (msg, url, line) ->
      if (config.notify instanceof Array and 'global' in config.notify) or
        (!config.output and config.mode is 'production')
          notify 'global', 'An unhandled error occured.',
            msg: msg
            url: url
            line: line

    setMode = (m) ->
      config.mode = m

    setSentry = (s) ->
      config.sentry = s

    debug: (msg, info) ->
      color = 'color: #333; background-color: #fff;'

      if (config.output instanceof Array and 'debug' in config.output) or
        (!config.output and config.mode is 'development')
          console.log '%c DEBUG >> ' + msg, color, info || ''

      if config.notify instanceof Array and 'debug' in config.notify
        notify 'debug', msg, info

    info: (msg, info) ->
      color = 'color: #5E9CD2; background-color: #fff;'

      if (config.output instanceof Array and 'info' in config.output) or
        (!config.output and config.mode is 'development')
          console.log '%c INFO >> ' + msg, color, info || ''

      if config.notify instanceof Array and 'info' in config.notify
        notify 'debug', msg, info

    warn: (msg, info) ->
      color = 'color: #FF9900; background-color: #fff;'

      if (config.output instanceof Array and 'warn' in config.output) or
        (!config.output and config.mode is 'development')
          console.log '%c WARNING >> ' + msg, color, info || ''

      if (config.notify instanceof Array and 'warn' in config.notify) or
        (!config.notify and config.mode is 'production')
          notify 'warn', msg, info

    error: (msg, info) ->
      color = 'color: #f00; background-color: #fff;'

      if (config.output instanceof Array and 'error' in config.output) or
        (!config.output and config.mode is 'development')
          console.log '%c ERROR >> ' + msg, color, info || ''

      if (config.notify instanceof Array and 'error' in config.notify) or
        (!config.notify and config.mode is 'production')
          notify 'error', msg, info
]
