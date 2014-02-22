/*
    ${CONTROLLER} Controller (esp-angular-mvc)
 */
#include "esp.h"

/*
    Create a new resource in the database
 */
static void create${UCONTROLLER}() { 
    sendResult(updateRec(createRec("${TABLE}", params())));
}

/*
    Get a resource
 */
static void get${UCONTROLLER}() { 
    sendRec(readRec("${TABLE}", param("id")));
}

/*
    Initialize a new resource for the client to complete
 */
static void init${UCONTROLLER}() { 
    sendRec(createRec("${TABLE}", 0));
}

/*
    List the resources in this group
 */
static void list${UCONTROLLER}() {
    sendGrid(readTable("${TABLE}"));
}

/*
    Remove a resource identified by the "id" parameter
 */
static void remove${UCONTROLLER}() { 
    sendResult(removeRec("${TABLE}", param("id")));
}

/*
    Update an existing resource in the database
    If "id" is not defined, this is the same as a create
 */
static void update${UCONTROLLER}() { 
    sendResult(updateRec(setFields(readRec("${TABLE}", param("id")), params())));
}

/*
    Dynamic module initialization
 */
ESP_EXPORT int esp_controller_${APP}_${CONTROLLER}(HttpRoute *route, MprModule *module) {
    espDefineAction(route, "${CONTROLLER}-create", create${UCONTROLLER});
    espDefineAction(route, "${CONTROLLER}-get", get${UCONTROLLER});
    espDefineAction(route, "${CONTROLLER}-init", init${UCONTROLLER});
    espDefineAction(route, "${CONTROLLER}-list", list${UCONTROLLER});
    espDefineAction(route, "${CONTROLLER}-remove", remove${UCONTROLLER});
    espDefineAction(route, "${CONTROLLER}-update", update${UCONTROLLER});
${DEFINE_ACTIONS}    
#if SAMPLE_VALIDATIONS
    Edi *edi = espGetRouteDatabase(route);
    ediAddValidation(edi, "present", "${CONTROLLER}", "title", 0);
    ediAddValidation(edi, "unique", "${CONTROLLER}", "title", 0);
    ediAddValidation(edi, "banned", "${CONTROLLER}", "body", "(swear|curse)");
    ediAddValidation(edi, "format", "${CONTROLLER}", "phone", "/^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/");
#endif
    return 0;
}
