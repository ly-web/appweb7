/*
    esp-input-group.js - ESP esp-input-group directive

    Emits esp-input elements for each field in the schema
 */
app.directive('espInputGroup', function($rootScope, $compile, Esp) {
    return {
        restrict: 'E',
        replace: true,
        link: function (scope, element, attrs) {
            var model = attrs.ngModel;
            scope.$watch('schema', function (val) {
                if (scope.schema) {
                    if (element.children().length == 0) {
//  MOB - where should this grid col come from
                        var attributes = "";
                        angular.forEach(attrs.$attr, function(value, key){
                            if (value == 'ng-model') return;
                            attributes += ' ' + value + '="' + attrs[key] + '"';
                        });
                        var columns = scope.schema.columns;
                        if (attrs.fields) {
                            columns = attrs.fields.split(',');
                        }
                        var labels;
                        if (attrs.labels) {
                            labels = attrs.labels.split(',');
                        }
                        //  MOB - TODO
                        var styles;
                        if (attrs.styles) {
                            styles = attrs.styles.split(',');
                        }
                        angular.forEach(columns, function(field, key) {
                            //  MOB labels attribute
                            var label = labels ? labels[0 + key] : Esp.titlecase(field);
                            var thisAtt = attributes + ' ng-model="' + model + '.' + field + '"';
                            var input = '<div class="form-group">\n' +
                                    '<label class="control-label col-md-2">' + label + '</label>\n' +
                                    '<div class="col-md-6">\n' +
                                        '<esp-input' + thisAtt + '>\n' +
                                    '</div>\n' +
                                '</div>';
                            var newelt = angular.element(input);
                            element.append(newelt);
                            $compile(newelt)(scope);
                            element.removeAttr('class');
                        });
                    }
                }
            });
        },
    }
});
