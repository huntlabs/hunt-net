module server;

import hunt.net;
import hunt.logging.ConsoleLogger;

import hunt.net.codec.textline;

import std.format;

enum Host = "0.0.0.0";
enum Port = 8080;

void main() {

    NetServerOptions options = new NetServerOptions();
    // options.workerThreadSize = 8;

    NetServer server = NetUtil.createNetServer(options);

    server.setCodec(new TextLineCodec);
    // dfmt off
    server.setHandler(new class NetConnectionHandler {

        override void connectionOpened(Connection connection) {
            infof("Connection created: %s", connection.getRemoteAddress());
        }

        override void connectionClosed(Connection connection) {
            infof("Connection closed: %s", connection.getRemoteAddress());
        }

        override void messageReceived(Connection connection, Object message) {
            tracef("message type: %s", typeid(message).name);
            string str = format("data received: %s", message.toString());
            tracef(str);
            connection.write(str);
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
