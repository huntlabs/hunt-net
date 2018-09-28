module hunt.net.secure.conscrypt.NativeConstants;

version(NoSSL) {} else {
import deimos.openssl.ssl3;
import deimos.openssl.tls1;

class NativeConstants
{
    // TODO: Tasks pending completion -@zxp at 7/30/2018, 1:59:29 PM
    // 
    enum SSL3_RT_MAX_PACKET_SIZE = deimos.openssl.ssl3.SSL3_RT_MAX_PACKET_SIZE;
    enum SSL3_RT_MAX_PLAIN_LENGTH = deimos.openssl.ssl3.SSL3_RT_MAX_PLAIN_LENGTH;
    
    enum TLS1_VERSION = deimos.openssl.tls1.TLS1_VERSION;
    enum TLS1_1_VERSION = deimos.openssl.tls1.TLS1_1_VERSION;
    enum TLS1_2_VERSION = deimos.openssl.tls1.TLS1_2_VERSION;

    
    enum SSL_MODE_SEND_FALLBACK_SCSV = 0x00000400L;
}
}