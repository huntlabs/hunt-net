module hunt.net.OutputEntry;

import hunt.net.OutputEntryType;
import hunt.util.functional;

interface OutputEntry(T) {

    OutputEntryType getOutputEntryType();

    Callback getCallback();

    T getData();

    long remaining();
}
