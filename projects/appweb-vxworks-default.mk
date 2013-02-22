#
#   appweb-vxworks-default.mk -- Makefile to build Embedthis Appweb for vxworks
#

export WIND_BASE := $(WIND_BASE)
export WIND_HOME := $(WIND_BASE)/..
export WIND_PLATFORM := $(WIND_PLATFORM)

PRODUCT         := appweb
VERSION         := 4.3.0
BUILD_NUMBER    := 0
PROFILE         := default
ARCH            := $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/')
OS              := vxworks
CC              := ccpentium
LD              := /usr/bin/ld
CONFIG          := $(OS)-$(ARCH)-$(PROFILE)
LBIN            := $(CONFIG)/bin

BIT_ROOT_PREFIX       := deploy
BIT_BASE_PREFIX       := $(BIT_ROOT_PREFIX)
BIT_DATA_PREFIX       := $(BIT_VAPP_PREFIX)
BIT_STATE_PREFIX      := $(BIT_VAPP_PREFIX)
BIT_BIN_PREFIX        := $(BIT_VAPP_PREFIX)
BIT_INC_PREFIX        := $(BIT_VAPP_PREFIX)/inc
BIT_LIB_PREFIX        := $(BIT_VAPP_PREFIX)
BIT_MAN_PREFIX        := $(BIT_VAPP_PREFIX)
BIT_SBIN_PREFIX       := $(BIT_VAPP_PREFIX)
BIT_ETC_PREFIX        := $(BIT_VAPP_PREFIX)
BIT_WEB_PREFIX        := $(BIT_VAPP_PREFIX)/web
BIT_LOG_PREFIX        := $(BIT_VAPP_PREFIX)
BIT_SPOOL_PREFIX      := $(BIT_VAPP_PREFIX)
BIT_CACHE_PREFIX      := $(BIT_VAPP_PREFIX)
BIT_APP_PREFIX        := $(BIT_BASE_PREFIX)
BIT_VAPP_PREFIX       := $(BIT_APP_PREFIX)
BIT_SRC_PREFIX        := $(BIT_ROOT_PREFIX)/usr/src/$(PRODUCT)-$(VERSION)

CFLAGS          += -fno-builtin -fno-defer-pop -fvolatile -w
DFLAGS          += -D_REENTRANT -DVXWORKS -DRW_MULTI_THREAD -D_GNU_TOOL -DCPU=PENTIUM $(patsubst %,-D%,$(filter BIT_%,$(MAKEFLAGS)))
IFLAGS          += -I$(CONFIG)/inc -I$(WIND_BASE)/target/h -I$(WIND_BASE)/target/h/wrn/coreip
LDFLAGS         += '-Wl,-r'
LIBPATHS        += -L$(CONFIG)/bin
LIBS            += 

DEBUG           := debug
CFLAGS-debug    := -g
DFLAGS-debug    := -DBIT_DEBUG
LDFLAGS-debug   := -g
DFLAGS-release  := 
CFLAGS-release  := -O2
LDFLAGS-release := 
CFLAGS          += $(CFLAGS-$(DEBUG))
DFLAGS          += $(DFLAGS-$(DEBUG))
LDFLAGS         += $(LDFLAGS-$(DEBUG))

unexport CDPATH

all compile: prep \
        $(CONFIG)/bin/libmpr.out \
        $(CONFIG)/bin/libmprssl.out \
        $(CONFIG)/bin/appman.out \
        $(CONFIG)/bin/makerom.out \
        $(CONFIG)/bin/libest.out \
        $(CONFIG)/bin/ca.crt \
        $(CONFIG)/bin/libpcre.out \
        $(CONFIG)/bin/libhttp.out \
        $(CONFIG)/bin/http.out \
        $(CONFIG)/bin/libsqlite3.out \
        $(CONFIG)/bin/sqlite.out \
        $(CONFIG)/bin/libappweb.out \
        $(CONFIG)/bin/libmod_esp.out \
        $(CONFIG)/bin/esp.out \
        $(CONFIG)/bin/esp.conf \
        src/server/esp.conf \
        $(CONFIG)/bin/esp-www \
        $(CONFIG)/bin/esp-appweb.conf \
        $(CONFIG)/bin/libejs.out \
        $(CONFIG)/bin/ejs.out \
        $(CONFIG)/bin/ejsc.out \
        $(CONFIG)/bin/ejs.mod \
        $(CONFIG)/bin/libmod_cgi.out \
        $(CONFIG)/bin/libmod_ejs.out \
        $(CONFIG)/bin/libmod_ssl.out \
        $(CONFIG)/bin/authpass.out \
        $(CONFIG)/bin/cgiProgram.out \
        src/server/slink.c \
        $(CONFIG)/bin/libapp.out \
        $(CONFIG)/bin/appweb.out \
        src/server/cache \
        $(CONFIG)/bin/testAppweb.out \
        test/cgi-bin/testScript \
        test/web/caching/cache.cgi \
        test/web/auth/basic/basic.cgi \
        test/cgi-bin/cgiProgram.out \
        test/web/js

