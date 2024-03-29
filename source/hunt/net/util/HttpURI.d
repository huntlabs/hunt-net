module hunt.net.util.HttpURI;

import hunt.collection.MultiMap;

import hunt.Exceptions;
import hunt.text.Charset;
import hunt.text.Common;
import hunt.util.StringBuilder;
import hunt.util.ConverterUtils;
import hunt.net.util.UrlEncoded;

import std.array;
import std.conv;
import std.string;

import hunt.logging;


/**
 * Http URI. Parse a HTTP URI from a string or byte array. Given a URI
 * <code>http://user@host:port/path/info;param?query#fragment</code> this class
 * will split it into the following undecoded optional elements:
 * <ul>
 * <li>{@link #getScheme()} - http:</li>
 * <li>{@link #getAuthority()} - //name@host:port</li>
 * <li>{@link #getHost()} - host</li>
 * <li>{@link #getPort()} - port</li>
 * <li>{@link #getPath()} - /path/info</li>
 * <li>{@link #getParam()} - param</li>
 * <li>{@link #getQuery()} - query</li>
 * <li>{@link #getFragment()} - fragment</li>
 * </ul>
 * 
	https://bob:bobby@www.lunatech.com:8080/file;p=1?q=2#third
	\___/   \_/ \___/ \______________/ \__/\_______/ \_/ \___/
	|      |    |          |          |      | \_/  |    |
	Scheme User Password    Host       Port  Path |   | Fragment
			\_____________________________/       | Query
						|               Path parameter
					Authority 
 * <p>
 * Any parameters will be returned from {@link #getPath()}, but are excluded
 * from the return value of {@link #getDecodedPath()}. If there are multiple
 * parameters, the {@link #getParam()} method returns only the last one.
 * 
 * See_Also:
 *	 https://stackoverflow.com/questions/1634271/url-encoding-the-space-character-or-20
 */
class HttpURI {
	private enum State {
		START, HOST_OR_PATH, SCHEME_OR_PATH, HOST, IPV6, PORT, PATH, PARAM, QUERY, FRAGMENT, ASTERISK
	}

	private string _scheme;
	private string _userInfo;
	private string _user;
	private string _password;
	private string _host;
	private int _port;
	private string _path;
	private string _param;
	private string _query;
	private string _fragment;
	private MultiMap!string _parameters;

	string _uri;
	string _decodedPath;

	/**
	 * Construct a normalized URI. Port is not set if it is the default port.
	 * 
	 * @param scheme
	 *            the URI scheme
	 * @param host
	 *            the URI hose
	 * @param port
	 *            the URI port
	 * @param path
	 *            the URI path
	 * @param param
	 *            the URI param
	 * @param query
	 *            the URI query
	 * @param fragment
	 *            the URI fragment
	 * @return the normalized URI
	 */
	static HttpURI createHttpURI(string scheme, string host, int port, string path, string param, string query,
			string fragment) {
		if (port == 80 && (scheme == "http"))
			port = 0;
		if (port == 443 && (scheme == "https"))
			port = 0;
		return new HttpURI(scheme, host, port, path, param, query, fragment);
	}

	this() {
	}

	this(string scheme, string host, int port, string path, string param, string query, string fragment) {
		_scheme = scheme;
		_host = host;
		_port = port;
		_path = path;
		_param = param;
		_query = query;
		_fragment = fragment;
	}

	this(HttpURI uri) {
		this(uri._scheme, uri._host, uri._port, uri._path, uri._param, uri._query, uri._fragment);
		_uri = uri._uri;
	}

	this(string uri) {
		_port = -1;
		parse(State.START, uri);
	}

	this(string scheme, string host, int port, string pathQuery) {
		_uri = null;

		_scheme = scheme;
		_host = host;
		_port = port;

		parse(State.PATH, pathQuery);

	}

	void parse(string uri) {
		clear();
		_uri = uri;
		parse(State.START, uri);
	}

