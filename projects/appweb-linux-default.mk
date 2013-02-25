#
#   appweb-linux-default.mk -- Makefile to build Embedthis Appweb for linux
#

PRODUCT         := appweb
VERSION         := 4.3.0
BUILD_NUMBER    := 0
PROFILE         := default
ARCH            := $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/')
OS              := linux
CC              := /usr/bin/gcc
LD              := /usr/bin/ld
CONFIG          := $(OS)-$(ARCH)-$(PROFILE)
LBIN            := $(CONFIG)/bin

CFLAGS          += -fPIC   -w
DFLAGS          += -D_REENTRANT -DPIC  $(patsubst %,-D%,$(filter BIT_%,$(MAKEFLAGS)))
IFLAGS          += -I$(CONFIG)/inc
LDFLAGS         += '-Wl,--enable-new-dtags' '-Wl,-rpath,$$ORIGIN/' '-rdynamic'
LIBPATHS        += -L$(CONFIG)/bin
LIBS            += -lpthread -lm -lrt -ldl

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

BIT_PACK_EST          := 1
BIT_PACK_EJSCRIPT     := 1
BIT_PACK_CGI          := 1
BIT_PACK_ESP          := 1
BIT_PACK_SQLITE       := 1

BIT_ROOT_PREFIX       := 
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

WEB_USER    = $(shell egrep 'www-data|_www|nobody' /etc/passwd | sed 's/:.*$$//' |  tail -1)
WEB_GROUP   = $(shell egrep 'www-data|_www|nobody|nogroup' /etc/group | sed 's/:.*$$//' |  tail -1)

TARGETS     += $(CONFIG)/bin/libmpr.so
TARGETS     += $(CONFIG)/bin/libmprssl.so
TARGETS     += $(CONFIG)/bin/appman
TARGETS     += $(CONFIG)/bin/makerom
ifeq ($(BIT_PACK_EST),1)
TARGETS += $(CONFIG)/bin/libest.so
endif
TARGETS     += $(CONFIG)/bin/ca.crt
TARGETS     += $(CONFIG)/bin/libpcre.so
TARGETS     += $(CONFIG)/bin/libhttp.so
TARGETS     += $(CONFIG)/bin/http
ifeq ($(BIT_PACK_SQLITE),1)
TARGETS += $(CONFIG)/bin/libsqlite3.so
endif
ifeq ($(BIT_PACK_SQLITE),1)
TARGETS += $(CONFIG)/bin/sqlite
endif
TARGETS     += $(CONFIG)/bin/libappweb.so
ifeq ($(BIT_PACK_ESP),1)
TARGETS += $(CONFIG)/bin/libmod_esp.so
endif
ifeq ($(BIT_PACK_ESP),1)
TARGETS += $(CONFIG)/bin/esp
endif
ifeq ($(BIT_PACK_ESP),1)
TARGETS += $(CONFIG)/bin/esp.conf
endif
ifeq ($(BIT_PACK_ESP),1)
TARGETS += src/server/esp.conf
endif
ifeq ($(BIT_PACK_ESP),1)
TARGETS += $(CONFIG)/bin/esp-www
endif
ifeq ($(BIT_PACK_ESP),1)
TARGETS += $(CONFIG)/bin/esp-appweb.conf
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
TARGETS += $(CONFIG)/bin/libejs.so
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
TARGETS += $(CONFIG)/bin/ejs
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
TARGETS += $(CONFIG)/bin/ejsc
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
TARGETS += $(CONFIG)/bin/ejs.mod
endif
ifeq ($(BIT_PACK_CGI),1)
TARGETS += $(CONFIG)/bin/libmod_cgi.so
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
TARGETS += $(CONFIG)/bin/libmod_ejs.so
endif
TARGETS     += $(CONFIG)/bin/libmod_ssl.so
TARGETS     += $(CONFIG)/bin/authpass
ifeq ($(BIT_PACK_CGI),1)
TARGETS += $(CONFIG)/bin/cgiProgram
endif
TARGETS     += src/server/slink.c
TARGETS     += $(CONFIG)/bin/libapp.so
TARGETS     += $(CONFIG)/bin/appweb
TARGETS     += src/server/cache
TARGETS     += $(CONFIG)/bin/testAppweb
ifeq ($(BIT_PACK_CGI),1)
TARGETS += test/cgi-bin/testScript
endif
ifeq ($(BIT_PACK_CGI),1)
TARGETS += test/web/caching/cache.cgi
endif
ifeq ($(BIT_PACK_CGI),1)
TARGETS += test/web/auth/basic/basic.cgi
endif
ifeq ($(BIT_PACK_CGI),1)
TARGETS += test/cgi-bin/cgiProgram
endif
TARGETS     += test/web/js

unexport CDPATH

ifndef SHOW
.SILENT:
endif

all compile: prep $(TARGETS)

.PHONY: prep

prep:
	@echo "      [Info] Use "make SHOW=1" to trace executed commands."
	@if [ "$(CONFIG)" = "" ] ; then echo WARNING: CONFIG not set ; exit 255 ; fi
	@if [ "$(BIT_APP_PREFIX)" = "" ] ; then echo WARNING: BIT_APP_PREFIX not set ; exit 255 ; fi
	@[ ! -x $(CONFIG)/bin ] && mkdir -p $(CONFIG)/bin; true
	@[ ! -x $(CONFIG)/inc ] && mkdir -p $(CONFIG)/inc; true
	@[ ! -x $(CONFIG)/obj ] && mkdir -p $(CONFIG)/obj; true
	@[ ! -f $(CONFIG)/inc/bit.h ] && cp projects/appweb-linux-default-bit.h $(CONFIG)/inc/bit.h ; true
	@[ ! -f $(CONFIG)/inc/bitos.h ] && cp src/bitos.h $(CONFIG)/inc/bitos.h ; true
	@if ! diff $(CONFIG)/inc/bit.h projects/appweb-linux-default-bit.h >/dev/null ; then\
		echo cp projects/appweb-linux-default-bit.h $(CONFIG)/inc/bit.h  ; \
		cp projects/appweb-linux-default-bit.h $(CONFIG)/inc/bit.h  ; \
	fi; true

clean:
	rm -rf $(CONFIG)/bin/libmpr.so
	rm -rf $(CONFIG)/bin/libmprssl.so
	rm -rf $(CONFIG)/bin/appman
	rm -rf $(CONFIG)/bin/makerom
	rm -rf $(CONFIG)/bin/libest.so
	rm -rf $(CONFIG)/bin/ca.crt
	rm -rf $(CONFIG)/bin/libpcre.so
	rm -rf $(CONFIG)/bin/libhttp.so
	rm -rf $(CONFIG)/bin/http
	rm -rf $(CONFIG)/bin/libsqlite3.so
	rm -rf $(CONFIG)/bin/sqlite
	rm -rf $(CONFIG)/bin/libappweb.so
	rm -rf $(CONFIG)/bin/libmod_esp.so
	rm -rf $(CONFIG)/bin/esp
	rm -rf $(CONFIG)/bin/esp.conf
	rm -rf src/server/esp.conf
	rm -rf $(CONFIG)/bin/esp-www
	rm -rf $(CONFIG)/bin/esp-appweb.conf
	rm -rf $(CONFIG)/bin/libejs.so
	rm -rf $(CONFIG)/bin/ejs
	rm -rf $(CONFIG)/bin/ejsc
	rm -rf $(CONFIG)/bin/ejs.mod
	rm -rf $(CONFIG)/bin/libmod_cgi.so
	rm -rf $(CONFIG)/bin/libmod_ejs.so
	rm -rf $(CONFIG)/bin/libmod_ssl.so
	rm -rf $(CONFIG)/bin/authpass
	rm -rf $(CONFIG)/bin/cgiProgram
	rm -rf $(CONFIG)/bin/libapp.so
	rm -rf $(CONFIG)/bin/appweb
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

#
#   mpr.h
#
$(CONFIG)/inc/mpr.h: $(DEPS_1)
	@echo '      [File] linux-x86-default/inc/mpr.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/deps/mpr/mpr.h" "$(CONFIG)/inc/mpr.h"

#
#   bit.h
#
$(CONFIG)/inc/bit.h: $(DEPS_2)

#
#   bitos.h
#
DEPS_3 += $(CONFIG)/inc/bit.h

$(CONFIG)/inc/bitos.h: $(DEPS_3)
	@echo '      [File] linux-x86-default/inc/bitos.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/bitos.h" "$(CONFIG)/inc/bitos.h"

#
#   mprLib.o
#
DEPS_4 += $(CONFIG)/inc/bit.h
DEPS_4 += $(CONFIG)/inc/mpr.h
DEPS_4 += $(CONFIG)/inc/bitos.h

$(CONFIG)/obj/mprLib.o: \
    src/deps/mpr/mprLib.c $(DEPS_4)
	@echo '   [Compile] src/deps/mpr/mprLib.c'
	$(CC) -c -o $(CONFIG)/obj/mprLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/mpr/mprLib.c

#
#   libmpr
#
DEPS_5 += $(CONFIG)/inc/mpr.h
DEPS_5 += $(CONFIG)/obj/mprLib.o

$(CONFIG)/bin/libmpr.so: $(DEPS_5)
	@echo '      [Link] libmpr'
	$(CC) -shared -o $(CONFIG)/bin/libmpr.so $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/mprLib.o $(LIBS)