.PHONY: prep

prep:
	@if [ "$(CONFIG)" = "" ] ; then echo WARNING: CONFIG not set ; exit 255 ; fi
	@if [ "$(BIT_APP_PREFIX)" = "" ] ; then echo WARNING: BIT_APP_PREFIX not set ; exit 255 ; fi
	@[ ! -x $(CONFIG)/bin ] && mkdir -p $(CONFIG)/bin; true
	@[ ! -x $(CONFIG)/inc ] && mkdir -p $(CONFIG)/inc; true
	@[ ! -x $(CONFIG)/obj ] && mkdir -p $(CONFIG)/obj; true
	@[ ! -f $(CONFIG)/inc/bit.h ] && cp projects/appweb-vxworks-default-bit.h $(CONFIG)/inc/bit.h ; true
	@[ ! -f $(CONFIG)/inc/bitos.h ] && cp src/bitos.h $(CONFIG)/inc/bitos.h ; true
	@if ! diff $(CONFIG)/inc/bit.h projects/appweb-vxworks-default-bit.h >/dev/null ; then\
		echo cp projects/appweb-vxworks-default-bit.h $(CONFIG)/inc/bit.h  ; \
		cp projects/appweb-vxworks-default-bit.h $(CONFIG)/inc/bit.h  ; \
	fi; true

clean:
	rm -rf $(CONFIG)/bin/libmpr.out
	rm -rf $(CONFIG)/bin/libmprssl.out
	rm -rf $(CONFIG)/bin/appman.out
	rm -rf $(CONFIG)/bin/makerom.out
	rm -rf $(CONFIG)/bin/libest.out
	rm -rf $(CONFIG)/bin/ca.crt
	rm -rf $(CONFIG)/bin/libpcre.out
	rm -rf $(CONFIG)/bin/libhttp.out
	rm -rf $(CONFIG)/bin/http.out
	rm -rf $(CONFIG)/bin/libsqlite3.out
	rm -rf $(CONFIG)/bin/sqlite.out
	rm -rf $(CONFIG)/bin/libappweb.out
	rm -rf $(CONFIG)/bin/libmod_esp.out
	rm -rf $(CONFIG)/bin/esp.out
	rm -rf $(CONFIG)/bin/esp.conf
	rm -rf src/server/esp.conf
	rm -rf $(CONFIG)/bin/esp-www
	rm -rf $(CONFIG)/bin/esp-appweb.conf
	rm -rf $(CONFIG)/bin/libejs.out
	rm -rf $(CONFIG)/bin/ejs.out
	rm -rf $(CONFIG)/bin/ejsc.out
	rm -rf $(CONFIG)/bin/ejs.mod
	rm -rf $(CONFIG)/bin/libmod_cgi.out
	rm -rf $(CONFIG)/bin/libmod_ejs.out
	rm -rf $(CONFIG)/bin/libmod_ssl.out
	rm -rf $(CONFIG)/bin/authpass.out
	rm -rf $(CONFIG)/bin/cgiProgram.out
	rm -rf $(CONFIG)/bin/libapp.out
	rm -rf $(CONFIG)/bin/appweb.out
	rm -rf $(CONFIG)/bin/testAppweb.out
	rm -rf test/cgi-bin/testScript
	rm -rf test/web/caching/cache.cgi
	rm -rf test/web/auth/basic/basic.cgi
	rm -rf test/cgi-bin/cgiProgram.out
	rm -rf test/web/js
	rm -rf $(CONFIG)/obj/mprLib.o
	rm -rf $(CONFIG)/obj/mprSsl.o
	rm -rf $(CONFIG)/obj/manager.o
	rm -rf $(CONFIG)/obj/makerom.o
	rm -rf $(CONFIG)/obj/estLib.o
	rm -rf $(CONFIG)/obj/pcre.o
	rm -rf $(CONFIG)/obj/httpLib.o
	rm -rf $(CONFIG)/obj/http.o
	rm -rf $(CONFIG)/obj/sqlite3.o
	rm -rf $(CONFIG)/obj/sqlite.o
	rm -rf $(CONFIG)/obj/config.o
	rm -rf $(CONFIG)/obj/convenience.o
	rm -rf $(CONFIG)/obj/dirHandler.o
	rm -rf $(CONFIG)/obj/fileHandler.o
	rm -rf $(CONFIG)/obj/log.o
	rm -rf $(CONFIG)/obj/server.o
	rm -rf $(CONFIG)/obj/edi.o
	rm -rf $(CONFIG)/obj/esp.o
	rm -rf $(CONFIG)/obj/espAbbrev.o
	rm -rf $(CONFIG)/obj/espFramework.o
	rm -rf $(CONFIG)/obj/espHandler.o
	rm -rf $(CONFIG)/obj/espHtml.o
	rm -rf $(CONFIG)/obj/espTemplate.o
	rm -rf $(CONFIG)/obj/mdb.o
	rm -rf $(CONFIG)/obj/sdb.o
	rm -rf $(CONFIG)/obj/ejsLib.o
	rm -rf $(CONFIG)/obj/ejs.o
	rm -rf $(CONFIG)/obj/ejsc.o
	rm -rf $(CONFIG)/obj/cgiHandler.o
	rm -rf $(CONFIG)/obj/ejsHandler.o
	rm -rf $(CONFIG)/obj/sslModule.o
	rm -rf $(CONFIG)/obj/authpass.o
	rm -rf $(CONFIG)/obj/cgiProgram.o
	rm -rf $(CONFIG)/obj/slink.o
	rm -rf $(CONFIG)/obj/appweb.o
	rm -rf $(CONFIG)/obj/testAppweb.o
	rm -rf $(CONFIG)/obj/testHttp.o

