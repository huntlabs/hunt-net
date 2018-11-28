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

void main() 
{   
    import std.stdio;

    alias logInfo = writeln;
    alias logDebug= writeln;
    
    auto server = NetUtil.createNetServer();
    server.connectionHandler((NetSocket sock){
        logInfo("accepted a connection...");
        sock.handler(
            ( in ubyte[] data){      
                logInfo("recved data from client");      
                sock.write(data);
            }
        );
    }).listen("0.0.0.0", 3003, (Result!Server result){
        if(result.failed())
            throw result.cause();
    });


    auto client = NetUtil.createNetClient();
    client.connect(3003 , "127.0.0.1" , 0, (Result!NetSocket result)
    {
        if(result.failed())
        {
            logDebug(result.cause().toString());
            return;
        }
        auto sock = result.result();
        logDebug("client have connected to server...");
        logDebug("client send data to server");
        sock.write("hello world");
        sock.handler((in ubyte[] data){
            import core.thread;
            Thread.sleep(dur!"seconds"(1));
            logDebug("client send data to server");
            sock.write(data);
            
        });
    });   
    getchar();

}
