/*
    app.c -- App Source
 */
 #include "esp-app.h"

static void base(HttpConn *conn) {}

ESP_EXPORT int esp_app_app(HttpRoute *route, MprModule *module)
{
    espDefineBase(route, base);
    return 0;
}
