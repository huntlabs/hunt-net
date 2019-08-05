module server;

import hunt.net;
import hunt.logging;

import hunt.net.codec.textline;

import std.format;

void main() {

    NetServerOptions options = new NetServerOptions();
    NetServer server = NetUtil.createNetServer!(ThreadMode.Single)(options);

    server.setCodec(new class Codec {

        private TextLineEncoder encoder;
        private TextLineDecoder decoder;

        this() {
            encoder = new TextLineEncoder();
            decoder = new TextLineDecoder();
        }

        Encoder getEncoder() {
            return encoder;
        }

        Decoder getDecoder() {
            return decoder;
        }
    });

    server.setHandler(new class ConnectionEventHandler {

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

        override void exceptionCaught(Connection connection, Exception t) {
            warning(t);
        }

        override void failedOpeningConnection(int connectionId, Exception t) {
            warning(t);
        }

        override void failedAcceptingConnection(int connectionId, Exception t) {
            warning(t);
        }
    }).listen("0.0.0.0", 8080);
}
