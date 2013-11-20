/*
    app.c -- Esp-html-mvc Application Module

    This module is loaded when Appweb starts.
 */
#include "esp.h"

/*
    This base for controllers is called before processing each request
 */
static void base(HttpConn *conn) {
}

ESP_EXPORT int esp_app_esp-html-mvc(HttpRoute *route, MprModule *module) {
    espDefineBase(route, base);
    return 0;
}
