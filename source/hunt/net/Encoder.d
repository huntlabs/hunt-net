module hunt.net.Encoder;

import hunt.net.Session;

interface Encoder {
	void encode(Object message, Session session);
}