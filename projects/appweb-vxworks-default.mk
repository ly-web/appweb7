#
#   appweb-vxworks-default.mk -- Makefile to build Embedthis Appweb for vxworks
#

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

BIT_ROOT_PREFIX := /
BIT_CFG_PREFIX  := $(BIT_VER_PREFIX)
BIT_PRD_PREFIX  := $(BIT_ROOT_PREFIX)deploy
BIT_VER_PREFIX  := $(BIT_ROOT_PREFIX)deploy
BIT_BIN_PREFIX  := $(BIT_VER_PREFIX)
BIT_INC_PREFIX  := $(BIT_VER_PREFIX)/inc
BIT_LOG_PREFIX  := $(BIT_VER_PREFIX)
BIT_SPL_PREFIX  := $(BIT_VER_PREFIX)
BIT_SRC_PREFIX  := $(BIT_ROOT_PREFIX)usr/src/appweb-4.3.0
BIT_WEB_PREFIX  := $(BIT_VER_PREFIX)/web
BIT_UBIN_PREFIX := $(BIT_VER_PREFIX)
BIT_MAN_PREFIX  := $(BIT_VER_PREFIX)

CFLAGS          += -fno-builtin -fno-defer-pop -fvolatile  -w
DFLAGS          += -D_REENTRANT -DVXWORKS -DRW_MULTI_THREAD -D_GNU_TOOL  -DCPU=PENTIUM $(patsubst %,-D%,$(filter BIT_%,$(MAKEFLAGS)))
IFLAGS          += -I$(CONFIG)/inc
LDFLAGS         += '-Wl,-r'
LIBPATHS        += -L$(CONFIG)/bin -L$(CONFIG)/bin
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
        $(CONFIG)/bin/setConfig.out \
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
	@if [ "$(BIT_PRD_PREFIX)" = "" ] ; then echo WARNING: BIT_PRD_PREFIX not set ; exit 255 ; fi
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
	rm -rf $(CONFIG)/bin/setConfig.out
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
	rm -rf $(CONFIG)/obj/espAbbrev.o
	rm -rf $(CONFIG)/obj/espFramework.o
	rm -rf $(CONFIG)/obj/espHandler.o
	rm -rf $(CONFIG)/obj/espHtml.o
	rm -rf $(CONFIG)/obj/espTemplate.o
	rm -rf $(CONFIG)/obj/mdb.o
	rm -rf $(CONFIG)/obj/sdb.o
	rm -rf $(CONFIG)/obj/esp.o
	rm -rf $(CONFIG)/obj/ejsLib.o
	rm -rf $(CONFIG)/obj/ejs.o
	rm -rf $(CONFIG)/obj/ejsc.o
	rm -rf $(CONFIG)/obj/cgiHandler.o
	rm -rf $(CONFIG)/obj/ejsHandler.o
	rm -rf $(CONFIG)/obj/phpHandler.o
	rm -rf $(CONFIG)/obj/proxyHandler.o
	rm -rf $(CONFIG)/obj/sslModule.o
	rm -rf $(CONFIG)/obj/authpass.o
	rm -rf $(CONFIG)/obj/cgiProgram.o
	rm -rf $(CONFIG)/obj/setConfig.o
	rm -rf $(CONFIG)/obj/slink.o
	rm -rf $(CONFIG)/obj/appweb.o
	rm -rf $(CONFIG)/obj/appwebMonitor.o
	rm -rf $(CONFIG)/obj/testAppweb.o
	rm -rf $(CONFIG)/obj/testHttp.o
	rm -rf $(CONFIG)/obj/removeFiles.o

clobber: clean
	rm -fr ./$(CONFIG)

$(CONFIG)/inc/mpr.h: 
	rm -fr $(CONFIG)/inc/mpr.h
	cp -r src/deps/mpr/mpr.h $(CONFIG)/inc/mpr.h

$(CONFIG)/inc/bitos.h: \
    $(CONFIG)/inc/bit.h
	rm -fr $(CONFIG)/inc/bitos.h
	cp -r src/bitos.h $(CONFIG)/inc/bitos.h

$(CONFIG)/obj/mprLib.o: \
    src/deps/mpr/mprLib.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/mpr.h \
    $(CONFIG)/inc/bitos.h
	[object Object]

$(CONFIG)/bin/libmpr.out: \
    $(CONFIG)/inc/mpr.h \
    $(CONFIG)/obj/mprLib.o
	[object Object]

