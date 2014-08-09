/*
    vhost.tst - Virtual Host tests
 */

const HTTP = tget('TM_HTTP')
const NAMED = tget('TM_NAMED')
const VIRT = tget('TM_VIRT')

let http: Http = new Http

function mainHost() {
    http.get(HTTP + "/main.html")
    http.response.contains("HTTP SERVER")
    ttrue(http.status == 200)

    //  These should fail
    http.get(HTTP + "/iphost.html")
    ttrue(http.status == 404)
    http.get(HTTP + "/vhost1.html")
    ttrue(http.status == 404)
    http.get(HTTP + "/vhost2.html")
    ttrue(http.status == 404)
    http.close()
}


//  The first virtual host listens to "localhost", the second listens to HTTP.

function namedHost() {
    http = new Http
    http.setHeader("Host", "localhost:" + Uri(NAMED).port)
    http.get(NAMED + "/vhost1.html")
    ttrue(http.status == 200)
    http.close()

    //  These should fail
    http = new Http
    http.setHeader("Host", "localhost:" + Uri(NAMED).port)
    http.get(NAMED + "/main.html")
    ttrue(http.status == 404)
    http.close()

    http = new Http
    http.setHeader("Host", "localhost:" + Uri(NAMED).port)
    http.get(NAMED + "/iphost.html")
    ttrue(http.status == 404)
    http.close()

    http = new Http
    http.setHeader("Host", "localhost:" + Uri(NAMED).port)
    http.get(NAMED + "/vhost2.html")
    ttrue(http.status == 404)
    http.close()

    //  Now try the second vhost on 127.0.0.1
    http = new Http
    http.setHeader("Host", "127.0.0.1:" + Uri(NAMED).port)
    http.get(NAMED + "/vhost2.html")
    ttrue(http.status == 200)
    http.close()

    //  These should fail
    http = new Http
    http.setHeader("Host", "127.0.0.1:" + Uri(NAMED).port)
    http.get(NAMED + "/main.html")
    ttrue(http.status == 404)
    http.close()

    http = new Http
    http.setHeader("Host", "127.0.0.1:" + Uri(NAMED).port)
    http.get(NAMED + "/iphost.html")
    ttrue(http.status == 404)
    http.close()

    http = new Http
    http.setHeader("Host", "127.0.0.1:" + Uri(NAMED).port)
    http.get(NAMED + "/vhost1.html")
    ttrue(http.status == 404)
    http.close()
}

function ipHost() {
    let http: Http = new Http
    http.setCredentials("mary", "pass2")
    http.get(VIRT + "/private.html")
    ttrue(http.status == 200)
    http.close()
}

mainHost()
namedHost()
ipHost()
