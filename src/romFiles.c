/*
    romFiles -- Compiled Files

    Generate via:

    makerom --prefix / files...
 */
#include "mpr.h"

#if ME_ROM

static uchar _file_1[] = {
    0
};

PUBLIC MprRomInode romFiles[] = {
    { "/appweb.conf", _file_1, 3401, 1 },
    { 0, 0, 0, 0 },
};

PUBLIC MprRomInode *mprGetRomFiles() {
    return romFiles;
}
#else
PUBLIC int romDummy;
#endif /* ME_ROM */
