/*
    websockets.c - WebSockets echo server
 */
#include "esp.h"

static void echo_callback(HttpConn *conn, int event, int arg)
{
    HttpPacket      *packet;
    HttpWebSocket   *ws;
    char            *msg;
    ssize           len;

    if (event == HTTP_EVENT_APP_CLOSE) {
        mprTrace(1, "websock.c: close event. Status status %d, orderly closed %d, reason %s", arg,
            httpWebSocketOrderlyClosed(conn), httpGetWebSocketCloseReason(conn));

    } else if (event == HTTP_EVENT_READABLE) {
        mprTrace(1, "websock.c: read %s event, last %d", packet->type == WS_MSG_TEXT ? "text" : "binary", packet->last);
        packet = httpGetPacket(conn->readq);
        if (packet->last) {
            msg = httpPacketString(packet);
            len = httpGetWebSocketMessageLength(conn);
            httpSend(conn, "Server received: {type: %d, last: %d, length: %d, msg: \"%s\"}\n", 
                packet->type, packet->last, len, msg);
        }

    } else if (event == HTTP_EVENT_ERROR) {
        mprTrace(1, "websock.c: error event");
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
