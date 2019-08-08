module hunt.net.secure.AbstractSecureSession;

// dfmt off
version(WITH_HUNT_SECURITY):
// dfmt on

import hunt.net.secure.ProtocolSelector;
import hunt.net.secure.SecureSession;
import hunt.net.Exceptions;
import hunt.net.Connection;
import hunt.net.ssl;


import hunt.collection;
import hunt.concurrency.CountingCallback;
import hunt.Exceptions;
import hunt.io.Common;
import hunt.text.Common;
import hunt.util.Common;

import hunt.logging;

import std.array;
import std.conv;
import std.format;


abstract class AbstractSecureSession : SecureSession {

    protected __gshared ByteBuffer hsBuffer;

    protected Connection session;
    protected SSLEngine sslEngine;
    protected ProtocolSelector applicationProtocolSelector;
    protected SecureSessionHandshakeListener handshakeListener;

    protected ByteBuffer receivedPacketBuf;
    protected ByteBuffer receivedAppBuf;

    protected bool closed = false;
    protected HandshakeStatus initialHSStatus;
    protected bool initialHSComplete;

    shared static this() {
        hsBuffer = new HeapByteBuffer(0,0); 
    }

    this(Connection session, SSLEngine sslEngine,
                                 ProtocolSelector applicationProtocolSelector,
                                 SecureSessionHandshakeListener handshakeListener) {
        this.session = session;
        this.sslEngine = sslEngine;
        this.applicationProtocolSelector = applicationProtocolSelector;
        this.handshakeListener = handshakeListener;

        SSLSession ses = sslEngine.getSession();
        receivedAppBuf = newBuffer(ses.getApplicationBufferSize());
        // receivedAppBuf = newBuffer(sslEngine.getSession().getApplicationBufferSize());
        initialHSComplete = false;

        // start tls
        version(HUNT_DEBUG) info("Starting TLS ...");
        this.sslEngine.beginHandshake();
        initialHSStatus = sslEngine.getHandshakeStatus();
        if (sslEngine.getUseClientMode()) {
            doHandshakeResponse();
        }
    }

    /**
     * The initial handshake is a procedure by which the two peers exchange
     * communication parameters until an SecureSession is established. Application
     * data can not be sent during this phase.
     *
     * @param receiveBuffer Encrypted message
     * @return True means handshake success
     * @The I/O exception
     */
    protected bool doHandshake(ByteBuffer receiveBuffer) {
        try {
            return _doHandshake(receiveBuffer);
        }
        catch(Exception ex)
        {
            debug error(ex.toString());
            else
                error(ex.msg);
            return false;
        }
    }
    
    protected bool _doHandshake(ByteBuffer receiveBuffer) {
        if (!session.isConnected()) {
            close();
            return (initialHSComplete = false);
        }

        if (initialHSComplete) {
            return true;
        }

        switch (initialHSStatus) {
            case HandshakeStatus.NOT_HANDSHAKING:
            case HandshakeStatus.FINISHED: {
                handshakeFinish();
                return initialHSComplete;
            }

            case HandshakeStatus.NEED_UNWRAP:
                doHandshakeReceive(receiveBuffer);
                if (initialHSStatus == HandshakeStatus.NEED_WRAP)
                    doHandshakeResponse();
                break;

            case HandshakeStatus.NEED_WRAP:
                doHandshakeResponse();
                break;

            default: // NEED_TASK
                throw new SecureNetException("Invalid Handshaking State" ~ initialHSStatus.to!string());
        }
        return initialHSComplete;
    }

