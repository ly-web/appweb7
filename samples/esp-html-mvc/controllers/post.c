/*
    post Controller
 */
#include "esp.h"

/*
    Create a new resource in the database
 */ 
static void createPost() { 
    if (updateRec(createRec("post", params()))) {
        flash("inform", "New post created");
        renderView("post/post-list");
    } else {
        renderView("post/post-edit");
    }
}

/*
    Prepare a template for editing a resource
 */
static void editPost() { 
    readRec("post", param("id"));
}

/*
    Get a resource
 */ 
static void getPost() { 
    readRec("post", param("id"));
    renderView("post/post-edit");
}

/*
    Initialize a new resource for the client to complete
 */
static void initPost() { 
    createRec("post", 0);
    renderView("post/post-edit");
}

/*
    List the resources in this group
 */ 
static void listPost() { 
    renderView("post/post-list");
}

/*
    Remove a resource identified by the "id" parameter
 */
static void removePost() { 
    if (removeRec("post", param("id"))) {
        flash("inform", "Post removed");
    }
    redirect("list");
}

/*
    Update an existing resource in the database
    If "id" is not defined, this is the same as a create
    Also we tunnel delete here if the user clicked delete
 */
static void updatePost() { 
    if (smatch(param("submit"), "Delete")) {
        removePost();
    } else {
        if (updateFields("post", params())) {
            flash("inform", "Post updated successfully.");
            redirect("list");
        } else {
            renderView("post/post-edit");
        }
    }
}

static void common(HttpConn *conn) {
}

/*
    Dynamic module initialization
 */
ESP_EXPORT int esp_controller_blog_post(HttpRoute *route, MprModule *module) {
    espDefineBase(route, common);
    espDefineAction(route, "post-create", createPost);
    espDefineAction(route, "post-remove", removePost);
    espDefineAction(route, "post-edit", editPost);
    espDefineAction(route, "post-get", getPost);
    espDefineAction(route, "post-init", initPost);
    espDefineAction(route, "post-list", listPost);
    espDefineAction(route, "post-update", updatePost);
    
#if SAMPLE_VALIDATIONS
    Edi *edi = espGetRouteDatabase(route);
    ediAddValidation(edi, "present", "post", "title", 0);
    ediAddValidation(edi, "unique", "post", "title", 0);
    ediAddValidation(edi, "format", "post", "message", "(dog|cat)");
#endif
    return 0;
}
