app.controller 'RoomCtrl', [
  '$scope', '$rootScope', '$state', '$stateParams', '$q',
  '$modal', '$location', '$sce'
  'noLogger', 'noSocket', 'noNotify', 'noSession', 'noQueue', 'noUtil'
  ($scope, $rootScope, $state, $stateParams, $q,
  $modal, $location, $sce
  Logger, Socket, Notify, Session, Queue, Util) ->
    # go to home page if no room id
    return $state.go 'index' if !$stateParams.id

    $scope.self = {}
    $scope.connected = false
    $scope.streams = []
    $scope.users = []

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
      $rootScope.$broadcast 'initialize' # tell other controllers to initialize
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

      Socket.on 'users:self', (data) -> # info on socket
        $scope.self = data.message

      # # # # # # # # # #

      Socket.on 'users:update', (data) -> # update user info
        for user, i in $scope.users when user.socket is data.message.socket
          return $scope.users[i] = x

      # # # # # # # # # #

      Socket.on 'users:all', (data) -> # update all roommates
        $scope.users = []
        for user in data.message when user not in $scope.users
          $scope.users.push user

      # # # # # # # # # #

      Socket.on 'rooms:error', (data) -> # room error
        Socket.close() # kill socket connection
        $state.go 'index' # redirect home

    # # # # # # # # # # # # # # # # # # # #
    # # # # # # # # # # # # # # # # # # # #

    $rootScope.$on 'stream:attach', (e, stream) ->
      Logger.debug 'Attaching stream.', stream
      stream.user = $scope.self.socket if !stream.user

      Util.safeApply $scope, () ->
        $scope.streams.push stream

    # # # # # # # # # # # # # # # # # # # #
    # # # # # # # # # # # # # # # # # # # #

    $rootScope.$on 'stream:detach', (e, stream) ->
      Logger.debug 'Detaching stream.', stream
      stream.user = $scope.self.socket if !stream.user

      for s, i in $scope.streams
        if stream.user is s.user and stream.type is s.type
          Util.safeApply $scope, () ->
            $scope.streams.splice i, 1

      $scope.$broadcast 'resizeCluster'

    # # # # # # # # # # # # # # # # # # # #
    # # # # # # # # # # # # # # # # # # # #

    MUTED = false

    $rootScope.$on 'mute', (e, val) ->
      MUTED = val
      stream.muted = MUTED for stream in $scope.streams

    # # # # # # # # # # # # # # # # # # # #
    # # # # # # # # # # # # # # # # # # # #

    # helper functions

    $scope.getName = (id) -> # get username from id
      for user in $scope.users
        return user.name if user.socket is id

    $scope.checkMuted = (stream) -> # trust url for interpolation
      return true if MUTED
      return true if stream.muted
      return true if stream.user is $scope.self.socket
      return false

    $scope.trustSrc = (src) -> # trust url for interpolation
      Logger.debug '$scope.trustSrc got src.', src
      return $sce.trustAsResourceUrl src
]