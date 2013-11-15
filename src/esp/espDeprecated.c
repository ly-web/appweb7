/*
    espDeprecated.c -- Deprecated HTML controls 

    This code was deprecated in 4.2 and will soon be removed.

    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */

/********************************** Includes **********************************/

#include    "esp.h"
#include    "edi.h"

#if (BIT_PACK_ESP && BIT_ESP_LEGACY)
/************************************* Local **********************************/

#define EDATA(s)        "data-esp-" s           /* Prefix for data attributes */
#define ESTYLE(s)       "esp-" s                /* Prefix for ESP styles */

#define SCRIPT_IE       0x1
#define SCRIPT_LESS     0x2

typedef struct EspScript {
    cchar   *name;                              /* Script name */
    cchar   *option;                            /* Esp control option that must be present to trigger emitting script */
    int     flags;                              /* Conditional generation flags */
} EspScript;

static EspScript defaultScripts[] = {
    { "/js/jquery",              0,              0 },
    { "/js/jquery.tablesorter",  "tablesorter",  0 },
    { "/js/jquery.simplemodal",  "simplemodal",  0 },
    { "/js/jquery.esp",          0,              0 },
    { "/js/html5shiv",           0,              SCRIPT_IE },
    { "/js/respond",             "respond",      SCRIPT_IE },
    { "/js/less",                "less",         SCRIPT_LESS },
    { 0,                         0,              0 },
};

static char *defaultLess[] = {
    "/css/all.less", 
    0,
};

static char *defaultCss[] = {
    "/css/all.css", 
    0,
};

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

static cchar *escapeValue(cchar *value, MprHash *options);
static cchar *formatValue(EdiField *fp, MprHash *options);
static cchar *getValue(HttpConn *conn, cchar *field, MprHash *options);
static cchar *map(HttpConn *conn, MprHash *options);
static void textInner(HttpConn *conn, cchar *field, MprHash *options);

/************************************* Code ***********************************/

PUBLIC void espAlert(HttpConn *conn, cchar *text, cchar *optionString)
{
    MprHash     *options;
   
    options = httpGetOptions(optionString);
    httpInsertOption(options, "class", ESTYLE("alert"));
    text = escapeValue(text, options);
    espRender(conn, "<div%s>%s</div>", map(conn, options), text);
}


PUBLIC void espAnchor(HttpConn *conn, cchar *text, cchar *uri, cchar *optionString) 
{
    MprHash     *options;

    options = httpGetOptions(optionString);
    text = escapeValue(text, options);
    espRender(conn, "<a href='%s'%s>%s</a>", uri, map(conn, options), text);
}


PUBLIC void espButton(HttpConn *conn, cchar *name, cchar *value, cchar *optionString)
{
    MprHash     *options;

    options = httpGetOptions(optionString);
    espRender(conn, "<input name='%s' type='submit' value='%s'%s />", name, value, map(conn, options));
}


PUBLIC void espButtonLink(HttpConn *conn, cchar *text, cchar *uri, cchar *optionString)
{
    MprHash     *options;

    options = httpGetOptions(optionString);
    httpSetOption(options, EDATA("click"), httpUri(conn, uri));
    espRender(conn, "<button%s>%s</button>", map(conn, options), text);
}


/*
    checkbox field 

    checkedValue -- Value for which the checkbox will be checked. Defaults to true.
    Example:
        checkbox("admin", "true")
 */
PUBLIC void espCheckbox(HttpConn *conn, cchar *field, cchar *checkedValue, cchar *optionString) 
{
    MprHash     *options;
    cchar       *value, *checked;
   
    options = httpGetOptions(optionString);
    value = getValue(conn, field, options);
    checked = scaselessmatch(value, checkedValue) ? " checked='yes'" : "";
    espRender(conn, "<input name='%s' type='checkbox'%s%s value='%s' />\r\n", field, map(conn, options), 
        checked, checkedValue);
    espRender(conn, "    <input name='%s' type='hidden'%s value='' />", field, map(conn, options));
}


