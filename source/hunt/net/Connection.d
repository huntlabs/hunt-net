module hunt.net.Connection;

import hunt.util.common;

import std.socket;

interface Connection : Closeable { 

    Object getAttachment();

    void setAttachment(Object object);

    int getSessionId();

    long getOpenTime();

    long getCloseTime();

    long getDuration();

    long getLastReadTime();

    long getLastWrittenTime();

    long getLastActiveTime();

    long getReadBytes();

    long getWrittenBytes();

    long getIdleTimeout();

    long getMaxIdleTimeout();

    bool isOpen();

    bool isClosed();

    Address getLocalAddress();

    Address getRemoteAddress();

}