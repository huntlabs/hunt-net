module hunt.net.AbstractConnection;

import hunt.net.AsyncResult;
import hunt.net.Connection;

import hunt.Boolean;
import hunt.collection.ByteBuffer;
import hunt.Functions;
import hunt.io.channel;
import hunt.io.TcpStream;
import hunt.logging.ConsoleLogger;
import hunt.util.Common;

import std.socket;



// alias Handler = void delegate(AbstractConnection sock);

/**
 * Abstract base class for TCP connections.
 *
 */
class AbstractConnection : Connection {
    protected TcpStream _tcp;
    protected SimpleEventHandler _closeHandler;
    protected DataReceivedHandler _dataReceivedHandler;
    protected Object[string] attributes;

    protected Object attachment;

    ///
    this(TcpStream tcp) {
        _tcp = tcp;
        _tcp.onClosed(&onClosed);
        _tcp.onReceived(&onDataReceived);
    }

    deprecated("Using setAttributes instead.")
    void attachObject(Object attachment) {
        this.attachment = attachment;
    }

    deprecated("Using getAttributes instead.")
    Object getAttachment() {
        return attachment;
    }

    ///
    AbstractConnection handler(DataReceivedHandler handler) {
        _dataReceivedHandler = handler;
        return this;
    }

    protected void onDataReceived(ByteBuffer buffer) {
        version(HUNT_DEBUG) { 
            auto data = cast(ubyte[]) buffer.getRemaining();
            infof("data received (%d bytes): ", data.length); 
            version(HUNT_IO_MORE) {
            if(data.length<=64)
                infof("%(%02X %)", data[0 .. $]);
            else
                infof("%(%02X %) ...", data[0 .. 64]);
            }
        }      

        if(_dataReceivedHandler !is null) {
            _dataReceivedHandler(buffer);
        }
    }

    ///
    void close() {
        _tcp.close();
    }
    
    ////
    AbstractConnection closeHandler(SimpleEventHandler handler) {
        _tcp.closeHandler = &onClosed;
        _closeHandler = handler;
        return this;
    }

    protected void onClosed() {
        if(_closeHandler !is null)
            _closeHandler();
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
    AbstractConnection write(const(ubyte)[] data) {
        version (HUNT_IO_MORE) {
            if (data.length <= 32)
                infof("%d bytes: %(%02X %)", data.length, data[0 .. $]);
            else
                infof("%d bytes: %(%02X %)", data.length, data[0 .. 32]);
        }
        _tcp.write(data);
        return this;
    }

    ////
    AbstractConnection write(string str) {
        return write(cast(ubyte[]) str);
    }

    AbstractConnection write(ByteBuffer buffer) {
        _tcp.write(buffer);
        return this;
    }

    TcpStream getTcpStream() {
        return _tcp;
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

}


