/*
    esp-titlecase.js - Titlecase Filter

    This filter caps the first letter of each word

    string | titlecase
 */

app.filter('titlecase', function(Esp) {
    var titlecaseFilter = function(str) {
        return Esp.titlecase(str);
    };
    return titlecaseFilter;
});
