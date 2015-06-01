angular.module('starter.controllers', [])
.controller('LoginCtrl', function($scope, $state) {
	// Open the login modal
  	$scope.join = function() {
  		console.log($state);
  		$state.go('app.map');
  	};
});