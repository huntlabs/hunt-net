module hunt.net.util.UrlEncoded;

import hunt.collection;

import hunt.text.Charset;
import hunt.Exceptions;
import hunt.text.Common;
import hunt.util.StringBuilder;
import hunt.util.ConverterUtils;

import hunt.logging;

import std.ascii;
import std.conv;
import std.array;


/* rfc1738:

   ...The characters ";",
   "/", "?", ":", "@", "=" and "&" are the characters which may be
   reserved for special meaning within a scheme...

   ...Thus, only alphanumerics, the special characters "$-_.+!*'(),", and
   reserved characters used for their reserved purposes may be used
   unencoded within a URL...

   For added safety, we only leave -_. unencoded.
 */
private string urlEncode(string s, bool raw) {

    Appender!string sb;
    sb.reserve(s.length * 3);

    foreach(char c; s) {
		if (!raw && c == ' ') {
			sb.put('+');
		} else if ((c < '0' && c != '-' && c != '.') ||
				(c < 'A' && c > '9') ||
				(c > 'Z' && c < 'a' && c != '_') ||
				(c > 'z' && (!raw || c != '~'))) {
			sb.put('%');
			sb.put(hexDigits[c >> 4]);
			sb.put(hexDigits[c & 15]);
		} else {
			sb.put(c);
		}
    }

    return sb.data;
}


private string urlDecode(string str) {
    Appender!string sb;
    sb.reserve(str.length);

    size_t len = str.length;
	immutable(char) *data = str.ptr;

	while (len--) {
		if (*data == '+') {
			sb.put(' ');
		}
		else if (*data == '%' && len >= 2 && isHexDigit(data[1])
				 && isHexDigit(data[2])) {
            sb.put(cast(char)to!int(data[1..3], 16));
			data += 2;
			len -= 2;
		} else {
            sb.put(*data);
		}
		data++;
	}

    return sb.data;
}


// unittest {
//     string s = `abcd 1234567890ABCD1234~!@#$%^&*()_+{}<>?:"[]\|';/.,`;

        // RFC1738
//     string r = urlEncode(s, false);
//     // abcd+1234567890ABCD1234%7E%21%40%23%24%25%5E%26%2A%28%29_%2B%7B%7D%3C%3E%3F%3A%22%5B%5D%5C%7C%27%3B%2F.%2C

//     r = urlDecode(r);
//     assert(r == s);

        // RFC-3986    
//     r = urlEncode(s, true);
//     // abcd%201234567890ABCD1234~%21%40%23%24%25%5E%26%2A%28%29_%2B%7B%7D%3C%3E%3F%3A%22%5B%5D%5C%7C%27%3B%2F.%2C
    
//     r = urlDecode(r);
//     writefln("Decode: %s", r);
//     assert(r == s);

//     r = urlEncode("中 文", true);
//     // %E4%B8%AD%20%E6%96%87
// }


enum UrlEncodeStyle {
    HtmlForm,
    URI
}

/**
 * Handles coding of MIME "x-www-form-urlencoded".
 * <p>
 * This class handles the encoding and decoding for either the query string of a
 * URL or the _content of a POST HTTP request.
 * </p>
 * <b>Notes</b>
 * <p>
 * The UTF-8 charset is assumed, unless otherwise defined by either passing a
 * parameter or setting the "org.hunt.utils.UrlEncoding.charset" System
 * property.
 * </p>
 * <p>
 * The hashtable either contains string single values, vectors of string or
 * arrays of Strings.
 * </p>
 * <p>
 * This class is only partially synchronised. In particular, simple get
 * operations are not protected from concurrent updates.
 * </p>
 * 
 * See_Also:
 *    https://www.w3.org/TR/REC-html40/interact/forms.html#h-17.13.4
 *    https://stackoverflow.com/questions/996139/urlencode-vs-rawurlencode
 */
class UrlEncoded  : MultiMap!string { 
    
    enum string ENCODING = StandardCharsets.UTF_8;

    private UrlEncodeStyle _encodeStyle = UrlEncodeStyle.URI;


    this(UrlEncodeStyle encodeStyle = UrlEncodeStyle.URI) {
        _encodeStyle = encodeStyle;
    }
    

    this(string query, UrlEncodeStyle encodeStyle = UrlEncodeStyle.URI) {
        _encodeStyle = encodeStyle;
        decode(query);
    }

    UrlEncodeStyle encodeStyle() {
        return _encodeStyle;
    }

    /**
     * Encode MultiMap with % encoding for UTF8 sequences.
     *
     * @return the MultiMap as a string with % encoding
     */
    string encode() {
        return encode(true);
    }

