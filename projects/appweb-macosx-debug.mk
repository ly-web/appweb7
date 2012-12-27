#
#   appweb-macosx-debug.mk -- Makefile to build Embedthis Appweb for macosx
#

ARCH     ?= $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/')
OS       ?= macosx
CC       ?= /usr/bin/clang
LD       ?= /usr/bin/ld
PROFILE  ?= debug
CONFIG   ?= $(OS)-$(ARCH)-$(PROFILE)

CFLAGS   += -w
DFLAGS   += 
IFLAGS   += -I$(CONFIG)/inc
LDFLAGS  += '-Wl,-rpath,@executable_path/' '-Wl,-rpath,@loader_path/'
LIBPATHS += -L$(CONFIG)/bin
LIBS     += -lpthread -lm -ldl

CFLAGS-debug    := -DBIT_DEBUG -g
CFLAGS-release  := -O2
LDFLAGS-debug   := -g
LDFLAGS-release := 
CFLAGS          += $(CFLAGS-$(PROFILE))
LDFLAGS         += $(LDFLAGS-$(PROFILE))

all: prep \
        $(CONFIG)/bin/libmpr.dylib \
        $(CONFIG)/bin/libmprssl.dylib \
        $(CONFIG)/bin/appman \
        $(CONFIG)/bin/makerom \
        $(CONFIG)/bin/libpcre.dylib \
        $(CONFIG)/bin/libhttp.dylib \
        $(CONFIG)/bin/http \
        $(CONFIG)/bin/libsqlite3.dylib \
        $(CONFIG)/bin/sqlite \
        $(CONFIG)/bin/libappweb.dylib \
        $(CONFIG)/bin/libmod_esp.dylib \
        $(CONFIG)/bin/esp \
        $(CONFIG)/bin/esp.conf \
        $(CONFIG)/bin/esp-www \
        $(CONFIG)/bin/esp-appweb.conf \
        $(CONFIG)/bin/libmod_cgi.dylib \
        $(CONFIG)/bin/authpass \
        $(CONFIG)/bin/cgiProgram \
        $(CONFIG)/bin/setConfig \
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
	@[ ! -x $(CONFIG)/inc ] && mkdir -p $(CONFIG)/inc $(CONFIG)/obj $(CONFIG)/lib $(CONFIG)/bin ; true
	@[ ! -f $(CONFIG)/inc/bit.h ] && cp projects/appweb-$(OS)-$(PROFILE)-bit.h $(CONFIG)/inc/bit.h ; true
	@[ ! -f $(CONFIG)/inc/bitos.h ] && cp src/bitos.h $(CONFIG)/inc/bitos.h ; true
	@if ! diff $(CONFIG)/inc/bit.h projects/appweb-$(OS)-$(PROFILE)-bit.h >/dev/null ; then\
		echo cp projects/appweb-$(OS)-$(PROFILE)-bit.h $(CONFIG)/inc/bit.h  ; \
		cp projects/appweb-$(OS)-$(PROFILE)-bit.h $(CONFIG)/inc/bit.h  ; \
	fi; true

