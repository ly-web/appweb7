/*
    ${NAME} Controller
 */
#include "esp.h"

/*
    Create a new resource in the database
 */
static void create${TITLE}() { 
    sendResult(updateRec(createRec("${TABLE}", params())));
}

/*
    Get a resource
 */
static void get${TITLE}() { 
    sendRec(readRec("${TABLE}", param("id")));
}

/*
    Initialize a new resource for the client to complete
 */
static void init${TITLE}() { 
    sendRec(createRec("${TABLE}", 0));
}

/*
    List the resources in this group
 */
static void list${TITLE}() {
    sendGrid(readTable("${TABLE}"));
}

/*
    Remove a resource identified by the "id" parameter
 */
static void remove${TITLE}() { 
    sendResult(removeRec("${TABLE}", param("id")));
}

/*
    Update an existing resource in the database
    If "id" is not defined, this is the same as a create
 */
static void update${TITLE}() { 
    sendResult(updateRec(setFields(readRec("${TABLE}", param("id")), params())));
}

/*
    Dynamic module initialization
 */
ESP_EXPORT int esp_controller_${APP}_${NAME}(HttpRoute *route, MprModule *module) {
    espDefineAction(route, "${NAME}-create", create${TITLE});
    espDefineAction(route, "${NAME}-get", get${TITLE});
    espDefineAction(route, "${NAME}-init", init${TITLE});
    espDefineAction(route, "${NAME}-list", list${TITLE});
    espDefineAction(route, "${NAME}-remove", remove${TITLE});
    espDefineAction(route, "${NAME}-update", update${TITLE});
${DEFINE_ACTIONS}    
#if SAMPLE_VALIDATIONS
    Edi *edi = espGetRouteDatabase(route);
    ediAddValidation(edi, "present", "${NAME}", "title", 0);
    ediAddValidation(edi, "unique", "${NAME}", "title", 0);
    ediAddValidation(edi, "banned", "${NAME}", "body", "(swear|curse)");
    ediAddValidation(edi, "format", "${NAME}", "phone", "/^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/");
#endif
    return 0;
}
