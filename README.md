# hunt-net
net module for hunt.


### Build BoringSSL

make build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make 
cd ..
mkdir -p .openssl/lib
cp build/crypto/libcrypto.a build/ssl/libssl.a .openssl/lib
	
    "versions": [
		"BoringSSL"
	]