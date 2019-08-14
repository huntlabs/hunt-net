module hunt.net.Exceptions;

import hunt.Exceptions;

import std.exception;

class SSLException : IOException {
    mixin basicExceptionCtors;
}

class SSLHandshakeException : SSLException {
    mixin basicExceptionCtors;
}

class SSLPeerUnverifiedException : SSLException {
    mixin basicExceptionCtors;
}

class RecoverableProtocolDecoderException : SSLException {
    mixin basicExceptionCtors;
}


/**
 * An {@link Exception} which is thrown by a codec.
 */
class CodecException : RuntimeException {
    mixin basicExceptionCtors;
}

class DecoderException : CodecException {
    mixin basicExceptionCtors;
}

class EncoderException : CodecException {
    mixin basicExceptionCtors;
}

