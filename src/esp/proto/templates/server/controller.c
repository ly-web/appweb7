/*
    ${NAME} Controller
 */
#include "esp.h"

${DEFINE_CONTROLLERS}

ESP_EXPORT int esp_module_${NAME}(HttpRoute *route, MprModule *module) {
    ${DEFINE_ACTIONS}    
    return 0;
}