clobber: clean
	rm -fr ./$(CONFIG)

$(CONFIG)/inc/mpr.h: 
	mkdir -p "$(CONFIG)/inc"
	cp "src/deps/mpr/mpr.h" "$(CONFIG)/inc/mpr.h"

$(CONFIG)/inc/bit.h: 

$(CONFIG)/inc/bitos.h: \
    $(CONFIG)/inc/bit.h
	mkdir -p "$(CONFIG)/inc"
	cp "src/bitos.h" "$(CONFIG)/inc/bitos.h"

$(CONFIG)/obj/mprLib.o: \
    src/deps/mpr/mprLib.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/mpr.h \
    $(CONFIG)/inc/bitos.h
	$(CC) -c -o $(CONFIG)/obj/mprLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/mpr/mprLib.c

$(CONFIG)/bin/libmpr.out: \
    $(CONFIG)/inc/mpr.h \
    $(CONFIG)/obj/mprLib.o
	$(CC) -r -o $(CONFIG)/bin/libmpr.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/mprLib.o 

$(CONFIG)/inc/est.h: 
	mkdir -p "$(CONFIG)/inc"
	cp "src/deps/est/est.h" "$(CONFIG)/inc/est.h"

$(CONFIG)/obj/estLib.o: \
    src/deps/est/estLib.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/est.h \
    $(CONFIG)/inc/bitos.h
	$(CC) -c -o $(CONFIG)/obj/estLib.o -fno-builtin -fno-defer-pop -fvolatile $(DFLAGS) $(IFLAGS) src/deps/est/estLib.c

$(CONFIG)/bin/libest.out: \
    $(CONFIG)/inc/est.h \
    $(CONFIG)/obj/estLib.o
	$(CC) -r -o $(CONFIG)/bin/libest.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/estLib.o 

$(CONFIG)/obj/mprSsl.o: \
    src/deps/mpr/mprSsl.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/mpr.h \
    $(CONFIG)/inc/est.h
	$(CC) -c -o $(CONFIG)/obj/mprSsl.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/mpr/mprSsl.c

$(CONFIG)/bin/libmprssl.out: \
    $(CONFIG)/bin/libmpr.out \
    $(CONFIG)/bin/libest.out \
    $(CONFIG)/obj/mprSsl.o
	$(CC) -r -o $(CONFIG)/bin/libmprssl.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/mprSsl.o 

$(CONFIG)/obj/manager.o: \
    src/deps/mpr/manager.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/mpr.h
	$(CC) -c -o $(CONFIG)/obj/manager.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/mpr/manager.c

$(CONFIG)/bin/appman.out: \
    $(CONFIG)/bin/libmpr.out \
    $(CONFIG)/obj/manager.o
	$(CC) -o $(CONFIG)/bin/appman.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/manager.o $(LDFLAGS)

$(CONFIG)/obj/makerom.o: \
    src/deps/mpr/makerom.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/mpr.h
	$(CC) -c -o $(CONFIG)/obj/makerom.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/mpr/makerom.c

$(CONFIG)/bin/makerom.out: \
    $(CONFIG)/bin/libmpr.out \
    $(CONFIG)/obj/makerom.o
	$(CC) -o $(CONFIG)/bin/makerom.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/makerom.o $(LDFLAGS)

$(CONFIG)/bin/ca.crt: \
    src/deps/est/ca.crt
	mkdir -p "$(CONFIG)/bin"
	cp "src/deps/est/ca.crt" "$(CONFIG)/bin/ca.crt"

$(CONFIG)/inc/pcre.h: 
	mkdir -p "$(CONFIG)/inc"
	cp "src/deps/pcre/pcre.h" "$(CONFIG)/inc/pcre.h"

