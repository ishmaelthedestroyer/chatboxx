app.controller 'IndexCtrl', [
  '$scope', '$state', 'noLogger'
  ($scope, $state, Logger) ->
    $scope.room = ''

    $scope.enter = () ->
      return false if !$scope.room.length

      Logger.debug $scope.room
      $state.go 'room', id: $scope.room

    $scope.help = () ->
      e = document.getElementById 'help'
      if !!e && e.scrollIntoView
        e.scrollIntoView()

    ###
    $scope.help = () ->
      window.scroll(0,findPos(document.getElementById("help")) + 100)

    #Finds y value of given object
    findPos = (obj) ->
      curtop = 0
      if obj.offsetParent
        loop
          curtop += obj.offsetTop
          break unless obj = obj.offsetParent
        [curtop]
    ###

    apply = (scope, fn) ->
      if scope.$$phase or scope.$root.$$phase
        fn()
      else
        scope.$apply fn
]
