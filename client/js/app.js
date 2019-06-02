var socket = null;
var curSessionCode = null;
var gMap = null;
var markers = {};
var locationWatcher = null;
var modalTextMsg = {
  map: 'Getting map. Please wait...',
  join: 'Trying to join session. Please wait...',
  session: 'Getting sessionCode. Please wait...',
  connect: 'Try to connect. Please wait...'
}
var myLocation = null;
var leaderLocation = null;
var iAmLeader = false;

var followers = {};

function showModalText (type) {
  document.getElementById('modalText').innerText = modalTextMsg[type];
  modal.show();
}

function getLocation (cb) {
  navigator.geolocation.getCurrentPosition(function(position) {
    cb(position.coords.latitude, position.coords.longitude);
    myLocation = {lat: position.coords.latitude, lng: position.coords.longitude};
    updateLocation(position.coords.latitude, position.coords.longitude);
    if (iAmLeader) {
      leaderLocation = myLocation;
    }
  });
};


function startTracking () {
  locationWatcher = navigator.geolocation.watchPosition(function(position) {
    updateLocation(position.coords.latitude, position.coords.longitude);
    myLocation = {lat: position.coords.latitude, lng: position.coords.longitude};
    if (iAmLeader) {
      leaderLocation = myLocation;
    }
  });

  socket.on('newFollower', function(followerId, followerName, isLeader) {
    followers[followerId] = {name: followerName, isLeader: isLeader};
    socket.emit('notifyFollower', followerId);
  });

  socket.on('newLocation', function(followerId, location, isLeader) {
    if (markers[followerId]) {
      markers[followerId].setLatLng(new L.latLng(location));
      if (isLeader) {
        leaderLocation = location;
      }
    }
    else
    {
      type = ''
      if (isLeader) {
        type = 'leader'
        leaderLocation = location;
      }
      newMarker(followerId, location, type, 'Follower');
    }
  });

  socket.on('followerDeco', function(followerId, followerName) {
    marker = markers[followerId]
    if (marker) {
      gMap.removeLayer(marker);
      delete markers[followerId];
    }
    delete followers[followerId];
  });

  socket.on('endOfTrackingSession', function() {
    socket.removeAllListeners('endOfTrackingSession');
    socket.removeAllListeners('followerDeco');
    socket.removeAllListeners('newLocation');
    socket.removeAllListeners('newFollower');

    if (locationWatcher) {
      navigator.geolocation.clearWatch(locationWatcher);
    }
    markers = {};
    leaderLocation = null;
    myNavigator.resetToPage("register.html");
  });

}

function updateLocation (lat, lng) {
  socket.emit('updateTracking', {lat: lat, lng: lng});
};

function newMarker (id, location, type, label) {
  var marker;
  if (type == 'leader') {
    var leaderMarker = L.AwesomeMarkers.icon({
      markerColor: 'red'
    });
    marker = L.marker(location, {icon: leaderMarker}).addTo(gMap);
  }
  else
    if (type == 'myself') {
      var meMarker = L.AwesomeMarkers.icon({
        markerColor: 'green'
      });
      marker = L.marker(location, {icon: meMarker}).addTo(gMap);
    }
    else
    {
      var otherMarker = L.AwesomeMarkers.icon({
        markerColor: 'blue'
      });
      marker = L.marker(location, {icon: otherMarker}).addTo(gMap);
    }
  markers[id] = marker;
}

(function() {
  var app = ons.bootstrap('myApp', ['onsen']);

  app.controller('registerController', function($scope, $timeout){
    $scope.getSessionCode = function(){
      showModalText('session');
      socket.emit('startTrackingSession');
      storeSessionCode = function(sessionCode) {
        if (!sessionCode) {
          ons.notification.alert({
            message: 'Sorry, but there is no more session available. Please retry later.',
            title: 'Full server use',
            buttonLabel: 'OK',
            animation: 'default',
            callback: function() {}
          });
          socket.removeListener('setSessionCode', storeSessionCode);
          modal.hide();
          return
        }
        myNavigator.pushPage('session.html');
        curSessionCode = sessionCode;
        socket.removeListener('setSessionCode', storeSessionCode);
        iAmLeader = true;
      };
      socket.on('setSessionCode', storeSessionCode);
    };


    $scope.joinSession = function () {
      sessionCode = document.getElementById("joinSessionCode").value
      if (sessionCode && sessionCode != '') {
        showModalText('join');
        socket.emit('joinTrackingSession', sessionCode, 'Follower');
        successJoin = function () {
          myNavigator.pushPage('map.html');
          modal.hide();
          socket.removeListener('joinedSession', successJoin);
        };
        socket.on('joinedSession', successJoin);

        failedJoin = function () {
          modal.hide();
          ons.notification.alert({
            message: 'sessionCode unknown',
            title: 'Session code error',
            buttonLabel: 'OK',
            animation: 'default',
            callback: function() {}
          });
          socket.removeListener('noSession', failedJoin);
        };
        socket.on('noSession', failedJoin);
      }
      else
      {
        ons.notification.alert({
          message: 'Wrong sessionCode entered.',
          title: 'Session code error',
          buttonLabel: 'OK',
          animation: 'default',
          callback: function() {}
        });
      }
    };
    
  });

  app.controller('SessionController', function($scope, $timeout){
    if(curSessionCode) {
      $timeout(function(){
       document.getElementById("inputSessionCode").value = curSessionCode;
       modal.hide();
      }, 100);
    }
    else {
      myNavigator.popPage();
    }

    $scope.leaveSession = function () {
      socket.emit('leaveTrackingSession');
    }
  });

  app.controller('MapController', function($scope){
    followers[socket.id] = {name: 'Me', isLeader: iAmLeader};
    showModalText('map');
    getLocation(function(lat, lon){
      var latlng = new L.LatLng(lat, lon);
      var myOptions = {
        zoom: 14,
        center: latlng,
        layers: [
          new L.TileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
              'attribution': 'Map data © <a href="http://openstreetmap.org">OpenStreetMap</a> contributors'
          })
      ]
      };
      gMap = new L.Map('map_canvas', myOptions);
      newMarker(socket.id, latlng, 'myself');
      modal.hide();
      startTracking();
    });

    $scope.leaveSession = function () {
      if (locationWatcher) {
        navigator.geolocation.clearWatch(locationWatcher);
      }
      myNavigator.resetToPage("register.html");
      socket.emit('leaveTrackingSession');
    }

    $scope.centerOnMe = function () {
      gMap.panTo(new L.LatLng(myLocation.lat, myLocation.lng));
    }

    $scope.centerOnLeader = function () {
      gMap.panTo(new L.LatLng(leaderLocation.lat, myLocation.lng));
    }

  });

  app.controller('FollowersController', function($scope){
    $scope.followers = followers;
  });


  ons.ready(function() {
    showModalText('connect');
    socket = io.connect();
    socket.on('connect', function(){
      modal.hide();
    });

    socket.on('connect_error', function(err){
      console.log(err, '......')
      modal.hide();
      ons.notification.alert({
        message: 'There is a problem while trying to connect.',
        title: 'Connection error',
        buttonLabel: 'OK',
        animation: 'default',
        callback: function() {
          showModalText('connect');
          socket.connect();
        }
      });
    });
  });
})();
