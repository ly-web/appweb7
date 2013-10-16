/*
    esp-titlecase.js - Titlecase Filter

    This filter caps the first letter of each word

    string | titlecase
 */

app.filter('titlecase', function(Esp) {
    return function(str) {
        return str ? Esp.titlecase(str) : '';
    };
});
