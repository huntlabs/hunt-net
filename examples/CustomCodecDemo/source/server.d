module server;

import hunt.net;
import hunt.logging.ConsoleLogger;

import hunt.net.codec.textline;

import std.format;

enum Host = "0.0.0.0";
enum Port = 8080;

enum string ResponseContent = `HTTP/1.1 200 OK
Server: Example
Content-Length: 13
Date: Wed, 02 May 2018 14:31:50 
Content-Type: text/plain

Hello, World!
`;


void main() {

    NetServerOptions options = new NetServerOptions();
    options.workerThreadSize = 3;

    NetServer server = NetUtil.createNetServer(options);

    server.setCodec(new TextLineCodec);

    // dfmt off
    server.setHandler(new class NetConnectionHandler {

        override void connectionOpened(Connection connection) {
            debug infof("Connection created: %s", connection.getRemoteAddress());
        }

        override void connectionClosed(Connection connection) {
            debug infof("Connection closed: %s", connection.getRemoteAddress());
        }

        override DataHandleStatus messageReceived(Connection connection, Object message) {

            tracef("message type: %s", typeid(message).name);
            string str = format("data received: %s", message.toString());
            tracef(str);

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
