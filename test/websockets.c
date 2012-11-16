/*
    websockets.c - Test WebSockets
 */
#include "esp.h"

static void traceEvent(HttpConn *conn, int event, int arg)
{
    HttpPacket  *packet;

    if (event == HTTP_EVENT_READABLE) {
        packet = conn->readq->first;
        mprLog(3, "websock.c: read %s event, last %d", packet->type == WS_MSG_TEXT ? "text" : "binary", packet->last);
        mprLog(3, "websock.c: read: (start of data only) \"%s\"", snclone(mprGetBufStart(packet->content), 40));

    } else if (event == HTTP_EVENT_APP_CLOSE) {
        mprLog(3, "websock.c: close event. Status status %d, orderly closed %d, reason %s", arg,
            httpWebSocketOrderlyClosed(conn), httpGetWebSocketCloseReason(conn));

    } else if (event == HTTP_EVENT_ERROR) {
        mprLog(2, "websock.c: error event");
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
    HttpPacket      *packet;
    HttpWebSocket   *ws;
    cchar           *data;

    traceEvent(conn, event, arg);
    if (event == HTTP_EVENT_READABLE) {
        packet = httpGetPacket(conn->readq);
        assure(packet);
        /* Ignore precedding packets and just trace the last */
        if (packet->last) {
            ws = conn->rx->webSocket;
            httpSend(conn, "{type: %d, last: %d, length: %d, data: \"%s\"}\n", packet->type, packet->last,
                ws->messageLength, snclone(mprGetBufStart(packet->content), 10));
        }
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
    espDefineAction(route, "basic-echo", echo_action);
    espDefineAction(route, "basic-ssl", echo_action);
    espDefineAction(route, "basic-len", echo_action);
    return 0;
}
