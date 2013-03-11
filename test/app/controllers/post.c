/*
    Post controller
 */
#include "esp.h"

static void common() {
}

static void post_create() { 
    if (updateRec(createRec("post", params()))) {
        inform("New post created");
        redirect("@");
    } else {
        renderView("post-edit");
    }
}

static void post_destroy() { 
    if (removeRec("post", param("id"))) {
        inform("Post removed");
    }
    redirect("@");
}

static void post_edit() { 
    readRec("post");
}

static void post_list() { }

static void post_init() { 
    createRec("post", 0);
    renderView("post-edit");
}

static void post_show() { 
    readRec("post");
    renderView("post-edit");
}

static void post_update() { 
    if (updateFields("post", params())) {
        inform("Post updated successfully.");
        redirect("@");
    } else {
        renderView("post-edit");
    }
}

ESP_EXPORT int esp_module_post(HttpRoute *route, MprModule *module) 
{
    Edi     *edi;

    espDefineBase(route, common);
    espDefineAction(route, "post-create", post_create);
    espDefineAction(route, "post-destroy", post_destroy);
    espDefineAction(route, "post-edit", post_edit);
    espDefineAction(route, "post-init", post_init);
    espDefineAction(route, "post-list", post_list);
    espDefineAction(route, "post-show", post_show);
    espDefineAction(route, "post-update", post_update);

    /*
        Add model validations
     */
    edi = espGetRouteDatabase(route->eroute);
    ediAddValidation(edi, "present", "post", "title", 0);
    ediAddValidation(edi, "unique", "post", "title", 0);
    ediAddValidation(edi, "format", "post", "body", "(fox|dog)");
    return 0;
}