    protected void doHandshakeReceive(ByteBuffer receiveBuffer) {
        merge(receiveBuffer);
        needIO:
        while (initialHSStatus == HandshakeStatus.NEED_UNWRAP) {

            unwrapLabel:
            while (true) {
                SSLEngineResult result = unwrap();
                initialHSStatus = result.getHandshakeStatus();

                version(HUNT_NET_DEBUG_MORE) {
                    tracef("Connection %s handshake result -> %s, initialHSStatus -> %s, inNetRemain -> %s", 
                        session.getId(), result.toString(), initialHSStatus, receivedPacketBuf.remaining());
                }

                switch (result.getStatus()) {
                    case SSLEngineResult.Status.OK: {
                        switch (initialHSStatus) {
                            case HandshakeStatus.NEED_TASK:
                                initialHSStatus = doTasks();
                                break unwrapLabel;
                            case HandshakeStatus.NOT_HANDSHAKING:
                            case HandshakeStatus.FINISHED:
                                handshakeFinish();
                                break needIO;
                            default:
                                break unwrapLabel;
                        }
                    }

                    case SSLEngineResult.Status.BUFFER_UNDERFLOW: {
                        switch (initialHSStatus) {
                            case HandshakeStatus.NOT_HANDSHAKING:
                            case HandshakeStatus.FINISHED:
                                handshakeFinish();
                                break needIO;
                            default:
                                break;
                        }

                        int packetBufferSize = sslEngine.getSession().getPacketBufferSize();
                        if (receivedPacketBuf.remaining() >= packetBufferSize) {
                            break; // retry the operation.
                        } else {
                            break needIO;
                        }
                    }

                    case SSLEngineResult.Status.BUFFER_OVERFLOW: {
                        resizeAppBuffer();
                        // retry the operation.
                    }
                    break;

                    case SSLEngineResult.Status.CLOSED: {
                        infof("Connection %s handshake failure. SSLEngine will close inbound", session.getId());
                        closeInbound();
                    }
                    break needIO;

                    default:
                        throw new SecureNetException(format("Connection %s handshake exception. status -> %s", session.getId(), result.getStatus()));

                }
            }
        }
    }

    protected void handshakeFinish() {
        version(HUNT_NET_DEBUG) infof("Connection %s handshake success. The application protocol is %s", 
            session.getId(), getApplicationProtocol());
        initialHSComplete = true;
        if(handshakeListener !is null)
            handshakeListener(this);
    }


    protected void doHandshakeResponse() {

        outer:
        while (initialHSStatus == HandshakeStatus.NEED_WRAP) {
            SSLEngineResult result;
            ByteBuffer packetBuffer = newBuffer(sslEngine.getSession().getPacketBufferSize());

            wrap:
            while (true) {
                result = sslEngine.wrap(hsBuffer, packetBuffer);
                initialHSStatus = result.getHandshakeStatus();
                version(HUNT_NET_DEBUG) {
                    infof("session %s handshake response, init: %s | ret: %s | complete: %s ",
                            session.getId(), initialHSStatus, result.getStatus(), initialHSComplete);
                }

                switch (result.getStatus()) {
                    case SSLEngineResult.Status.OK: {
                        packetBuffer.flip();
                        version(HUNT_NET_DEBUG) {
                            tracef("session %s handshake response %s bytes", 
                                session.getId(), packetBuffer.remaining());
                        }

                        switch (initialHSStatus) {
                            case HandshakeStatus.NEED_TASK: {
                                initialHSStatus = doTasks();
                                if (packetBuffer.hasRemaining()) {
                                    session.write(packetBuffer);
                                }
                            }
                            break;

                            case HandshakeStatus.FINISHED: {
                                if (packetBuffer.hasRemaining()) {
                                    session.write(packetBuffer);
                                    handshakeFinish();
                                } else {
                                    handshakeFinish();
                                }
                            }
                            break;

                            default: {
                                if (packetBuffer.hasRemaining()) {
                                    session.write(packetBuffer);
                                }
                            }
                        }
                    }
                    break wrap;

                    case SSLEngineResult.Status.BUFFER_OVERFLOW:
                        ByteBuffer b = newBuffer(packetBuffer.position() + sslEngine.getSession().getPacketBufferSize());
                        packetBuffer.flip();
                        b.put(packetBuffer);
                        packetBuffer = b;
                        break;

                    case SSLEngineResult.Status.CLOSED:
                        warningf("Connection %s handshake failure. SSLEngine will close inbound", session.getId());
                        packetBuffer.flip();
                        if (packetBuffer.hasRemaining()) {
                            session.write(packetBuffer);
                        }
                        closeOutbound();
                        break outer;

                    default: // BUFFER_UNDERFLOW
                        throw new SecureNetException(format("Connection %s handshake exception. status -> %s", 
                            session.getId(), result.getStatus()));
                }
            }
        }
    }

