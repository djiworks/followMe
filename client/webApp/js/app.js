var socket = null;
var curSessionCode = null;
var gMap = null;
var markers = [];
var locationWatcher = null;


function getLocation (cb) {
  navigator.geolocation.getCurrentPosition(function(position) {
    cb(position.coords.latitude, position.coords.longitude);
  });

};


function startTracking () {
  locationWatcher = navigator.geolocation.watchPosition(function(position) {
    updateLocation(position.coords.latitude, position.coords.longitude);
  });
}

function updateLocation (lat, lng) {
  socket.emit('updateTracking', {lat: lat, lng:lng});
};

function newMarker (location, type) {
  var marker;
  if (type == 'leader') {
    marker = new google.maps.Marker({
    position: location,
    map: gMap,
    icon: 'img/target2.png'
    });
  }
  else
    if (type == 'myself') {
      marker = new google.maps.Marker({
      position: location,
      map: gMap,
      icon: 'img/target.png'
      });
    }
    else
    {
      marker = new google.maps.Marker({
        position: location,
        map: gMap
        //label: 
      });
    }
  markers.push(marker);
}

(function() {
  var app = ons.bootstrap('myApp', ['onsen']);

  app.controller('registerController', function($scope, $timeout){
    $scope.getSessionCode = function(){
      modalSession.show();
      socket.emit('startTrackingSession');
      socket.on('setSessionCode', function(sessionCode) {
        myNavigator.pushPage('session.html');
        curSessionCode = sessionCode;
      });
    };
    
  });

  app.controller('SessionController', function($scope, $timeout){
    if(curSessionCode) {
      $timeout(function(){
       document.getElementById("inputSessionCode").value = curSessionCode;
       modalSession.hide();
      }, 100);
    }
    else {
      myNavigator.popPage();
    }
  });

  app.controller('MapController', function($scope){
    modalMap.show();
    getLocation(function(lat, lon){
      var latlng = new google.maps.LatLng(lat, lon);
      var myOptions = {
        zoom: 14,
        center: latlng,
        mapTypeId: google.maps.MapTypeId.ROADMAP,
        disableDefaultUI: true
      };
      gMap = new google.maps.Map(document.getElementById("map_canvas"), myOptions);
      newMarker(latlng, 'myself');
      modalMap.hide();
      startTracking();
    });

    $scope.leaveSessions = function () {
      if (locationWatcher) {
        navigator.geolocation.clearWatch(locationWatcher);
      }
      myNavigator.resetToPage("register.html");
      // TODO emit exiSession to execute a followerDeco or abortTrackingSession
    }
  });


  ons.ready(function() {
    modalConnection.show();
    socket = io.connect('http://localhost:9595', {
      reconnection: false
    });
    socket.on('connect', function(){
      modalConnection.hide();
    });

    socket.on('connect_error', function(){
      modalConnection.hide();
      ons.notification.alert({
        message: 'Connection error. Please connect to Internet',
        title: 'Connection error',
        buttonLabel: 'OK',
        animation: 'default',
        callback: function() {
          socket.connect();
        }
      });
    });
  });
})();