$(CONFIG)/obj/pcre.o: \
    src/deps/pcre/pcre.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/pcre.h
	$(CC) -c -o $(CONFIG)/obj/pcre.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/pcre/pcre.c

$(CONFIG)/bin/libpcre.out: \
    $(CONFIG)/inc/pcre.h \
    $(CONFIG)/obj/pcre.o
	$(CC) -r -o $(CONFIG)/bin/libpcre.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/pcre.o 

$(CONFIG)/inc/http.h: 
	mkdir -p "$(CONFIG)/inc"
	cp "src/deps/http/http.h" "$(CONFIG)/inc/http.h"

$(CONFIG)/obj/httpLib.o: \
    src/deps/http/httpLib.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/http.h \
    $(CONFIG)/inc/mpr.h
	$(CC) -c -o $(CONFIG)/obj/httpLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/http/httpLib.c

$(CONFIG)/bin/libhttp.out: \
    $(CONFIG)/bin/libmpr.out \
    $(CONFIG)/bin/libpcre.out \
    $(CONFIG)/inc/http.h \
    $(CONFIG)/obj/httpLib.o
	$(CC) -r -o $(CONFIG)/bin/libhttp.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/httpLib.o 

$(CONFIG)/obj/http.o: \
    src/deps/http/http.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/http.h
	$(CC) -c -o $(CONFIG)/obj/http.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/http/http.c

$(CONFIG)/bin/http.out: \
    $(CONFIG)/bin/libhttp.out \
    $(CONFIG)/obj/http.o
	$(CC) -o $(CONFIG)/bin/http.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/http.o $(LDFLAGS)

$(CONFIG)/inc/sqlite3.h: 
	mkdir -p "$(CONFIG)/inc"
	cp "src/deps/sqlite/sqlite3.h" "$(CONFIG)/inc/sqlite3.h"

$(CONFIG)/obj/sqlite3.o: \
    src/deps/sqlite/sqlite3.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/sqlite3.h
	$(CC) -c -o $(CONFIG)/obj/sqlite3.o -fno-builtin -fno-defer-pop -fvolatile $(DFLAGS) $(IFLAGS) src/deps/sqlite/sqlite3.c

$(CONFIG)/bin/libsqlite3.out: \
    $(CONFIG)/inc/sqlite3.h \
    $(CONFIG)/obj/sqlite3.o
	$(CC) -r -o $(CONFIG)/bin/libsqlite3.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/sqlite3.o 

$(CONFIG)/obj/sqlite.o: \
    src/deps/sqlite/sqlite.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/sqlite3.h
	$(CC) -c -o $(CONFIG)/obj/sqlite.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/sqlite/sqlite.c

$(CONFIG)/bin/sqlite.out: \
    $(CONFIG)/bin/libsqlite3.out \
    $(CONFIG)/obj/sqlite.o
	$(CC) -o $(CONFIG)/bin/sqlite.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/sqlite.o $(LDFLAGS)

$(CONFIG)/inc/appweb.h: 
	mkdir -p "$(CONFIG)/inc"
	cp "src/appweb.h" "$(CONFIG)/inc/appweb.h"

$(CONFIG)/inc/customize.h: 
	mkdir -p "$(CONFIG)/inc"
	cp "src/customize.h" "$(CONFIG)/inc/customize.h"

$(CONFIG)/obj/config.o: \
    src/config.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h \
    $(CONFIG)/inc/pcre.h \
    $(CONFIG)/inc/mpr.h \
    $(CONFIG)/inc/http.h \
    $(CONFIG)/inc/customize.h
	$(CC) -c -o $(CONFIG)/obj/config.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/config.c

$(CONFIG)/obj/convenience.o: \
    src/convenience.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h
	$(CC) -c -o $(CONFIG)/obj/convenience.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/convenience.c

$(CONFIG)/obj/dirHandler.o: \
    src/dirHandler.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h
	$(CC) -c -o $(CONFIG)/obj/dirHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/dirHandler.c

$(CONFIG)/obj/fileHandler.o: \
    src/fileHandler.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h
	$(CC) -c -o $(CONFIG)/obj/fileHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/fileHandler.c

$(CONFIG)/obj/log.o: \
    src/log.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h
	$(CC) -c -o $(CONFIG)/obj/log.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/log.c

$(CONFIG)/obj/server.o: \
    src/server.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h
	$(CC) -c -o $(CONFIG)/obj/server.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/server.c

