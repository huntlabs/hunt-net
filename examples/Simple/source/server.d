module server;

import hunt.net;
import hunt.logging.ConsoleLogger;

import hunt.net.codec.textline;
import hunt.util.worker;

import std.format;
import core.atomic;

import hunt.io.channel.posix.AbstractStream;

enum Host = "0.0.0.0";
enum Port = 8080;

enum string ResponseContent = "HTTP/1.1 200 OK\r\nContent-Length: 13\r\nConnection: Keep-Alive\r\nContent-Type: text/plain\r\nServer: Hunt/1.0\r\nDate: Wed, 17 Apr 2013 12:00:00 GMT\r\n\r\nHello, World!";


    // "versions": ["HUNT_DEBUG", "HUNT_IO_DEBUG", "HUNT_NET_DEBUG", "HUNT_METRIC"],

void main() {

    NetServerOptions options = new NetServerOptions();
    options.workerThreadSize = 5;
    shared int counter = 0;

    NetServer server = NetUtil.createNetServer(options);

    // server.setCodec(new TextLineCodec);

    // dfmt off
    server.setHandler(new class NetConnectionHandler {

        override void connectionOpened(Connection connection) {
            // debug infof("Connection created: %s", connection.getRemoteAddress());
        }

        override void connectionClosed(Connection connection) {
            // debug infof("Connection closed: %s", connection.getRemoteAddress());
        }

        override DataHandleStatus messageReceived(Connection connection, Object message) {
            string str;
            version(HUNT_IO_DEBUG) {
                tracef("message type: %s", typeid(message).name);
                str = format("data received: %s", message.toString());
                tracef(str);
            }
            
            int c = atomicOp!("+=")(counter, 1);
            if(c % 100 == 0)
                warningf("Response: %d", c);

            import hunt.io.ByteBuffer;
            ByteBuffer buffer = cast(ByteBuffer)message;
            // debug warning(cast(string)buffer.peekRemaining());

            str = cast(string)buffer.peekRemaining();
            // warning(str);
            if(str == "peek") {
                warningf("Response: %d, requests: %d", c, dataCounter);
                Worker taskWorker = connection.getStream().taskWorker;
                taskWorker.inspect();
            }

            buffer.clear();
            buffer.flip();

            import core.thread;
            // Thread.sleep(2.seconds);
            Thread.sleep(200.msecs);

            connection.write(ResponseContent);

            return DataHandleStatus.Done;
        }

        override void exceptionCaught(Connection connection, Throwable t) {
            warning(t);
        }

        override void failedOpeningConnection(int connectionId, Throwable t) {
            warning(t);
        }

        override void failedAcceptingConnection(int connectionId, Throwable t) {
            warning(t);
        }
    }).listen(Host, Port);

    // dmft on
}
