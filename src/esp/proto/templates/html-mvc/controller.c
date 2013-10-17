/*
    ${NAME} Controller
 */
#include "esp.h"

static void create() { 
    if (updateRec(createRec("${NAME}", params()))) {
        feedback("inform", "New ${NAME} created");
        renderView("${NAME}-list");
    } else {
        renderView("${NAME}-edit");
    }
}

static void destroy() { 
    if (removeRec("${NAME}", param("id"))) {
        feedback("inform", "${TITLE} removed");
    }
    renderView("${NAME}-list");
}

static void edit() { 
    readRec("${NAME}", param("id"));
}

static void list() { 
    renderView("${NAME}-list");
}

static void init() { 
    createRec("${NAME}", 0);
    renderView("${NAME}-edit");
}

static void show() { 
    readRec("${NAME}", param("id"));
    renderView("${NAME}-edit");
}

static void update() { 
    if (updateFields("${NAME}", params())) {
        feedback("inform", "${TITLE} updated successfully.");
        renderView("${NAME}-list");
    } else {
        renderView("${NAME}-edit");
    }
}

ESP_EXPORT int esp_controller_${APP}_${NAME}(HttpRoute *route, MprModule *module) {
    espDefineAction(route, "${NAME}-create", create);
    espDefineAction(route, "${NAME}-destroy", destroy);
    espDefineAction(route, "${NAME}-edit", edit);
    espDefineAction(route, "${NAME}-init", init);
    espDefineAction(route, "${NAME}-list", list);
    espDefineAction(route, "${NAME}-show", show);
    espDefineAction(route, "${NAME}-update", update);
${DEFINE_ACTIONS}    return 0;
}