PUBLIC void espDivision(HttpConn *conn, cchar *body, cchar *optionString) 
{
    MprHash     *options;

    options = httpGetOptions(optionString);
    espRender(conn, "<div%s>%s</div>", map(conn, options), body);
}


/*
    dropdown("priority", makeGrid("[{ id: 0, low: 0}, { id: 1, med: 1}, {id: 2, high: 2}]"), 0)
    dropdown("priority", makeGrid("[{ low: 0}, { med: 1}, {high: 2}]"), 0)
    dropdown("priority", makeGrid("[0, 10, 100]"), 0)

    Options can provide the defaultValue in a "value" property.
 */
PUBLIC void espDropdown(HttpConn *conn, cchar *field, EdiGrid *choices, cchar *optionString) 
{
    EdiRec      *rec;
    MprHash     *options;
    cchar       *id, *currentValue, *selected, *value;
    int         r;

    if (choices == 0) {
        return;
    }
    options = httpGetOptions(optionString);
    currentValue = getValue(conn, field, options);
    if (field == 0) {
        field = httpGetOption(options, "field", "id");
    }
    espRender(conn, "<select name='%s'%s>\r\n", field, map(conn, options));
    for (r = 0; r < choices->nrecords; r++) {
        rec = choices->records[r];
        if (rec->nfields == 1) {
            value = rec->fields[0].value;
        } else {
            value = ediGetFieldValue(rec, field);
        }
        if ((id = ediGetFieldValue(choices->records[r], "id")) == 0) {
            id = value;
        }
        selected = (smatch(value, currentValue)) ? " selected='yes'" : "";
        espRender(conn, "        <option value='%s'%s>%s</option>\r\n", id, selected, value);
    }
    espRender(conn, "    </select>");
}


PUBLIC void espIcon(HttpConn *conn, cchar *uri, cchar *optionString)
{
    MprHash     *options;
    EspRoute    *eroute;

    eroute = conn->rx->route->eroute;
    options = httpGetOptions(optionString);
    if (uri == 0) {
        /* Suppress favicon */
        uri = "data:image/x-icon;,";
    } else if (*uri == 0) {
        uri = sjoin("~/", mprGetPathBase(eroute->clientDir), "/images/favicon.ico", NULL);
    }
    espRender(conn, "<link href='%s' rel='shortcut icon'%s />", httpUri(conn, uri), map(conn, options));
}


PUBLIC void espImage(HttpConn *conn, cchar *uri, cchar *optionString)
{
    MprHash     *options;

    options = httpGetOptions(optionString);
    espRender(conn, "<img src='%s'%s />", httpUri(conn, uri), map(conn, options));
}


PUBLIC void espLabel(HttpConn *conn, cchar *text, cchar *optionString)
{
    MprHash     *options;

    options = httpGetOptions(optionString);
    espRender(conn, "<span%s>%s</span>", map(conn, options), text);
}


PUBLIC void espMail(HttpConn *conn, cchar *name, cchar *address, cchar *optionString) 
{
    MprHash     *options;

    options = httpGetOptions(optionString);
    espRender(conn, "<a href='mailto:%s'%s>%s</a>", address, map(conn, options), name);
}


PUBLIC void espProgress(HttpConn *conn, cchar *percent, cchar *optionString)
{
    MprHash     *options;
   
    options = httpGetOptions(optionString);
    httpAddOption(options, EDATA("progress"), percent);
    espRender(conn, "<div class='" ESTYLE("progress") "'>\r\n");
    espRender(conn, "    <div class='" ESTYLE("progress-inner") "'%s>%s %%</div>\r\n</div>", map(conn, options), percent);
}


/*
    radio("priority", "{low: 0, med: 1, high: 2}", NULL)
    radio("priority", "{low: 0, med: 1, high: 2}", "{value:'2'}")
 */
