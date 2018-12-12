module hunt.net.AsynchronousTcpSession;

import hunt.net.Config;
import hunt.net.NetEvent;
import hunt.net.NetSocket;
import hunt.net.OutputEntry;
import hunt.net.Session;

import hunt.container;
import hunt.datetime;
import hunt.io.TcpStream;
import hunt.lang.exception;
import hunt.lang.common;
import hunt.logging;
import hunt.util.functional;

import core.atomic;
import std.socket;

class AsynchronousTcpSession : NetSocket, Session {
    protected int sessionId;

version(HUNT_METRIC) {
    private long openTime;
    private long closeTime;
    private long lastReadTime;
    private long lastWrittenTime;
    private size_t readBytes = 0;
    private size_t writtenBytes = 0;
} 

    protected Config _config;
    protected NetEvent _netEvent;
    protected Object attachment;
    protected shared bool _isClosed = false;
    protected shared bool _isShutdownOutput = false;
    protected shared bool _isShutdownInput = false;
    protected shared bool _isWaitingForClose = false;

    this(int sessionId, Config config, NetEvent netEvent, TcpStream tcp) {
        assert(netEvent !is null);
        this.sessionId = sessionId;
        this._config = config;
        this._netEvent = netEvent;
        super(tcp);
        version(HUNT_METRIC) this.openTime = DateTimeHelper.currentTimeMillis();
        version (HUNT_DEBUG) trace("initializing AsynchronousTcpSession");
        netEvent.notifySessionOpened(this);
    }  

    override void attachObject(Object attachment) {
        this.attachment = attachment;
    }

    override Object getAttachment() {
        return attachment;
    }

    void encode(Object message) {
        try {
            _config.getEncoder().encode(message, this);
        } catch (Exception t) {
            _netEvent.notifyExceptionCaught(this, t);
        }
    }

    // void encode(ByteBuffer message) {
    //     try {
    //         _config.getEncoder().encode(message, this);
    //     } catch (Exception t) {
    //         _netEvent.notifyExceptionCaught(this, t);
    //     }
    // }

    void encode(ByteBuffer[] messages) {
        try {
            foreach (ByteBuffer message; messages) {
                _config.getEncoder().encode(message, this);
            }
        } catch (Exception t) {
            _netEvent.notifyExceptionCaught(this, t);
        }
    }

    override void write(ByteBuffer buffer, Callback callback) {
        version (HUNT_DEBUG)
            tracef("writting buffer: %s", buffer.toString());

        byte[] data = buffer.array;
        int start = buffer.position();
        int end = buffer.limit();

        write(cast(ubyte[]) data[start .. end]);
        callback.succeeded();
    }

    // override
    // void write(ByteBufferOutputEntry entry) {
    //     ByteBuffer buffer = entry.getData();
    //     Callback callback = entry.getCallback();
    //     write(buffer, callback);
    //     // version(HUNT_DEBUG)
    //     // tracef("writting buffer: %s", buffer.toString());

    //     // byte[] data = buffer.array;
    //     // int start = buffer.position();
    //     // int end = buffer.limit();

    //     // super.write(cast(ubyte[])data[start .. end]);
    //     // callback.succeeded();
    // }

    override void write(ByteBuffer[] buffers, Callback callback) {
        foreach (ByteBuffer buffer; buffers) {
            version (HUNT_DEBUG)
                tracef("writting buffer: %s", buffer.toString());

            byte[] data = buffer.array;
            int start = buffer.position();
            int end = buffer.limit();

            write(cast(ubyte[]) data[start .. end]);
        }
        callback.succeeded();
    }

    override void write(Collection!(ByteBuffer) buffers, Callback callback) {
        write(buffers.toArray(), callback); // BufferUtils.EMPTY_BYTE_BUFFER_ARRAY
    }

    alias write = NetSocket.write;

    void notifyMessageReceived(Object message) {
        implementationMissing(false);
    }

