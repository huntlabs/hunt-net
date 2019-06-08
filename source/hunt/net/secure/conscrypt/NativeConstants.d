module hunt.net.secure.conscrypt.NativeConstants;





// dfmt off
version(WITH_HUNT_SECURITY):
// dfmt on

import deimos.openssl.ssl3;
import deimos.openssl.tls1;

class NativeConstants
{
    enum SSL3_RT_MAX_PACKET_SIZE = deimos.openssl.ssl3.SSL3_RT_MAX_PACKET_SIZE;
    enum SSL3_RT_MAX_PLAIN_LENGTH = deimos.openssl.ssl3.SSL3_RT_MAX_PLAIN_LENGTH;
    
    enum TLS1_VERSION = deimos.openssl.tls1.TLS1_VERSION;
    enum TLS1_1_VERSION = deimos.openssl.tls1.TLS1_1_VERSION;
    enum TLS1_2_VERSION = deimos.openssl.tls1.TLS1_2_VERSION;

    
    enum SSL_MODE_SEND_FALLBACK_SCSV = 0x00000400L;
}