PUBLIC void espRadio(HttpConn *conn, cchar *field, cchar *choicesString, cchar *optionsString)
{
    MprKey      *kp;
    MprHash     *choices, *options;
    cchar       *value, *checked;

    choices = httpGetOptions(choicesString);
    options = httpGetOptions(optionsString);
    value = getValue(conn, field, options);
    for (kp = 0; (kp = mprGetNextKey(choices, kp)) != 0; ) {
        checked = (smatch(kp->data, value)) ? " checked" : "";
        espRender(conn, "%s <input type='radio' name='%s' value='%s'%s%s />\r\n", 
            spascal(kp->key), field, kp->data, checked, map(conn, options));
    }
}


/*
    Control the refresh of dynamic elements in the page
 */
PUBLIC void espRefresh(HttpConn *conn, cchar *on, cchar *off, cchar *optionString)
{
    MprHash     *options;
   
    options = httpGetOptions(optionString);
    espRender(conn, "<img src='%s' " EDATA("on") "='%s' " EDATA("off") "='%s%s' class='" ESTYLE("refresh") "' />", on, on, off, map(conn, options));
}


PUBLIC void espScript(HttpConn *conn, cchar *uri, cchar *optionString)
{
    MprHash     *options;
    cchar       *indent, *newline, *path;
    EspScript   *sp;
    EspRoute    *eroute;
    bool        minified;
   
    eroute = conn->rx->route->eroute;
    options = httpGetOptions(optionString);
    if (uri) {
        espRender(conn, "<script src='%s' type='text/javascript'></script>", httpUri(conn, uri));
    } else {
        minified = smatch(httpGetOption(options, "minified", 0), "true");
        indent = "";
        for (sp = defaultScripts; sp->name; sp++) {
            if (sp->option && !smatch(httpGetOption(options, sp->option, "false"), "true")) {
                continue;
            }
            if (sp->flags & SCRIPT_IE) {
                espRender(conn, "%s<!-- [if lt IE 9]>\n", indent);
            }
            path = sjoin("~/", mprGetPathBase(eroute->clientDir), sp->name, minified ? ".min.js" : ".js", NULL);
            uri = httpUri(conn, path);
            newline = sp[1].name ? "\r\n" :  "";
            espRender(conn, "%s<script src='%s' type='text/javascript'></script>%s", indent, uri, newline);
            if (sp->flags & SCRIPT_IE) {
                espRender(conn, "%s<![endif]-->\n", indent);
            }
            indent = "    ";
        }
    }
}


PUBLIC void espStylesheet(HttpConn *conn, cchar *uri, cchar *optionString) 
{
    EspRoute    *eroute;
    MprHash     *options;
    cchar       *indent, *newline;
    char        **up;
    bool        less;
   
    eroute = conn->rx->route->eroute;
    if (uri) {
        espRender(conn, "<link rel='stylesheet' type='text/css' href='%s' />", httpUri(conn, uri));
    } else {
        indent = "";
        options = httpGetOptions(optionString);
        less = smatch(httpGetOption(options, "type", "css"), "less");
        up = less ? defaultLess : defaultCss;
        for (; *up; up++) {
            uri = httpUri(conn, sjoin("~/", mprGetPathBase(eroute->clientDir), *up, NULL));
            newline = up[1] ? "\r\n" :  "";
            espRender(conn, "%s<link rel='stylesheet%s' type='text/css' href='%s' />%s", indent, less ? "/less" : "", uri, newline);
            indent = "    ";
        }
    }
}


/*
    Grid is modified. Columns are removed and sorted as required.
 */
