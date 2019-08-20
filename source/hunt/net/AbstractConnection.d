module hunt.net.AbstractConnection;

import hunt.net.Connection;
import hunt.net.codec;

import hunt.Boolean;
import hunt.collection.ByteBuffer;
import hunt.Exceptions;
import hunt.Functions;
import hunt.io.channel;
import hunt.io.TcpStream;
import hunt.logging.ConsoleLogger;
import hunt.util.Common;

import std.socket;


/**
 * Abstract base class for TCP connections.
 *
 */
abstract class AbstractConnection : Connection {
    protected int _connectionId;
    protected TcpStream _tcp;
    protected DataReceivedHandler _dataReceivedHandler;
    protected Object[string] attributes;
    private Codec _codec;
    protected Encoder _encoder;
    protected Decoder _decoder;
    protected ConnectionEventHandler _eventHandler;
    protected ConnectionState _connectionState;
    // protected Object attachment;
    private bool _isSecured = false;


    this(int connectionId, TcpStream tcp) {
        assert(tcp !is null);
        _tcp = tcp;
        this._connectionId = connectionId;
        this._connectionState = ConnectionState.Ready;

        _tcp.onClosed(&notifyClose);
        _tcp.onReceived(&onDataReceived);
    }

    ///
    this(int connectionId, TcpStream tcp, Codec codec, ConnectionEventHandler eventHandler) {
        assert(eventHandler !is null);

        if(codec !is null) {
            this.setCodec(codec);
        }
        
        this._eventHandler = eventHandler;
        this(connectionId, tcp);
    }

    // deprecated("Using setAttributes instead.")
    // void attachObject(Object attachment) {
    //     this.attachment = attachment;
    // }

    // deprecated("Using getAttributes instead.")
    // Object getAttachment() {
    //     return attachment;
    // }

    int getId() {
        return _connectionId;
    }

    TcpStream getStream() {
        return _tcp;
    }

    ConnectionState getState() {
        return this._connectionState;
    }

    void setState(ConnectionState state) {
        if(state == ConnectionState.Secured) {
            _isSecured = true;
        }
        this._connectionState = state;
    }

    AbstractConnection setCodec(Codec codec) {
        this._codec = codec;
        if(codec !is null) {
            this._encoder = codec.getEncoder();
            this._decoder = codec.getDecoder;
        }
        return this;
    }

    Codec getCodec() {
        return this._codec;
    }    

    ///
    AbstractConnection setHandler(ConnectionEventHandler handler) {
        this._eventHandler = handler;
        return this;
    }

    ConnectionEventHandler getHandler() {
        return _eventHandler;
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
        return _isSecured;
    }

    protected void onDataReceived(ByteBuffer buffer) {
        version(HUNT_DEBUG) { 
            auto data = cast(ubyte[]) buffer.getRemaining();
            infof("data received (%d bytes): ", data.length); 
            version(HUNT_NET_DEBUG_MORE) {
                if(data.length<=64)
                    infof("%(%02X %)", data[0 .. $]);
                else
                    infof("%(%02X %) ...", data[0 .. 64]);
            }
        }      

        if(_decoder !is null) {
            _decoder.decode(buffer, this);
        } else {
            if(_eventHandler !is null) {
                _eventHandler.messageReceived(this, cast(Object)buffer);
            }
        }
    }

    ///
    void close() {
        setState(ConnectionState.Closing);
        _tcp.close();
    }
    
    ///
    @property Address localAddress() {
        return _tcp.localAddress;
    }
    
    ////
    @property Address remoteAddress() {
        return _tcp.remoteAddress;
    }

    ////
    void write(const(ubyte)[] data) {
        version (HUNT_IO_MORE) {
            if (data.length <= 32)
                infof("%d bytes: %(%02X %)", data.length, data[0 .. $]);
            else
                infof("%d bytes: %(%02X %)", data.length, data[0 .. 32]);
        }
        _tcp.write(data);
    }

    ////
    void write(string str) {
        write(cast(ubyte[]) str);
    }

    void write(ByteBuffer buffer) {
        _tcp.write(buffer);
    }

