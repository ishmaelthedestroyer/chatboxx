window.RoomPromptCtrl = [
  '$scope', '$modalInstance', '$state', '$stateParams',
  'noNotify', 'noLogger'
  ($s, $m, $state, $stateParams,
  Notify, Logger) ->

    $s.valid = false
    $s.working = false

    $s.room =
      action: 'find'
      name: sluggify $stateParams.id
      password: ''
      confirm: ''

    $s.modal =
      header: 'Preparing your room...'
      message: ''
      class: 'text-danger'

    $s.$on '$stateChangeStart', (e) ->
      e.preventDefault()

    $s.updateURL = () ->
      $location.path($s.room.name).replace()

    $s.validate = () ->
      if $s.room.name.length == 0
        $s.valid = false
        $s.modal.message = 'You must enter a room name.'
      else if $s.room.password.length == 0
        $s.valid = false
        $s.modal.message = 'You must enter a password.'
      else if $s.room.confirm.length == 0
        $s.valid = false
        $s.modal.message = 'You must confirm your password.'
      else if $s.room.password != $s.room.confirm
        $s.valid = false
        $s.modal.message = 'The passwords you entered don\'t match.'
      else
        $s.valid = true
        $s.modal.message = ''

    $s.updateURL()

    # event listener for room enter success / failure
    Socket.on 'rooms:enter', (data) ->
      apply $s, () -> $s.working = false

      # Socket.on 'rooms:error', (data) ->
      # Socket.emit 'rooms:enter', $s.room
      if data.message.result == 'success'
        Logger.debug 'Successfully entered the room.',
          response: data

        $m.close() # close modal

        apply $scope, () -> $scope.connected = true

        # request video stream
        $scope.toggleStream()

        # TODO: handle successful response
        deferred.resolve data
      else
        Logger.debug 'An error occured trying to enter the room.',
          response: data

        Notify.push data.message.message, 'danger', 4000

        apply $s, () ->
          $s.room.password = ''
          $s.room.confirm = ''

        # TODO: handle
        # deferred.reject data

    $s.submit = () ->
      return false if $s.working || !$s.valid

      Logger.debug 'Form submitted.',
        action: $s.room.action
        name: $s.room.name
        password: $s.room.password
        confirm: $s.room.confirm

      apply $s, () -> $s.working = true

      Socket.emit 'rooms:enter', $s.room

    $s.close = () ->
      $m.dismiss 'cancel'
      $state.go 'index'

    # # # # # # # # # #
    # # # # # # # # # #

    # check if password in URL
    $s.room.password = $location.search().p || ''

    # if password in URL
    if $s.room.password.length
      $s.room.confirm = $s.room.password
      $s.valid = true
      $s.submit()

    # check if password in url
    Logger.debug 'Checking params.', $location.search()

    apply = (scope, fn) ->
      if scope.$$phase or scope.$root.$$phase
        fn()
      else
        scope.$apply fn
]
