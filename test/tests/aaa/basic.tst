/*
    basic.tst - Test basic connectivity
 */

const HTTP = App.config.uris.http || "127.0.0.1:4100"

let http: Http = new Http

/*
    If this fails. Look at trace.txt log output
 */
http.get(HTTP + "/index.html")
assert(http.status == 200)

