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

        override void sessionOpened(Connection session) {
            infof("Connection created: %s", session.getRemoteAddress());
        }

        override void sessionClosed(Connection session) {
            infof("Connection closed: %s", session.getRemoteAddress());
        }

        override void messageReceived(Connection session, Object message) {
            tracef("message type: %s", typeid(message).name);
            string str = format("data received: %s", message.toString());
            tracef(str);
            session.write(str);
        }

        override void exceptionCaught(Connection session, Exception t) {
            warning(t);
        }

        override void failedOpeningSession(int sessionId, Exception t) {
            warning(t);
        }

        override void failedAcceptingSession(int sessionId, Exception t) {
            warning(t);
        }
    }).listen("0.0.0.0", 8080);
}
