module hunt.net.secure.conscrypt.OpenSSLKey;

version(BoringSSL) {
    version=WithSSL;
} else version(OpenSSL) {
    version=WithSSL;
}
version(WithSSL):

import hunt.net.secure.conscrypt.NativeCrypto;
import hunt.net.secure.conscrypt.NativeRef;
import hunt.net.secure.conscrypt.OpenSSLKeyHolder;

import hunt.security.key;

import hunt.util.exception;
import hunt.string;

/**
 * Represents a BoringSSL {@code EVP_PKEY}.
 */
final class OpenSSLKey {
    private NativeRef.EVP_PKEY ctx;

    private bool wrapped;

    this(long ctx) {
        this(ctx, false);
    }

    this(long ctx, bool wrapped) {
        this.ctx = new NativeRef.EVP_PKEY(ctx);
        this.wrapped = wrapped;
    }

    /**
     * Returns the EVP_PKEY context for use in JNI calls.
     */
    NativeRef.EVP_PKEY getNativeRef() {
        return ctx;
    }

    bool isWrapped() {
        return wrapped;
    }

    // static OpenSSLKey fromPrivateKey(PrivateKey key) {
    //     if (key instanceof OpenSSLKeyHolder) {
    //         return ((OpenSSLKeyHolder) key).getOpenSSLKey();
    //     }

    //     string keyFormat = key.getFormat();
    //     if (keyFormat == null) {
    //         return wrapPrivateKey(key);
    //     } else if (!"PKCS#8".equals(key.getFormat())) {
    //         throw new InvalidKeyException("Unknown key format " + keyFormat);
    //     }

    //     byte[] encoded = key.getEncoded();
    //     if (encoded == null) {
    //         throw new InvalidKeyException("Key encoding is null");
    //     }

    //     try {
    //         return new OpenSSLKey(NativeCrypto.EVP_parse_private_key(key.getEncoded()));
    //     } catch (ParsingException e) {
    //         throw new InvalidKeyException(e);
    //     }
    // }

    // /**
    //  * Parse a private key in PEM encoding from the provided input stream.
    //  *
    //  * @throws InvalidKeyException if parsing fails
    //  */
    // static OpenSSLKey fromPrivateKeyPemInputStream(InputStream is)
    //         {
    //     OpenSSLBIOInputStream bis = new OpenSSLBIOInputStream(is, true);
    //     try {
    //         long keyCtx = NativeCrypto.PEM_read_bio_PrivateKey(bis.getBioContext());
    //         if (keyCtx == 0L) {
    //             return null;
    //         }

    //         return new OpenSSLKey(keyCtx);
    //     } catch (Exception e) {
    //         throw new InvalidKeyException(e);
    //     } finally {
    //         bis.release();
    //     }
    // }

    /**
     * Gets an {@code OpenSSLKey} instance backed by the provided private key. The resulting key is
     * usable only by this provider's TLS/SSL stack.
     *
     * @param privateKey private key.
     * @param publicKey corresponding key or {@code null} if not available. Some opaque
     *        private keys cannot be used by the TLS/SSL stack without the key.
     */
    static OpenSSLKey fromPrivateKeyForTLSStackOnly(
            PrivateKey privateKey, PublicKey publicKey) {
        OpenSSLKey result = getOpenSSLKey(privateKey);
        if (result !is null) {
            return result;
        }

        result = fromKeyMaterial(privateKey);
        if (result !is null) {
            return result;
        }

        return wrapJCAPrivateKeyForTLSStackOnly(privateKey, publicKey);
    }

    // /**
    //  * Gets an {@code OpenSSLKey} instance backed by the provided EC private key. The resulting key
    //  * is usable only by this provider's TLS/SSL stack.
    //  *
    //  * @param key private key.
    //  * @param ecParams EC parameters {@code null} if not available. Some opaque private keys cannot
    //  *        be used by the TLS/SSL stack without the parameters because the private key itself
    //  *        might not expose the parameters.
    //  */
    // static OpenSSLKey fromECPrivateKeyForTLSStackOnly(
    //         PrivateKey key, ECParameterSpec ecParams) {
    //     OpenSSLKey result = getOpenSSLKey(key);
    //     if (result !is null) {
    //         return result;
    //     }

