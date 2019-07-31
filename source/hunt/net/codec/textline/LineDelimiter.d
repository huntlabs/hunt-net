/*
 *  Licensed to the Apache Software Foundation (ASF) under one
 *  or more contributor license agreements.  See the NOTICE file
 *  distributed with this work for additional information
 *  regarding copyright ownership.  The ASF licenses this file
 *  to you under the Apache License, Version 2.0 (the
 *  "License"); you may not use this file except in compliance
 *  with the License.  You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 *  Unless required by applicable law or agreed to in writing,
 *  software distributed under the License is distributed on an
 *  "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
 *  KIND, either express or implied.  See the License for the
 *  specific language governing permissions and limitations
 *  under the License.
 *
 */
module hunt.net.codec.textline.LineDelimiter;

import hunt.Exceptions;
import hunt.text.StringBuilder;


import std.array;
import std.ascii;
import std.format;
import std.string;
// import java.io.ByteArrayOutputStream;
// import java.io.PrintWriter;

/**
 * A delimiter which is appended to the end of a text line, such as
 * <tt>CR/LF</tt>. This class defines default delimiters for various
 * OS :
 * <ul>
 * <li><b>Unix/Linux</b> : LineDelimiter.UNIX ("\n")</li>
 * <li><b>Windows</b> : LineDelimiter.WINDOWS ("\r\n")</li>
 * <li><b>MAC</b> : LineDelimiter.MAC ("\r")</li>
 * </ul>
 *
 * @author <a href="http://mina.apache.org">Apache MINA Project</a>
 */
struct LineDelimiter {
    /** the line delimiter constant of the current O/S. */
    enum LineDelimiter DEFAULT = LineDelimiter(newline);

    /**
     * A special line delimiter which is used for auto-detection of
     * EOL in {@link TextLineDecoder}.  If this delimiter is used,
     * {@link TextLineDecoder} will consider both  <tt>'\r'</tt> and
     * <tt>'\n'</tt> as a delimiter.
     */
    enum LineDelimiter AUTO = LineDelimiter("");

    /**
     * The CRLF line delimiter constant (<tt>"\r\n"</tt>)
     */
    enum LineDelimiter CRLF = LineDelimiter("\r\n");

    /**
     * The line delimiter constant of UNIX (<tt>"\n"</tt>)
     */
    enum LineDelimiter UNIX = LineDelimiter("\n");

    /**
     * The line delimiter constant of MS Windows/DOS (<tt>"\r\n"</tt>)
     */
    enum LineDelimiter WINDOWS = CRLF;

    /**
     * The line delimiter constant of Mac OS (<tt>"\r"</tt>)
     */
    enum LineDelimiter MAC = LineDelimiter("\r");

    /**
     * The line delimiter constant for NUL-terminated text protocols
     * such as Flash XML socket (<tt>"\0"</tt>)
     */
    enum LineDelimiter NUL = LineDelimiter("\0");

    /** Stores the selected Line delimiter */
    private string value;

    /**
     * Creates a new line delimiter with the specified <tt>value</tt>.
     * 
     * @param value The new Line Delimiter
     */
    this(string value) {
        if(!__ctfe) {
            if (value.empty) {
                throw new IllegalArgumentException("delimiter");
            }
        }

        this.value = value;
    }

    /**
     * @return the delimiter string.
     */
    string getValue() {
        return value;
    }

    /**
     * {@inheritDoc}
     */
    size_t toHash() @trusted nothrow {
        return hashOf(value);
    }

    /**
     * {@inheritDoc}
     */
    bool opEquals(ref LineDelimiter o) {
        return this.value == o.value;
    }

    /**
     * {@inheritDoc}
     */
    string toString() {
        if (value.length == 0) {
            return "delimiter: auto";
        } else {
            StringBuilder buf = new StringBuilder();
            buf.append("delimiter:");

            for (int i = 0; i < value.length; i++) {
                buf.append(" 0x");
                buf.append(format("%02X", value[i]));
            }

            return buf.toString();
        }
    }
}
