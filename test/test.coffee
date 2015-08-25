path = require 'path'
io = require 'socket.io-client'

module = loadModule 'server/server.coffee'

socketURL = 'http://localhost:9595'
options =
  transports: ['websocket']
  'force new connection': true

timeout = 5000
client1 = null
client2 = null
client3 = null
curSessionCode = null

describe 'Use case', ->
  before (done) ->
    client1 = io.connect socketURL, options
    client1.on 'connect', ->
      done()

  afterEach ->
    client1.removeAllListeners() if client1
    client2.removeAllListeners() if client2
    client3.removeAllListeners() if client3

  it 'not joinTrackingSession on wrong sessionCode', (done) ->
    client1.on 'noSession', ->
      done()

    client1.emit 'joinTrackingSession', 'wrongcode', 'fakeName'

  it 'start a session', (done) ->
    client1.on 'setSessionCode', (sessionCode) ->
      expect(sessionCode).to.exist
      curSessionCode = sessionCode
      done()

    client1.emit 'startTrackingSession'

  it 'new follower arrives', (done) ->
    @timeout timeout
    called = 0
    makeDone = ->
      called++
      if called == 3
        done()

    client2 = io.connect socketURL, options
    client2.on 'joinedSession', (sessionCode) ->
      expect(sessionCode).to.exist
      expect(sessionCode).to.eql(curSessionCode)
      makeDone()

    client2.on 'newFollower', (id, name, isLeader) ->
      expect(id).to.eql(client1.id)
      expect(name).to.eql('Leader')
      expect(isLeader).to.be.true
      makeDone()


    client1.on 'newFollower', (id, name, isLeader) ->
      expect(id).to.eql(client2.id)
      expect(name).to.eql('client 2')
      expect(isLeader).to.be.false
      client1.emit 'notifyFollower', id
      makeDone()

    client2.on 'connect', ->
      client2.emit 'joinTrackingSession', curSessionCode, 'client 2'

  it 'send location', (done) ->
    @timeout timeout
    loc = {lat: 1, lng: 2}

    client2.on 'newLocation', (followerId, location, isLeader) ->
      expect(followerId).to.eql(client1.id)
      expect(location).to.deep.eql(loc)
      expect(isLeader).to.be.true
      done()

    client1.emit 'updateTracking', loc

  it 'new follower arrives again', (done) ->
    @timeout(timeout * 2)

    called = 0
    makeDone = ->
      called++
      if called == 5
        done()

    client3 = io.connect socketURL, options
    client3.on 'joinedSession', (sessionCode) ->
      expect(sessionCode).to.exist
      expect(sessionCode).to.eql(curSessionCode)
      makeDone()

    client3.on 'newFollower', (id, name, isLeader) ->
      expect([client1.id, client2.id]).to.include(id)
      expect(['client 2', 'Leader']).to.include(name)
      makeDone()

    client2.on 'newFollower', (id, name, isLeader) ->
      expect(id).to.eql(client3.id)
      expect(name).to.eql('client 3')
      expect(isLeader).to.be.false
      client2.emit 'notifyFollower', id
      makeDone()

    client1.on 'newFollower', (id, name, isLeader) ->
      expect(id).to.eql(client3.id)
      expect(name).to.eql('client 3')
      expect(isLeader).to.be.false
      client1.emit 'notifyFollower', id
      makeDone()

    client3.on 'connect', ->
      client3.emit 'joinTrackingSession', curSessionCode, 'client 3'

  it 'follower leave', (done) ->
    @timeout timeout

    called = 0
    makeDone = ->
      called++
      if called == 2
        done()

    client1.on 'followerDeco', (id, name) ->
      expect(id).to.eql(client3.id)
      expect(name).to.eql('client 3')
      makeDone()

    client2.on 'followerDeco', (id, name) ->
      expect(id).to.eql(client3.id)
      expect(name).to.eql('client 3')
      makeDone()

    client3.emit 'leaveTrackingSession'

  it 'leader disconnect and free sessionCode', (done) ->
    @timeout timeout

    client2.on 'endOfTrackingSession', (sessionCode) ->
      expect(sessionCode).to.eql(curSessionCode)
      
      cli = io.connect socketURL, options
      cli.on 'connect', ->
        cli.on 'noSession', ->
          done()

        cli.emit 'joinTrackingSession', sessionCode, 'fake name'
    
    client1.disconnect()

  it 'follower become leader after end of session', (done) ->
    client2.on 'setSessionCode', (sessionCode) ->
      expect(sessionCode).to.exist
      curSessionCode = sessionCode
      done()

    client2.emit 'startTrackingSession'