	/**
	 * Parse according to https://tools.ietf.org/html/rfc7230#section-5.3
	 * 
	 * @param method
	 *            the request method
	 * @param uri
	 *            the request uri
	 */
	void parseRequestTarget(string method, string uri) {
		clear();
		_uri = uri;

		if (method == "CONNECT")
			_path = uri;
		else
			parse(uri.startsWith("/") ? State.PATH : State.START, uri);
	}

	void parse(string uri, int offset, int length) {
		clear();
		int end = offset + length;
		_uri = uri[offset .. end];
		parse(State.START, uri);
	}

	private void parse(State state, string uri) {
		bool encoded = false;
		int end = cast(int)uri.length;
		int mark = 0;
		int path_mark = 0;
		char last = '/';
		for (int i = 0; i < end; i++) {
			char c = uri[i];

			final switch (state) {
			case State.START: {
				switch (c) {
				case '/':
					mark = i;
					state = State.HOST_OR_PATH;
					break;
				case ';':
					mark = i + 1;
					state = State.PARAM;
					break;
				case '?':
					// assume empty path (if seen at start)
					_path = "";
					mark = i + 1;
					state = State.QUERY;
					break;
				case '#':
					mark = i + 1;
					state = State.FRAGMENT;
					break;
				case '*':
					_path = "*";
					state = State.ASTERISK;
					break;

				case '.':
					path_mark = i;
					state = State.PATH;
					encoded = true;
					break;

				default:
					mark = i;
					if (_scheme is null)
						state = State.SCHEME_OR_PATH;
					else {
						path_mark = i;
						state = State.PATH;
					}
					break;
				}

				continue;
			}

			case State.SCHEME_OR_PATH: {
				switch (c) {
				case ':':
					// must have been a scheme
					_scheme = uri[mark .. i];
					// Start again with scheme set
					state = State.START;
					break;

				case '/':
					// must have been in a path and still are
					state = State.PATH;
					break;

				case ';':
					// must have been in a path
					mark = i + 1;
					state = State.PARAM;
					break;

				case '?':
					// must have been in a path
					_path = uri[mark .. i];
					mark = i + 1;
					state = State.QUERY;
					break;

				case '%':
					// must have be in an encoded path
					encoded = true;
					state = State.PATH;
					break;

				case '#':
					// must have been in a path
					_path = uri[mark .. i];
					state = State.FRAGMENT;
					break;

				default:
					break;
				}
				continue;
			}

			case State.HOST_OR_PATH: {
				switch (c) {
				case '/':
					_host = "";
					mark = i + 1;
					state = State.HOST;
					break;

				case '@':
				case ';':
				case '?':
				case '#':
					// was a path, look again
					i--;
					path_mark = mark;
					state = State.PATH;
					break;

				case '.':
					// it is a path
					encoded = true;
					path_mark = mark;
					state = State.PATH;
					break;

				default:
					// it is a path
					path_mark = mark;
					state = State.PATH;
				}
				continue;
			}

			case State.HOST: {
				switch (c) {
				case '/':
					_host = uri[mark .. i];
					path_mark = mark = i;
					state = State.PATH;
					break;
				case ':':
					if (i > mark)
						_host = uri[mark .. i];
					mark = i + 1;
					state = State.PORT;
					break;
				case '@':
					if (!_userInfo.empty())
						throw new IllegalArgumentException("Bad authority");
					_userInfo = uri[mark .. i];
					string[] parts = _userInfo.split(":");
					if(parts.length>0)
						_user = parts[0];
					if(parts.length>1)
						_password = parts[1];
					mark = i + 1;
					break;

				case '[':
					state = State.IPV6;
					break;
					
				default:
					break;
				}
				break;
			}

			case State.IPV6: {
				switch (c) {
				case '/':
					throw new IllegalArgumentException("No closing ']' for ipv6 in " ~ uri);
				case ']':
					c = uri.charAt(++i);
					_host = uri[mark .. i];
					if (c == ':') {
						mark = i + 1;
						state = State.PORT;
					} else {
						path_mark = mark = i;
						state = State.PATH;
					}
					break;
					
				default:
					break;
				}

				break;
			}

			case State.PORT: {
				if (c == '@') {
					if (_userInfo !is null)
						throw new IllegalArgumentException("Bad authority");
					// It wasn't a port, but a password!
					_userInfo = _host ~ ":" ~ uri[mark .. i];
					string[] parts = _userInfo.split(":");
					if(parts.length>0)
						_user = parts[0];
					if(parts.length>1)
						_password = parts[1];

					mark = i + 1;
					state = State.HOST;
				} else if (c == '/') {
					// _port = ConverterUtils.parseInt(uri, mark, i - mark, 10);
					_port = to!int(uri[mark .. i], 10);
					path_mark = mark = i;
					state = State.PATH;
				}
				break;
			}

			case State.PATH: {
				switch (c) {
				case ';':
					mark = i + 1;
					state = State.PARAM;
					break;
				case '?':
					_path = uri[path_mark .. i];
					mark = i + 1;
					state = State.QUERY;
					break;
				case '#':
					_path = uri[path_mark .. i];
					mark = i + 1;
					state = State.FRAGMENT;
					break;
				case '%':
					encoded = true;
					break;
				case '.':
					if ('/' == last)
						encoded = true;
					break;
					
				default:
					break;
				}
				break;
			}

			case State.PARAM: {
				switch (c) {
				case '?':
					_path = uri[path_mark .. i];
					_param = uri[mark .. i];
					mark = i + 1;
					state = State.QUERY;
					break;
				case '#':
					_path = uri[path_mark .. i];
					_param = uri[mark .. i];
					mark = i + 1;
					state = State.FRAGMENT;
					break;
				case '/':
					encoded = true;
					// ignore internal params
					state = State.PATH;
					break;
				case ';':
					// multiple parameters
					mark = i + 1;
					break;
					
				default:
					break;
				}
				break;
			}

			case State.QUERY: {
				if (c == '#') {
					_query = uri[mark .. i];
					mark = i + 1;
					state = State.FRAGMENT;
				}
				break;
			}

			case State.ASTERISK: {
				throw new IllegalArgumentException("Bad character '*'");
			}

			case State.FRAGMENT: {
				_fragment = uri[mark .. end];
				i = end;
				break;
			}
			}
			last = c;
		}

		final switch (state) {
		case State.START:
			break;
		case State.SCHEME_OR_PATH:
			_path = uri[mark .. end];
			break;

		case State.HOST_OR_PATH:
			_path = uri[mark .. end];
			break;

		case State.HOST:
			if (end > mark)
				_host = uri[mark .. end];
			break;

		case State.IPV6:
			throw new IllegalArgumentException("No closing ']' for ipv6 in " ~ uri);

		case State.PORT:
			// _port = ConverterUtils.parseInt(uri, mark, end - mark, 10);
			_port = to!int(uri[mark .. end], 10);
			break;

		case State.ASTERISK:
			break;

		case State.FRAGMENT:
			_fragment = uri[mark .. end];
			break;

		case State.PARAM:
			_path = uri[path_mark .. end];
			_param = uri[mark .. end];
			break;

		case State.PATH:
			_path = uri[path_mark .. end];
			break;

		case State.QUERY:
			_query = uri[mark .. end];
			break;
		}

		if (!encoded) {
			if (_param is null)
				_decodedPath = _path;
			else
				_decodedPath = _path[0 .. _path.length - _param.length - 1];
		}
	}

