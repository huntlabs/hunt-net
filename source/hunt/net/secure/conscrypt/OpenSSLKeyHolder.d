module hunt.net.secure.conscrypt.OpenSSLKeyHolder;

version(BoringSSL) {
    version=WithSSL;
} else version(OpenSSL) {
    version=WithSSL;
}
version(WithSSL):

import hunt.net.secure.conscrypt.OpenSSLKey;

/**
 * Marker interface for classes that hold an {@link OpenSSLKey}.
 *
 * @hide
 */
interface OpenSSLKeyHolder {
    OpenSSLKey getOpenSSLKey();
}
