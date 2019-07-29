module hunt.net.SessionEventHandler;

import hunt.net.Session;

import std.exception;

abstract class SessionEventHandler {

	void sessionOpened(Session session) ;

	void sessionClosed(Session session) ;

	void messageReceived(Session session, Object message) ;

	void exceptionCaught(Session session, Exception t) ;

	void failedOpeningSession(int sessionId, Exception t) { }

	void failedAcceptingSession(int sessionId, Exception t) { }
}

deprecated("Using SessionEventHandler instead.")
alias Handler = SessionEventHandler;