#
#   est.h
#
$(CONFIG)/inc/est.h: $(DEPS_6)
	@echo '      [File] linux-x86-default/inc/est.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/deps/est/est.h" "$(CONFIG)/inc/est.h"

#
#   estLib.o
#
DEPS_7 += $(CONFIG)/inc/bit.h
DEPS_7 += $(CONFIG)/inc/est.h
DEPS_7 += $(CONFIG)/inc/bitos.h

$(CONFIG)/obj/estLib.o: \
    src/deps/est/estLib.c $(DEPS_7)
	@echo '   [Compile] src/deps/est/estLib.c'
	$(CC) -c -o $(CONFIG)/obj/estLib.o -fPIC $(DFLAGS) $(IFLAGS) src/deps/est/estLib.c

ifeq ($(BIT_PACK_EST),1)
#
#   libest
#
DEPS_8 += $(CONFIG)/inc/est.h
DEPS_8 += $(CONFIG)/obj/estLib.o

$(CONFIG)/bin/libest.so: $(DEPS_8)
	@echo '      [Link] libest'
	$(CC) -shared -o $(CONFIG)/bin/libest.so $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/estLib.o $(LIBS)
endif

#
#   mprSsl.o
#
DEPS_9 += $(CONFIG)/inc/bit.h
DEPS_9 += $(CONFIG)/inc/mpr.h
DEPS_9 += $(CONFIG)/inc/est.h

$(CONFIG)/obj/mprSsl.o: \
    src/deps/mpr/mprSsl.c $(DEPS_9)
	@echo '   [Compile] src/deps/mpr/mprSsl.c'
	$(CC) -c -o $(CONFIG)/obj/mprSsl.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/mpr/mprSsl.c

#
#   libmprssl
#
DEPS_10 += $(CONFIG)/bin/libmpr.so
ifeq ($(BIT_PACK_EST),1)
    DEPS_10 += $(CONFIG)/bin/libest.so
endif
DEPS_10 += $(CONFIG)/obj/mprSsl.o

ifeq ($(BIT_PACK_EST),1)
    LIBS_10 += -lest
endif
LIBS_10 += -lmpr

$(CONFIG)/bin/libmprssl.so: $(DEPS_10)
	@echo '      [Link] libmprssl'
	$(CC) -shared -o $(CONFIG)/bin/libmprssl.so $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/mprSsl.o $(LIBS_10) $(LIBS_10) $(LIBS)

#
#   manager.o
#
DEPS_11 += $(CONFIG)/inc/bit.h
DEPS_11 += $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/manager.o: \
    src/deps/mpr/manager.c $(DEPS_11)
	@echo '   [Compile] src/deps/mpr/manager.c'
	$(CC) -c -o $(CONFIG)/obj/manager.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/mpr/manager.c

#
#   manager
#
DEPS_12 += $(CONFIG)/bin/libmpr.so
DEPS_12 += $(CONFIG)/obj/manager.o

LIBS_12 += -lmpr

$(CONFIG)/bin/appman: $(DEPS_12)
	@echo '      [Link] manager'
	$(CC) -o $(CONFIG)/bin/appman $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/manager.o $(LIBS_12) $(LIBS_12) $(LIBS) $(LDFLAGS)

#
#   makerom.o
#
DEPS_13 += $(CONFIG)/inc/bit.h
DEPS_13 += $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/makerom.o: \
    src/deps/mpr/makerom.c $(DEPS_13)
	@echo '   [Compile] src/deps/mpr/makerom.c'
	$(CC) -c -o $(CONFIG)/obj/makerom.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/mpr/makerom.c

#
#   makerom
#
DEPS_14 += $(CONFIG)/bin/libmpr.so
DEPS_14 += $(CONFIG)/obj/makerom.o

LIBS_14 += -lmpr

$(CONFIG)/bin/makerom: $(DEPS_14)
	@echo '      [Link] makerom'
	$(CC) -o $(CONFIG)/bin/makerom $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/makerom.o $(LIBS_14) $(LIBS_14) $(LIBS) $(LDFLAGS)

#
#   ca-crt
#
DEPS_15 += src/deps/est/ca.crt

$(CONFIG)/bin/ca.crt: $(DEPS_15)
	@echo '      [File] linux-x86-default/bin/ca.crt'
	mkdir -p "$(CONFIG)/bin"
	cp "src/deps/est/ca.crt" "$(CONFIG)/bin/ca.crt"

#
#   pcre.h
#
$(CONFIG)/inc/pcre.h: $(DEPS_16)
	@echo '      [File] linux-x86-default/inc/pcre.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/deps/pcre/pcre.h" "$(CONFIG)/inc/pcre.h"

#
#   pcre.o
#
DEPS_17 += $(CONFIG)/inc/bit.h
DEPS_17 += $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/pcre.o: \
    src/deps/pcre/pcre.c $(DEPS_17)
	@echo '   [Compile] src/deps/pcre/pcre.c'
	$(CC) -c -o $(CONFIG)/obj/pcre.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/pcre/pcre.c

#
#   libpcre
#
DEPS_18 += $(CONFIG)/inc/pcre.h
DEPS_18 += $(CONFIG)/obj/pcre.o

$(CONFIG)/bin/libpcre.so: $(DEPS_18)
	@echo '      [Link] libpcre'
	$(CC) -shared -o $(CONFIG)/bin/libpcre.so $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/pcre.o $(LIBS)

#
#   http.h
#
$(CONFIG)/inc/http.h: $(DEPS_19)
	@echo '      [File] linux-x86-default/inc/http.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/deps/http/http.h" "$(CONFIG)/inc/http.h"

#
#   httpLib.o
#
DEPS_20 += $(CONFIG)/inc/bit.h
DEPS_20 += $(CONFIG)/inc/http.h
DEPS_20 += $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/httpLib.o: \
    src/deps/http/httpLib.c $(DEPS_20)
	@echo '   [Compile] src/deps/http/httpLib.c'
	$(CC) -c -o $(CONFIG)/obj/httpLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/http/httpLib.c

#
#   libhttp
#
DEPS_21 += $(CONFIG)/bin/libmpr.so
DEPS_21 += $(CONFIG)/bin/libpcre.so
DEPS_21 += $(CONFIG)/inc/http.h
DEPS_21 += $(CONFIG)/obj/httpLib.o

LIBS_21 += -lpcre
LIBS_21 += -lmpr

$(CONFIG)/bin/libhttp.so: $(DEPS_21)
	@echo '      [Link] libhttp'
	$(CC) -shared -o $(CONFIG)/bin/libhttp.so $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/httpLib.o $(LIBS_21) $(LIBS_21) $(LIBS)

#
#   http.o
#
DEPS_22 += $(CONFIG)/inc/bit.h
DEPS_22 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/http.o: \
    src/deps/http/http.c $(DEPS_22)
	@echo '   [Compile] src/deps/http/http.c'
	$(CC) -c -o $(CONFIG)/obj/http.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/http/http.c

#
#   http
#
DEPS_23 += $(CONFIG)/bin/libhttp.so
DEPS_23 += $(CONFIG)/obj/http.o

LIBS_23 += -lhttp
LIBS_23 += -lpcre
LIBS_23 += -lmpr

$(CONFIG)/bin/http: $(DEPS_23)
	@echo '      [Link] http'
	$(CC) -o $(CONFIG)/bin/http $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/http.o $(LIBS_23) $(LIBS_23) $(LIBS) -lmpr $(LDFLAGS)

#
#   sqlite3.h
#
$(CONFIG)/inc/sqlite3.h: $(DEPS_24)
	@echo '      [File] linux-x86-default/inc/sqlite3.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/deps/sqlite/sqlite3.h" "$(CONFIG)/inc/sqlite3.h"

#
#   sqlite3.o
#
DEPS_25 += $(CONFIG)/inc/bit.h
DEPS_25 += $(CONFIG)/inc/sqlite3.h

$(CONFIG)/obj/sqlite3.o: \
    src/deps/sqlite/sqlite3.c $(DEPS_25)
	@echo '   [Compile] src/deps/sqlite/sqlite3.c'
	$(CC) -c -o $(CONFIG)/obj/sqlite3.o -fPIC $(DFLAGS) $(IFLAGS) src/deps/sqlite/sqlite3.c

ifeq ($(BIT_PACK_SQLITE),1)
#
#   libsqlite3
#
DEPS_26 += $(CONFIG)/inc/sqlite3.h
DEPS_26 += $(CONFIG)/obj/sqlite3.o

$(CONFIG)/bin/libsqlite3.so: $(DEPS_26)
	@echo '      [Link] libsqlite3'
	$(CC) -shared -o $(CONFIG)/bin/libsqlite3.so $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/sqlite3.o $(LIBS)
endif

#
#   sqlite.o
#
DEPS_27 += $(CONFIG)/inc/bit.h
DEPS_27 += $(CONFIG)/inc/sqlite3.h

$(CONFIG)/obj/sqlite.o: \
    src/deps/sqlite/sqlite.c $(DEPS_27)
	@echo '   [Compile] src/deps/sqlite/sqlite.c'
	$(CC) -c -o $(CONFIG)/obj/sqlite.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/sqlite/sqlite.c

