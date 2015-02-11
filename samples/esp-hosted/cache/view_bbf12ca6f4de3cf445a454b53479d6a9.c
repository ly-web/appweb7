/*
   Generated from post/list.esp
 */
#include "esp.h"

static void view_bbf12ca6f4de3cf445a454b53479d6a9(HttpConn *conn) {
EdiGrid     *grid = readTable("post");
            EdiRec      *rec;
            EdiField    *fp;
          
  espRenderBlock(conn, "<!DOCTYPE html>\n\
<html lang=\"en\">\n\
<head>\n\
    \n\
    <title>Esp Application</title>\n\
    <meta charset=\"utf-8\" />\n\
    <meta name=\"description\" content=\"Esp Sample Application\">\n\
    <link rel=\"shortcut icon\" href=\"data:image/x-icon;,\" type=\"image/x-icon\">\n\
    \n\
\n\
    <link rel=\"stylesheet\" href=\"../css/all.css\" type=\"text/css\" />\n\
\n\
\n\
</head>\n\
<body>\n\
    \n\
    <div class=\"navbar\">\n\
        <div class=\"navbar-header\">\n\
            <a class=\"navbar-brand\" href=\"#\">", 452);
  espRenderSafeString(conn, getConfig("title"));
  espRenderBlock(conn, "</a>\n\
        </div>\n\
    </div>\n\
\n\
\n\
    <main class=\"container\">\n\
\n\
        ", 71);
  espRenderBlock(conn, "\n\
        <h1>Post List</h1>\n\
        <table class='list'>\n\
            <thead>\n\
                <tr>", 97);
if (grid && grid->nrecords) {
                        rec = grid->records[0];
                        for (fp = 0; (fp = ediGetNextField(rec, fp, 1)) != 0; ) { 
                            render("<th>%s</th>\n", stitle(fp->name));
                        }
                    }   espRenderBlock(conn, "\n\
                </tr>\n\
            </thead>\n\
            <tbody>\n\
                ", 80);
for (rec = 0; (rec = ediGetNextRec(grid, rec)) != 0; ) {   espRenderBlock(conn, "\n\
                    <tr onclick='document.location=\"", 53);
  espRenderSafeString(conn, uri("%s", rec->id));
  espRenderBlock(conn, "\"'>\n\
                        ", 28);
for (fp = 0; (fp = ediGetNextField(rec, fp, 1)) != 0; ) {   espRenderBlock(conn, "\n\
                            <td>", 33);
  espRenderSafeString(conn, ediFormatField(0, fp));
  espRenderBlock(conn, "</td>\n\
                        ", 30);
}   espRenderBlock(conn, "\n\
                    </tr>\n\
                ", 43);
}   espRenderBlock(conn, "\n\
            </tbody>\n\
        </table>\n\
        <a href=\"init\"><button class='btn btn-primary'>New Post</button></a>\n\
\n\
    </main>\n\
    \n\
        <div class=\"feedback\">\n\
            ", 177);
renderFlash("all");   espRenderBlock(conn, "\n\
        </div>\n\
\n\
\n\
\n\
</body>\n\
</html>\n\
", 35);
}

ESP_EXPORT int esp_view_bbf12ca6f4de3cf445a454b53479d6a9(HttpRoute *route, MprModule *module) {
   espDefineView(route, "post/list.esp", view_bbf12ca6f4de3cf445a454b53479d6a9);
   return 0;
}
