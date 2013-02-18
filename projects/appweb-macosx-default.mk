#
#   appweb-macosx-default.mk -- Makefile to build Embedthis Appweb for macosx
#

PRODUCT         := appweb
VERSION         := 4.3.0
BUILD_NUMBER    := 0
PROFILE         := default
ARCH            := $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/')
OS              := macosx
CC              := /usr/bin/clang
LD              := /usr/bin/ld
CONFIG          := $(OS)-$(ARCH)-$(PROFILE)
LBIN            := $(CONFIG)/bin

BIT_ROOT_PREFIX       := /
BIT_BASE_PREFIX       := $(BIT_ROOT_PREFIX)/usr/local
BIT_DATA_PREFIX       := $(BIT_ROOT_PREFIX)/
BIT_STATE_PREFIX      := $(BIT_ROOT_PREFIX)/var
BIT_APP_PREFIX        := $(BIT_BASE_PREFIX)/lib/$(PRODUCT)
BIT_VAPP_PREFIX       := $(BIT_APP_PREFIX)/$(VERSION)
BIT_BIN_PREFIX        := $(BIT_ROOT_PREFIX)/usr/local/bin
BIT_INC_PREFIX        := $(BIT_ROOT_PREFIX)/usr/local/include
BIT_LIB_PREFIX        := $(BIT_ROOT_PREFIX)/usr/local/lib
BIT_MAN_PREFIX        := $(BIT_ROOT_PREFIX)/usr/local/share/man
BIT_SBIN_PREFIX       := $(BIT_ROOT_PREFIX)/usr/local/sbin
BIT_ETC_PREFIX        := $(BIT_ROOT_PREFIX)/etc/$(PRODUCT)
BIT_WEB_PREFIX        := $(BIT_ROOT_PREFIX)/var/www/$(PRODUCT)-default
BIT_LOG_PREFIX        := $(BIT_ROOT_PREFIX)/var/log/$(PRODUCT)
BIT_SPOOL_PREFIX      := $(BIT_ROOT_PREFIX)/var/spool/$(PRODUCT)
BIT_CACHE_PREFIX      := $(BIT_ROOT_PREFIX)/var/spool/$(PRODUCT)/cache
BIT_SRC_PREFIX        := $(BIT_ROOT_PREFIX)$(PRODUCT)-$(VERSION)

CFLAGS          += -w
DFLAGS          +=  $(patsubst %,-D%,$(filter BIT_%,$(MAKEFLAGS)))
IFLAGS          += -I$(CONFIG)/inc
LDFLAGS         += '-Wl,-rpath,@executable_path/' '-Wl,-rpath,@loader_path/'
LIBPATHS        += -L$(CONFIG)/bin
LIBS            += -lpthread -lm -ldl

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
        $(CONFIG)/bin/libmpr.dylib \
        $(CONFIG)/bin/libmprssl.dylib \
        $(CONFIG)/bin/appman \
        $(CONFIG)/bin/makerom \
        $(CONFIG)/bin/libest.dylib \
        $(CONFIG)/bin/ca.crt \
        $(CONFIG)/bin/libpcre.dylib \
        $(CONFIG)/bin/libhttp.dylib \
        $(CONFIG)/bin/http \
        $(CONFIG)/bin/libsqlite3.dylib \
        $(CONFIG)/bin/sqlite \
        $(CONFIG)/bin/libappweb.dylib \
        $(CONFIG)/bin/libmod_esp.dylib \
        $(CONFIG)/bin/esp \
        $(CONFIG)/bin/esp.conf \
        src/server/esp.conf \
        $(CONFIG)/bin/esp-www \
        $(CONFIG)/bin/esp-appweb.conf \
        $(CONFIG)/bin/libejs.dylib \
        $(CONFIG)/bin/ejs \
        $(CONFIG)/bin/ejsc \
        $(CONFIG)/bin/ejs.mod \
        $(CONFIG)/bin/libmod_cgi.dylib \
        $(CONFIG)/bin/libmod_ejs.dylib \
        $(CONFIG)/bin/libmod_ssl.dylib \
        $(CONFIG)/bin/authpass \
        $(CONFIG)/bin/cgiProgram \
        src/server/slink.c \
        $(CONFIG)/bin/libapp.dylib \
        $(CONFIG)/bin/appweb \
        src/server/cache \
        $(CONFIG)/bin/testAppweb \
        test/cgi-bin/testScript \
        test/web/caching/cache.cgi \
        test/web/auth/basic/basic.cgi \
        test/cgi-bin/cgiProgram \
        test/web/js

.PHONY: prep