ifeq ($(BIT_PACK_SQLITE),1)
#
#   sqlite
#
ifeq ($(BIT_PACK_SQLITE),1)
    DEPS_28 += $(CONFIG)/bin/libsqlite3.so
endif
DEPS_28 += $(CONFIG)/obj/sqlite.o

ifeq ($(BIT_PACK_SQLITE),1)
    LIBS_28 += -lsqlite3
endif

$(CONFIG)/bin/sqlite: $(DEPS_28)
	@echo '      [Link] sqlite'
	$(CC) -o $(CONFIG)/bin/sqlite $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/sqlite.o $(LIBS_28) $(LIBS_28) $(LIBS) $(LDFLAGS)
endif

#
#   appweb.h
#
$(CONFIG)/inc/appweb.h: $(DEPS_29)
	@echo '      [File] linux-x86-default/inc/appweb.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/appweb.h" "$(CONFIG)/inc/appweb.h"

#
#   customize.h
#
$(CONFIG)/inc/customize.h: $(DEPS_30)
	@echo '      [File] linux-x86-default/inc/customize.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/customize.h" "$(CONFIG)/inc/customize.h"

#
#   config.o
#
DEPS_31 += $(CONFIG)/inc/bit.h
DEPS_31 += $(CONFIG)/inc/appweb.h
DEPS_31 += $(CONFIG)/inc/pcre.h
DEPS_31 += $(CONFIG)/inc/mpr.h
DEPS_31 += $(CONFIG)/inc/http.h
DEPS_31 += $(CONFIG)/inc/customize.h

$(CONFIG)/obj/config.o: \
    src/config.c $(DEPS_31)
	@echo '   [Compile] src/config.c'
	$(CC) -c -o $(CONFIG)/obj/config.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/config.c

#
#   convenience.o
#
DEPS_32 += $(CONFIG)/inc/bit.h
DEPS_32 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/convenience.o: \
    src/convenience.c $(DEPS_32)
	@echo '   [Compile] src/convenience.c'
	$(CC) -c -o $(CONFIG)/obj/convenience.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/convenience.c

#
#   dirHandler.o
#
DEPS_33 += $(CONFIG)/inc/bit.h
DEPS_33 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/dirHandler.o: \
    src/dirHandler.c $(DEPS_33)
	@echo '   [Compile] src/dirHandler.c'
	$(CC) -c -o $(CONFIG)/obj/dirHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/dirHandler.c

#
#   fileHandler.o
#
DEPS_34 += $(CONFIG)/inc/bit.h
DEPS_34 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/fileHandler.o: \
    src/fileHandler.c $(DEPS_34)
	@echo '   [Compile] src/fileHandler.c'
	$(CC) -c -o $(CONFIG)/obj/fileHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/fileHandler.c

#
#   log.o
#
DEPS_35 += $(CONFIG)/inc/bit.h
DEPS_35 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/log.o: \
    src/log.c $(DEPS_35)
	@echo '   [Compile] src/log.c'
	$(CC) -c -o $(CONFIG)/obj/log.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/log.c

#
#   server.o
#
DEPS_36 += $(CONFIG)/inc/bit.h
DEPS_36 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/server.o: \
    src/server.c $(DEPS_36)
	@echo '   [Compile] src/server.c'
	$(CC) -c -o $(CONFIG)/obj/server.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/server.c

#
#   libappweb
#
DEPS_37 += $(CONFIG)/bin/libhttp.so
DEPS_37 += $(CONFIG)/inc/appweb.h
DEPS_37 += $(CONFIG)/inc/bitos.h
DEPS_37 += $(CONFIG)/inc/customize.h
DEPS_37 += $(CONFIG)/obj/config.o
DEPS_37 += $(CONFIG)/obj/convenience.o
DEPS_37 += $(CONFIG)/obj/dirHandler.o
DEPS_37 += $(CONFIG)/obj/fileHandler.o
DEPS_37 += $(CONFIG)/obj/log.o
DEPS_37 += $(CONFIG)/obj/server.o

LIBS_37 += -lhttp
LIBS_37 += -lpcre
LIBS_37 += -lmpr

$(CONFIG)/bin/libappweb.so: $(DEPS_37)
	@echo '      [Link] libappweb'
	$(CC) -shared -o $(CONFIG)/bin/libappweb.so $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/config.o $(CONFIG)/obj/convenience.o $(CONFIG)/obj/dirHandler.o $(CONFIG)/obj/fileHandler.o $(CONFIG)/obj/log.o $(CONFIG)/obj/server.o $(LIBS_37) $(LIBS_37) $(LIBS) -lmpr

#
#   edi.h
#
$(CONFIG)/inc/edi.h: $(DEPS_38)
	@echo '      [File] linux-x86-default/inc/edi.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/esp/edi.h" "$(CONFIG)/inc/edi.h"

#
#   esp-app.h
#
$(CONFIG)/inc/esp-app.h: $(DEPS_39)
	@echo '      [File] linux-x86-default/inc/esp-app.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/esp/esp-app.h" "$(CONFIG)/inc/esp-app.h"

#
#   esp.h
#
$(CONFIG)/inc/esp.h: $(DEPS_40)
	@echo '      [File] linux-x86-default/inc/esp.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/esp/esp.h" "$(CONFIG)/inc/esp.h"

#
#   mdb.h
#
$(CONFIG)/inc/mdb.h: $(DEPS_41)
	@echo '      [File] linux-x86-default/inc/mdb.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/esp/mdb.h" "$(CONFIG)/inc/mdb.h"

#
#   edi.o
#
DEPS_42 += $(CONFIG)/inc/bit.h
DEPS_42 += $(CONFIG)/inc/edi.h
DEPS_42 += $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/edi.o: \
    src/esp/edi.c $(DEPS_42)
	@echo '   [Compile] src/esp/edi.c'
	$(CC) -c -o $(CONFIG)/obj/edi.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/edi.c

#
#   esp.o
#
DEPS_43 += $(CONFIG)/inc/bit.h
DEPS_43 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/esp.o: \
    src/esp/esp.c $(DEPS_43)
	@echo '   [Compile] src/esp/esp.c'
	$(CC) -c -o $(CONFIG)/obj/esp.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/esp.c

#
#   espAbbrev.o
#
DEPS_44 += $(CONFIG)/inc/bit.h
DEPS_44 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espAbbrev.o: \
    src/esp/espAbbrev.c $(DEPS_44)
	@echo '   [Compile] src/esp/espAbbrev.c'
	$(CC) -c -o $(CONFIG)/obj/espAbbrev.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/espAbbrev.c

#
#   espFramework.o
#
DEPS_45 += $(CONFIG)/inc/bit.h
DEPS_45 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espFramework.o: \
    src/esp/espFramework.c $(DEPS_45)
	@echo '   [Compile] src/esp/espFramework.c'
	$(CC) -c -o $(CONFIG)/obj/espFramework.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/espFramework.c

#
#   espHandler.o
#
DEPS_46 += $(CONFIG)/inc/bit.h
DEPS_46 += $(CONFIG)/inc/appweb.h
DEPS_46 += $(CONFIG)/inc/esp.h
DEPS_46 += $(CONFIG)/inc/edi.h

$(CONFIG)/obj/espHandler.o: \
    src/esp/espHandler.c $(DEPS_46)
	@echo '   [Compile] src/esp/espHandler.c'
	$(CC) -c -o $(CONFIG)/obj/espHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/espHandler.c

#
#   espHtml.o
#
DEPS_47 += $(CONFIG)/inc/bit.h
DEPS_47 += $(CONFIG)/inc/esp.h
DEPS_47 += $(CONFIG)/inc/edi.h

$(CONFIG)/obj/espHtml.o: \
    src/esp/espHtml.c $(DEPS_47)
	@echo '   [Compile] src/esp/espHtml.c'
	$(CC) -c -o $(CONFIG)/obj/espHtml.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/espHtml.c

#
#   espTemplate.o
#
DEPS_48 += $(CONFIG)/inc/bit.h
DEPS_48 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espTemplate.o: \
    src/esp/espTemplate.c $(DEPS_48)
	@echo '   [Compile] src/esp/espTemplate.c'
	$(CC) -c -o $(CONFIG)/obj/espTemplate.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/espTemplate.c

#
#   mdb.o
#
DEPS_49 += $(CONFIG)/inc/bit.h
DEPS_49 += $(CONFIG)/inc/appweb.h
DEPS_49 += $(CONFIG)/inc/edi.h
DEPS_49 += $(CONFIG)/inc/mdb.h
DEPS_49 += $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/mdb.o: \
    src/esp/mdb.c $(DEPS_49)
	@echo '   [Compile] src/esp/mdb.c'
	$(CC) -c -o $(CONFIG)/obj/mdb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/mdb.c

#
#   sdb.o
#
DEPS_50 += $(CONFIG)/inc/bit.h
DEPS_50 += $(CONFIG)/inc/appweb.h
DEPS_50 += $(CONFIG)/inc/edi.h

$(CONFIG)/obj/sdb.o: \
    src/esp/sdb.c $(DEPS_50)
	@echo '   [Compile] src/esp/sdb.c'
	$(CC) -c -o $(CONFIG)/obj/sdb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/sdb.c