clean:
	rm -rf $(CONFIG)/bin/libmpr.dylib
	rm -rf $(CONFIG)/bin/libmprssl.dylib
	rm -rf $(CONFIG)/bin/appman
	rm -rf $(CONFIG)/bin/makerom
	rm -rf $(CONFIG)/bin/libpcre.dylib
	rm -rf $(CONFIG)/bin/libhttp.dylib
	rm -rf $(CONFIG)/bin/http
	rm -rf $(CONFIG)/bin/libsqlite3.dylib
	rm -rf $(CONFIG)/bin/sqlite
	rm -rf $(CONFIG)/bin/libappweb.dylib
	rm -rf $(CONFIG)/bin/libmod_esp.dylib
	rm -rf $(CONFIG)/bin/esp
	rm -rf $(CONFIG)/bin/esp.conf
	rm -rf $(CONFIG)/bin/esp-www
	rm -rf $(CONFIG)/bin/esp-appweb.conf
	rm -rf $(CONFIG)/bin/libmod_cgi.dylib
	rm -rf $(CONFIG)/bin/authpass
	rm -rf $(CONFIG)/bin/cgiProgram
	rm -rf $(CONFIG)/bin/setConfig
	rm -rf $(CONFIG)/bin/appweb
	rm -rf src/server/cache
	rm -rf $(CONFIG)/bin/testAppweb
	rm -rf test/cgi-bin/testScript
	rm -rf test/web/caching/cache.cgi
	rm -rf test/web/auth/basic/basic.cgi
	rm -rf test/cgi-bin/cgiProgram
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
	rm -rf $(CONFIG)/obj/espSession.o
	rm -rf $(CONFIG)/obj/espTemplate.o
	rm -rf $(CONFIG)/obj/mdb.o
	rm -rf $(CONFIG)/obj/sdb.o
	rm -rf $(CONFIG)/obj/esp.o
	rm -rf $(CONFIG)/obj/cgiHandler.o
	rm -rf $(CONFIG)/obj/ejsHandler.o
	rm -rf $(CONFIG)/obj/phpHandler.o
	rm -rf $(CONFIG)/obj/proxyHandler.o
	rm -rf $(CONFIG)/obj/sslModule.o
	rm -rf $(CONFIG)/obj/authpass.o
	rm -rf $(CONFIG)/obj/cgiProgram.o
	rm -rf $(CONFIG)/obj/setConfig.o
	rm -rf $(CONFIG)/obj/appweb.o
	rm -rf $(CONFIG)/obj/appwebMonitor.o
	rm -rf $(CONFIG)/obj/testAppweb.o
	rm -rf $(CONFIG)/obj/testHttp.o
	rm -rf $(CONFIG)/obj/removeFiles.o

clobber: clean
	rm -fr ./$(CONFIG)

$(CONFIG)/inc/bitos.h: 
	rm -fr $(CONFIG)/inc/bitos.h
	cp -r src/bitos.h $(CONFIG)/inc/bitos.h

$(CONFIG)/inc/mpr.h:  \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/bitos.h
	rm -fr $(CONFIG)/inc/mpr.h
	cp -r src/deps/mpr/mpr.h $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/mprLib.o: \
        src/deps/mpr/mprLib.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/mpr.h
	$(CC) -c -o $(CONFIG)/obj/mprLib.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/deps/mpr/mprLib.c

$(CONFIG)/bin/libmpr.dylib:  \
        $(CONFIG)/inc/mpr.h \
        $(CONFIG)/obj/mprLib.o
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmpr.dylib -arch x86_64 $(LDFLAGS) -compatibility_version 4.3.0 -current_version 4.3.0 -compatibility_version 4.3.0 -current_version 4.3.0 $(LIBPATHS) -install_name @rpath/libmpr.dylib $(CONFIG)/obj/mprLib.o $(LIBS)

$(CONFIG)/inc/est.h:  \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/bitos.h
	rm -fr $(CONFIG)/inc/est.h
	cp -r src/deps/est/est.h $(CONFIG)/inc/est.h

$(CONFIG)/obj/mprSsl.o: \
        src/deps/mpr/mprSsl.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/mpr.h \
        $(CONFIG)/inc/est.h
	$(CC) -c -o $(CONFIG)/obj/mprSsl.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/deps/mpr/mprSsl.c

$(CONFIG)/bin/libmprssl.dylib:  \
        $(CONFIG)/bin/libmpr.dylib \
        $(CONFIG)/obj/mprSsl.o
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmprssl.dylib -arch x86_64 $(LDFLAGS) -compatibility_version 4.3.0 -current_version 4.3.0 -compatibility_version 4.3.0 -current_version 4.3.0 $(LIBPATHS) -install_name @rpath/libmprssl.dylib $(CONFIG)/obj/mprSsl.o -lmpr $(LIBS)

