app.controller 'ChatCtrl', [
  '$scope', '$rootScope', '$state', 'noLogger', 'noSocket', 'noUtil'
  ($scope, $rootScope, $state, Logger, Socket, Util) ->
    $scope.focus = 'GROUP'
    $scope.messages = []
    $scope.message = ''

    $rootScope.$on 'initialize', () ->
      Socket.on 'users:message', (data) -> # received message
        Logger.debug 'Received message.', data

        # if public message
        if data.message.type is 'group'
          Logger.debug 'Received group message.'

          Util.safeApply $scope, () ->
            addMessage
              date: data.date
              message: data.message.message
              from: data.message.from
              to: data.message.to
              type: 'group'
        else if data.message.type is 'private'
          Logger.debug 'Received private message.'

          Util.safeApply $scope, () ->
            addMessage
              date: data.date
              message: data.message.message
              from: data.message.from
              to: data.message.to
              type: 'private'
        else
          # pass to RTC
          RTC.handle data.message

    addMessage = (message) ->
      $scope.messages.push message if message not in $scope.messages

    getSocket = () ->
      if $scope.$parent.self
        return $scope.$parent.self.socket
      else if $scope.$parent.$parent.self
        return $scope.$parent.$parent.self.socket
      else if $scope.$parent.$parent.$parent.self
        return $scope.$parent.$parent.$parent.self.socket

    getRecepients = () ->
      return [ $scope.focus, getSocket() ] if $scope.focus isnt 'GROUP'

      recepients = []
      users = []

      if $scope.$parent.users
        users = $scope.$parent.users
      else if $scope.$parent.$parent.self
        users = $scope.$parent.$parent.users
      else if $scope.$parent.$parent.$parent.users
        users = $scope.$parent.$parent.$parent.users

      recepients.push user.socket for user in users
      return recepients

    $scope.chat = () ->
      return false if !$scope.message.length

      message =
        to: getRecepients()
        from: getSocket()
        message: $scope.message
        type: ''

      if $scope.focus is 'GROUP'
        message.type = 'group'
      else
        message.type = 'private'

      $scope.message = ''
      Socket.emit 'users:message', message
      Logger.debug 'Sending message.', message
]