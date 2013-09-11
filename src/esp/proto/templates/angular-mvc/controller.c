/*
    ${NAME} Controller
 */
#include "esp.h"

static void create${TITLE}() { 
    EdiRec *rec;
    rec = createRec("${NAME}", params());
    renderResult(updateRec(rec));
}

static void get${TITLE}() { 
    renderRec(readRec("${NAME}", param("id")));
}

static void init${TITLE}() { 
    renderRec(createRec("${NAME}", 0));
}

static void list${TITLE}() {
    renderGrid(readTable("${NAME}"));
}

static void remove${TITLE}() { 
    renderResult(removeRec("${NAME}", param("id")));
}

static void update${TITLE}() { 
    EdiRec *rec;
    rec = setFields(readRec("${NAME}", param("id")), params());
    renderResult(updateRec(rec));
}

ESP_EXPORT int esp_module_${NAME}(HttpRoute *route, MprModule *module) {
    espDefineAction(route, "${NAME}-create", create${TITLE});
    espDefineAction(route, "${NAME}-get", get${TITLE});
    espDefineAction(route, "${NAME}-init", init${TITLE});
    espDefineAction(route, "${NAME}-list", list${TITLE});
    espDefineAction(route, "${NAME}-remove", remove${TITLE});
    espDefineAction(route, "${NAME}-update", update${TITLE});
${DEFINE_ACTIONS}    return 0;
}
