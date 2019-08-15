module hunt.net.secure.conscrypt.SessionSnapshot;

// dfmt off
version(WITH_HUNT_SECURITY):
// dfmt on

import hunt.net.secure.conscrypt.ConscryptSession;
import hunt.net.secure.conscrypt.NativeConstants;

import hunt.security.cert.Certificate;
import hunt.security.cert.X509Certificate;

import hunt.net.ssl.SSLSession;
import hunt.net.ssl.SSLSessionContext;

import hunt.security.Principal;
import hunt.security.cert.Certificate;

import hunt.collection;

import hunt.net.Exceptions;
import hunt.Exceptions;

/**
 * A snapshot of the content of another {@link ConscryptSession}. This copies everything over
 * except for the certificates.
 */
final class SessionSnapshot : ConscryptSession {
    private SSLSessionContext sessionContext;
    private byte[] id;
    private string requestedServerName;
    private List!(byte[]) statusResponses;
    private byte[] peerTlsSctData;
    private long creationTime;
    private long lastAccessedTime;
    private string cipherSuite;
    private string protocol;
    private string peerHost;
    private int peerPort;

    this(ConscryptSession session) {
        sessionContext = session.getSessionContext();
        id = session.getId();
        requestedServerName = session.getRequestedServerName();
        statusResponses = session.getStatusResponses();
        peerTlsSctData = session.getPeerSignedCertificateTimestamp();
        creationTime = session.getCreationTime();
        lastAccessedTime = session.getLastAccessedTime();
        cipherSuite = session.getCipherSuite();
        protocol = session.getProtocol();
        peerHost = session.getPeerHost();
        peerPort = session.getPeerPort();
    }

    override
    string getRequestedServerName() {
        return requestedServerName;
    }

    override
    List!(byte[]) getStatusResponses() {
        List!(byte[]) ret = new ArrayList!(byte[])(statusResponses.size());
        foreach (byte[] resp ; statusResponses) {
            ret.add(resp.dup);
        }
        return ret;
    }

    override
    byte[] getPeerSignedCertificateTimestamp() {
        return peerTlsSctData !is null ? peerTlsSctData.dup : null;
    }

    override
    byte[] getId() {
        return id;
    }

    override
    SSLSessionContext getSessionContext() {
        return sessionContext;
    }

    override
    long getCreationTime() {
        return creationTime;
    }

    override
    long getLastAccessedTime() {
        return lastAccessedTime;
    }

    override
    void invalidate() {
        // Do nothing.
    }

    override
    bool isValid() {
        return false;
    }

    override
    void putValue(string s, Object o) {
        throw new UnsupportedOperationException(
                "All calls to this method should be intercepted by ProvidedSessionDecorator.");
    }

    override
    Object getValue(string s) {
        throw new UnsupportedOperationException(
                "All calls to this method should be intercepted by ProvidedSessionDecorator.");
    }

    override
    void removeValue(string s) {
        throw new UnsupportedOperationException(
                "All calls to this method should be intercepted by ProvidedSessionDecorator.");
    }

    override
    string[] getValueNames() {
        throw new UnsupportedOperationException(
                "All calls to this method should be intercepted by ProvidedSessionDecorator.");
    }

    override
    Certificate[] getPeerCertificates()  {
        throw new SSLPeerUnverifiedException("No peer certificates");
    }

    override
    Certificate[] getLocalCertificates() {
        return null;
    }

    override
    X509Certificate[] getPeerCertificateChain(){
        throw new SSLPeerUnverifiedException("No peer certificates");
    }

    override
    Principal getPeerPrincipal()  {
        throw new SSLPeerUnverifiedException("No peer certificates");
    }

    override
    Principal getLocalPrincipal() {
        return null;
    }

    override
    string getCipherSuite() {
        return cipherSuite;
    }

    override
    string getProtocol() {
        return protocol;
    }

    override
    string getPeerHost() {
        return peerHost;
    }

    override
    int getPeerPort() {
        return peerPort;
    }

    override
    int getPacketBufferSize() {
        return NativeConstants.SSL3_RT_MAX_PACKET_SIZE;
    }

    override
    int getApplicationBufferSize() {
        return NativeConstants.SSL3_RT_MAX_PLAIN_LENGTH;
    }
}