$(CONFIG)/inc/est.h: 
	rm -fr $(CONFIG)/inc/est.h
	cp -r src/deps/est/est.h $(CONFIG)/inc/est.h

$(CONFIG)/obj/estLib.o: \
    src/deps/est/estLib.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/est.h \
    $(CONFIG)/inc/bitos.h
	[object Object]

$(CONFIG)/bin/libest.out: \
    $(CONFIG)/inc/est.h \
    $(CONFIG)/obj/estLib.o
	[object Object]

$(CONFIG)/obj/mprSsl.o: \
    src/deps/mpr/mprSsl.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/mpr.h \
    $(CONFIG)/inc/est.h
	[object Object]

$(CONFIG)/bin/libmprssl.out: \
    $(CONFIG)/bin/libmpr.out \
    $(CONFIG)/bin/libest.out \
    $(CONFIG)/obj/mprSsl.o
	[object Object]

$(CONFIG)/obj/manager.o: \
    src/deps/mpr/manager.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/mpr.h
	[object Object]

$(CONFIG)/bin/appman.out: \
    $(CONFIG)/bin/libmpr.out \
    $(CONFIG)/obj/manager.o
	[object Object]

$(CONFIG)/obj/makerom.o: \
    src/deps/mpr/makerom.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/mpr.h
	[object Object]

$(CONFIG)/bin/makerom.out: \
    $(CONFIG)/bin/libmpr.out \
    $(CONFIG)/obj/makerom.o
	[object Object]

$(CONFIG)/bin/ca.crt: src/deps/est/ca.crt
	rm -fr $(CONFIG)/bin/ca.crt
	cp -r src/deps/est/ca.crt $(CONFIG)/bin/ca.crt

$(CONFIG)/inc/pcre.h: 
	rm -fr $(CONFIG)/inc/pcre.h
	cp -r src/deps/pcre/pcre.h $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/pcre.o: \
    src/deps/pcre/pcre.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/pcre.h
	[object Object]

$(CONFIG)/bin/libpcre.out: \
    $(CONFIG)/inc/pcre.h \
    $(CONFIG)/obj/pcre.o
	[object Object]

$(CONFIG)/inc/http.h: 
	rm -fr $(CONFIG)/inc/http.h
	cp -r src/deps/http/http.h $(CONFIG)/inc/http.h

$(CONFIG)/obj/httpLib.o: \
    src/deps/http/httpLib.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/http.h \
    $(CONFIG)/inc/mpr.h
	[object Object]

$(CONFIG)/bin/libhttp.out: \
    $(CONFIG)/bin/libmpr.out \
    $(CONFIG)/bin/libpcre.out \
    $(CONFIG)/inc/http.h \
    $(CONFIG)/obj/httpLib.o
	[object Object]

$(CONFIG)/obj/http.o: \
    src/deps/http/http.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/http.h
	[object Object]

$(CONFIG)/bin/http.out: \
    $(CONFIG)/bin/libhttp.out \
    $(CONFIG)/obj/http.o
	[object Object]

$(CONFIG)/inc/sqlite3.h: 
	rm -fr $(CONFIG)/inc/sqlite3.h
	cp -r src/deps/sqlite/sqlite3.h $(CONFIG)/inc/sqlite3.h

$(CONFIG)/obj/sqlite3.o: \
    src/deps/sqlite/sqlite3.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/sqlite3.h
	[object Object]

$(CONFIG)/bin/libsqlite3.out: \
    $(CONFIG)/inc/sqlite3.h \
    $(CONFIG)/obj/sqlite3.o
	[object Object]

$(CONFIG)/obj/sqlite.o: \
    src/deps/sqlite/sqlite.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/sqlite3.h
	[object Object]

$(CONFIG)/bin/sqlite.out: \
    $(CONFIG)/bin/libsqlite3.out \
    $(CONFIG)/obj/sqlite.o
	[object Object]

$(CONFIG)/inc/appweb.h: 
	rm -fr $(CONFIG)/inc/appweb.h
	cp -r src/appweb.h $(CONFIG)/inc/appweb.h

$(CONFIG)/inc/customize.h: 
	rm -fr $(CONFIG)/inc/customize.h
	cp -r src/customize.h $(CONFIG)/inc/customize.h

$(CONFIG)/obj/config.o: \
    src/config.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h \
    $(CONFIG)/inc/pcre.h \
    $(CONFIG)/inc/mpr.h \
    $(CONFIG)/inc/http.h \
    $(CONFIG)/inc/customize.h
	[object Object]