$(CONFIG)/obj/manager.o: \
        src/deps/mpr/manager.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/mpr.h
	$(CC) -c -o $(CONFIG)/obj/manager.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/deps/mpr/manager.c

$(CONFIG)/bin/appman:  \
        $(CONFIG)/bin/libmpr.dylib \
        $(CONFIG)/obj/manager.o
	$(CC) -o $(CONFIG)/bin/appman -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/manager.o -lmpr $(LIBS)

$(CONFIG)/obj/makerom.o: \
        src/deps/mpr/makerom.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/mpr.h
	$(CC) -c -o $(CONFIG)/obj/makerom.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/deps/mpr/makerom.c

$(CONFIG)/bin/makerom:  \
        $(CONFIG)/bin/libmpr.dylib \
        $(CONFIG)/obj/makerom.o
	$(CC) -o $(CONFIG)/bin/makerom -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/makerom.o -lmpr $(LIBS)

$(CONFIG)/inc/pcre.h:  \
        $(CONFIG)/inc/bit.h
	rm -fr $(CONFIG)/inc/pcre.h
	cp -r src/deps/pcre/pcre.h $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/pcre.o: \
        src/deps/pcre/pcre.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/pcre.h
	$(CC) -c -o $(CONFIG)/obj/pcre.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/deps/pcre/pcre.c

$(CONFIG)/bin/libpcre.dylib:  \
        $(CONFIG)/inc/pcre.h \
        $(CONFIG)/obj/pcre.o
	$(CC) -dynamiclib -o $(CONFIG)/bin/libpcre.dylib -arch x86_64 $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libpcre.dylib $(CONFIG)/obj/pcre.o $(LIBS)

$(CONFIG)/inc/http.h:  \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/mpr.h
	rm -fr $(CONFIG)/inc/http.h
	cp -r src/deps/http/http.h $(CONFIG)/inc/http.h

$(CONFIG)/obj/httpLib.o: \
        src/deps/http/httpLib.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/http.h \
        $(CONFIG)/inc/pcre.h
	$(CC) -c -o $(CONFIG)/obj/httpLib.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/deps/http/httpLib.c

$(CONFIG)/bin/libhttp.dylib:  \
        $(CONFIG)/bin/libmpr.dylib \
        $(CONFIG)/bin/libpcre.dylib \
        $(CONFIG)/inc/http.h \
        $(CONFIG)/obj/httpLib.o
	$(CC) -dynamiclib -o $(CONFIG)/bin/libhttp.dylib -arch x86_64 $(LDFLAGS) -compatibility_version 4.3.0 -current_version 4.3.0 -compatibility_version 4.3.0 -current_version 4.3.0 $(LIBPATHS) -install_name @rpath/libhttp.dylib $(CONFIG)/obj/httpLib.o -lpcre -lmpr $(LIBS) -lpam

$(CONFIG)/obj/http.o: \
        src/deps/http/http.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/http.h
	$(CC) -c -o $(CONFIG)/obj/http.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/deps/http/http.c

$(CONFIG)/bin/http:  \
        $(CONFIG)/bin/libhttp.dylib \
        $(CONFIG)/obj/http.o
	$(CC) -o $(CONFIG)/bin/http -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/http.o -lhttp $(LIBS) -lpcre -lmpr -lpam

$(CONFIG)/inc/sqlite3.h:  \
        $(CONFIG)/inc/bit.h
	rm -fr $(CONFIG)/inc/sqlite3.h
	cp -r src/deps/sqlite/sqlite3.h $(CONFIG)/inc/sqlite3.h

$(CONFIG)/obj/sqlite3.o: \
        src/deps/sqlite/sqlite3.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/sqlite3.h
	$(CC) -c -o $(CONFIG)/obj/sqlite3.o -arch x86_64 -w $(DFLAGS) -I$(CONFIG)/inc src/deps/sqlite/sqlite3.c

