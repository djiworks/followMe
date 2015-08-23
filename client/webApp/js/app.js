var socket = null;
var curSessionCode = null;
var gMap = null;
var markers = [];
var locationWatcher = null;
var modalTextMsg = {
  map: 'Getting map. Please wait...',
  join: 'Trying to join session. Please wait...',
  session: 'Getting sessionCode. Please wait...',
  connect: 'Try to connect. Please wait...'
}

function showModalText (type) {
  document.getElementById('modalText').innerText = modalTextMsg[type];
  modal.show();
}

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

function newMarker (location, type, label) {
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
        map: gMap,
        label: label
      });
    }
  markers.push(marker);
}

(function() {
  var app = ons.bootstrap('myApp', ['onsen']);

  app.controller('registerController', function($scope, $timeout){
    $scope.getSessionCode = function(){
      showModalText('session');
      socket.emit('startTrackingSession');
      storeSessionCode = function(sessionCode) {
        myNavigator.pushPage('session.html');
        curSessionCode = sessionCode;
        socket.removeListener('setSessionCode', storeSessionCode);
      };
      socket.on('setSessionCode', storeSessionCode);
    };


    $scope.joinSession = function () {
      sessionCode = document.getElementById("joinSessionCode").value
      if (sessionCode && sessionCode != '') {
        showModalText('join');
        socket.emit('joinTrackingSession', sessionCode, 'Test');
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
    showModalText('map');
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
      modal.hide();
      startTracking();
    });

    $scope.leaveSession = function () {
      if (locationWatcher) {
        navigator.geolocation.clearWatch(locationWatcher);
      }
      myNavigator.resetToPage("register.html");
      socket.emit('leaveTrackingSession');
      // TODO emit exiSession to execute a followerDeco or abortTrackingSession
    }
  });


  ons.ready(function() {
    showModalText('connect');
    socket = io.connect('http://localhost:9595', {
      reconnection: false
    });
    socket.on('connect', function(){
      modal.hide();
    });

    socket.on('connect_error', function(){
      modal.hide();
      ons.notification.alert({
        message: 'Connection error. Please connect to Internet',
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
