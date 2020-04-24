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
import hunt.net.codec.textline.TextLineCodec;
import hunt.String;
import hunt.logging.ConsoleLogger;
void main() {
    import std.stdio;

    alias logInfo = writeln;
    alias logDebug = writeln;

    auto server = NetUtil.createNetServer!(ThreadMode.Single)();
    server.setCodec(new TextLineCodec);
    server.setHandler(new class NetConnectionHandler {
        override void connectionOpened(Connection connection) {
            warning("accepted a connection...");
        }
        override void messageReceived(Connection connection, Object message){
           // logInfo("received from client %s",(cast(String)message).value);
            warning("received from client %s",(cast(String)message).value);
            connection.write("hello\n");
        }
        override void connectionClosed(Connection connection){
            warning("connection closed");
        }
        override void exceptionCaught(Connection connection, Throwable t)
        {
        }

    }).listen("0.0.0.0", 8080);

    auto client = NetUtil.createNetClient();
    client.setCodec(new TextLineCodec);
    client.setHandler(new class NetConnectionHandler{
        override void connectionOpened(Connection connection) {
            connection.write("hello world\n");
        }
        override void connectionClosed(Connection connection) {
        }
        override void messageReceived(Connection connection, Object message) {
            warning("received from server");
        }
        override void exceptionCaught(Connection connection, Throwable t)
        {

        }
    }).connect("127.0.0.1", 8080);

    getchar();
}
