/*
    sdb.c -- SQLite Database (SDB)

    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */

/********************************** Includes **********************************/

#include    "appweb.h"

#if BIT_PACK_ESP && BIT_PACK_SDB
 #include    "edi.h"
 #include    "sqlite3.h"

#ifndef BIT_MAX_SQLITE_MEM
    #define BIT_MAX_SQLITE_MEM      (2*1024*1024)   /**< Maximum buffering for Sqlite */
#endif
#ifndef BIT_MAX_SQLITE_DURATION
    #define BIT_MAX_SQLITE_DURATION 30000           /**< Database busy timeout */
#endif

/************************************* Local **********************************/

typedef struct Sdb {
    Edi             edi;            /**< EDI database interface structure */
    sqlite3         *db;            /**< SQLite database handle */
    MprHash         *validations;   /**< Validations */
    MprHash         *schemas;       /**< Table schemas */
} Sdb;

static int sqliteInitialized;
static void initSqlite();

#if UNUSED && KEEP
static char *DataTypeToSqlType[] = {
    "binary":       "blob",
    "boolean":      "tinyint",
    "date":         "date",
    "datetime":     "datetime",
    "decimal":      "decimal",
    "float":        "float",
    "integer":      "int",
    "number":       "decimal",
    "string":       "varchar",
    "text":         "text",
    "time":         "time",
    "timestamp":    "datetime",
    0, 0, 
};
#endif

static char *dataTypeToSqlType[] = {
                            0,
    /* EDI_TYPE_BINARY */   "BLOB",
    /* EDI_TYPE_BOOL */     "TINYINT",      //  "INTEGER",
    /* EDI_TYPE_DATE */     "DATE",         //  "TEXT",
    /* EDI_TYPE_FLOAT */    "FLOAT",        //  "REAL",
    /* EDI_TYPE_INT */      "INTEGER",
    /* EDI_TYPE_STRING */   "STRING",       //  "TEXT",
    /* EDI_TYPE_TEXT */     "TEXT",
                            0,
};

/************************************ Forwards ********************************/

static EdiRec *createBareRec(Edi *edi, cchar *tableName, int nfields);
static EdiField makeRecField(cchar *value, cchar *name, int type);
static void manageSdb(Sdb *sdb, int flags);
static int mapQueryToEdiType(int type);
static cchar *mapToSqlType(int type);
static int mapToEdiType(cchar *type);
static EdiGrid *query(Edi *edi, cchar *cmd);
static int sdbAddColumn(Edi *edi, cchar *tableName, cchar *columnName, int type, int flags);
static int sdbAddIndex(Edi *edi, cchar *tableName, cchar *columnName, cchar *indexName);
static int sdbAddTable(Edi *edi, cchar *tableName);
static int sdbAddValidation(Edi *edi, cchar *tableName, cchar *fieldName, EdiValidation *vp);
static int sdbChangeColumn(Edi *edi, cchar *tableName, cchar *columnName, int type, int flags);
static void sdbClose(Edi *edi);
static EdiRec *sdbCreateRec(Edi *edi, cchar *tableName);
static int sdbDelete(cchar *path);
static int sdbDeleteRow(Edi *edi, cchar *tableName, cchar *key);
static MprList *sdbGetColumns(Edi *edi, cchar *tableName);
static int sdbGetColumnSchema(Edi *edi, cchar *tableName, cchar *columnName, int *type, int *flags, int *cid);
static MprList *sdbGetTables(Edi *edi);
static int sdbGetTableSchema(Edi *edi, cchar *tableName, int *numRows, int *numCols);
static int sdbLookupField(Edi *edi, cchar *tableName, cchar *fieldName);
static Edi *sdbOpen(cchar *path, int flags);
static EdiGrid *sdbQuery(Edi *edi, cchar *cmd);
static EdiField sdbReadField(Edi *edi, cchar *tableName, cchar *key, cchar *fieldName);
static EdiRec *sdbReadRec(Edi *edi, cchar *tableName, cchar *key);
static EdiGrid *sdbReadWhere(Edi *edi, cchar *tableName, cchar *columnName, cchar *operation, cchar *value);
static int sdbRemoveColumn(Edi *edi, cchar *tableName, cchar *columnName);
static int sdbRemoveIndex(Edi *edi, cchar *tableName, cchar *indexName);
static int sdbRemoveTable(Edi *edi, cchar *tableName);
static int sdbRenameTable(Edi *edi, cchar *tableName, cchar *newTableName);
static int sdbRenameColumn(Edi *edi, cchar *tableName, cchar *columnName, cchar *newColumnName);
static int sdbSave(Edi *edi);
static int sdbUpdateField(Edi *edi, cchar *tableName, cchar *key, cchar *fieldName, cchar *value);
static int sdbUpdateRec(Edi *edi, EdiRec *rec);
static bool sdbValidateRec(Edi *edi, EdiRec *rec);
static bool validateField(Sdb *sdb, EdiRec *rec, cchar *tableName, cchar *columnName, cchar *value);

