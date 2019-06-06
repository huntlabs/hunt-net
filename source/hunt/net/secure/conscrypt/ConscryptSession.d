module hunt.net.secure.conscrypt.ConscryptSession;

// dfmt off
version(WITH_HUNT_SECURITY):
// dfmt on

import hunt.security.cert.Certificate;
import hunt.security.cert.X509Certificate;
import hunt.net.ssl.SSLSession;
import hunt.collection.List;

/**
 * Extends the default interface for {@link SSLSession} to provide additional properties exposed
 * by Conscrypt.
 */
interface ConscryptSession : SSLSession {

  string getRequestedServerName();

  /**
   * Returns the OCSP stapled response. Returns a copy of the internal arrays.
   *
   * The method signature matches
   * <a
   * href="http://download.java.net/java/jdk9/docs/api/javax/net/ssl/ExtendedSSLSession.html#getStatusResponses--">Java
   * 9</a>.
   *
   * @see <a href="https://tools.ietf.org/html/rfc6066">RFC 6066</a>
   * @see <a href="https://tools.ietf.org/html/rfc6961">RFC 6961</a>
   */
  List!(byte[]) getStatusResponses();

  /**
   * Returns the signed certificate timestamp (SCT) received from the peer. Returns a
   * copy of the internal array.
   *
   * @see <a href="https://tools.ietf.org/html/rfc6962">RFC 6962</a>
   */
  byte[] getPeerSignedCertificateTimestamp();

  // X509Certificate[] getPeerCertificates();
}