	string getScheme() {
		return _scheme;
	}

	string getHost() {
		// Return null for empty host to retain compatibility with java.net.URI
		if (_host !is null && _host.length == 0)
			return null;
		return _host;
	}

	int getPort() {
		return _port;
	}

	/**
	 * The parsed Path.
	 * 
	 * @return the path as parsed on valid URI. null for invalid URI.
	 */
	string getPath() {
		return _path;
	}

	string getDecodedPath() {
		if (_decodedPath.empty && !_path.empty)
			_decodedPath = URIUtils.canonicalPath(URIUtils.decodePath(_path));
		return _decodedPath;
	}

	string getParam() {
		return _param;
	}

	string getQuery() {
		return _query;
	}

	bool hasQuery() {
		return _query !is null && _query.length > 0;
	}

	string getFragment() {
		return _fragment;
	}

	// void decodeQueryTo(MultiMap!string parameters, string encoding = StandardCharsets.UTF_8) {
	// 	if (_query == _fragment)
	// 		return;

	// 	decodeTo(_query, parameters, encoding);
	// }

	MultiMap!string decodeQuery() {
		
		if(_parameters is null) {
			UrlEncoded urlEncoded = new UrlEncoded();
			if (_query != _fragment) {
				urlEncoded.decode(_query);
			}
			_parameters = urlEncoded;
		}

		return _parameters;
	}

