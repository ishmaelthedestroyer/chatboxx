app.controller 'RoomCtrl', [
  '$scope', '$rootScope', '$state', '$stateParams', '$q', '$modal', '$location'
  'noLogger', 'noSocket', 'noNotify', 'noSession', 'noQueue', 'noUtil'
  ($scope, $rootScope, $state, $stateParams, $q, $modal, $location
  Logger, Socket, Notify, Session, Queue, Util) ->
    # go to home page if no room id
    return $state.go 'index' if !$stateParams.id

    $scope.self = {}
    $scope.connected = false

    # # # # # # # # # # # # # # # # # # # #
    # # # # # # # # # # # # # # # # # # # #

    content = document.getElementById 'snap-content'
    dragger = document.getElementById 'chat-btn'

    snapper = new Snap
      element: content
      dragger: dragger
      disable: 'right'
      maxPosition: 450

    dragger.addEventListener 'click', (e) ->
      e.preventDefault()
      e.stopPropagation()

      if snapper.state().state is 'left'
        snapper.close()
      else
        snapper.open 'left'
    , false

    setTimeout ->
      snapper.open 'left'
    , 500

    # # # # # # # # # # # # # # # # # # # #
    # # # # # # # # # # # # # # # # # # # #

    # create deferred object for connection
    deferred = $q.defer()
    Queue.push deferred.promise

    Session.load()
    .then () ->
      Socket.open() # open socket
      .then (data) ->
        deferred.resolve true # resolve promise, remove loader icon
        $scope.self = data.message # info on socket returned from server

        # prompt for room + password
        modal = do -> $modal.open
          backdrop: true
          keyboard: false
          backdropClick: false
          templateUrl: '/routes/modals/views/roomPrompt.html'
          windowClass: 'modal'
          controller: window.RoomPromptCtrl
      , (err) ->
        deferred.reject err
        $state.go 'index'
        Notify.push 'Error connecting to room.', 'danger', 5000

    # # # # # # # # # # # # # # # # # # # #
    # # # # # # # # # # # # # # # # # # # #

    # listeners
    $rootScope.$on 'rooms:enter', (e, data) ->
      Logger.debug 'Succesfully connected to room.'

      # # # # # # # # # #

      Util.safeApply $scope, () -> $scope.connected = true

      # # # # # # # # # #

      Socket.on 'server', (data) -> # message from server
        Notify.push data.message, 'warning', 4000

      # # # # # # # # # #

      $scope.$on '$destroy', () ->
        Logger.debug 'Scope destroyed.'

        Socket.removeAllListeners()
        Socket.close()
        Queue.clear()

      # # # # # # # # # #

      Socket.on 'rooms:error', (data) -> # room error
        Socket.close() # kill socket connection
        $state.go 'index' # redirect home

    # # # # # # # # # # # # # # # # # # # #
    # # # # # # # # # # # # # # # # # # # #
]