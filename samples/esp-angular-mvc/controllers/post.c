/*
    post Controller (esp-angular-mvc)
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
    espDefineAction(route, "post-create", createPost);
    espDefineAction(route, "post-get", getPost);
    espDefineAction(route, "post-init", initPost);
    espDefineAction(route, "post-list", listPost);
    espDefineAction(route, "post-remove", removePost);
    espDefineAction(route, "post-update", updatePost);
    
#if SAMPLE_VALIDATIONS
    Edi *edi = espGetRouteDatabase(route);
    ediAddValidation(edi, "present", "post", "title", 0);
    ediAddValidation(edi, "unique", "post", "title", 0);
    ediAddValidation(edi, "banned", "post", "body", "(swear|curse)");
    ediAddValidation(edi, "format", "post", "phone", "/^\(?([0-9]{3})\)?[-. ]?([0-9]{3})[-. ]?([0-9]{4})$/");
#endif
    return 0;
}
