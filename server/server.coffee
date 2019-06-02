express = require 'express'
socketIO = require('socket.io')
shortId = require 'shortid'
_       = require 'underscore'
path = require('path')

registrations = {}
host = '0.0.0.0'
PORT = process.env.PORT || '3000'
INDEX = path.join(__dirname, '..', 'client','index.html');
MAX_SESSION = 10;
MAX_FOLLOWERS = 3;

logger =  (type, message) ->
  date = new Date().toISOString()
  console.log "[#{date}] - #{type} - #{message}"

server = express()
  .use(express.static('client'))
  .use (req, res) -> res.sendFile(INDEX)
  .listen PORT, () -> logger 'Server', "Start server on #{host}:#{process.env.PORT || PORT}"
io = socketIO(server)

registerTrackingSessionCode = (socket) ->
  logger 'Registration', 'Trying to get new Registration code...'
  curCount = _.keys(registrations).length
  if curCount >= MAX_SESSION 
    logger 'Registration', "Failed: #{curCount} on #{MAX_SESSION} space available"
    return null

  sessionCode = shortId.generate()
  while ! _.isUndefined(registrations[sessionCode])
    sessionCode = shortId.generate()

  logger 'Registration', "New registration code affected: #{sessionCode}"
  socket.trackingSessionCode = sessionCode
  socket.isLeader = true
  socket.followerName = 'Leader'
  registrations[sessionCode] =
    state: 'running'
    followers: {}

  registrations[sessionCode].followers[socket.id] = socket
  
  socket.join sessionCode
  return sessionCode


joinTrackingSession = (sessionCode, followerName, socket) ->
  logger 'Join', "#{followerName} is trying to join #{sessionCode}"
  followerId = socket.id
  session = registrations[sessionCode]
  if _.isObject(session)
    logger 'Join', "Tracking session found: #{sessionCode}"
    curCount = _.keys(session.followers).length
    if curCount >= MAX_FOLLOWERS
      logger 'Join', "Failed: #{curCount} on #{MAX_FOLLOWERS} followers available"
      # Should return something else to differenciate not found from full space
      return null

    socket.followerName = followerName
    socket.trackingSessionCode = sessionCode
    socket.isLeader = false
    session.followers[socket.id] = socket
    
    socket.join sessionCode
    logger 'Join', "Sending new follower to session: #{sessionCode}"
    socket.broadcast.to(sessionCode).emit 'newFollower', followerId, followerName, socket.isLeader
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
    
    else
      logger 'Join', "Sending follower deconnection: #{socket.id}"
      socket.broadcast.to(sessionCode).emit 'followerDeco', followerId
      , socket.followerName
      

informLocationUpdate = (socket, location) ->
  followerId = socket.id
  sessionCode = socket.trackingSessionCode
  session = registrations[sessionCode]
  if _.isObject session
    logger 'Location', "Transfer location to session: #{sessionCode}"
    socket.broadcast.to(sessionCode).emit 'newLocation', followerId, location, socket.isLeader


notifyFollower = (socket, followerId) ->
  sessionCode = socket.trackingSessionCode
  session = registrations[sessionCode]
  dest = session.followers[followerId]
  if dest
    logger 'Join', 'Relay presence'
    dest.emit 'newFollower', socket.id, socket.followerName, socket.isLeader


io.sockets.on 'connection', (socket) ->
  logger 'Connection', "New socket found: #{socket.id}"

  socket.on 'startTrackingSession', ->
    socket.emit 'setSessionCode', registerTrackingSessionCode socket

  socket.on 'joinTrackingSession', (sessionCode, followerName) ->
    if joinTrackingSession sessionCode, followerName, socket
      socket.emit 'joinedSession', sessionCode
    else
      socket.emit 'noSession', sessionCode

  socket.on 'notifyFollower', (followerId) ->
    notifyFollower socket, followerId

  socket.on 'updateTracking', (location) ->
    logger 'Location',"Transfer location of: #{socket.id}"
    informLocationUpdate socket, location

  socket.on 'leaveTrackingSession', ->
    abortTrackingSession socket

  socket.on 'disconnect', ->
    logger 'Connection',"Socket lost: #{socket.id}"
    abortTrackingSession socket