    //     result = fromKeyMaterial(key);
    //     if (result !is null) {
    //         return result;
    //     }

    //     return OpenSSLECPrivateKey.wrapJCAPrivateKeyForTLSStackOnly(key, ecParams);
    // }

    /**
     * Gets the {@code OpenSSLKey} instance of the provided key.
     *
     * @return instance or {@code null} if the {@code key} is not backed by OpenSSL's
     *         {@code EVP_PKEY}.
     */
    private static OpenSSLKey getOpenSSLKey(PrivateKey key) {
        OpenSSLKeyHolder keyHolder = cast(OpenSSLKeyHolder) key;
        if (keyHolder !is null) {
            return keyHolder.getOpenSSLKey();
        }

        if ("RSA" == key.getAlgorithm()) {
            implementationMissing(false);
            // return Platform.wrapRsaKey(key);
        }

        return null;
    }

    /**
     * Gets an {@code OpenSSLKey} instance initialized with the key material of the provided key.
     *
     * @return instance or {@code null} if the {@code key} does not export its key material in a
     *         suitable format.
     */
    private static OpenSSLKey fromKeyMaterial(PrivateKey key) {
        if (!"PKCS#8".equals(key.getFormat())) {
            return null;
        }
        byte[] encoded = key.getEncoded();
        if (encoded == null) {
            return null;
        }
        try {
            version(BoringSSL) return new OpenSSLKey(NativeCrypto.EVP_parse_private_key(encoded));
            version(OpenSSL) {
                implementationMissing(false);
                return null;
            }
        } catch (ParsingException e) {
            throw new InvalidKeyException(e.msg);
        }
    }

    /**
     * Wraps the provided private key for use in the TLS/SSL stack only. Sign/decrypt operations
     * using the key will be delegated to the {@code Signature}/{@code Cipher} implementation of the
     * provider which accepts the key.
     */
    private static OpenSSLKey wrapJCAPrivateKeyForTLSStackOnly(PrivateKey privateKey,
            PublicKey publicKey) {
        string keyAlgorithm = privateKey.getAlgorithm();
        implementationMissing(false);
        return null;
        // if ("RSA".equals(keyAlgorithm)) {
        //     return OpenSSLRSAPrivateKey.wrapJCAPrivateKeyForTLSStackOnly(privateKey, publicKey);
        // } else if ("EC".equals(keyAlgorithm)) {
        //     return OpenSSLECPrivateKey.wrapJCAPrivateKeyForTLSStackOnly(privateKey, publicKey);
        // } else {
        //     throw new InvalidKeyException("Unsupported key algorithm: " + keyAlgorithm);
        // }
    }

    // private static OpenSSLKey wrapPrivateKey(PrivateKey key) {
    //     if (key instanceof RSAPrivateKey) {
    //         return OpenSSLRSAPrivateKey.wrapPlatformKey((RSAPrivateKey) key);
    //     } else if (key instanceof ECPrivateKey) {
    //         return OpenSSLECPrivateKey.wrapPlatformKey((ECPrivateKey) key);
    //     } else {
    //         throw new InvalidKeyException("Unknown key type: " + key.toString());
    //     }
    // }

    // static OpenSSLKey fromPublicKey(PublicKey key) {
    //     if (key instanceof OpenSSLKeyHolder) {
    //         return ((OpenSSLKeyHolder) key).getOpenSSLKey();
    //     }

    //     if (!"X.509".equals(key.getFormat())) {
    //         throw new InvalidKeyException("Unknown key format " + key.getFormat());
    //     }

    //     byte[] encoded = key.getEncoded();
    //     if (encoded == null) {
    //         throw new InvalidKeyException("Key encoding is null");
    //     }

    //     try {
    //         return new OpenSSLKey(NativeCrypto.EVP_parse_public_key(key.getEncoded()));
    //     } catch (Exception e) {
    //         throw new InvalidKeyException(e);
    //     }
    // }