prep:
	@if [ "$(CONFIG)" = "" ] ; then echo WARNING: CONFIG not set ; exit 255 ; fi
	@if [ "$(BIT_APP_PREFIX)" = "" ] ; then echo WARNING: BIT_APP_PREFIX not set ; exit 255 ; fi
	@[ ! -x $(CONFIG)/bin ] && mkdir -p $(CONFIG)/bin; true
	@[ ! -x $(CONFIG)/inc ] && mkdir -p $(CONFIG)/inc; true
	@[ ! -x $(CONFIG)/obj ] && mkdir -p $(CONFIG)/obj; true
	@[ ! -f $(CONFIG)/inc/bit.h ] && cp projects/appweb-macosx-default-bit.h $(CONFIG)/inc/bit.h ; true
	@[ ! -f $(CONFIG)/inc/bitos.h ] && cp src/bitos.h $(CONFIG)/inc/bitos.h ; true
	@if ! diff $(CONFIG)/inc/bit.h projects/appweb-macosx-default-bit.h >/dev/null ; then\
		echo cp projects/appweb-macosx-default-bit.h $(CONFIG)/inc/bit.h  ; \
		cp projects/appweb-macosx-default-bit.h $(CONFIG)/inc/bit.h  ; \
	fi; true
clean:
	rm -rf $(CONFIG)/bin/libmpr.dylib
	rm -rf $(CONFIG)/bin/libmprssl.dylib
	rm -rf $(CONFIG)/bin/appman
	rm -rf $(CONFIG)/bin/makerom
	rm -rf $(CONFIG)/bin/libest.dylib
	rm -rf $(CONFIG)/bin/ca.crt
	rm -rf $(CONFIG)/bin/libpcre.dylib
	rm -rf $(CONFIG)/bin/libhttp.dylib
	rm -rf $(CONFIG)/bin/http
	rm -rf $(CONFIG)/bin/libsqlite3.dylib
	rm -rf $(CONFIG)/bin/sqlite
	rm -rf $(CONFIG)/bin/libappweb.dylib
	rm -rf $(CONFIG)/bin/libmod_esp.dylib
	rm -rf $(CONFIG)/bin/esp
	rm -rf $(CONFIG)/bin/esp.conf
	rm -rf src/server/esp.conf
	rm -rf $(CONFIG)/bin/esp-www
	rm -rf $(CONFIG)/bin/esp-appweb.conf
	rm -rf $(CONFIG)/bin/libejs.dylib
	rm -rf $(CONFIG)/bin/ejs
	rm -rf $(CONFIG)/bin/ejsc
	rm -rf $(CONFIG)/bin/ejs.mod
	rm -rf $(CONFIG)/bin/libmod_cgi.dylib
	rm -rf $(CONFIG)/bin/libmod_ejs.dylib
	rm -rf $(CONFIG)/bin/libmod_ssl.dylib
	rm -rf $(CONFIG)/bin/authpass
	rm -rf $(CONFIG)/bin/cgiProgram
	rm -rf $(CONFIG)/bin/libapp.dylib
	rm -rf $(CONFIG)/bin/appweb
	rm -rf $(CONFIG)/bin/testAppweb
	rm -rf test/cgi-bin/testScript
	rm -rf test/web/caching/cache.cgi
	rm -rf test/web/auth/basic/basic.cgi
	rm -rf test/cgi-bin/cgiProgram
	rm -rf test/web/js
	rm -rf $(CONFIG)/obj/removeFiles.o
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
	rm -rf $(CONFIG)/obj/slink.o
	rm -rf $(CONFIG)/obj/appweb.o
	rm -rf $(CONFIG)/obj/appwebMonitor.o
	rm -rf $(CONFIG)/obj/testAppweb.o
	rm -rf $(CONFIG)/obj/testHttp.o

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
	$(CC) -c -o $(CONFIG)/obj/mprLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/mpr/mprLib.c

$(CONFIG)/bin/libmpr.dylib: \
    $(CONFIG)/inc/mpr.h \
    $(CONFIG)/obj/mprLib.o
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmpr.dylib $(LDFLAGS) -compatibility_version 4.3.0 -current_version 4.3.0 $(LIBPATHS) -install_name @rpath/libmpr.dylib $(CONFIG)/obj/mprLib.o $(LIBS)

$(CONFIG)/inc/est.h: 
	rm -fr $(CONFIG)/inc/est.h
	cp -r src/deps/est/est.h $(CONFIG)/inc/est.h

$(CONFIG)/obj/estLib.o: \
    src/deps/est/estLib.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/est.h \
    $(CONFIG)/inc/bitos.h
	$(CC) -c -o $(CONFIG)/obj/estLib.o $(DFLAGS) $(IFLAGS) src/deps/est/estLib.c

$(CONFIG)/bin/libest.dylib: \
    $(CONFIG)/inc/est.h \
    $(CONFIG)/obj/estLib.o
	$(CC) -dynamiclib -o $(CONFIG)/bin/libest.dylib $(LDFLAGS) -compatibility_version 4.3.0 -current_version 4.3.0 $(LIBPATHS) -install_name @rpath/libest.dylib $(CONFIG)/obj/estLib.o $(LIBS)

