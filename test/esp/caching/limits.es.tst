/*
    limits.tst - Test caching limits
 */

const HTTP = tget('TM_HTTP') || "127.0.0.1:4100"
let http: Http = new Http

//  Get a document that will normally require chunking
http.get(HTTP + "/cache/huge")
ttrue(http.status == 200)
ttrue(http.header("Transfer-Encoding") == "chunked")
ttrue(!http.header("Content-Length"))
ttrue(http.response.contains("Line: 09999 aaaaaaaaaaaaaaaaaabbbbbbbbbbbbbbbbccccccccccccccccccddddddd<br/>"))

//  Because of the LimitCacheItem, huge won't be cached,
http.get(HTTP + "/cache/huge")
ttrue(http.status == 200)
ttrue(http.header("Transfer-Encoding") == "chunked")
ttrue(!http.header("Content-Length"))
ttrue(http.response.contains("Line: 09999 aaaaaaaaaaaaaaaaaabbbbbbbbbbbbbbbbccccccccccccccccccddddddd<br/>"))

http.close()
