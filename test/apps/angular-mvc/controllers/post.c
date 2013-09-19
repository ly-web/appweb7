/*
    post Controller
 */
#include "esp.h"

static void createPost() { 
    EdiRec *rec;
    rec = createRec("post", params());
    renderResult(updateRec(rec));
}

static void getPost() { 
    renderRec(readRec("post", param("id")));
}

static void initPost() { 
    renderRec(createRec("post", 0));
}

static void listPost() {
    renderGrid(readTable("post"));
}

static void removePost() { 
    renderResult(removeRec("post", param("id")));
}

static void updatePost() { 
    EdiRec *rec;
    rec = setFields(readRec("post", param("id")), params());
    renderResult(updateRec(rec));
}

ESP_EXPORT int esp_controller_angular_post(HttpRoute *route, MprModule *module) {
    espDefineAction(route, "post-create", createPost);
    espDefineAction(route, "post-get", getPost);
    espDefineAction(route, "post-init", initPost);
    espDefineAction(route, "post-list", listPost);
    espDefineAction(route, "post-remove", removePost);
    espDefineAction(route, "post-update", updatePost);
    return 0;
}