	void clear() {
		_uri = null;

		_scheme = null;
		_host = null;
		_port = -1;
		_path = null;
		_param = null;
		_query = null;
		_fragment = null;

		_decodedPath = null;
	}

	bool isAbsolute() {
		return _scheme !is null && _scheme.length > 0;
	}

	override
	string toString() {
		if (_uri is null) {
			StringBuilder ot = new StringBuilder();

			if (_scheme !is null)
				ot.append(_scheme).append(':');

			if (_host !is null) {
				ot.append("//");
				if (_userInfo !is null)
					ot.append(_userInfo).append('@');
				ot.append(_host);
			}

			if (_port > 0)
				ot.append(':').append(_port);

			if (_path !is null)
				ot.append(_path);

			if (_query !is null)
				ot.append('?').append(_query);

			if (_fragment !is null)
				ot.append('#').append(_fragment);

			if (ot.length > 0)
				_uri = ot.toString();
			else
				_uri = "";
		}
		return _uri;
	}

	bool equals(Object o) {
		if (o is this)
			return true;
		if (!(typeid(o) == typeid(HttpURI)))
			return false;
		return toString().equals(o.toString());
	}

	void setScheme(string scheme) {
		_scheme = scheme;
		_uri = null;
	}

	/**
	 * @param host
	 *            the host
	 * @param port
	 *            the port
	 */
	void setAuthority(string host, int port) {
		_host = host;
		_port = port;
		_uri = null;
	}

	/**
	 * @param path
	 *            the path
	 */
	void setPath(string path) {
		_uri = null;
		_path = path;
		_decodedPath = null;
	}

	/**
	 * @param path
	 *            the decoded path
	 */
	// void setDecodedPath(string path) {
	// 	_uri = null;
	// 	_path = URIUtils.encodePath(path);
	// 	_decodedPath = path;
	// }

	void setPathQuery(string path) {
		_uri = null;
		_path = null;
		_decodedPath = null;
		_param = null;
		_fragment = null;
		if (!path.empty)
			parse(State.PATH, path);
	}

	void setQuery(string query) {
		_query = query;
		_uri = null;
	}

	// URI toURI() {
	// 	return new URI(_scheme, null, _host, _port, _path, _query is null ? null : UrlEncoded.decodestring(_query),
	// 			_fragment);
	// }

	string getPathQuery() {
		if (_query is null)
			return _path;
		return _path ~ "?" ~ _query;
	}

	bool hasAuthority() {
		return _host !is null;
	}

	string getAuthority() {
		if (_port > 0)
			return _host ~ ":" ~ to!string(_port);
		return _host;
	}

	string getUserInfo() {
		return _userInfo;
	}

	string getUser() {
		return _user;
	}

	string getPassword() {
		return _password;
	}

}


