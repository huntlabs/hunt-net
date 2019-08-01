module hunt.net.TcpConnection;

import hunt.net.TcpSslOptions;
import hunt.net.AbstractConnection;
import hunt.net.Connection;
import hunt.net.codec;
import hunt.net.OutputEntry;
// import hunt.net.Session;

import hunt.collection;
import hunt.util.DateTime;
import hunt.io.TcpStream;
import hunt.Exceptions;
import hunt.Functions;
import hunt.logging;
import hunt.util.Common;

import core.atomic;
import core.time;
import std.socket;

deprecated("Using TcpConnection instead.")
alias AsynchronousTcpSession = TcpConnection;
deprecated("Using TcpConnection instead.")
alias NetSocketImpl = TcpConnection;


/**
 * Represents a socket-like interface to a TCP connection on either the
 * client or the server side.
 */
class TcpConnection : AbstractConnection {

version(HUNT_METRIC) {
    private long openTime;
    private long closeTime;
    private long lastReadTime;
    private long lastWrittenTime;
    private size_t readBytes = 0;
    private size_t writtenBytes = 0;
} 

    protected TcpSslOptions _config;
    protected shared bool _isClosed = false;
    protected shared bool _isShutdownOutput = false;
    protected shared bool _isShutdownInput = false;
    protected shared bool _isWaitingForClose = false;

    this(int sessionId, TcpSslOptions config, ConnectionEventHandler eventHandler, Codec codec, TcpStream tcp) {
        this._config = config;
        super(sessionId, tcp, codec, eventHandler);
        version(HUNT_METRIC) this.openTime = DateTimeHelper.currentTimeMillis();
        version(HUNT_DEBUG) trace("initializing...");
    }  


    void write(ByteBuffer buffer, AsyncVoidResultHandler callback) {
        version (HUNT_DEBUG_MORE)
            tracef("writting buffer: %s", buffer.toString());

        byte[] data = buffer.array;
        int start = buffer.position();
        int end = buffer.limit();

        write(cast(ubyte[]) data[start .. end]);
        // callback.succeeded();
    }

    // override
    // void write(ByteBufferOutputEntry entry) {
    //     ByteBuffer buffer = entry.getData();
    //     AsyncVoidResultHandler callback = entry.getCallback();
    //     write(buffer, callback);
    //     // version(HUNT_DEBUG)
    //     // tracef("writting buffer: %s", buffer.toString());

    //     // byte[] data = buffer.array;
    //     // int start = buffer.position();
    //     // int end = buffer.limit();

    //     // super.write(cast(ubyte[])data[start .. end]);
    //     // callback.succeeded();
    // }

    void write(ByteBuffer[] buffers, AsyncVoidResultHandler callback) {
        foreach (ByteBuffer buffer; buffers) {
            version (HUNT_DEBUG)
                tracef("writting buffer: %s", buffer.toString());

            byte[] data = buffer.array;
            int start = buffer.position();
            int end = buffer.limit();

            write(cast(ubyte[]) data[start .. end]);
        }
        // callback.succeeded();
    }

    void write(Collection!(ByteBuffer) buffers, AsyncVoidResultHandler callback) {
        write(buffers.toArray(), callback); // BufferUtils.EMPTY_BYTE_BUFFER_ARRAY
    }

    alias write = AbstractConnection.write;

    void notifyMessageReceived(Object message) {
        implementationMissing(false);
    }


version(HUNT_METRIC) {

    override protected void onDataReceived(ByteBuffer buffer) {
        readBytes += buffer.limit();
        super.onDataReceived(buffer);
    }

    override AsynchronousTcpConnection write(const ubyte[] data) {
        writtenBytes += data.length;
        super.write(data);
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
        return "[sessionId=" ~ _sessionId.to!string() ~ ", openTime="
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
                warningf("The session %d asynchronously close exception", _sessionId);
            } catch (IOException e) {
                errorf("The session %d close exception: %s", _sessionId, e.msg);
            } 
            // finally {
            //     _eventHandler.notifySessionClosed(this);
            // }
        } else {
            infof("The session %d already closed", _sessionId);
        }
    }

    // override void closeNow() {
    //     this.close();
    // }

    override protected void onClosed() {
        super.onClosed();
        version(HUNT_METRIC) {
            closeTime = DateTimeHelper.currentTimeMillis();
            // version(HUNT_DEBUG) 
            tracef("The session %d closed: %s", _sessionId, this.toString());
        } else {
            version(HUNT_DEBUG) tracef("The session %d closed", _sessionId);
        }
        if(_eventHandler !is null)
            _eventHandler.sessionClosed(this);
    }

    private void shutdownSocketChannel() {
        shutdownOutput();
        shutdownInput();
    }

    void shutdownOutput() {
        if (_isShutdownOutput) {
            tracef("The session %d is already shutdown output", _sessionId);
        } else {
            _isShutdownOutput = true;
            try {
                _tcp.shutdownOutput();
                tracef("The session %d is shutdown output", _sessionId);
            } catch (ClosedChannelException e) {
                warningf("Shutdown output exception. The session %d is closed", _sessionId);
            } catch (IOException e) {
                errorf("The session %d shutdown output I/O exception. %s", _sessionId, e.message);
            }
        }
    }

    void shutdownInput() {
        if (_isShutdownInput) {
            tracef("The session %d is already shutdown input", _sessionId);
        } else {
            _isShutdownInput = true;
            try {
                _tcp.shutdownInput();
                tracef("The session %d is shutdown input", _sessionId);
            } catch (ClosedChannelException e) {
                warningf("Shutdown input exception. The session %d is closed", _sessionId);
            } catch (IOException e) {
                errorf("The session %d shutdown input I/O exception. %s", _sessionId, e.message);
            }
        }
    }

    bool isOpen() {
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

    Duration getMaxIdleTimeout() {
        return _config.getIdleTimeout();
    }

}
