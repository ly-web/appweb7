/**
    makerom.c - Compile source files into C code suitable for embedding in ROM.
  
    Usage: makerom --prefix prefix --name romName files ... >rom.c
  
    Copyright (c) All Rights Reserved. See copyright notice at the bottom of the file.
 */

/********************************** Includes **********************************/

#include    "mpr.h"

/**************************** Forward Declarations ****************************/

static void printUsage();
static int  binToC(MprList *files, char *romName, char *prefix);

/*********************************** Code *************************************/

int main(int argc, char **argv)
{
    Mpr         *mpr;
    MprList     *files;
    FILE        *fp;
    char        *argp, *prefix, *romName, *fileList, *path, fbuf[ME_MAX_FNAME];
    int         nextArg, err;

    mpr = mprCreate(argc, argv, 0);

    err = 0;
    prefix = "";
    romName = "romFiles";
    files = mprCreateList(-1, 0);
    fileList = 0;

    for (nextArg = 1; nextArg < argc; nextArg++) {
        argp = argv[nextArg];
        if (*argp != '-') {
            break;
        }
        if (smatch(argp, "--files")) {
            if (nextArg >= argc) {
                err++;
            } else {
                fileList = argv[++nextArg];
            }
        } else if (smatch(argp, "--name")) {
            if (nextArg >= argc) {
                err++;
            } else {
                romName = argv[++nextArg];
            }
        } else if (smatch(argp, "--prefix")) {
            if (nextArg >= argc) {
                err++;
            } else {
                prefix = argv[++nextArg];
            }

        } else {
            printUsage();
            return MPR_ERR;
        }
    }
    if (fileList) {
        if ((fp = fopen(fileList, "r")) == 0) {
            mprLog("error makerom", 0, "Cannot open file list %s", fileList);
            return MPR_ERR;
        }
        while (fgets(fbuf, sizeof(fbuf), fp) != NULL) {
            path = strim(fbuf, "\r\n", 0);
            mprAddItem(files, path);
        }
        fclose(fp);
    }
    while (nextArg < argc) {
        mprAddItem(files, argv[nextArg++]);
    }
    if (mprGetListLength(files) == 0) {
        printUsage();
        return MPR_ERR;
    }
    if (binToC(files, romName, prefix) < 0) {
        return MPR_ERR;
    }
    return 0;
}


static void printUsage()
{
    mprEprintf("usage: makerom [options] files... >output.c\n");
    mprEprintf("  Makerom options:\n");
    mprEprintf("  --files fileList      # List of files\n");
    mprEprintf("  --name structName     # Name of top level C struct\n");
    mprEprintf("  --prefix prefix       # File prefix to remove\n");
}


/* 
    Encode the files as C code
 */
static int binToC(MprList *files, char *romName, char *prefix)
{
    struct stat     sbuf;
    char            buf[512];
    char            *filename, *p, *name;
    ssize           len;
    int             fd, next, i, j;

    mprPrintf("/*\n    %s -- Compiled Files\n */\n", romName);

    mprPrintf("#include \"mpr.h\"\n\n");
    mprPrintf("#if ME_ROM\n");

    /*
        Open each input file and compile
     */
    for (next = 0; (filename = mprGetNextItem(files, &next)) != 0; ) {
        if (stat(filename, &sbuf) == 0 && sbuf.st_mode & S_IFDIR) {
            continue;
        } 
        if ((fd = open(filename, O_RDONLY | O_BINARY, 0666)) < 0) {
            mprLog("error makerom", 0, "Cannot open file %s", filename);
            return -1;
        }
        mprPrintf("static uchar _file_%d[] = {\n", next);

        while ((len = read(fd, buf, sizeof(buf))) > 0) {
            p = buf;
            for (i = 0; i < len; ) {
                mprPrintf("    ");
                for (j = 0; p < &buf[len] && j < 16; j++, p++) {
                    mprPrintf("%4d,", (unsigned char) *p);
                }
                i += j;
                mprPrintf("\n");
            }
        }
        mprPrintf("    0 };\n\n");
        close(fd);
    }

    /*
        Now output the page index
     */ 
    mprPrintf("PUBLIC MprRomInode %s[] = {\n", romName);

    for (next = 0; (filename = mprGetNextItem(files, &next)) != 0; ) {
        name = sncmp(filename, prefix, slen(prefix)) == 0 ? &filename[slen(prefix)] : filename;
        name = mprGetRelPath(name, 0);
        name = sjoin("/", name, NULL);
        name = mprNormalizePath(name);
        mprMapSeparators(name, '/');
        if (stat(filename, &sbuf) == 0 && sbuf.st_mode & S_IFDIR) {
            mprPrintf("    { \"%s\", 0, 0, 0 },\n", name);
            continue;
        }
        mprPrintf("    { \"%s\", _file_%d, %d, %d },\n", name, next, (int) sbuf.st_size, next);
    }
    mprPrintf("    { 0, 0, 0, 0 },\n");
    mprPrintf("};\n");
    mprPrintf("#else\n");
    mprPrintf("PUBLIC int romDummy;\n");
    mprPrintf("#endif /* ME_ROM */\n");
    return 0;
}

/*
    @copy   default

    Copyright (c) Embedthis Software. All Rights Reserved.

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
