module test.URLEncodedTest;

import hunt.net.util.UrlEncoded;

import hunt.Assert;
import hunt.Exceptions;

import hunt.logging;

import std.uri;
import std.stdio;
import std.string;

class URLEncodedTest {

    void testEncoder() {
        // https://dotblogs.com.tw/apprenticeworkshop/2018/12/09/About-URL-Encoding

        string str = "Hello +%-_.!~*'()@";

        // str = `abcd 1234567890ABCD1234~!@#$%^&*()_+{}<>?:"[]\|';/.,`;
        str = `abcd 1234567890ABCD1234~!@#$%^&*()_+{}<>?:[]\|;/.,`;
        
        // PHP
        // abcd+1234567890ABCD1234%7E%21%40%23%24%25%5E%26%2A%28%29_%2B%7B%7D%3C%3E%3F%3A%5B%5D%5C%7C%3B%2F.%2C
        // abcd%201234567890ABCD1234~%21%40%23%24%25%5E%26%2A%28%29_%2B%7B%7D%3C%3E%3F%3A%5B%5D%5C%7C%3B%2F.%2C
        

        // https://www.webtools.services/url-encoder-decoder
        // https://www.urlencoder.org/
        // abcd%201234567890ABCD1234~%21%40%23%24%25%5E%26%2A%28%29_%2B%7B%7D%3C%3E%3F%3A%5B%5D%5C%7C%3B%2F.%2C


        // abcd%201234567890ABCD1234~%21%40%23%24%25%5E%26%2A%28%29_%2B%7B%7D%3C%3E%3F%3A%22%5B%5D%5C%7C%27%3B%2F.%2C
        // abcd+1234567890ABCD1234%7E%21%40%23%24%25%5E%26*%28%29_%2B%7B%7D%3C%3E%3F%3A%22%5B%5D%5C%7C%27%3B%2F.%2C

        // https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/encodeURIComponent
        // abcd%201234567890ABCD1234~!%40%23%24%25%5E%26*()_%2B%7B%7D%3C%3E%3F%3A%22%5B%5D%7C%3B%2F.%2C

        string result = UrlEncoded.encodeString(str);
        warning(result);
        // 

        trace(encodeComponent(str));
        // abcd%201234567890ABCD1234~!%40%23%24%25%5E%26*()_%2B%7B%7D%3C%3E%3F%3A%5B%5D%5C%7C%3B%2F.%2C

        trace(encode(str));
        // abcd%201234567890ABCD1234~!@#$%25%5E&*()_+%7B%7D%3C%3E?:%5B%5D%5C%7C;/.,
    }

    void testDecoder() {
        
        string playload = `email=&password=abc&file=`;
        UrlEncoded url_encoded = new UrlEncoded(UrlEncodeStyle.HtmlForm);
        url_encoded.decode(playload);
        
        string[][string] dataMap;
        foreach (string key; url_encoded.byKey()) {
            foreach(string v; url_encoded.getValues(key)) {
                key = key.strip();
                dataMap[key] ~= v.strip();
            }
        }

        // trace(dataMap);
        assert(dataMap["password"] == ["abc"]);
    }
}