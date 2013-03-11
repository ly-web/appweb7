#
#   appweb-macosx-default.mk -- Makefile to build Embedthis Appweb for macosx
#

PRODUCT           := appweb
VERSION           := 4.4.0
BUILD_NUMBER      := 0
PROFILE           := default
ARCH              := $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/')
OS                := macosx
CC                := /usr/bin/clang
LD                := /usr/bin/ld
CONFIG            := $(OS)-$(ARCH)-$(PROFILE)
LBIN              := $(CONFIG)/bin

BIT_PACK_EST      := 0
BIT_PACK_EJSCRIPT := 1
BIT_PACK_SSL      := 1
BIT_PACK_PHP      := 0
BIT_PACK_CGI      := 1
BIT_PACK_ESP      := 1
BIT_PACK_SQLITE   := 1

CFLAGS            += -w
DFLAGS            +=  $(patsubst %,-D%,$(filter BIT_%,$(MAKEFLAGS))) -DBIT_PACK_EST=$(BIT_PACK_EST) -DBIT_PACK_EJSCRIPT=$(BIT_PACK_EJSCRIPT) -DBIT_PACK_SSL=$(BIT_PACK_SSL) -DBIT_PACK_PHP=$(BIT_PACK_PHP) -DBIT_PACK_CGI=$(BIT_PACK_CGI) -DBIT_PACK_ESP=$(BIT_PACK_ESP) -DBIT_PACK_SQLITE=$(BIT_PACK_SQLITE) 
IFLAGS            += -I$(CONFIG)/inc
LDFLAGS           += '-Wl,-rpath,@executable_path/' '-Wl,-rpath,@loader_path/'
LIBPATHS          += -L$(CONFIG)/bin
LIBS              += -lpthread -lm -ldl

DEBUG             := debug
CFLAGS-debug      := -g
DFLAGS-debug      := -DBIT_DEBUG
LDFLAGS-debug     := -g
DFLAGS-release    := 
CFLAGS-release    := -O2
LDFLAGS-release   := 
CFLAGS            += $(CFLAGS-$(DEBUG))
DFLAGS            += $(DFLAGS-$(DEBUG))
LDFLAGS           += $(LDFLAGS-$(DEBUG))

BIT_ROOT_PREFIX   := 
BIT_BASE_PREFIX   := $(BIT_ROOT_PREFIX)/usr/local
BIT_DATA_PREFIX   := $(BIT_ROOT_PREFIX)/
BIT_STATE_PREFIX  := $(BIT_ROOT_PREFIX)/var
BIT_APP_PREFIX    := $(BIT_BASE_PREFIX)/lib/$(PRODUCT)
BIT_VAPP_PREFIX   := $(BIT_APP_PREFIX)/$(VERSION)
BIT_BIN_PREFIX    := $(BIT_ROOT_PREFIX)/usr/local/bin
BIT_INC_PREFIX    := $(BIT_ROOT_PREFIX)/usr/local/include
BIT_LIB_PREFIX    := $(BIT_ROOT_PREFIX)/usr/local/lib
BIT_MAN_PREFIX    := $(BIT_ROOT_PREFIX)/usr/local/share/man
BIT_SBIN_PREFIX   := $(BIT_ROOT_PREFIX)/usr/local/sbin
BIT_ETC_PREFIX    := $(BIT_ROOT_PREFIX)/etc/$(PRODUCT)
BIT_WEB_PREFIX    := $(BIT_ROOT_PREFIX)/var/www/$(PRODUCT)-default
BIT_LOG_PREFIX    := $(BIT_ROOT_PREFIX)/var/log/$(PRODUCT)
BIT_SPOOL_PREFIX  := $(BIT_ROOT_PREFIX)/var/spool/$(PRODUCT)
BIT_CACHE_PREFIX  := $(BIT_ROOT_PREFIX)/var/spool/$(PRODUCT)/cache
BIT_SRC_PREFIX    := $(BIT_ROOT_PREFIX)$(PRODUCT)-$(VERSION)

WEB_USER    = $(shell egrep 'www-data|_www|nobody' /etc/passwd | sed 's/:.*$$//' |  tail -1)
WEB_GROUP   = $(shell egrep 'www-data|_www|nobody|nogroup' /etc/group | sed 's/:.*$$//' |  tail -1)

TARGETS           += $(CONFIG)/bin/libmpr.dylib
ifeq ($(BIT_PACK_SSL),1)
TARGETS           += $(CONFIG)/bin/libmprssl.dylib
endif
TARGETS           += $(CONFIG)/bin/appman
TARGETS           += $(CONFIG)/bin/makerom
ifeq ($(BIT_PACK_EST),1)
TARGETS           += $(CONFIG)/bin/libest.dylib
endif
TARGETS           += $(CONFIG)/bin/ca.crt
TARGETS           += $(CONFIG)/bin/libpcre.dylib
TARGETS           += $(CONFIG)/bin/libhttp.dylib
TARGETS           += $(CONFIG)/bin/http
ifeq ($(BIT_PACK_SQLITE),1)
TARGETS           += $(CONFIG)/bin/libsqlite3.dylib
endif
ifeq ($(BIT_PACK_SQLITE),1)
TARGETS           += $(CONFIG)/bin/sqlite
endif
TARGETS           += $(CONFIG)/bin/libappweb.dylib
ifeq ($(BIT_PACK_ESP),1)
TARGETS           += $(CONFIG)/bin/libmod_esp.dylib
endif
ifeq ($(BIT_PACK_ESP),1)
TARGETS           += $(CONFIG)/bin/esp
endif
ifeq ($(BIT_PACK_ESP),1)
TARGETS           += $(CONFIG)/bin/esp.conf
endif
ifeq ($(BIT_PACK_ESP),1)
TARGETS           += src/server/esp.conf
endif
ifeq ($(BIT_PACK_ESP),1)
TARGETS           += $(CONFIG)/bin/esp-www
endif
ifeq ($(BIT_PACK_ESP),1)
TARGETS           += $(CONFIG)/bin/esp-appweb.conf
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
TARGETS           += $(CONFIG)/bin/libejs.dylib
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
TARGETS           += $(CONFIG)/bin/ejs
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
TARGETS           += $(CONFIG)/bin/ejsc
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
TARGETS           += $(CONFIG)/bin/ejs.mod
endif
ifeq ($(BIT_PACK_CGI),1)
TARGETS           += $(CONFIG)/bin/libmod_cgi.dylib
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
TARGETS           += $(CONFIG)/bin/libmod_ejs.dylib
endif
ifeq ($(BIT_PACK_SSL),1)
TARGETS           += $(CONFIG)/bin/libmod_ssl.dylib
endif
TARGETS           += $(CONFIG)/bin/authpass
ifeq ($(BIT_PACK_CGI),1)
TARGETS           += $(CONFIG)/bin/cgiProgram
endif
TARGETS           += src/server/slink.c
TARGETS           += $(CONFIG)/bin/libslink.dylib
TARGETS           += $(CONFIG)/bin/appweb
TARGETS           += src/server/cache
TARGETS           += $(CONFIG)/bin/testAppweb
ifeq ($(BIT_PACK_CGI),1)
TARGETS           += test/cgi-bin/testScript
endif
ifeq ($(BIT_PACK_CGI),1)
TARGETS           += test/web/caching/cache.cgi
endif
ifeq ($(BIT_PACK_CGI),1)
TARGETS           += test/web/auth/basic/basic.cgi
endif
ifeq ($(BIT_PACK_CGI),1)
TARGETS           += test/cgi-bin/cgiProgram
endif
TARGETS           += test/web/js

unexport CDPATH

ifndef SHOW
.SILENT:
endif

