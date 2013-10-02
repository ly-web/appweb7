/*
    ${NAME} Controller
 */
#include "esp.h"

static void create${TITLE}() { 
    renderResult(updateRec(createRec("${TABLE}", params())));
}

static void get${TITLE}() { 
    renderRec(readRec("${TABLE}", "1"));
}

static void init${TITLE}() { 
    renderRec(createRec("${TABLE}", 0));
}

static void remove${TITLE}() { 
    renderResult(removeRec("${TABLE}", "1"));
}

static void update${TITLE}() { 
    renderResult(updateRec(setFields(readRec("${TABLE}", "1"), params())));
}

ESP_EXPORT int esp_controller_${APP}_${NAME}(HttpRoute *route, MprModule *module) {
    espDefineAction(route, "${NAME}-create", create${TITLE});
    espDefineAction(route, "${NAME}-get", get${TITLE});
    espDefineAction(route, "${NAME}-init", init${TITLE});
    espDefineAction(route, "${NAME}-remove", remove${TITLE});
    espDefineAction(route, "${NAME}-update", update${TITLE});
${DEFINE_ACTIONS}    return 0;
}