static void filterCols(EdiGrid *grid, MprHash *options, MprHash *colOptions)
{
    MprList     *gridCols;
    MprHash     *cp;
    EdiRec      *rec;
    EdiField    f;
    cchar       *columnName;
    char        key[8];
    int         ncols, r, fnum, currentPos, c, index, *desired, *location, pos, t;

    gridCols = ediGetGridColumns(grid);

    if (colOptions) {
        /*
            Sort grid record columns into the order specified by the column options
         */
        ncols = grid->records[0]->nfields;
        location = mprAlloc(sizeof(int) * ncols);
        for (c = 0; c < ncols; c++) {
            location[c] = c;
        }
        ncols = mprGetHashLength(colOptions);
        desired = mprAlloc(sizeof(int) * ncols);
        for (c = 0; c < ncols; c++) {
            cp = mprLookupKey(colOptions, itosbuf(key, sizeof(key), c, 10));
            if ((columnName = mprLookupKey(cp, "name")) == 0) {
                mprError("Cannot locate \"name\" field for column in table");
                return;
            }
            pos = mprLookupStringItem(gridCols, columnName);
            if (pos < 0) {
                mprError("Cannot find column \"%s\", columns: %s", columnName, mprListToString(gridCols, ", "));
            } else {
                desired[c] = pos;
                location[c] = c;
            }
        }
        for (c = 0; c < ncols; c++) {
            fnum = c;
            for (r = 0; r < grid->nrecords; r++) {
                rec = grid->records[r];
                rec->nfields = ncols;
                fnum = desired[c];
                if (fnum < 0) {
                    continue;
                }
                currentPos = location[fnum];

                f = rec->fields[c];
                rec->fields[c] = rec->fields[currentPos];
                rec->fields[currentPos] = f;
            }
            t = location[c];
            location[c] = location[fnum];
            location[fnum] = t;
        }
        
    } else {
        /*
            If showId is false, remove the "id" column
         */
        if (httpOption(options, "showId", "false", 0) && (index = mprLookupStringItem(gridCols, "id")) >= 0) {
            for (r = 0; r < grid->nrecords; r++) {
                rec = grid->records[r];
                rec->nfields--;
                mprMemcpy(rec->fields, sizeof(EdiField) * rec->nfields, &rec->fields[index],
                    sizeof(EdiField) * (rec->nfields - 1));
            }
        }
    }
}


static char *hashToString(MprHash *hash, cchar *sep)
{
    MprBuf  *buf;
    cchar   *data;
    char    key[8];
    int     i, len;

    len = mprGetHashLength(hash);
    buf = mprCreateBuf(0, 0);
    mprPutCharToBuf(buf, '{');
    for (i = 0; i < len; ) {
        data = mprLookupKey(hash, itosbuf(key, sizeof(key), i, 10));
        mprPutStringToBuf(buf, data);
        if (++i < len) {
            mprPutStringToBuf(buf, sep ? sep : ",");
        }
    }
    mprPutCharToBuf(buf, '}');
    mprAddNullToBuf(buf);
    return mprGetBufStart(buf);
}


static EdiGrid *hashToGrid(MprHash *hash)
{
    EdiGrid *grid;
    EdiRec  *rec;
    cchar   *data;
    char    key[8];
    int     i, len;

    len = mprGetHashLength(hash);
    grid = ediCreateBareGrid(NULL, "grid", len);
    for (i = 0; i < len; i++) {
        data = mprLookupKey(hash, itosbuf(key, sizeof(key), i, 10));
        grid->records[i] = rec = ediCreateBareRec(NULL, "grid", 1);
        rec->fields[0].name = sclone("value");
        rec->fields[0].type = EDI_TYPE_STRING;
        rec->fields[0].value = data;
    }
    return grid;
}


/*
    Render a table from a data grid

    Examples:

        table(grid, "{ refresh:'@update', period:'1000', pivot:'true' }");
        table(grid, "{ click:'@edit' }");
        table(grid, "columns: [ \
            { name: product, header: 'Product', width: '20%' }, \
            { name: date,    format: '%m-%d-%y' }, \
            { name: 'user.name' }, \
        ]");
        table(readTable("users"));
        table(makeGrid("[{'name': 'peter', age: 23 }, {'name': 'mary', age: 22}]")
        table(grid, "{ \
            columns: [ \
                { name: 'speed',         header: 'Speed', dropdown: [100, 1000, 40000] }, \
                { name: 'adminMode',     header: 'Admin Mode', radio: ['Up', 'Down'] }, \
                { name: 'state',         header: 'State', radio: ['Enabled', 'Disabled'] }, \
                { name: 'autoNegotiate', header: 'Auto Negotiate', checkbox: ['enabled'] }, \
                { name: 'type',          header: 'Type' }, \
            ], \
            edit: true, \
            pivot: true, \
            showHeader: false, \
            class: 'esp-pivot', \
        }");

 */