all build compile: prep $(TARGETS)

.PHONY: prep

prep:
	@echo "      [Info] Use "make SHOW=1" to trace executed commands."
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
	rm -rf $(CONFIG)/bin/libslink.dylib
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
	@echo '      [Copy] $(CONFIG)/inc/mpr.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/deps/mpr/mpr.h" "$(CONFIG)/inc/mpr.h"

#
#   bit.h
#
$(CONFIG)/inc/bit.h: $(DEPS_2)
	@echo '      [Copy] $(CONFIG)/inc/bit.h'

#
#   bitos.h
#
DEPS_3 += $(CONFIG)/inc/bit.h

$(CONFIG)/inc/bitos.h: $(DEPS_3)
	@echo '      [Copy] $(CONFIG)/inc/bitos.h'
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

$(CONFIG)/bin/libmpr.dylib: $(DEPS_5)
	@echo '      [Link] libmpr'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmpr.dylib $(LDFLAGS) -compatibility_version 4.4.0 -current_version 4.4.0 $(LIBPATHS) -install_name @rpath/libmpr.dylib $(CONFIG)/obj/mprLib.o $(LIBS)

#
#   est.h
#
$(CONFIG)/inc/est.h: $(DEPS_6)
	@echo '      [Copy] $(CONFIG)/inc/est.h'
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
	$(CC) -c -o $(CONFIG)/obj/estLib.o $(DFLAGS) $(IFLAGS) src/deps/est/estLib.c

ifeq ($(BIT_PACK_EST),1)
#
#   libest
#
DEPS_8 += $(CONFIG)/inc/est.h
DEPS_8 += $(CONFIG)/obj/estLib.o

$(CONFIG)/bin/libest.dylib: $(DEPS_8)
	@echo '      [Link] libest'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libest.dylib $(LDFLAGS) -compatibility_version 4.4.0 -current_version 4.4.0 $(LIBPATHS) -install_name @rpath/libest.dylib $(CONFIG)/obj/estLib.o $(LIBS)
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

ifeq ($(BIT_PACK_SSL),1)
#
#   libmprssl
#
DEPS_10 += $(CONFIG)/bin/libmpr.dylib
ifeq ($(BIT_PACK_EST),1)
    DEPS_10 += $(CONFIG)/bin/libest.dylib
endif
DEPS_10 += $(CONFIG)/obj/mprSsl.o

ifeq ($(BIT_PACK_EST),1)
    LIBS_10 += -lest
endif
LIBS_10 += -lmpr

$(CONFIG)/bin/libmprssl.dylib: $(DEPS_10)
	@echo '      [Link] libmprssl'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmprssl.dylib $(LDFLAGS) -compatibility_version 4.4.0 -current_version 4.4.0 $(LIBPATHS) -install_name @rpath/libmprssl.dylib $(CONFIG)/obj/mprSsl.o $(LIBS_10) $(LIBS_10) $(LIBS)
endif

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
DEPS_12 += $(CONFIG)/bin/libmpr.dylib
DEPS_12 += $(CONFIG)/obj/manager.o

LIBS_12 += -lmpr

$(CONFIG)/bin/appman: $(DEPS_12)
	@echo '      [Link] manager'
	$(CC) -o $(CONFIG)/bin/appman -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/manager.o $(LIBS_12) $(LIBS_12) $(LIBS)

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
DEPS_14 += $(CONFIG)/bin/libmpr.dylib
DEPS_14 += $(CONFIG)/obj/makerom.o

LIBS_14 += -lmpr

$(CONFIG)/bin/makerom: $(DEPS_14)
	@echo '      [Link] makerom'
	$(CC) -o $(CONFIG)/bin/makerom -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/makerom.o $(LIBS_14) $(LIBS_14) $(LIBS)

#
#   ca-crt
#
DEPS_15 += src/deps/est/ca.crt

$(CONFIG)/bin/ca.crt: $(DEPS_15)
	@echo '      [Copy] $(CONFIG)/bin/ca.crt'
	mkdir -p "$(CONFIG)/bin"
	cp "src/deps/est/ca.crt" "$(CONFIG)/bin/ca.crt"

#
#   pcre.h
#
$(CONFIG)/inc/pcre.h: $(DEPS_16)
	@echo '      [Copy] $(CONFIG)/inc/pcre.h'
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

$(CONFIG)/bin/libpcre.dylib: $(DEPS_18)
	@echo '      [Link] libpcre'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libpcre.dylib $(LDFLAGS) -compatibility_version 4.4.0 -current_version 4.4.0 $(LIBPATHS) -install_name @rpath/libpcre.dylib $(CONFIG)/obj/pcre.o $(LIBS)

#
#   http.h
#
$(CONFIG)/inc/http.h: $(DEPS_19)
	@echo '      [Copy] $(CONFIG)/inc/http.h'
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
DEPS_21 += $(CONFIG)/bin/libmpr.dylib
DEPS_21 += $(CONFIG)/bin/libpcre.dylib
DEPS_21 += $(CONFIG)/inc/http.h
DEPS_21 += $(CONFIG)/obj/httpLib.o

LIBS_21 += -lpcre
LIBS_21 += -lmpr

$(CONFIG)/bin/libhttp.dylib: $(DEPS_21)
	@echo '      [Link] libhttp'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libhttp.dylib $(LDFLAGS) -compatibility_version 4.4.0 -current_version 4.4.0 $(LIBPATHS) -install_name @rpath/libhttp.dylib $(CONFIG)/obj/httpLib.o $(LIBS_21) $(LIBS_21) $(LIBS) -lpam

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
DEPS_23 += $(CONFIG)/bin/libhttp.dylib
DEPS_23 += $(CONFIG)/obj/http.o

LIBS_23 += -lhttp
LIBS_23 += -lpcre
LIBS_23 += -lmpr

$(CONFIG)/bin/http: $(DEPS_23)
	@echo '      [Link] http'
	$(CC) -o $(CONFIG)/bin/http -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/http.o $(LIBS_23) $(LIBS_23) $(LIBS) -lpam

#
#   sqlite3.h
#
$(CONFIG)/inc/sqlite3.h: $(DEPS_24)
	@echo '      [Copy] $(CONFIG)/inc/sqlite3.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/deps/sqlite/sqlite3.h" "$(CONFIG)/inc/sqlite3.h"

#
#   config.h
#
$(CONFIG)/inc/config.h: $(DEPS_25)
	@echo '      [Copy] $(CONFIG)/inc/config.h'

#
#   sqlite3.o
#
DEPS_26 += $(CONFIG)/inc/bit.h
DEPS_26 += $(CONFIG)/inc/sqlite3.h
DEPS_26 += $(CONFIG)/inc/config.h

$(CONFIG)/obj/sqlite3.o: \
    src/deps/sqlite/sqlite3.c $(DEPS_26)
	@echo '   [Compile] src/deps/sqlite/sqlite3.c'
	$(CC) -c -o $(CONFIG)/obj/sqlite3.o $(DFLAGS) $(IFLAGS) src/deps/sqlite/sqlite3.c

ifeq ($(BIT_PACK_SQLITE),1)
#
#   libsqlite3
#
DEPS_27 += $(CONFIG)/inc/sqlite3.h
DEPS_27 += $(CONFIG)/obj/sqlite3.o

$(CONFIG)/bin/libsqlite3.dylib: $(DEPS_27)
	@echo '      [Link] libsqlite3'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libsqlite3.dylib $(LDFLAGS) -compatibility_version 4.4.0 -current_version 4.4.0 $(LIBPATHS) -install_name @rpath/libsqlite3.dylib $(CONFIG)/obj/sqlite3.o $(LIBS)