/**
 * Parse an authority string into Host and Port
 * <p>Parse a string in the form "host:port", handling IPv4 an IPv6 hosts</p>
 *
 */
class URIUtils
{
	/* ------------------------------------------------------------ */
    /* Decode a URI path and strip parameters
     */
    static string decodePath(string path) {
        return decodePath(path, 0, cast(int)path.length);
    }

    /* ------------------------------------------------------------ */
    /* Decode a URI path and strip parameters of UTF-8 path
     */
    static string decodePath(string path, int offset, int length) {
        try {
            StringBuilder builder = null;

            int end = offset + length;
            for (int i = offset; i < end; i++) {
                char c = path[i];
                switch (c) {
                    case '%':
                        if (builder is null) {
                            builder = new StringBuilder(path.length);
                            builder.append(path, offset, i - offset);
                        }
                        if ((i + 2) < end) {
                            char u = path.charAt(i + 1);
                            if (u == 'u') {
                                // TODO this is wrong. This is a codepoint not a char
                                builder.append(cast(char) (0xffff & ConverterUtils.parseInt(path, i + 2, 4, 16)));
                                i += 5;
                            } else {
                                builder.append(cast(byte) (0xff & (ConverterUtils.convertHexDigit(u) * 16 + 
									ConverterUtils.convertHexDigit(path.charAt(i + 2)))));
                                i += 2;
                            }
                        } else {
                            throw new IllegalArgumentException("Bad URI % encoding");
                        }

                        break;

                    case ';':
                        if (builder is null) {
                            builder = new StringBuilder(path.length);
                            builder.append(path, offset, i - offset);
                        }

                        while (++i < end) {
                            if (path[i] == '/') {
                                builder.append('/');
                                break;
                            }
                        }

                        break;

                    default:
                        if (builder !is null)
                            builder.append(c);
                        break;
                }
            }

            if (builder !is null)
                return builder.toString();
            if (offset == 0 && length == path.length)
                return path;
            return path[offset .. end];
        } catch (Exception e) {
            // System.err.println(path.substring(offset, offset + length) ~ " " ~ e);
			error(e.toString);
            return decodeISO88591Path(path, offset, length);
        }
    }


    /* ------------------------------------------------------------ */
    /* Decode a URI path and strip parameters of ISO-8859-1 path
     */
    private static string decodeISO88591Path(string path, int offset, int length) {
        StringBuilder builder = null;
        int end = offset + length;
        for (int i = offset; i < end; i++) {
            char c = path[i];
            switch (c) {
                case '%':
                    if (builder is null) {
                        builder = new StringBuilder(path.length);
                        builder.append(path, offset, i - offset);
                    }
                    if ((i + 2) < end) {
                        char u = path.charAt(i + 1);
                        if (u == 'u') {
                            // TODO this is wrong. This is a codepoint not a char
                            builder.append(cast(char) (0xffff & ConverterUtils.parseInt(path, i + 2, 4, 16)));
                            i += 5;
                        } else {
                            builder.append(cast(byte) (0xff & (ConverterUtils.convertHexDigit(u) * 16 + ConverterUtils.convertHexDigit(path.charAt(i + 2)))));
                            i += 2;
                        }
                    } else {
                        throw new IllegalArgumentException("");
                    }

                    break;

                case ';':
                    if (builder is null) {
                        builder = new StringBuilder(path.length);
                        builder.append(path, offset, i - offset);
                    }
                    while (++i < end) {
                        if (path[i] == '/') {
                            builder.append('/');
                            break;
                        }
                    }
                    break;


                default:
                    if (builder !is null)
                        builder.append(c);
                    break;
            }
        }

        if (builder !is null)
            return builder.toString();
        if (offset == 0 && length == path.length)
            return path;
        return path[offset .. end];
    }

	/* ------------------------------------------------------------ */

