/*
    websockets.c - Test WebSockets
 */
#include "esp.h"

static void traceEvent(HttpConn *conn, int event, int arg)
{
    HttpPacket  *packet;

    if (event == HTTP_EVENT_READABLE) {
        packet = conn->readq->first;
        mprLog(1, "websock.c: read %s event, last %d", packet->type == WS_MSG_TEXT ? "text" : "binary", packet->last);
        mprLog(1, "websock.c: read: (start of data only) \"%s\"", snclone(mprGetBufStart(packet->content), 40));

    } else if (event == HTTP_EVENT_APP_CLOSE) {
        mprLog(1, "websock.c: close event. Status status %d, orderly closed %d, reason %s", arg,
            httpWebSocketOrderlyClosed(conn), httpGetWebSocketCloseReason(conn));

    } else if (event == HTTP_EVENT_ERROR) {
        mprLog(1, "websock.c: error event");
    }
}

static void echo_callback(HttpConn *conn, int event, int arg)
{
    HttpPacket      *packet;
    HttpWebSocket   *ws;

    traceEvent(conn, event, arg);
    if (event == HTTP_EVENT_READABLE) {
        packet = httpGetPacket(conn->readq);
        assert(packet);
        /* Ignore precedding packets and just trace the last */
        if (packet->last) {
            ws = conn->rx->webSocket;
            mprAddNullToBuf(packet->content);
            httpSend(conn, "Server received: {type: %d, last: %d, length: %d, msg: \"%s\"}\n", 
                packet->type, packet->last, ws->messageLength, mprGetBufStart(packet->content));
        }
    }
}

static void echo_action() { 
    dontAutoFinalize();
    httpSetConnNotifier(getConn(), echo_callback);
}


ESP_EXPORT int esp_module_websockets(HttpRoute *route, MprModule *module) {
    espDefineAction(route, "test-echo", echo_action);
    return 0;
}
