/*
    esp-edit.js - The esp-edit attribute to conditionally redirect to URLs if the user has the required abilities.

    <tag esp-edit="URL" ... />
 */
'use strict';

angular.module('esp.edit', [])
.directive('espEdit', function (Esp, $location, $rootScope, $timeout) {
    return {
        restrict: 'A',
        link: function (scope, element, attrs) {
            attrs.$observe('esp-edit', function(val) {
                element.on('click', function() {
                    scope.$apply(function() {
                        if (!Esp.config.auth || Esp.can('edit')) {
                            $location.path(attrs.espEdit);
                        } else {
                            /* Delay so that the feedback clear won't immediately erase */
                            $timeout(function() {
                                $rootScope.feedback = { error: "Insufficient Privilege" };
                            }, 0, true);
                        }
                    });
                });
            });
        }
    };
});
