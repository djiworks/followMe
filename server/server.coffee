server  = require('http').createServer()
io      = require('socket.io')(server)
shortId = require 'shortid'
_       = require 'underscore'

registrations = {}
host = '0.0.0.0'
port = '9595'

logger =  (type, message) ->
  date = new Date().toISOString()
  console.log "[#{date}] - #{type} - #{message}"


registerTrackingSessionCode = (socket) ->
  logger 'Registration', 'Trying to get new Registration code...'
  sessionCode = shortId.generate()
  while ! _.isUndefined(registrations[sessionCode])
    sessionCode = shortId.generate()

  logger 'Registration', "New registration code affected: #{sessionCode}"
  socket.trackingSessionCode = sessionCode
  socket.isLeader = true
  socket.followerName = 'Leader'
  registrations[sessionCode] =
    state: 'running'
    followers: [socket]
  
  socket.join sessionCode
  return sessionCode


joinTrackingSession = (sessionCode, followerName, socket) ->
  logger 'Join', "#{followerName} is trying to join #{sessionCode}"
  followerId = socket.id
  session = registrations[sessionCode]
  if _.isObject(session)
    logger 'Join', "Tracking session found: #{sessionCode}"
    socket.join sessionCode
    socket.followerName = followerName
    socket.trackingSessionCode = sessionCode
    socket.isFollower = true

    logger 'Join', 'Sending other follower to new follower'
    _.each session.followers, (follower) ->
      socket.emit 'newFollower', follower.id, follower.followerName, socket.isLeader

    session.followers.push socket
    logger 'Join', "Sending new follower to session: #{sessionCode}"
    socket.broadcast.to(sessionCode).emit 'newFollower', followerId
    , followerName
    return true
  else
    logger 'Join', "Tracking session not found: #{sessionCode}"
    return false


abortTrackingSession = (socket) ->
  sessionCode = socket.trackingSessionCode
  session = registrations[sessionCode]
  followerId = socket.id

  if _.isObject session
    if socket.isLeader
      logger 'Join', "Sending leader deconnection for session: #{sessionCode}"
      socket.broadcast.to(sessionCode).emit 'endOfTrackingSession', sessionCode
      delete registrations[sessionCode]
    
    if socket.isFollower
      logger 'Join', "Sending follower deconnection: #{socket.id}"
      socket.broadcast.to(sessionCode).emit 'followerDeco', followerId
      , socket.followerName
      

informLocationUpdate = (socket, location) ->
  followerId = socket.id
  sessionCode = socket.trackingSessionCode
  session = registrations[sessionCode]
  if _.isObject session
    logger 'Location', "Transfer location to session: #{sessionCode}"
    socket.broadcast.to(sessionCode).emit 'newLocation', followerId, location

io.sockets.on 'connection', (socket) ->
  logger 'Connection', "New socket found: #{socket.id}"

  socket.on 'startTrackingSession', ->
    socket.emit 'setSessionCode', registerTrackingSessionCode socket

  socket.on 'joinTrackingSession', (sessionCode, followerName) ->
    if joinTrackingSession sessionCode, followerName, socket
      socket.emit 'joinedSession', sessionCode
    else
      socket.emit 'noSession', sessionCode

  socket.on 'updateTracking', (location) ->
    logger 'Location',"Transfer location of: #{socket.id}"
    informLocationUpdate socket, location

  socket.on 'leaveTrackingSession', ->
    abortTrackingSession socket

  socket.on 'disconnect', ->
    logger 'Connection',"Socket lost: #{socket.id}"
    abortTrackingSession socket

server.listen port, (err) ->
  logger 'Server', "Start server on #{host}:#{port}"