    protected void resizeAppBuffer() {
        int applicationBufferSize = sslEngine.getSession().getApplicationBufferSize();
        ByteBuffer b = newBuffer(receivedAppBuf.position() + applicationBufferSize);
        receivedAppBuf.flip();
        b.put(receivedAppBuf);
        receivedAppBuf = b;
    }

    protected void merge(ByteBuffer now) {
        if (!now.hasRemaining()) {
            return;
        }

        if (receivedPacketBuf !is null) {
            if (receivedPacketBuf.hasRemaining()) {
                version(HUNT_NET_DEBUG) {
                    tracef("Connection %s read data, merge buffer -> %s, %s", session.getId(),
                            receivedPacketBuf.remaining(), now.remaining());
                }
                ByteBuffer ret = newBuffer(receivedPacketBuf.remaining() + now.remaining());
                ret.put(receivedPacketBuf).put(now).flip();
                receivedPacketBuf = ret;
            } else {
                version(HUNT_NET_DEBUG)  {
                    tracef("buffering data: %s, bytes, current buffer: %s", 
                        now.toString(), receivedPacketBuf.toString());
                }

                if(now.remaining() <= receivedPacketBuf.remaining()) {
                    receivedPacketBuf.clear();
                    receivedPacketBuf.put(now).flip();
                } else {
                    ByteBuffer ret = newBuffer(now.remaining());
                    ret.put(now).flip();
                    receivedPacketBuf = ret;
                }
            }
        } else {
            version(HUNT_NET_DEBUG) tracef("buffering data: %d, bytes", now.remaining());
            ByteBuffer ret = newBuffer(now.remaining());
            ret.put(now).flip();
            receivedPacketBuf = ret;
        }
    }

    protected ByteBuffer getReceivedAppBuf() {
        receivedAppBuf.flip();
        version(HUNT_NET_DEBUG_MORE) {
            tracef("Connection %s read data, get app buf -> %s, %s", 
                session.getId(), receivedAppBuf.position(), receivedAppBuf.limit());
        }

        if (receivedAppBuf.hasRemaining()) {
            ByteBuffer buf = newBuffer(receivedAppBuf.remaining());
            buf.put(receivedAppBuf).flip();
            receivedAppBuf = newBuffer(sslEngine.getSession().getApplicationBufferSize());
            version(HUNT_NET_DEBUG_MORE) {
                tracef("SSL session %s unwrap, app buffer -> %s", session.getId(), buf.remaining());
            }
            return buf;
        } else {
            return null;
        }
    }

    /**
     * Do all the outstanding handshake tasks in the current Thread.
     *
     * @return The result of handshake
     */
    protected HandshakeStatus doTasks() {
        // Runnable runnable;

        // // We could run this in a separate thread, but do in the current for
        // // now.
        // while ((runnable = sslEngine.getDelegatedTask()) !is null) {
        //     runnable.run();
        // }
        // return sslEngine.getHandshakeStatus();
        implementationMissing(false);
        return HandshakeStatus.FINISHED;
    }

    // override
    void close() {
        if (!closed) {
            closed = true;
            closeOutbound();
        }
    }

    protected void closeInbound() {
        try {
            sslEngine.closeInbound();
        } catch (SSLException e) {
            warning("close inbound exception", e);
        } finally {
            session.shutdownInput();
        }
    }

    protected void closeOutbound() {
        sslEngine.closeOutbound();
        session.close();
    }

    override
    string getApplicationProtocol() {
        string protocol = applicationProtocolSelector.getApplicationProtocol();
        tracef("selected protocol -> %s", protocol);
        return protocol;
    }

    override
    string[] getSupportedApplicationProtocols() {
        return applicationProtocolSelector.getSupportedApplicationProtocols();
    }

    override
    bool isOpen() {
        return !closed;
    }

