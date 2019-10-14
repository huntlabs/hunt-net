[![Build Status](https://travis-ci.org/huntlabs/hunt-net.svg?branch=master)](https://travis-ci.org/huntlabs/hunt-net)

# hunt-net
A net library for DLang, hunt library based. hunt-net have codec to encoding and decoding tcp streaming frames.

### Using codec to build a TcpServer
```D
import hunt.net;
import hunt.net.codec.textline;

import hunt.logging;

void main()
{
    NetServerOptions options = new NetServerOptions();
    NetServer server = NetUtil.createNetServer!(ThreadMode.Single)(options);

    server.setCodec(new TextLineCodec);
    server.setHandler(new class ConnectionEventHandler
    {
        override void messageReceived(Connection connection, Object message)
        {
            import std.format;

            string str = format("data received: %s", message.toString());
            connection.write(str);
        }
    }).listen("0.0.0.0", 9999);
}
```

### Using codec to build a TcpClient
```D
import hunt.net;
import hunt.net.codec.textline;

import hunt.logging;

void main()
{
    NetClient client = NetUtil.createNetClient();

    client.setCodec(new TextLineCodec);
    client.setHandler(new class ConnectionEventHandler
    {
        override void messageReceived(Connection connection, Object message)
        {
            import std.format;
            import hunt.String;

            string str = format("data received: %s", message.toString());
            
            connection.write(new String(str));
        }
    }).connect("localhost", 9999);
}
```

## TODO
- [ ] Improve support for SSL
- [ ] Improve APIs

