app.controller 'RoomCtrl', [
  '$scope', '$state', 'noLogger'
  ($scope, $state, Logger) ->

    apply = (scope, fn) ->
      if scope.$$phase or scope.$root.$$phase
        fn()
      else
        scope.$apply fn
]