$(CONFIG)/obj/mprSsl.o: \
    src/deps/mpr/mprSsl.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/mpr.h \
    $(CONFIG)/inc/est.h \
    $(CONFIG)/inc/bitos.h
	$(CC) -c -o $(CONFIG)/obj/mprSsl.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/mpr/mprSsl.c

$(CONFIG)/bin/libmprssl.dylib: \
    $(CONFIG)/bin/libmpr.dylib \
    $(CONFIG)/bin/libest.dylib \
    $(CONFIG)/obj/mprSsl.o
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmprssl.dylib $(LDFLAGS) -compatibility_version 4.3.0 -current_version 4.3.0 $(LIBPATHS) -install_name @rpath/libmprssl.dylib $(CONFIG)/obj/mprSsl.o -lest -lmpr $(LIBS)

$(CONFIG)/obj/manager.o: \
    src/deps/mpr/manager.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/mpr.h
	$(CC) -c -o $(CONFIG)/obj/manager.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/mpr/manager.c

$(CONFIG)/bin/appman: \
    $(CONFIG)/bin/libmpr.dylib \
    $(CONFIG)/obj/manager.o
	$(CC) -o $(CONFIG)/bin/appman -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/manager.o -lmpr $(LIBS)

$(CONFIG)/obj/makerom.o: \
    src/deps/mpr/makerom.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/mpr.h
	$(CC) -c -o $(CONFIG)/obj/makerom.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/mpr/makerom.c

$(CONFIG)/bin/makerom: \
    $(CONFIG)/bin/libmpr.dylib \
    $(CONFIG)/obj/makerom.o
	$(CC) -o $(CONFIG)/bin/makerom -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/makerom.o -lmpr $(LIBS)

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
	$(CC) -c -o $(CONFIG)/obj/pcre.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/pcre/pcre.c

$(CONFIG)/bin/libpcre.dylib: \
    $(CONFIG)/inc/pcre.h \
    $(CONFIG)/obj/pcre.o
	$(CC) -dynamiclib -o $(CONFIG)/bin/libpcre.dylib $(LDFLAGS) -compatibility_version 4.3.0 -current_version 4.3.0 $(LIBPATHS) -install_name @rpath/libpcre.dylib $(CONFIG)/obj/pcre.o $(LIBS)

$(CONFIG)/inc/http.h: 
	rm -fr $(CONFIG)/inc/http.h
	cp -r src/deps/http/http.h $(CONFIG)/inc/http.h

$(CONFIG)/obj/httpLib.o: \
    src/deps/http/httpLib.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/http.h \
    $(CONFIG)/inc/mpr.h
	$(CC) -c -o $(CONFIG)/obj/httpLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/http/httpLib.c

$(CONFIG)/bin/libhttp.dylib: \
    $(CONFIG)/bin/libmpr.dylib \
    $(CONFIG)/bin/libpcre.dylib \
    $(CONFIG)/inc/http.h \
    $(CONFIG)/obj/httpLib.o
	$(CC) -dynamiclib -o $(CONFIG)/bin/libhttp.dylib $(LDFLAGS) -compatibility_version 4.3.0 -current_version 4.3.0 $(LIBPATHS) -install_name @rpath/libhttp.dylib $(CONFIG)/obj/httpLib.o -lpcre -lmpr $(LIBS) -lpam

$(CONFIG)/obj/http.o: \
    src/deps/http/http.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/http.h
	$(CC) -c -o $(CONFIG)/obj/http.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/http/http.c

$(CONFIG)/bin/http: \
    $(CONFIG)/bin/libhttp.dylib \
    $(CONFIG)/obj/http.o
	$(CC) -o $(CONFIG)/bin/http -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/http.o -lhttp $(LIBS) -lpcre -lmpr -lpam

$(CONFIG)/inc/sqlite3.h: 
	rm -fr $(CONFIG)/inc/sqlite3.h
	cp -r src/deps/sqlite/sqlite3.h $(CONFIG)/inc/sqlite3.h

$(CONFIG)/obj/sqlite3.o: \
    src/deps/sqlite/sqlite3.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/sqlite3.h
	$(CC) -c -o $(CONFIG)/obj/sqlite3.o $(DFLAGS) $(IFLAGS) src/deps/sqlite/sqlite3.c

$(CONFIG)/bin/libsqlite3.dylib: \
    $(CONFIG)/inc/sqlite3.h \
    $(CONFIG)/obj/sqlite3.o
	$(CC) -dynamiclib -o $(CONFIG)/bin/libsqlite3.dylib $(LDFLAGS) -compatibility_version 4.3.0 -current_version 4.3.0 $(LIBPATHS) -install_name @rpath/libsqlite3.dylib $(CONFIG)/obj/sqlite3.o $(LIBS)

$(CONFIG)/obj/sqlite.o: \
    src/deps/sqlite/sqlite.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/sqlite3.h
	$(CC) -c -o $(CONFIG)/obj/sqlite.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/sqlite/sqlite.c

