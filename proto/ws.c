/*
    Test web sockets controller
 */
#include "esp.h"

static void onEvent(HttpConn *conn, int event, int arg)
{
    char    buf[1024];
    ssize   len;

    if (event == HTTP_NOTIFY_READABLE) {
        /* Called once per packet unless packet is too large (LimitWebSocketPacket) */
        print("wscontroller: READABLE format %s\n", arg == WS_MSG_TEXT ? "text" : "binary");
        if ((len = httpRead(conn, buf, sizeof(buf) - 1)) > 0) {
            buf[len] = '\0';
            print("wscontroller: GOT \"%s\"\n", buf);
        }
        httpSend(conn, "Appweb alive at %s", mprGetDate(0));

    } else if (event == HTTP_NOTIFY_CLOSED) {
        print("wscontroller: CLOSED status %d\n", arg);
        print("CLEAN close %d\n", (arg != WS_STATUS_COMMS_ERROR));
        print("CLEAN reason %s\n", conn->rx->closeReason);
        //  MOB - is this required
        httpFinalize(conn);

    } else if (event == HTTP_NOTIFY_ERROR) {
        print("wscontroller: ERROR\n");
        //  MOB - is this required
        httpFinalize(conn);
    }
}

static void msgtest() { 
    HttpConn *conn = getConn();
    dontAutoFinalize();
    httpSetWebSocketNotifier(conn, onEvent);
    print("wscontroller: PROTOCOL %s\n", httpGetWebSockProtocol(conn));
    /*
    if (smatch(httpGetWebSockProtocol(getConn()), "chat")) {
        httpSendClose(conn, WS_STATUS_GOING_AWAY, NULL);
    }
    */
}

ESP_EXPORT int esp_controller_ws(HttpRoute *route, MprModule *module) {
    espDefineAction(route, "proto-msg", msgtest);
    return 0;
}
