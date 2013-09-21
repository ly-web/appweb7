/*
    esp-input-group.js - ESP esp-input-group directive

    Attributes:
        ng-model="MODEL"                Angular model object
        columns="Title,Title,..."       Ordered list of columns to render. Default to all columns of schema.
        labels="Name,Name,..."          Order list of input field labels
        classes="Class,Class,..."       Order list of input field classes for the division wrapping the esp-input
        controls="Control,Control,..."  Order list of input control types (checkbox,radiobox)

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
                        var classes;
                        if (attrs.classes) {
                            classes = attrs.classes.split(',');
                        }
                        var controls;
                        if (attrs.controls) {
                            controls = attrs.controls.split(',');
                        }
                        angular.forEach(columns, function(field, key) {
                            var label = labels ? labels[0 + key] : Esp.titlecase(field);
                            var style = classes ? classes[0 + key] : '';
                            var control = controls ? ('control="' + controls[0 + key] + '"') : '';
                            var thisAtt = attributes + ' ng-model="' + model + '.' + field + '"';
                            var input = '<div class="form-group">\n' +
                                    '<label class="control-label col-md-2">' + label + '</label>\n' +
                                    '<div class="controls col-md-6 ' + style + '">\n' +
                                        '<esp-input' + thisAtt + control + '>\n' +
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