$(CONFIG)/bin/libsqlite3.dylib:  \
        $(CONFIG)/inc/sqlite3.h \
        $(CONFIG)/obj/sqlite3.o
	$(CC) -dynamiclib -o $(CONFIG)/bin/libsqlite3.dylib -arch x86_64 $(LDFLAGS) -compatibility_version 4.3.0 -current_version 4.3.0 -compatibility_version 4.3.0 -current_version 4.3.0 $(LIBPATHS) -install_name @rpath/libsqlite3.dylib $(CONFIG)/obj/sqlite3.o $(LIBS)

$(CONFIG)/obj/sqlite.o: \
        src/deps/sqlite/sqlite.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/sqlite3.h
	$(CC) -c -o $(CONFIG)/obj/sqlite.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/deps/sqlite/sqlite.c

$(CONFIG)/bin/sqlite:  \
        $(CONFIG)/bin/libsqlite3.dylib \
        $(CONFIG)/obj/sqlite.o
	$(CC) -o $(CONFIG)/bin/sqlite -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/sqlite.o -lsqlite3 $(LIBS)

$(CONFIG)/inc/customize.h:  \
        $(CONFIG)/inc/bit.h
	rm -fr $(CONFIG)/inc/customize.h
	cp -r src/customize.h $(CONFIG)/inc/customize.h

$(CONFIG)/inc/appweb.h:  \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/mpr.h \
        $(CONFIG)/inc/http.h \
        $(CONFIG)/inc/customize.h
	rm -fr $(CONFIG)/inc/appweb.h
	cp -r src/appweb.h $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/config.o: \
        src/config.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/appweb.h \
        $(CONFIG)/inc/pcre.h
	$(CC) -c -o $(CONFIG)/obj/config.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/config.c

$(CONFIG)/obj/convenience.o: \
        src/convenience.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/appweb.h
	$(CC) -c -o $(CONFIG)/obj/convenience.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/convenience.c

$(CONFIG)/obj/dirHandler.o: \
        src/dirHandler.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/appweb.h
	$(CC) -c -o $(CONFIG)/obj/dirHandler.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/dirHandler.c

$(CONFIG)/obj/fileHandler.o: \
        src/fileHandler.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/appweb.h
	$(CC) -c -o $(CONFIG)/obj/fileHandler.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/fileHandler.c

$(CONFIG)/obj/log.o: \
        src/log.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/appweb.h
	$(CC) -c -o $(CONFIG)/obj/log.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/log.c

$(CONFIG)/obj/server.o: \
        src/server.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/appweb.h
	$(CC) -c -o $(CONFIG)/obj/server.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/server.c

$(CONFIG)/bin/libappweb.dylib:  \
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
	$(CC) -dynamiclib -o $(CONFIG)/bin/libappweb.dylib -arch x86_64 $(LDFLAGS) -compatibility_version 4.3.0 -current_version 4.3.0 -compatibility_version 4.3.0 -current_version 4.3.0 $(LIBPATHS) -install_name @rpath/libappweb.dylib $(CONFIG)/obj/config.o $(CONFIG)/obj/convenience.o $(CONFIG)/obj/dirHandler.o $(CONFIG)/obj/fileHandler.o $(CONFIG)/obj/log.o $(CONFIG)/obj/server.o -lhttp $(LIBS) -lpcre -lmpr -lpam

$(CONFIG)/inc/edi.h:  \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/appweb.h
	rm -fr $(CONFIG)/inc/edi.h
	cp -r src/esp/edi.h $(CONFIG)/inc/edi.h

$(CONFIG)/inc/esp-app.h: 
	rm -fr $(CONFIG)/inc/esp-app.h
	cp -r src/esp/esp-app.h $(CONFIG)/inc/esp-app.h

$(CONFIG)/inc/esp.h:  \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/appweb.h \
        $(CONFIG)/inc/edi.h
	rm -fr $(CONFIG)/inc/esp.h
	cp -r src/esp/esp.h $(CONFIG)/inc/esp.h

