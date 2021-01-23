module hunt.net.TcpConnection;

import hunt.net.AbstractConnection;
import hunt.net.Connection;
import hunt.net.codec;
import hunt.net.TcpSslOptions;

import hunt.collection;
import hunt.io.TcpStream;
import hunt.io.channel;
import hunt.Exceptions;
import hunt.Functions;
import hunt.logging;
import hunt.util.Common;
import hunt.util.DateTime;

import core.atomic;
import core.time;
import std.socket;


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

    protected shared bool _isShutdownOutput = false;
    protected shared bool _isShutdownInput = false;
    protected shared bool _isWaitingForClose = false;

    this(int connectionId, TcpSslOptions options, NetConnectionHandler handler, Codec codec, TcpStream tcp) {
        super(connectionId, options, tcp, codec, handler);
        version(HUNT_METRIC) this.openTime = DateTime.currentTimeMillis();
        version(HUNT_DEBUG) {
            import core.thread;
            tracef("Initializing TCP connection %d...", connectionId);
        }
    }  

version(HUNT_METRIC) {

    override DataHandleStatus onDataReceived(ByteBuffer buffer) {
        readBytes += buffer.limit();
        return super.onDataReceived(buffer);
    }

    override void write(const ubyte[] data) {
        writtenBytes += data.length;
        super.write(data);
    }
    alias write = AbstractConnection.write; 

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
            return DateTime.currentTimeMillis - openTime;
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
        return DateTime.currentTimeMillis - getLastActiveTime();
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
        version(HUNT_METRIC) {
            closeTime = DateTime.currentTimeMillis();
            // version(HUNT_DEBUG) 
            // tracef("The connection %d closed.", _connectionId);
        } else {
            version(HUNT_DEBUG) tracef("The connection %d closed.", _connectionId);
        }
        super.notifyClose();
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
