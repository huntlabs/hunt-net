module hunt.net.codec.Encoder;

import hunt.net.Connection;
import hunt.Exceptions;

interface Encoder {
	void encode(Object message, Session session);
}

/**
*/
class EncoderChain : Encoder {

	protected EncoderChain next;

	this() {
	}

	this(EncoderChain next) {
		this.next = next;
	}

	EncoderChain getNext() {
		return next;
	}

	void setNext(EncoderChain next) {
		this.next = next;
	}

	void encode(Object message, Session session) {
        implementationMissing();
	}
}
