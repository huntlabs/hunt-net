module hunt.net.KeyCertOptions;

/**
 * 
 */
interface KeyCertOptions {
    string getCaFile();

    KeyCertOptions setCaFile(string file);

    string getCaPassword();

    KeyCertOptions setCaPassword(string password);

    string getCertFile();

    string getCertPassword();

    string getKeyFile();

    string getKeyPassword();
    
    KeyCertOptions copy();
}