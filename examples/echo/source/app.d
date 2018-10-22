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
    server.listen(3003).connectHandler((NetSocket sock){
        logInfo("server have accepted a connection...");
        sock.handler(
            ( in ubyte[] data){      
                logInfo("server recved data from client");      
                sock.write(data);
            }
        );
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