static EdiProvider SdbProvider = {
    "sdb",
    sdbAddColumn, sdbAddIndex, sdbAddTable, sdbAddValidation, sdbChangeColumn, sdbClose, sdbCreateRec, sdbDelete, 
    sdbDeleteRow, sdbGetColumns, sdbGetColumnSchema, sdbGetTables, sdbGetTableSchema, NULL, sdbLookupField, 
    sdbOpen, sdbQuery, sdbReadField, sdbReadRec, sdbReadWhere, sdbRemoveColumn, sdbRemoveIndex, sdbRemoveTable, 
    sdbRenameTable, sdbRenameColumn, sdbSave, sdbUpdateField, sdbUpdateRec, sdbValidateRec,
};

/************************************* Code ***********************************/

PUBLIC void sdbInit()
{
    ediAddProvider(&SdbProvider);
}


static Sdb *sdbCreate(cchar *path, int flags)
{
    Sdb      *sdb;

    assert(path && *path);

    initSqlite();
    if ((sdb = mprAllocObj(Sdb, manageSdb)) == 0) {
        return 0;
    }
    sdb->edi.flags = flags;
    sdb->edi.provider = &SdbProvider;
    sdb->edi.path = sclone(path);
    sdb->schemas = mprCreateHash(0, MPR_HASH_STABLE);
    sdb->validations = mprCreateHash(0, MPR_HASH_STABLE);
    return sdb;
}


static void manageSdb(Sdb *sdb, int flags)
{
    if (flags & MPR_MANAGE_MARK) {
        mprMark(sdb->edi.path);
        mprMark(sdb->schemas);
        mprMark(sdb->validations);
    } else if (flags & MPR_MANAGE_FREE) {
        sdbClose((Edi*) sdb);
    }
}


static void sdbClose(Edi *edi)
{
    Sdb     *sdb;

    assert(edi);

    sdb = (Sdb*) edi;
    if (sdb->db) {
        sqlite3_close(sdb->db);
        sdb->db = 0;
    }
}


static void removeSchema(Edi *edi, cchar *tableName)
{
    mprRemoveKey(((Sdb*) edi)->schemas, tableName);
}


static EdiRec *getSchema(Edi *edi, cchar *tableName)
{
    Sdb         *sdb;
    EdiRec      *rec, *schema;
    EdiField    *fp;
    EdiGrid     *grid;
    int         r;

    sdb = (Sdb*) edi;
    if ((schema = mprLookupKey(sdb->schemas, tableName)) != 0) {
        return schema;
    }
    /*
        Each result row represents an EDI column: CID, Name, Type, NotNull, Dflt_value, PK
     */
    if ((grid = sdbQuery(edi, sfmt("PRAGMA table_info(\"%s\");", tableName))) == 0) {
        return 0;
    }
    schema = createBareRec(edi, tableName, grid->nrecords);
    for (r = 0; r < grid->nrecords; r++) {
        rec = grid->records[r];
        fp = &schema->fields[r];
        fp->name = rec->fields[1].value;
        fp->type = mapToEdiType(rec->fields[2].value);
        if (rec->fields[5].value && rec->fields[5].value[0] == '1') {
            //  MOB - NOT_NULL, AUTO_INC ...
            //  MOB - should have separeate field for ID
            //  MOB - is ID always first?
            fp->flags = EDI_KEY;
        }
    }
    mprAddKey(sdb->schemas, tableName, schema);
    return schema;
}


