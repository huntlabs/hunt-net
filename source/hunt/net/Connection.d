module hunt.net.Connection;

import hunt.net.AsyncResult;
import hunt.util.Common;
import hunt.io.TcpStream;

import hunt.collection.ByteBuffer;
import hunt.collection.Collection;

import core.time;
import std.socket;


deprecated("Using Connection instead.")
alias TcpSession = Connection;
deprecated("Using Connection instead.")
alias Session = Connection;

alias NetEventHandler(E) = void delegate(E event);
alias NetEventHandler(T, U) = void delegate(T t, U u);
alias NetConnectHandler = NetEventHandler!Connection;
alias NetMessageHandler = NetEventHandler!(Connection, Object);
alias NetExceptionHandler = NetEventHandler!(Connection, Throwable);
alias NetErrorHandler = NetEventHandler!(int, Throwable);
// alias AsyncConnectHandler = NetEventHandler!(AsyncResult!Connection);
// alias AsyncVoidResultHandler = NetEventHandler!(AsyncResult!(Void));

enum ConnectionState {
    Ready,
    Error,
    Opening,
    Opened,
    Securing,
    Secured,
    // Idle,
    // Active,
    // Broken,
    Closing,
    Closed
}

/**
 * <p>
 *   A handle which represents connection between two end-points regardless of
 *   transport types.
 * </p>
 * <p>
 *   {@link Connection} provides user-defined attributes.  User-defined attributes
 *   are application-specific data which are associated with a connection.
 *   It often contains objects that represents the state of a higher-level protocol
 *   and becomes a way to exchange data between filters and handlers.
 * </p>
 * <h3>Adjusting Transport Type Specific Properties</h3>
 * <p>
 *   You can simply downcast the connection to an appropriate subclass.
 * </p>
 * <h3>Thread Safety</h3>
 * <p>
 *   {@link Connection} is thread-safe.  But please note that performing
 *   more than one {@link #write(Object)} calls at the same time will
 *   cause the {@link IoFilter#filterWrite(IoFilter.NextFilter,Connection,WriteRequest)}
 *   to be executed simultaneously, and therefore you have to make sure the
 *   {@link IoFilter} implementations you're using are thread-safe, too.
 * </p>
 * <h3>Equality of Connections</h3>
 * TODO : The getId() method is totally wrong. We can't base
 * a method which is designed to create a unique ID on the hashCode method.
 * {@link Object#equals(Object)} and {@link Object#hashCode()} shall not be overriden
 * to the default behavior that is defined in {@link Object}.
 *
 * @author <a href="http://mina.apache.org">Apache MINA Project</a>
 */
interface Connection : Closeable {

    TcpStream getStream();

    ConnectionState getState();
    
    void setState(ConnectionState state);

    /**
     * @return the EventHandler which handles this connection.
     */
    ConnectionEventHandler getHandler();    



    /**
     * Returns the value of the user-defined attribute of this connection.
     *
     * @param key the key of the attribute
     * @return <tt>null</tt> if there is no attribute with the specified key
     */
    Object getAttribute(string key);

    /**
     * Returns the value of user defined attribute associated with the
     * specified key.  If there's no such attribute, the specified default
     * value is associated with the specified key, and the default value is
     * returned.  This method is same with the following code except that the
     * operation is performed atomically.
     * <pre>
     * if (containsAttribute(key)) {
     *     return getAttribute(key);
     * } else {
     *     setAttribute(key, defaultValue);
     *     return defaultValue;
     * }
     * </pre>
     * 
     * @param key the key of the attribute we want to retreive
     * @param defaultValue the default value of the attribute
     * @return The retrieved attribute or <tt>null</tt> if not found
     */
    Object getAttribute(string key, Object defaultValue);

    /**
     * Sets a user-defined attribute.
     *
     * @param key the key of the attribute
     * @param value the value of the attribute
     * @return The old value of the attribute.  <tt>null</tt> if it is new.
     */
    Object setAttribute(string key, Object value);

