# Simple Follow Me app

## Description

Follow Me is a simple app allowing you to start or follow a location tracker session with your friends. When starting the session, the first user get a session token to share with his followers. Then, followers ask to join the session and everyone share their location in real time.

## API

It's based on socket.io library with following events :

### Server-side:
-   startTrackingSession: On connection, client asks to server a registration code which is also the session code to share
- joinTrackingSession (sessionCode, followerName): To join a location tracker session from a session code
- updateTracking (location): To ask server to transfer a location to other followers
- leaveTrackingSession: Stop session
- notifyFollower (followerId): To ask server to notify follower socket id, the caller exists

### Client-side:
- setSessionCode (sessionCode): Server sends the token to share in this event
- joinedSession / noSession(sessionCode): Inform client about his joinTrackingSession request
- newLocation (followerId, location, isLeader): Inform client about location update from other follower
- endOfTrackingSession(sessionCode): Inform client about the end of the session because the leader has aborted
- newFollower (followerId, followerName, isLeader): Inform followers that new follower has joined the session and reply to new follower with a notifyFollower
- followerDeco (followerId, followerName): Inform followers that a follower has left the session

## Roadmap
- Client apps for mobile (Android, iOS)
- Crypt location with sessionCode
- Limit number of followers in one session
- Session expiration system
