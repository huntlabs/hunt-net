module hunt.security.OpenSSLRandom;

import hunt.security.SecureRandomSpi;

import hunt.util.exception;

/**
 * Implements {@link java.security.SecureRandom} using BoringSSL's RAND interface.
 *
 * @hide
 */
public final class OpenSSLRandom : SecureRandomSpi  {
    // private static final long serialVersionUID = 8506210602917522861L;

    override
    protected void engineSetSeed(byte[] seed) {
        if (seed == null) {
            throw new NullPointerException("seed == null");
        }
    }

    override
    protected void engineNextBytes(byte[] bytes) {
        // NativeCrypto.RAND_bytes(bytes);
        implementationMissing();
    }

    override
    protected byte[] engineGenerateSeed(int numBytes) {
        byte[] output = new byte[numBytes];
        // NativeCrypto.RAND_bytes(output);
        implementationMissing();
        return output;
    }
}

