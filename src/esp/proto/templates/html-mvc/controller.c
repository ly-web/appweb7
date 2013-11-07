/*
    ${NAME} Controller
 */
#include "esp.h"

/*
    Create a new resource in the database
 */ 
static void create${TITLE}() { 
    if (updateRec(createRec("${NAME}", params()))) {
        feedback("inform", "New ${NAME} created");
        renderView("${NAME}-list");
    } else {
        renderView("${NAME}-edit");
    }
}

/*
    Prepare a template for editing a resource
 */
static void edit${TITLE}() { 
    readRec("${NAME}", param("id"));
}

/*
    Get a resource
 */ 
static void get${TITLE}() { 
    readRec("${NAME}", param("id"));
    renderView("${NAME}-edit");
}

/*
    Initialize a new resource for the client to complete
 */
static void init${TITLE}() { 
    createRec("${NAME}", 0);
    renderView("${NAME}-edit");
}

/*
    List the resources in this group
 */ 
static void list${TITLE}() { 
    renderView("${NAME}-list");
}

/*
    Remove a resource identified by the "id" parameter
 */
static void remove${TITLE}() { 
    if (removeRec("${NAME}", param("id"))) {
        feedback("inform", "${TITLE} removed");
    }
    renderView("${NAME}-list");
}

/*
    Update an existing resource in the database
    If "id" is not defined, this is the same as a create
 */
static void update${TITLE}() { 
    if (updateFields("${NAME}", params())) {
        feedback("inform", "${TITLE} updated successfully.");
        renderView("${NAME}-list");
    } else {
        renderView("${NAME}-edit");
    }
}

/*
    Dynamic module initialization
 */
ESP_EXPORT int esp_controller_${APP}_${NAME}(HttpRoute *route, MprModule *module) {
    espDefineAction(route, "${NAME}-create", create${TITLE});
    espDefineAction(route, "${NAME}-remove", remove${TITLE});
    espDefineAction(route, "${NAME}-edit", edit${TITLE});
    espDefineAction(route, "${NAME}-get", get${TITLE});
    espDefineAction(route, "${NAME}-init", init${TITLE});
    espDefineAction(route, "${NAME}-list", list${TITLE});
    espDefineAction(route, "${NAME}-update", update${TITLE});
${DEFINE_ACTIONS}    return 0;
}
