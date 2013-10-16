/*
    esp-input-group.js - ESP esp-input-group directive

    Attributes:
        ng-model="MODEL"                Angular model object
        fields="Title,Title,..."        Ordered list of fields to render. Default to all fields of schema.
        filters="filter,filter,..."     Ordered list of field filters.
        labels="Name,Name,..."          Ordered list of input field labels
        labelWidths="Style,Style,..."   Ordered list of input field label width styles
        widths="Style,style,..."        Ordered list of input field width styles
        classes="Class,Class,..."       Ordered list of input field classes for the division wrapping the esp-input
        types="type,type,..."           Ordered list of input control types (checkbox,radiobox)

    Emits esp-input elements for each field in the schema
 */
app.directive('espInputGroup', function(Esp, $compile, $rootScope) {
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
                        //  MOB - should this be fields or columns
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
                        var types;
                        if (attrs.types) {
                            types = attrs.types.split(',');
                        }
                        var filters;
                        if (attrs.filters) {
                            filters = attrs.filters.split(',');
                        }
                        var widths;
                        if (attrs.widths) {
                            widths = attrs.widths.split(',');
                        }
                        var labelWidths;
                        if (attrs.labelWidths) {
                            labelWidths = attrs.labelWidths.split(',');
                        }
                        angular.forEach(columns, function(field, key) {
                            var i = 0 + key;
                            var label = (labels && labels[i]) ? ('label="' + labels[i] + '"') : Esp.titlecase(field);
                            var style = (classes && classes[i]) ? classes[i] : '';
                            var type = (types && types[i]) ? ('type="' + types[i] + '"') : '';
                            var filter = (filters && filters[i]) ? ('filter="' + filters[i] + '"') : '';
                            var width = (widths && widths[i]) ? ('width="' + widths[i] + '"') : '';
                            var labelWidth = (labelWidths && labelWidths[i]) ? ('labelWidth="' + labelWidths[i] + '"') : '';
                            var thisAtt = attributes + ' ng-model="' + model + '.' + field + '"';
                            var html = '<esp-input' + thisAtt + ' ' + type + ' ' + label + ' ' + labelWidth + ' ' +
                                filter + ' ' + style + '>\n';
                            var newelt = angular.element(html);
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