ifeq ($(BIT_PACK_ESP),1)
#
#   libmod_esp
#
DEPS_51 += $(CONFIG)/bin/libappweb.so
DEPS_51 += $(CONFIG)/inc/edi.h
DEPS_51 += $(CONFIG)/inc/esp-app.h
DEPS_51 += $(CONFIG)/inc/esp.h
DEPS_51 += $(CONFIG)/inc/mdb.h
DEPS_51 += $(CONFIG)/obj/edi.o
DEPS_51 += $(CONFIG)/obj/esp.o
DEPS_51 += $(CONFIG)/obj/espAbbrev.o
DEPS_51 += $(CONFIG)/obj/espFramework.o
DEPS_51 += $(CONFIG)/obj/espHandler.o
DEPS_51 += $(CONFIG)/obj/espHtml.o
DEPS_51 += $(CONFIG)/obj/espTemplate.o
DEPS_51 += $(CONFIG)/obj/mdb.o
DEPS_51 += $(CONFIG)/obj/sdb.o

LIBS_51 += -lappweb
LIBS_51 += -lhttp
LIBS_51 += -lpcre
LIBS_51 += -lmpr

$(CONFIG)/bin/libmod_esp.so: $(DEPS_51)
	@echo '      [Link] libmod_esp'
	$(CC) -shared -o $(CONFIG)/bin/libmod_esp.so $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/edi.o $(CONFIG)/obj/esp.o $(CONFIG)/obj/espAbbrev.o $(CONFIG)/obj/espFramework.o $(CONFIG)/obj/espHandler.o $(CONFIG)/obj/espHtml.o $(CONFIG)/obj/espTemplate.o $(CONFIG)/obj/mdb.o $(CONFIG)/obj/sdb.o $(LIBS_51) $(LIBS_51) $(LIBS) -lmpr
endif

ifeq ($(BIT_PACK_ESP),1)
#
#   esp
#
DEPS_52 += $(CONFIG)/bin/libappweb.so
DEPS_52 += $(CONFIG)/obj/edi.o
DEPS_52 += $(CONFIG)/obj/esp.o
DEPS_52 += $(CONFIG)/obj/espAbbrev.o
DEPS_52 += $(CONFIG)/obj/espFramework.o
DEPS_52 += $(CONFIG)/obj/espHandler.o
DEPS_52 += $(CONFIG)/obj/espHtml.o
DEPS_52 += $(CONFIG)/obj/espTemplate.o
DEPS_52 += $(CONFIG)/obj/mdb.o
DEPS_52 += $(CONFIG)/obj/sdb.o

LIBS_52 += -lappweb
LIBS_52 += -lhttp
LIBS_52 += -lpcre
LIBS_52 += -lmpr

$(CONFIG)/bin/esp: $(DEPS_52)
	@echo '      [Link] esp'
	$(CC) -o $(CONFIG)/bin/esp $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/edi.o $(CONFIG)/obj/esp.o $(CONFIG)/obj/espAbbrev.o $(CONFIG)/obj/espFramework.o $(CONFIG)/obj/espHandler.o $(CONFIG)/obj/espHtml.o $(CONFIG)/obj/espTemplate.o $(CONFIG)/obj/mdb.o $(CONFIG)/obj/sdb.o $(LIBS_52) $(LIBS_52) $(LIBS) -lmpr $(LDFLAGS)
endif

ifeq ($(BIT_PACK_ESP),1)
#
#   esp.conf
#
DEPS_53 += src/esp/esp.conf

$(CONFIG)/bin/esp.conf: $(DEPS_53)
	@echo '      [File] linux-x86-default/bin/esp.conf'
	mkdir -p "$(CONFIG)/bin"
	cp "src/esp/esp.conf" "$(CONFIG)/bin/esp.conf"
endif

ifeq ($(BIT_PACK_ESP),1)
#
#   esp.conf.server
#
DEPS_54 += src/esp/esp.conf

src/server/esp.conf: $(DEPS_54)
	@echo '      [File] src/server/esp.conf'
	mkdir -p "src/server"
	cp "src/esp/esp.conf" "src/server/esp.conf"
endif

ifeq ($(BIT_PACK_ESP),1)
#
#   esp.www
#
DEPS_55 += src/esp/esp-www

$(CONFIG)/bin/esp-www: $(DEPS_55)
	@echo '      [File] linux-x86-default/bin/esp-www'
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
endif

ifeq ($(BIT_PACK_ESP),1)
#
#   esp-appweb.conf
#
DEPS_56 += src/esp/esp-appweb.conf

$(CONFIG)/bin/esp-appweb.conf: $(DEPS_56)
	@echo '      [File] linux-x86-default/bin/esp-appweb.conf'
	mkdir -p "$(CONFIG)/bin"
	cp "src/esp/esp-appweb.conf" "$(CONFIG)/bin/esp-appweb.conf"
endif

#
#   ejs.h
#
$(CONFIG)/inc/ejs.h: $(DEPS_57)
	@echo '      [File] linux-x86-default/inc/ejs.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/deps/ejs/ejs.h" "$(CONFIG)/inc/ejs.h"

#
#   ejs.slots.h
#
$(CONFIG)/inc/ejs.slots.h: $(DEPS_58)
	@echo '      [File] linux-x86-default/inc/ejs.slots.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/deps/ejs/ejs.slots.h" "$(CONFIG)/inc/ejs.slots.h"

#
#   ejsByteGoto.h
#
$(CONFIG)/inc/ejsByteGoto.h: $(DEPS_59)
	@echo '      [File] linux-x86-default/inc/ejsByteGoto.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/deps/ejs/ejsByteGoto.h" "$(CONFIG)/inc/ejsByteGoto.h"

#
#   ejsLib.o
#
DEPS_60 += $(CONFIG)/inc/bit.h
DEPS_60 += $(CONFIG)/inc/ejs.h
DEPS_60 += $(CONFIG)/inc/mpr.h
DEPS_60 += $(CONFIG)/inc/pcre.h
DEPS_60 += $(CONFIG)/inc/bitos.h
DEPS_60 += $(CONFIG)/inc/http.h
DEPS_60 += $(CONFIG)/inc/ejs.slots.h

$(CONFIG)/obj/ejsLib.o: \
    src/deps/ejs/ejsLib.c $(DEPS_60)
	@echo '   [Compile] src/deps/ejs/ejsLib.c'
	$(CC) -c -o $(CONFIG)/obj/ejsLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/ejs/ejsLib.c

ifeq ($(BIT_PACK_EJSCRIPT),1)
#
#   libejs
#
DEPS_61 += $(CONFIG)/bin/libhttp.so
DEPS_61 += $(CONFIG)/bin/libpcre.so
DEPS_61 += $(CONFIG)/bin/libmpr.so
ifeq ($(BIT_PACK_SQLITE),1)
    DEPS_61 += $(CONFIG)/bin/libsqlite3.so
endif
DEPS_61 += $(CONFIG)/inc/ejs.h
DEPS_61 += $(CONFIG)/inc/ejs.slots.h
DEPS_61 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_61 += $(CONFIG)/obj/ejsLib.o

ifeq ($(BIT_PACK_SQLITE),1)
    LIBS_61 += -lsqlite3
endif
LIBS_61 += -lmpr
LIBS_61 += -lpcre
LIBS_61 += -lhttp
LIBS_61 += -lpcre
LIBS_61 += -lmpr

$(CONFIG)/bin/libejs.so: $(DEPS_61)
	@echo '      [Link] libejs'
	$(CC) -shared -o $(CONFIG)/bin/libejs.so $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/ejsLib.o $(LIBS_61) $(LIBS_61) $(LIBS) -lmpr
endif

#
#   ejs.o
#
DEPS_62 += $(CONFIG)/inc/bit.h
DEPS_62 += $(CONFIG)/inc/ejs.h

$(CONFIG)/obj/ejs.o: \
    src/deps/ejs/ejs.c $(DEPS_62)
	@echo '   [Compile] src/deps/ejs/ejs.c'
	$(CC) -c -o $(CONFIG)/obj/ejs.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/ejs/ejs.c

ifeq ($(BIT_PACK_EJSCRIPT),1)
#
#   ejs
#
ifeq ($(BIT_PACK_EJSCRIPT),1)
    DEPS_63 += $(CONFIG)/bin/libejs.so
endif
DEPS_63 += $(CONFIG)/obj/ejs.o

ifeq ($(BIT_PACK_EJSCRIPT),1)
    LIBS_63 += -lejs
endif
ifeq ($(BIT_PACK_SQLITE),1)
    LIBS_63 += -lsqlite3
endif
LIBS_63 += -lmpr
LIBS_63 += -lpcre
LIBS_63 += -lhttp

$(CONFIG)/bin/ejs: $(DEPS_63)
	@echo '      [Link] ejs'
	$(CC) -o $(CONFIG)/bin/ejs $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/ejs.o $(LIBS_63) $(LIBS_63) $(LIBS) -lhttp $(LDFLAGS)
endif

#
#   ejsc.o
#
DEPS_64 += $(CONFIG)/inc/bit.h
DEPS_64 += $(CONFIG)/inc/ejs.h

$(CONFIG)/obj/ejsc.o: \
    src/deps/ejs/ejsc.c $(DEPS_64)
	@echo '   [Compile] src/deps/ejs/ejsc.c'
	$(CC) -c -o $(CONFIG)/obj/ejsc.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/ejs/ejsc.c

