app.config ($stateProvider) ->
  $stateProvider.state 'room',
    url: '/:id'
    templateUrl: '/routes/room/views/room.html'
