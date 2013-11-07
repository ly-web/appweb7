/*
    ${NAME} Controller
 */
#include "esp.h"

/*
    Create a new resource in the database
 */
static void create${TITLE}() { 
    renderResult(updateRec(createRec("${TABLE}", params())));
}

/*
    Get a resource
 */
static void get${TITLE}() { 
    renderRec(readRec("${TABLE}", "1"));
}

/*
    Initialize a new resource for the client to complete
 */
static void init${TITLE}() { 
    renderRec(createRec("${TABLE}", 0));
}

/*
    Remove a resource identified by the "id" parameter
 */
static void remove${TITLE}() { 
    renderResult(removeRec("${TABLE}", "1"));
}

/*
    Update an existing resource in the database
    If "id" is not defined, this is the same as a create
 */
static void update${TITLE}() { 
    renderResult(updateRec(setFields(readRec("${TABLE}", "1"), params())));
}

/*
    Dynamic module initialization
 */
ESP_EXPORT int esp_controller_${APP}_${NAME}(HttpRoute *route, MprModule *module) {
    espDefineAction(route, "${NAME}-create", create${TITLE});
    espDefineAction(route, "${NAME}-get", get${TITLE});
    espDefineAction(route, "${NAME}-init", init${TITLE});
    espDefineAction(route, "${NAME}-remove", remove${TITLE});
    espDefineAction(route, "${NAME}-update", update${TITLE});
${DEFINE_ACTIONS}    return 0;
}
