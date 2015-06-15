starterCtrl = angular.module 'starter.controllers', []

starterCtrl.controller 'LoginCtrl', ($scope, $state) ->
    $scope.join = ->
      $state.go 'app.map'