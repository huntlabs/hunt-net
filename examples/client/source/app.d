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
import hunt.logging;

void main() {
    import std.stdio;

    NetClient client = NetUtil.createNetClient();
    client.connectHandler((NetSocket sock) {
        trace("connected-------------------------------------------");
        sock.closeHandler(() {
            trace("disconnected-------------------------------------");
        });
    });
    client.connect(3003, "127.0.0.1", 0, (Result!NetSocket result) {
        if (result.failed()) {
            trace(result.cause().toString());
        } else {
            trace("client have connected to server...");
        }
    });
    NetUtil.startEventLoop();
}
