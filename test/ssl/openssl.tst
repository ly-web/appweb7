/*
    openssl.tst - Test OpenSSL
 */

if (!Config.SSL) {
    test.skip("SSL not enabled in ejs")

} else if (App.config.bit_openssl !== false) {
    let http: Http = new Http

    http.retries = 0
    http.ca = '../sslconf/ca.crt'
    assert(http.verify == true)
 
    //  Verify the server cert and send a client cert 
    endpoint = App.config.uris.openssl || "https://127.0.0.1:7443"
    http.key = '../sslconf/test.key'
    http.certificate = '../sslconf/test.crt'
    http.get(endpoint + '/index.html')
    assert(http.status == 200) 
    assert(http.info.CLIENT_S_CN == 'localhost')
    assert(http.info.SERVER_S_CN == 'localhost')
    assert(http.info.SERVER_I_OU != http.info.SERVER_S_OU)
    assert(http.info.SERVER_I_EMAIL == 'licensing@example.com')
    http.close()

} else {
    test.skip("SSL not enabled")
}
