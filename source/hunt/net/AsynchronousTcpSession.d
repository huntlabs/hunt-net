module hunt.net.AsynchronousTcpSession;

import hunt.net.NetSocket;
import hunt.net.Config;
import hunt.net.NetEvent;
import hunt.net.Session;

import hunt.container;
import hunt.util.exception;
import hunt.util.functional;

import kiss.net.TcpStream;

import std.socket;


class AsynchronousTcpSession : NetSocket, Session
{
    protected int sessionId;
    protected Config _config;
    protected NetEvent _netEvent;
    protected Object attachment;
    protected bool _isOpen = false;

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
    bool isOpen() {
        return _isOpen;
    }

    override
    void write(ByteBuffer buffer, Callback callback) {
        // outboundData.offer(buffer);
        buffer.flip();

        byte[] data = buffer.array;
        int start = buffer.position();
        int end = buffer.limit();
        // int start = buffer.arrayOffset() + buffer.position();
        // int end = start + buffer.remaining();

        super.write(cast(ubyte[])data[start .. end]);
        callback.succeeded();
    }

    override
    void write(ByteBuffer[] buffers, Callback callback) {
        foreach (ByteBuffer buffer ; buffers) {           

            // byte[] data = buffer.array;
            // int start = buffer.arrayOffset() + buffer.position();
            // int end = start + buffer.remaining();

            buffer.flip();

            byte[] data = buffer.array;
            int start = buffer.position();
            int end = buffer.limit();

            super.write(cast(ubyte[])data[start .. end]);

            buffer.flip();
        }
        callback.succeeded();

    }

    override
    void write(Collection!(ByteBuffer) buffers, Callback callback) {
        write(buffers.toArray(), callback); // BufferUtils.EMPTY_BYTE_BUFFER_ARRAY
    }

    alias write = NetSocket.write;

    // override
    // void write(OutputEntry!(?) entry) {
    //     if (entry instanceof ByteBufferOutputEntry) {
    //         ByteBufferOutputEntry outputEntry = (ByteBufferOutputEntry) entry;
    //         write(outputEntry.getData(), outputEntry.getCallback());
    //     } else {
    //         ByteBufferArrayOutputEntry outputEntry = (ByteBufferArrayOutputEntry) entry;
    //         write(outputEntry.getData(), outputEntry.getCallback());
    //     }
    // }

    override
    void closeNow() {
        _isOpen = false;
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
        _isOpen = false;
        super.close(); 
    }

    void shutdownOutput(){ implementationMissing(false); }

    void shutdownInput(){ implementationMissing(false); }

    bool isClosed(){ return !_isOpen; }

    bool isShutdownOutput(){ implementationMissing(false); return false; }

    bool isShutdownInput(){ implementationMissing(false); return false; }

    bool isWaitingForClose(){ implementationMissing(false); return false; }

    Address getLocalAddress(){ return localAddress(); }

    Address getRemoteAddress(){ return remoteAddress(); }

    long getIdleTimeout() { implementationMissing(false); return 0; }

    long getMaxIdleTimeout() { implementationMissing(false); return 0; }

}