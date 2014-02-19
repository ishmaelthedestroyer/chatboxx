window.RoomPromptCtrl = [
  '$scope', '$rootScope', '$modalInstance', '$state',
  '$stateParams', '$location'
  'noNotify', 'noLogger', 'noUtil', 'noSocket'
  ($s, $rootScope, $m, $state,
  $stateParams, $location
  Notify, Logger, Util, Socket) ->

    $s.valid = false
    $s.working = false

    $s.room =
      action: 'find'
      name: Util.sluggify $stateParams.id
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
      Util.safeApply $s, () -> $s.working = false

      # Socket.on 'rooms:error', (data) ->
      # Socket.emit 'rooms:enter', $s.room
      if data.message.result == 'success'
        $m.close() # close modal

        $rootScope.$broadcast 'rooms:enter', data
      else
        Logger.debug 'An error occured trying to enter the room.',
          response: data

        Notify.push data.message.message, 'danger', 4000

        Util.safeApply $s, () ->
          $s.room.password = ''
          $s.room.confirm = ''

    $s.submit = () ->
      return false if $s.working || !$s.valid

      Logger.debug 'Form submitted.',
        action: $s.room.action
        name: $s.room.name
        password: $s.room.password
        confirm: $s.room.confirm

      Util.safeApply $s, () -> $s.working = true

      Socket.emit 'rooms:enter', $s.room

    $s.close = () ->
      $m.dismiss 'cancel'
      $state.go 'index'

    # # # # # # # # # #
    # # # # # # # # # #

    # check if password in URL
    $s.room.password = $location.search().p || $location.search().password || ''

    # if password in URL
    if $s.room.password.length
      $s.room.confirm = $s.room.password
      $s.valid = true
      $s.submit()
]
