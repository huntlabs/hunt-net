module hunt.net.secure.conscrypt.SSLNullSession;

import hunt.net.secure.conscrypt.AbstractSessionContext;
import hunt.net.secure.conscrypt.ConscryptSession;
import hunt.net.secure.conscrypt.NativeSsl;
import hunt.net.secure.conscrypt.NativeConstants;
import hunt.net.secure.conscrypt.SSLUtils;

import hunt.net.ssl.SSLSessionContext;

import hunt.security.cert.Certificate;
import hunt.security.cert.X509Certificate;
import hunt.security.Principal;

import hunt.net.ssl.SSLSession;
import hunt.net.exception;

import hunt.container.List;

import hunt.util.datetime;
import hunt.util.exception;


/**
 * This is returned in the place of a {@link SSLSession} when no TLS connection could be negotiated,
 * but one was requested from a method that can't throw an exception such as {@link
 * javax.net.ssl.SSLSocket#getSession()} before {@link javax.net.ssl.SSLSocket#startHandshake()} is
 * called.
 */
final class SSLNullSession { //  : ConscryptSession
    enum string INVALID_CIPHER = "SSL_NULL_WITH_NULL_NULL";

    // /*
    //  * Holds default instances so class preloading doesn't create an instance of
    //  * it.
    //  */
    // private static class DefaultHolder {
    //     static final SSLNullSession NULL_SESSION = new SSLNullSession();
    // }

    // private long creationTime;
    // private long lastAccessedTime;

    // static ConscryptSession getNullSession() {
    //     return DefaultHolder.NULL_SESSION;
    // }

    // static bool isNullSession(SSLSession session) {
    //     return SSLUtils.unwrapSession(session) == DefaultHolder.NULL_SESSION;
    // }

    // private SSLNullSession() {
    //     creationTime = DateTimeHelper.currentTimeMillis();
    //     lastAccessedTime = creationTime;
    // }

    // override
    // string getRequestedServerName() {
    //     return null;
    // }

    // override
    // List!(byte[]) getStatusResponses() {
    //     return Collections.emptyList();
    // }

    // override
    // byte[] getPeerSignedCertificateTimestamp() {
    //     return [];
    // }

    // override
    // int getApplicationBufferSize() {
    //     return NativeConstants.SSL3_RT_MAX_PLAIN_LENGTH;
    // }

    // override
    // string getCipherSuite() {
    //     return INVALID_CIPHER;
    // }

    // override
    // long getCreationTime() {
    //     return creationTime;
    // }

    // override
    // byte[] getId() {
    //     return EmptyArray.BYTE;
    // }

    // override
    // long getLastAccessedTime() {
    //     return lastAccessedTime;
    // }

    // override
    // Certificate[] getLocalCertificates() {
    //     return null;
    // }

    // override
    // Principal getLocalPrincipal() {
    //     return null;
    // }

    // override
    // int getPacketBufferSize() {
    //     return NativeConstants.SSL3_RT_MAX_PACKET_SIZE;
    // }

    // override
    // X509Certificate[] getPeerCertificateChain(){
    //     throw new SSLPeerUnverifiedException("No peer certificate");
    // }

    // override
    // X509Certificate[] getPeerCertificates(){
    //     throw new SSLPeerUnverifiedException("No peer certificate");
    // }

    // override
    // string getPeerHost() {
    //     return null;
    // }

    // override
    // int getPeerPort() {
    //     return -1;
    // }

    // override
    // Principal getPeerPrincipal(){
    //     throw new SSLPeerUnverifiedException("No peer certificate");
    // }

    // override
    // string getProtocol() {
    //     return "NONE";
    // }

    // override
    // SSLSessionContext getSessionContext() {
    //     return null;
    // }

    // override
    // Object getValue(string name) {
    //     throw new UnsupportedOperationException(
    //             "All calls to this method should be intercepted by ProvidedSessionDecorator.");
    // }

    // override
    // string[] getValueNames() {
    //     throw new UnsupportedOperationException(
    //             "All calls to this method should be intercepted by ProvidedSessionDecorator.");
    // }

    // override
    // void invalidate() {
    // }

    // override
    // bool isValid() {
    //     return false;
    // }

    // override
    // void putValue(string name, Object value) {
    //     throw new UnsupportedOperationException(
    //             "All calls to this method should be intercepted by ProvidedSessionDecorator.");
    // }

    // override
    // void removeValue(string name) {
    //     throw new UnsupportedOperationException(
    //             "All calls to this method should be intercepted by ProvidedSessionDecorator.");
    // }
}
