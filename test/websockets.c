/*
    websockets.c - Test WebSockets
 */
#include "esp.h"

static void traceEvent(HttpConn *conn, int event, int arg)
{
    HttpPacket  *packet;

    if (event == HTTP_EVENT_READABLE) {
        packet = conn->readq->first;
        print("websock.c: read %s event, last %d\n", packet->type == WS_MSG_TEXT ? "text" : "binary", packet->last);
        print("websock.c: read: \"%s\"\n", mprGetBufStart(packet->content));

    } else if (event == HTTP_EVENT_APP_CLOSE) {
        print("websock.c: close event. Status status %d, orderly closed %d, reason %s\n", arg,
            httpWebSocketOrderlyClosed(conn), httpGetWebSocketCloseReason(conn));

    } else if (event == HTTP_EVENT_ERROR) {
        print("websock.c: error event\n");
    }
}

static void dummy_callback(HttpConn *conn, int event, int arg)
{
}

static void dummy_action() { 
    dontAutoFinalize();
    httpSetConnNotifier(getConn(), dummy_callback);
}

static void echo_callback(HttpConn *conn, int event, int arg)
{
    HttpPacket  *packet;

    traceEvent(conn, event, arg);
    if (event == HTTP_EVENT_READABLE) {
        packet = httpGetPacket(conn->readq);
        httpSend(conn, sjoin("got:", mprGetBufStart(packet->content), NULL));
    }
}

static void echo_action() { 
    dontAutoFinalize();
    httpSetConnNotifier(getConn(), echo_callback);
}


ESP_EXPORT int esp_module_websockets(HttpRoute *route, MprModule *module) {
    espDefineAction(route, "basic-construct", dummy_action);
    espDefineAction(route, "basic-open", dummy_action);
    espDefineAction(route, "basic-send", dummy_action);
    espDefineAction(route, "basic-ssl", echo_action);
    espDefineAction(route, "basic-len", echo_action);
    return 0;
}