$(CONFIG)/obj/convenience.o: \
    src/convenience.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h
	[object Object]

$(CONFIG)/obj/dirHandler.o: \
    src/dirHandler.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h
	[object Object]

$(CONFIG)/obj/fileHandler.o: \
    src/fileHandler.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h
	[object Object]

$(CONFIG)/obj/log.o: \
    src/log.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h
	[object Object]

$(CONFIG)/obj/server.o: \
    src/server.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h
	[object Object]

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
	[object Object]

$(CONFIG)/inc/edi.h: 
	rm -fr $(CONFIG)/inc/edi.h
	cp -r src/esp/edi.h $(CONFIG)/inc/edi.h

$(CONFIG)/inc/esp-app.h: 
	rm -fr $(CONFIG)/inc/esp-app.h
	cp -r src/esp/esp-app.h $(CONFIG)/inc/esp-app.h

$(CONFIG)/inc/esp.h: 
	rm -fr $(CONFIG)/inc/esp.h
	cp -r src/esp/esp.h $(CONFIG)/inc/esp.h

$(CONFIG)/inc/mdb.h: 
	rm -fr $(CONFIG)/inc/mdb.h
	cp -r src/esp/mdb.h $(CONFIG)/inc/mdb.h

$(CONFIG)/obj/edi.o: \
    src/esp/edi.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/edi.h \
    $(CONFIG)/inc/pcre.h
	[object Object]

$(CONFIG)/obj/espAbbrev.o: \
    src/esp/espAbbrev.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/esp.h
	[object Object]

$(CONFIG)/obj/espFramework.o: \
    src/esp/espFramework.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/esp.h
	[object Object]

$(CONFIG)/obj/espHandler.o: \
    src/esp/espHandler.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h \
    $(CONFIG)/inc/esp.h \
    $(CONFIG)/inc/edi.h
	[object Object]

$(CONFIG)/obj/espHtml.o: \
    src/esp/espHtml.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/esp.h \
    $(CONFIG)/inc/edi.h
	[object Object]

$(CONFIG)/obj/espTemplate.o: \
    src/esp/espTemplate.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/esp.h
	[object Object]

$(CONFIG)/obj/mdb.o: \
    src/esp/mdb.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h \
    $(CONFIG)/inc/edi.h \
    $(CONFIG)/inc/mdb.h \
    $(CONFIG)/inc/pcre.h
	[object Object]

$(CONFIG)/obj/sdb.o: \
    src/esp/sdb.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h \
    $(CONFIG)/inc/edi.h
	[object Object]

$(CONFIG)/bin/libmod_esp.out: \
    $(CONFIG)/bin/libappweb.out \
    $(CONFIG)/inc/edi.h \
    $(CONFIG)/inc/esp-app.h \
    $(CONFIG)/inc/esp.h \
    $(CONFIG)/inc/mdb.h \
    $(CONFIG)/obj/edi.o \
    $(CONFIG)/obj/espAbbrev.o \
    $(CONFIG)/obj/espFramework.o \
    $(CONFIG)/obj/espHandler.o \
    $(CONFIG)/obj/espHtml.o \
    $(CONFIG)/obj/espTemplate.o \
    $(CONFIG)/obj/mdb.o \
    $(CONFIG)/obj/sdb.o
	[object Object]

$(CONFIG)/obj/esp.o: \
    src/esp/esp.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/esp.h
	[object Object]

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
	[object Object]

$(CONFIG)/bin/esp.conf: src/esp/esp.conf
	rm -fr $(CONFIG)/bin/esp.conf
	cp -r src/esp/esp.conf $(CONFIG)/bin/esp.conf

src/server/esp.conf: src/esp/esp.conf
	rm -fr src/server/esp.conf
	cp -r src/esp/esp.conf src/server/esp.conf

$(CONFIG)/bin/esp-www: src/esp/www
	rm -fr $(CONFIG)/bin/esp-www
	cp -r src/esp/www $(CONFIG)/bin/esp-www

$(CONFIG)/bin/esp-appweb.conf: src/esp/esp-appweb.conf
	rm -fr $(CONFIG)/bin/esp-appweb.conf
	cp -r src/esp/esp-appweb.conf $(CONFIG)/bin/esp-appweb.conf

$(CONFIG)/inc/ejs.h: 
	rm -fr $(CONFIG)/inc/ejs.h
	cp -r src/deps/ejs/ejs.h $(CONFIG)/inc/ejs.h

