/*
    ${NAME} Controller
 */
#include "esp.h"

${DEFINE_CONTROLLERS}

ESP_EXPORT int esp_controller_${APP}_${NAME}(HttpRoute *route, MprModule *module) {
    ${DEFINE_ACTIONS}    
    return 0;
}
