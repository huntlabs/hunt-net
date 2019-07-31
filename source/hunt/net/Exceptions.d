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
