module hunt.net.AbstractConnection;

import hunt.net.Connection;
import hunt.net.TcpSslOptions;
import hunt.net.codec;

import hunt.Boolean;
import hunt.Exceptions;
import hunt.Functions;
import hunt.io.ByteBuffer;
import hunt.io.BufferUtils;
import hunt.io.channel;
import hunt.io.TcpStream;
import hunt.logging;
import hunt.util.Common;

import std.format;
import std.socket;


/**
 * Abstract base class for TCP connections.
 *
 */
abstract class AbstractConnection : Connection {
    protected int _connectionId;
    protected TcpStream _tcp;
    protected TcpSslOptions _options;
    protected DataReceivedHandler _dataReceivedHandler;
    protected Object[string] attributes;
    private Codec _codec;
    protected Encoder _encoder;
    protected Decoder _decoder;
    protected NetConnectionHandler _netHandler;
    protected shared ConnectionState _connectionState;
    private bool _isSecured = false;


    this(int connectionId, TcpSslOptions options, TcpStream tcp) {
        assert(tcp !is null);
        _tcp = tcp;
        this._options = options;
        this._connectionId = connectionId;
        this._connectionState = ConnectionState.Ready;

        _tcp.closed(&notifyClose);
        _tcp.received(&onDataReceived);
    }

    ///
    this(int connectionId, TcpSslOptions options, TcpStream tcp,
            Codec codec, NetConnectionHandler eventHandler) {
        assert(eventHandler !is null);

        this._netHandler = eventHandler;
        this(connectionId, options, tcp);
        if(codec !is null) {
            this.setCodec(codec);
        }

    }

    int getId() {
        return _connectionId;
    }

    TcpSslOptions getOptions() {
        return _options;
    }

    TcpStream getStream() {
        return _tcp;
    }

    ConnectionState getState() {
        return this._connectionState;
    }

