module hunt.net.secure.conscrypt.OpenSSLKeyHolder;

import hunt.net.secure.conscrypt.OpenSSLKey;

/**
 * Marker interface for classes that hold an {@link OpenSSLKey}.
 *
 * @hide
 */
interface OpenSSLKeyHolder {
    OpenSSLKey getOpenSSLKey();
}