endif

#
#   sqlite.o
#
DEPS_28 += $(CONFIG)/inc/bit.h
DEPS_28 += $(CONFIG)/inc/sqlite3.h

$(CONFIG)/obj/sqlite.o: \
    src/deps/sqlite/sqlite.c $(DEPS_28)
	@echo '   [Compile] src/deps/sqlite/sqlite.c'
	$(CC) -c -o $(CONFIG)/obj/sqlite.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/sqlite/sqlite.c

ifeq ($(BIT_PACK_SQLITE),1)
#
#   sqlite
#
ifeq ($(BIT_PACK_SQLITE),1)
    DEPS_29 += $(CONFIG)/bin/libsqlite3.dylib
endif
DEPS_29 += $(CONFIG)/obj/sqlite.o

ifeq ($(BIT_PACK_SQLITE),1)
    LIBS_29 += -lsqlite3
endif

$(CONFIG)/bin/sqlite: $(DEPS_29)
	@echo '      [Link] sqlite'
	$(CC) -o $(CONFIG)/bin/sqlite -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/sqlite.o $(LIBS_29) $(LIBS_29) $(LIBS)
endif

#
#   appweb.h
#
$(CONFIG)/inc/appweb.h: $(DEPS_30)
	@echo '      [Copy] $(CONFIG)/inc/appweb.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/appweb.h" "$(CONFIG)/inc/appweb.h"

#
#   customize.h
#
$(CONFIG)/inc/customize.h: $(DEPS_31)
	@echo '      [Copy] $(CONFIG)/inc/customize.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/customize.h" "$(CONFIG)/inc/customize.h"

#
#   config.o
#
DEPS_32 += $(CONFIG)/inc/bit.h
DEPS_32 += $(CONFIG)/inc/appweb.h
DEPS_32 += $(CONFIG)/inc/pcre.h
DEPS_32 += $(CONFIG)/inc/mpr.h
DEPS_32 += $(CONFIG)/inc/http.h
DEPS_32 += $(CONFIG)/inc/customize.h

$(CONFIG)/obj/config.o: \
    src/config.c $(DEPS_32)
	@echo '   [Compile] src/config.c'
	$(CC) -c -o $(CONFIG)/obj/config.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/config.c

#
#   convenience.o
#
DEPS_33 += $(CONFIG)/inc/bit.h
DEPS_33 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/convenience.o: \
    src/convenience.c $(DEPS_33)
	@echo '   [Compile] src/convenience.c'
	$(CC) -c -o $(CONFIG)/obj/convenience.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/convenience.c

#
#   dirHandler.o
#
DEPS_34 += $(CONFIG)/inc/bit.h
DEPS_34 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/dirHandler.o: \
    src/dirHandler.c $(DEPS_34)
	@echo '   [Compile] src/dirHandler.c'
	$(CC) -c -o $(CONFIG)/obj/dirHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/dirHandler.c

#
#   fileHandler.o
#
DEPS_35 += $(CONFIG)/inc/bit.h
DEPS_35 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/fileHandler.o: \
    src/fileHandler.c $(DEPS_35)
	@echo '   [Compile] src/fileHandler.c'
	$(CC) -c -o $(CONFIG)/obj/fileHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/fileHandler.c

#
#   log.o
#
DEPS_36 += $(CONFIG)/inc/bit.h
DEPS_36 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/log.o: \
    src/log.c $(DEPS_36)
	@echo '   [Compile] src/log.c'
	$(CC) -c -o $(CONFIG)/obj/log.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/log.c

#
#   server.o
#
DEPS_37 += $(CONFIG)/inc/bit.h
DEPS_37 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/server.o: \
    src/server.c $(DEPS_37)
	@echo '   [Compile] src/server.c'
	$(CC) -c -o $(CONFIG)/obj/server.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/server.c

#
#   libappweb
#
DEPS_38 += $(CONFIG)/bin/libhttp.dylib
DEPS_38 += $(CONFIG)/inc/appweb.h
DEPS_38 += $(CONFIG)/inc/bitos.h
DEPS_38 += $(CONFIG)/inc/customize.h
DEPS_38 += $(CONFIG)/obj/config.o
DEPS_38 += $(CONFIG)/obj/convenience.o
DEPS_38 += $(CONFIG)/obj/dirHandler.o
DEPS_38 += $(CONFIG)/obj/fileHandler.o
DEPS_38 += $(CONFIG)/obj/log.o
DEPS_38 += $(CONFIG)/obj/server.o

LIBS_38 += -lhttp
LIBS_38 += -lpcre
LIBS_38 += -lmpr

$(CONFIG)/bin/libappweb.dylib: $(DEPS_38)
	@echo '      [Link] libappweb'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libappweb.dylib $(LDFLAGS) -compatibility_version 4.4.0 -current_version 4.4.0 $(LIBPATHS) -install_name @rpath/libappweb.dylib $(CONFIG)/obj/config.o $(CONFIG)/obj/convenience.o $(CONFIG)/obj/dirHandler.o $(CONFIG)/obj/fileHandler.o $(CONFIG)/obj/log.o $(CONFIG)/obj/server.o $(LIBS_38) $(LIBS_38) $(LIBS) -lpam

#
#   edi.h
#
$(CONFIG)/inc/edi.h: $(DEPS_39)
	@echo '      [Copy] $(CONFIG)/inc/edi.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/esp/edi.h" "$(CONFIG)/inc/edi.h"

#
#   esp-app.h
#
$(CONFIG)/inc/esp-app.h: $(DEPS_40)
	@echo '      [Copy] $(CONFIG)/inc/esp-app.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/esp/esp-app.h" "$(CONFIG)/inc/esp-app.h"

#
#   esp.h
#
$(CONFIG)/inc/esp.h: $(DEPS_41)
	@echo '      [Copy] $(CONFIG)/inc/esp.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/esp/esp.h" "$(CONFIG)/inc/esp.h"

#
#   mdb.h
#
$(CONFIG)/inc/mdb.h: $(DEPS_42)
	@echo '      [Copy] $(CONFIG)/inc/mdb.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/esp/mdb.h" "$(CONFIG)/inc/mdb.h"

#
#   edi.o
#
DEPS_43 += $(CONFIG)/inc/bit.h
DEPS_43 += $(CONFIG)/inc/edi.h
DEPS_43 += $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/edi.o: \
    src/esp/edi.c $(DEPS_43)
	@echo '   [Compile] src/esp/edi.c'
	$(CC) -c -o $(CONFIG)/obj/edi.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/edi.c

#
#   esp.o
#
DEPS_44 += $(CONFIG)/inc/bit.h
DEPS_44 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/esp.o: \
    src/esp/esp.c $(DEPS_44)
	@echo '   [Compile] src/esp/esp.c'
	$(CC) -c -o $(CONFIG)/obj/esp.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/esp.c

#
#   espAbbrev.o
#
DEPS_45 += $(CONFIG)/inc/bit.h
DEPS_45 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espAbbrev.o: \
    src/esp/espAbbrev.c $(DEPS_45)
	@echo '   [Compile] src/esp/espAbbrev.c'
	$(CC) -c -o $(CONFIG)/obj/espAbbrev.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/espAbbrev.c

#
#   espFramework.o
#
DEPS_46 += $(CONFIG)/inc/bit.h
DEPS_46 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espFramework.o: \
    src/esp/espFramework.c $(DEPS_46)
	@echo '   [Compile] src/esp/espFramework.c'
	$(CC) -c -o $(CONFIG)/obj/espFramework.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/espFramework.c

