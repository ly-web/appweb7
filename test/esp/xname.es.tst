/*
    xname.tst - ESP get with .xesp extension
 */

const HTTP = tget('TM_HTTP') || "127.0.0.1:4100"
let http: Http = new Http

http.get(HTTP + "/test.xesp")
ttrue(http.status == 200)
http.close()
