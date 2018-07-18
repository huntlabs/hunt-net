module hunt.net.Handler;

import hunt.net.Session;

import std.exception;

abstract class Handler {

	void sessionOpened(Session session) ;

	void sessionClosed(Session session) ;

	void messageReceived(Session session, Object message) ;

	void exceptionCaught(Session session, Exception t) ;

	void failedOpeningSession(int sessionId, Exception t) { }

	void failedAcceptingSession(int sessionId, Exception t) { }
}