$(CONFIG)/bin/sqlite: \
    $(CONFIG)/bin/libsqlite3.dylib \
    $(CONFIG)/obj/sqlite.o
	$(CC) -o $(CONFIG)/bin/sqlite -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/sqlite.o -lsqlite3 $(LIBS)

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

$(CONFIG)/bin/libappweb.dylib: \
    $(CONFIG)/bin/libhttp.dylib \
    $(CONFIG)/inc/appweb.h \
    $(CONFIG)/inc/bitos.h \
    $(CONFIG)/inc/customize.h \
    $(CONFIG)/obj/config.o \
    $(CONFIG)/obj/convenience.o \
    $(CONFIG)/obj/dirHandler.o \
    $(CONFIG)/obj/fileHandler.o \
    $(CONFIG)/obj/log.o \
    $(CONFIG)/obj/server.o
	$(CC) -dynamiclib -o $(CONFIG)/bin/libappweb.dylib $(LDFLAGS) -compatibility_version 4.3.0 -current_version 4.3.0 $(LIBPATHS) -install_name @rpath/libappweb.dylib $(CONFIG)/obj/config.o $(CONFIG)/obj/convenience.o $(CONFIG)/obj/dirHandler.o $(CONFIG)/obj/fileHandler.o $(CONFIG)/obj/log.o $(CONFIG)/obj/server.o -lhttp $(LIBS) -lpcre -lmpr -lpam

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
	$(CC) -c -o $(CONFIG)/obj/edi.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/edi.c

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

$(CONFIG)/bin/libmod_esp.dylib: \
    $(CONFIG)/bin/libappweb.dylib \
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
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmod_esp.dylib $(LDFLAGS) -compatibility_version 4.3.0 -current_version 4.3.0 $(LIBPATHS) -install_name @rpath/libmod_esp.dylib $(CONFIG)/obj/edi.o $(CONFIG)/obj/espAbbrev.o $(CONFIG)/obj/espFramework.o $(CONFIG)/obj/espHandler.o $(CONFIG)/obj/espHtml.o $(CONFIG)/obj/espTemplate.o $(CONFIG)/obj/mdb.o $(CONFIG)/obj/sdb.o -lappweb $(LIBS) -lhttp -lpcre -lmpr -lpam

$(CONFIG)/obj/esp.o: \
    src/esp/esp.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/esp.h
	$(CC) -c -o $(CONFIG)/obj/esp.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/esp.c

$(CONFIG)/bin/esp: \
    $(CONFIG)/bin/libappweb.dylib \
    $(CONFIG)/obj/edi.o \
    $(CONFIG)/obj/esp.o \
    $(CONFIG)/obj/espAbbrev.o \
    $(CONFIG)/obj/espFramework.o \
    $(CONFIG)/obj/espHandler.o \
    $(CONFIG)/obj/espHtml.o \
    $(CONFIG)/obj/espTemplate.o \
    $(CONFIG)/obj/mdb.o \
    $(CONFIG)/obj/sdb.o
	$(CC) -o $(CONFIG)/bin/esp -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/edi.o $(CONFIG)/obj/esp.o $(CONFIG)/obj/espAbbrev.o $(CONFIG)/obj/espFramework.o $(CONFIG)/obj/espHandler.o $(CONFIG)/obj/espHtml.o $(CONFIG)/obj/espTemplate.o $(CONFIG)/obj/mdb.o $(CONFIG)/obj/sdb.o -lappweb $(LIBS) -lhttp -lpcre -lmpr -lpam

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
	$(CC) -c -o $(CONFIG)/obj/ejsLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/ejs/ejsLib.c

$(CONFIG)/bin/libejs.dylib: \
    $(CONFIG)/bin/libhttp.dylib \
    $(CONFIG)/bin/libpcre.dylib \
    $(CONFIG)/bin/libmpr.dylib \
    $(CONFIG)/bin/libsqlite3.dylib \
    $(CONFIG)/inc/ejs.h \
    $(CONFIG)/inc/ejs.slots.h \
    $(CONFIG)/inc/ejsByteGoto.h \
    $(CONFIG)/obj/ejsLib.o
	$(CC) -dynamiclib -o $(CONFIG)/bin/libejs.dylib $(LDFLAGS) -compatibility_version 4.3.0 -current_version 4.3.0 $(LIBPATHS) -install_name @rpath/libejs.dylib $(CONFIG)/obj/ejsLib.o -lsqlite3 -lmpr -lpcre -lhttp $(LIBS) -lpcre -lmpr -lpam

$(CONFIG)/obj/ejs.o: \
    src/deps/ejs/ejs.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/ejs.h
	$(CC) -c -o $(CONFIG)/obj/ejs.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/ejs/ejs.c

$(CONFIG)/bin/ejs: \
    $(CONFIG)/bin/libejs.dylib \
    $(CONFIG)/obj/ejs.o
	$(CC) -o $(CONFIG)/bin/ejs -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/ejs.o -lejs $(LIBS) -lsqlite3 -lmpr -lpcre -lhttp -lpam -ledit