$(CONFIG)/inc/mdb.h:  \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/appweb.h \
        $(CONFIG)/inc/edi.h
	rm -fr $(CONFIG)/inc/mdb.h
	cp -r src/esp/mdb.h $(CONFIG)/inc/mdb.h

$(CONFIG)/obj/edi.o: \
        src/esp/edi.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/edi.h \
        $(CONFIG)/inc/pcre.h
	$(CC) -c -o $(CONFIG)/obj/edi.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/esp/edi.c

$(CONFIG)/obj/espAbbrev.o: \
        src/esp/espAbbrev.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/esp.h
	$(CC) -c -o $(CONFIG)/obj/espAbbrev.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/esp/espAbbrev.c

$(CONFIG)/obj/espFramework.o: \
        src/esp/espFramework.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/esp.h
	$(CC) -c -o $(CONFIG)/obj/espFramework.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/esp/espFramework.c

$(CONFIG)/obj/espHandler.o: \
        src/esp/espHandler.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/appweb.h \
        $(CONFIG)/inc/esp.h \
        $(CONFIG)/inc/edi.h
	$(CC) -c -o $(CONFIG)/obj/espHandler.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/esp/espHandler.c

$(CONFIG)/obj/espHtml.o: \
        src/esp/espHtml.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/esp.h \
        $(CONFIG)/inc/edi.h
	$(CC) -c -o $(CONFIG)/obj/espHtml.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/esp/espHtml.c

$(CONFIG)/obj/espSession.o: \
        src/esp/espSession.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/esp.h
	$(CC) -c -o $(CONFIG)/obj/espSession.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/esp/espSession.c

$(CONFIG)/obj/espTemplate.o: \
        src/esp/espTemplate.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/esp.h
	$(CC) -c -o $(CONFIG)/obj/espTemplate.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/esp/espTemplate.c

$(CONFIG)/obj/mdb.o: \
        src/esp/mdb.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/appweb.h \
        $(CONFIG)/inc/edi.h \
        $(CONFIG)/inc/mdb.h \
        $(CONFIG)/inc/pcre.h
	$(CC) -c -o $(CONFIG)/obj/mdb.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/esp/mdb.c

$(CONFIG)/obj/sdb.o: \
        src/esp/sdb.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/appweb.h \
        $(CONFIG)/inc/edi.h
	$(CC) -c -o $(CONFIG)/obj/sdb.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/esp/sdb.c

$(CONFIG)/bin/libmod_esp.dylib:  \
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
        $(CONFIG)/obj/espSession.o \
        $(CONFIG)/obj/espTemplate.o \
        $(CONFIG)/obj/mdb.o \
        $(CONFIG)/obj/sdb.o
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmod_esp.dylib -arch x86_64 $(LDFLAGS) -compatibility_version 4.3.0 -current_version 4.3.0 -compatibility_version 4.3.0 -current_version 4.3.0 $(LIBPATHS) -install_name @rpath/libmod_esp.dylib $(CONFIG)/obj/edi.o $(CONFIG)/obj/espAbbrev.o $(CONFIG)/obj/espFramework.o $(CONFIG)/obj/espHandler.o $(CONFIG)/obj/espHtml.o $(CONFIG)/obj/espSession.o $(CONFIG)/obj/espTemplate.o $(CONFIG)/obj/mdb.o $(CONFIG)/obj/sdb.o -lappweb $(LIBS) -lhttp -lpcre -lmpr -lpam

$(CONFIG)/obj/esp.o: \
        src/esp/esp.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/esp.h
	$(CC) -c -o $(CONFIG)/obj/esp.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/esp/esp.c

