angular.module('bxQueue', [])

.factory 'bxQueue', [
  '$rootScope', '$timeout'
  ($rootScope, $timeout) ->
    queue = []
    scope = $rootScope

    apply = (scope, fn) ->
      if scope.$$phase or scope.$root.$$phase
        fn()
      else
        scope.$apply fn

    remove = (promise, callback) ->
      apply scope, () ->
        i = 0
        while i < queue.length
          if queue[i] is promise
            queue.splice i, 1
            callback? callback()
            break
          ++i

    # return methods
    setScope: (s) ->
      scope = s
    list: () ->
      queue
    push: (promise, timeout, callback) ->
      # add to queue
      apply scope, () ->
        queue.push promise

      # when resolved (or rejected), remove from queue
      promise.then () ->
        remove promise, callback
      , (err) ->
        remove promise, callback

      # if timeout set, remove & call optional callback
      if timeout
        $timeout ->
          remove promise, callback
        , timeout
    remove: (promise) ->
      remove promise
    clear: () ->
      remove promise for promise in queue
      ###
      apply scope, () ->
        queue = []
      ###
]
