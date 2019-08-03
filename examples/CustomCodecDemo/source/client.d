module client;

import hunt.net;
import hunt.net.codec.textline;
import hunt.logging;
import hunt.String;

import std.format;

void main() {
    import std.stdio;

    int count = 0;

    NetClient client = NetUtil.createNetClient();

    client.setCodec(new class Codec {

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

    client.setHandler(new class ConnectionEventHandler {

        override void sessionOpened(Connection session) {
            infof("Connection created: %s", session.getRemoteAddress());

            // session.write("Hi, I'm client");
            session.encode(new String("Hi, I'm client\r"));
        }

        override void sessionClosed(Connection session) {
            infof("Connection closed: %s", session.getRemoteAddress());

            // client.close();
        }

        override void messageReceived(Connection session, Object message) {
            tracef("message type: %s", typeid(message).name);
            string str = format("data received: %s", message.toString());
            tracef(str);
            if(count< 10) {
                session.encode(new String(str));
            }
            count++;
        }

        override void exceptionCaught(Connection session, Exception t) {
            warning(t);
        }

        override void failedOpeningSession(int sessionId, Exception t) {
            warning(t);
            client.close(); 
        }

        override void failedAcceptingSession(int sessionId, Exception t) {
            warning(t);
        }
    }).connect("10.1.222.120", 8080);




}
