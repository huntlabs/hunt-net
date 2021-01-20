module server;

import hunt.net;
import hunt.logging.ConsoleLogger;

import hunt.net.codec.textline;

import std.format;
import core.atomic;

enum Host = "0.0.0.0";
enum Port = 8080;

enum string ResponseContent = "HTTP/1.1 200 OK\r\nContent-Length: 13\r\nConnection: Keep-Alive\r\nContent-Type: text/plain\r\nServer: Hunt/1.0\r\nDate: Wed, 17 Apr 2013 12:00:00 GMT\r\n\r\nHello, World!";


    // "versions": ["HUNT_DEBUG", "HUNT_IO_DEBUG", "HUNT_NET_DEBUG"],

void main() {

    NetServerOptions options = new NetServerOptions();
    options.workerThreadSize = 16;
    shared int counter;

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
            version(HUNT_IO_DEBUG) {
                tracef("message type: %s", typeid(message).name);
                string str = format("data received: %s", message.toString());
                tracef(str);
            }

            import hunt.io.ByteBuffer;
            ByteBuffer buffer = cast(ByteBuffer)message;
            // debug warning(cast(string)buffer.peekRemaining());
            buffer.clear();
            buffer.flip();

            // int c = atomicOp!("+=")(counter, 1);
            // warningf("received: %d", c);

            // import core.thread;
            // Thread.sleep(3.seconds);

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
