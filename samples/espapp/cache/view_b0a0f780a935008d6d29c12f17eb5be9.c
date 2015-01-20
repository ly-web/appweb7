/*
   Generated from post/edit.esp
 */
#include "esp.h"

static void view_b0a0f780a935008d6d29c12f17eb5be9(HttpConn *conn) {
EdiRec      *rec = getRec();
            EdiField    *fp;
          
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
    <link rel=\"stylesheet\" href=\"../css/all.css\" type=\"text/css\" />\n\
\n\
\n\
</head>\n\
<body>\n\
    \n\
    <div class=\"navbar\">\n\
        <div class=\"navbar-header\">\n\
            <a class=\"navbar-brand\" href=\"#\">", 435);
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
        <h1>", 13);
  espRenderSafeString(conn, param("id") ? "Edit" : "Create");
  espRenderBlock(conn, " Post</h1>\n\
\n\
        <form name='PostForm' class='form-horizontal' action='../post/", 82);
  espRenderVar(conn, "id");
  espRenderBlock(conn, "' method=\"POST\">\n\
            ", 29);
for (fp = 0; (fp = ediGetNextField(rec, fp, 1)) != 0; ) {   espRenderBlock(conn, " \n\
                <div class='form-group'>\n\
                    <label class='control-label col-md-3'>", 101);
  espRenderSafeString(conn, stitle(fp->name));
  espRenderBlock(conn, "</label>\n\
                    <div class='input-group col-md-8 ", 62);
  espRenderSafeString(conn, getFieldError(fp->name) ? "has-error" : "");
  espRenderBlock(conn, "'>\n\
                        ", 27);
input(fp->name, "{class: 'form-control'}");   espRenderBlock(conn, "\n\
                    </div>\n\
                </div>\n\
            ", 63);
}   espRenderBlock(conn, "\n\
            <div class='form-group'>\n\
                <div class='col-md-offset-2 col-md-10'>\n\
                    <input type='submit' class='btn btn-primary' name=\"submit\" value=\"Save\">\n\
                    <a href='list'><button class='btn' type=\"button\">Cancel</button></a>\n\
                    ", 296);
if (hasRec()) {   espRenderBlock(conn, "\n\
                        <input type='submit' class='btn' name=\"submit\" value=\"Delete\">\n\
                    ", 108);
}   espRenderBlock(conn, "\n\
                    ", 21);
inputSecurityToken();   espRenderBlock(conn, "\n\
                </div>\n\
            </div>\n\
        </form>\n\
\n\
    </main>\n\
    \n\
        <div class=\"feedback\">\n\
            ", 120);
renderFlash("all");   espRenderBlock(conn, "\n\
        </div>\n\
\n\
\n\
\n\
</body>\n\
</html>\n\
", 35);
}

ESP_EXPORT int esp_view_b0a0f780a935008d6d29c12f17eb5be9(HttpRoute *route, MprModule *module) {
   espDefineView(route, "post/edit.esp", view_b0a0f780a935008d6d29c12f17eb5be9);
   return 0;
}