    /**
     * Sets a user defined attribute without a value.  This is useful when
     * you just want to put a 'mark' attribute.  Its value is set to
     * {@link bool#TRUE}.
     *
     * @param key the key of the attribute
     * @return The old value of the attribute.  <tt>null</tt> if it is new.
     */
    Object setAttribute(string key);

    /**
     * Sets a user defined attribute if the attribute with the specified key
     * is not set yet.  This method is same with the following code except
     * that the operation is performed atomically.
     * <pre>
     * if (containsAttribute(key)) {
     *     return getAttribute(key);
     * } else {
     *     return setAttribute(key, value);
     * }
     * </pre>
     * 
     * @param key The key of the attribute we want to set
     * @param value The value we want to set
     * @return The old value of the attribute.  <tt>null</tt> if not found.
     */
    Object setAttributeIfAbsent(string key, Object value);

    /**
     * Sets a user defined attribute without a value if the attribute with
     * the specified key is not set yet.  This is useful when you just want to
     * put a 'mark' attribute.  Its value is set to {@link bool#TRUE}.
     * This method is same with the following code except that the operation
     * is performed atomically.
     * <pre>
     * if (containsAttribute(key)) {
     *     return getAttribute(key);  // might not always be bool.TRUE.
     * } else {
     *     return setAttribute(key);
     * }
     * </pre>
     * 
     * @param key The key of the attribute we want to set
     * @return The old value of the attribute.  <tt>null</tt> if not found.
     */
    Object setAttributeIfAbsent(string key);

    /**
     * Removes a user-defined attribute with the specified key.
     *
     * @param key The key of the attribute we want to remove
     * @return The old value of the attribute.  <tt>null</tt> if not found.
     */
    Object removeAttribute(string key);

    /**
     * Removes a user defined attribute with the specified key if the current
     * attribute value is equal to the specified value.  This method is same
     * with the following code except that the operation is performed
     * atomically.
     * <pre>
     * if (containsAttribute(key) &amp;&amp; getAttribute(key).equals(value)) {
     *     removeAttribute(key);
     *     return true;
     * } else {
     *     return false;
     * }
     * </pre>
     * 
     * @param key The key we want to remove
     * @param value The value we want to remove
     * @return <tt>true</tt> if the removal was successful
     */
    bool removeAttribute(string key, Object value);

    /**
     * Replaces a user defined attribute with the specified key if the
     * value of the attribute is equals to the specified old value.
     * This method is same with the following code except that the operation
     * is performed atomically.
     * <pre>
     * if (containsAttribute(key) &amp;&amp; getAttribute(key).equals(oldValue)) {
     *     setAttribute(key, newValue);
     *     return true;
     * } else {
     *     return false;
     * }
     * </pre>
     * 
     * @param key The key we want to replace
     * @param oldValue The previous value
     * @param newValue The new value
     * @return <tt>true</tt> if the replacement was successful
     */
    bool replaceAttribute(string key, Object oldValue, Object newValue);

    /**
     * @param key The key of the attribute we are looking for in the connection 
     * @return <tt>true</tt> if this connection contains the attribute with
     * the specified <tt>key</tt>.
     */
    bool containsAttribute(string key);

    /**
     * @return the set of keys of all user-defined attributes.
     */
    string[] getAttributeKeys();

    void encode(Object message);

    // void encode(ByteBuffer[] message);

    // void encode(ByteBufferOutputEntry message);

    // void notifyMessageReceived(Object message);

    /**
     * Writes the specified <code>message</code> to remote peer.  This
     * operation is asynchronous; {@link IoHandler#messageSent(Connection,Object)}
     * will be invoked when the message is actually sent to remote peer.
     * You can also wait for the returned {@link WriteFuture} if you want
     * to wait for the message actually written.
     * 
     * @param message The message to write
     * @return The associated WriteFuture
     */
    void write(Object message); // It's same as void encode(Object message);