$(CONFIG)/obj/ejsc.o: \
    src/deps/ejs/ejsc.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/ejs.h
	$(CC) -c -o $(CONFIG)/obj/ejsc.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/ejs/ejsc.c

$(CONFIG)/bin/ejsc: \
    $(CONFIG)/bin/libejs.dylib \
    $(CONFIG)/obj/ejsc.o
	$(CC) -o $(CONFIG)/bin/ejsc -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/ejsc.o -lejs $(LIBS) -lsqlite3 -lmpr -lpcre -lhttp -lpam

$(CONFIG)/bin/ejs.mod: $(CONFIG)/bin/ejsc
	$(LBIN)/ejsc --out ./$(CONFIG)/bin/ejs.mod --optimize 9 --bind --require null src/deps/ejs/ejs.es

$(CONFIG)/obj/cgiHandler.o: \
    src/modules/cgiHandler.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h
	$(CC) -c -o $(CONFIG)/obj/cgiHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/modules/cgiHandler.c

$(CONFIG)/bin/libmod_cgi.dylib: \
    $(CONFIG)/bin/libappweb.dylib \
    $(CONFIG)/obj/cgiHandler.o
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmod_cgi.dylib $(LDFLAGS) -compatibility_version 4.3.0 -current_version 4.3.0 $(LIBPATHS) -install_name @rpath/libmod_cgi.dylib $(CONFIG)/obj/cgiHandler.o -lappweb $(LIBS) -lhttp -lpcre -lmpr -lpam

$(CONFIG)/obj/ejsHandler.o: \
    src/modules/ejsHandler.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h
	$(CC) -c -o $(CONFIG)/obj/ejsHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/modules/ejsHandler.c

$(CONFIG)/bin/libmod_ejs.dylib: \
    $(CONFIG)/bin/libappweb.dylib \
    $(CONFIG)/bin/libejs.dylib \
    $(CONFIG)/obj/ejsHandler.o
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmod_ejs.dylib $(LDFLAGS) -compatibility_version 4.3.0 -current_version 4.3.0 $(LIBPATHS) -install_name @rpath/libmod_ejs.dylib $(CONFIG)/obj/ejsHandler.o -lejs -lappweb $(LIBS) -lhttp -lpcre -lmpr -lpam -lsqlite3

$(CONFIG)/obj/sslModule.o: \
    src/modules/sslModule.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h
	$(CC) -c -o $(CONFIG)/obj/sslModule.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/modules/sslModule.c

$(CONFIG)/bin/libmod_ssl.dylib: \
    $(CONFIG)/bin/libappweb.dylib \
    $(CONFIG)/obj/sslModule.o
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmod_ssl.dylib $(LDFLAGS) -compatibility_version 4.3.0 -current_version 4.3.0 $(LIBPATHS) -install_name @rpath/libmod_ssl.dylib $(CONFIG)/obj/sslModule.o -lappweb $(LIBS) -lhttp -lpcre -lmpr -lpam

$(CONFIG)/obj/authpass.o: \
    src/utils/authpass.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h
	$(CC) -c -o $(CONFIG)/obj/authpass.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/utils/authpass.c

$(CONFIG)/bin/authpass: \
    $(CONFIG)/bin/libappweb.dylib \
    $(CONFIG)/obj/authpass.o
	$(CC) -o $(CONFIG)/bin/authpass -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/authpass.o -lappweb $(LIBS) -lhttp -lpcre -lmpr -lpam

$(CONFIG)/obj/cgiProgram.o: \
    src/utils/cgiProgram.c\
    $(CONFIG)/inc/bit.h
	$(CC) -c -o $(CONFIG)/obj/cgiProgram.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/utils/cgiProgram.c

$(CONFIG)/bin/cgiProgram: \
    $(CONFIG)/obj/cgiProgram.o
	$(CC) -o $(CONFIG)/bin/cgiProgram -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/cgiProgram.o $(LIBS)

src/server/slink.c: 
	cd src/server; [ ! -f slink.c ] && cp slink.empty slink.c ; true ; cd ../..

$(CONFIG)/obj/slink.o: \
    src/server/slink.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/esp.h
	$(CC) -c -o $(CONFIG)/obj/slink.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/server/slink.c

$(CONFIG)/bin/libapp.dylib: \
    src/server/slink.c \
    $(CONFIG)/bin/esp \
    $(CONFIG)/bin/libmod_esp.dylib \
    $(CONFIG)/obj/slink.o
	$(CC) -dynamiclib -o $(CONFIG)/bin/libapp.dylib $(LDFLAGS) -compatibility_version 4.3.0 -current_version 4.3.0 $(LIBPATHS) -install_name @rpath/libapp.dylib $(CONFIG)/obj/slink.o -lmod_esp $(LIBS) -lappweb -lhttp -lpcre -lmpr -lpam

$(CONFIG)/obj/appweb.o: \
    src/server/appweb.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/appweb.h \
    $(CONFIG)/inc/esp.h
	$(CC) -c -o $(CONFIG)/obj/appweb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/server/appweb.c