static EdiRec *sdbCreateRec(Edi *edi, cchar *tableName)
{
    EdiRec  *rec, *schema;
    int     i;

    schema = getSchema(edi, tableName);
    if ((rec = mprAllocMem(sizeof(EdiRec) + sizeof(EdiField) * schema->nfields, MPR_ALLOC_MANAGER | MPR_ALLOC_ZERO)) == 0) {
        return 0;
    }
    mprSetManager(rec, (MprManager) ediManageEdiRec);
    rec->edi = edi;
    rec->tableName = sclone(tableName);
    rec->nfields = schema->nfields;
    for (i = 0; i < schema->nfields; i++) {
        rec->fields[i].name = schema->fields[i].name;
        rec->fields[i].type = schema->fields[i].type;
        rec->fields[i].flags = schema->fields[i].flags;
    }
    return rec;
}


static int sdbDelete(cchar *path)
{
    assert(path && *path);
    return mprDeletePath(path);
}


static Edi *sdbOpen(cchar *path, int flags)
{
    Sdb     *sdb;

    assert(path && *path);
    if ((sdb = sdbCreate(path, flags)) == 0) {
        return 0;
    }
    if (mprPathExists(path, R_OK) || (flags & EDI_CREATE)) {
        if (sqlite3_open(path, &sdb->db) != SQLITE_OK) {
            mprError("Cannot open database %s", path);
            return 0;
        }
        sqlite3_soft_heap_limit(BIT_MAX_SQLITE_MEM);
        sqlite3_busy_timeout(sdb->db, BIT_MAX_SQLITE_DURATION);
    } else {
        return 0;
    }
    return (Edi*) sdb;
}


static int sdbAddColumn(Edi *edi, cchar *tableName, cchar *columnName, int type, int flags)
{
    assert(edi);
    assert(tableName && *tableName);
    assert(columnName && *columnName);
    assert(type > 0);

    if (sdbLookupField(edi, tableName, columnName) >= 0) {
        /* Already exists */
        return 0;
    }
    removeSchema(edi, tableName);
    /*
        The field types are used for the SQLite column affinity settings
     */
    //  MOB - what about autinc, notnul, index, foreign flags?
    if (query(edi, sfmt("ALTER TABLE %s ADD %s %s", tableName, columnName, mapToSqlType(type))) == 0) {
        return MPR_ERR_CANT_CREATE;
    }
    return 0;
}


static int sdbAddIndex(Edi *edi, cchar *tableName, cchar *columnName, cchar *indexName)
{
    assert(edi);
    assert(tableName && *tableName);
    assert(columnName && *columnName);
    assert(indexName && *indexName);

    return query(edi, sfmt("CREATE INDEX %s ON %s (%s);", indexName, tableName, columnName)) != 0;
}


static int sdbAddTable(Edi *edi, cchar *tableName)
{
    assert(edi);
    assert(tableName && *tableName);

    if (query(edi, sfmt("DROP TABLE IF EXISTS %s;", tableName)) == 0) {
        return MPR_ERR_CANT_DELETE;
    }
    /*
        SQLite cannot add a primary key after the table is created
     */
    removeSchema(edi, tableName);
    return query(edi, sfmt("CREATE TABLE %s (id INTEGER PRIMARY KEY AUTOINCREMENT NOT NULL);", tableName)) != 0;
}


static int sdbAddValidation(Edi *edi, cchar *tableName, cchar *columnName, EdiValidation *vp)
{
    Sdb             *sdb;
    MprList         *validations;
    EdiValidation   *prior;
    cchar           *vkey;
    int             next;

    assert(edi);
    assert(tableName && *tableName);
    assert(columnName && *columnName);
    assert(vp);

    sdb = (Sdb*) edi;
    vkey = sfmt("%s.%s", tableName, columnName);
    if ((validations = mprLookupKey(sdb->validations, vkey)) == 0) {
        validations = mprCreateList(0, MPR_LIST_STABLE);
        mprAddKey(sdb->validations, vkey, validations);
    }
    for (ITERATE_ITEMS(validations, prior, next)) {
        if (prior->vfn == vp->vfn) {
            break;
        }
    }
    if (!prior) {
        mprAddItem(validations, vp);
    }
    return 0;
}


static int sdbChangeColumn(Edi *edi, cchar *tableName, cchar *columnName, int type, int flags)
{
    mprError("SDB does not support changing columns");
    return MPR_ERR_BAD_STATE;
}


static int sdbDeleteRow(Edi *edi, cchar *tableName, cchar *key)
{
    assert(edi);
    assert(tableName && *tableName);
    assert(key && *key);

    return query(edi, sfmt("DELETE FROM %s WHERE id = '%s';", tableName, key)) != 0;
}