    // void write(OutputEntry<?> entry);
    // void write(ByteBufferOutputEntry entry);

    void write(const(ubyte)[] data);
    void write(string str);
    void write(ByteBuffer buffer);

    void write(ByteBuffer byteBuffer, Callback callback);

    // void write(ByteBuffer[] buffers, Callback callback);

    // void write(Collection!ByteBuffer buffers, Callback callback);

    // void write(FileRegion file, Callback callback);

    int getId();

version(HUNT_METRIC) {
    long getOpenTime();

    long getCloseTime();

    long getDuration();

    long getLastReadTime();

    long getLastWrittenTime();

    long getLastActiveTime();

    size_t getReadBytes();

    size_t getWrittenBytes();

    long getIdleTimeout();

    string toString();
}    

    void close();

    // void closeNow();

    void shutdownOutput();

    void shutdownInput();

    // bool isOpen();

    // bool isClosed();

    /**
     * @return <tt>true</tt> if this connection is connected with remote peer.
     */
    bool isConnected();
    
    /**
     * @return <tt>true</tt> if this connection is active.
     */
    bool isActive();

    /**
     * @return <tt>true</tt> if and only if this connection is being closed
     * (but not disconnected yet) or is closed.
     */
    bool isClosing();
    
    /**
     * @return <tt>true</tt> if the connection has started and initialized a SslEngine,
     * <tt>false</tt> if the connection is not yet secured (the handshake is not completed)
     * or if SSL is not set for this connection, or if SSL is not even an option.
     */
    bool isSecured();    

    bool isShutdownOutput();

    bool isShutdownInput();

    bool isWaitingForClose();

    Address getLocalAddress();

    Address getRemoteAddress();

    Duration getMaxIdleTimeout();
}



/**
 * Handles all I/O events on a socket connection.
 *
 */
abstract class ConnectionEventHandler {

	void connectionOpened(Connection connection) ;

	void connectionClosed(Connection connection) ;

	void messageReceived(Connection connection, Object message) ;

	void exceptionCaught(Connection connection, Exception t) ;

	void failedOpeningConnection(int connectionId, Exception t) { }

	void failedAcceptingConnection(int connectionId, Exception t) { }
}

/**
*/
class ConnectionEventHandlerAdapter : ConnectionEventHandler {

    private NetConnectHandler _openedHandler;
    private NetConnectHandler _closedHandler;
    private NetMessageHandler _messageHandler;
    private NetExceptionHandler _exceptionHandler;
    private NetErrorHandler _openFailedHandler;
    private NetErrorHandler _acceptFailedHandler;


    this() {

    }

    ////// Event Handlers

    ///
    void onOpened(NetConnectHandler handler) {
        _openedHandler = handler;
    }

    void onClosed(NetConnectHandler handler) {
        _closedHandler = handler;
    }

    void onMessageReceived(NetMessageHandler handler) {
        _messageHandler = handler;
    }

    void onException(NetExceptionHandler handler) {
        _exceptionHandler = handler;
    }

    void onOpeneFailed(NetConnectHandler handler) {
        _openedHandler = handler;
    }

    ////// ConnectionEventHandler APIs

    ///
    void connectionOpened(Connection connection) {
        if(_openedHandler !is null) 
            _openedHandler(connection);
    }

	void connectionClosed(Connection connection) {
        if(_closedHandler !is null)
            _closedHandler(connection);
    }

	void messageReceived(Connection connection, Object message) {
        if(_messageHandler !is null)
            _messageHandler(connection, message);
    }

	void exceptionCaught(Connection connection, Exception e) {
        if(_exceptionHandler !is null)
            _exceptionHandler(connection, e);
    }

	void failedOpeningConnection(int connectionId, Exception e) { 
        if(_openFailedHandler !is null)
            _openFailedHandler(connectionId, e)
    }

	void failedAcceptingConnection(int connectionId, Exception e) { 
        if(_acceptFailedHandler !is null) 
            _acceptFailedHandler(connectionId, e);
    }
}