    // /**
    //  * Parse a key in PEM encoding from the provided input stream.
    //  *
    //  * @throws InvalidKeyException if parsing fails
    //  */
    // static OpenSSLKey fromPublicKeyPemInputStream(InputStream is)
    //         {
    //     OpenSSLBIOInputStream bis = new OpenSSLBIOInputStream(is, true);
    //     try {
    //         long keyCtx = NativeCrypto.PEM_read_bio_PUBKEY(bis.getBioContext());
    //         if (keyCtx == 0L) {
    //             return null;
    //         }

    //         return new OpenSSLKey(keyCtx);
    //     } catch (Exception e) {
    //         throw new InvalidKeyException(e);
    //     } finally {
    //         bis.release();
    //     }
    // }

    // PublicKey getPublicKey() throws NoSuchAlgorithmException {
    //     switch (NativeCrypto.EVP_PKEY_type(ctx)) {
    //         case NativeConstants.EVP_PKEY_RSA:
    //             return new OpenSSLRSAPublicKey(this);
    //         case NativeConstants.EVP_PKEY_EC:
    //             return new OpenSSLECPublicKey(this);
    //         default:
    //             throw new NoSuchAlgorithmException("unknown PKEY type");
    //     }
    // }

    // static PublicKey getPublicKey(X509EncodedKeySpec keySpec, int type)
    //         throws InvalidKeySpecException {
    //     X509EncodedKeySpec x509KeySpec = keySpec;

    //     OpenSSLKey key;
    //     try {
    //         key = new OpenSSLKey(NativeCrypto.EVP_parse_public_key(x509KeySpec.getEncoded()));
    //     } catch (Exception e) {
    //         throw new InvalidKeySpecException(e);
    //     }

    //     if (NativeCrypto.EVP_PKEY_type(key.getNativeRef()) != type) {
    //         throw new InvalidKeySpecException("Unexpected key type");
    //     }

    //     try {
    //         return key.getPublicKey();
    //     } catch (NoSuchAlgorithmException e) {
    //         throw new InvalidKeySpecException(e);
    //     }
    // }

    // PrivateKey getPrivateKey() throws NoSuchAlgorithmException {
    //     switch (NativeCrypto.EVP_PKEY_type(ctx)) {
    //         case NativeConstants.EVP_PKEY_RSA:
    //             return new OpenSSLRSAPrivateKey(this);
    //         case NativeConstants.EVP_PKEY_EC:
    //             return new OpenSSLECPrivateKey(this);
    //         default:
    //             throw new NoSuchAlgorithmException("unknown PKEY type");
    //     }
    // }

    // static PrivateKey getPrivateKey(PKCS8EncodedKeySpec keySpec, int type)
    //         throws InvalidKeySpecException {
    //     PKCS8EncodedKeySpec pkcs8KeySpec = keySpec;

    //     OpenSSLKey key;
    //     try {
    //         key = new OpenSSLKey(NativeCrypto.EVP_parse_private_key(pkcs8KeySpec.getEncoded()));
    //     } catch (Exception e) {
    //         throw new InvalidKeySpecException(e);
    //     }

    //     if (NativeCrypto.EVP_PKEY_type(key.getNativeRef()) != type) {
    //         throw new InvalidKeySpecException("Unexpected key type");
    //     }

    //     try {
    //         return key.getPrivateKey();
    //     } catch (NoSuchAlgorithmException e) {
    //         throw new InvalidKeySpecException(e);
    //     }
    // }

    // override
    // bool equals(Object o) {
    //     if (o == this) {
    //         return true;
    //     }

    //     if (!(o instanceof OpenSSLKey)) {
    //         return false;
    //     }

    //     OpenSSLKey other = (OpenSSLKey) o;
    //     if (ctx.equals(other.getNativeRef())) {
    //         return true;
    //     }

    //     return NativeCrypto.EVP_PKEY_cmp(ctx, other.getNativeRef()) == 1;
    // }

    // override
    // int hashCode() {
    //     return ctx.hashCode();
    // }
}