$(CONFIG)/inc/ejs.slots.h: 
	rm -fr $(CONFIG)/inc/ejs.slots.h
	cp -r src/deps/ejs/ejs.slots.h $(CONFIG)/inc/ejs.slots.h

$(CONFIG)/inc/ejsByteGoto.h: 
	rm -fr $(CONFIG)/inc/ejsByteGoto.h
	cp -r src/deps/ejs/ejsByteGoto.h $(CONFIG)/inc/ejsByteGoto.h

$(CONFIG)/obj/ejsLib.o: \
    src/deps/ejs/ejsLib.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/ejs.h \
    $(CONFIG)/inc/mpr.h \
    $(CONFIG)/inc/pcre.h \
    $(CONFIG)/inc/bitos.h \
    $(CONFIG)/inc/http.h \
    $(CONFIG)/inc/ejs.slots.h
	[object Object]

$(CONFIG)/bin/libejs.out: \
    $(CONFIG)/bin/libhttp.out \
    $(CONFIG)/bin/libpcre.out \
    $(CONFIG)/bin/libmpr.out \
    $(CONFIG)/bin/libsqlite3.out \
    $(CONFIG)/inc/ejs.h \
    $(CONFIG)/inc/ejs.slots.h \
    $(CONFIG)/inc/ejsByteGoto.h \
    $(CONFIG)/obj/ejsLib.o
	[object Object]

$(CONFIG)/obj/ejs.o: \
    src/deps/ejs/ejs.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/ejs.h
	[object Object]

$(CONFIG)/bin/ejs.out: \
    $(CONFIG)/bin/libejs.out \
    $(CONFIG)/obj/ejs.o
	[object Object]

$(CONFIG)/obj/ejsc.o: \
    src/deps/ejs/ejsc.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/ejs.h
	[object Object]

$(CONFIG)/bin/ejsc.out: \
    $(CONFIG)/bin/libejs.out \
    $(CONFIG)/obj/ejsc.o
	[object Object]

$(CONFIG)/bin/ejs.mod: $(CONFIG)/bin/ejsc.out
	$(LBIN)/ejsc --out ./$(CONFIG)/bin/ejs.mod --optimize 9 --bind --require null src/deps/ejs/ejs.es

$(CONFIG)/obj/cgiHandler.o: \
    src/modules/cgiHandler.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h
	[object Object]

$(CONFIG)/bin/libmod_cgi.out: \
    $(CONFIG)/bin/libappweb.out \
    $(CONFIG)/obj/cgiHandler.o
	[object Object]

$(CONFIG)/obj/ejsHandler.o: \
    src/modules/ejsHandler.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h
	[object Object]

$(CONFIG)/bin/libmod_ejs.out: \
    $(CONFIG)/bin/libappweb.out \
    $(CONFIG)/bin/libejs.out \
    $(CONFIG)/obj/ejsHandler.o
	[object Object]

$(CONFIG)/obj/sslModule.o: \
    src/modules/sslModule.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h
	[object Object]

$(CONFIG)/bin/libmod_ssl.out: \
    $(CONFIG)/bin/libappweb.out \
    $(CONFIG)/obj/sslModule.o
	[object Object]

$(CONFIG)/obj/authpass.o: \
    src/utils/authpass.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h
	[object Object]

$(CONFIG)/bin/authpass.out: \
    $(CONFIG)/bin/libappweb.out \
    $(CONFIG)/obj/authpass.o
	[object Object]

$(CONFIG)/obj/cgiProgram.o: \
    src/utils/cgiProgram.c\
    $(CONFIG)/inc/bit.h
	[object Object]

$(CONFIG)/bin/cgiProgram.out: \
    $(CONFIG)/obj/cgiProgram.o
	[object Object]

$(CONFIG)/obj/setConfig.o: \
    src/utils/setConfig.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/mpr.h
	[object Object]

$(CONFIG)/bin/setConfig.out: \
    $(CONFIG)/bin/libmpr.out \
    $(CONFIG)/obj/setConfig.o
	[object Object]

src/server/slink.c: 
	cd src/server; [ ! -f slink.c ] && cp slink.empty slink.c ; true ; cd ../..

$(CONFIG)/obj/slink.o: \
    src/server/slink.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/esp.h
	[object Object]

$(CONFIG)/bin/libapp.out: \
    src/server/slink.c \
    $(CONFIG)/bin/esp.out \
    $(CONFIG)/bin/libmod_esp.out \
    $(CONFIG)/obj/slink.o
	[object Object]

