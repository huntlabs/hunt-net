module hunt.net.Connection;

import hunt.net.AsyncResult;
import hunt.net.OutputEntry;
import hunt.net.OutputEntryType;
import hunt.util.Common;

import hunt.collection.ByteBuffer;
import hunt.collection.Collection;

import std.socket;


alias TcpSession = Connection;
alias IoSession = Connection;
alias SocketSession = Connection;
alias Session = Connection;
alias NetSocket = Connection;

alias NetEventHandler(E) = void delegate(E event);
alias ExceptionHandler = NetEventHandler!(Throwable);
alias ConnectHandler = NetEventHandler!Connection;
// alias AsyncConnectHandler = NetEventHandler!(AsyncResult!Connection);
alias AsyncVoidResultHandler = NetEventHandler!(AsyncResult!(Void));

/**
 * <p>
 *   A handle which represents connection between two end-points regardless of
 *   transport types.
 * </p>
 * <p>
 *   {@link IoSession} provides user-defined attributes.  User-defined attributes
 *   are application-specific data which are associated with a session.
 *   It often contains objects that represents the state of a higher-level protocol
 *   and becomes a way to exchange data between filters and handlers.
 * </p>
 * <h3>Adjusting Transport Type Specific Properties</h3>
 * <p>
 *   You can simply downcast the session to an appropriate subclass.
 * </p>
 * <h3>Thread Safety</h3>
 * <p>
 *   {@link IoSession} is thread-safe.  But please note that performing
 *   more than one {@link #write(Object)} calls at the same time will
 *   cause the {@link IoFilter#filterWrite(IoFilter.NextFilter,IoSession,WriteRequest)}
 *   to be executed simultaneously, and therefore you have to make sure the
 *   {@link IoFilter} implementations you're using are thread-safe, too.
 * </p>
 * <h3>Equality of Sessions</h3>
 * TODO : The getId() method is totally wrong. We can't base
 * a method which is designed to create a unique ID on the hashCode method.
 * {@link Object#equals(Object)} and {@link Object#hashCode()} shall not be overriden
 * to the default behavior that is defined in {@link Object}.
 *
 * @author <a href="http://mina.apache.org">Apache MINA Project</a>
 */
interface Connection {

    // DisconnectionOutputEntry DISCONNECTION_FLAG = new DisconnectionOutputEntry(null, null);


    /**
     * @return the {@link IoHandler} which handles this session.
     */
    SessionEventHandler getHandler();    

deprecated("Using setAttribute instead.")
    void attachObject(Object attachment);

deprecated("Using getAttribute instead.")
    Object getAttachment();

    /**
     * Returns the value of the user-defined attribute of this session.
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
     * @param key The key of the attribute we are looking for in the session 
     * @return <tt>true</tt> if this session contains the attribute with
     * the specified <tt>key</tt>.
     */
    bool containsAttribute(string key);

    /**
     * @return the set of keys of all user-defined attributes.
     */
    string[] getAttributeKeys();


    void notifyMessageReceived(Object message);

    void encode(Object message);

    void encode(ByteBuffer[] message);

    // void encode(ByteBufferOutputEntry message);

    // void write(OutputEntry<?> entry);
    // void write(ByteBufferOutputEntry entry);

    void write(ByteBuffer byteBuffer, AsyncVoidResultHandler callback);

    void write(ByteBuffer[] buffers, AsyncVoidResultHandler callback);

    void write(Collection!ByteBuffer buffers, AsyncVoidResultHandler callback);

    // void write(FileRegion file, AsyncVoidResultHandler callback);

    int getSessionId();

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

    void closeNow();

    void shutdownOutput();

    void shutdownInput();

    bool isOpen();

    bool isClosed();

    bool isShutdownOutput();

    bool isShutdownInput();

    bool isWaitingForClose();

    Address getLocalAddress();

    Address getRemoteAddress();

    long getMaxIdleTimeout();
}



/**
 * Handles all I/O events on a socket session.
 *
 */
abstract class ConnectionEventHandler {

	void sessionOpened(Session session) ;

	void sessionClosed(Session session) ;

	void messageReceived(Session session, Object message) ;

	void exceptionCaught(Session session, Exception t) ;

	void failedOpeningSession(int sessionId, Exception t) { }

	void failedAcceptingSession(int sessionId, Exception t) { }
}

deprecated("Using ConnectionEventHandler instead.")
alias Handler = ConnectionEventHandler;

deprecated("Using ConnectionEventHandler instead.")
alias SessionEventHandler = ConnectionEventHandler;