static void pivotTable(HttpConn *conn, EdiGrid *grid, MprHash *options)
{
    MprHash     *colOptions, *rowOptions, *thisCol, *dropdown, *radio;
    MprList     *cols;
    EdiRec      *rec;
    EdiField    *fp;
    cchar       *title, *width, *o, *header, *name, *checkbox;
    char        index[8];
    int         c, r, ncols;
   
    assert(grid);
    if (grid->nrecords == 0) {
        espRender(conn, "<p>No Data</p>\r\n");
        return;
    }
    colOptions = httpGetOptionHash(options, "columns");
    cols = ediGetGridColumns(grid);
    ncols = mprGetListLength(cols);
    rowOptions = mprCreateHash(0, MPR_HASH_STABLE);
    httpSetOption(rowOptions, EDATA("click"), httpGetOption(options, EDATA("click"), 0));
    httpInsertOption(options, "class", ESTYLE("pivot"));
    httpInsertOption(options, "class", ESTYLE("table"));
    espRender(conn, "<table%s>\r\n", map(conn, options));

    /*
        Table header
     */
    if (httpOption(options, "showHeader", "true", 1)) {
        espRender(conn, "    <thead>\r\n");
        if ((title = httpGetOption(options, "title", 0)) != 0) {
            espRender(conn, "        <tr class='" ESTYLE("table-title") "'><td colspan='%s'>%s</td></tr>\r\n", 
                mprGetListLength(cols), title);
        }
        espRender(conn, "        <tr class='" ESTYLE("header") "'>\r\n");
        rec = grid->records[0];
        for (r = 0; r < ncols; r++) {
            assert(r <= grid->nrecords);
            width = ((o = httpGetOption(options, "width", 0)) != 0) ? sfmt(" width='%s'", o) : "";
            thisCol = mprLookupKey(colOptions, itosbuf(index, sizeof(index), r, 10));
            header = httpGetOption(thisCol, "header", spascal(rec->id));
            espRender(conn, "            <th%s>%s</th>\r\n", width, header);
        }
        espRender(conn, "        </tr>\r\n    </thead>\r\n");
    }
    espRender(conn, "    <tbody>\r\n");

    /*
        Table body data
     */
    for (r = 0; r < grid->nrecords; r++) {
        rec = grid->records[r];
        httpSetOption(rowOptions, "id", rec->id);
        espRender(conn, "        <tr%s>\r\n", map(conn, rowOptions));
        for (c = 0; c < ncols; c++) {
            fp = &rec->fields[c];
            thisCol = mprLookupKey(colOptions, itosbuf(index, sizeof(index), r, 10));
            if (httpGetOption(thisCol, "align", 0) == 0) {
                if (fp->type == EDI_TYPE_INT || fp->type == EDI_TYPE_FLOAT) {
                    if (!thisCol) {
                        thisCol = mprCreateHash(0, MPR_HASH_STABLE);
                    }
                    httpInsertOption(thisCol, "align", "right");
                }
            }
            if (c == 0) {
                /* 
                    Render column name
                 */
                name = httpGetOption(thisCol, "header", spascal(rec->id));
                if (httpOption(options, "edit", "true", 0) && httpOption(thisCol, "edit", "true", 1)) {
                    espRender(conn, "            <td%s>%s</td><td>", map(conn, thisCol), name);
                    if ((dropdown = httpGetOption(thisCol, "dropdown", 0)) != 0) {
                        espDropdown(conn, fp->name, hashToGrid(dropdown), 0);
                    } else if ((radio = httpGetOption(thisCol, "radio", 0)) != 0) {
                        espRadio(conn, fp->name, hashToString(radio, 0), 0);
                    } else if ((checkbox = httpGetOption(thisCol, "checkbox", 0)) != 0) {
                        espCheckbox(conn, fp->name, checkbox, 0);
                    } else {
                        input(fp->name, 0);
                    }
                    espRender(conn, "</td>\r\n");
                } else {
                    espRender(conn, "            <td%s>%s</td><td>%s</td>\r\n", map(conn, thisCol), name, fp->value);
                }                
            } else {
                espRender(conn, "            <td%s>%s</td>\r\n", map(conn, thisCol), fp->value);
            }
        }
    }
    espRender(conn, "        </tr>\r\n");
    espRender(conn, "    </tbody>\r\n</table>\r\n");
}