static MprList *sdbGetColumns(Edi *edi, cchar *tableName)
{
    MprList     *result;
    EdiRec      *schema;
    int         c;

    assert(edi);
    assert(tableName && *tableName);
    
    if ((schema = getSchema(edi, tableName)) == 0) {
        return 0;
    }
    if ((result = mprCreateList(0, MPR_LIST_STABLE)) == 0) {
        return 0;
    }
    for (c = 0; c < schema->nfields; c++) {
        mprAddItem(result, schema->fields[c].name);
    }
    return result;
}



static int sdbGetColumnSchema(Edi *edi, cchar *tableName, cchar *columnName, int *type, int *flags, int *cid)
{
    EdiRec      *schema;
    EdiField    *fp;
    int         c;

    assert(edi);
    assert(tableName && *tableName);
    assert(columnName && *columnName);

    schema = getSchema(edi, tableName);
    for (c = 0; c < schema->nfields; c++) {
        fp = &schema->fields[c];
        if (smatch(columnName, fp->name)) {
            if (type) {
                *type = fp->type;
            }
            if (flags) {
                *flags = fp->flags;
            }
            if (cid) {
                *cid = c;
            }
        }
    }
    return 0;
}


static MprList *sdbGetTables(Edi *edi)
{
    EdiGrid     *grid;
    EdiRec      *rec;
    MprList     *result;
    int         r;

    assert(edi);

    if ((grid = sdbQuery(edi, "SELECT name from sqlite_master WHERE type = 'table' order by NAME;")) == 0) {
        return 0;
    }
    if ((result = mprCreateList(0, MPR_LIST_STABLE)) == 0) {
        return 0;
    }
    for (r = 0; r < grid->nrecords; r++) {
        rec = grid->records[r];
        if (sstarts(rec->tableName, "sqlite_")) {
            continue;
        }
        mprAddItem(result, rec->tableName);
    }
    return result;
}


static int sdbGetTableSchema(Edi *edi, cchar *tableName, int *numRows, int *numCols)
{
    EdiGrid     *grid;
    EdiRec      *schema;

    assert(edi);
    assert(tableName && *tableName);

    if (numRows) {
        if ((grid = sdbQuery(edi, "SELECT COUNT(*) FROM ' + table + ';")) == 0) { 
            return MPR_ERR_BAD_STATE;
        }
        *numRows = grid->nrecords;
    }
    if (numCols) {
        if ((schema = getSchema(edi, tableName)) == 0) {
            return MPR_ERR_CANT_FIND;
        }
        *numCols = schema->nfields;
    }
    return 0;
}


static int sdbLookupField(Edi *edi, cchar *tableName, cchar *fieldName)
{
    EdiRec      *schema;
    int         c;

    assert(edi);
    assert(tableName && *tableName);
    assert(fieldName && *fieldName);
    
    if ((schema = getSchema(edi, tableName)) == 0) {
        return 0;
    }
    for (c = 0; c < schema->nfields; c++) {
        /* Name is second field */
        if (smatch(fieldName, schema->fields[c].name)) {
            return c;
        }
    }
    return MPR_ERR_CANT_FIND;
}


