module hunt.net.SecureSession;

import hunt.container.ByteBuffer;
import hunt.util.functional;

/**
 * 
 */
public interface SecureSession { // : Closeable, ApplicationProtocolSelector 

    bool isOpen();

    ByteBuffer read(ByteBuffer receiveBuffer) ;

    int write(ByteBuffer[] outputBuffers, Callback callback) ;

    int write(ByteBuffer outputBuffer, Callback callback) ;

    // long transferFileRegion(FileRegion file, Callback callback) ;

    bool isHandshakeFinished();

    bool isClientMode();
}