PUBLIC void espTable(HttpConn *conn, EdiGrid *grid, cchar *optionString)
{
    MprHash     *options, *colOptions, *rowOptions, *thisCol;
    MprList     *cols;
    EdiRec      *rec;
    EdiField    *fp;
    cchar       *title, *width, *o, *header, *value, *sortColumn;
    char        index[8];
    int         c, r, ncols, sortOrder;
   
    assert(grid);
    if (grid == 0) {
        return;
    }
    options = httpGetOptions(optionString);
    if (grid->nrecords == 0) {
        espRender(conn, "<p>No Data</p>\r\n");
        return;
    }
    if (grid->flags & EDI_GRID_READ_ONLY) {
        grid = ediCloneGrid(grid);
    }
    if ((sortColumn = httpGetOption(options, "sort", 0)) != 0) {
        sortOrder = httpOption(options, "sortOrder", "ascending", 1);
        ediSortGrid(grid, sortColumn, sortOrder);
    }
    colOptions = httpGetOptionHash(options, "columns");

    filterCols(grid, options, colOptions);

    if (httpOption(options, "pivot", "true", 0) != 0) {
        pivotTable(conn, ediPivotGrid(grid, 1), options);
        return;
    }
    cols = ediGetGridColumns(grid);
    ncols = mprGetListLength(cols);
    rowOptions = mprCreateHash(0, MPR_HASH_STABLE);

    httpSetOption(rowOptions, EDATA("click"), httpGetOption(options, EDATA("click"), 0));
    httpRemoveOption(options, EDATA("click"));
    httpSetOption(rowOptions, EDATA("remote"), httpGetOption(options, EDATA("remote"), 0));
    httpSetOption(rowOptions, EDATA("key"), httpGetOption(options, EDATA("key"), 0));
    httpSetOption(rowOptions, EDATA("params"), httpGetOption(options, EDATA("params"), 0));
    httpSetOption(rowOptions, EDATA("edit"), httpGetOption(options, EDATA("edit"), 0));

    httpInsertOption(options, "class", ESTYLE("table"));
    httpInsertOption(options, "class", ESTYLE("stripe"));
    espRender(conn, "<table%s>\r\n", map(conn, options));

    /*
        Table header
     */
    if (httpOption(options, "showHeader", "true", 1)) {
        espRender(conn, "    <thead>\r\n");
        if ((title = httpGetOption(options, "title", 0)) != 0) {
            espRender(conn, "        <tr class='" ESTYLE("table-title") "'><td colspan='%s'>%s</td></tr>\r\n", 
                mprGetListLength(cols), title);
        }
        espRender(conn, "        <tr class='" ESTYLE("table-header") "'>\r\n");
        rec = grid->records[0];
        for (c = 0; c < ncols; c++) {
            assert(c <= rec->nfields);
            fp = &rec->fields[c];
            width = ((o = httpGetOption(options, "width", 0)) != 0) ? sfmt(" width='%s'", o) : "";
            thisCol = mprLookupKey(colOptions, itosbuf(index, sizeof(index), c, 10));
            header = httpGetOption(thisCol, "header", spascal(fp->name));
            espRender(conn, "            <th%s>%s</th>\r\n", width, header);
        }
        espRender(conn, "        </tr>\r\n    </thead>\r\n");
    }
    espRender(conn, "    <tbody>\r\n");

    /*
        Table body data
     */
    for (r = 0; r < grid->nrecords; r++) {
        rec = grid->records[r];
        httpSetOption(rowOptions, "id", rec->id);
        espRender(conn, "        <tr%s>\r\n", map(conn, rowOptions));
        for (c = 0; c < ncols; c++) {
            fp = &rec->fields[c];
            thisCol = mprLookupKey(colOptions, itosbuf(index, sizeof(index), c, 10));

            if (httpGetOption(thisCol, "align", 0) == 0) {
                if (fp->type == EDI_TYPE_INT || fp->type == EDI_TYPE_FLOAT) {
                    if (!thisCol) {
                        thisCol = mprCreateHash(0, MPR_HASH_STABLE);
                    }
                    httpInsertOption(thisCol, "align", "right");
                }
            }
            value = formatValue(fp, thisCol);
            espRender(conn, "            <td%s>%s</td>\r\n", map(conn, thisCol), value);
        }
        espRender(conn, "        </tr>\r\n");
    }
    espRender(conn, "    </tbody>\r\n</table>\r\n");
}


