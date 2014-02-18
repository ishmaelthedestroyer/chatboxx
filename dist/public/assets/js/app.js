/** 
 * noSeed - v0.0.0 - 2014-02-18
 * http://no-seed.herokuapp.com 
 * 
 * Copyright (c) 2014 ishmaelthedestroyer
 * Licensed  <>
 * */
var app;

app = angular.module('App', ['ui.router', 'ui.bootstrap', 'noToolbox']);

app.run([
  '$rootScope', '$state', '$stateParams', function($rootScope, $state, $stateParams) {
    $rootScope.$state = $state;
    return $rootScope.$stateParams = $stateParams;
  }
]);

app.config(function($stateProvider, $urlRouterProvider, $locationProvider) {
  $urlRouterProvider.otherwise('/404');
  return $locationProvider.html5Mode(true);
});

angular.element(document).ready(function() {
  return angular.bootstrap(document, ['App']);
});

app.config(function($stateProvider) {
  return $stateProvider.state('404', {
    url: '/404',
    templateUrl: '/routes/404/views/404.html'
  });
});

app.config(function($stateProvider) {
  return $stateProvider.state('index', {
    url: '/',
    templateUrl: '/routes/index/views/index.html'
  });
});

app.controller('IndexCtrl', [
  '$scope', '$state', function($scope, $state) {
    var apply;
    return apply = function(scope, fn) {
      if (scope.$$phase || scope.$root.$$phase) {
        return fn();
      } else {
        return scope.$apply(fn);
      }
    };
  }
]);