    /**
     * Encode MultiMap with % encoding.
     *
     * @param charset            the charset to encode with
     * @param equalsForNullValue if True, then an '=' is always used, even
     *                           for parameters without a value. e.g. <code>"blah?a=&amp;b=&amp;c="</code>.
     * @return the MultiMap as a string encoded with % encodings
     */
    string encode(bool equalsForNullValue) {

        StringBuilder result = new StringBuilder(128);

        bool delim = false;
        foreach(string key, List!string list; this)
        {
            int s = 0;
            if(list !is null)
                s = list.size();

            if (delim) {
                result.append('&');
            }

            if (s == 0) {
                result.append(encodeString(key, _encodeStyle));
                if (equalsForNullValue)
                    result.append('=');
            } else {
                for (int i = 0; i < s; i++) {
                    if (i > 0)
                        result.append('&');
                    string val = list.get(i);
                    result.append(encodeString(key, _encodeStyle));

                    if (val !is null) {
                        if (val.length > 0) {
                            result.append('=');
                            result.append(encodeString(val, _encodeStyle));
                        } else if (equalsForNullValue)
                            result.append('=');
                    } else if (equalsForNullValue)
                        result.append('=');
                }
            }
            delim = true;
        }
        return result.toString();        
    }


    /**
     * Decoded parameters to Map.
     *
     * @param content the string containing the encoded parameters
     * @param map     the MultiMap to put parsed query parameters into
     * @param charset the charset to use for decoding
     */
    void decode(string content, string charset = ENCODING) {

        string key = null;
        string value = null;
        int mark = -1;
        bool encoded = false;
        for (int i = 0; i < content.length; i++) {
            char c = content[i];
            switch (c) {
                case '&':
                    int l = i - mark - 1;
                    value = l == 0 ? "" :
                            (encoded ? decodeString(content, mark + 1, l) : content[mark + 1 .. i]);
                    mark = i;

                    encoded = false;
                    if (key !is null) {
                        version(HUNT_HTTP_DEBUG) tracef("key=%s, value=%s", key, value);
                        this.add(key, value);
                    } else if (value !is null && value.length > 0) {
                        this.add(value, "");
                    }
                    key = null;
                    value = null;
                    break;
                case '=':
                    if (key !is null)
                        break;
                    key = encoded ? decodeString(content, mark + 1, i - mark - 1) : content[mark + 1 .. i];
                    mark = i;
                    encoded = false;
                    break;
                case '+':
                    encoded = true;
                    break;
                case '%':
                    encoded = true;
                    break;
                default: break;
            }
        }

            int contentLen = cast(int)content.length;

            if (key !is null) {
                int l =  contentLen - mark - 1;
            value = l == 0 ? "" : (encoded ? decodeString(content, mark + 1, l) : content[mark + 1 .. $]);
                version(HUNT_HTTP_DEBUG) tracef("key=%s, value=%s", key, value);
                this.add(key, value);
            } else if (mark < contentLen) {
                version(HUNT_HTTP_DEBUG) tracef("empty value: content=%s, key=%s", content, key);
                key = encoded
                        ? decodeString(content, mark + 1, contentLen - mark - 1)
                    : content[mark + 1 .. $];
                if (!key.empty) {
                version(HUNT_HTTP_DEBUG) tracef("key=%s, value=", key);
                    this.add(key, "");
                }
            } else {
                warningf("No key found.");
            }
        }

    /**
     * Decode string with % encoding.
     * This method makes the assumption that the majority of calls
     * will need no decoding.
     *
     * @param encoded the encoded string to decode
     * @return the decoded string
     */
    static string decodeString(string encoded) {
        return urlDecode(encoded);
    }

    /**
     * Decode string with % encoding.
     * This method makes the assumption that the majority of calls
     * will need no decoding.
     *
     * @param encoded the encoded string to decode
     * @param offset  the offset in the encoded string to decode from
     * @param length  the length of characters in the encoded string to decode
     * @param charset the charset to use for decoding
     * @return the decoded string
     */
    static string decodeString(string encoded, size_t offset, size_t length) {
        return urlDecode(encoded[offset .. offset+length]);
    }


    /**
     * Perform URL encoding.
     *
     * @param string the string to encode
     * @return encoded string.
     */
    static string encodeString(string str, UrlEncodeStyle encodeStyle = UrlEncodeStyle.URI) {
        return urlEncode(str, encodeStyle == UrlEncodeStyle.URI);       
    }
}
