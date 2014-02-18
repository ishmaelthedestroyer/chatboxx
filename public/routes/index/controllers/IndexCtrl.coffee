app.controller 'IndexCtrl', [
  '$scope', '$state'
  ($scope, $state) ->
    apply = (scope, fn) ->
      if scope.$$phase or scope.$root.$$phase
        fn()
      else
        scope.$apply fn
]
