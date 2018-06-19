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
    
    auto server = Net.createNetServer();
    server.listen(3003).connectHandler((NetSocket sock){
        size_t count = 0;
        logInfo("server accept a conn");
        sock.handler(
            ( in ubyte[] data){      
                count = ++count;
                logInfo("server recved "  , count , " " , data.length);      
                sock.write(data);
            }
        );
    });

    auto client = Net.createNetClient();
    client.connect(3003 , "127.0.0.1" , (bool suc , NetSocket sock)
    {
        size_t count = 1;
        logDebug("client connect a conn " , suc , " " , sock.toHash());
        sock.write("hello world");
        sock.handler((in ubyte[] data){
            import core.thread;
            count = ++count;
            logDebug("Client begin send "  , count);
            Thread.sleep(dur!"seconds"(1));
            sock.write(data);
            logDebug("Client send "  , count);
            
        });
    });   
    import std.stdio;
    getchar();

}
