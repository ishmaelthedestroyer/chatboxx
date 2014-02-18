angular.module('bxCtrl', ['bxNotify', 'bxQueue', 'bxSession'])

.controller 'bxCtrl', [
  '$scope', '$rootScope', '$state', '$location', '$q',
  'bxNotify', 'bxQueue', 'bxSession', 'bxLogger',
  ($scope, $rootScope, $state, $location, $q,
  Notify, Queue, Session, Logger) ->
    Notify.setScope $scope
    Queue.setScope $scope
    $scope.session = {}

    $scope.notifications = Notify.list()
    $scope.queue = Queue.list()

    $scope.bxState = $state

    $scope.loadSession = () ->
      deferred = $q.defer()

      # add session request to queue, fetch session
      deferred = $q.defer()
      Queue.push deferred.promise

      Session.refresh().then (data) ->
        deferred.resolve true

    $rootScope.$on 'session:loaded', (event, data) ->
      Logger.debug 'Updated session.', data
      $scope.session = data

    $scope.logout = ($e, location) ->
      $e.preventDefault()
      deferred = $q.defer()

      Queue.push deferred.promise
      Session.logout().then (data) ->
        $location.path '/' || location
        deferred.resolve true

    $scope.removeNotification = (index) ->
      Notify.remove index

    apply = (scope, fn) ->
      if scope.$$phase or scope.$root.$$phase
        fn()
      else
        scope.$apply fn
]
