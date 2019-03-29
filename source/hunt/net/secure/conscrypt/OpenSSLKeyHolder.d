module hunt.net.secure.conscrypt.OpenSSLKeyHolder;

// dfmt off
import hunt.net.VersionUtil;
mixin(checkVersions());
version(WITH_HUNT_SECURITY) :
// dfmt on

import hunt.net.secure.conscrypt.OpenSSLKey;

/**
 * Marker interface for classes that hold an {@link OpenSSLKey}.
 *
 * @hide
 */
interface OpenSSLKeyHolder {
    OpenSSLKey getOpenSSLKey();
}