$(CONFIG)/bin/appweb: \
    $(CONFIG)/bin/libappweb.dylib \
    $(CONFIG)/bin/libmod_esp.dylib \
    $(CONFIG)/bin/libmod_ssl.dylib \
    $(CONFIG)/bin/libmod_ejs.dylib \
    $(CONFIG)/bin/libmod_cgi.dylib \
    $(CONFIG)/bin/libapp.dylib \
    $(CONFIG)/obj/appweb.o
	$(CC) -o $(CONFIG)/bin/appweb -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/appweb.o -lapp -lmod_cgi -lmod_ejs -lmod_ssl -lmod_esp -lappweb $(LIBS) -lhttp -lpcre -lmpr -lpam -lejs -lsqlite3

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
	$(CC) -c -o $(CONFIG)/obj/testAppweb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) test/testAppweb.c

$(CONFIG)/obj/testHttp.o: \
    test/testHttp.c\
    $(CONFIG)/inc/bit.h \
    $(CONFIG)/inc/testAppweb.h
	$(CC) -c -o $(CONFIG)/obj/testHttp.o $(CFLAGS) $(DFLAGS) $(IFLAGS) test/testHttp.c

$(CONFIG)/bin/testAppweb: \
    $(CONFIG)/bin/libappweb.dylib \
    $(CONFIG)/inc/testAppweb.h \
    $(CONFIG)/obj/testAppweb.o \
    $(CONFIG)/obj/testHttp.o
	$(CC) -o $(CONFIG)/bin/testAppweb -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/testAppweb.o $(CONFIG)/obj/testHttp.o -lappweb $(LIBS) -lhttp -lpcre -lmpr -lpam

test/cgi-bin/testScript: $(CONFIG)/bin/cgiProgram
	cd test; echo '#!../$(CONFIG)/bin/cgiProgram' >cgi-bin/testScript ; chmod +x cgi-bin/testScript ; cd ..

test/web/caching/cache.cgi: 
	cd test; echo "#!`type -p ejs`" >web/caching/cache.cgi ; cd ..
	cd test; echo 'print("HTTP/1.0 200 OK\nContent-Type: text/plain\n\n" + Date() + "\n")' >>web/caching/cache.cgi ; cd ..
	cd test; chmod +x web/caching/cache.cgi ; cd ..

test/web/auth/basic/basic.cgi: 
	cd test; echo "#!`type -p ejs`" >web/auth/basic/basic.cgi ; cd ..
	cd test; echo 'print("HTTP/1.0 200 OK\nContent-Type: text/plain\n\n" + serialize(App.env, {pretty: true}) + "\n")' >>web/auth/basic/basic.cgi ; cd ..
	cd test; chmod +x web/auth/basic/basic.cgi ; cd ..