#
#   espHandler.o
#
DEPS_47 += $(CONFIG)/inc/bit.h
DEPS_47 += $(CONFIG)/inc/appweb.h
DEPS_47 += $(CONFIG)/inc/esp.h
DEPS_47 += $(CONFIG)/inc/edi.h

$(CONFIG)/obj/espHandler.o: \
    src/esp/espHandler.c $(DEPS_47)
	@echo '   [Compile] src/esp/espHandler.c'
	$(CC) -c -o $(CONFIG)/obj/espHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/espHandler.c

#
#   espHtml.o
#
DEPS_48 += $(CONFIG)/inc/bit.h
DEPS_48 += $(CONFIG)/inc/esp.h
DEPS_48 += $(CONFIG)/inc/edi.h

$(CONFIG)/obj/espHtml.o: \
    src/esp/espHtml.c $(DEPS_48)
	@echo '   [Compile] src/esp/espHtml.c'
	$(CC) -c -o $(CONFIG)/obj/espHtml.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/espHtml.c

#
#   espTemplate.o
#
DEPS_49 += $(CONFIG)/inc/bit.h
DEPS_49 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espTemplate.o: \
    src/esp/espTemplate.c $(DEPS_49)
	@echo '   [Compile] src/esp/espTemplate.c'
	$(CC) -c -o $(CONFIG)/obj/espTemplate.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/espTemplate.c

#
#   mdb.o
#
DEPS_50 += $(CONFIG)/inc/bit.h
DEPS_50 += $(CONFIG)/inc/appweb.h
DEPS_50 += $(CONFIG)/inc/edi.h
DEPS_50 += $(CONFIG)/inc/mdb.h
DEPS_50 += $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/mdb.o: \
    src/esp/mdb.c $(DEPS_50)
	@echo '   [Compile] src/esp/mdb.c'
	$(CC) -c -o $(CONFIG)/obj/mdb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/mdb.c

#
#   sdb.o
#
DEPS_51 += $(CONFIG)/inc/bit.h
DEPS_51 += $(CONFIG)/inc/appweb.h
DEPS_51 += $(CONFIG)/inc/edi.h

$(CONFIG)/obj/sdb.o: \
    src/esp/sdb.c $(DEPS_51)
	@echo '   [Compile] src/esp/sdb.c'
	$(CC) -c -o $(CONFIG)/obj/sdb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/sdb.c

ifeq ($(BIT_PACK_ESP),1)
#
#   libmod_esp
#
DEPS_52 += $(CONFIG)/bin/libappweb.dylib
DEPS_52 += $(CONFIG)/inc/edi.h
DEPS_52 += $(CONFIG)/inc/esp-app.h
DEPS_52 += $(CONFIG)/inc/esp.h
DEPS_52 += $(CONFIG)/inc/mdb.h
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

$(CONFIG)/bin/libmod_esp.dylib: $(DEPS_52)
	@echo '      [Link] libmod_esp'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmod_esp.dylib $(LDFLAGS) -compatibility_version 4.4.0 -current_version 4.4.0 $(LIBPATHS) -install_name @rpath/libmod_esp.dylib $(CONFIG)/obj/edi.o $(CONFIG)/obj/esp.o $(CONFIG)/obj/espAbbrev.o $(CONFIG)/obj/espFramework.o $(CONFIG)/obj/espHandler.o $(CONFIG)/obj/espHtml.o $(CONFIG)/obj/espTemplate.o $(CONFIG)/obj/mdb.o $(CONFIG)/obj/sdb.o $(LIBS_52) $(LIBS_52) $(LIBS) -lpam
endif

ifeq ($(BIT_PACK_ESP),1)
#
#   esp
#
DEPS_53 += $(CONFIG)/bin/libappweb.dylib
DEPS_53 += $(CONFIG)/obj/edi.o
DEPS_53 += $(CONFIG)/obj/esp.o
DEPS_53 += $(CONFIG)/obj/espAbbrev.o
DEPS_53 += $(CONFIG)/obj/espFramework.o
DEPS_53 += $(CONFIG)/obj/espHandler.o
DEPS_53 += $(CONFIG)/obj/espHtml.o
DEPS_53 += $(CONFIG)/obj/espTemplate.o
DEPS_53 += $(CONFIG)/obj/mdb.o
DEPS_53 += $(CONFIG)/obj/sdb.o

LIBS_53 += -lappweb
LIBS_53 += -lhttp
LIBS_53 += -lpcre
LIBS_53 += -lmpr

$(CONFIG)/bin/esp: $(DEPS_53)
	@echo '      [Link] esp'
	$(CC) -o $(CONFIG)/bin/esp -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/edi.o $(CONFIG)/obj/esp.o $(CONFIG)/obj/espAbbrev.o $(CONFIG)/obj/espFramework.o $(CONFIG)/obj/espHandler.o $(CONFIG)/obj/espHtml.o $(CONFIG)/obj/espTemplate.o $(CONFIG)/obj/mdb.o $(CONFIG)/obj/sdb.o $(LIBS_53) $(LIBS_53) $(LIBS) -lpam
endif

ifeq ($(BIT_PACK_ESP),1)
#
#   esp.conf
#
DEPS_54 += src/esp/esp.conf

$(CONFIG)/bin/esp.conf: $(DEPS_54)
	@echo '      [Copy] $(CONFIG)/bin/esp.conf'
	mkdir -p "$(CONFIG)/bin"
	cp "src/esp/esp.conf" "$(CONFIG)/bin/esp.conf"
endif

ifeq ($(BIT_PACK_ESP),1)
#
#   esp.conf.server
#
DEPS_55 += src/esp/esp.conf

src/server/esp.conf: $(DEPS_55)
	@echo '      [Copy] src/server/esp.conf'
	mkdir -p "src/server"
	cp "src/esp/esp.conf" "src/server/esp.conf"
endif

ifeq ($(BIT_PACK_ESP),1)
#
#   esp.www
#
DEPS_56 += src/esp/esp-www

$(CONFIG)/bin/esp-www: $(DEPS_56)
	@echo '      [Copy] $(CONFIG)/bin/esp-www'
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
	mkdir -p "$(CONFIG)/bin/esp-www/files/static/js/new"
	cp "src/esp/esp-www/files/static/js/new/jquery-1.9.1.js" "$(CONFIG)/bin/esp-www/files/static/js/new/jquery-1.9.1.js"
	cp "src/esp/esp-www/files/static/js/new/jquery-1.9.1.min.js" "$(CONFIG)/bin/esp-www/files/static/js/new/jquery-1.9.1.min.js"
	cp "src/esp/esp-www/files/static/layout.css" "$(CONFIG)/bin/esp-www/files/static/layout.css"
	mkdir -p "$(CONFIG)/bin/esp-www/files/static/themes"
	cp "src/esp/esp-www/files/static/themes/default.css" "$(CONFIG)/bin/esp-www/files/static/themes/default.css"
endif

ifeq ($(BIT_PACK_ESP),1)
#
#   esp-appweb.conf
#
DEPS_57 += src/esp/esp-appweb.conf

$(CONFIG)/bin/esp-appweb.conf: $(DEPS_57)
	@echo '      [Copy] $(CONFIG)/bin/esp-appweb.conf'
	mkdir -p "$(CONFIG)/bin"
	cp "src/esp/esp-appweb.conf" "$(CONFIG)/bin/esp-appweb.conf"
endif

#
#   ejs.h
#
$(CONFIG)/inc/ejs.h: $(DEPS_58)
	@echo '      [Copy] $(CONFIG)/inc/ejs.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/deps/ejs/ejs.h" "$(CONFIG)/inc/ejs.h"

