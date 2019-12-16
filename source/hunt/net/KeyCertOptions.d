module hunt.net.KeyCertOptions;

/**
 * 
 */
interface KeyCertOptions {
    string getCaFile();

    KeyCertOptions setCaFile(string file);

    string getCertFile();

    string getCertPassword();

    string getKeyFile();

    string getKeyPassword();
    
    KeyCertOptions copy();
}