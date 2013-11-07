/*
    espHtml.c -- HTML controls 

    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */

/********************************** Includes **********************************/

#include    "esp.h"
#include    "edi.h"

#if BIT_PACK_ESP

#define EDATA(s)        "data-esp-" s           /* Prefix for data attributes */
#define ESTYLE(s)       "esp-" s                /* Prefix for ESP styles */

/************************************* Local **********************************/

//  MOB - review
static char *internalOptions[] = {
    "action",                       /* Service/Action to invoke */
    "cell",                         /* table(): If set, table clicks apply to the cell and not to the row */
    "click",                        /* general: URI to invoke if the control is clicked */
    "columns",                      /* table(): Column options */
    "controller",                   /* general: Service to use for click events */
    "escape",                       /* general: Html escape the data */
    "feedback",                     /* general: User feedback overlay after a clickable event */
    "field",
    "formatter",                    /* general: Printf style format string to apply to data */
    "header",                       /* table(): Column options header */
    "hidden",                       /* text(): Field should be hidden */
    "hideErrors",                   /* form(): Hide record validation errors */
    "insecure",                     /* form(): Don't generate a CSRF security token */
    "key",                          /* general: key property/value data to provide for clickable events */
    "keyFormat",                    /* General: How keys are handled for click events: "params" | "path" | "query" */
    "kind",
    "minified",                     /* script(): Use minified script variants */
    "name",                         /* table(): Column options name */
    "params",                       /* general: Parms to pass on click events */
    "pass",
    "password",                     /* text(): Text input is a password */
    "pivot",                        /* table(): Pivot the table data */
    "remote",                       /* general: Set to true to make click event operate in the background */
    "retain",
    "securityToken",                /* form(): Name of security token to use */
    "showHeader",                   /* table(): Show table column names header  */
    "showId",                       /* table(): Show the ID column */
    "sort",                         /* table(): Column to sort rows by */
    "sortOrder",                    /* table(): Row sort order */
    "styleCells",                   /* table(): Styles to use for table cells */
    "styleColumns",                 /* table(): Styles to use for table columns */
    "styleRows",                    /* table(): Styles to use for table rows */
    "title",                        /* table(): Table title to display */
    "toggle",                       /* tabs(): Toggle tabbed panes */
    "value",                        /* general: Value to use instead of record-bound data */
    0
};

static void emitFormErrors(HttpConn *conn, EdiRec *record, MprHash *options);
static cchar *map(HttpConn *conn, MprHash *options);

/************************************* Code ***********************************/

PUBLIC void endForm() 
{
    renderString("</form>");
}


/*
    recid
    method
    action
    remote
    insecure
    securityToken
    hideErrors
    params
 */
PUBLIC void form(EdiRec *record, cchar *optionString)
{
    HttpConn    *conn;
    EspReq      *req;
    MprHash     *options;
    cchar       *action, *recid, *method, *uri, *token;
   
    conn = getConn();
    if (record == 0) {
        record = getRec();
    }
    req = conn->data;
    options = httpGetOptions(optionString);
    recid = 0;

    /*
        If record provided, get the record id. Can be overridden using options.recid
     */
    if (record) {
        req->record = record;
        if (record->id && !httpGetOption(options, "recid", 0)) {
            httpAddOption(options, "recid", record->id);
        }
        recid = httpGetOption(options, "recid", 0);
        emitFormErrors(conn, record, options);
    }
    if ((method = httpGetOption(options, "method", 0)) == 0) {
        method = (recid) ? "PUT" : "POST";
    }
    if (!scaselessmatch(method, "GET") && !scaselessmatch(method, "POST")) {
        /* All methods use POST and tunnel method in data-method */
        httpAddOption(options, EDATA("method"), method);
        method = "POST";
    }
    if ((action = httpGetOption(options, "action", 0)) == 0) {
        action = (recid) ? "@update" : "@create";
    }
    uri = httpUri(conn, action, NULL);
    if (smatch(httpGetOption(options, "remote", 0), "true")) {
        espRender(conn, "<form method='%s' " EDATA("remote") "='%s'%s >\r\n", method, uri, map(conn, options));
    } else {
        espRender(conn, "<form method='%s' action='%s'%s >\r\n", method, uri, map(conn, options));
    }
    if (recid) {
        espRender(conn, "    <input name='recid' type='hidden' value='%s' />\r\n", recid);
    }
    if (!httpGetOption(options, "insecure", 0)) {
        if ((token = httpGetOption(options, "securityToken", 0)) == 0) {
            token = espGetSecurityToken(conn);
        }
        espRender(conn, "    <input name='%s' type='hidden' value='%s' />\r\n", ESP_SECURITY_TOKEN_NAME, token);
    }
}