static EdiGrid *query(Edi *edi, cchar *cmd)
{
    Sdb             *sdb;
    sqlite3         *db;
    sqlite3_stmt    *stmt;
    EdiGrid         *grid;
    EdiRec          *rec;
    MprList         *result;
    char            *tableName;
    cchar           *tail, *colName, *value, *defaultTableName;
    ssize           len;
    int             r, nrows, i, ncol, rc, retries, type;

    assert(edi);
    assert(cmd && *cmd);

    sdb = (Sdb*) edi;
    retries = 0;
    sdb->edi.errMsg = 0;

    if ((db = sdb->db) == 0) {
        sdb->edi.errMsg = sfmt("Database '%s' is closed", sdb->edi.path);
        mprError(sdb->edi.errMsg);
        return 0;
    }
    if ((result = mprCreateList(0, MPR_LIST_STABLE)) == 0) {
        return 0;
    }
    defaultTableName = 0;
    rc = SQLITE_OK;
    nrows = 0;

    while (cmd && *cmd && (rc == SQLITE_OK || (rc == SQLITE_SCHEMA && ++retries < 2))) {
        stmt = 0;
        mprLog(2, "SQL: %s", cmd);
        rc = sqlite3_prepare_v2(db, cmd, -1, &stmt, &tail);
        if (rc != SQLITE_OK) {
            continue;
        }
        if (stmt == 0) {
            /* Comment or white space */
            cmd = tail;
            continue;
        }
        ncol = sqlite3_column_count(stmt);
        for (nrows = 0; ; nrows++) {
            if (sqlite3_step(stmt) == SQLITE_ROW) {
                tableName = (char*) sqlite3_column_table_name(stmt, 0);
                if ((rec = createBareRec(edi, tableName, ncol)) == 0) {
                    sqlite3_finalize(stmt);
                    return 0;
                }
                if (defaultTableName == 0) {
                    defaultTableName = rec->tableName;
                }
                mprAddItem(result, rec);
                for (i = 0; i < ncol; i++) {
                    colName = sqlite3_column_name(stmt, i);
                    value = (cchar*) sqlite3_column_text(stmt, i);
                    type = sqlite3_column_type(stmt, i);
                    if (tableName && strcmp(tableName, defaultTableName) != 0) {
                        //  MOB - is this required?
                        len = strlen(tableName) + 1;
                        tableName = sjoin("_", tableName, colName, NULL);
                        tableName[len] = toupper((uchar) tableName[len]);
                    }
                    //  MOB - what about flags
                    rec->fields[i] = makeRecField(value, colName, mapQueryToEdiType(type));
                    if (smatch(colName, "id")) {
                        rec->fields[i].flags |= EDI_KEY;
                        rec->id = rec->fields[i].value;
                    }
                }
            } else {
                rc = sqlite3_finalize(stmt);
                stmt = 0;
                if (rc != SQLITE_SCHEMA) {
                    retries = 0;
                    for (cmd = tail; isspace((uchar) *cmd); cmd++) {}
                }
                break;
            }
        }
    }
    if (stmt) {
        rc = sqlite3_finalize(stmt);
    }
    if (rc != SQLITE_OK) {
        if (rc == sqlite3_errcode(db)) {
            sdb->edi.errMsg = (char*) sqlite3_errmsg(db);
        } else {
            sdb->edi.errMsg = sclone("Unspecified SQL error");
        }
        mprLog(1, "SQL error: %s", sdb->edi.errMsg);
        return 0;
    }
    if ((grid = ediCreateBareGrid(edi, defaultTableName, nrows)) == 0) {
        return 0;
    }
    for (r = 0; r < nrows; r++) {
        grid->records[r] = mprGetItem(result, r);
    }
    return grid;
}


static EdiGrid *sdbQuery(Edi *edi, cchar *cmd)
{
    return query(edi, cmd);
}


static EdiField sdbReadField(Edi *edi, cchar *tableName, cchar *key, cchar *fieldName)
{
    EdiGrid     *grid;

    if ((grid = query(edi, sfmt("SELECT %s FROM %s WHERE 'id' = %s;", fieldName, tableName, key))) == 0) {
        EdiField    err;
        err.valid = 0;
        return err;
    }
    return grid->records[0]->fields[0];
}


static EdiRec *sdbReadRec(Edi *edi, cchar *tableName, cchar *key)
{
    EdiGrid     *grid;

    if ((grid = query(edi, sfmt("SELECT * FROM %s WHERE id = %s;", tableName, key))) == 0) {
        return 0;
    }
    return grid->records[0];
}


static EdiGrid *setTableName(EdiGrid *grid, cchar *tableName)
{
    if (grid && !grid->tableName) {
        grid->tableName = sclone(tableName);
    }
    return grid;
}


static EdiGrid *sdbReadWhere(Edi *edi, cchar *tableName, cchar *columnName, cchar *operation, cchar *value)
{
    EdiGrid     *grid;
    
    assert(tableName && *tableName);

    if (columnName) {
        assert(columnName && *columnName);
        assert(operation && *operation);
        assert(value);
        grid = query(edi, sfmt("SELECT * FROM %s WHERE %s %s '%s';", tableName, columnName, operation, value));
    } else {
        grid = query(edi, sfmt("SELECT * FROM %s;", tableName));
    }
    return setTableName(grid, tableName);
}


