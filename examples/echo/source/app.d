/*
 *
 *
 * Copyright (C) 2015-2017  Shanghai Putao Technology Co., Ltd
 *
 * Developer: HuntLabs
 *
 * Licensed under the Apache-2.0 License.
 *
 */

import hunt.net;
import hunt.collection.ByteBuffer;

import core.time;
import core.thread;

void main() {
    import std.stdio;

    alias logInfo = writeln;
    alias logDebug = writeln;

    auto server = NetUtil.createNetServer!(ServerThreadMode.Single)();
    server.connectionHandler((NetSocket sock) {
        logInfo("accepted a connection...");
        sock.handler((ByteBuffer buffer) {
            logInfo("received from client");
            sock.write(buffer);
        });
    }).listen("0.0.0.0", 8080, (Result!Server result) {
        if (result.failed())
            throw result.cause();
    });

    auto client = NetUtil.createNetClient();
    client.connect(8080, "127.0.0.1", 0, (Result!NetSocket result) {
        if (result.failed()) {
            logDebug(result.cause().toString());
            return;
        }
        auto sock = result.result();
        logDebug("client have connected to server...");
        logDebug("client send data to server");
        sock.write("hello world");
        
        sock.handler((ByteBuffer buffer) {
            Thread.sleep(2.seconds);
            logDebug("client send data to server");
            sock.write(buffer);

        });
    });
    getchar();

}