$(CONFIG)/bin/libappweb.out: \
    $(CONFIG)/bin/libhttp.out \
    $(CONFIG)/inc/appweb.h \
    $(CONFIG)/inc/bitos.h \
    $(CONFIG)/inc/customize.h \
    $(CONFIG)/obj/config.o \
    $(CONFIG)/obj/convenience.o \
    $(CONFIG)/obj/dirHandler.o \
    $(CONFIG)/obj/fileHandler.o \
    $(CONFIG)/obj/log.o \
    $(CONFIG)/obj/server.o
	$(CC) -r -o $(CONFIG)/bin/libappweb.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/config.o $(CONFIG)/obj/convenience.o $(CONFIG)/obj/dirHandler.o $(CONFIG)/obj/fileHandler.o $(CONFIG)/obj/log.o $(CONFIG)/obj/server.o 

$(CONFIG)/inc/edi.h: 
	mkdir -p "$(CONFIG)/inc"
	cp "src/esp/edi.h" "$(CONFIG)/inc/edi.h"

$(CONFIG)/inc/esp-app.h: 
	mkdir -p "$(CONFIG)/inc"
	cp "src/esp/esp-app.h" "$(CONFIG)/inc/esp-app.h"

$(CONFIG)/inc/esp.h: 
	mkdir -p "$(CONFIG)/inc"
	cp "src/esp/esp.h" "$(CONFIG)/inc/esp.h"

$(CONFIG)/inc/mdb.h: 
	mkdir -p "$(CONFIG)/inc"
	cp "src/esp/mdb.h" "$(CONFIG)/inc/mdb.h"

$(CONFIG)/obj/edi.o: \
    src/esp/edi.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/edi.h \
    $(CONFIG)/inc/pcre.h
	$(CC) -c -o $(CONFIG)/obj/edi.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/edi.c

$(CONFIG)/obj/esp.o: \
    src/esp/esp.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/esp.h
	$(CC) -c -o $(CONFIG)/obj/esp.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/esp.c

$(CONFIG)/obj/espAbbrev.o: \
    src/esp/espAbbrev.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/esp.h
	$(CC) -c -o $(CONFIG)/obj/espAbbrev.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/espAbbrev.c

$(CONFIG)/obj/espFramework.o: \
    src/esp/espFramework.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/esp.h
	$(CC) -c -o $(CONFIG)/obj/espFramework.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/espFramework.c

$(CONFIG)/obj/espHandler.o: \
    src/esp/espHandler.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h \
    $(CONFIG)/inc/esp.h \
    $(CONFIG)/inc/edi.h
	$(CC) -c -o $(CONFIG)/obj/espHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/espHandler.c

$(CONFIG)/obj/espHtml.o: \
    src/esp/espHtml.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/esp.h \
    $(CONFIG)/inc/edi.h
	$(CC) -c -o $(CONFIG)/obj/espHtml.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/espHtml.c

$(CONFIG)/obj/espTemplate.o: \
    src/esp/espTemplate.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/esp.h
	$(CC) -c -o $(CONFIG)/obj/espTemplate.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/espTemplate.c

$(CONFIG)/obj/mdb.o: \
    src/esp/mdb.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h \
    $(CONFIG)/inc/edi.h \
    $(CONFIG)/inc/mdb.h \
    $(CONFIG)/inc/pcre.h
	$(CC) -c -o $(CONFIG)/obj/mdb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/mdb.c

$(CONFIG)/obj/sdb.o: \
    src/esp/sdb.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h \
    $(CONFIG)/inc/edi.h
	$(CC) -c -o $(CONFIG)/obj/sdb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/sdb.c

$(CONFIG)/bin/libmod_esp.out: \
    $(CONFIG)/bin/libappweb.out \
    $(CONFIG)/inc/edi.h \
    $(CONFIG)/inc/esp-app.h \
    $(CONFIG)/inc/esp.h \
    $(CONFIG)/inc/mdb.h \
    $(CONFIG)/obj/edi.o \
    $(CONFIG)/obj/esp.o \
    $(CONFIG)/obj/espAbbrev.o \
    $(CONFIG)/obj/espFramework.o \
    $(CONFIG)/obj/espHandler.o \
    $(CONFIG)/obj/espHtml.o \
    $(CONFIG)/obj/espTemplate.o \
    $(CONFIG)/obj/mdb.o \
    $(CONFIG)/obj/sdb.o
	$(CC) -r -o $(CONFIG)/bin/libmod_esp.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/edi.o $(CONFIG)/obj/esp.o $(CONFIG)/obj/espAbbrev.o $(CONFIG)/obj/espFramework.o $(CONFIG)/obj/espHandler.o $(CONFIG)/obj/espHtml.o $(CONFIG)/obj/espTemplate.o $(CONFIG)/obj/mdb.o $(CONFIG)/obj/sdb.o 

