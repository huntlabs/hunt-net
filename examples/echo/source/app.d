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
 import kiss.logger;

void main() 
{   
    
    auto server = Net.createNetServer();
    server.listen(3003).connectHandler((NetSocket sock){
        size_t count = 0;
        logInfo("server accept a conn");
        sock.handler(
            ( in ubyte[] data){
                logInfo("server recved " , cast(string)data , " " , ++count);
                sock.write(data);
                logInfo("server send " , cast(string)data , " " , count);
            }
        );
    });

    auto client = Net.createNetClient();
    client.connect(3003 , "127.0.0.1" , (bool suc , NetSocket sock)
    {
        size_t count = 0;
        logDebug("client connect a conn " , suc , " " , sock.toHash());
        sock.write("hello world");
        sock.handler((in ubyte[] data){
            import core.thread;
            logDebug("Client recv " , cast(string)data , " " , ++count);
            Thread.sleep(dur!"seconds"(1));
            sock.write(data);
            logDebug("Client send " , cast(string)data , " " , count);
        });
    });   
    import std.stdio;
    getchar();

}
