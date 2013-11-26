/*
    post Controller
 */
#include "esp.h"

/*
    Create a new resource in the database
 */
static void createPost() { 
    sendResult(updateRec(createRec("post", params())));
}

/*
    Get a resource
 */
static void getPost() { 
    sendRec(readRec("post", param("id")));
}

/*
    Initialize a new resource for the client to complete
 */
static void initPost() { 
    sendRec(createRec("post", 0));
}

/*
    List the resources in this group
 */
static void listPost() {
    sendGrid(readTable("post"));
}

/*
    Remove a resource identified by the "id" parameter
 */
static void removePost() { 
    sendResult(removeRec("post", param("id")));
}

/*
    Update an existing resource in the database
    If "id" is not defined, this is the same as a create
 */
static void updatePost() { 
    sendResult(updateRec(setFields(readRec("post", param("id")), params())));
}

/*
    Dynamic module initialization
 */
ESP_EXPORT int esp_controller_blog_post(HttpRoute *route, MprModule *module) {
    Edi     *edi;

    espDefineAction(route, "post-create", createPost);
    espDefineAction(route, "post-get", getPost);
    espDefineAction(route, "post-init", initPost);
    espDefineAction(route, "post-list", listPost);
    espDefineAction(route, "post-remove", removePost);
    espDefineAction(route, "post-update", updatePost);
    /*
        Add model validations
     */
    edi = espGetRouteDatabase(route);
    ediAddValidation(edi, "present", "post", "title", 0);
    ediAddValidation(edi, "unique", "post", "title", 0);

#if FUTURE || 1
    /*
        Regular expression to check the format of a field. This example requires posts to mention dog or cat.
     */
    ediAddValidation(edi, "format", "post", "body", "(cat|dog)");
#endif
    return 0;
}