#
#   ejs.slots.h
#
$(CONFIG)/inc/ejs.slots.h: $(DEPS_59)
	@echo '      [Copy] $(CONFIG)/inc/ejs.slots.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/deps/ejs/ejs.slots.h" "$(CONFIG)/inc/ejs.slots.h"

#
#   ejsByteGoto.h
#
$(CONFIG)/inc/ejsByteGoto.h: $(DEPS_60)
	@echo '      [Copy] $(CONFIG)/inc/ejsByteGoto.h'
	mkdir -p "$(CONFIG)/inc"
	cp "src/deps/ejs/ejsByteGoto.h" "$(CONFIG)/inc/ejsByteGoto.h"

#
#   ejsLib.o
#
DEPS_61 += $(CONFIG)/inc/bit.h
DEPS_61 += $(CONFIG)/inc/ejs.h
DEPS_61 += $(CONFIG)/inc/mpr.h
DEPS_61 += $(CONFIG)/inc/pcre.h
DEPS_61 += $(CONFIG)/inc/bitos.h
DEPS_61 += $(CONFIG)/inc/http.h
DEPS_61 += $(CONFIG)/inc/ejs.slots.h

$(CONFIG)/obj/ejsLib.o: \
    src/deps/ejs/ejsLib.c $(DEPS_61)
	@echo '   [Compile] src/deps/ejs/ejsLib.c'
	$(CC) -c -o $(CONFIG)/obj/ejsLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/ejs/ejsLib.c

ifeq ($(BIT_PACK_EJSCRIPT),1)
#
#   libejs
#
DEPS_62 += $(CONFIG)/bin/libhttp.dylib
DEPS_62 += $(CONFIG)/bin/libpcre.dylib
DEPS_62 += $(CONFIG)/bin/libmpr.dylib
ifeq ($(BIT_PACK_SQLITE),1)
    DEPS_62 += $(CONFIG)/bin/libsqlite3.dylib
endif
DEPS_62 += $(CONFIG)/inc/ejs.h
DEPS_62 += $(CONFIG)/inc/ejs.slots.h
DEPS_62 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_62 += $(CONFIG)/obj/ejsLib.o

ifeq ($(BIT_PACK_SQLITE),1)
    LIBS_62 += -lsqlite3
endif
LIBS_62 += -lmpr
LIBS_62 += -lpcre
LIBS_62 += -lhttp
LIBS_62 += -lpcre
LIBS_62 += -lmpr

$(CONFIG)/bin/libejs.dylib: $(DEPS_62)
	@echo '      [Link] libejs'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libejs.dylib $(LDFLAGS) -compatibility_version 4.4.0 -current_version 4.4.0 $(LIBPATHS) -install_name @rpath/libejs.dylib $(CONFIG)/obj/ejsLib.o $(LIBS_62) $(LIBS_62) $(LIBS) -lpam
endif

#
#   ejs.o
#
DEPS_63 += $(CONFIG)/inc/bit.h
DEPS_63 += $(CONFIG)/inc/ejs.h

$(CONFIG)/obj/ejs.o: \
    src/deps/ejs/ejs.c $(DEPS_63)
	@echo '   [Compile] src/deps/ejs/ejs.c'
	$(CC) -c -o $(CONFIG)/obj/ejs.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/ejs/ejs.c

ifeq ($(BIT_PACK_EJSCRIPT),1)
#
#   ejs
#
ifeq ($(BIT_PACK_EJSCRIPT),1)
    DEPS_64 += $(CONFIG)/bin/libejs.dylib
endif
DEPS_64 += $(CONFIG)/obj/ejs.o

ifeq ($(BIT_PACK_EJSCRIPT),1)
    LIBS_64 += -lejs
endif
ifeq ($(BIT_PACK_SQLITE),1)
    LIBS_64 += -lsqlite3
endif
LIBS_64 += -lmpr
LIBS_64 += -lpcre
LIBS_64 += -lhttp

$(CONFIG)/bin/ejs: $(DEPS_64)
	@echo '      [Link] ejs'
	$(CC) -o $(CONFIG)/bin/ejs -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/ejs.o $(LIBS_64) $(LIBS_64) $(LIBS) -ledit
endif

#
#   ejsc.o
#
DEPS_65 += $(CONFIG)/inc/bit.h
DEPS_65 += $(CONFIG)/inc/ejs.h

$(CONFIG)/obj/ejsc.o: \
    src/deps/ejs/ejsc.c $(DEPS_65)
	@echo '   [Compile] src/deps/ejs/ejsc.c'
	$(CC) -c -o $(CONFIG)/obj/ejsc.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/ejs/ejsc.c

ifeq ($(BIT_PACK_EJSCRIPT),1)
#
#   ejsc
#
ifeq ($(BIT_PACK_EJSCRIPT),1)
    DEPS_66 += $(CONFIG)/bin/libejs.dylib
endif
DEPS_66 += $(CONFIG)/obj/ejsc.o

ifeq ($(BIT_PACK_EJSCRIPT),1)
    LIBS_66 += -lejs
endif
ifeq ($(BIT_PACK_SQLITE),1)
    LIBS_66 += -lsqlite3
endif
LIBS_66 += -lmpr
LIBS_66 += -lpcre
LIBS_66 += -lhttp

$(CONFIG)/bin/ejsc: $(DEPS_66)
	@echo '      [Link] ejsc'
	$(CC) -o $(CONFIG)/bin/ejsc -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/ejsc.o $(LIBS_66) $(LIBS_66) $(LIBS) -lpam
endif

ifeq ($(BIT_PACK_EJSCRIPT),1)
#
#   ejs.mod
#
ifeq ($(BIT_PACK_EJSCRIPT),1)
    DEPS_67 += $(CONFIG)/bin/ejsc
endif

$(CONFIG)/bin/ejs.mod: $(DEPS_67)
	$(LBIN)/ejsc --out ./$(CONFIG)/bin/ejs.mod --optimize 9 --bind --require null src/deps/ejs/ejs.es
endif

#
#   cgiHandler.o
#
DEPS_68 += $(CONFIG)/inc/bit.h
DEPS_68 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/cgiHandler.o: \
    src/modules/cgiHandler.c $(DEPS_68)
	@echo '   [Compile] src/modules/cgiHandler.c'
	$(CC) -c -o $(CONFIG)/obj/cgiHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/modules/cgiHandler.c

ifeq ($(BIT_PACK_CGI),1)
#
#   libmod_cgi
#
DEPS_69 += $(CONFIG)/bin/libappweb.dylib
DEPS_69 += $(CONFIG)/obj/cgiHandler.o

LIBS_69 += -lappweb
LIBS_69 += -lhttp
LIBS_69 += -lpcre
LIBS_69 += -lmpr

$(CONFIG)/bin/libmod_cgi.dylib: $(DEPS_69)
	@echo '      [Link] libmod_cgi'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmod_cgi.dylib $(LDFLAGS) -compatibility_version 4.4.0 -current_version 4.4.0 $(LIBPATHS) -install_name @rpath/libmod_cgi.dylib $(CONFIG)/obj/cgiHandler.o $(LIBS_69) $(LIBS_69) $(LIBS) -lpam
endif

#
#   ejsHandler.o
#
DEPS_70 += $(CONFIG)/inc/bit.h
DEPS_70 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/ejsHandler.o: \
    src/modules/ejsHandler.c $(DEPS_70)
	@echo '   [Compile] src/modules/ejsHandler.c'
	$(CC) -c -o $(CONFIG)/obj/ejsHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/modules/ejsHandler.c

ifeq ($(BIT_PACK_EJSCRIPT),1)
#
#   libmod_ejs
#
DEPS_71 += $(CONFIG)/bin/libappweb.dylib
ifeq ($(BIT_PACK_EJSCRIPT),1)
    DEPS_71 += $(CONFIG)/bin/libejs.dylib