test/cgi-bin/cgiProgram: $(CONFIG)/bin/cgiProgram
	cd test; cp ../$(CONFIG)/bin/cgiProgram cgi-bin/cgiProgram ; cd ..
	cd test; cp ../$(CONFIG)/bin/cgiProgram cgi-bin/nph-cgiProgram ; cd ..
	cd test; cp ../$(CONFIG)/bin/cgiProgram 'cgi-bin/cgi Program' ; cd ..
	cd test; cp ../$(CONFIG)/bin/cgiProgram web/cgiProgram.cgi ; cd ..
	cd test; chmod +x cgi-bin/* web/cgiProgram.cgi ; cd ..

test/web/js: 
	cd test; cp -r ../src/esp/www/files/static/js 'web/js' ; cd ..

version: 
	@echo 4.3.0-0

stop: 
	

installBinary: stop
	install -d -m 493 "$(BIT_VAPP_PREFIX)/bin"
	install -m 493  "$(CONFIG)/bin/appman" "$(BIT_VAPP_PREFIX)/bin/appman"
	rm -f "$(BIT_BIN_PREFIX)/appman"
	install -d "$(BIT_BIN_PREFIX)"
	ln -s "$(BIT_VAPP_PREFIX)/bin/appman" "$(BIT_BIN_PREFIX)/appman"
	install -d -m 493 "$(BIT_VAPP_PREFIX)/bin"
	install -m 493  "$(CONFIG)/bin/appweb" "$(BIT_VAPP_PREFIX)/bin/appweb"
	rm -f "$(BIT_BIN_PREFIX)/appweb"
	install -d "$(BIT_BIN_PREFIX)"
	ln -s "$(BIT_VAPP_PREFIX)/bin/appweb" "$(BIT_BIN_PREFIX)/appweb"
	install -d -m 493 "$(BIT_VAPP_PREFIX)/bin"
	install -m 493  "$(CONFIG)/bin/esp" "$(BIT_VAPP_PREFIX)/bin/esp"
	rm -f "$(BIT_BIN_PREFIX)/esp"
	install -d "$(BIT_BIN_PREFIX)"
	ln -s "$(BIT_VAPP_PREFIX)/bin/esp" "$(BIT_BIN_PREFIX)/esp"
	install -d -m 493 "$(BIT_VAPP_PREFIX)/bin"
	install -m 493  "$(CONFIG)/bin/http" "$(BIT_VAPP_PREFIX)/bin/http"
	rm -f "$(BIT_BIN_PREFIX)/http"
	install -d "$(BIT_BIN_PREFIX)"
	ln -s "$(BIT_VAPP_PREFIX)/bin/http" "$(BIT_BIN_PREFIX)/http"
	install -d -m 493 "$(BIT_VAPP_PREFIX)/bin"
	install -m 493  "$(CONFIG)/bin/libappweb" "$(BIT_VAPP_PREFIX)/bin/libappweb"
	rm -f "$(BIT_BIN_PREFIX)/libappweb"
	install -d "$(BIT_BIN_PREFIX)"
	ln -s "$(BIT_VAPP_PREFIX)/bin/libappweb" "$(BIT_BIN_PREFIX)/libappweb"
	install -d -m 493 "$(BIT_VAPP_PREFIX)/bin"
	install -m 493  "$(CONFIG)/bin/libest" "$(BIT_VAPP_PREFIX)/bin/libest"
	rm -f "$(BIT_BIN_PREFIX)/libest"
	install -d "$(BIT_BIN_PREFIX)"
	ln -s "$(BIT_VAPP_PREFIX)/bin/libest" "$(BIT_BIN_PREFIX)/libest"
	install -d -m 493 "$(BIT_VAPP_PREFIX)/bin"
	install -m 493  "$(CONFIG)/bin/libhttp" "$(BIT_VAPP_PREFIX)/bin/libhttp"
	rm -f "$(BIT_BIN_PREFIX)/libhttp"
	install -d "$(BIT_BIN_PREFIX)"
	ln -s "$(BIT_VAPP_PREFIX)/bin/libhttp" "$(BIT_BIN_PREFIX)/libhttp"
	install -d -m 493 "$(BIT_VAPP_PREFIX)/bin"
	install -m 493  "$(CONFIG)/bin/libmod*" "$(BIT_VAPP_PREFIX)/bin/libmod*"
	rm -f "$(BIT_BIN_PREFIX)/libmod*"
	install -d "$(BIT_BIN_PREFIX)"
	ln -s "$(BIT_VAPP_PREFIX)/bin/libmod*" "$(BIT_BIN_PREFIX)/libmod*"
	install -d -m 493 "$(BIT_VAPP_PREFIX)/bin"
	install -m 493  "$(CONFIG)/bin/libmpr*" "$(BIT_VAPP_PREFIX)/bin/libmpr*"
	rm -f "$(BIT_BIN_PREFIX)/libmpr*"
	install -d "$(BIT_BIN_PREFIX)"
	ln -s "$(BIT_VAPP_PREFIX)/bin/libmpr*" "$(BIT_BIN_PREFIX)/libmpr*"
	install -d -m 493 "$(BIT_VAPP_PREFIX)/bin"
	install -m 493  "$(CONFIG)/bin/libpcre" "$(BIT_VAPP_PREFIX)/bin/libpcre"
	rm -f "$(BIT_BIN_PREFIX)/libpcre"
	install -d "$(BIT_BIN_PREFIX)"
	ln -s "$(BIT_VAPP_PREFIX)/bin/libpcre" "$(BIT_BIN_PREFIX)/libpcre"
	install -d -m 493 "$(BIT_VAPP_PREFIX)/bin"
	install -m 493  "$(CONFIG)/bin/libsqlite3" "$(BIT_VAPP_PREFIX)/bin/libsqlite3"
	rm -f "$(BIT_BIN_PREFIX)/libsqlite3"
	install -d "$(BIT_BIN_PREFIX)"
	ln -s "$(BIT_VAPP_PREFIX)/bin/libsqlite3" "$(BIT_BIN_PREFIX)/libsqlite3"
	install -d "$(BIT_VAPP_PREFIX)/bin"
	install  "$(CONFIG)/bin/esp-*" "$(BIT_VAPP_PREFIX)/bin/esp-*"
	install -d "/etc/appweb"
	install  "$(CONFIG)/bin/esp.conf" "/etc/appweb/esp.conf"
	install -d "/var/www/appweb-default"
	install -d "/var/www/appweb-default/bench"
	install -d "/var/www/appweb-default/bench"
	install  "src/server/web/bench/1b.html" "/var/www/appweb-default/bench/1b.html"
	install -d "/var/www/appweb-default/bench"
	install  "src/server/web/bench/4k.html" "/var/www/appweb-default/bench/4k.html"
	install -d "/var/www/appweb-default/bench"
	install  "src/server/web/bench/64k.html" "/var/www/appweb-default/bench/64k.html"
	install -d "/var/www/appweb-default"
	install  "src/server/web/favicon.ico" "/var/www/appweb-default/favicon.ico"
	install -d "/var/www/appweb-default"
	install -d "/var/www/appweb-default/icons"
	install -d "/var/www/appweb-default/icons"
	install  "src/server/web/icons/back.gif" "/var/www/appweb-default/icons/back.gif"
	install -d "/var/www/appweb-default/icons"
	install  "src/server/web/icons/blank.gif" "/var/www/appweb-default/icons/blank.gif"
	install -d "/var/www/appweb-default/icons"
	install  "src/server/web/icons/compressed.gif" "/var/www/appweb-default/icons/compressed.gif"
	install -d "/var/www/appweb-default/icons"
	install  "src/server/web/icons/folder.gif" "/var/www/appweb-default/icons/folder.gif"
	install -d "/var/www/appweb-default/icons"
	install  "src/server/web/icons/parent.gif" "/var/www/appweb-default/icons/parent.gif"
	install -d "/var/www/appweb-default/icons"
	install  "src/server/web/icons/space.gif" "/var/www/appweb-default/icons/space.gif"
	install -d "/var/www/appweb-default/icons"
	install  "src/server/web/icons/text.gif" "/var/www/appweb-default/icons/text.gif"
	install -d "/var/www/appweb-default"
	install  "src/server/web/iehacks.css" "/var/www/appweb-default/iehacks.css"
	install -d "/var/www/appweb-default"
	install -d "/var/www/appweb-default/images"
	install -d "/var/www/appweb-default/images"
	install  "src/server/web/images/banner.jpg" "/var/www/appweb-default/images/banner.jpg"
	install -d "/var/www/appweb-default/images"
	install  "src/server/web/images/bottomShadow.jpg" "/var/www/appweb-default/images/bottomShadow.jpg"
	install -d "/var/www/appweb-default/images"
	install  "src/server/web/images/shadow.jpg" "/var/www/appweb-default/images/shadow.jpg"
	install -d "/var/www/appweb-default"
	install  "src/server/web/index.html" "/var/www/appweb-default/index.html"
	install -d "/var/www/appweb-default"
	install  "src/server/web/min-index.html" "/var/www/appweb-default/min-index.html"
	install -d "/var/www/appweb-default"
	install  "src/server/web/print.css" "/var/www/appweb-default/print.css"
	install -d "/var/www/appweb-default"
	install  "src/server/web/screen.css" "/var/www/appweb-default/screen.css"
	install -d "/var/www/appweb-default"
	install -d "/var/www/appweb-default/test"
	install -d "/var/www/appweb-default/test"
	install  "src/server/web/test/bench.html" "/var/www/appweb-default/test/bench.html"
	install -d "/var/www/appweb-default/test"
	install  "src/server/web/test/test.cgi" "/var/www/appweb-default/test/test.cgi"
	install -d "/var/www/appweb-default/test"
	install  "src/server/web/test/test.ejs" "/var/www/appweb-default/test/test.ejs"
	install -d "/var/www/appweb-default/test"
	install  "src/server/web/test/test.esp" "/var/www/appweb-default/test/test.esp"
	install -d "/var/www/appweb-default/test"
	install  "src/server/web/test/test.html" "/var/www/appweb-default/test/test.html"
	install -d "/var/www/appweb-default/test"
	install  "src/server/web/test/test.php" "/var/www/appweb-default/test/test.php"
	install -d "/var/www/appweb-default/test"
	install  "src/server/web/test/test.pl" "/var/www/appweb-default/test/test.pl"
	install -d "/var/www/appweb-default/test"
	install  "src/server/web/test/test.py" "/var/www/appweb-default/test/test.py"
	install -d "/etc/appweb"
	install  "src/server/mime.types" "/etc/appweb/mime.types"
	install -d "/etc/appweb"
	install  "src/server/appweb.conf" "/etc/appweb/appweb.conf"
	install -d "$(BIT_VAPP_PREFIX)/bin"
	install  "$(CONFIG)/bin/ejs.mod" "$(BIT_VAPP_PREFIX)/bin/ejs.mod"
	rm -f "$(BIT_APP_PREFIX)/latest"
	install -d "$(BIT_APP_PREFIX)"
	ln -s "4.3.0" "$(BIT_APP_PREFIX)/latest"


start: 
	

install: stop installBinary start
	

uninstall: stop
	rm -f "/var/log/appweb/error.log"
	rm -f "/var/log/appweb/error.log.0"
	rm -fr "$(BIT_APP_PREFIX)"
	rm -fr "$(BIT_VAPP_PREFIX)"
	rm -fr "/etc/appweb"
	rm -fr "/var/www/appweb-default"
	rm -fr "/var/log/appweb"
	rm -fr "/var/spool/appweb"


genslink: 
	cd src/server; esp --static --genlink slink.c --flat compile ; cd ../..

run: compile
	cd src/server; sudo ../../$(CONFIG)/bin/appweb -v ; cd ../..

test-run: compile
	cd test; ${platform.configuration}/bin/appweb -v ; cd ..

