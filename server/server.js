var server = require('http').createServer();
var io = require('socket.io')(server);
var shortId = require('shortid');
var _ = require('underscore');

var registrations = {};
var host = '0.0.0.0';
var port = '9595';

var logger =  function (type, message) {
	console.log('[' + new Date().toISOString() + '] - ' + type + ' - ' + message);
};

var registerTrackingSessionCode = function (socket) {
	logger('Registration', 'Trying to get new Registration code...');
	sessionCode = shortId.generate();
	while (! _.isUndefined(registrations[sessionCode])) {
		sessionCode = shortId.generate();
	}

	logger('Registration', 'New registration code affected: ' + sessionCode);
	socket.trackingSessionCode = sessionCode;
	socket.isLeader = true;
	registrations[sessionCode] = {
		state: 'running'
	};
	
	socket.join(sessionCode);
	return sessionCode;
};

var joinTrackingSession = function (sessionCode, followerName, socket) {
	logger('Join', followerName + ' is trying to join:' + sessionCode);
	followerId = socket['id'];
	session = registrations[sessionCode];
	if (_.isObject(session)) {
		logger('Join', 'Tracking session found: ' + sessionCode);
		socket.join(sessionCode);
		socket.followerName = followerName;
		socket.trackingSessionCode = sessionCode;
		socket.isFollower = true;

		logger('Join', 'Sending new follower to session: ' + sessionCode);
		socket.broadcast.to(sessionCode).emit('newFollower', followerId, followerName);
		return true;
	}
	else {
		logger('Join', 'Tracking session not found: ' + sessionCode);
		return false;
	}
};

var abortTrackingSession = function (socket) {
	sessionCode = socket.trackingSessionCode;
	session = registrations[sessionCode];
	if (_.isObject(session)) {
		if (socket.isLeader) {
			logger('Join', 'Sending leader deconnection for session: ' + sessionCode);
			socket.broadcast.to(sessionCode).emit('endOfTrackingSession', sessionCode);
		}
		if (socket.isFollower) {
			logger('Join', 'Sending follower deconnection: ' + socket['id']);
			socket.broadcast.to(sessionCode).emit('followerDeco', followerId, socket.followerName);
		}		
	}
};

var informLocationUpdate = function (socket, location) {
	followerId = socket['id'];
	sessionCode = socket.trackingSessionCode;
	session = registrations[sessionCode];
	if (_.isObject(session)) {
		logger('Location', 'Transfer location to session: ' + sessionCode);
		socket.broadcast.to(sessionCode).emit('newLocation', followerId, location);
	}
};

io.sockets.on('connection', function (socket) {
	logger('Connection','New socket found: ' + socket['id']);

    socket.on('startTrackingSession', function () {
    	socket.emit('setSessionCode', registerTrackingSessionCode(socket));
    });

    socket.on('joinTrackingSession', function (sessionCode, followerName) {
    	if (joinTrackingSession(sessionCode, followerName, socket)) {
    		socket.emit('joinedSession', sessionCode);
    	}
    	else {
    		socket.emit('noSession', sessionCode);
 	   	}
    });

    socket.on('updateTracking', function (location) {
    	logger('Location','Transfer location of:' + socket['id']);
    	informLocationUpdate(socket, location);
    });

    socket.on('disconnect', function () {
    	logger('Connection','Socket lost: ' + socket['id']);
    	abortTrackingSession(socket);
    });
});

server.listen(port, function(err) {
	logger('Server', 'Start server on '+ host + ':' + port);
});