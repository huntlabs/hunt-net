module hunt.net.Decoder;

import hunt.container.ByteBuffer;
import hunt.net.Session;

interface Decoder {
	void decode(ByteBuffer buf, Session session) ;
}
