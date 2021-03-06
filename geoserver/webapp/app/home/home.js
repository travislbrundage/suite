angular.module('gsApp.home', [])
.config(['$stateProvider', '$urlRouterProvider',
    function($stateProvider, $urlRouterProvider) {
      $urlRouterProvider.otherwise('/');
      $stateProvider.state('home', {
        url: '/',
        templateUrl: '/home/home.tpl.html',
        controller: 'HomeCtrl'
      });
    }])
.controller('HomeCtrl', ['$scope', 'GeoServer',
    function($scope, GeoServer) {

      $scope.title = 'Recent';

      GeoServer.workspaces.get(true).then(function(result) {
        $scope.projects = result.data;
      });

      GeoServer.maps.recent().then(function(result) {
        $scope.recentmaps = result.data;
      });

      GeoServer.layers.recent().then(function(result) {
        $scope.recentlayers = result.data;
      });


    }]);