$(CONFIG)/obj/appweb.o: \
    src/server/appweb.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h \
    $(CONFIG)/inc/esp.h
	[object Object]

$(CONFIG)/bin/appweb.out: \
    $(CONFIG)/bin/libappweb.out \
    $(CONFIG)/bin/libmod_esp.out \
    $(CONFIG)/bin/libmod_ssl.out \
    $(CONFIG)/bin/libmod_ejs.out \
    $(CONFIG)/bin/libmod_cgi.out \
    $(CONFIG)/bin/libapp.out \
    $(CONFIG)/obj/appweb.o
	[object Object]

src/server/cache: 
	cd src/server; mkdir -p cache ; cd ../..

$(CONFIG)/inc/testAppweb.h: 
	rm -fr $(CONFIG)/inc/testAppweb.h
	cp -r test/testAppweb.h $(CONFIG)/inc/testAppweb.h

$(CONFIG)/obj/testAppweb.o: \
    test/testAppweb.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/testAppweb.h \
    $(CONFIG)/inc/mpr.h \
    $(CONFIG)/inc/http.h
	[object Object]

$(CONFIG)/obj/testHttp.o: \
    test/testHttp.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/testAppweb.h
	[object Object]

$(CONFIG)/bin/testAppweb.out: \
    $(CONFIG)/bin/libappweb.out \
    $(CONFIG)/inc/testAppweb.h \
    $(CONFIG)/obj/testAppweb.o \
    $(CONFIG)/obj/testHttp.o
	[object Object]

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
	cd test; cp ../$(CONFIG)/bin/cgiProgram cgi-bin/cgiProgram.out ; cd ..
	cd test; cp ../$(CONFIG)/bin/cgiProgram cgi-bin/nph-cgiProgram.out ; cd ..
	cd test; cp ../$(CONFIG)/bin/cgiProgram 'cgi-bin/cgi Program.out' ; cd ..
	cd test; cp ../$(CONFIG)/bin/cgiProgram web/cgiProgram.cgi ; cd ..
	cd test; chmod +x cgi-bin/* web/cgiProgram.cgi ; cd ..

test/web/js: 
	cd test; cp -r ../src/esp/www/files/static/js 'web/js' ; cd ..

version: 
	@echo 4.3.0-0

genslink: 
	cd src/server; esp --static --genlink slink.c --flat compile ; cd ../..

deploy: compile
	for n in appman appweb authpass esp; do rm -f $(BIT_UBIN_PREFIX)/$$n ; done
	mkdir -p '$(BIT_CFG_PREFIX)' '$(BIT_BIN_PREFIX)' '$(BIT_INC_PREFIX)' '$(BIT_WEB_PREFIX)' '$(BIT_VER_PREFIX)/man/man1'
	cp ./$(CONFIG)/inc/*.h $(BIT_INC_PREFIX)
	cp src/server/appweb.conf src/server/esp.conf src/server/mime.types $(BIT_CFG_PREFIX)
	account=`cat /etc/passwd | grep www | sed -e 's/:.*//'` ; install -d -m 755 -g $$account -o $$account '$(BIT_SPL_PREFIX)' '$(BIT_LOG_PREFIX)'
	cp -R -P ./$(CONFIG)/bin/* $(BIT_BIN_PREFIX)
	cp -R -P src/server/web/* $(BIT_WEB_PREFIX)
	rm -f '$(BIT_PRD_PREFIX)/latest'
	ln -s $(VERSION) $(BIT_PRD_PREFIX)/latest
	for n in appman appweb authpass esp; do rm -f $(BIT_UBIN_PREFIX)/$$n ; ln -s $(BIT_BIN_PREFIX)/$$n $(BIT_UBIN_PREFIX)/$$n ; done
	for n in appman.1 appweb.1 appwebMonitor.1 authpass.1 esp.1 http.1 makerom.1 ; do rm -f $(BIT_VER_PREFIX)/man/man1/$$n $(BIT_MAN_PREFIX)/$$n ; cp doc/man/$$n $(BIT_VER_PREFIX)/man/man1 ; ln -s $(BIT_VER_PREFIX)/man/man1/$$n $(BIT_MAN_PREFIX)/$$n ; done
	echo 'Documents "$(BIT_WEB_PREFIX)"\nListen 80"\nset LOG_DIR "$(BIT_LOG_PREFIX)"\nset CACHE_DIR "$(BIT_SPL_PREFIX)/cache"' >$(BIT_CFG_PREFIX)/install.conf

