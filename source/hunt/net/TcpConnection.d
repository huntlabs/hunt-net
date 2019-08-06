module hunt.net.TcpConnection;

import hunt.net.TcpSslOptions;
import hunt.net.AbstractConnection;
import hunt.net.Connection;
import hunt.net.codec;
import hunt.net.OutputEntry;
// import hunt.net.Connection;

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
alias AsynchronousTcpConnection = TcpConnection;


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

    protected TcpSslOptions _options;
    // protected shared bool _isClosed = false;
    protected shared bool _isShutdownOutput = false;
    protected shared bool _isShutdownInput = false;
    protected shared bool _isWaitingForClose = false;

    this(int connectionId, TcpSslOptions options, ConnectionEventHandler eventHandler, Codec codec, TcpStream tcp) {
        this._options = options;
        super(connectionId, tcp, codec, eventHandler);
        version(HUNT_METRIC) this.openTime = DateTimeHelper.currentTimeMillis();
        version(HUNT_DEBUG) trace("initializing TCP connection...");
    }  


    void write(ByteBuffer buffer, AsyncVoidResultHandler callback) {
        version (HUNT_IO_MORE)
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
        return "[connectionId=" ~ _connectionId.to!string() ~ ", openTime="
                ~ openTime.to!string() ~ ", closeTime="
                ~ closeTime.to!string() ~ ", duration=" ~ getDuration().to!string()
                ~ ", readBytes=" ~ readBytes.to!string() ~ ", writtenBytes=" ~ writtenBytes.to!string() ~ "]";
    }
}

    // override void close() {
    //     // if(cas(&_isClosed, false, true)) {
    //         try {
    //             super.close();                
    //         } catch (AsynchronousCloseException e) {
    //             warningf("The connection %d asynchronously close exception", _connectionId);
    //         } catch (IOException e) {
    //             errorf("The connection %d close exception: %s", _connectionId, e.msg);
    //         } 
    //         // finally {
    //         //     _eventHandler.notifyConnectionClosed(this);
    //         // }
    //     // } else {
    //     //     infof("The connection %d already closed", _connectionId);
    //     // }
    // }

    // override void closeNow() {
    //     this.close();
    // }

    override protected void notifyClose() {
        super.notifyClose();
        version(HUNT_METRIC) {
            closeTime = DateTimeHelper.currentTimeMillis();
            // version(HUNT_DEBUG) 
            tracef("The connection %d closed: %s", _connectionId, this.toString());
        } else {
            version(HUNT_DEBUG) tracef("The connection %d closed", _connectionId);
        }
        if(_eventHandler !is null)
            _eventHandler.connectionClosed(this);
    }

    private void shutdownSocketChannel() {
        shutdownOutput();
        shutdownInput();
    }

    void shutdownOutput() {
        if (_isShutdownOutput) {
            tracef("The connection %d is already shutdown output", _connectionId);
        } else {
            _isShutdownOutput = true;
            try {
                _tcp.shutdownOutput();
                tracef("The connection %d is shutdown output", _connectionId);
            } catch (ClosedChannelException e) {
                warningf("Shutdown output exception. The connection %d is closed", _connectionId);
            } catch (IOException e) {
                errorf("The connection %d shutdown output I/O exception. %s", _connectionId, e.message);
            }
        }
    }

    void shutdownInput() {
        if (_isShutdownInput) {
            tracef("The connection %d is already shutdown input", _connectionId);
        } else {
            _isShutdownInput = true;
            try {
                _tcp.shutdownInput();
                tracef("The connection %d is shutdown input", _connectionId);
            } catch (ClosedChannelException e) {
                warningf("Shutdown input exception. The connection %d is closed", _connectionId);
            } catch (IOException e) {
                errorf("The connection %d shutdown input I/O exception. %s", _connectionId, e.message);
            }
        }
    }

    bool isConnected() {
        return _tcp.isConnected();
    }

    bool isActive() {
        // FIXME: Needing refactor or cleanup -@zxp at 8/1/2019, 6:04:44 PM
        // 
        return _tcp.isConnected();
    }

    bool isClosing() {
        return _tcp.isClosing();
    }

    bool isSecured() {
        // FIXME: Needing refactor or cleanup -@zxp at 8/1/2019, 6:09:26 PM
        // 
        return false;
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
        return _options.getIdleTimeout();
    }

}
