module hunt.net.EncoderChain;

import hunt.net.Encoder;

abstract class EncoderChain : Encoder {
	
	protected EncoderChain next;
	
	this() { }

	this(EncoderChain next) {
		this.next = next;
	}

	EncoderChain getNext() {
		return next;
	}

	void setNext(EncoderChain next) {
		this.next = next;
	}
}
