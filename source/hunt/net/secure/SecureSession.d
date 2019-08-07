module hunt.net.secure.SecureSession;

import hunt.collection.ByteBuffer;
import hunt.util.Common;

import hunt.net.secure.ProtocolSelector;

/**
 * 
 */
interface SecureSession : ProtocolSelector {
    enum string NAME = typeof(this).stringof;

    bool isOpen();

    ByteBuffer read(ByteBuffer receiveBuffer) ;

    int write(ByteBuffer[] outputBuffers, Callback callback) ;

    int write(ByteBuffer outputBuffer, Callback callback) ;

    // long transferFileRegion(FileRegion file, Callback callback) ;

    bool isHandshakeFinished();

    bool isClientMode();
}


alias SecureSessionHandshakeListener = void delegate(SecureSession secureSession);