    protected ByteBuffer splitBuffer(int netSize) {
        ByteBuffer buf = receivedPacketBuf.duplicate();
        if (buf.remaining() <= netSize) {
            return buf;
        } else {
            ByteBuffer splitBuf = newBuffer(netSize);
            byte[] data = new byte[netSize];
            buf.get(data);
            splitBuf.put(data).flip();
            return splitBuf;
        }
    }

    protected SSLEngineResult unwrap(ByteBuffer input) {
        version(HUNT_NET_DEBUG_MORE) {
            tracef("Connection %d read data, src -> %s, dst -> %s", 
                session.getId(), input.isDirect(), receivedAppBuf.isDirect());
        }
        receivedAppBuf.clear(); 
        version(HUNT_NET_DEBUG_MORE) infof("receivedAppBuf=%s", receivedAppBuf.toString());
        SSLEngineResult result = sslEngine.unwrap(input, receivedAppBuf);
        if (input !is receivedPacketBuf) {
            int consumed = result.bytesConsumed();
            version(HUNT_NET_DEBUG_MORE) infof("receivedAppBuf=%s, consumed=%d", receivedAppBuf.toString(), consumed);
            receivedPacketBuf.position(receivedPacketBuf.position() + consumed);
        }
        return result;
    }

    protected SSLEngineResult wrap(ByteBuffer src, ByteBuffer dst) {
        return sslEngine.wrap(src, dst);
    }

    protected ByteBuffer newBuffer(int size) {
        return BufferUtils.allocate(size);
    }

    protected SSLEngineResult unwrap() {
        int packetBufferSize = sslEngine.getSession().getPacketBufferSize();
        //split net buffer when the net buffer remaining great than the net size
        ByteBuffer buf = splitBuffer(packetBufferSize);
        version(HUNT_NET_DEBUG_MORE) {
            tracef("Connection %s read data, buf -> %s, packet -> %s, appBuf -> %s",
                    session.getId(), buf.remaining(), packetBufferSize, receivedAppBuf.remaining());
        }
        if (!receivedAppBuf.hasRemaining()) {
            resizeAppBuffer();
        }
        return unwrap(buf);
    }

    /**
     * This method is used to decrypt data, it implied do handshake
     *
     * @param receiveBuffer Encrypted message
     * @return plaintext
     * @sslEngine error during data read
     */
    override
    ByteBuffer read(ByteBuffer receiveBuffer) {
        if (!doHandshake(receiveBuffer))
            return null;

        if (!initialHSComplete)
            throw new IllegalStateException("The initial handshake is not complete.");

        version(HUNT_NET_DEBUG_MORE) {
            tracef("session %s read data status -> %s, initialHSComplete -> %s", session.getId(),
                    session.isConnected(), initialHSComplete);
        }

        merge(receiveBuffer);
        if (!receivedPacketBuf.hasRemaining()) {
            return null;
        }

        needIO:
        while (true) {
            SSLEngineResult result = unwrap();

            version(HUNT_NET_DEBUG_MORE) {
                tracef("Connection %s read data result -> %s, receivedPacketBuf -> %s, appBufSize -> %s",
                        session.getId(), result.toString().replace("\n", " "),
                        receivedPacketBuf.remaining(), receivedAppBuf.remaining());
            }

            switch (result.getStatus()) {
                case SSLEngineResult.Status.BUFFER_OVERFLOW: {
                    resizeAppBuffer();
                    // retry the operation.
                }
                break;
                case SSLEngineResult.Status.BUFFER_UNDERFLOW: {
                    int packetBufferSize = sslEngine.getSession().getPacketBufferSize();
                    if (receivedPacketBuf.remaining() >= packetBufferSize) {
                        break; // retry the operation.
                    } else {
                        break needIO;
                    }
                }
                case SSLEngineResult.Status.OK: {
                    if (result.getHandshakeStatus() == HandshakeStatus.NEED_TASK) {
                        doTasks();
                    }
                    if (receivedPacketBuf.hasRemaining()) {
                        break; // retry the operation.
                    } else {
                        break needIO;
                    }
                }

                case SSLEngineResult.Status.CLOSED: {
                    infof("Connection %s read data failure. SSLEngine will close inbound", session.getId());
                    closeInbound();
                }
                break needIO;

                default:
                    throw new SecureNetException(format("Connection %s SSLEngine read data exception. status -> %s",
                            session.getId(), result.getStatus()));
            }
        }

        return getReceivedAppBuf();
    }

