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

        override void connectionOpened(Connection connection) {
            infof("Connection created: %s", connection.getRemoteAddress());

            // connection.write("Hi, I'm client");
            connection.encode(new String("Hi, I'm client\r"));
        }

        override void connectionClosed(Connection connection) {
            infof("Connection closed: %s", connection.getRemoteAddress());

            // client.close();
        }

        override void messageReceived(Connection connection, Object message) {
            tracef("message type: %s", typeid(message).name);
            string str = format("data received: %s", message.toString());
            tracef(str);
            if(count< 10) {
                connection.encode(new String(str));
            }
            count++;
        }

        override void exceptionCaught(Connection connection, Exception t) {
            warning(t);
        }

        override void failedOpeningConnection(int connectionId, Exception t) {
            warning(t);
            client.close(); 
        }

        override void failedAcceptingConnection(int connectionId, Exception t) {
            warning(t);
        }
    }).connect("10.1.222.120", 8080);




}