    /**
     * Convert a decoded path to a canonical form.
     * <p>
     * All instances of "." and ".." are factored out.
     * </p>
     * <p>
     * Null is returned if the path tries to .. above its root.
     * </p>
     *
     * @param path the path to convert, decoded, with path separators '/' and no queries.
     * @return the canonical path, or null if path traversal above root.
     */
    static string canonicalPath(string path) {
        if (path.empty)
            return path;

        bool slash = true;
        int end = cast(int)path.length;
        int i = 0;

        loop:
        while (i < end) {
            char c = path[i];
            switch (c) {
                case '/':
                    slash = true;
                    break;

                case '.':
                    if (slash)
                        break loop;
                    slash = false;
                    break;

                default:
                    slash = false;
            }

            i++;
        }

        if (i == end)
            return path;

        StringBuilder canonical = new StringBuilder(path.length);
        canonical.append(path, 0, i);

        int dots = 1;
        i++;
        while (i <= end) {
            char c = i < end ? path[i] : '\0';
            switch (c) {
                case '\0':
                case '/':
                    switch (dots) {
                        case 0:
                            if (c != '\0')
                                canonical.append(c);
                            break;

                        case 1:
                            break;

                        case 2:
                            if (canonical.length < 2)
                                return null;
                            canonical.setLength(canonical.length - 1);
                            canonical.setLength(canonical.lastIndexOf("/") + 1);
                            break;

                        default:
                            while (dots-- > 0)
                                canonical.append('.');
                            if (c != '\0')
                                canonical.append(c);
                    }

                    slash = true;
                    dots = 0;
                    break;

                case '.':
                    if (dots > 0)
                        dots++;
                    else if (slash)
                        dots = 1;
                    else
                        canonical.append('.');
                    slash = false;
                    break;

                default:
                    while (dots-- > 0)
                        canonical.append('.');
                    canonical.append(c);
                    dots = 0;
                    slash = false;
            }

            i++;
        }
        return canonical.toString();
    }


    /* ------------------------------------------------------------ */

    /**
     * Convert a path to a cananonical form.
     * <p>
     * All instances of "." and ".." are factored out.
     * </p>
     * <p>
     * Null is returned if the path tries to .. above its root.
     * </p>
     *
     * @param path the path to convert (expects URI/URL form, encoded, and with path separators '/')
     * @return the canonical path, or null if path traversal above root.
     */
    static string canonicalEncodedPath(string path) {
        if (path.empty)
            return path;

        bool slash = true;
        int end = cast(int)path.length;
        int i = 0;

        loop:
        while (i < end) {
            char c = path[i];
            switch (c) {
                case '/':
                    slash = true;
                    break;

                case '.':
                    if (slash)
                        break loop;
                    slash = false;
                    break;

                case '?':
                    return path;

                default:
                    slash = false;
            }

            i++;
        }

        if (i == end)
            return path;

        StringBuilder canonical = new StringBuilder(path.length);
        canonical.append(path, 0, i);

        int dots = 1;
        i++;
        while (i <= end) {
            char c = i < end ? path[i] : '\0';
            switch (c) {
                case '\0':
                case '/':
                case '?':
                    switch (dots) {
                        case 0:
                            if (c != '\0')
                                canonical.append(c);
                            break;

                        case 1:
                            if (c == '?')
                                canonical.append(c);
                            break;

                        case 2:
                            if (canonical.length < 2)
                                return null;
                            canonical.setLength(canonical.length - 1);
                            canonical.setLength(canonical.lastIndexOf("/") + 1);
                            if (c == '?')
                                canonical.append(c);
                            break;
                        default:
                            while (dots-- > 0)
                                canonical.append('.');
                            if (c != '\0')
                                canonical.append(c);
                    }

                    slash = true;
                    dots = 0;
                    break;

                case '.':
                    if (dots > 0)
                        dots++;
                    else if (slash)
                        dots = 1;
                    else
                        canonical.append('.');
                    slash = false;
                    break;

                default:
                    while (dots-- > 0)
                        canonical.append('.');
                    canonical.append(c);
                    dots = 0;
                    slash = false;
            }

            i++;
        }
        return canonical.toString();
    }