/*
    tabs(makeGrid("[{ name: 'Status', uri: 'pane-1' }, { name: 'Edit', uri: 'pane-2' }]"))

    Options:
        click
        toggle
        remote
 */
PUBLIC void espTabs(HttpConn *conn, EdiGrid *grid, cchar *optionString)
{
    MprHash     *options;
    EdiRec      *rec;
    cchar       *attr, *uri, *name, *klass;
    int         r, toggle;

    options = httpGetOptions(optionString);
    httpInsertOption(options, "class", ESTYLE("tabs"));

    attr = httpGetOption(options, "toggle", EDATA("click"));
    if ((toggle = smatch(attr, "true")) != 0) {
        attr = EDATA("toggle");
    }
    espRender(conn, "<div%s>\r\n    <ul>\r\n", map(conn, options));
    for (r = 0; r < grid->nrecords; r++) {
        rec = grid->records[r];
        name = ediGetFieldValue(rec, "name");
        uri = ediGetFieldValue(rec, "uri");
        uri = toggle ? uri : httpUri(conn, uri);
        if ((r == 0 && toggle) || smatch(uri, conn->rx->pathInfo)) {
            klass = smatch(uri, conn->rx->pathInfo) ? " class='esp-selected'" : "";
        } else {
            klass = "";
        }
        espRender(conn, "          <li %s='%s'%s>%s</li>\r\n", attr, uri, klass, name);
    }
    espRender(conn, "        </ul>\r\n    </div>\r\n");
}


static void textInner(HttpConn *conn, cchar *field, MprHash *options)
{
    cchar   *rows, *cols, *type, *value;

    type = "text";
    value = getValue(conn, field, options);
    if (value == 0 || *value == '\0') {
        value = espGetParam(conn, field, "");
    }
    if (httpGetOption(options, "password", 0)) {
        type = "password";
    } else if (httpGetOption(options, "hidden", 0)) {
        type = "hidden";
    }
    if ((rows = httpGetOption(options, "rows", 0)) != 0) {
        cols = httpGetOption(options, "cols", "60");
        espRender(conn, "<textarea name='%s' type='%s' cols='%s' rows='%s'%s>%s</textarea>", field, type, 
            cols, rows, map(conn, options), value);
    } else {
          espRender(conn, "<input name='%s' type='%s' value='%s'%s />", field, type, value, map(conn, options));
    }
}


PUBLIC void espText(HttpConn *conn, cchar *field, cchar *optionString)
{
    textInner(conn, field, httpGetOptions(optionString));
}


/************************************ Abbreviated API *********************************/ 

PUBLIC void alert(cchar *text, cchar *optionString)
{
    espAlert(getConn(), text, optionString);
}


PUBLIC void anchor(cchar *text, cchar *uri, cchar *optionString) 
{
    espAnchor(getConn(), text, uri, optionString);
}


PUBLIC void button(cchar *name, cchar *value, cchar *optionString)
{
    espButton(getConn(), name, value, optionString);
}


PUBLIC void buttonLink(cchar *text, cchar *uri, cchar *optionString)
{
    espButtonLink(getConn(), text, uri, optionString);
}


PUBLIC void checkbox(cchar *field, cchar *checkedValue, cchar *optionString) 
{
    espCheckbox(getConn(), field, checkedValue, optionString);
}