$(CONFIG)/bin/esp:  \
        $(CONFIG)/bin/libappweb.dylib \
        $(CONFIG)/obj/edi.o \
        $(CONFIG)/obj/esp.o \
        $(CONFIG)/obj/espAbbrev.o \
        $(CONFIG)/obj/espFramework.o \
        $(CONFIG)/obj/espHandler.o \
        $(CONFIG)/obj/espHtml.o \
        $(CONFIG)/obj/espSession.o \
        $(CONFIG)/obj/espTemplate.o \
        $(CONFIG)/obj/mdb.o \
        $(CONFIG)/obj/sdb.o
	$(CC) -o $(CONFIG)/bin/esp -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/edi.o $(CONFIG)/obj/esp.o $(CONFIG)/obj/espAbbrev.o $(CONFIG)/obj/espFramework.o $(CONFIG)/obj/espHandler.o $(CONFIG)/obj/espHtml.o $(CONFIG)/obj/espSession.o $(CONFIG)/obj/espTemplate.o $(CONFIG)/obj/mdb.o $(CONFIG)/obj/sdb.o -lappweb $(LIBS) -lhttp -lpcre -lmpr -lpam

$(CONFIG)/bin/esp.conf: 
	rm -fr $(CONFIG)/bin/esp.conf
	cp -r src/esp/esp.conf $(CONFIG)/bin/esp.conf

$(CONFIG)/bin/esp-www: 
	rm -fr $(CONFIG)/bin/esp-www
	cp -r src/esp/www $(CONFIG)/bin/esp-www

$(CONFIG)/bin/esp-appweb.conf: 
	rm -fr $(CONFIG)/bin/esp-appweb.conf
	cp -r src/esp/esp-appweb.conf $(CONFIG)/bin/esp-appweb.conf

$(CONFIG)/obj/cgiHandler.o: \
        src/modules/cgiHandler.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/appweb.h
	$(CC) -c -o $(CONFIG)/obj/cgiHandler.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/modules/cgiHandler.c

$(CONFIG)/bin/libmod_cgi.dylib:  \
        $(CONFIG)/bin/libappweb.dylib \
        $(CONFIG)/obj/cgiHandler.o
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmod_cgi.dylib -arch x86_64 $(LDFLAGS) -compatibility_version 4.3.0 -current_version 4.3.0 -compatibility_version 4.3.0 -current_version 4.3.0 $(LIBPATHS) -install_name @rpath/libmod_cgi.dylib $(CONFIG)/obj/cgiHandler.o -lappweb $(LIBS) -lhttp -lpcre -lmpr -lpam

$(CONFIG)/obj/authpass.o: \
        src/utils/authpass.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/appweb.h
	$(CC) -c -o $(CONFIG)/obj/authpass.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/utils/authpass.c

$(CONFIG)/bin/authpass:  \
        $(CONFIG)/bin/libappweb.dylib \
        $(CONFIG)/obj/authpass.o
	$(CC) -o $(CONFIG)/bin/authpass -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/authpass.o -lappweb $(LIBS) -lhttp -lpcre -lmpr -lpam

$(CONFIG)/obj/cgiProgram.o: \
        src/utils/cgiProgram.c \
        $(CONFIG)/inc/bit.h
	$(CC) -c -o $(CONFIG)/obj/cgiProgram.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/utils/cgiProgram.c

$(CONFIG)/bin/cgiProgram:  \
        $(CONFIG)/obj/cgiProgram.o
	$(CC) -o $(CONFIG)/bin/cgiProgram -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/cgiProgram.o $(LIBS)

$(CONFIG)/obj/setConfig.o: \
        src/utils/setConfig.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/mpr.h
	$(CC) -c -o $(CONFIG)/obj/setConfig.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/utils/setConfig.c

$(CONFIG)/bin/setConfig:  \
        $(CONFIG)/bin/libmpr.dylib \
        $(CONFIG)/obj/setConfig.o
	$(CC) -o $(CONFIG)/bin/setConfig -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/setConfig.o -lmpr $(LIBS)

$(CONFIG)/obj/appweb.o: \
        src/server/appweb.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/appweb.h \
        $(CONFIG)/inc/esp.h
	$(CC) -c -o $(CONFIG)/obj/appweb.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc src/server/appweb.c