static cchar *getValue(HttpConn *conn, cchar *fieldName, MprHash *options)
{
    EspReq      *req;
    EdiRec      *record;
    MprKey      *field;
    cchar       *value, *msg;

    req = conn->data;
    value = 0;
    record = req->record;
    if (record) {
        value = ediGetFieldValue(record, fieldName);
        if (record->errors) {
            for (ITERATE_KEY_DATA(record->errors, field, msg)) {
                if (smatch(field->key, fieldName)) {
                    httpInsertOption(options, "class", ESTYLE("field-error"));
                }
            }
        }
    }
    if (value == 0) {
        value = httpGetOption(options, "value", 0);
    }
    if (httpGetOption(options, "escape", 0)) {                                                                                                                 
        value = mprEscapeHtml(value);                                                                                                                          
    }                                                                                                                                                          
    return value;                                                                                                                                              
}


/*
    rows
 */
PUBLIC void input(cchar *field, cchar *optionString)
{
    HttpConn    *conn;
    MprHash     *choices, *options;
    MprKey      *kp;
    EspReq      *req;
    EdiRec      *rec;
    cchar       *rows, *cols, *etype, *value, *checked;
    int         type, flags;

    conn = getConn();
    req = conn->data;
    rec = req->record;
    if (ediGetColumnSchema(rec->edi, rec->tableName, field, &type, &flags, NULL) < 0) {
        type = -1;
    }
    switch (type) {
    case EDI_TYPE_BOOL:
        choices = httpGetOptions("{off: 0, on: 1}");
        options = httpGetOptions(optionString);
        value = getValue(conn, field, options);
        for (kp = 0; (kp = mprGetNextKey(choices, kp)) != 0; ) {
            checked = (smatch(kp->data, value)) ? " checked" : "";
            espRender(conn, "%s <input type='radio' name='%s' value='%s'%s%s />\r\n",
                spascal(kp->key), field, kp->data, checked, map(conn, options));
        }
        break;
    case EDI_TYPE_FLOAT:
    case EDI_TYPE_INT:
        /* Fall through */
    case EDI_TYPE_BINARY:
    default:
        httpError(conn, 0, "espInput: unknown field type %d", type);
        /* Fall through */
    case EDI_TYPE_DATE:
    case EDI_TYPE_STRING:
    case EDI_TYPE_TEXT:
        options = httpGetOptions(optionString);
        if (!httpGetOption(options, "rows", 0)) {
            httpSetOption(options, "rows", "10");
        }
        etype = "text";
        value = getValue(conn, field, options);
        if (value == 0 || *value == '\0') {
            value = espGetParam(conn, field, "");
        }
        if (httpGetOption(options, "password", 0)) {
            etype = "password";
        } else if (httpGetOption(options, "hidden", 0)) {
            etype = "hidden";
        }
        if ((rows = httpGetOption(options, "rows", 0)) != 0) {
            cols = httpGetOption(options, "cols", "60");
            espRender(conn, "<textarea name='%s' type='%s' cols='%s' rows='%s'%s>%s</textarea>", field, etype,
                cols, rows, map(conn, options), value);
        } else {
              espRender(conn, "<input name='%s' type='%s' value='%s'%s />", field, etype, value, map(conn, options));
        }
        break;
    }
}

/**************************************** Support *************************************/ 

//  MOB - update to be like has-errors

