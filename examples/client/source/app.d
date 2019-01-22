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

int main()
{
    import std.stdio;
    auto client = NetUtil.createNetClient();
    client.connectHandler((NetSocket sock){
        writeln("connected-------------------------------------------");
        sock.closeHandler((){
            writeln("disconnected-------------------------------------");
        });
    });
    client.connect(3003, "127.0.0.1");
    NetUtil.startEventLoop();
    while(1){}
}