ifeq ($(BIT_PACK_EJSCRIPT),1)
#
#   ejsc
#
ifeq ($(BIT_PACK_EJSCRIPT),1)
    DEPS_65 += $(CONFIG)/bin/libejs.so
endif
DEPS_65 += $(CONFIG)/obj/ejsc.o

ifeq ($(BIT_PACK_EJSCRIPT),1)
    LIBS_65 += -lejs
endif
ifeq ($(BIT_PACK_SQLITE),1)
    LIBS_65 += -lsqlite3
endif
LIBS_65 += -lmpr
LIBS_65 += -lpcre
LIBS_65 += -lhttp

$(CONFIG)/bin/ejsc: $(DEPS_65)
	@echo '      [Link] ejsc'
	$(CC) -o $(CONFIG)/bin/ejsc $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/ejsc.o $(LIBS_65) $(LIBS_65) $(LIBS) -lhttp $(LDFLAGS)
endif

ifeq ($(BIT_PACK_EJSCRIPT),1)
#
#   ejs.mod
#
ifeq ($(BIT_PACK_EJSCRIPT),1)
    DEPS_66 += $(CONFIG)/bin/ejsc
endif

$(CONFIG)/bin/ejs.mod: $(DEPS_66)
	$(LBIN)/ejsc --out ./$(CONFIG)/bin/ejs.mod --optimize 9 --bind --require null src/deps/ejs/ejs.es
endif

#
#   cgiHandler.o
#
DEPS_67 += $(CONFIG)/inc/bit.h
DEPS_67 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/cgiHandler.o: \
    src/modules/cgiHandler.c $(DEPS_67)
	@echo '   [Compile] src/modules/cgiHandler.c'
	$(CC) -c -o $(CONFIG)/obj/cgiHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/modules/cgiHandler.c

ifeq ($(BIT_PACK_CGI),1)
#
#   libmod_cgi
#
DEPS_68 += $(CONFIG)/bin/libappweb.so
DEPS_68 += $(CONFIG)/obj/cgiHandler.o

LIBS_68 += -lappweb
LIBS_68 += -lhttp
LIBS_68 += -lpcre
LIBS_68 += -lmpr

$(CONFIG)/bin/libmod_cgi.so: $(DEPS_68)
	@echo '      [Link] libmod_cgi'
	$(CC) -shared -o $(CONFIG)/bin/libmod_cgi.so $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/cgiHandler.o $(LIBS_68) $(LIBS_68) $(LIBS) -lmpr
endif

#
#   ejsHandler.o
#
DEPS_69 += $(CONFIG)/inc/bit.h
DEPS_69 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/ejsHandler.o: \
    src/modules/ejsHandler.c $(DEPS_69)
	@echo '   [Compile] src/modules/ejsHandler.c'
	$(CC) -c -o $(CONFIG)/obj/ejsHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/modules/ejsHandler.c

ifeq ($(BIT_PACK_EJSCRIPT),1)
#
#   libmod_ejs
#
DEPS_70 += $(CONFIG)/bin/libappweb.so
ifeq ($(BIT_PACK_EJSCRIPT),1)
    DEPS_70 += $(CONFIG)/bin/libejs.so
endif
DEPS_70 += $(CONFIG)/obj/ejsHandler.o

ifeq ($(BIT_PACK_EJSCRIPT),1)
    LIBS_70 += -lejs
endif
LIBS_70 += -lappweb
LIBS_70 += -lhttp
LIBS_70 += -lpcre
LIBS_70 += -lmpr
ifeq ($(BIT_PACK_SQLITE),1)
    LIBS_70 += -lsqlite3
endif

$(CONFIG)/bin/libmod_ejs.so: $(DEPS_70)
	@echo '      [Link] libmod_ejs'
	$(CC) -shared -o $(CONFIG)/bin/libmod_ejs.so $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/ejsHandler.o $(LIBS_70) $(LIBS_70) $(LIBS) -lsqlite3
endif

#
#   sslModule.o
#
DEPS_71 += $(CONFIG)/inc/bit.h
DEPS_71 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/sslModule.o: \
    src/modules/sslModule.c $(DEPS_71)
	@echo '   [Compile] src/modules/sslModule.c'
	$(CC) -c -o $(CONFIG)/obj/sslModule.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/modules/sslModule.c

#
#   libmod_ssl
#
DEPS_72 += $(CONFIG)/bin/libappweb.so
DEPS_72 += $(CONFIG)/obj/sslModule.o

LIBS_72 += -lappweb
LIBS_72 += -lhttp
LIBS_72 += -lpcre
LIBS_72 += -lmpr

$(CONFIG)/bin/libmod_ssl.so: $(DEPS_72)
	@echo '      [Link] libmod_ssl'
	$(CC) -shared -o $(CONFIG)/bin/libmod_ssl.so $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/sslModule.o $(LIBS_72) $(LIBS_72) $(LIBS) -lmpr

#
#   authpass.o
#
DEPS_73 += $(CONFIG)/inc/bit.h
DEPS_73 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/authpass.o: \
    src/utils/authpass.c $(DEPS_73)
	@echo '   [Compile] src/utils/authpass.c'
	$(CC) -c -o $(CONFIG)/obj/authpass.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/utils/authpass.c

#
#   authpass
#
DEPS_74 += $(CONFIG)/bin/libappweb.so
DEPS_74 += $(CONFIG)/obj/authpass.o

LIBS_74 += -lappweb
LIBS_74 += -lhttp
LIBS_74 += -lpcre
LIBS_74 += -lmpr

$(CONFIG)/bin/authpass: $(DEPS_74)
	@echo '      [Link] authpass'
	$(CC) -o $(CONFIG)/bin/authpass $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/authpass.o $(LIBS_74) $(LIBS_74) $(LIBS) -lmpr $(LDFLAGS)

#
#   cgiProgram.o
#
DEPS_75 += $(CONFIG)/inc/bit.h

$(CONFIG)/obj/cgiProgram.o: \
    src/utils/cgiProgram.c $(DEPS_75)
	@echo '   [Compile] src/utils/cgiProgram.c'
	$(CC) -c -o $(CONFIG)/obj/cgiProgram.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/utils/cgiProgram.c

ifeq ($(BIT_PACK_CGI),1)
#
#   cgiProgram
#
DEPS_76 += $(CONFIG)/obj/cgiProgram.o

$(CONFIG)/bin/cgiProgram: $(DEPS_76)
	@echo '      [Link] cgiProgram'
	$(CC) -o $(CONFIG)/bin/cgiProgram $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/cgiProgram.o $(LIBS) $(LDFLAGS)
endif

#
#   slink.c
#
src/server/slink.c: $(DEPS_77)
	cd src/server; [ ! -f slink.c ] && cp slink.empty slink.c ; true ; cd ../..

#
#   slink.o
#
DEPS_78 += $(CONFIG)/inc/bit.h
DEPS_78 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/slink.o: \
    src/server/slink.c $(DEPS_78)
	@echo '   [Compile] src/server/slink.c'
	$(CC) -c -o $(CONFIG)/obj/slink.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/server/slink.c

#
#   libapp
#
DEPS_79 += src/server/slink.c
ifeq ($(BIT_PACK_ESP),1)
    DEPS_79 += $(CONFIG)/bin/esp
endif
ifeq ($(BIT_PACK_ESP),1)
    DEPS_79 += $(CONFIG)/bin/libmod_esp.so
endif
DEPS_79 += $(CONFIG)/obj/slink.o

ifeq ($(BIT_PACK_ESP),1)
    LIBS_79 += -lmod_esp
endif
LIBS_79 += -lappweb
LIBS_79 += -lhttp
LIBS_79 += -lpcre
LIBS_79 += -lmpr

$(CONFIG)/bin/libapp.so: $(DEPS_79)
	@echo '      [Link] libapp'
	$(CC) -shared -o $(CONFIG)/bin/libapp.so $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/slink.o $(LIBS_79) $(LIBS_79) $(LIBS) -lmpr

#
#   appweb.o
#
DEPS_80 += $(CONFIG)/inc/bit.h
DEPS_80 += $(CONFIG)/inc/appweb.h
DEPS_80 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/appweb.o: \
    src/server/appweb.c $(DEPS_80)
	@echo '   [Compile] src/server/appweb.c'
	$(CC) -c -o $(CONFIG)/obj/appweb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/server/appweb.c

#
#   appweb
#
DEPS_81 += $(CONFIG)/bin/libappweb.so
ifeq ($(BIT_PACK_ESP),1)
    DEPS_81 += $(CONFIG)/bin/libmod_esp.so
endif
DEPS_81 += $(CONFIG)/bin/libmod_ssl.so
ifeq ($(BIT_PACK_EJSCRIPT),1)
    DEPS_81 += $(CONFIG)/bin/libmod_ejs.so
endif
ifeq ($(BIT_PACK_CGI),1)
    DEPS_81 += $(CONFIG)/bin/libmod_cgi.so
endif
DEPS_81 += $(CONFIG)/bin/libapp.so
DEPS_81 += $(CONFIG)/obj/appweb.o

LIBS_81 += -lapp
ifeq ($(BIT_PACK_CGI),1)
    LIBS_81 += -lmod_cgi
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
    LIBS_81 += -lmod_ejs
endif
LIBS_81 += -lmod_ssl
ifeq ($(BIT_PACK_ESP),1)
    LIBS_81 += -lmod_esp