static void emitFormErrors(HttpConn *conn, EdiRec *rec, MprHash *options)
{
    MprHash         *errors;
    MprKey          *field;
    char            *msg;
    int             count;
   
    if (!rec->errors || httpGetOption(options, "hideErrors", 0)) {
        return;
    }
    errors = ediGetRecErrors(rec);
    if (errors) {
        count = mprGetHashLength(errors);
        espRender(conn, "<div class='" ESTYLE("form-error") "'><h2>The %s has %s it being saved.</h2>\r\n",
            spascal(rec->tableName), count <= 1 ? "an error that prevents" : "errors that prevent");
        espRender(conn, "    <p>There were problems with the following fields:</p>\r\n");
        espRender(conn, "    <ul>\r\n");
        for (ITERATE_KEY_DATA(errors, field, msg)) {
            espRender(conn, "        <li>%s %s</li>\r\n", field->key, msg);
        }
        espRender(conn, "    </ul>\r\n");
        espRender(conn, "</div>");
    }
}


/*
    Map options to an attribute string. Remove all internal control specific options and transparently handle URI link options.
    WARNING: this returns a non-cloned reference and relies on no GC yield until the returned value is used or cloned.
    This is done as an optimization to reduce memeory allocations.
 */
static cchar *map(HttpConn *conn, MprHash *options)
{
    Esp         *esp;
    EspReq      *req;
    MprHash     *params;
    MprKey      *kp;
    MprBuf      *buf;
    cchar       *value;
    char        *pstr;

    if (options == 0 || mprGetHashLength(options) == 0) {
        return MPR->emptyString;
    }
    req = conn->data;
    //  MOB - remove refresh
    if (httpGetOption(options, EDATA("refresh"), 0) && !httpGetOption(options, "id", 0)) {
        httpAddOption(options, "id", sfmt("id_%d", req->lastDomID++));
    }
    esp = MPR->espService;
    buf = mprCreateBuf(-1, -1);
    for (kp = 0; (kp = mprGetNextKey(options, kp)) != 0; ) {
        if (kp->type != MPR_JSON_OBJ && kp->type != MPR_JSON_ARRAY && !mprLookupKey(esp->internalOptions, kp->key)) {
            mprPutCharToBuf(buf, ' ');
            value = kp->data;
            /*
                Support link template resolution for these options
             */
            if (smatch(kp->key, EDATA("click")) || smatch(kp->key, EDATA("remote")) || smatch(kp->key, EDATA("refresh"))) {
                value = httpUri(conn, value, options);
                if ((params = httpGetOptionHash(options, "params")) != 0) {
                    pstr = (char*) "";
                    for (kp = 0; (kp = mprGetNextKey(params, kp)) != 0; ) {
                        pstr = sjoin(pstr, mprUriEncode(kp->key, MPR_ENCODE_URI_COMPONENT), "=", 
                            mprUriEncode(kp->data, MPR_ENCODE_URI_COMPONENT), "&", NULL);
                    }
                    if (pstr[0]) {
                        /* Trim last "&" */
                        pstr[strlen(pstr) - 1] = '\0';
                    }
                    mprPutToBuf(buf, "%s-params='%s", params);
                }
            }
            mprPutStringToBuf(buf, kp->key);
            mprPutStringToBuf(buf, "='");
            mprPutStringToBuf(buf, value);
            mprPutCharToBuf(buf, '\'');
        }
    }
    mprAddNullToBuf(buf);
    return mprGetBufStart(buf);
}


PUBLIC void espInitHtmlOptions(Esp *esp)
{
    char   **op;

    for (op = internalOptions; *op; op++) {
        mprAddKey(esp->internalOptions, *op, op);
    }
}

#endif /* BIT_PACK_ESP */
/*
    @copy   default

    Copyright (c) Embedthis Software LLC, 2003-2013. All Rights Reserved.

    This software is distributed under commercial and open source licenses.
    You may use the Embedthis Open Source license or you may acquire a 
    commercial license from Embedthis Software. You agree to be fully bound
    by the terms of either license. Consult the LICENSE.md distributed with
    this software for full details and other copyrights.

    Local variables:
    tab-width: 4
    c-basic-offset: 4
    End:
    vim: sw=4 ts=4 expandtab

    @end
 */