    /* ------------------------------------------------------------ */

    /**
     * Convert a path to a compact form.
     * All instances of "//" and "///" etc. are factored out to single "/"
     *
     * @param path the path to compact
     * @return the compacted path
     */
    static string compactPath(string path) {
        if (path is null || path.length == 0)
            return path;

        int state = 0;
        int end = cast(int)path.length;
        int i = 0;

        loop:
        while (i < end) {
            char c = path[i];
            switch (c) {
                case '?':
                    return path;
                case '/':
                    state++;
                    if (state == 2)
                        break loop;
                    break;
                default:
                    state = 0;
            }
            i++;
        }

        if (state < 2)
            return path;

        StringBuilder buf = new StringBuilder(path.length);
        buf.append(path, 0, i);

        loop2:
        while (i < end) {
            char c = path[i];
            switch (c) {
                case '?':
                    buf.append(path, i, end);
                    break loop2;
                case '/':
                    if (state++ == 0)
                        buf.append(c);
                    break;
                default:
                    state = 0;
                    buf.append(c);
            }
            i++;
        }

        return buf.toString();
    }

    /* ------------------------------------------------------------ */

    /**
     * @param uri URI
     * @return True if the uri has a scheme
     */
    static bool hasScheme(string uri) {
        for (int i = 0; i < uri.length; i++) {
            char c = uri[i];
            if (c == ':')
                return true;
            if (!(c >= 'a' && c <= 'z' ||
                    c >= 'A' && c <= 'Z' ||
                    (i > 0 && (c >= '0' && c <= '9' ||
                            c == '.' ||
                            c == '+' ||
                            c == '-'))
            ))
                break;
        }
        return false;
    }
}




/**
 * A mapping from schemes to their default ports.
 *
 * This is not exhaustive. Not all schemes use ports. Not all schemes uniquely identify a port to
 * use even if they use ports. Entries here should be treated as best guesses.
 */
enum ushort[string] SchemePortMap = [
    "aaa": 3868,
    "aaas": 5658,
    "acap": 674,
    "amqp": 5672,
    "cap": 1026,
    "coap": 5683,
    "coaps": 5684,
    "dav": 443,
    "dict": 2628,
    "ftp": 21,
    "git": 9418,
    "go": 1096,
    "gopher": 70,
    "http": 80,
    "https": 443,
    "ws": 80,
    "wss": 443,
    "iac": 4569,
    "icap": 1344,
    "imap": 143,
    "ipp": 631,
    "ipps": 631,  // yes, they're both mapped to port 631
    "irc": 6667,  // De facto default port, not the IANA reserved port.
    "ircs": 6697,
    "iris": 702,  // defaults to iris.beep
    "iris.beep": 702,
    "iris.lwz": 715,
    "iris.xpc": 713,
    "iris.xpcs": 714,
    "jabber": 5222,  // client-to-server
    "ldap": 389,
    "ldaps": 636,
    "msrp": 2855,
    "msrps": 2855,
    "mtqp": 1038,
    "mupdate": 3905,
    "news": 119,
    "nfs": 2049,
    "pop": 110,
    "redis": 6379,
    "reload": 6084,
    "rsync": 873,
    "rtmfp": 1935,
    "rtsp": 554,
    "shttp": 80,
    "sieve": 4190,
    "sip": 5060,
    "sips": 5061,
    "smb": 445,
    "smtp": 25,
    "snews": 563,
    "snmp": 161,
    "soap.beep": 605,
    "ssh": 22,
    "stun": 3478,
    "stuns": 5349,
    "svn": 3690,
    "teamspeak": 9987,
    "telnet": 23,
    "tftp": 69,
    "tip": 3372,
    "mysql": 3306,
    "postgresql": 5432,
];