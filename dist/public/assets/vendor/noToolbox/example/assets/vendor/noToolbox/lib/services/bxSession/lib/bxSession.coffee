angular.module('bxSession.session', [])

.service 'bxSession', [
  '$rootScope', '$http', '$q'
  ($rootScope, $http, $q)->
    session = null
    authenticated = false
    scope = $rootScope

    # TODO: emit error object
    onError = () ->
      session = null
      authenticated = false

    api =
      login: '/api/login'
      logout: '/api/logout'
      signup: '/api/signup'
      session: '/api/session'

    loadSession = (override) ->
      deferred = $q.defer()
      promise = deferred.promise

      if !session or override
        $http.get(api.session)
        .success (data, status, headers, config) ->
          update 'loaded', ->
            session = data
            deferred.resolve data
        .error (data, status, headers, config) ->
          update 'error', ->
            onError && onError()
            deferred.reject {}
      else
        deferred.resolve session

      promise

    update = (emit, fn) ->
      if scope.$$phase or scope.$root.$$phase
        fn()
      else
        scope.$apply fn

      scope.$emit 'session:' + emit, session
      if emit isnt 'loaded'
        scope.$emit 'session:loaded', session

    config: (options) ->
      api.login = options.login if options.login
      api.logout = options.logout if options.logout
      api.signup = options.signup if options.signup
      api.session = options.session if options.session
      scope = options.scope if options.scope

      if options.onError
        if typeof options.onError isnt 'function'
          err = new Error 'bxSession.config() requires ' +
            'options.onError to be typeof == function'
        else
          onError = options.onError

    # return methods
    load: () ->
      loadSession false

    refresh: () ->
      loadSession true

    isAuthenticated: () ->
      authenticated

    login: (username, password) ->
      deferred = $q.defer()

      $http.post(api.login,
        username: username
        password: password
      ).success (data, status, headers, config) ->
        update 'login', () ->
          session = data
          authenticated = true
          deferred.resolve true
      .error (data, status, headers, config) ->
        update 'error', () ->
          onError && onError()
          deferred.reject false

      deferred.promise

    signup: (username, password) ->
      deferred = $q.defer()

      $http.post(api.signup,
        username: username
        password: password
      ).success (data, status, headers, config) ->
        update 'signup', () ->
          session = data
          authenticated = true
          deferred.resolve true
      .error (data, status, headers, config) ->
        update 'error', () ->
          onError && onError()
          deferred.reject false

      deferred.promise

    logout: () ->
      deferred = $q.defer()

      $http.get(api.logout)
      .success (data, status, headers, config) ->
        update 'logout', () ->
          session = null
          authenticated = false
          deferred.resolve true
      .error (data, status, headers, config) ->
        update 'error', () ->
          onError && onError()
          deferred.reject false

      deferred.promise
]



angular.module('bxSession.auth', [ 'bxSession.session' ])

.provider 'bxAuth', ->
  bxSession = null
  $location = null
  $state = null
  $q = null

  @auth = (options) ->
    return ->
      handleError = (err) ->
        err = new Error err
        console.log err
        throw err
        return false

      if !bxSession || !$location || !$state || !$q
        return handleError 'ERROR! bxAuth not initialized.'

      if !('authKey' of options)
        return handleError 'bxAuth requires options.authKey ' +
          'in the options object'
      else if !('reqAuth' of options)
        return handleError 'bxAuth requires options.reqAuth ' +
          'in the options object'
      else if !('redirAuth' of options)
        return handleError 'bxAuth requires options.redirAuth ' +
          'in the options object'

      authKey = options.authKey
      reqAuth = options.reqAuth
      redirAuth = options.redirAuth

      deferred = $q.defer()

      bxSession.load().then (session) ->
        checkAuth = () ->
          keys = authKey.split '.'
          ref = session
          i = 0

          while i < keys.length
            k = keys[i]
            return false if !ref[k]
            ref = ref[k]
            ++i

          return true

        if reqAuth
          # if route requires auth but user not authenticated
          if !session? || typeof session isnt 'object' or !checkAuth()
            deferred.resolve null

            # if not on reqAuth page, redirect
            if $state.current.name isnt reqAuth
              $state.go reqAuth
            else
              # already @ redirect target. this is a hack to fix the url
              # https://github.com/angular-ui/ui-router/issues/242
              $location.path $state.current.url
              $state.go reqAuth
          else
            deferred.resolve true
        else if redirAuth # if meant to redirect authenticated users
          # if already authenticated
          if session and Object.getOwnPropertyNames(session).length
            deferred.reject null

            # if not on redirAuth page, redirect
            if $state.current.name isnt redirAuth
              $state.go redirAuth
            else
              # already @ redirect target. this is a hack to fix the url
              # https://github.com/angular-ui/ui-router/issues/242
              $location.path $state.current.url
          else
            deferred.resolve true
        else
          deferred.resolve true

      deferred.promise

  @$get = () ->
    bootstrap: (_location, _state, _q, _bxSession) ->
      $location = _location
      $state = _state
      $q = _q
      bxSession = _bxSession

  return @



angular.module('bxSession', [ 'ui.router', 'bxSession.auth' ])

.run [
  '$rootScope', '$state', '$location', '$http', '$q','bxAuth', 'bxSession'
  ($rootScope, $state, $location, $http, $q, bxAuth, bxSession) ->
    # inject dependencies into bxAuth provider
    bxAuth.bootstrap $location, $state, $q, bxSession
]