$(CONFIG)/bin/appweb:  \
        $(CONFIG)/bin/libappweb.dylib \
        $(CONFIG)/bin/libmod_esp.dylib \
        $(CONFIG)/bin/libmod_cgi.dylib \
        $(CONFIG)/obj/appweb.o
	$(CC) -o $(CONFIG)/bin/appweb -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/appweb.o -lmod_cgi -lmod_esp -lappweb $(LIBS) -lhttp -lpcre -lmpr -lpam

src/server/cache: 
	cd src/server >/dev/null ;\
		mkdir -p cache ;\
		cd - >/dev/null 

$(CONFIG)/inc/testAppweb.h:  \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/mpr.h \
        $(CONFIG)/inc/http.h
	rm -fr $(CONFIG)/inc/testAppweb.h
	cp -r test/testAppweb.h $(CONFIG)/inc/testAppweb.h

$(CONFIG)/obj/testAppweb.o: \
        test/testAppweb.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/testAppweb.h
	$(CC) -c -o $(CONFIG)/obj/testAppweb.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc test/testAppweb.c

$(CONFIG)/obj/testHttp.o: \
        test/testHttp.c \
        $(CONFIG)/inc/bit.h \
        $(CONFIG)/inc/testAppweb.h
	$(CC) -c -o $(CONFIG)/obj/testHttp.o -arch x86_64 $(CFLAGS) $(DFLAGS) -I$(CONFIG)/inc test/testHttp.c

$(CONFIG)/bin/testAppweb:  \
        $(CONFIG)/bin/libappweb.dylib \
        $(CONFIG)/inc/testAppweb.h \
        $(CONFIG)/obj/testAppweb.o \
        $(CONFIG)/obj/testHttp.o
	$(CC) -o $(CONFIG)/bin/testAppweb -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/testAppweb.o $(CONFIG)/obj/testHttp.o -lappweb $(LIBS) -lhttp -lpcre -lmpr -lpam

test/cgi-bin/testScript:  \
        $(CONFIG)/bin/cgiProgram
	cd test >/dev/null ;\
		echo '#!../$(CONFIG)/bin/cgiProgram' >cgi-bin/testScript ; chmod +x cgi-bin/testScript ;\
		cd - >/dev/null 

test/web/caching/cache.cgi: 
	cd test >/dev/null ;\
		echo "#!`type -p ejs`" >web/caching/cache.cgi ;\
	echo 'print("HTTP/1.0 200 OK\nContent-Type: text/plain\n\n" + Date() + "\n")' >>web/caching/cache.cgi ;\
	chmod +x web/caching/cache.cgi ;\
		cd - >/dev/null 

test/web/auth/basic/basic.cgi: 
	cd test >/dev/null ;\
		echo "#!`type -p ejs`" >web/auth/basic/basic.cgi ;\
	echo 'print("HTTP/1.0 200 OK\nContent-Type: text/plain\n\n" + serialize(App.env, {pretty: true}) + "\n")' >>web/auth/basic/basic.cgi ;\
	chmod +x web/auth/basic/basic.cgi ;\
		cd - >/dev/null 

test/cgi-bin/cgiProgram:  \
        $(CONFIG)/bin/cgiProgram
	cd test >/dev/null ;\
		cp ../$(CONFIG)/bin/cgiProgram cgi-bin/cgiProgram ;\
	cp ../$(CONFIG)/bin/cgiProgram cgi-bin/nph-cgiProgram ;\
	cp ../$(CONFIG)/bin/cgiProgram 'cgi-bin/cgi Program' ;\
	cp ../$(CONFIG)/bin/cgiProgram web/cgiProgram.cgi ;\
	chmod +x cgi-bin/* web/cgiProgram.cgi ;\
		cd - >/dev/null 

test/web/js: 
	cd test >/dev/null ;\
		cp -r ../src/esp/www/files/static/js 'web/js' ;\
		cd - >/dev/null 