    override
    int write(ByteBuffer[] outputBuffers, Callback callback) {
        int ret = 0;
        CountingCallback countingCallback = new CountingCallback(callback, cast(int)outputBuffers.length);
        foreach (ByteBuffer outputBuffer ; outputBuffers) {
            ret += write(outputBuffer, countingCallback);
        }
        return ret;
    }

    /**
     * This method is used to encrypt and flush to socket channel
     *
     * @param outAppBuf Plaintext message
     * @return writen length
     * @sslEngine error during data write
     */
    override
    int write(ByteBuffer outAppBuf, Callback callback) {
        if (!initialHSComplete) {
            IllegalStateException ex = new IllegalStateException("The initial handshake is not complete.");
            callback.failed(ex);
            throw ex;
        }

        int ret = 0;
        if (!outAppBuf.hasRemaining()) {
            callback.succeeded();
            return ret;
        }

        int remain = outAppBuf.remaining();
        int packetBufferSize = sslEngine.getSession().getPacketBufferSize();
        List!ByteBuffer pocketBuffers = new ArrayList!ByteBuffer();
        bool closeOutput = false;

        outer:
        while (ret < remain) {
            ByteBuffer packetBuffer = newBuffer(packetBufferSize);

            wrap:
            while (true) {
                SSLEngineResult result = wrap(outAppBuf, packetBuffer);
                ret += result.bytesConsumed();

                switch (result.getStatus()) {
                    case SSLEngineResult.Status.OK: {
                        if (result.getHandshakeStatus() == HandshakeStatus.NEED_TASK) {
                            doTasks();
                        }

                        packetBuffer.flip();
                        if (packetBuffer.hasRemaining()) {
                            pocketBuffers.add(packetBuffer);
                        }
                    }
                    break wrap;

                    case SSLEngineResult.Status.BUFFER_OVERFLOW: {
                        packetBufferSize = sslEngine.getSession().getPacketBufferSize();
                        ByteBuffer b = newBuffer(packetBuffer.position() + packetBufferSize);
                        packetBuffer.flip();
                        b.put(packetBuffer);
                        packetBuffer = b;
                    }
                    break; // retry the operation.

                    case SSLEngineResult.Status.CLOSED: {
                        infof("Connection %s SSLEngine will close", session.getId());
                        packetBuffer.flip();
                        if (packetBuffer.hasRemaining()) {
                            pocketBuffers.add(packetBuffer);
                        }
                        closeOutput = true;
                    }
                    break outer;

                    default: {
                        SecureNetException ex = new SecureNetException(format("Connection %s SSLEngine writes data exception. status -> %s", session.getId(), result.getStatus()));
                        callback.failed(ex);
                        throw ex;
                    }
                }
            }
        }

        foreach(ByteBuffer pocket; pocketBuffers) {
            session.write(pocket); // , callback
        }

        callback.succeeded();
        if (closeOutput) {
            closeOutbound();
        }
        return ret;
    }

    protected class FileBufferReaderHandler : BufferReaderHandler {

        private long len;

        private this(long len) {
            this.len = len;
        }

        override
        void readBuffer(ByteBuffer buf, CountingCallback countingCallback, long count) {
            tracef("write file,  count: %d , length: %d", count, len);
            try {
                write(buf, countingCallback);
            } catch (Exception e) {
                errorf("ssl session writing error: ", e.msg);
            }
        }

    }

    // override
    // long transferFileRegion(FileRegion file, Callback callback) {
    //     long ret = 0;
    //     try  {
    //         FileRegion fileRegion = file;
    //         fileRegion.transferTo(callback, new FileBufferReaderHandler(file.getLength()));
    //     }
    //     return ret;
    // }

    override
    bool isHandshakeFinished() {
        return initialHSComplete;
    }

    override
    bool isClientMode() {
        return sslEngine.getUseClientMode();
    }
}
