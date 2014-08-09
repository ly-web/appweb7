/*
    session.tst -- Test sessions
 */

const HTTP = tget('TM_HTTP') || "127.0.0.1:4100"

var http: Http = new Http

//  Create a session cookie
http.get(HTTP + "/session.ejs")
ttrue(http.status == 200)
let cookie = http.sessionCookie
ttrue(http.response.trim() == "")
http.close()


//  Issue a request with the cookie to pick up the value set in session.ejs
http.setCookie(cookie)
http.get(HTTP + "/session.ejs")
ttrue(http.response.trim() == "77")
http.close()