endif
DEPS_71 += $(CONFIG)/obj/ejsHandler.o

ifeq ($(BIT_PACK_EJSCRIPT),1)
    LIBS_71 += -lejs
endif
LIBS_71 += -lappweb
LIBS_71 += -lhttp
LIBS_71 += -lpcre
LIBS_71 += -lmpr
ifeq ($(BIT_PACK_SQLITE),1)
    LIBS_71 += -lsqlite3
endif

$(CONFIG)/bin/libmod_ejs.dylib: $(DEPS_71)
	@echo '      [Link] libmod_ejs'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmod_ejs.dylib $(LDFLAGS) -compatibility_version 4.4.0 -current_version 4.4.0 $(LIBPATHS) -install_name @rpath/libmod_ejs.dylib $(CONFIG)/obj/ejsHandler.o $(LIBS_71) $(LIBS_71) $(LIBS) -lsqlite3
endif

#
#   sslModule.o
#
DEPS_72 += $(CONFIG)/inc/bit.h
DEPS_72 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/sslModule.o: \
    src/modules/sslModule.c $(DEPS_72)
	@echo '   [Compile] src/modules/sslModule.c'
	$(CC) -c -o $(CONFIG)/obj/sslModule.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/modules/sslModule.c

ifeq ($(BIT_PACK_SSL),1)
#
#   libmod_ssl
#
DEPS_73 += $(CONFIG)/bin/libappweb.dylib
DEPS_73 += $(CONFIG)/obj/sslModule.o

LIBS_73 += -lappweb
LIBS_73 += -lhttp
LIBS_73 += -lpcre
LIBS_73 += -lmpr

$(CONFIG)/bin/libmod_ssl.dylib: $(DEPS_73)
	@echo '      [Link] libmod_ssl'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmod_ssl.dylib $(LDFLAGS) -compatibility_version 4.4.0 -current_version 4.4.0 $(LIBPATHS) -install_name @rpath/libmod_ssl.dylib $(CONFIG)/obj/sslModule.o $(LIBS_73) $(LIBS_73) $(LIBS) -lpam
endif

#
#   authpass.o
#
DEPS_74 += $(CONFIG)/inc/bit.h
DEPS_74 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/authpass.o: \
    src/utils/authpass.c $(DEPS_74)
	@echo '   [Compile] src/utils/authpass.c'
	$(CC) -c -o $(CONFIG)/obj/authpass.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/utils/authpass.c

#
#   authpass
#
DEPS_75 += $(CONFIG)/bin/libappweb.dylib
DEPS_75 += $(CONFIG)/obj/authpass.o

LIBS_75 += -lappweb
LIBS_75 += -lhttp
LIBS_75 += -lpcre
LIBS_75 += -lmpr

$(CONFIG)/bin/authpass: $(DEPS_75)
	@echo '      [Link] authpass'
	$(CC) -o $(CONFIG)/bin/authpass -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/authpass.o $(LIBS_75) $(LIBS_75) $(LIBS) -lpam

#
#   cgiProgram.o
#
DEPS_76 += $(CONFIG)/inc/bit.h

$(CONFIG)/obj/cgiProgram.o: \
    src/utils/cgiProgram.c $(DEPS_76)
	@echo '   [Compile] src/utils/cgiProgram.c'
	$(CC) -c -o $(CONFIG)/obj/cgiProgram.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/utils/cgiProgram.c

ifeq ($(BIT_PACK_CGI),1)
#
#   cgiProgram
#
DEPS_77 += $(CONFIG)/obj/cgiProgram.o

$(CONFIG)/bin/cgiProgram: $(DEPS_77)
	@echo '      [Link] cgiProgram'
	$(CC) -o $(CONFIG)/bin/cgiProgram -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/cgiProgram.o $(LIBS)
endif

#
#   slink.c
#
src/server/slink.c: $(DEPS_78)
	cd src/server; [ ! -f slink.c ] && cp slink.empty slink.c ; true ; cd ../..

#
#   slink.o
#
DEPS_79 += $(CONFIG)/inc/bit.h
DEPS_79 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/slink.o: \
    src/server/slink.c $(DEPS_79)
	@echo '   [Compile] src/server/slink.c'
	$(CC) -c -o $(CONFIG)/obj/slink.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/server/slink.c

#
#   libslink
#
DEPS_80 += src/server/slink.c
ifeq ($(BIT_PACK_ESP),1)
    DEPS_80 += $(CONFIG)/bin/esp
endif
ifeq ($(BIT_PACK_ESP),1)
    DEPS_80 += $(CONFIG)/bin/libmod_esp.dylib
endif
DEPS_80 += $(CONFIG)/obj/slink.o

ifeq ($(BIT_PACK_ESP),1)
    LIBS_80 += -lmod_esp
endif
LIBS_80 += -lappweb
LIBS_80 += -lhttp
LIBS_80 += -lpcre
LIBS_80 += -lmpr

$(CONFIG)/bin/libslink.dylib: $(DEPS_80)
	@echo '      [Link] libslink'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libslink.dylib $(LDFLAGS) -compatibility_version 4.4.0 -current_version 4.4.0 $(LIBPATHS) -install_name @rpath/libslink.dylib $(CONFIG)/obj/slink.o $(LIBS_80) $(LIBS_80) $(LIBS) -lpam

#
#   appweb.o
#
DEPS_81 += $(CONFIG)/inc/bit.h
DEPS_81 += $(CONFIG)/inc/appweb.h
DEPS_81 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/appweb.o: \
    src/server/appweb.c $(DEPS_81)
	@echo '   [Compile] src/server/appweb.c'
	$(CC) -c -o $(CONFIG)/obj/appweb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/server/appweb.c

#
#   appweb
#
DEPS_82 += $(CONFIG)/bin/libappweb.dylib
ifeq ($(BIT_PACK_ESP),1)
    DEPS_82 += $(CONFIG)/bin/libmod_esp.dylib
endif
ifeq ($(BIT_PACK_SSL),1)
    DEPS_82 += $(CONFIG)/bin/libmod_ssl.dylib
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
    DEPS_82 += $(CONFIG)/bin/libmod_ejs.dylib
endif
ifeq ($(BIT_PACK_CGI),1)
    DEPS_82 += $(CONFIG)/bin/libmod_cgi.dylib
endif
DEPS_82 += $(CONFIG)/bin/libslink.dylib
DEPS_82 += $(CONFIG)/obj/appweb.o

LIBS_82 += -lslink
ifeq ($(BIT_PACK_CGI),1)
    LIBS_82 += -lmod_cgi
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
    LIBS_82 += -lmod_ejs
endif
ifeq ($(BIT_PACK_SSL),1)
    LIBS_82 += -lmod_ssl
endif
ifeq ($(BIT_PACK_ESP),1)
    LIBS_82 += -lmod_esp
endif
LIBS_82 += -lappweb
LIBS_82 += -lhttp
LIBS_82 += -lpcre
LIBS_82 += -lmpr
ifeq ($(BIT_PACK_EJSCRIPT),1)
    LIBS_82 += -lejs
endif
ifeq ($(BIT_PACK_SQLITE),1)
    LIBS_82 += -lsqlite3
endif

$(CONFIG)/bin/appweb: $(DEPS_82)
	@echo '      [Link] appweb'
	$(CC) -o $(CONFIG)/bin/appweb -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/appweb.o $(LIBS_82) $(LIBS_82) $(LIBS) -lsqlite3

#
#   server-cache
#
src/server/cache: $(DEPS_83)
	cd src/server; mkdir -p cache ; cd ../..

