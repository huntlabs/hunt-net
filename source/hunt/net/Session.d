module hunt.net.Session;

import hunt.net.OutputEntry;
import hunt.net.OutputEntryType;

import std.socket;
import hunt.util.functional;

import hunt.container.ByteBuffer;
import hunt.container.Collection;


alias TcpSession = Session;

interface Session {

    // DisconnectionOutputEntry DISCONNECTION_FLAG = new DisconnectionOutputEntry(null, null);

    void attachObject(Object attachment);

    Object getAttachment();

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
