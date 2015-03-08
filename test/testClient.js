var socket = io.connect ('http://localhost:9595');

socket.on ('connect', function(){
	console.log('ready');
});

socket.on ('setSessionCode', function(){
	console.log('setSessionCode', arguments);
});


socket.on ('joinedSession', function(){
	console.log('joinedSession', arguments);
});


socket.on ('noSession', function(){
	console.log('noSession', arguments);
});

socket.on ('newLocation', function(){
	console.log('newLocation', arguments);
});

socket.on ('endOfTrackingSession', function(){
	console.log('endOfTrackingSession', arguments);
});

socket.on ('newFollower', function(){
	console.log('newFollower', arguments);
});

socket.on ('followerDeco', function(){
	console.log('followerDeco', arguments);
});

