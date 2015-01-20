/*
   Generated from index.esp
 */
#include "esp.h"

static void view_3db592c117d52e741ef12c0bd3612d0f(HttpConn *conn) {
  espRenderBlock(conn, "<!DOCTYPE html>\n\
<html lang=\"en\">\n\
<head>\n\
    \n\
    <title>Blog</title>\n\
    <meta charset=\"utf-8\" />\n\
    <meta name=\"description\" content=\"Blog Application\">\n\
    <link rel=\"shortcut icon\" href=\"data:image/x-icon;,\" type=\"image/x-icon\">\n\
    \n\
\n\
    <link rel=\"stylesheet\" href=\"css/all.css\" type=\"text/css\" />\n\
\n\
\n\
</head>\n\
<body>\n\
    \n\
    <div class=\"navbar\">\n\
        <div class=\"navbar-header\">\n\
            <a class=\"navbar-brand\" href=\"#\">", 432);
  espRenderSafeString(conn, getConfig("title"));
  espRenderBlock(conn, "</a>\n\
        </div>\n\
    </div>\n\
\n\
\n\
    <main class=\"container\">\n\
\n\
        <article>\n\
            <h1>Welcome to Embedded Server Pages</h1>\n\
            <section>\n\
                <p>ESP is a powerful \"C\"-based web framework for blazing fast dynamic web applications.\n\
                It has an page templating engine, layout pages, a Model-View-Controller framework,\n\
                    embedded database, content caching and application generator.</p>\n\
            </section>\n\
\n\
            <section>\n\
                <h2>Quick Start</h2>\n\
                <ol>\n\
                    <li><b><a href=\"https://embedthis.com/esp/doc/users/pages.html\">Create ESP Pages</b></a>\n\
                    <p>Create web pages under the <b>clients</b> directory.\n\
                        Modify the layout in \"layouts/default.esp\" and customize the Less-based style sheet in the \n\
                        \"css/app.less\" and \"css/theme.less\".</p>\n\
                    </li>\n\
                    <li><b><a href=\"https://embedthis.com/esp/doc/users/controllers.html\">Generate \n\
                        Controllers</a></b>\n\
                        <p>Create controllers to manage your app. Run \n\
                            <a href=\"https://embedthis.com/esp/doc/users/esp.html\"><b>esp</b></a> \n\
                            with no options to see its usage.</p>\n\
                        <pre>esp generate controller NAME [action, ...]</pre>\n\
                    </li>\n\
                    <li><b><a href=\"https://embedthis.com/esp/doc/users/program.html#scaffolds\">Generate \n\
                        Scaffolds</a></b>\n\
                        <p>Create entire scaffolds for large sections of your application. \n\
                        <pre>esp generate scaffold NAME [field:type, ...]</pre>\n\
                    </li>\n\
                    \n\
                    <li><b><a href=\"https://embedthis.com/esp/doc/\">Read the Documentation</a></b>\n\
                        <p>Go to <a href=\"https://embedthis.com/esp/doc/\">\n\
                        https://embedthis.com/esp/doc/</a> for the latest ESP documentation. \n\
                        Here you can read quick tours, overviews and access all the ESP APIs.</b>\n\
                    </li>\n\
                    <li><b>Enjoy!</b></li>\n\
                </ol>\n\
            </section>\n\
        </article>\n\
\n\
        <aside>\n\
            <h2 class=\"section\">ESP Links</h2>\n\
            <ul>\n\
                <li><a href=\"https://embedthis.com\">Official Web Site</a></li>\n\
                <li><a href=\"https://embedthis.com/esp/doc/\">Documentation</a></li>\n\
                <li><a href=\"https://embedthis.com/esp/doc/users/\">ESP User's Guide</a></li>\n\
                <li><a href=\"https://github.com/embedthis/esp\">ESP Repository and Issue List</a></li>\n\
                <li><a href=\"https://embedthis.com/blog/\">Embedthis Blog</a></li>\n\
            </ul>\n\
        </aside>\n\
\n\
    </main>\n\
    \n\
        <div class=\"feedback\">\n\
            ", 2909);
renderFlash("all");   espRenderBlock(conn, "\n\
        </div>\n\
\n\
\n\
\n\
</body>\n\
</html>\n\
", 35);
}

ESP_EXPORT int esp_view_3db592c117d52e741ef12c0bd3612d0f(HttpRoute *route, MprModule *module) {
   espDefineView(route, "index.esp", view_3db592c117d52e741ef12c0bd3612d0f);
   return 0;
}