static int sdbRemoveColumn(Edi *edi, cchar *tableName, cchar *columnName)
{
    mprError("SDB does not support removing columns");
    return MPR_ERR_BAD_STATE;
}


static int sdbRemoveIndex(Edi *edi, cchar *tableName, cchar *indexName)
{
    return query(edi, sfmt("DROP INDEX %s;", indexName)) != 0;
}


static int sdbRemoveTable(Edi *edi, cchar *tableName)
{
    return query(edi, sfmt("DROP TABLE IF EXISTS %s;", tableName)) != 0;
}


static int sdbRenameTable(Edi *edi, cchar *tableName, cchar *newTableName)
{
    removeSchema(edi, tableName);
    removeSchema(edi, newTableName);
    return query(edi, sfmt("ALTER TABLE %s RENAME TO %s;", tableName, newTableName)) != 0;
}


static int sdbRenameColumn(Edi *edi, cchar *tableName, cchar *columnName, cchar *newColumnName)
{
    mprError("SQLite does not support renaming columns");
    return MPR_ERR_BAD_STATE;
}


static int sdbSave(Edi *edi)
{
    return 0;
}


static bool sdbValidateRec(Edi *edi, EdiRec *rec)
{
    Sdb         *sdb;
    EdiField    *fp;
    bool        pass;
    int         c;

    if (!rec) {
        return 0;
    }
    sdb = (Sdb*) edi;
    pass = 1;
    for (c = 0; c < rec->nfields; c++) {
        fp = &rec->fields[c];
        if (!validateField(sdb, rec, rec->tableName, fp->name, fp->value)) {
            pass = 0;
            /* Keep going */
        }
    }
    return pass;
}


static int sdbUpdateField(Edi *edi, cchar *tableName, cchar *key, cchar *fieldName, cchar *value)
{
    return query(edi, sfmt("UPDATE %s SET %s TO %s WHERE 'id' = '%s';", tableName, fieldName, value, key)) != 0;
}


static cchar *prepareValue(EdiField *fp) 
{
    //  MOB -- 
#if FUTURE
    switch (f.type) {
    case EDI_TYPE_BINARY:
    case EDI_TYPE_BOOL:
    case EDI_TYPE_DATE:
    case EDI_TYPE_FLOAT:
    case EDI_TYPE_INT:
    case EDI_TYPE_STRING:
        return f.
    case EDI_TYPE_TEXT:
    default:
    }
#endif
    return fp->value;
}


static int sdbUpdateRec(Edi *edi, EdiRec *rec)
{
    MprBuf      *buf;
    EdiField    *fp;
    int         f;

    if (!sdbValidateRec(edi, rec)) {
        return MPR_ERR_CANT_WRITE;
    }
    buf = mprCreateBuf(0, 0);
    if (rec->id) {
        mprPutToBuf(buf, "UPDATE %s SET ", rec->tableName);
        for (f = 0; f < rec->nfields; f++) {
            fp = &rec->fields[f];
            mprPutToBuf(buf, "%s = '%s'", fp->name, prepareValue(fp));
            mprPutStringToBuf(buf, ", ");
        }
        mprAdjustBufEnd(buf, -2);
        mprPutToBuf(buf, " WHERE id = %s;", rec->id);
    } else {
        mprPutToBuf(buf, "INSERT INTO %s (", rec->tableName);
        for (f = 1; f < rec->nfields; f++) {
            fp = &rec->fields[f];
            mprPutToBuf(buf, "%s,", fp->name);
        }
        mprAdjustBufEnd(buf, -1);
        mprPutStringToBuf(buf, ") VALUES (");
        for (f = 1; f < rec->nfields; f++) {
            fp = &rec->fields[f];
            mprPutToBuf(buf, "'%s',", prepareValue(fp));
        }
        mprAdjustBufEnd(buf, -1);
        mprPutCharToBuf(buf, ')');
    }
    if (rec->id == 0) {
        //  MOB - Is this used anywhere?
        mprPutStringToBuf(buf, "; SELECT last_insert_rowid();");
    }
    if (query(edi, mprGetBufStart(buf)) == 0) {
        return MPR_ERR_CANT_WRITE;
    }
    return 0;
}


PUBLIC cchar *sdbGetLastError(Edi *edi)
{
    return ((Sdb*) edi)->edi.errMsg;
}


/*********************************** Support *******************************/

