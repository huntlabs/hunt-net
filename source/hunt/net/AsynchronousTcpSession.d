module hunt.net.AsynchronousTcpSession;

import hunt.net.NetSocket;
import hunt.net.Config;
import hunt.net.NetEvent;
import hunt.net.Session;

import hunt.container;
import hunt.util.exception;
import hunt.util.functional;

import hunt.logging;
import hunt.io.TcpStream;

import std.socket;


class AsynchronousTcpSession : NetSocket, Session
{
    protected int sessionId;
    protected Config _config;
    protected NetEvent _netEvent;
    protected Object attachment;
    protected bool _isShutdownOutput = false;
    protected bool _isShutdownInput = false;
    protected bool _isWaitingForClose = false;

    this(int sessionId, Config config, NetEvent netEvent, TcpStream tcp) {
        this.sessionId = sessionId;
        this._config = config;
        this._netEvent = netEvent;
        
        super(tcp);
    }


    override
    void attachObject(Object attachment) {
        this.attachment = attachment;
    }

    override
    Object getAttachment() {
        return attachment;
    }

    override
    void encode(ByteBuffer message) {
        try {
            _config.getEncoder().encode(message, this);
        } catch (Exception t) {
            _netEvent.notifyExceptionCaught(this, t);
        }
    }

    override
    void write(ByteBuffer buffer, Callback callback) {
        version(HuntDebugMode)
        tracef("writting buffer: %s", buffer.toString());

        byte[] data = buffer.array;
        int start = buffer.position();
        int end = buffer.limit();

        super.write(cast(ubyte[])data[start .. end]);
        callback.succeeded();
    }

    override
    void write(ByteBuffer[] buffers, Callback callback) {
        foreach (ByteBuffer buffer ; buffers) { 
            version(HuntDebugMode)
            tracef("writting buffer: %s", buffer.toString());

            byte[] data = buffer.array;
            int start = buffer.position();
            int end = buffer.limit();

            super.write(cast(ubyte[])data[start .. end]);
        }
        callback.succeeded();
    }

    override
    void write(Collection!(ByteBuffer) buffers, Callback callback) {
        write(buffers.toArray(), callback); // BufferUtils.EMPTY_BYTE_BUFFER_ARRAY
    }

    alias write = NetSocket.write;

    override
    void closeNow() {
        close();
    }


    void notifyMessageReceived(Object message){ implementationMissing(false); }

    void encode(ByteBuffer[] messages){ 
        try {
            foreach(ByteBuffer message; messages)
            {
                _config.getEncoder().encode(message, this);
            }
        } catch (Exception t) {
            _netEvent.notifyExceptionCaught(this, t);
        }
    }

    int getSessionId(){ return sessionId; }

    long getOpenTime(){ implementationMissing(false); return 0; }

    long getCloseTime(){ implementationMissing(false); return 0; }

    long getDuration(){ implementationMissing(false); return 0; }

    long getLastReadTime(){ implementationMissing(false); return 0; }

    long getLastWrittenTime(){ implementationMissing(false); return 0; }

    long getLastActiveTime(){ implementationMissing(false); return 0; }

    long getReadBytes(){ implementationMissing(false); return 0; }

    long getWrittenBytes(){ implementationMissing(false); return 0; }

    override
    void close(){ 
        super.close(); 
    }


    private void shutdownSocketChannel() {
        shutdownOutput();
        shutdownInput();
    }

    void shutdownOutput(){ 
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

    void shutdownInput(){ 
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


    override
    bool isOpen() {
        return _tcp.isConnected();
    }

    bool isClosed(){ return _tcp.isClosed(); }

    bool isShutdownOutput(){ return _isShutdownOutput; }

    bool isShutdownInput(){ return _isShutdownInput; }

    bool isWaitingForClose(){ return _isWaitingForClose; }

    Address getLocalAddress(){ return localAddress(); }

    Address getRemoteAddress(){ return remoteAddress(); }

    long getIdleTimeout() { implementationMissing(false); return 0; }

    long getMaxIdleTimeout() { implementationMissing(false); return 0; }

}