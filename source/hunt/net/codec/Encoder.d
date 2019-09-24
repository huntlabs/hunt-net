module hunt.net.codec.Encoder;

import hunt.net.Connection;
import hunt.Exceptions;

interface Encoder {
	void encode(Object message, Connection connection);
	void setBufferSize(int size);
}

/**
*/
class EncoderChain : Encoder {

	protected EncoderChain next;
    protected int _bufferSize = 256;

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

    void setBufferSize(int size) {
		assert(size>0 || size == -1, "The size must be > 0.");
        this._bufferSize = size;
    }

	void encode(Object message, Connection connection) {
        implementationMissing();
	}
}
