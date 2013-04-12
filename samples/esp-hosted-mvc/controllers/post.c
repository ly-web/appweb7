/*
    Blog post controller
 */
 #include "esp-app.h"

/*
    Create a post
 */
static void create() { 
    if (updateRec(createRec("post", params()))) {
        inform("New post created");
        renderView("post-list");
    } else {
        renderView("post-edit");
    }
}

static void destroy() { 
    if (removeRec("post", param("id"))) {
        inform("Post removed");
    }
    renderView("post-list");
}

static void edit() { 
    readRec("post");
}

static void list() { }

static void init() { 
    createRec("post", 0);
    renderView("post-edit");
}

static void show() { 
    readRec("post");
    renderView("post-edit");
}

static void update() { 
    if (updateFields("post", params())) {
        inform("Post updated successfully.");
        renderView("post-list");
    } else {
        renderView("post-edit");
    }
}

/*
    Define controller actions. This bind each RESTful URI route to the C function.
 */
ESP_EXPORT int esp_module_post(HttpRoute *route, MprModule *module) 
{
    espDefineAction(route, "post-create", create);
    espDefineAction(route, "post-destroy", destroy);
    espDefineAction(route, "post-edit", edit);
    espDefineAction(route, "post-init", init);
    espDefineAction(route, "post-list", list);
    espDefineAction(route, "post-show", show);
    espDefineAction(route, "post-update", update);
    return 0;
}