    int getSessionId() {
        return sessionId;
    }

version(HUNT_METRIC) {

    override protected void onDataReceived(const ubyte[] data) {
        readBytes += data.length;
        super.onDataReceived(data);
    }

    override NetSocket write(const ubyte[] data , SimpleEventHandler handler = null) {
        writtenBytes += data.length;
        super.write(data, handler);
        return this;
    }

    long getOpenTime() {
        return openTime;
    }

    long getCloseTime() {
        return closeTime;
    }

    long getDuration() {
        if (closeTime > 0) {
            return closeTime - openTime;
        } else {
            return DateTimeHelper.currentTimeMillis - openTime;
        }
    }

    long getLastReadTime() {
        return lastReadTime;
    }

    long getLastWrittenTime() {
        return lastWrittenTime;
    }

    long getLastActiveTime() {
        import std.algorithm;
        return max(max(lastReadTime, lastWrittenTime), openTime);
    }

    size_t getReadBytes() {
        return readBytes;
    }

    size_t getWrittenBytes() {
        return writtenBytes;
    }

    long getIdleTimeout() {
        return DateTimeHelper.currentTimeMillis - getLastActiveTime();
    }

    void reset() {
        readBytes = 0;
        writtenBytes = 0;
    }

    override string toString() {
        import std.conv;
        return "[sessionId=" ~ sessionId.to!string() ~ ", openTime="
                ~ openTime.to!string() ~ ", closeTime="
                ~ closeTime.to!string() ~ ", duration=" ~ getDuration().to!string()
                ~ ", readBytes=" ~ readBytes.to!string() ~ ", writtenBytes=" ~ writtenBytes.to!string() ~ "]";
    }
}

    override void close() {
        if(cas(&_isClosed, false, true)) {
            try {
                super.close();                
            } catch (AsynchronousCloseException e) {
                warningf("The session %d asynchronously close exception", sessionId);
            } catch (IOException e) {
                errorf("The session %d close exception: %s", sessionId, e.msg);
            } 
            // finally {
            //     _netEvent.notifySessionClosed(this);
            // }
        } else {
            infof("The session %d already closed", sessionId);
        }
    }

    override void closeNow() {
        this.close();
    }

    override protected void onClosed() {
        super.onClosed();
        version(HUNT_METRIC) {
            closeTime = DateTimeHelper.currentTimeMillis();
            // version(HUNT_DEBUG) 
            tracef("The session %d closed: %s", sessionId, this.toString());
        } else {
            version(HUNT_DEBUG) tracef("The session %d closed", sessionId);
        }
        _netEvent.notifySessionClosed(this);
    }

    private void shutdownSocketChannel() {
        shutdownOutput();
        shutdownInput();
    }

    void shutdownOutput() {
        if (_isShutdownOutput) {
            tracef("The session %d is already shutdown output", sessionId);
        } else {
            _isShutdownOutput = true;
            try {
                _tcp.shutdownOutput();
                tracef("The session %d is shutdown output", sessionId);
            } catch (ClosedChannelException e) {
                warningf("Shutdown output exception. The session %d is closed", sessionId);
            } catch (IOException e) {
                errorf("The session %d shutdown output I/O exception. %s", sessionId, e.message);
            }
        }
    }

    void shutdownInput() {
        if (_isShutdownInput) {
            tracef("The session %d is already shutdown input", sessionId);
        } else {
            _isShutdownInput = true;
            try {
                _tcp.shutdownInput();
                tracef("The session %d is shutdown input", sessionId);
            } catch (ClosedChannelException e) {
                warningf("Shutdown input exception. The session %d is closed", sessionId);
            } catch (IOException e) {
                errorf("The session %d shutdown input I/O exception. %s", sessionId, e.message);
            }
        }
    }

    override bool isOpen() {
        return _tcp.isConnected();
    }

    bool isClosed() {
        return _tcp.isClosed();
    }

    bool isShutdownOutput() {
        return _isShutdownOutput;
    }

    bool isShutdownInput() {
        return _isShutdownInput;
    }

    bool isWaitingForClose() {
        return _isWaitingForClose;
    }

    Address getLocalAddress() {
        return localAddress();
    }

    Address getRemoteAddress() {
        return remoteAddress();
    }

    long getMaxIdleTimeout() {
        return _config.getTimeout();
    }

}
