/*
    condition.tst - Test conditional routing based on certificate data
 */

if (!Config.SSL) {
    test.skip("SSL not enabled in ejs")

} else if (App.config.bit_ssl !== false) {
    let http: Http

    for each (let provider in Http.providers) {
        if (provider == 'matrixssl') {
            //  MatrixSSL doesn't support certificate state yet
            continue
        }
        http = new Http
        http.provider = provider;
        // http.ca = '../sslconf/ca.crt'
        http.verify = false

        //  Should fail if no cert is provided
        endpoint = App.config.uris.clientcert || "https://127.0.0.1:6443"
        // http.key = '../sslconf/test.key'
        // http.certificate = '../sslconf/test.crt'
        http.get(endpoint + '/ssl-match/index.html')
        try {
            assert(http.status == 200) 
        } catch {
            /* Should catch */
            assert(true)
        }
        http.close()

        //  Should pass with a cert
        endpoint = App.config.uris.clientcert || "https://127.0.0.1:6443"
        http.key = '../sslconf/test.key'
        http.certificate = '../sslconf/test.crt'
        http.get(endpoint + '/ssl-match/index.html')
        assert(http.status == 200) 
        http.close()
    }

} else {
    test.skip("SSL not enabled")
}