static bool validateField(Sdb *sdb, EdiRec *rec, cchar *tableName, cchar *columnName, cchar *value)
{
    EdiValidation   *vp;
    MprList         *validations;
    cchar           *error, *vkey;
    int             next;
    bool            pass;

    assert(sdb);
    assert(rec);
    assert(tableName && *tableName);
    assert(columnName && *columnName);

    pass = 1;
    vkey = sfmt("%s.%s", tableName, columnName);
    if ((validations = mprLookupKey(sdb->validations, vkey)) != 0) {
        for (ITERATE_ITEMS(validations, vp, next)) {
            if ((error = (*vp->vfn)(vp, rec, columnName, value)) != 0) {
                if (rec->errors == 0) {
                    rec->errors = mprCreateHash(0, MPR_HASH_STABLE);
                }
                mprAddKey(rec->errors, columnName, sfmt("%s %s", columnName, error));
                pass = 0;
            }
        }
    }
    return pass;
}


static EdiRec *createBareRec(Edi *edi, cchar *tableName, int nfields)
{
    EdiRec  *rec;

    if ((rec = mprAllocMem(sizeof(EdiRec) + sizeof(EdiField) * nfields, MPR_ALLOC_MANAGER | MPR_ALLOC_ZERO)) == 0) {
        return 0;
    }
    mprSetManager(rec, (MprManager) ediManageEdiRec);
    rec->edi = edi;
    rec->tableName = sclone(tableName);
    rec->nfields = nfields;
    return rec;
}


static EdiField makeRecField(cchar *value, cchar *name, int type)
{
    EdiField    f;

    f.valid = 1;
    f.value = sclone(value);
    f.name = sclone(name);
    f.type = type;
    f.flags = 0;
    return f;
}


static void *allocBlock(int size)
{
    void    *ptr;

    if ((ptr = mprAlloc(size)) != 0) {
        mprHold(ptr);
    }
    return ptr;
}


static void freeBlock(void *ptr)
{
    mprRelease(ptr);
}


static void *reallocBlock(void *ptr, int size)
{
    mprRelease(ptr);
    if ((ptr =  mprRealloc(ptr, size)) != 0) {
        mprHold(ptr);
    }
    return ptr;
}


static int blockSize(void *ptr)
{
    return (int) mprGetBlockSize(ptr);
}


static int roundBlockSize(int size)
{
    return MPR_ALLOC_ALIGN(size);
}


static int initAllocator(void *data)
{
    return 0;
}


static void termAllocator(void *data)
{
}


struct sqlite3_mem_methods mem = {
    allocBlock, freeBlock, reallocBlock, blockSize, roundBlockSize, initAllocator, termAllocator, NULL 
};


static cchar *mapToSqlType(int type)
{
    assert(0 < type && type < EDI_TYPE_MAX);
    return dataTypeToSqlType[type];
}


static int mapToEdiType(cchar *type)
{
    int     i;

    for (i = 0; i < EDI_TYPE_MAX; i++) {
        if (smatch(dataTypeToSqlType[i], type)) {
            return i;
        }
    }
    mprError("SDB: Cannot find type %s", type);
    assert(0);
    return 0;
}


static int mapQueryToEdiType(int type) 
{
    if (type == SQLITE_INTEGER) {
        return EDI_TYPE_INT;
    } else if (type == SQLITE_FLOAT) {
        return EDI_TYPE_FLOAT;
    } else if (type == SQLITE_TEXT) {
        return EDI_TYPE_TEXT;
    } else if (type == SQLITE_BLOB) {
        return EDI_TYPE_BINARY;
    } else if (type == SQLITE_NULL) {
        return EDI_TYPE_NULL;
    }
    mprError("SDB: Cannot find query type %d", type);
    assert(0);
    return 0;
}

/*********************************** Factory *******************************/

static void initSqlite()
{
    mprGlobalLock();
    if (!sqliteInitialized) {
        sqlite3_config(SQLITE_CONFIG_MALLOC, &mem);
        sqlite3_config(SQLITE_CONFIG_MULTITHREAD);
        if (sqlite3_initialize() != SQLITE_OK) {
            mprError("Cannot initialize SQLite");
            return;
        }
        sqliteInitialized = 1;
    }
    mprGlobalUnlock();
}

#else
/* To prevent ar/ranlib warnings */
PUBLIC void sdbDummy() {}
#endif /* BIT_PACK_ESP && BIT_PACK_SDB */

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
