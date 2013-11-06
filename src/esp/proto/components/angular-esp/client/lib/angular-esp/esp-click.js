/*
    esp-click.js - The esp-click attribute for elements without href
 */
'use strict';

angular.module('esp.click', [])
.directive('espClick', function (Esp, $location, $rootScope, $timeout) {
    return {
        restrict: 'A',
        link: function (scope, element, attrs) {
            attrs.$observe('esp-click', function(val) {
                element.on('click', function() {
                    scope.$apply(function() {
                        if (!Esp.config.auth || Esp.can('edit')) {
                            $location.path(attrs.espClick);
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
