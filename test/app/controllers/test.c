/*
    Test mvc controller
 */
#include "esp.h"

#if UNUSED
static void common() {
    setParam("page-title", "MVC Title");
}
#endif

static void check() { 
    render("Check: OK\r\n");
    finalize();
    /* No view used */
}

static void details() { 
    setParam("secret", "42");
    /* View will be rendered */
}

static void login() { 
    // mprLog(0, "SESSION VAR %s", getSessionVar("id"));
    if (getSessionVar("id")[0]) {
        render("Logged in");
        finalize();

    } else if (smatch(param("username"), "admin") && smatch(param("password"), "secret")) {
        render("Valid Login");
        finalize();
        setSessionVar("id", "admin");

    } else if (smatch(getMethod(), "POST")) {
        render("Invalid login, please retry.");
        finalize();

    } else {
        // mprLog(0, "TRACE CREATE SESSION");
        createSession();
    }
}

static void streamCallback(HttpConn *conn, int event, int arg)
{
    HttpPacket      *packet;
    cchar           *data;

    if (event == HTTP_EVENT_READABLE) {
        while ((packet = httpGetPacket(conn->readq)) != 0) {
            render("Got packet length %d\n", httpGetPacketLength(packet));
            if (packet->flags & HTTP_PACKET_END) {
                render("All input received");
                finalize();
            }
        }
    }
}

/*
    Demonstrate streaming I/O
 */
static void stream() {
    if (smatch(getMethod(), "POST") || smatch(getMethod(), "PUT")) {
        dontAutoFinalize();
        httpSetConnNotifier(getConn(), streamCallback);
    } else {
        render("All input received for %s method\n", getMethod());
    }
}

static void missing() {
    renderError(HTTP_CODE_INTERNAL_SERVER_ERROR, "Missing action");
}

ESP_EXPORT int esp_module_test(HttpRoute *route, MprModule *module) {
    espDefineAction(route, "test-missing", missing);
    espDefineAction(route, "test-cmd-check", check);
    espDefineAction(route, "test-cmd-details", details);
    espDefineAction(route, "test-cmd-login", login);
    espDefineAction(route, "test-cmd-stream", stream);
    return 0;
}
