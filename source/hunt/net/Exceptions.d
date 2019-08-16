module hunt.net.Exceptions;

import hunt.Exceptions;

import std.exception;
import std.conv;

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
 * An {@link IllegalStateException} which is raised when a user attempts to access a {@link ReferenceCounted} whose
 * reference count has been decreased to 0 (and consequently freed).
 */
class IllegalReferenceCountException : IllegalStateException {
    // mixin basicExceptionCtors;
    /++
        Params:
            msg  = The message for the exception.
            file = The file where the exception occurred.
            line = The line number where the exception occurred.
            next = The previous exception in the chain of exceptions, if any.
    +/
    this(string msg, string file = __FILE__, size_t line = __LINE__,
         Throwable next = null) @nogc @safe pure nothrow
    {
        super(msg, file, line, next);
    }

    /++
        Params:
            msg  = The message for the exception.
            next = The previous exception in the chain of exceptions.
            file = The file where the exception occurred.
            line = The line number where the exception occurred.
    +/
    this(string msg, Throwable next, string file = __FILE__,
         size_t line = __LINE__) @nogc @safe pure nothrow
    {
        super(msg, file, line, next);
    }    

    this(int refCnt) {
        this("refCnt: " ~ refCnt.to!string());
    }

    this(int refCnt, int increment) {
        this("refCnt: " ~ refCnt.to!string() ~ ", " ~ 
            (increment > 0? "increment: " ~ increment.to!string() : 
                "decrement: -" ~ increment.to!string()));
    }    
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