    /**
     *
     */
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
            this._encoder.setBufferSize(_options.getEncoderBufferSize());
            this._decoder = codec.getDecoder;
        }
        return this;
    }

    Codec getCodec() {
        return this._codec;
    }

    ///
    AbstractConnection setHandler(NetConnectionHandler handler) {
        this._netHandler = handler;
        return this;
    }

    NetConnectionHandler getHandler() {
        return _netHandler;
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

    protected DataHandleStatus onDataReceived(ByteBuffer buffer) {
        version(HUNT_NET_DEBUG) {
            auto data = cast(ubyte[]) buffer.peekRemaining();
            tracef("data received (%d bytes): ", data.length);
            version(HUNT_NET_DEBUG_MORE) {
                infof("%(%02X %)", data[0 .. $]);
            } else {
                if(data.length<=64)
                    infof("%(%02X %)", data[0 .. $]);
                else
                    infof("%(%02X %) ...", data[0 .. 64]);
            }
        } else version(HUNT_DEBUG) {
            // auto data = cast(string) buffer.peekRemaining();
            // tracef("data received (%d bytes): ", data.length);
            // infof("%(%02X %)", data[0 .. $]);
        }

        // synchronized (this) {
        //     import hunt.io.BufferUtils;
        //     // Make usre data and thread safe
        //     handleReceivedData(BufferUtils.clone(buffer));
        // }
        DataHandleStatus status = DataHandleStatus.Done;

        try {
            // Make usre data and thread safe
            // status = handleReceivedData(BufferUtils.clone(buffer));
            status = handleReceivedData(buffer);
        } catch(Throwable ex) {
            warning(ex.msg);
            warning(ex);
            
            BufferUtils.clear(buffer);
        }

        return status;
    }

    private DataHandleStatus handleReceivedData(ByteBuffer buffer) {
        DataHandleStatus result = DataHandleStatus.Done;

        if(_decoder !is null) {
            version(HUNT_NET_DEBUG) {
                trace("Running decoder...");
            }
            
            result = _decoder.decode(buffer, this);
            version(HUNT_NET_DEBUG_) info("Decoding done.");

        } else if(_netHandler !is null) {
            result = _netHandler.messageReceived(this, cast(Object)buffer);
        } else {
            // do nothing
            buffer.clear();
            buffer.flip();            
        }

        return result;
    }

    ///
    void close() {
        version(HUNT_NET_DEBUG) infof("Closing connection %d...The state: %s", this.getId(), _connectionState);
        if(_connectionState == ConnectionState.Closing || _connectionState == ConnectionState.Closed)
            return;
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
        version(HUNT_NET_DEBUG) {
            tracef("writting data (%d bytes)...", data.length);
            if(data.length<=64)
                infof("%(%02X %)", data[0 .. $]);
            else
                infof("%(%02X %) ...", data[0 .. 64]);
        } else version(HUNT_NET_DEBUG_MORE) {
            tracef("writting data (%d bytes)...", data.length);
            infof("%(%02X %)", data[0 .. $]);
        }
        //if (_tcp !is null && _tcp.isConnected)
        _tcp.write(data);
    }

    ////
    void write(string str) {
        write(cast(ubyte[]) str);
    }

    void write(ByteBuffer buffer) {

        version(HUNT_NET_DEBUG) {
            tracef("writting buffer (%s bytes)...", buffer.toString());
            auto data = buffer.peekRemaining();
            if(data.length<=64)
                infof("%(%02X %)", data[0 .. $]);
            else
                infof("%(%02X %) ...", data[0 .. 64]);
        } else version(HUNT_NET_DEBUG_MORE) {
            tracef("writting buffer (%s bytes)...", buffer.toString());
            auto data = buffer.peekRemaining();
            infof("%(%02X %)", data[0 .. $]);
        } else version(HUNT_DEBUG) {
            // tracef("writting buffer (%s bytes)...", buffer.toString());
        }
        //if (_tcp !is null && _tcp.isConnected)
        _tcp.write(buffer);
    }

    void write(ByteBuffer buffer, Callback callback) {
        // byte[] data = buffer.array;
        // int start = buffer.position();
        // int end = buffer.limit();

        // write(cast(ubyte[]) data[start .. end]);

        write(cast(ubyte[])buffer.peekRemaining());
        callback.succeeded();
    }

    void write(ByteBuffer[] buffers, Callback callback) {
        foreach (ByteBuffer buffer; buffers) {
            version (HUNT_DEBUG)
                tracef("writting buffer: %s", buffer.toString());

            // byte[] data = buffer.array;
            // int start = buffer.position();
            // int end = buffer.limit();

            // write(cast(ubyte[]) data[start .. end]);
            write(cast(ubyte[])buffer.peekRemaining());
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
            version(HUNT_DEBUG) {
                string msg = format("Connection %d exception: %s", this.getId(), t.msg);
                warning(msg);
            }
            version(HUNT_NET_DEBUG_MORE) warning(t);
            notifyException(t);
        }
    }

    // void encode(ByteBuffer message) {
    //     try {
    //         _config.getEncoder().encode(message, this);
    //     } catch (Exception t) {
    //         _netHandler.notifyExceptionCaught(this, t);
    //     }
    // }

    // void encode(ByteBuffer[] messages) {
    //     try {
    //         foreach (ByteBuffer message; messages) {
    //             this._encoder.encode(message, this);
    //         }
    //     } catch (Exception t) {
    //         _netHandler.exceptionCaught(this, t);
    //     }
    // }

    // void notifyMessageReceived(Object message) {
    //     implementationMissing(false);
    // }

    protected void notifyClose() {
        this._connectionState = ConnectionState.Closed;
        if(_netHandler !is null)
            _netHandler.connectionClosed(this);
    }

    void notifyException(Exception t) {
        if(_netHandler !is null)
            _netHandler.exceptionCaught(this, t);
    }

    version(HUNT_METRIC) {
        override string toString() {
            return "";
        }
    }
}