endif
LIBS_81 += -lappweb
LIBS_81 += -lhttp
LIBS_81 += -lpcre
LIBS_81 += -lmpr
ifeq ($(BIT_PACK_EJSCRIPT),1)
    LIBS_81 += -lejs
endif
ifeq ($(BIT_PACK_SQLITE),1)
    LIBS_81 += -lsqlite3
endif

$(CONFIG)/bin/appweb: $(DEPS_81)
	@echo '      [Link] appweb'
	$(CC) -o $(CONFIG)/bin/appweb $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/appweb.o $(LIBS_81) $(LIBS_81) $(LIBS) -lsqlite3 $(LDFLAGS)

#
#   server-cache
#
src/server/cache: $(DEPS_82)
	cd src/server; mkdir -p cache ; cd ../..

#
#   testAppweb.h
#
$(CONFIG)/inc/testAppweb.h: $(DEPS_83)
	@echo '      [File] linux-x86-default/inc/testAppweb.h'
	mkdir -p "$(CONFIG)/inc"
	cp "test/testAppweb.h" "$(CONFIG)/inc/testAppweb.h"

#
#   testAppweb.o
#
DEPS_84 += $(CONFIG)/inc/bit.h
DEPS_84 += $(CONFIG)/inc/testAppweb.h
DEPS_84 += $(CONFIG)/inc/mpr.h
DEPS_84 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/testAppweb.o: \
    test/testAppweb.c $(DEPS_84)
	@echo '   [Compile] test/testAppweb.c'
	$(CC) -c -o $(CONFIG)/obj/testAppweb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) test/testAppweb.c

#
#   testHttp.o
#
DEPS_85 += $(CONFIG)/inc/bit.h
DEPS_85 += $(CONFIG)/inc/testAppweb.h

$(CONFIG)/obj/testHttp.o: \
    test/testHttp.c $(DEPS_85)
	@echo '   [Compile] test/testHttp.c'
	$(CC) -c -o $(CONFIG)/obj/testHttp.o $(CFLAGS) $(DFLAGS) $(IFLAGS) test/testHttp.c

#
#   testAppweb
#
DEPS_86 += $(CONFIG)/bin/libappweb.so
DEPS_86 += $(CONFIG)/inc/testAppweb.h
DEPS_86 += $(CONFIG)/obj/testAppweb.o
DEPS_86 += $(CONFIG)/obj/testHttp.o

LIBS_86 += -lappweb
LIBS_86 += -lhttp
LIBS_86 += -lpcre
LIBS_86 += -lmpr

$(CONFIG)/bin/testAppweb: $(DEPS_86)
	@echo '      [Link] testAppweb'
	$(CC) -o $(CONFIG)/bin/testAppweb $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/testAppweb.o $(CONFIG)/obj/testHttp.o $(LIBS_86) $(LIBS_86) $(LIBS) -lmpr $(LDFLAGS)

ifeq ($(BIT_PACK_CGI),1)
#
#   test-testScript
#
ifeq ($(BIT_PACK_CGI),1)
    DEPS_87 += $(CONFIG)/bin/cgiProgram
endif

test/cgi-bin/testScript: $(DEPS_87)
	cd test; echo '#!../$(CONFIG)/bin/cgiProgram' >cgi-bin/testScript ; chmod +x cgi-bin/testScript ; cd ..
endif

ifeq ($(BIT_PACK_CGI),1)
#
#   test-cache.cgi
#
test/web/caching/cache.cgi: $(DEPS_88)
	cd test; echo "#!`type -p ejs`" >web/caching/cache.cgi ; cd ..
	cd test; echo 'print("HTTP/1.0 200 OK\nContent-Type: text/plain\n\n" + Date() + "\n")' >>web/caching/cache.cgi ; cd ..
	cd test; chmod +x web/caching/cache.cgi ; cd ..
endif

ifeq ($(BIT_PACK_CGI),1)
#
#   test-basic.cgi
#
test/web/auth/basic/basic.cgi: $(DEPS_89)
	cd test; echo "#!`type -p ejs`" >web/auth/basic/basic.cgi ; cd ..
	cd test; echo 'print("HTTP/1.0 200 OK\nContent-Type: text/plain\n\n" + serialize(App.env, {pretty: true}) + "\n")' >>web/auth/basic/basic.cgi ; cd ..
	cd test; chmod +x web/auth/basic/basic.cgi ; cd ..
endif

ifeq ($(BIT_PACK_CGI),1)
#
#   test-cgiProgram
#
ifeq ($(BIT_PACK_CGI),1)
    DEPS_90 += $(CONFIG)/bin/cgiProgram
endif

