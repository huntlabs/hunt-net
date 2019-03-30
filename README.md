[![Build Status](https://travis-ci.org/huntlabs/hunt-net.svg?branch=master)](https://travis-ci.org/huntlabs/hunt-net)

# hunt-net
A net library for dlang, hunt library based.

# Additional package dependencies
| package | version | purpose |
|--------|--------|--------|
| boringssl |  0.0.1  |   BoringSSL bindings     |
| openssl | 1.1.6+1.0.1g |  OpenSSL bindings   |
| hunt-security |  0.2.0    |  Some core APIs for security  |

**Note:**
To support SSL, you must add these packages to your project:
1. hunt-security
1. boringssl or openssl

## TODO
- [x] Support OpenSSL 1.1.x
- [ ] Improve support for SSL
- [ ] Improve APIs
