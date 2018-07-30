module hunt.net.secure.SecureSession;

import hunt.container.ByteBuffer;
import hunt.util.functional;

import hunt.net.secure.ProtocolSelector;

/**
 * 
 */
public interface SecureSession : ProtocolSelector { // : Closeable,  

    bool isOpen();

    ByteBuffer read(ByteBuffer receiveBuffer) ;

    int write(ByteBuffer[] outputBuffers, Callback callback) ;

    int write(ByteBuffer outputBuffer, Callback callback) ;

    // long transferFileRegion(FileRegion file, Callback callback) ;

    bool isHandshakeFinished();

    bool isClientMode();
}


alias SecureSessionHandshakeListener = void delegate(SecureSession secureSession);