    void write(ByteBuffer buffer, Callback callback) {
        version (HUNT_IO_MORE)
            tracef("writting buffer: %s", buffer.toString());

        // byte[] data = buffer.array;
        // int start = buffer.position();
        // int end = buffer.limit();

        // write(cast(ubyte[]) data[start .. end]);

        write(cast(ubyte[])buffer.getRemaining());
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

    void write(ByteBuffer[] buffers, Callback callback) {
        foreach (ByteBuffer buffer; buffers) {
            version (HUNT_DEBUG)
                tracef("writting buffer: %s", buffer.toString());

            // byte[] data = buffer.array;
            // int start = buffer.position();
            // int end = buffer.limit();

            // write(cast(ubyte[]) data[start .. end]);
            write(cast(ubyte[])buffer.getRemaining());
        }
        callback.succeeded();
    }

    /**
     * {@inheritDoc}
     */
    Object getAttribute(string key) {
        return getAttribute(key, null);
    }

    /**
     * {@inheritDoc}
     */
    Object getAttribute(string key, Object defaultValue) {
        return attributes.get(key, defaultValue);
    }

    /**
     * {@inheritDoc}
     */
    Object setAttribute(string key, Object value) {
        auto itemPtr = key in attributes;
		Object oldValue = null;
        if(itemPtr !is null) {
            oldValue = *itemPtr;
        }
        attributes[key] = value;
		return oldValue;
    }

    /**
     * {@inheritDoc}
     */
    Object setAttribute(string key) {
        return setAttribute(key, Boolean.TRUE);
    }

    /**
     * {@inheritDoc}
     */
    Object setAttributeIfAbsent(string key, Object value) {
        auto itemPtr = key in attributes;
        if(itemPtr is null) {
            attributes[key] = value;
            return null;
        } else {
            return *itemPtr;
        }
    }

    /**
     * {@inheritDoc}
     */
    Object setAttributeIfAbsent(string key) {
        return setAttributeIfAbsent(key, Boolean.TRUE);
    }

    /**
     * {@inheritDoc}
     */
    Object removeAttribute(string key) {
        auto itemPtr = key in attributes;
        if(itemPtr is null) {
            return null;
        } else {
            Object oldValue = *itemPtr;
            attributes.remove(key);
            return oldValue;
        }
    }

    /**
     * {@inheritDoc}
     */
    bool removeAttribute(string key, Object value) {
        auto itemPtr = key in attributes;
        if(itemPtr !is null && *itemPtr == value) {
            attributes.remove(key);
            return true;
        }
        return false;
    }

    /**
     * {@inheritDoc}
     */
    bool replaceAttribute(string key, Object oldValue, Object newValue) {
        auto itemPtr = key in attributes;
        if(itemPtr !is null && *itemPtr == oldValue) {
            attributes[key] = newValue;
            return true;
        }
        return false;
    }

    /**
     * {@inheritDoc}
     */
    bool containsAttribute(string key) {
        auto itemPtr = key in attributes;
        return itemPtr !is null;
    }

    /**
     * {@inheritDoc}
     */
    string[] getAttributeKeys() {
        return attributes.keys();
    }

    void write(Object message) {
        encode(message);
    }

    void encode(Object message) {
        try {
            if(this._encoder is null) {
                throw new IOException("No encoder set.");
            } else {
                this._encoder.encode(message, this);
            }
        } catch (Exception t) {
            version(HUNT_DEBUG) warning(t);
            notifyException(t);
        }
    }

    // void encode(ByteBuffer message) {
    //     try {
    //         _config.getEncoder().encode(message, this);
    //     } catch (Exception t) {
    //         _eventHandler.notifyExceptionCaught(this, t);
    //     }
    // }

    // void encode(ByteBuffer[] messages) {
    //     try {
    //         foreach (ByteBuffer message; messages) {
    //             this._encoder.encode(message, this);
    //         }
    //     } catch (Exception t) {
    //         _eventHandler.exceptionCaught(this, t);
    //     }
    // }

    // void notifyMessageReceived(Object message) {
    //     implementationMissing(false);
    // }

    protected void notifyClose() {
        this._connectionState = ConnectionState.Closed;
        if(_eventHandler !is null)
            _eventHandler.connectionClosed(this);
    }

    void notifyException(Exception t) {
        if(_eventHandler !is null)
            _eventHandler.exceptionCaught(this, t);
    }
}


