module hunt.net.Decoder;

import hunt.collection.ByteBuffer;
import hunt.net.Session;

interface Decoder {
	void decode(ByteBuffer buf, Session session) ;
}