#
#   testAppweb.h
#
$(CONFIG)/inc/testAppweb.h: $(DEPS_84)
	@echo '      [Copy] $(CONFIG)/inc/testAppweb.h'
	mkdir -p "$(CONFIG)/inc"
	cp "test/testAppweb.h" "$(CONFIG)/inc/testAppweb.h"

#
#   testAppweb.o
#
DEPS_85 += $(CONFIG)/inc/bit.h
DEPS_85 += $(CONFIG)/inc/testAppweb.h
DEPS_85 += $(CONFIG)/inc/mpr.h
DEPS_85 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/testAppweb.o: \
    test/testAppweb.c $(DEPS_85)
	@echo '   [Compile] test/testAppweb.c'
	$(CC) -c -o $(CONFIG)/obj/testAppweb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) test/testAppweb.c

#
#   testHttp.o
#
DEPS_86 += $(CONFIG)/inc/bit.h
DEPS_86 += $(CONFIG)/inc/testAppweb.h

$(CONFIG)/obj/testHttp.o: \
    test/testHttp.c $(DEPS_86)
	@echo '   [Compile] test/testHttp.c'
	$(CC) -c -o $(CONFIG)/obj/testHttp.o $(CFLAGS) $(DFLAGS) $(IFLAGS) test/testHttp.c

#
#   testAppweb
#
DEPS_87 += $(CONFIG)/bin/libappweb.dylib
DEPS_87 += $(CONFIG)/inc/testAppweb.h
DEPS_87 += $(CONFIG)/obj/testAppweb.o
DEPS_87 += $(CONFIG)/obj/testHttp.o

LIBS_87 += -lappweb
LIBS_87 += -lhttp
LIBS_87 += -lpcre
LIBS_87 += -lmpr

$(CONFIG)/bin/testAppweb: $(DEPS_87)
	@echo '      [Link] testAppweb'
	$(CC) -o $(CONFIG)/bin/testAppweb -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/testAppweb.o $(CONFIG)/obj/testHttp.o $(LIBS_87) $(LIBS_87) $(LIBS) -lpam

ifeq ($(BIT_PACK_CGI),1)
#
#   test-testScript
#
ifeq ($(BIT_PACK_CGI),1)
    DEPS_88 += $(CONFIG)/bin/cgiProgram
endif

test/cgi-bin/testScript: $(DEPS_88)
	cd test; echo '#!../$(CONFIG)/bin/cgiProgram' >cgi-bin/testScript ; chmod +x cgi-bin/testScript ; cd ..
endif

ifeq ($(BIT_PACK_CGI),1)
#
#   test-cache.cgi
#
test/web/caching/cache.cgi: $(DEPS_89)
	cd test; echo "#!`type -p ejs`" >web/caching/cache.cgi ; cd ..
	cd test; echo 'print("HTTP/1.0 200 OK\nContent-Type: text/plain\n\n" + Date() + "\n")' >>web/caching/cache.cgi ; cd ..
	cd test; chmod +x web/caching/cache.cgi ; cd ..
endif

ifeq ($(BIT_PACK_CGI),1)
#
#   test-basic.cgi
#
test/web/auth/basic/basic.cgi: $(DEPS_90)
	cd test; echo "#!`type -p ejs`" >web/auth/basic/basic.cgi ; cd ..
	cd test; echo 'print("HTTP/1.0 200 OK\nContent-Type: text/plain\n\n" + serialize(App.env, {pretty: true}) + "\n")' >>web/auth/basic/basic.cgi ; cd ..
	cd test; chmod +x web/auth/basic/basic.cgi ; cd ..
endif

ifeq ($(BIT_PACK_CGI),1)
#
#   test-cgiProgram
#
ifeq ($(BIT_PACK_CGI),1)
    DEPS_91 += $(CONFIG)/bin/cgiProgram
endif

