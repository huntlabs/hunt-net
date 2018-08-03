module hunt.net.secure.conscrypt.NativeRef;

import hunt.net.secure.conscrypt.NativeCrypto;

import hunt.util.exception;

/**
 * Used to hold onto native OpenSSL references and run finalization on those
 * objects. Individual types must subclass this and implement finalizer.
 */
abstract class NativeRef {
    long context;

    this(long context) {
        if (context == 0) {
            throw new NullPointerException("context == 0");
        }

        this.context = context;
    }

    override
    bool opEquals(Object o) {
        if (typeid(o) != typeid(NativeRef)) {
            return false;
        }

        return (cast(NativeRef) o).context == context;
    }

    override size_t toHash() @trusted nothrow {
        return cast(size_t)context;
    }

    protected void finalize() {
        try {
            if (context != 0) {
                doFree(context);
            }
        } finally {
            // super.finalize();
        }
    }

    abstract void doFree(long context);

    // static final class EC_GROUP : NativeRef {
    //     EC_GROUP(long ctx) {
    //         super(ctx);
    //     }

    //     override
    //     void doFree(long context) {
    //         NativeCrypto.EC_GROUP_clear_free(context);
    //     }
    // }

    // static final class EC_POINT : NativeRef {
    //     EC_POINT(long nativePointer) {
    //         super(nativePointer);
    //     }

    //     override
    //     void doFree(long context) {
    //         NativeCrypto.EC_POINT_clear_free(context);
    //     }
    // }

    // static final class EVP_CIPHER_CTX : NativeRef {
    //     EVP_CIPHER_CTX(long nativePointer) {
    //         super(nativePointer);
    //     }

    //     override
    //     void doFree(long context) {
    //         NativeCrypto.EVP_CIPHER_CTX_free(context);
    //     }
    // }

    // static final class EVP_MD_CTX : NativeRef {
    //     EVP_MD_CTX(long nativePointer) {
    //         super(nativePointer);
    //     }

    //     override
    //     void doFree(long context) {
    //         NativeCrypto.EVP_MD_CTX_destroy(context);
    //     }
    // }

    static final class EVP_PKEY : NativeRef {
        this(long nativePointer) {
            super(nativePointer);
        }

        override
        void doFree(long context) {
            NativeCrypto.EVP_PKEY_free(context);
        }
    }

    // static final class EVP_PKEY_CTX : NativeRef {
    //     EVP_PKEY_CTX(long nativePointer) {
    //         super(nativePointer);
    //     }

    //     override
    //     void doFree(long context) {
    //         NativeCrypto.EVP_PKEY_CTX_free(context);
    //     }
    // }

    // static final class HMAC_CTX : NativeRef {
    //     HMAC_CTX(long nativePointer) {
    //         super(nativePointer);
    //     }

    //     override
    //     void doFree(long context) {
    //         NativeCrypto.HMAC_CTX_free(context);
    //     }
    // }

    static final class SSL_SESSION : NativeRef {
        this(long nativePointer) {
            super(nativePointer);
        }

        override
        void doFree(long context) {
            NativeCrypto.SSL_SESSION_free(context);
        }
    }
}