$(CONFIG)/bin/esp.out: \
    $(CONFIG)/bin/libappweb.out \
    $(CONFIG)/obj/edi.o \
    $(CONFIG)/obj/esp.o \
    $(CONFIG)/obj/espAbbrev.o \
    $(CONFIG)/obj/espFramework.o \
    $(CONFIG)/obj/espHandler.o \
    $(CONFIG)/obj/espHtml.o \
    $(CONFIG)/obj/espTemplate.o \
    $(CONFIG)/obj/mdb.o \
    $(CONFIG)/obj/sdb.o
	$(CC) -o $(CONFIG)/bin/esp.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/edi.o $(CONFIG)/obj/esp.o $(CONFIG)/obj/espAbbrev.o $(CONFIG)/obj/espFramework.o $(CONFIG)/obj/espHandler.o $(CONFIG)/obj/espHtml.o $(CONFIG)/obj/espTemplate.o $(CONFIG)/obj/mdb.o $(CONFIG)/obj/sdb.o $(LDFLAGS)

$(CONFIG)/bin/esp.conf: \
    src/esp/esp.conf
	mkdir -p "$(CONFIG)/bin"
	cp "src/esp/esp.conf" "$(CONFIG)/bin/esp.conf"

src/server/esp.conf: \
    src/esp/esp.conf
	mkdir -p "src/server"
	cp "src/esp/esp.conf" "src/server/esp.conf"

$(CONFIG)/bin/esp-www: \
    src/esp/esp-www/
	mkdir -p "$(CONFIG)/bin/esp-www"
	cp "src/esp/esp-www/app.conf" "$(CONFIG)/bin/esp-www/app.conf"
	cp "src/esp/esp-www/appweb.conf" "$(CONFIG)/bin/esp-www/appweb.conf"
	mkdir -p "$(CONFIG)/bin/esp-www/files/layouts"
	cp "src/esp/esp-www/files/layouts/default.esp" "$(CONFIG)/bin/esp-www/files/layouts/default.esp"
	mkdir -p "$(CONFIG)/bin/esp-www/files/static/images"
	cp "src/esp/esp-www/files/static/images/banner.jpg" "$(CONFIG)/bin/esp-www/files/static/images/banner.jpg"
	cp "src/esp/esp-www/files/static/images/favicon.ico" "$(CONFIG)/bin/esp-www/files/static/images/favicon.ico"
	cp "src/esp/esp-www/files/static/images/splash.jpg" "$(CONFIG)/bin/esp-www/files/static/images/splash.jpg"
	mkdir -p "$(CONFIG)/bin/esp-www/files/static"
	cp "src/esp/esp-www/files/static/index.esp" "$(CONFIG)/bin/esp-www/files/static/index.esp"
	mkdir -p "$(CONFIG)/bin/esp-www/files/static/js"
	cp "src/esp/esp-www/files/static/js/jquery.esp.js" "$(CONFIG)/bin/esp-www/files/static/js/jquery.esp.js"
	cp "src/esp/esp-www/files/static/js/jquery.js" "$(CONFIG)/bin/esp-www/files/static/js/jquery.js"
	cp "src/esp/esp-www/files/static/js/jquery.simplemodal.js" "$(CONFIG)/bin/esp-www/files/static/js/jquery.simplemodal.js"
	cp "src/esp/esp-www/files/static/js/jquery.tablesorter.js" "$(CONFIG)/bin/esp-www/files/static/js/jquery.tablesorter.js"
	cp "src/esp/esp-www/files/static/layout.css" "$(CONFIG)/bin/esp-www/files/static/layout.css"
	mkdir -p "$(CONFIG)/bin/esp-www/files/static/themes"
	cp "src/esp/esp-www/files/static/themes/default.css" "$(CONFIG)/bin/esp-www/files/static/themes/default.css"

$(CONFIG)/bin/esp-appweb.conf: \
    src/esp/esp-appweb.conf
	mkdir -p "$(CONFIG)/bin"
	cp "src/esp/esp-appweb.conf" "$(CONFIG)/bin/esp-appweb.conf"

$(CONFIG)/inc/ejs.h: 
	mkdir -p "$(CONFIG)/inc"
	cp "src/deps/ejs/ejs.h" "$(CONFIG)/inc/ejs.h"

$(CONFIG)/inc/ejs.slots.h: 
	mkdir -p "$(CONFIG)/inc"
	cp "src/deps/ejs/ejs.slots.h" "$(CONFIG)/inc/ejs.slots.h"

$(CONFIG)/inc/ejsByteGoto.h: 
	mkdir -p "$(CONFIG)/inc"
	cp "src/deps/ejs/ejsByteGoto.h" "$(CONFIG)/inc/ejsByteGoto.h"

$(CONFIG)/obj/ejsLib.o: \
    src/deps/ejs/ejsLib.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/ejs.h \
    $(CONFIG)/inc/mpr.h \
    $(CONFIG)/inc/pcre.h \
    $(CONFIG)/inc/bitos.h \
    $(CONFIG)/inc/http.h \
    $(CONFIG)/inc/ejs.slots.h
	$(CC) -c -o $(CONFIG)/obj/ejsLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/ejs/ejsLib.c