test/cgi-bin/cgiProgram: $(DEPS_91)
	cd test; cp ../$(CONFIG)/bin/cgiProgram cgi-bin/cgiProgram ; cd ..
	cd test; cp ../$(CONFIG)/bin/cgiProgram cgi-bin/nph-cgiProgram ; cd ..
	cd test; cp ../$(CONFIG)/bin/cgiProgram 'cgi-bin/cgi Program' ; cd ..
	cd test; cp ../$(CONFIG)/bin/cgiProgram web/cgiProgram.cgi ; cd ..
	cd test; chmod +x cgi-bin/* web/cgiProgram.cgi ; cd ..
endif

#
#   test.js
#
DEPS_92 += src/esp/esp-www/files/static/js

test/web/js: $(DEPS_92)
	@echo '      [Copy] test/web/js'
	mkdir -p "test/web/js"
	cp "src/esp/esp-www/files/static/js/jquery.esp.js" "test/web/js/jquery.esp.js"
	cp "src/esp/esp-www/files/static/js/jquery.js" "test/web/js/jquery.js"
	cp "src/esp/esp-www/files/static/js/jquery.simplemodal.js" "test/web/js/jquery.simplemodal.js"
	cp "src/esp/esp-www/files/static/js/jquery.tablesorter.js" "test/web/js/jquery.tablesorter.js"
	mkdir -p "test/web/js/new"
	cp "src/esp/esp-www/files/static/js/new/jquery-1.9.1.js" "test/web/js/new/jquery-1.9.1.js"
	cp "src/esp/esp-www/files/static/js/new/jquery-1.9.1.min.js" "test/web/js/new/jquery-1.9.1.min.js"

#
#   version
#
version: $(DEPS_93)
	@echo 4.4.0-0


#
#   stop
#
DEPS_94 += compile

stop: $(DEPS_94)
	@./$(CONFIG)/bin/appman stop disable uninstall >/dev/null 2>&1 ; true

#
#   installBinary
#
DEPS_95 += stop

installBinary: $(DEPS_95)
	mkdir -p "$(BIT_APP_PREFIX)"
	mkdir -p "$(BIT_VAPP_PREFIX)"
	mkdir -p "$(BIT_ETC_PREFIX)"
	mkdir -p "$(BIT_WEB_PREFIX)"
	mkdir -p "$(BIT_LOG_PREFIX)"
	mkdir -p "$(BIT_SPOOL_PREFIX)"
	rm -fr "$(BIT_CACHE_PREFIX)"
	mkdir -p "$(BIT_CACHE_PREFIX)"
	mkdir -p "$(BIT_APP_PREFIX)"
	rm -f "$(BIT_APP_PREFIX)/latest"
	ln -s "4.4.0" "$(BIT_APP_PREFIX)/latest"
	mkdir -p "$(BIT_LOG_PREFIX)"
	chmod 755 "$(BIT_LOG_PREFIX)"
	[ `id -u` = 0 ] && chown _www:_www "$(BIT_LOG_PREFIX)"
	mkdir -p "$(BIT_CACHE_PREFIX)"
	chmod 755 "$(BIT_CACHE_PREFIX)"
	[ `id -u` = 0 ] && chown _www:_www "$(BIT_CACHE_PREFIX)"
	mkdir -p "$(BIT_VAPP_PREFIX)/bin"
	cp "$(CONFIG)/bin/appman" "$(BIT_VAPP_PREFIX)/bin/appman"
	mkdir -p "$(BIT_BIN_PREFIX)"
	rm -f "$(BIT_BIN_PREFIX)/appman"
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
	cp "$(CONFIG)/bin/libappweb.dylib" "$(BIT_VAPP_PREFIX)/bin/libappweb.dylib"
	cp "$(CONFIG)/bin/libhttp.dylib" "$(BIT_VAPP_PREFIX)/bin/libhttp.dylib"
	cp "$(CONFIG)/bin/libmpr.dylib" "$(BIT_VAPP_PREFIX)/bin/libmpr.dylib"
	cp "$(CONFIG)/bin/libpcre.dylib" "$(BIT_VAPP_PREFIX)/bin/libpcre.dylib"
	cp "$(CONFIG)/bin/libslink.dylib" "$(BIT_VAPP_PREFIX)/bin/libslink.dylib"
ifeq ($(BIT_PACK_SSL),1)
	cp "$(CONFIG)/bin/libmprssl.dylib" "$(BIT_VAPP_PREFIX)/bin/libmprssl.dylib"
	cp "$(CONFIG)/bin/libmod_ssl.dylib" "$(BIT_VAPP_PREFIX)/bin/libmod_ssl.dylib"
	cp "$(CONFIG)/bin/ca.crt" "$(BIT_VAPP_PREFIX)/bin/ca.crt"
endif
ifeq ($(BIT_PACK_SQLITE),1)
	cp "$(CONFIG)/bin/libsqlite3.dylib" "$(BIT_VAPP_PREFIX)/bin/libsqlite3.dylib"
endif
ifeq ($(BIT_PACK_ESP),1)
	cp "$(CONFIG)/bin/libmod_esp.dylib" "$(BIT_VAPP_PREFIX)/bin/libmod_esp.dylib"
endif
ifeq ($(BIT_PACK_CGI),1)
	cp "$(CONFIG)/bin/libmod_cgi.dylib" "$(BIT_VAPP_PREFIX)/bin/libmod_cgi.dylib"
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
	cp "$(CONFIG)/bin/libejs.dylib" "$(BIT_VAPP_PREFIX)/bin/libejs.dylib"
	cp "$(CONFIG)/bin/libmod_ejs.dylib" "$(BIT_VAPP_PREFIX)/bin/libmod_ejs.dylib"
endif
ifeq ($(BIT_PACK_ESP),1)
	cp "$(CONFIG)/bin/libmod_esp.dylib" "$(BIT_VAPP_PREFIX)/bin/libmod_esp.dylib"
	cp "$(CONFIG)/bin/libappweb.dylib" "$(BIT_VAPP_PREFIX)/bin/libappweb.dylib"
	cp "$(CONFIG)/bin/libpcre.dylib" "$(BIT_VAPP_PREFIX)/bin/libpcre.dylib"
	cp "$(CONFIG)/bin/libhttp.dylib" "$(BIT_VAPP_PREFIX)/bin/libhttp.dylib"
	cp "$(CONFIG)/bin/libmpr.dylib" "$(BIT_VAPP_PREFIX)/bin/libmpr.dylib"
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
	mkdir -p "$(BIT_VAPP_PREFIX)/bin/esp-www/files/static/js/new"
	cp "src/esp/esp-www/files/static/js/new/jquery-1.9.1.js" "$(BIT_VAPP_PREFIX)/bin/esp-www/files/static/js/new/jquery-1.9.1.js"
	cp "src/esp/esp-www/files/static/js/new/jquery-1.9.1.min.js" "$(BIT_VAPP_PREFIX)/bin/esp-www/files/static/js/new/jquery-1.9.1.min.js"
	cp "src/esp/esp-www/files/static/layout.css" "$(BIT_VAPP_PREFIX)/bin/esp-www/files/static/layout.css"
	mkdir -p "$(BIT_VAPP_PREFIX)/bin/esp-www/files/static/themes"
	cp "src/esp/esp-www/files/static/themes/default.css" "$(BIT_VAPP_PREFIX)/bin/esp-www/files/static/themes/default.css"
	cp "src/esp/esp-appweb.conf" "$(BIT_VAPP_PREFIX)/bin/esp-appweb.conf"
endif
ifeq ($(BIT_PACK_ESP),1)
	cp "$(CONFIG)/bin/esp.conf" "$(BIT_VAPP_PREFIX)/bin/esp.conf"
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
	mkdir -p "$(BIT_ETC_PREFIX)"
	cp "src/server/mime.types" "$(BIT_ETC_PREFIX)/mime.types"
	cp "src/server/appweb.conf" "$(BIT_ETC_PREFIX)/appweb.conf"
	mkdir -p "$(BIT_VAPP_PREFIX)/inc"
	cp "$(CONFIG)/inc/bit.h" "$(BIT_VAPP_PREFIX)/inc/bit.h"
	mkdir -p "$(BIT_INC_PREFIX)/appweb"
	rm -f "$(BIT_INC_PREFIX)/appweb/bit.h"
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
	mkdir -p "$(BIT_MAN_PREFIX)/man1"
	rm -f "$(BIT_MAN_PREFIX)/man1/appman.1"
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
	mkdir -p "$(BIT_ROOT_PREFIX)/Library/LaunchDaemons"
	cp "package/macosx/com.embedthis.appweb.plist" "$(BIT_ROOT_PREFIX)/Library/LaunchDaemons/com.embedthis.appweb.plist"
	[ `id -u` = 0 ] && chown root:wheel "$(BIT_ROOT_PREFIX)/Library/LaunchDaemons/com.embedthis.appweb.plist"
	chmod 644 "$(BIT_ROOT_PREFIX)/Library/LaunchDaemons/com.embedthis.appweb.plist"
	echo 'set LOG_DIR "$(BIT_LOG_PREFIX)"\nset CACHE_DIR "$(BIT_CACHE_PREFIX)"\nDocuments "$(BIT_WEB_PREFIX)\nListen 80\n' >$(BIT_ETC_PREFIX)/install.conf

#
#   start
#
DEPS_96 += compile
DEPS_96 += stop

start: $(DEPS_96)
	./$(CONFIG)/bin/appman install enable start

#
#   install
#
DEPS_97 += stop
DEPS_97 += installBinary
DEPS_97 += start

install: $(DEPS_97)
	

#
#   uninstall
#
DEPS_98 += stop

uninstall: $(DEPS_98)
	rm -f "$(BIT_ETC_PREFIX)/appweb.conf"
	rm -f "$(BIT_ETC_PREFIX)/esp.conf"
	rm -f "$(BIT_ETC_PREFIX)/mine.types"
	rm -f "$(BIT_ETC_PREFIX)/install.conf"
	rm -fr "$(BIT_INC_PREFIX)/appweb"
	rm -fr "$(BIT_WEB_PREFIX)"
	rm -fr "$(BIT_SPOOL_PREFIX)"
	rm -fr "$(BIT_CACHE_PREFIX)"
	rm -fr "$(BIT_LOG_PREFIX)"
	rm -fr "$(BIT_VAPP_PREFIX)"
	rmdir -p "$(BIT_ETC_PREFIX)" 2>/dev/null ; true
	rmdir -p "$(BIT_WEB_PREFIX)" 2>/dev/null ; true
	rmdir -p "$(BIT_LOG_PREFIX)" 2>/dev/null ; true
	rmdir -p "$(BIT_SPOOL_PREFIX)" 2>/dev/null ; true
	rmdir -p "$(BIT_CACHE_PREFIX)" 2>/dev/null ; true
	rm -f "$(BIT_APP_PREFIX)/latest"
	rmdir -p "$(BIT_APP_PREFIX)" 2>/dev/null ; true

#
#   genslink
#
genslink: $(DEPS_99)
	cd src/server; esp --static --genlink slink.c --flat compile ; cd ../..

#
#   run
#
DEPS_100 += compile

run: $(DEPS_100)
	cd src/server; sudo ../../$(CONFIG)/bin/appweb -v ; cd ../..

#
#   test-run
#
DEPS_101 += compile

test-run: $(DEPS_101)
	cd test; ../$(CONFIG)/bin/appweb -v ; cd ..

