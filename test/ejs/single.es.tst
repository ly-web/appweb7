/*
    single.tst -- Single non blocking request
 */

const HTTP = tget('TM_HTTP') || "127.0.0.1:4100"

var http: Http = new Http

http.get(HTTP + "/index.ejs")
ttrue(http.status == 200)
http.close()
