app.controller 'ChatCtrl', [
  '$scope', '$state', 'noLogger', 'noSocket'
  ($scope, $state, Logger, Socket) ->

    $scope.messages = [
        author: 'ishmael'
        date: new Date()
        body: 'Whaddddup'
      ,
        author: 'pops'
        date: new Date()
        body: 'testing, testing'

    ]


    apply = (scope, fn) ->
      if scope.$$phase or scope.$root.$$phase
        fn()
      else
        scope.$apply fn
]