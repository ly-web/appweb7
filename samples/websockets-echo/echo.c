/*
    echo.c - WebSockets echo server
 */
#include "esp.h"

static void echo_callback(HttpConn *conn, int event, int arg)
{
    HttpPacket      *packet;

    if (event == HTTP_EVENT_READABLE) {
        packet = httpGetPacket(conn->readq);
        if (packet->type == WS_MSG_TEXT || packet->type == WS_MSG_BINARY) {
            httpSendBlock(conn, packet->type, httpGetPacketStart(packet), httpGetPacketLength(packet), 0);
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
