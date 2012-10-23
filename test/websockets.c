/*
    websockets.c - Test WebSockets
 */
#include "esp.h"

#if UNUSED
static void wsCallback(HttpConn *conn, int event, int arg)
{
    HttpPacket  *packet;
    char        buf[1024];

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

static void dummy_callback(HttpConn *conn, int event, int arg)
{
}

static void dummy_action() { 
    dontAutoFinalize();
    httpSetConnNotifier(getConn(), dummy_callback);
}

static void send_callback(HttpConn *conn, int event, int arg)
{
    HttpPacket  *packet;
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

static void send_action() { 
    dontAutoFinalize();
    httpSetConnNotifier(getConn(), send_callback);
}


ESP_EXPORT int esp_module_websockets(HttpRoute *route, MprModule *module) {
    espDefineAction(route, "basic-construct", dummy_action);
    espDefineAction(route, "basic-open", dummy_action);
    espDefineAction(route, "basic-send", send_action);
    return 0;
}
