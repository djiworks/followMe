app.config ($stateProvider, $urlRouterProvider) ->
  $stateProvider

  .state 'app',
    url: '/app'
    abstract: true
    templateUrl: 'templates/login.html'
    controller: 'LoginCtrl'

  .state 'app.login',
    url: '/login'
    templateUrl: 'templates/login.html'
    controller: 'LoginCtrl'

  .state 'app.map',
    url: '/map'
    templateUrl: 'templates/map.html'
    # controller: 'LoginCtrl'

  $urlRouterProvider.otherwise '/app/login'