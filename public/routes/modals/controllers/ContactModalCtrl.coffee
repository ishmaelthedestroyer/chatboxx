window.ContactModalCtrl = [
  '$scope', '$modalInstance', 'noResource', 'noNotify', 'noLogger'
  ($s, $m, Resource, Notify, Logger) ->
    $s.close = () ->
      $m.dismiss 'cancel'

    Message = Resource.get 'Messages'

    $s.working = false

    $s.message =
      name: ''
      email: ''
      message: ''

    EMAIL_REGEXP = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/

    $s.promptName = ''
    $s.statusName = 'warning'
    $s.validName = false
    $s.validateName = () ->
      if !$s.message.name.length
        $s.promptName = ''
        $s.statusName = 'warning'
        $s.validName = false
        return 'empty'

      else if $s.message.name.length < 3
        $s.promptName = 'Name too short.'
        $s.statusName = 'error'
        $s.validName = false
        return 'invalid'

      else
        $s.promptName = ''
        $s.statusName = 'success'
        $s.validName = true
        return 'valid'

    $s.promptEmail = ''
    $s.statusEmail = 'warning'
    $s.validEmail = false
    $s.validateEmail = () ->
      if !$s.message.email.length
        $s.promptEmail = ''
        $s.statusEmail = 'warning'
        $s.validEmail = false
        return 'empty'

      else if EMAIL_REGEXP.test $s.message.email
        $s.promptEmail = ''
        $s.statusEmail = 'success'
        $s.validEmail = true
        return 'valid'

      else
        $s.promptEmail = 'Invalid email.'
        $s.statusEmail = 'error'
        $s.validEmail = false
        return 'Invalid email.'

    $s.promptMessage = ''
    $s.statusMessage = 'warning'
    $s.validMessage = false
    $s.validateMessage = () ->
      if !$s.message.message.length

        $s.promptMessage = ''
        $s.statusMessage = 'warning'
        $s.validMessage = false
        return 'empty'

      else if $s.message.message.length < 10
        $s.promptMessage = 'Message too short.'
        $s.statusMessage = 'error'
        $s.validMessage = false
        return 'invalid'
      else

        $s.promptMessage = ''
        $s.statusMessage = 'success'
        $s.validMessage = true
        return 'valid'

    $s.send = () ->
      $s.working = true
      Logger.debug 'Sending message...',

      message = new Message
        name: $s.message.name
        email: $s.message.email
        message: $s.message.email

      message.$save (data, headers) ->
        apply $s, () ->
          $s.working = false
          $s.message =
            name: ''
            email: ''
            message: ''

          $m.dismiss 'cancel'

          Notify.push 'Your message has been sent.', 'success', 3000

    apply = (scope, fn) ->
      if scope.$$phase or scope.$root.$$phase
        fn()
      else
        scope.$apply fn
]
