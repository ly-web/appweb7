/*
    esp-click.js - The esp-click attribute for elements without href
 */
'use strict';

app.directive('espClick', function ($location) {
    return {
        restrict: 'A',
        link: function (scope, element, attrs) {
            attrs.$observe('esp-click', function(val) {
                element.on('click', function() {
                    scope.$apply(function() {
                        $location.path(attrs.espClick);
                            /* MOB
                        if (Esp.can('edit')) {
                        } else {
                            $rootScope.feedback = { warning: "Insufficient Privilege" };
                        }
                        */
                    });
                });
            });
        }
    };
});
