module hunt.net.ConnectionEvent;

import hunt.net.Connection;
// import hunt.http.utils.function.Action1;
// import hunt.http.utils.function.Action2;
import kiss.logger;

import hunt.util.functional;

import hunt.container.LinkedList;
import hunt.container.List;

/**
 * 
 */
class ConnectionEvent(T) if( is(T:Connection)) {

    private T connection;
    private List!(Action1!(T)) closedListeners;
    private List!(Action2!(T, Exception)) exceptionListeners;

    this(T connection) {
        closedListeners = new LinkedList!(Action1!(T))();
        exceptionListeners = new LinkedList!(Action2!(T, Exception))();
        this.connection = connection;
    }

    T onClose(Action1!(T) closedListener) {
        closedListeners.add(closedListener);
        return connection;
    }

    T onException(Action2!(T, Exception) exceptionListener) {
        exceptionListeners.add(exceptionListener);
        return connection;
    }

    void notifyClose() {
        infof("The handler called %s closed listener. Session: %s", typeof(this).stringof, connection.getSessionId());
        foreach(c; closedListeners)
            c(connection);
    }

    void notifyException(Exception t) {
        infof("The handler called %s exception listener. Session: %s", typeof(this).stringof, connection.getSessionId());
        foreach(c; exceptionListeners)
            c(connection, t);
    }
}