$(CONFIG)/bin/libejs.out: \
    $(CONFIG)/bin/libhttp.out \
    $(CONFIG)/bin/libpcre.out \
    $(CONFIG)/bin/libmpr.out \
    $(CONFIG)/bin/libsqlite3.out \
    $(CONFIG)/inc/ejs.h \
    $(CONFIG)/inc/ejs.slots.h \
    $(CONFIG)/inc/ejsByteGoto.h \
    $(CONFIG)/obj/ejsLib.o
	$(CC) -r -o $(CONFIG)/bin/libejs.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/ejsLib.o 

$(CONFIG)/obj/ejs.o: \
    src/deps/ejs/ejs.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/ejs.h
	$(CC) -c -o $(CONFIG)/obj/ejs.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/ejs/ejs.c

$(CONFIG)/bin/ejs.out: \
    $(CONFIG)/bin/libejs.out \
    $(CONFIG)/obj/ejs.o
	$(CC) -o $(CONFIG)/bin/ejs.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/ejs.o $(LDFLAGS)

$(CONFIG)/obj/ejsc.o: \
    src/deps/ejs/ejsc.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/ejs.h
	$(CC) -c -o $(CONFIG)/obj/ejsc.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/ejs/ejsc.c

$(CONFIG)/bin/ejsc.out: \
    $(CONFIG)/bin/libejs.out \
    $(CONFIG)/obj/ejsc.o
	$(CC) -o $(CONFIG)/bin/ejsc.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/ejsc.o $(LDFLAGS)

$(CONFIG)/bin/ejs.mod: $(CONFIG)/bin/ejsc.out
	$(LBIN)/ejsc --out ./$(CONFIG)/bin/ejs.mod --optimize 9 --bind --require null src/deps/ejs/ejs.es

$(CONFIG)/obj/cgiHandler.o: \
    src/modules/cgiHandler.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h
	$(CC) -c -o $(CONFIG)/obj/cgiHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/modules/cgiHandler.c

$(CONFIG)/bin/libmod_cgi.out: \
    $(CONFIG)/bin/libappweb.out \
    $(CONFIG)/obj/cgiHandler.o
	$(CC) -r -o $(CONFIG)/bin/libmod_cgi.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/cgiHandler.o 

$(CONFIG)/obj/ejsHandler.o: \
    src/modules/ejsHandler.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h
	$(CC) -c -o $(CONFIG)/obj/ejsHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/modules/ejsHandler.c

$(CONFIG)/bin/libmod_ejs.out: \
    $(CONFIG)/bin/libappweb.out \
    $(CONFIG)/bin/libejs.out \
    $(CONFIG)/obj/ejsHandler.o
	$(CC) -r -o $(CONFIG)/bin/libmod_ejs.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/ejsHandler.o 

$(CONFIG)/obj/sslModule.o: \
    src/modules/sslModule.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h
	$(CC) -c -o $(CONFIG)/obj/sslModule.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/modules/sslModule.c

$(CONFIG)/bin/libmod_ssl.out: \
    $(CONFIG)/bin/libappweb.out \
    $(CONFIG)/obj/sslModule.o
	$(CC) -r -o $(CONFIG)/bin/libmod_ssl.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/sslModule.o 

$(CONFIG)/obj/authpass.o: \
    src/utils/authpass.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h
	$(CC) -c -o $(CONFIG)/obj/authpass.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/utils/authpass.c

$(CONFIG)/bin/authpass.out: \
    $(CONFIG)/bin/libappweb.out \
    $(CONFIG)/obj/authpass.o
	$(CC) -o $(CONFIG)/bin/authpass.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/authpass.o $(LDFLAGS)

$(CONFIG)/obj/cgiProgram.o: \
    src/utils/cgiProgram.c\
    $(CONFIG)/inc/bit.h
	$(CC) -c -o $(CONFIG)/obj/cgiProgram.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/utils/cgiProgram.c

$(CONFIG)/bin/cgiProgram.out: \
    $(CONFIG)/obj/cgiProgram.o
	$(CC) -o $(CONFIG)/bin/cgiProgram.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/cgiProgram.o $(LDFLAGS)

src/server/slink.c: 
	cd src/server; [ ! -f slink.c ] && cp slink.empty slink.c ; true ; cd ../..

$(CONFIG)/obj/slink.o: \
    src/server/slink.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/esp.h
	$(CC) -c -o $(CONFIG)/obj/slink.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/server/slink.c

$(CONFIG)/bin/libapp.out: \
    src/server/slink.c \
    $(CONFIG)/bin/esp.out \
    $(CONFIG)/bin/libmod_esp.out \
    $(CONFIG)/obj/slink.o
	$(CC) -r -o $(CONFIG)/bin/libapp.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/slink.o 

