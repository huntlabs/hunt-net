module hunt.net.exception;

import hunt.lang.exception;

import std.exception;


class SSLException : IOException
{
    mixin basicExceptionCtors;
}


class SSLHandshakeException : SSLException
{
    mixin basicExceptionCtors;
}


class SSLPeerUnverifiedException : SSLException
{
    mixin basicExceptionCtors;
}


