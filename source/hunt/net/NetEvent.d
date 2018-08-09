module hunt.net.NetEvent;

import hunt.net.Session;
import hunt.net.Config;

import kiss.logger;

/**
 * The net event callback
 *
 */
interface NetEvent {

    void notifySessionOpened(Session session);

    void notifySessionClosed(Session session);

    void notifyMessageReceived(Session session, Object message);

    void notifyExceptionCaught(Session session, Exception t);
}


class DefaultNetEvent : NetEvent {

    private Config config;

    this(Config config) {
        version(HuntDebugMode) info("create default event manager");
        this.config = config;
    }

    override
    void notifySessionOpened(Session session) {
        try {
            config.getHandler().sessionOpened(session);
        } catch (Exception t) {
            notifyExceptionCaught(session, t);
        }
    }

    override
    void notifySessionClosed(Session session) {
        try {
            config.getHandler().sessionClosed(session);
        } catch (Exception t) {
            notifyExceptionCaught(session, t);
        }
    }

    override
    void notifyMessageReceived(Session session, Object message) {
        try {
            trace("CurrentThreadEventManager");
            config.getHandler().messageReceived(session, message);
        } catch (Exception t) {
            notifyExceptionCaught(session, t);
        }
    }

    override
    void notifyExceptionCaught(Session session, Exception t) {
        try {
            config.getHandler().exceptionCaught(session, t);
        } catch (Exception t0) {
            error("handler exception: ", t0);
        }

    }
}