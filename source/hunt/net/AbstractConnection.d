module hunt.net.AbstractConnection;

// import hunt.net.exception.SecureNetException;
// import hunt.util.functional;
// import hunt.http.utils.concurrent.Scheduler;
// import hunt.http.utils.concurrent.Schedulers;
// import hunt.http.utils.function.Action2;
// import hunt.util.io;

import hunt.net.Connection;
import hunt.net.ConnectionExtInfo;
import hunt.net.secure.SecureSession;
import hunt.net.Session;

import hunt.container.ByteBuffer;
import hunt.util.functional;
import hunt.util.exception;

import kiss.logger;
import std.socket;

/**
 * 
 */
abstract class AbstractConnection  : Connection, ConnectionExtInfo 
{
    // static Scheduler scheduler = Schedulers.createScheduler();

    protected SecureSession secureSession;
    protected Session tcpSession;
    protected Object attachment;

    this(SecureSession secureSession, Session tcpSession) {
        this.secureSession = secureSession;
        this.tcpSession = tcpSession;
    }

    
    int getSessionId() {
        return tcpSession.getSessionId();
    }

    
    long getOpenTime() {
        return tcpSession.getOpenTime();
    }

    
    long getCloseTime() {
        return tcpSession.getCloseTime();
    }

    
    long getDuration() {
        return tcpSession.getDuration();
    }

    
    long getLastReadTime() {
        return tcpSession.getLastReadTime();
    }

    
    long getLastWrittenTime() {
        return tcpSession.getLastWrittenTime();
    }

    
    long getLastActiveTime() {
        return tcpSession.getLastActiveTime();
    }

    
    long getReadBytes() {
        return tcpSession.getReadBytes();
    }

    
    long getWrittenBytes() {
        return tcpSession.getWrittenBytes();
    }

    
    bool isOpen() {
        return tcpSession.isOpen();
    }

    
    bool isClosed() {
        return tcpSession.isClosed();
    }

    
    Address getLocalAddress() {
        return tcpSession.getLocalAddress();
    }

    
    Address getRemoteAddress() {
        return tcpSession.getRemoteAddress();
    }

    
    long getIdleTimeout() {
        return tcpSession.getIdleTimeout();
    }

    
    long getMaxIdleTimeout() {
        return tcpSession.getMaxIdleTimeout();
    }

    
    Object getAttachment() {
        return attachment;
    }

    
    void setAttachment(Object attachment) {
        this.attachment = attachment;
    }

    
    void close() {
        // if(secureSession !is null && secureSession.isOpen)
        //     secureSession.close();           
        if(tcpSession !is null && tcpSession.isOpen)
            tcpSession.close();   
        attachment = null;
    }

    SecureSession getSecureSession() {
        return secureSession;
    }

    Session getTcpSession() {
        return tcpSession;
    }

    
    bool isEncrypted() {
        return secureSession !is null;
    }

    ByteBuffer decrypt(ByteBuffer buffer) {
        if (isEncrypted()) {
            try {
                return secureSession.read(buffer);
            } catch (IOException e) {
                throw new SecureNetException("decrypt exception", e);
            }
        } else {
            return null;
        }
    }

    // void encrypt(ByteBufferOutputEntry entry) {
    //     encrypt(entry, (buffers, callback) {
    //         try {
    //             secureSession.write(buffers, callback);
    //         } catch (IOException e) {
    //             throw new SecureNetException("encrypt exception", e);
    //         }
    //     });
    // }

    // void encrypt(ByteBufferArrayOutputEntry entry) {
    //     encrypt(entry, (buffers, callback) {
    //         try {
    //             secureSession.write(buffers, callback);
    //         } catch (IOException e) {
    //             throw new SecureNetException("encrypt exception", e);
    //         }
    //     });
    // }

    void encrypt(ByteBuffer buffer) {
        try {
            secureSession.write(buffer, Callback.NOOP);
        } catch (IOException e) {
            throw new SecureNetException("encrypt exception", e);
        }
    }

    void encrypt(ByteBuffer[] buffers) {
        try {
            secureSession.write(buffers, Callback.NOOP);
        } catch (IOException e) {
            throw new SecureNetException("encrypt exception", e);
        }
    }

    private void encrypt(T)(OutputEntry!T entry, Action2!(T, Callback) encrypt) {
        if (isEncrypted()) {
            encrypt.call(entry.getData(), entry.getCallback());
        }
    }

}