$(CONFIG)/obj/appweb.o: \
    src/server/appweb.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h \
    $(CONFIG)/inc/esp.h
	$(CC) -c -o $(CONFIG)/obj/appweb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/server/appweb.c

$(CONFIG)/bin/appweb.out: \
    $(CONFIG)/bin/libappweb.out \
    $(CONFIG)/bin/libmod_esp.out \
    $(CONFIG)/bin/libmod_ssl.out \
    $(CONFIG)/bin/libmod_ejs.out \
    $(CONFIG)/bin/libmod_cgi.out \
    $(CONFIG)/bin/libapp.out \
    $(CONFIG)/obj/appweb.o
	$(CC) -o $(CONFIG)/bin/appweb.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/appweb.o $(LDFLAGS)

src/server/cache: 
	cd src/server; mkdir -p cache ; cd ../..

$(CONFIG)/inc/testAppweb.h: 
	mkdir -p "$(CONFIG)/inc"
	cp "test/testAppweb.h" "$(CONFIG)/inc/testAppweb.h"

$(CONFIG)/obj/testAppweb.o: \
    test/testAppweb.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/testAppweb.h \
    $(CONFIG)/inc/mpr.h \
    $(CONFIG)/inc/http.h
	$(CC) -c -o $(CONFIG)/obj/testAppweb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) test/testAppweb.c

$(CONFIG)/obj/testHttp.o: \
    test/testHttp.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/testAppweb.h
	$(CC) -c -o $(CONFIG)/obj/testHttp.o $(CFLAGS) $(DFLAGS) $(IFLAGS) test/testHttp.c

$(CONFIG)/bin/testAppweb.out: \
    $(CONFIG)/bin/libappweb.out \
    $(CONFIG)/inc/testAppweb.h \
    $(CONFIG)/obj/testAppweb.o \
    $(CONFIG)/obj/testHttp.o
	$(CC) -o $(CONFIG)/bin/testAppweb.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/testAppweb.o $(CONFIG)/obj/testHttp.o $(LDFLAGS)

test/cgi-bin/testScript: $(CONFIG)/bin/cgiProgram.out
	cd test; echo '#!../$(CONFIG)/bin/cgiProgram.out' >cgi-bin/testScript ; chmod +x cgi-bin/testScript ; cd ..

test/web/caching/cache.cgi: 
	cd test; echo "#!`type -p ejs`" >web/caching/cache.cgi ; cd ..
	cd test; echo 'print("HTTP/1.0 200 OK\nContent-Type: text/plain\n\n" + Date() + "\n")' >>web/caching/cache.cgi ; cd ..
	cd test; chmod +x web/caching/cache.cgi ; cd ..

test/web/auth/basic/basic.cgi: 
	cd test; echo "#!`type -p ejs`" >web/auth/basic/basic.cgi ; cd ..
	cd test; echo 'print("HTTP/1.0 200 OK\nContent-Type: text/plain\n\n" + serialize(App.env, {pretty: true}) + "\n")' >>web/auth/basic/basic.cgi ; cd ..
	cd test; chmod +x web/auth/basic/basic.cgi ; cd ..

test/cgi-bin/cgiProgram.out: $(CONFIG)/bin/cgiProgram.out
	cd test; cp ../$(CONFIG)/bin/cgiProgram.out cgi-bin/cgiProgram.out ; cd ..
	cd test; cp ../$(CONFIG)/bin/cgiProgram.out cgi-bin/nph-cgiProgram.out ; cd ..
	cd test; cp ../$(CONFIG)/bin/cgiProgram.out 'cgi-bin/cgi Program.out' ; cd ..
	cd test; cp ../$(CONFIG)/bin/cgiProgram.out web/cgiProgram.cgi ; cd ..
	cd test; chmod +x cgi-bin/* web/cgiProgram.cgi ; cd ..

test/web/js: \
    src/esp/esp-www/files/static/js/
	mkdir -p "test/web/js"
	cp "src/esp/esp-www/files/static/js/jquery.esp.js" "test/web/js/jquery.esp.js"
	cp "src/esp/esp-www/files/static/js/jquery.js" "test/web/js/jquery.js"
	cp "src/esp/esp-www/files/static/js/jquery.simplemodal.js" "test/web/js/jquery.simplemodal.js"
	cp "src/esp/esp-www/files/static/js/jquery.tablesorter.js" "test/web/js/jquery.tablesorter.js"

version: 
	@echo 4.3.0-0

installBinary: 


install: installBinary
	

uninstall: 
	rm -f "$(BIT_VAPP_PREFIX)/install.conf"
	rm -fr "$(BIT_VAPP_PREFIX)/inc/appweb"


genslink: 
	cd src/server; esp --static --genlink slink.c --flat compile ; cd ../..

run: compile
	cd src/server; sudo ../../$(CONFIG)/bin/appweb -v ; cd ../..