PUBLIC void division(cchar *body, cchar *optionString) 
{
    espDivision(getConn(), body, optionString);
}

PUBLIC void endform() 
{
    renderString("</form>");
}


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


PUBLIC void form(EdiRec *record, cchar *optionString)
{
    HttpConn    *conn;
    EspReq      *req;
    MprHash     *options;
    cchar       *action, *recid, *method, *uri, *token;
   
    conn = getConn();
    if (record == 0) {
        record = getRec();
    } else {
        conn->record = record;
    }
    req = conn->data;
    options = httpGetOptions(optionString);
    recid = 0;

    /*
        If record provided, get the record id. Can be overridden using options.recid
     */
    if (record) {
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
    uri = httpUri(conn, action);

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
            token = httpGetSecurityToken(conn);
        }
        espRender(conn, "    <input name='%s' type='hidden' value='%s' />\r\n", BIT_XSRF_PARAM, token);
    }
}


PUBLIC void icon(cchar *uri, cchar *optionString)
{
    espIcon(getConn(), uri, optionString);
}


PUBLIC void image(cchar *src, cchar *optionString)
{
    espImage(getConn(), src, optionString);
}


PUBLIC void inform(cchar *fmt, ...)
{
    va_list     args;

    va_start(args, fmt);
    espSetFlashv(getConn(), "inform", fmt, args);
    va_end(args);
}


PUBLIC void label(cchar *text, cchar *optionString)
{
    espLabel(getConn(), text, optionString);
}


PUBLIC void dropdown(cchar *name, EdiGrid *choices, cchar *optionString) 
{
    espDropdown(getConn(), name, choices, optionString);
}


PUBLIC void mail(cchar *name, cchar *address, cchar *optionString) 
{
    espMail(getConn(), name, address, optionString);
}


PUBLIC void progress(cchar *data, cchar *optionString)
{
    espProgress(getConn(), data, optionString);
}


/*
    radio("priority", "{low: 0, med: 1, high: 2}", NULL)
    radio("priority", "{low: 0, med: 1, high: 2}", "{value:'2'}")
 */
PUBLIC void radio(cchar *name, void *choices, cchar *optionString)
{
    espRadio(getConn(), name, choices, optionString);
}


PUBLIC void refresh(cchar *on, cchar *off, cchar *optionString)
{
    espRefresh(getConn(), on, off, optionString);
}


PUBLIC void script(cchar *uri, cchar *optionString)
{
    espScript(getConn(), uri, optionString);
}


PUBLIC void stylesheet(cchar *uri, cchar *optionString) 
{
    espStylesheet(getConn(), uri, optionString);
}


PUBLIC void table(EdiGrid *grid, cchar *optionString)
{
    if (grid == 0) {
        grid = getGrid();
    }
    espTable(getConn(), grid, optionString);
}


PUBLIC void tabs(EdiGrid *grid, cchar *optionString)
{
    espTabs(getConn(), grid, optionString);
}


PUBLIC void text(cchar *field, cchar *optionString)
{
    espText(getConn(), field, optionString);
}

/**************************************** Support *************************************/ 

static cchar *escapeValue(cchar *value, MprHash *options)
{
    if (httpGetOption(options, "escape", 0)) {
        return mprEscapeHtml(value);
    }
    return value;
}


static cchar *formatValue(EdiField *fp, MprHash *options)
{
    return ediFormatField(httpGetOption(options, "format", 0), fp);
}


static cchar *getValue(HttpConn *conn, cchar *fieldName, MprHash *options)
{
    EspReq      *req;
    EdiRec      *record;
    MprKey      *field;
    cchar       *value, *msg;

    req = conn->data;
    record = conn->record;
    value = 0;

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
                value = httpUriEx(conn, value, options);
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

    esp->internalOptions = mprCreateHash(-1, MPR_HASH_STATIC_VALUES);
    for (op = internalOptions; *op; op++) {
        mprAddKey(esp->internalOptions, *op, op);
    }
}

#endif /* BIT_PACK_ESP && BIT_ESP_LEGACY */
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
