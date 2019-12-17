module hunt.net.PemKeyCertOptions;

import hunt.net.KeyCertOptions;

/**
 * 
 */
class PemKeyCertOptions : KeyCertOptions {
    private string _caCertFile;
    private string _caPassword;
    private string _certFile;
    private string _certPassword;
    private string _keyFile;
    private string _keyPassword;

    this() {
        
    }

    this(string certificate, string privateKey, string certPassword="", string keyPassword="") {
        _certFile = certificate;
        _certPassword = certPassword;
        _keyFile = privateKey;
        _keyPassword = keyPassword;
    }

    string getCaFile() {
        return _caCertFile;
    }

    PemKeyCertOptions setCaFile(string file) {
        _caCertFile = file;
        return this;
    }

    string getCaPassword() {
        return _caPassword;
    }

    PemKeyCertOptions setCaPassword(string password) {
        _caPassword = password;
        return this;
    }

    string getCertFile() {
        return _certFile;
    }

    string getCertPassword() {
        return _certPassword;
    }

    string getKeyFile() {
        return _keyFile;
    }

    string getKeyPassword() {
        return _keyPassword;
    }

    KeyCertOptions copy() {
        PemKeyCertOptions options = new PemKeyCertOptions(_certFile, _keyFile, _certPassword, _keyPassword);
        options._caCertFile = _caCertFile;
        options._caPassword = _caPassword;
        return options;
    }
}