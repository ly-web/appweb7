/*
    websockets.c - Test WebSockets
 */
#include "esp.h"

#if UNUSED
static void wsCallback(HttpConn *conn, int event, int arg)
{
    HttpPacket  *packet;
    char        buf[1024];
    ssize       len;

    if (event == HTTP_EVENT_READABLE) {
        packet = httpGetPacket(conn->readq);
        print("websock.c: read %s event, last %d\n", packet->type == WS_MSG_TEXT ? "text" : "binary", packet->last);
        print("websock.c: read: \"%s\"\n", mprGetBufStart(packet->content));
        httpSend(conn, "Appweb alive at %s", mprGetDate(0));

    } else if (event == HTTP_EVENT_APP_CLOSE) {
        print("websock.c: close event. Status status %d, orderly closed %d, reason %s\n", arg,
            httpWebSocketOrderlyClosed(conn), httpGetWebSocketCloseReason(conn));

    } else if (event == HTTP_EVENT_ERROR) {
        print("websock.c: error event\n");
    }
}
#endif

static void construct_callback(HttpConn *conn, int event, int arg)
{
}

static void construct() { 
    dontAutoFinalize();
    httpSetConnNotifier(getConn(), construct_callback);
}

ESP_EXPORT int esp_module_websockets(HttpRoute *route, MprModule *module) {
    espDefineAction(route, "basic-construct", construct);
    return 0;
}
