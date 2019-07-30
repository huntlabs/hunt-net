module hunt.net.Session;

import hunt.net.OutputEntry;
import hunt.net.OutputEntryType;

import std.socket;
import hunt.util.Common;

import hunt.collection.ByteBuffer;
import hunt.collection.Collection;


alias TcpSession = Session;
alias IoSession = Session;

interface Session {

    // DisconnectionOutputEntry DISCONNECTION_FLAG = new DisconnectionOutputEntry(null, null);

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

    void write(ByteBuffer byteBuffer, Callback callback);

    void write(ByteBuffer[] buffers, Callback callback);

    void write(Collection!ByteBuffer buffers, Callback callback);

    // void write(FileRegion file, Callback callback);

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
