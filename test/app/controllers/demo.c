/*
    Demo controller

    Not used for test
 */
#include "esp.h"

static void demo_list() {
    render("DONE\n");
}

static void demo_restart() {
    MaAppweb        *appweb;
    MaServer        *server;
    HttpEndpoint    *endpoint;
    
    render("Restarting");
    flush();
    finalize();
    appweb = MPR->appwebService;
    server = mprGetFirstItem(appweb->servers);
    endpoint = mprGetFirstItem(server->endpoints);
    httpStopEndpoint(endpoint);
    endpoint->port = 5555;
    httpStartEndpoint(endpoint);
}

static void demo_second(HttpConn *conn) {
    setConn(conn);
    render("World\n");
    finalize();
}

static void demo_first() {
    dontAutoFinalize();
    render("Hello ");
    setTimeout(demo_second, 5000, getConn());
    flush();
}

static void outsideProc(void *data, MprEvent *event) {
    render("Message: %s\n", data);
    finalize();
}

static void demo_outside() {
    /* Normally used by thread outside */
    mprCreateEventOutside(getConn()->dispatcher, outsideProc, sclone("hello outside"));
    dontAutoFinalize();
}

ESP_EXPORT int esp_module_demo(HttpRoute *route, MprModule *module) {
    EspRoute    *eroute;
    cchar       *schema;

    schema = "{ \
        post: { \
            schema: { \
                id: { type: 'string', autoinc: 'true', key: 'true' }, \
                title: { type: 'string' }, \
                body: { type: 'text' }, \
            }, data: [ \
                [ '1', 'Message one', 'Line one' ], \
                [ '2', 'Message one', 'Line one' ], \
            ], \
        }, \
    ";
    eroute = route->eroute;
    eroute->edi = ediOpen(schema, "mdb", EDI_LITERAL);

#if UNUSED
    EdiGrid *grid = makeGrid("[ \
        { id: '1', country: 'Australia' }, \
        { id: '2', country: 'China' }, \
    ]");

    EdiRec *rec = makeRec("{ id: 1, title: 'Message One', body: 'Line one' }");
#endif

    espDefineAction(route, "demo-list", demo_list);
    espDefineAction(route, "demo-cmd-restart", demo_restart);
    espDefineAction(route, "demo-cmd-first", demo_first);
    espDefineAction(route, "demo-cmd-outside", demo_outside);
    return 0;
}
