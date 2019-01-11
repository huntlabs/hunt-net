module hunt.net.exception;

import hunt.Exceptions;

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


