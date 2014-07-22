/*
    badUrl.tst - Stress test malformed URLs 
 */

const HTTP = tget('TM_HTTP') || "127.0.0.1:4100"
let http: Http = new Http

http.get(HTTP + "/index\x01.html")
ttrue(http.status == 400)
http.close()