test/cgi-bin/cgiProgram: $(DEPS_90)
	cd test; cp ../$(CONFIG)/bin/cgiProgram cgi-bin/cgiProgram ; cd ..
	cd test; cp ../$(CONFIG)/bin/cgiProgram cgi-bin/nph-cgiProgram ; cd ..
	cd test; cp ../$(CONFIG)/bin/cgiProgram 'cgi-bin/cgi Program' ; cd ..
	cd test; cp ../$(CONFIG)/bin/cgiProgram web/cgiProgram.cgi ; cd ..
	cd test; chmod +x cgi-bin/* web/cgiProgram.cgi ; cd ..
endif

#
#   test.js
#
DEPS_91 += src/esp/esp-www/files/static/js

test/web/js: $(DEPS_91)
	@echo '      [File] test/web/js'
	mkdir -p "test/web/js"
	cp "src/esp/esp-www/files/static/js/jquery.esp.js" "test/web/js/jquery.esp.js"
	cp "src/esp/esp-www/files/static/js/jquery.js" "test/web/js/jquery.js"
	cp "src/esp/esp-www/files/static/js/jquery.simplemodal.js" "test/web/js/jquery.simplemodal.js"
	cp "src/esp/esp-www/files/static/js/jquery.tablesorter.js" "test/web/js/jquery.tablesorter.js"

#
#   version
#
version: $(DEPS_92)
	@echo 4.3.0-0


#
#   stop
#
DEPS_93 += compile

stop: $(DEPS_93)
	@./$(CONFIG)/bin/appman stop disable uninstall >/dev/null 2>&1 ; true

#
#   installBinary
#
DEPS_94 += stop

installBinary: $(DEPS_94)
	rm -f "$(BIT_APP_PREFIX)/latest"
	mkdir -p "$(BIT_APP_PREFIX)"
	ln -s "4.3.0" "$(BIT_APP_PREFIX)/latest"
	mkdir -p "$(BIT_LOG_PREFIX)"
	chmod 755 "$(BIT_LOG_PREFIX)"
	[ `id -u` = 0 ] && chown $(WEB_USER):$(WEB_GROUP) "$(BIT_LOG_PREFIX)"
	mkdir -p "$(BIT_CACHE_PREFIX)"
	chmod 755 "$(BIT_CACHE_PREFIX)"
	[ `id -u` = 0 ] && chown $(WEB_USER):$(WEB_GROUP) "$(BIT_CACHE_PREFIX)"
	mkdir -p "$(BIT_VAPP_PREFIX)/bin"
	cp "$(CONFIG)/bin/appman" "$(BIT_VAPP_PREFIX)/bin/appman"
	rm -f "$(BIT_BIN_PREFIX)/appman"
	mkdir -p "$(BIT_BIN_PREFIX)"
	ln -s "$(BIT_VAPP_PREFIX)/bin/appman" "$(BIT_BIN_PREFIX)/appman"
	cp "$(CONFIG)/bin/appweb" "$(BIT_VAPP_PREFIX)/bin/appweb"
	rm -f "$(BIT_BIN_PREFIX)/appweb"
	ln -s "$(BIT_VAPP_PREFIX)/bin/appweb" "$(BIT_BIN_PREFIX)/appweb"
	cp "$(CONFIG)/bin/http" "$(BIT_VAPP_PREFIX)/bin/http"
	rm -f "$(BIT_BIN_PREFIX)/http"
	ln -s "$(BIT_VAPP_PREFIX)/bin/http" "$(BIT_BIN_PREFIX)/http"
ifeq ($(BIT_PACK_ESP),1)
	cp "$(CONFIG)/bin/esp" "$(BIT_VAPP_PREFIX)/bin/esp"
	rm -f "$(BIT_BIN_PREFIX)/esp"
	ln -s "$(BIT_VAPP_PREFIX)/bin/esp" "$(BIT_BIN_PREFIX)/esp"
endif
	cp "$(CONFIG)/bin/libapp.so" "$(BIT_VAPP_PREFIX)/bin/libapp.so"
	cp "$(CONFIG)/bin/libappweb.so" "$(BIT_VAPP_PREFIX)/bin/libappweb.so"
	cp "$(CONFIG)/bin/libhttp.so" "$(BIT_VAPP_PREFIX)/bin/libhttp.so"
	cp "$(CONFIG)/bin/libmod_ssl.so" "$(BIT_VAPP_PREFIX)/bin/libmod_ssl.so"
	cp "$(CONFIG)/bin/libmpr.so" "$(BIT_VAPP_PREFIX)/bin/libmpr.so"
	cp "$(CONFIG)/bin/libmprssl.so" "$(BIT_VAPP_PREFIX)/bin/libmprssl.so"
	cp "$(CONFIG)/bin/libpcre.so" "$(BIT_VAPP_PREFIX)/bin/libpcre.so"
	cp "$(CONFIG)/bin/ca.crt" "$(BIT_VAPP_PREFIX)/bin/ca.crt"
ifeq ($(BIT_PACK_EST),1)
	cp "$(CONFIG)/bin/libest.so" "$(BIT_VAPP_PREFIX)/bin/libest.so"
endif
ifeq ($(BIT_PACK_SQLITE),1)
	cp "$(CONFIG)/bin/libsqlite3.so" "$(BIT_VAPP_PREFIX)/bin/libsqlite3.so"
endif
ifeq ($(BIT_PACK_ESP),1)
	cp "$(CONFIG)/bin/libmod_esp.so" "$(BIT_VAPP_PREFIX)/bin/libmod_esp.so"
endif
ifeq ($(BIT_PACK_CGI),1)
	cp "$(CONFIG)/bin/libmod_cgi.so" "$(BIT_VAPP_PREFIX)/bin/libmod_cgi.so"
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
	cp "$(CONFIG)/bin/libejs.so" "$(BIT_VAPP_PREFIX)/bin/libejs.so"
	cp "$(CONFIG)/bin/libmod_ejs.so" "$(BIT_VAPP_PREFIX)/bin/libmod_ejs.so"
endif
ifeq ($(BIT_PACK_ESP),1)
	cp "$(CONFIG)/bin/libmod_esp.so" "$(BIT_VAPP_PREFIX)/bin/libmod_esp.so"
	cp "$(CONFIG)/bin/libappweb.so" "$(BIT_VAPP_PREFIX)/bin/libappweb.so"
	cp "$(CONFIG)/bin/libpcre.so" "$(BIT_VAPP_PREFIX)/bin/libpcre.so"
	cp "$(CONFIG)/bin/libhttp.so" "$(BIT_VAPP_PREFIX)/bin/libhttp.so"
	cp "$(CONFIG)/bin/libmpr.so" "$(BIT_VAPP_PREFIX)/bin/libmpr.so"
endif
ifeq ($(BIT_PACK_ESP),1)
	mkdir -p "$(BIT_VAPP_PREFIX)/bin/esp-www"
	cp "src/esp/esp-www/app.conf" "$(BIT_VAPP_PREFIX)/bin/esp-www/app.conf"
	cp "src/esp/esp-www/appweb.conf" "$(BIT_VAPP_PREFIX)/bin/esp-www/appweb.conf"
	mkdir -p "$(BIT_VAPP_PREFIX)/bin/esp-www/files/layouts"
	cp "src/esp/esp-www/files/layouts/default.esp" "$(BIT_VAPP_PREFIX)/bin/esp-www/files/layouts/default.esp"
	mkdir -p "$(BIT_VAPP_PREFIX)/bin/esp-www/files/static/images"
	cp "src/esp/esp-www/files/static/images/banner.jpg" "$(BIT_VAPP_PREFIX)/bin/esp-www/files/static/images/banner.jpg"
	cp "src/esp/esp-www/files/static/images/favicon.ico" "$(BIT_VAPP_PREFIX)/bin/esp-www/files/static/images/favicon.ico"
	cp "src/esp/esp-www/files/static/images/splash.jpg" "$(BIT_VAPP_PREFIX)/bin/esp-www/files/static/images/splash.jpg"
	mkdir -p "$(BIT_VAPP_PREFIX)/bin/esp-www/files/static"
	cp "src/esp/esp-www/files/static/index.esp" "$(BIT_VAPP_PREFIX)/bin/esp-www/files/static/index.esp"
	mkdir -p "$(BIT_VAPP_PREFIX)/bin/esp-www/files/static/js"
	cp "src/esp/esp-www/files/static/js/jquery.esp.js" "$(BIT_VAPP_PREFIX)/bin/esp-www/files/static/js/jquery.esp.js"
	cp "src/esp/esp-www/files/static/js/jquery.js" "$(BIT_VAPP_PREFIX)/bin/esp-www/files/static/js/jquery.js"
	cp "src/esp/esp-www/files/static/js/jquery.simplemodal.js" "$(BIT_VAPP_PREFIX)/bin/esp-www/files/static/js/jquery.simplemodal.js"
	cp "src/esp/esp-www/files/static/js/jquery.tablesorter.js" "$(BIT_VAPP_PREFIX)/bin/esp-www/files/static/js/jquery.tablesorter.js"
	cp "src/esp/esp-www/files/static/layout.css" "$(BIT_VAPP_PREFIX)/bin/esp-www/files/static/layout.css"
	mkdir -p "$(BIT_VAPP_PREFIX)/bin/esp-www/files/static/themes"
	cp "src/esp/esp-www/files/static/themes/default.css" "$(BIT_VAPP_PREFIX)/bin/esp-www/files/static/themes/default.css"
	cp "src/esp/esp-appweb.conf" "$(BIT_VAPP_PREFIX)/bin/esp-appweb.conf"
endif
ifeq ($(BIT_PACK_ESP),1)
	mkdir -p "$(BIT_ETC_PREFIX)"
	cp "$(CONFIG)/bin/esp.conf" "$(BIT_ETC_PREFIX)/esp.conf"
endif
	mkdir -p "$(BIT_WEB_PREFIX)/bench"
	cp "src/server/web/bench/1b.html" "$(BIT_WEB_PREFIX)/bench/1b.html"
	cp "src/server/web/bench/4k.html" "$(BIT_WEB_PREFIX)/bench/4k.html"
	cp "src/server/web/bench/64k.html" "$(BIT_WEB_PREFIX)/bench/64k.html"
	mkdir -p "$(BIT_WEB_PREFIX)"
	cp "src/server/web/favicon.ico" "$(BIT_WEB_PREFIX)/favicon.ico"
	mkdir -p "$(BIT_WEB_PREFIX)/icons"
	cp "src/server/web/icons/back.gif" "$(BIT_WEB_PREFIX)/icons/back.gif"
	cp "src/server/web/icons/blank.gif" "$(BIT_WEB_PREFIX)/icons/blank.gif"
	cp "src/server/web/icons/compressed.gif" "$(BIT_WEB_PREFIX)/icons/compressed.gif"
	cp "src/server/web/icons/folder.gif" "$(BIT_WEB_PREFIX)/icons/folder.gif"
	cp "src/server/web/icons/parent.gif" "$(BIT_WEB_PREFIX)/icons/parent.gif"
	cp "src/server/web/icons/space.gif" "$(BIT_WEB_PREFIX)/icons/space.gif"
	cp "src/server/web/icons/text.gif" "$(BIT_WEB_PREFIX)/icons/text.gif"
	cp "src/server/web/iehacks.css" "$(BIT_WEB_PREFIX)/iehacks.css"
	mkdir -p "$(BIT_WEB_PREFIX)/images"
	cp "src/server/web/images/banner.jpg" "$(BIT_WEB_PREFIX)/images/banner.jpg"
	cp "src/server/web/images/bottomShadow.jpg" "$(BIT_WEB_PREFIX)/images/bottomShadow.jpg"
	cp "src/server/web/images/shadow.jpg" "$(BIT_WEB_PREFIX)/images/shadow.jpg"
	cp "src/server/web/index.html" "$(BIT_WEB_PREFIX)/index.html"
	cp "src/server/web/min-index.html" "$(BIT_WEB_PREFIX)/min-index.html"
	cp "src/server/web/print.css" "$(BIT_WEB_PREFIX)/print.css"
	cp "src/server/web/screen.css" "$(BIT_WEB_PREFIX)/screen.css"
	mkdir -p "$(BIT_WEB_PREFIX)/test"
	cp "src/server/web/test/bench.html" "$(BIT_WEB_PREFIX)/test/bench.html"
	cp "src/server/web/test/test.cgi" "$(BIT_WEB_PREFIX)/test/test.cgi"
	cp "src/server/web/test/test.ejs" "$(BIT_WEB_PREFIX)/test/test.ejs"
	cp "src/server/web/test/test.esp" "$(BIT_WEB_PREFIX)/test/test.esp"
	cp "src/server/web/test/test.html" "$(BIT_WEB_PREFIX)/test/test.html"
	cp "src/server/web/test/test.php" "$(BIT_WEB_PREFIX)/test/test.php"
	cp "src/server/web/test/test.pl" "$(BIT_WEB_PREFIX)/test/test.pl"
	cp "src/server/web/test/test.py" "$(BIT_WEB_PREFIX)/test/test.py"
	cp "src/server/mime.types" "$(BIT_ETC_PREFIX)/mime.types"
	cp "src/server/appweb.conf" "$(BIT_ETC_PREFIX)/appweb.conf"
	mkdir -p "$(BIT_VAPP_PREFIX)/inc"
	cp "$(CONFIG)/inc/bit.h" "$(BIT_VAPP_PREFIX)/inc/bit.h"
	rm -f "$(BIT_INC_PREFIX)/appweb/bit.h"
	mkdir -p "$(BIT_INC_PREFIX)/appweb"
	ln -s "$(BIT_VAPP_PREFIX)/inc/bit.h" "$(BIT_INC_PREFIX)/appweb/bit.h"
	cp "src/bitos.h" "$(BIT_VAPP_PREFIX)/inc/bitos.h"
	rm -f "$(BIT_INC_PREFIX)/appweb/bitos.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/bitos.h" "$(BIT_INC_PREFIX)/appweb/bitos.h"
	cp "src/appweb.h" "$(BIT_VAPP_PREFIX)/inc/appweb.h"
	rm -f "$(BIT_INC_PREFIX)/appweb/appweb.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/appweb.h" "$(BIT_INC_PREFIX)/appweb/appweb.h"
	cp "src/customize.h" "$(BIT_VAPP_PREFIX)/inc/customize.h"
	rm -f "$(BIT_INC_PREFIX)/appweb/customize.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/customize.h" "$(BIT_INC_PREFIX)/appweb/customize.h"
	cp "src/deps/est/est.h" "$(BIT_VAPP_PREFIX)/inc/est.h"
	rm -f "$(BIT_INC_PREFIX)/appweb/est.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/est.h" "$(BIT_INC_PREFIX)/appweb/est.h"
	cp "src/deps/http/http.h" "$(BIT_VAPP_PREFIX)/inc/http.h"
	rm -f "$(BIT_INC_PREFIX)/appweb/http.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/http.h" "$(BIT_INC_PREFIX)/appweb/http.h"
	cp "src/deps/mpr/mpr.h" "$(BIT_VAPP_PREFIX)/inc/mpr.h"
	rm -f "$(BIT_INC_PREFIX)/appweb/mpr.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/mpr.h" "$(BIT_INC_PREFIX)/appweb/mpr.h"
	cp "src/deps/pcre/pcre.h" "$(BIT_VAPP_PREFIX)/inc/pcre.h"
	rm -f "$(BIT_INC_PREFIX)/appweb/pcre.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/pcre.h" "$(BIT_INC_PREFIX)/appweb/pcre.h"
	cp "src/deps/sqlite/sqlite3.h" "$(BIT_VAPP_PREFIX)/inc/sqlite3.h"
	rm -f "$(BIT_INC_PREFIX)/appweb/sqlite3.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/sqlite3.h" "$(BIT_INC_PREFIX)/appweb/sqlite3.h"
ifeq ($(BIT_PACK_ESP),1)
	cp "src/esp/edi.h" "$(BIT_VAPP_PREFIX)/inc/edi.h"
	rm -f "$(BIT_INC_PREFIX)/appweb/edi.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/edi.h" "$(BIT_INC_PREFIX)/appweb/edi.h"
	cp "src/esp/esp-app.h" "$(BIT_VAPP_PREFIX)/inc/esp-app.h"
	rm -f "$(BIT_INC_PREFIX)/appweb/esp-app.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/esp-app.h" "$(BIT_INC_PREFIX)/appweb/esp-app.h"
	cp "src/esp/esp.h" "$(BIT_VAPP_PREFIX)/inc/esp.h"
	rm -f "$(BIT_INC_PREFIX)/appweb/esp.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/esp.h" "$(BIT_INC_PREFIX)/appweb/esp.h"
	cp "src/esp/mdb.h" "$(BIT_VAPP_PREFIX)/inc/mdb.h"
	rm -f "$(BIT_INC_PREFIX)/appweb/mdb.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/mdb.h" "$(BIT_INC_PREFIX)/appweb/mdb.h"
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
	cp "src/deps/ejs/ejs.h" "$(BIT_VAPP_PREFIX)/inc/ejs.h"
	rm -f "$(BIT_INC_PREFIX)/appweb/ejs.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/ejs.h" "$(BIT_INC_PREFIX)/appweb/ejs.h"
	cp "src/deps/ejs/ejs.slots.h" "$(BIT_VAPP_PREFIX)/inc/ejs.slots.h"
	rm -f "$(BIT_INC_PREFIX)/appweb/ejs.slots.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/ejs.slots.h" "$(BIT_INC_PREFIX)/appweb/ejs.slots.h"
	cp "src/deps/ejs/ejsByteGoto.h" "$(BIT_VAPP_PREFIX)/inc/ejsByteGoto.h"
	rm -f "$(BIT_INC_PREFIX)/appweb/ejsByteGoto.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/ejsByteGoto.h" "$(BIT_INC_PREFIX)/appweb/ejsByteGoto.h"
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
	cp "$(CONFIG)/bin/ejs.mod" "$(BIT_VAPP_PREFIX)/bin/ejs.mod"
endif
	mkdir -p "$(BIT_VAPP_PREFIX)/doc/man1"
	cp "doc/man/appman.1" "$(BIT_VAPP_PREFIX)/doc/man1/appman.1"
	rm -f "$(BIT_MAN_PREFIX)/man1/appman.1"
	mkdir -p "$(BIT_MAN_PREFIX)/man1"
	ln -s "$(BIT_VAPP_PREFIX)/doc/man1/appman.1" "$(BIT_MAN_PREFIX)/man1/appman.1"
	cp "doc/man/appweb.1" "$(BIT_VAPP_PREFIX)/doc/man1/appweb.1"
	rm -f "$(BIT_MAN_PREFIX)/man1/appweb.1"
	ln -s "$(BIT_VAPP_PREFIX)/doc/man1/appweb.1" "$(BIT_MAN_PREFIX)/man1/appweb.1"
	cp "doc/man/appwebMonitor.1" "$(BIT_VAPP_PREFIX)/doc/man1/appwebMonitor.1"
	rm -f "$(BIT_MAN_PREFIX)/man1/appwebMonitor.1"
	ln -s "$(BIT_VAPP_PREFIX)/doc/man1/appwebMonitor.1" "$(BIT_MAN_PREFIX)/man1/appwebMonitor.1"
	cp "doc/man/authpass.1" "$(BIT_VAPP_PREFIX)/doc/man1/authpass.1"
	rm -f "$(BIT_MAN_PREFIX)/man1/authpass.1"
	ln -s "$(BIT_VAPP_PREFIX)/doc/man1/authpass.1" "$(BIT_MAN_PREFIX)/man1/authpass.1"
	cp "doc/man/esp.1" "$(BIT_VAPP_PREFIX)/doc/man1/esp.1"
	rm -f "$(BIT_MAN_PREFIX)/man1/esp.1"
	ln -s "$(BIT_VAPP_PREFIX)/doc/man1/esp.1" "$(BIT_MAN_PREFIX)/man1/esp.1"
	cp "doc/man/http.1" "$(BIT_VAPP_PREFIX)/doc/man1/http.1"
	rm -f "$(BIT_MAN_PREFIX)/man1/http.1"
	ln -s "$(BIT_VAPP_PREFIX)/doc/man1/http.1" "$(BIT_MAN_PREFIX)/man1/http.1"
	cp "doc/man/makerom.1" "$(BIT_VAPP_PREFIX)/doc/man1/makerom.1"
	rm -f "$(BIT_MAN_PREFIX)/man1/makerom.1"
	ln -s "$(BIT_VAPP_PREFIX)/doc/man1/makerom.1" "$(BIT_MAN_PREFIX)/man1/makerom.1"
	cp "doc/man/manager.1" "$(BIT_VAPP_PREFIX)/doc/man1/manager.1"
	rm -f "$(BIT_MAN_PREFIX)/man1/manager.1"
	ln -s "$(BIT_VAPP_PREFIX)/doc/man1/manager.1" "$(BIT_MAN_PREFIX)/man1/manager.1"
	mkdir -p "$(BIT_ROOT_PREFIX)/etc/init.d"
	cp "package/linux/appweb.init" "$(BIT_ROOT_PREFIX)/etc/init.d/appweb"
	[ `id -u` = 0 ] && chown root:0 "$(BIT_ROOT_PREFIX)/etc/init.d/appweb"
	chmod 755 "$(BIT_ROOT_PREFIX)/etc/init.d/appweb"
	echo 'set LOG_DIR "$(BIT_LOG_PREFIX)"\nset CACHE_DIR "$(BIT_CACHE_PREFIX)"\nDocuments "$(BIT_WEB_PREFIX)\nListen 80\n' >$(BIT_ETC_PREFIX)/install.conf

#
#   start
#
DEPS_95 += compile
DEPS_95 += stop

start: $(DEPS_95)
	./$(CONFIG)/bin/appman install enable start

#
#   install
#
DEPS_96 += stop
DEPS_96 += installBinary
DEPS_96 += start

install: $(DEPS_96)
	

#
#   uninstall
#
DEPS_97 += stop

uninstall: $(DEPS_97)
	rm -f "$(BIT_ETC_PREFIX)/install.conf"
	rm -fr "$(BIT_INC_PREFIX)/appweb"
	rm -fr "$(BIT_VAPP_PREFIX)"
	rmdir -p "$(BIT_ETC_PREFIX)"
	rmdir -p "$(BIT_WEB_PREFIX)"
	rmdir -p "$(BIT_LOG_PREFIX)"
	rmdir -p "$(BIT_SPOOL_PREFIX)"
	rmdir -p "$(BIT_CACHE_PREFIX)"
	rm -f "$(BIT_APP_PREFIX)/latest"
	rmdir -p "$(BIT_APP_PREFIX)"

#
#   genslink
#
genslink: $(DEPS_98)
	cd src/server; esp --static --genlink slink.c --flat compile ; cd ../..

#
#   run
#
DEPS_99 += compile

run: $(DEPS_99)
	cd src/server; sudo ../../$(CONFIG)/bin/appweb -v ; cd ../..

