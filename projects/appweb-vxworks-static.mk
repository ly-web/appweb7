#
#   appweb-vxworks-static.mk -- Makefile to build Embedthis Appweb for vxworks
#

PRODUCT            := appweb
VERSION            := 4.3.1
BUILD_NUMBER       := 0
PROFILE            := static
ARCH               := $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/')
OS                 := vxworks
CC                 := cc$(subst x86,pentium,$(ARCH))
LD                 := link
CONFIG             := $(OS)-$(ARCH)-$(PROFILE)
LBIN               := $(CONFIG)/bin

BIT_PACK_CGI       := 1
BIT_PACK_EJSCRIPT  := 0
BIT_PACK_ESP       := 1
BIT_PACK_EST       := 0
BIT_PACK_MATRIXSSL := 0
BIT_PACK_MDB       := 1
BIT_PACK_NANOSSL   := 0
BIT_PACK_OPENSSL   := 0
BIT_PACK_PHP       := 0
BIT_PACK_SDB       := 0
BIT_PACK_SQLITE    := 0
BIT_PACK_SSL       := 0

ifeq ($(BIT_PACK_EST),1)
    BIT_PACK_SSL := 1
endif
ifeq ($(BIT_PACK_LIB),1)
    BIT_PACK_COMPILER := 1
endif
ifeq ($(BIT_PACK_MATRIXSSL),1)
    BIT_PACK_SSL := 1
endif
ifeq ($(BIT_PACK_MDB),1)
    BIT_PACK_ESP := 1
endif
ifeq ($(BIT_PACK_NANOSSL),1)
    BIT_PACK_SSL := 1
endif
ifeq ($(BIT_PACK_OPENSSL),1)
    BIT_PACK_SSL := 1
endif
ifeq ($(BIT_PACK_SDB),1)
    BIT_PACK_ESP := 1
    BIT_PACK_SQLITE := 1
endif

BIT_PACK_CGI_PATH         := cgi
BIT_PACK_COMPILER_PATH    := cc$(subst x86,pentium,$(ARCH))
BIT_PACK_DIR_PATH         := dir
BIT_PACK_DOXYGEN_PATH     := doxygen
BIT_PACK_DSI_PATH         := dsi
BIT_PACK_EJSCRIPT_PATH    := ejscript
BIT_PACK_ESP_PATH         := esp
BIT_PACK_EST_PATH         := est
BIT_PACK_LIB_PATH         := ar
BIT_PACK_LINK_PATH        := link
BIT_PACK_MAN_PATH         := man
BIT_PACK_MAN2HTML_PATH    := man2html
BIT_PACK_MATRIXSSL_PATH   := /usr/src/matrixssl
BIT_PACK_MDB_PATH         := mdb
BIT_PACK_NANOSSL_PATH     := /usr/src/nanossl
BIT_PACK_OPENSSL_PATH     := /usr/src/openssl
BIT_PACK_PCRE_PATH        := pcre
BIT_PACK_PHP_PATH         := /usr/src/php
BIT_PACK_PMAKER_PATH      := pmaker
BIT_PACK_SDB_PATH         := sdb
BIT_PACK_SQLITE_PATH      := sqlite
BIT_PACK_SSL_PATH         := ssl
BIT_PACK_UTEST_PATH       := utest
BIT_PACK_VXWORKS_PATH     := $(WIND_BASE)
BIT_PACK_ZIP_PATH         := zip

export WIND_BASE := $(WIND_BASE)
export WIND_HOME := $(WIND_BASE)/..
export WIND_PLATFORM := $(WIND_PLATFORM)

CFLAGS             += -fno-builtin -fno-defer-pop -fvolatile -w
DFLAGS             += -D_REENTRANT -DVXWORKS -DRW_MULTI_THREAD -D_GNU_TOOL -DCPU=PENTIUM $(patsubst %,-D%,$(filter BIT_%,$(MAKEFLAGS))) -DBIT_PACK_CGI=$(BIT_PACK_CGI) -DBIT_PACK_EJSCRIPT=$(BIT_PACK_EJSCRIPT) -DBIT_PACK_ESP=$(BIT_PACK_ESP) -DBIT_PACK_EST=$(BIT_PACK_EST) -DBIT_PACK_MATRIXSSL=$(BIT_PACK_MATRIXSSL) -DBIT_PACK_MDB=$(BIT_PACK_MDB) -DBIT_PACK_NANOSSL=$(BIT_PACK_NANOSSL) -DBIT_PACK_OPENSSL=$(BIT_PACK_OPENSSL) -DBIT_PACK_PHP=$(BIT_PACK_PHP) -DBIT_PACK_SDB=$(BIT_PACK_SDB) -DBIT_PACK_SQLITE=$(BIT_PACK_SQLITE) -DBIT_PACK_SSL=$(BIT_PACK_SSL) 
IFLAGS             += -I$(CONFIG)/inc -I$(WIND_BASE)/target/h -I$(WIND_BASE)/target/h/wrn/coreip
LDFLAGS            += '-Wl,-r'
LIBPATHS           += -L$(CONFIG)/bin
LIBS               += 

DEBUG              := debug
CFLAGS-debug       := -g
DFLAGS-debug       := -DBIT_DEBUG
LDFLAGS-debug      := -g
DFLAGS-release     := 
CFLAGS-release     := -O2
LDFLAGS-release    := 
CFLAGS             += $(CFLAGS-$(DEBUG))
DFLAGS             += $(DFLAGS-$(DEBUG))
LDFLAGS            += $(LDFLAGS-$(DEBUG))

BIT_ROOT_PREFIX    := deploy
BIT_BASE_PREFIX    := $(BIT_ROOT_PREFIX)
BIT_DATA_PREFIX    := $(BIT_VAPP_PREFIX)
BIT_STATE_PREFIX   := $(BIT_VAPP_PREFIX)
BIT_BIN_PREFIX     := $(BIT_VAPP_PREFIX)
BIT_INC_PREFIX     := $(BIT_VAPP_PREFIX)/inc
BIT_LIB_PREFIX     := $(BIT_VAPP_PREFIX)
BIT_MAN_PREFIX     := $(BIT_VAPP_PREFIX)
BIT_SBIN_PREFIX    := $(BIT_VAPP_PREFIX)
BIT_ETC_PREFIX     := $(BIT_VAPP_PREFIX)
BIT_WEB_PREFIX     := $(BIT_VAPP_PREFIX)/web
BIT_LOG_PREFIX     := $(BIT_VAPP_PREFIX)
BIT_SPOOL_PREFIX   := $(BIT_VAPP_PREFIX)
BIT_CACHE_PREFIX   := $(BIT_VAPP_PREFIX)
BIT_APP_PREFIX     := $(BIT_BASE_PREFIX)
BIT_VAPP_PREFIX    := $(BIT_APP_PREFIX)
BIT_SRC_PREFIX     := $(BIT_ROOT_PREFIX)/usr/src/$(PRODUCT)-$(VERSION)


TARGETS            += $(CONFIG)/bin/libmpr.a
ifeq ($(BIT_PACK_SSL),1)
TARGETS            += $(CONFIG)/bin/libmprssl.a
endif
TARGETS            += $(CONFIG)/bin/appman.out
TARGETS            += $(CONFIG)/bin/makerom.out
TARGETS            += $(CONFIG)/bin/ca.crt
TARGETS            += $(CONFIG)/bin/libpcre.a
TARGETS            += $(CONFIG)/bin/libhttp.a
TARGETS            += $(CONFIG)/bin/http.out
ifeq ($(BIT_PACK_SQLITE),1)
TARGETS            += $(CONFIG)/bin/libsqlite3.a
endif
ifeq ($(BIT_PACK_SQLITE),1)
TARGETS            += $(CONFIG)/bin/sqlite.out
endif
TARGETS            += $(CONFIG)/bin/libappweb.a
ifeq ($(BIT_PACK_ESP),1)
TARGETS            += $(CONFIG)/bin/libmod_esp.a
endif
ifeq ($(BIT_PACK_ESP),1)
TARGETS            += $(CONFIG)/bin/esp.out
endif
ifeq ($(BIT_PACK_ESP),1)
TARGETS            += $(CONFIG)/bin/esp.conf
endif
ifeq ($(BIT_PACK_ESP),1)
TARGETS            += src/server/esp.conf
endif
ifeq ($(BIT_PACK_ESP),1)
TARGETS            += $(CONFIG)/bin/esp-www
endif
ifeq ($(BIT_PACK_ESP),1)
TARGETS            += $(CONFIG)/bin/esp-appweb.conf
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
TARGETS            += $(CONFIG)/bin/libejs.a
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
TARGETS            += $(CONFIG)/bin/ejs.out
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
TARGETS            += $(CONFIG)/bin/ejsc.out
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
TARGETS            += $(CONFIG)/bin/ejs.mod
endif
ifeq ($(BIT_PACK_CGI),1)
TARGETS            += $(CONFIG)/bin/libmod_cgi.a
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
TARGETS            += $(CONFIG)/bin/libmod_ejs.a
endif
ifeq ($(BIT_PACK_PHP),1)
TARGETS            += $(CONFIG)/bin/libmod_php.a
endif
ifeq ($(BIT_PACK_SSL),1)
TARGETS            += $(CONFIG)/bin/libmod_ssl.a
endif
TARGETS            += $(CONFIG)/bin/authpass.out
ifeq ($(BIT_PACK_CGI),1)
TARGETS            += $(CONFIG)/bin/cgiProgram.out
endif
TARGETS            += src/server/slink.c
TARGETS            += $(CONFIG)/bin/libslink.a
TARGETS            += $(CONFIG)/bin/appweb.out
TARGETS            += src/server/cache
TARGETS            += $(CONFIG)/bin/testAppweb.out
ifeq ($(BIT_PACK_CGI),1)
TARGETS            += test/cgi-bin/testScript
endif
ifeq ($(BIT_PACK_CGI),1)
TARGETS            += test/web/caching/cache.cgi
endif
ifeq ($(BIT_PACK_CGI),1)
TARGETS            += test/web/auth/basic/basic.cgi
endif
ifeq ($(BIT_PACK_CGI),1)
TARGETS            += test/cgi-bin/cgiProgram.out
endif
TARGETS            += test/web/js

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
	@[ ! -f $(CONFIG)/inc/bit.h ] && cp projects/appweb-vxworks-static-bit.h $(CONFIG)/inc/bit.h ; true
	@[ ! -f $(CONFIG)/inc/bitos.h ] && cp src/bitos.h $(CONFIG)/inc/bitos.h ; true
	@if ! diff $(CONFIG)/inc/bitos.h src/bitos.h >/dev/null ; then\
		cp src/bitos.h $(CONFIG)/inc/bitos.h  ; \
	fi; true
	@if ! diff $(CONFIG)/inc/bit.h projects/appweb-vxworks-static-bit.h >/dev/null ; then\
		cp projects/appweb-vxworks-static-bit.h $(CONFIG)/inc/bit.h  ; \
	fi; true
	@if [ -f "$(CONFIG)/.makeflags" ] ; then \
		if [ "$(MAKEFLAGS)" != " ` cat $(CONFIG)/.makeflags`" ] ; then \
			echo "   [Warning] Make flags have changed since the last build: "`cat $(CONFIG)/.makeflags`"" ; \
		fi ; \
	fi
	@echo $(MAKEFLAGS) >$(CONFIG)/.makeflags
clean:
	rm -fr "$(CONFIG)/bin/libmpr.a"
	rm -fr "$(CONFIG)/bin/libmprssl.a"
	rm -fr "$(CONFIG)/bin/appman.out"
	rm -fr "$(CONFIG)/bin/makerom.out"
	rm -fr "$(CONFIG)/bin/libest.a"
	rm -fr "$(CONFIG)/bin/ca.crt"
	rm -fr "$(CONFIG)/bin/libpcre.a"
	rm -fr "$(CONFIG)/bin/libhttp.a"
	rm -fr "$(CONFIG)/bin/http.out"
	rm -fr "$(CONFIG)/bin/libsqlite3.a"
	rm -fr "$(CONFIG)/bin/sqlite.out"
	rm -fr "$(CONFIG)/bin/libappweb.a"
	rm -fr "$(CONFIG)/bin/libmod_esp.a"
	rm -fr "$(CONFIG)/bin/esp.out"
	rm -fr "$(CONFIG)/bin/esp.conf"
	rm -fr "src/server/esp.conf"
	rm -fr "$(CONFIG)/bin/esp-www"
	rm -fr "$(CONFIG)/bin/esp-appweb.conf"
	rm -fr "$(CONFIG)/bin/libejs.a"
	rm -fr "$(CONFIG)/bin/ejs.out"
	rm -fr "$(CONFIG)/bin/ejsc.out"
	rm -fr "$(CONFIG)/bin/libmod_cgi.a"
	rm -fr "$(CONFIG)/bin/libmod_ejs.a"
	rm -fr "$(CONFIG)/bin/libmod_php.a"
	rm -fr "$(CONFIG)/bin/libmod_ssl.a"
	rm -fr "$(CONFIG)/bin/authpass.out"
	rm -fr "$(CONFIG)/bin/cgiProgram.out"
	rm -fr "$(CONFIG)/bin/libslink.a"
	rm -fr "$(CONFIG)/bin/appweb.out"
	rm -fr "$(CONFIG)/bin/testAppweb.out"
	rm -fr "test/web/js"
	rm -fr "$(CONFIG)/obj/mprLib.o"
	rm -fr "$(CONFIG)/obj/mprSsl.o"
	rm -fr "$(CONFIG)/obj/manager.o"
	rm -fr "$(CONFIG)/obj/makerom.o"
	rm -fr "$(CONFIG)/obj/estLib.o"
	rm -fr "$(CONFIG)/obj/pcre.o"
	rm -fr "$(CONFIG)/obj/httpLib.o"
	rm -fr "$(CONFIG)/obj/http.o"
	rm -fr "$(CONFIG)/obj/sqlite3.o"
	rm -fr "$(CONFIG)/obj/sqlite.o"
	rm -fr "$(CONFIG)/obj/config.o"
	rm -fr "$(CONFIG)/obj/convenience.o"
	rm -fr "$(CONFIG)/obj/dirHandler.o"
	rm -fr "$(CONFIG)/obj/fileHandler.o"
	rm -fr "$(CONFIG)/obj/log.o"
	rm -fr "$(CONFIG)/obj/server.o"
	rm -fr "$(CONFIG)/obj/edi.o"
	rm -fr "$(CONFIG)/obj/espAbbrev.o"
	rm -fr "$(CONFIG)/obj/espFramework.o"
	rm -fr "$(CONFIG)/obj/espHandler.o"
	rm -fr "$(CONFIG)/obj/espHtml.o"
	rm -fr "$(CONFIG)/obj/espTemplate.o"
	rm -fr "$(CONFIG)/obj/mdb.o"
	rm -fr "$(CONFIG)/obj/sdb.o"
	rm -fr "$(CONFIG)/obj/esp.o"
	rm -fr "$(CONFIG)/obj/ejsLib.o"
	rm -fr "$(CONFIG)/obj/ejs.o"
	rm -fr "$(CONFIG)/obj/ejsc.o"
	rm -fr "$(CONFIG)/obj/cgiHandler.o"
	rm -fr "$(CONFIG)/obj/ejsHandler.o"
	rm -fr "$(CONFIG)/obj/phpHandler.o"
	rm -fr "$(CONFIG)/obj/sslModule.o"
	rm -fr "$(CONFIG)/obj/authpass.o"
	rm -fr "$(CONFIG)/obj/cgiProgram.o"
	rm -fr "$(CONFIG)/obj/slink.o"
	rm -fr "$(CONFIG)/obj/appweb.o"
	rm -fr "$(CONFIG)/obj/testAppweb.o"
	rm -fr "$(CONFIG)/obj/testHttp.o"

clobber: clean
	rm -fr ./$(CONFIG)



#
#   version
#
version: $(DEPS_1)
	@echo 4.3.1-0

#
#   mpr.h
#
$(CONFIG)/inc/mpr.h: $(DEPS_2)
	@echo '      [Copy] $(CONFIG)/inc/mpr.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/deps/mpr/mpr.h $(CONFIG)/inc/mpr.h

#
#   bit.h
#
$(CONFIG)/inc/bit.h: $(DEPS_3)
	@echo '      [Copy] $(CONFIG)/inc/bit.h'

#
#   bitos.h
#
DEPS_4 += $(CONFIG)/inc/bit.h

$(CONFIG)/inc/bitos.h: $(DEPS_4)
	@echo '      [Copy] $(CONFIG)/inc/bitos.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/bitos.h $(CONFIG)/inc/bitos.h

#
#   mprLib.o
#
DEPS_5 += $(CONFIG)/inc/bit.h
DEPS_5 += $(CONFIG)/inc/mpr.h
DEPS_5 += $(CONFIG)/inc/bitos.h

$(CONFIG)/obj/mprLib.o: \
    src/deps/mpr/mprLib.c $(DEPS_5)
	@echo '   [Compile] src/deps/mpr/mprLib.c'
	$(CC) -c -o $(CONFIG)/obj/mprLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/mpr/mprLib.c

#
#   libmpr
#
DEPS_6 += $(CONFIG)/inc/mpr.h
DEPS_6 += $(CONFIG)/obj/mprLib.o

$(CONFIG)/bin/libmpr.a: $(DEPS_6)
	@echo '      [Link] libmpr'
	ar -cr $(CONFIG)/bin/libmpr.a $(CONFIG)/obj/mprLib.o

#
#   est.h
#
$(CONFIG)/inc/est.h: $(DEPS_7)
	@echo '      [Copy] $(CONFIG)/inc/est.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/deps/est/est.h $(CONFIG)/inc/est.h

#
#   estLib.o
#
DEPS_8 += $(CONFIG)/inc/bit.h
DEPS_8 += $(CONFIG)/inc/est.h
DEPS_8 += $(CONFIG)/inc/bitos.h

$(CONFIG)/obj/estLib.o: \
    src/deps/est/estLib.c $(DEPS_8)
	@echo '   [Compile] src/deps/est/estLib.c'
	$(CC) -c -o $(CONFIG)/obj/estLib.o -fno-builtin -fno-defer-pop -fvolatile $(DFLAGS) $(IFLAGS) src/deps/est/estLib.c

ifeq ($(BIT_PACK_EST),1)
#
#   libest
#
DEPS_9 += $(CONFIG)/inc/est.h
DEPS_9 += $(CONFIG)/obj/estLib.o

$(CONFIG)/bin/libest.a: $(DEPS_9)
	@echo '      [Link] libest'
	ar -cr $(CONFIG)/bin/libest.a $(CONFIG)/obj/estLib.o
endif

#
#   mprSsl.o
#
DEPS_10 += $(CONFIG)/inc/bit.h
DEPS_10 += $(CONFIG)/inc/mpr.h
DEPS_10 += $(CONFIG)/inc/est.h

$(CONFIG)/obj/mprSsl.o: \
    src/deps/mpr/mprSsl.c $(DEPS_10)
	@echo '   [Compile] src/deps/mpr/mprSsl.c'
	$(CC) -c -o $(CONFIG)/obj/mprSsl.o $(CFLAGS) $(DFLAGS) $(IFLAGS) -I$(BIT_PACK_OPENSSL_PATH)/include -I$(BIT_PACK_MATRIXSSL_PATH) -I$(BIT_PACK_MATRIXSSL_PATH)/matrixssl -I$(BIT_PACK_NANOSSL_PATH)/src src/deps/mpr/mprSsl.c

ifeq ($(BIT_PACK_SSL),1)
#
#   libmprssl
#
DEPS_11 += $(CONFIG)/bin/libmpr.a
ifeq ($(BIT_PACK_EST),1)
    DEPS_11 += $(CONFIG)/bin/libest.a
endif
DEPS_11 += $(CONFIG)/obj/mprSsl.o

$(CONFIG)/bin/libmprssl.a: $(DEPS_11)
	@echo '      [Link] libmprssl'
	ar -cr $(CONFIG)/bin/libmprssl.a $(CONFIG)/obj/mprSsl.o
endif

#
#   manager.o
#
DEPS_12 += $(CONFIG)/inc/bit.h
DEPS_12 += $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/manager.o: \
    src/deps/mpr/manager.c $(DEPS_12)
	@echo '   [Compile] src/deps/mpr/manager.c'
	$(CC) -c -o $(CONFIG)/obj/manager.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/mpr/manager.c

#
#   manager
#
DEPS_13 += $(CONFIG)/bin/libmpr.a
DEPS_13 += $(CONFIG)/obj/manager.o

LIBS_13 += -lmpr

$(CONFIG)/bin/appman.out: $(DEPS_13)
	@echo '      [Link] manager'
	$(CC) -o $(CONFIG)/bin/appman.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/manager.o $(LDFLAGS)  $(LIBS_13) $(LIBS_13)

#
#   makerom.o
#
DEPS_14 += $(CONFIG)/inc/bit.h
DEPS_14 += $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/makerom.o: \
    src/deps/mpr/makerom.c $(DEPS_14)
	@echo '   [Compile] src/deps/mpr/makerom.c'
	$(CC) -c -o $(CONFIG)/obj/makerom.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/mpr/makerom.c

#
#   makerom
#
DEPS_15 += $(CONFIG)/bin/libmpr.a
DEPS_15 += $(CONFIG)/obj/makerom.o

LIBS_15 += -lmpr

$(CONFIG)/bin/makerom.out: $(DEPS_15)
	@echo '      [Link] makerom'
	$(CC) -o $(CONFIG)/bin/makerom.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/makerom.o $(LDFLAGS)  $(LIBS_15) $(LIBS_15)

#
#   ca-crt
#
DEPS_16 += src/deps/est/ca.crt

$(CONFIG)/bin/ca.crt: $(DEPS_16)
	@echo '      [Copy] $(CONFIG)/bin/ca.crt'
	mkdir -p "$(CONFIG)/bin"
	cp src/deps/est/ca.crt $(CONFIG)/bin/ca.crt

#
#   pcre.h
#
$(CONFIG)/inc/pcre.h: $(DEPS_17)
	@echo '      [Copy] $(CONFIG)/inc/pcre.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/deps/pcre/pcre.h $(CONFIG)/inc/pcre.h

#
#   pcre.o
#
DEPS_18 += $(CONFIG)/inc/bit.h
DEPS_18 += $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/pcre.o: \
    src/deps/pcre/pcre.c $(DEPS_18)
	@echo '   [Compile] src/deps/pcre/pcre.c'
	$(CC) -c -o $(CONFIG)/obj/pcre.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/pcre/pcre.c

#
#   libpcre
#
DEPS_19 += $(CONFIG)/inc/pcre.h
DEPS_19 += $(CONFIG)/obj/pcre.o

$(CONFIG)/bin/libpcre.a: $(DEPS_19)
	@echo '      [Link] libpcre'
	ar -cr $(CONFIG)/bin/libpcre.a $(CONFIG)/obj/pcre.o

#
#   http.h
#
$(CONFIG)/inc/http.h: $(DEPS_20)
	@echo '      [Copy] $(CONFIG)/inc/http.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/deps/http/http.h $(CONFIG)/inc/http.h

#
#   httpLib.o
#
DEPS_21 += $(CONFIG)/inc/bit.h
DEPS_21 += $(CONFIG)/inc/http.h
DEPS_21 += $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/httpLib.o: \
    src/deps/http/httpLib.c $(DEPS_21)
	@echo '   [Compile] src/deps/http/httpLib.c'
	$(CC) -c -o $(CONFIG)/obj/httpLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/http/httpLib.c

#
#   libhttp
#
DEPS_22 += $(CONFIG)/bin/libmpr.a
DEPS_22 += $(CONFIG)/bin/libpcre.a
DEPS_22 += $(CONFIG)/inc/http.h
DEPS_22 += $(CONFIG)/obj/httpLib.o

$(CONFIG)/bin/libhttp.a: $(DEPS_22)
	@echo '      [Link] libhttp'
	ar -cr $(CONFIG)/bin/libhttp.a $(CONFIG)/obj/httpLib.o

#
#   http.o
#
DEPS_23 += $(CONFIG)/inc/bit.h
DEPS_23 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/http.o: \
    src/deps/http/http.c $(DEPS_23)
	@echo '   [Compile] src/deps/http/http.c'
	$(CC) -c -o $(CONFIG)/obj/http.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/http/http.c

#
#   http
#
DEPS_24 += $(CONFIG)/bin/libhttp.a
DEPS_24 += $(CONFIG)/obj/http.o

LIBS_24 += -lmpr
LIBS_24 += -lpcre
LIBS_24 += -lhttp

$(CONFIG)/bin/http.out: $(DEPS_24)
	@echo '      [Link] http'
	$(CC) -o $(CONFIG)/bin/http.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/http.o $(LDFLAGS)  $(LIBS_24) $(LIBS_24)

#
#   sqlite3.h
#
$(CONFIG)/inc/sqlite3.h: $(DEPS_25)
	@echo '      [Copy] $(CONFIG)/inc/sqlite3.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/deps/sqlite/sqlite3.h $(CONFIG)/inc/sqlite3.h

#
#   sqlite3.o
#
DEPS_26 += $(CONFIG)/inc/bit.h
DEPS_26 += $(CONFIG)/inc/sqlite3.h

$(CONFIG)/obj/sqlite3.o: \
    src/deps/sqlite/sqlite3.c $(DEPS_26)
	@echo '   [Compile] src/deps/sqlite/sqlite3.c'
	$(CC) -c -o $(CONFIG)/obj/sqlite3.o -fno-builtin -fno-defer-pop -fvolatile $(DFLAGS) $(IFLAGS) src/deps/sqlite/sqlite3.c

ifeq ($(BIT_PACK_SQLITE),1)
#
#   libsqlite3
#
DEPS_27 += $(CONFIG)/inc/sqlite3.h
DEPS_27 += $(CONFIG)/obj/sqlite3.o

$(CONFIG)/bin/libsqlite3.a: $(DEPS_27)
	@echo '      [Link] libsqlite3'
	ar -cr $(CONFIG)/bin/libsqlite3.a $(CONFIG)/obj/sqlite3.o
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
    DEPS_29 += $(CONFIG)/bin/libsqlite3.a
endif
DEPS_29 += $(CONFIG)/obj/sqlite.o

ifeq ($(BIT_PACK_SQLITE),1)
    LIBS_29 += -lsqlite3
endif

$(CONFIG)/bin/sqlite.out: $(DEPS_29)
	@echo '      [Link] sqlite'
	$(CC) -o $(CONFIG)/bin/sqlite.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/sqlite.o $(LDFLAGS)  $(LIBS_29) $(LIBS_29)
endif

#
#   appweb.h
#
$(CONFIG)/inc/appweb.h: $(DEPS_30)
	@echo '      [Copy] $(CONFIG)/inc/appweb.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/appweb.h $(CONFIG)/inc/appweb.h

#
#   customize.h
#
$(CONFIG)/inc/customize.h: $(DEPS_31)
	@echo '      [Copy] $(CONFIG)/inc/customize.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/customize.h $(CONFIG)/inc/customize.h

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
DEPS_38 += $(CONFIG)/bin/libhttp.a
DEPS_38 += $(CONFIG)/inc/appweb.h
DEPS_38 += $(CONFIG)/inc/bitos.h
DEPS_38 += $(CONFIG)/inc/customize.h
DEPS_38 += $(CONFIG)/obj/config.o
DEPS_38 += $(CONFIG)/obj/convenience.o
DEPS_38 += $(CONFIG)/obj/dirHandler.o
DEPS_38 += $(CONFIG)/obj/fileHandler.o
DEPS_38 += $(CONFIG)/obj/log.o
DEPS_38 += $(CONFIG)/obj/server.o

$(CONFIG)/bin/libappweb.a: $(DEPS_38)
	@echo '      [Link] libappweb'
	ar -cr $(CONFIG)/bin/libappweb.a $(CONFIG)/obj/config.o $(CONFIG)/obj/convenience.o $(CONFIG)/obj/dirHandler.o $(CONFIG)/obj/fileHandler.o $(CONFIG)/obj/log.o $(CONFIG)/obj/server.o

#
#   edi.h
#
$(CONFIG)/inc/edi.h: $(DEPS_39)
	@echo '      [Copy] $(CONFIG)/inc/edi.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/esp/edi.h $(CONFIG)/inc/edi.h

#
#   esp-app.h
#
$(CONFIG)/inc/esp-app.h: $(DEPS_40)
	@echo '      [Copy] $(CONFIG)/inc/esp-app.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/esp/esp-app.h $(CONFIG)/inc/esp-app.h

#
#   esp.h
#
$(CONFIG)/inc/esp.h: $(DEPS_41)
	@echo '      [Copy] $(CONFIG)/inc/esp.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/esp/esp.h $(CONFIG)/inc/esp.h

#
#   mdb.h
#
$(CONFIG)/inc/mdb.h: $(DEPS_42)
	@echo '      [Copy] $(CONFIG)/inc/mdb.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/esp/mdb.h $(CONFIG)/inc/mdb.h

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

$(CONFIG)/obj/sdb.o: \
    src/esp/sdb.c $(DEPS_50)
	@echo '   [Compile] src/esp/sdb.c'
	$(CC) -c -o $(CONFIG)/obj/sdb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/sdb.c

ifeq ($(BIT_PACK_ESP),1)
#
#   libmod_esp
#
DEPS_51 += $(CONFIG)/bin/libappweb.a
ifeq ($(BIT_PACK_SQLITE),1)
    DEPS_51 += $(CONFIG)/bin/sqlite.out
endif
DEPS_51 += $(CONFIG)/inc/edi.h
DEPS_51 += $(CONFIG)/inc/esp-app.h
DEPS_51 += $(CONFIG)/inc/esp.h
DEPS_51 += $(CONFIG)/inc/mdb.h
DEPS_51 += $(CONFIG)/obj/edi.o
DEPS_51 += $(CONFIG)/obj/espAbbrev.o
DEPS_51 += $(CONFIG)/obj/espFramework.o
DEPS_51 += $(CONFIG)/obj/espHandler.o
DEPS_51 += $(CONFIG)/obj/espHtml.o
DEPS_51 += $(CONFIG)/obj/espTemplate.o
DEPS_51 += $(CONFIG)/obj/mdb.o
DEPS_51 += $(CONFIG)/obj/sdb.o

$(CONFIG)/bin/libmod_esp.a: $(DEPS_51)
	@echo '      [Link] libmod_esp'
	ar -cr $(CONFIG)/bin/libmod_esp.a $(CONFIG)/obj/edi.o $(CONFIG)/obj/espAbbrev.o $(CONFIG)/obj/espFramework.o $(CONFIG)/obj/espHandler.o $(CONFIG)/obj/espHtml.o $(CONFIG)/obj/espTemplate.o $(CONFIG)/obj/mdb.o $(CONFIG)/obj/sdb.o
endif

#
#   esp.o
#
DEPS_52 += $(CONFIG)/inc/bit.h
DEPS_52 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/esp.o: \
    src/esp/esp.c $(DEPS_52)
	@echo '   [Compile] src/esp/esp.c'
	$(CC) -c -o $(CONFIG)/obj/esp.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/esp.c

ifeq ($(BIT_PACK_ESP),1)
#
#   esp
#
DEPS_53 += $(CONFIG)/bin/libappweb.a
ifeq ($(BIT_PACK_SQLITE),1)
    DEPS_53 += $(CONFIG)/bin/sqlite.out
endif
DEPS_53 += $(CONFIG)/obj/edi.o
DEPS_53 += $(CONFIG)/obj/esp.o
DEPS_53 += $(CONFIG)/obj/espAbbrev.o
DEPS_53 += $(CONFIG)/obj/espFramework.o
DEPS_53 += $(CONFIG)/obj/espHandler.o
DEPS_53 += $(CONFIG)/obj/espHtml.o
DEPS_53 += $(CONFIG)/obj/espTemplate.o
DEPS_53 += $(CONFIG)/obj/mdb.o
DEPS_53 += $(CONFIG)/obj/sdb.o

ifeq ($(BIT_PACK_SQLITE),1)
    LIBS_53 += -lsqlite3
endif
LIBS_53 += -lhttp
LIBS_53 += -lpcre
LIBS_53 += -lmpr
LIBS_53 += -lappweb

$(CONFIG)/bin/esp.out: $(DEPS_53)
	@echo '      [Link] esp'
	$(CC) -o $(CONFIG)/bin/esp.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/edi.o $(CONFIG)/obj/esp.o $(CONFIG)/obj/espAbbrev.o $(CONFIG)/obj/espFramework.o $(CONFIG)/obj/espHandler.o $(CONFIG)/obj/espHtml.o $(CONFIG)/obj/espTemplate.o $(CONFIG)/obj/mdb.o $(CONFIG)/obj/sdb.o $(LDFLAGS)  $(LIBS_53) $(LIBS_53)
endif

ifeq ($(BIT_PACK_ESP),1)
#
#   esp.conf
#
DEPS_54 += src/esp/esp.conf

$(CONFIG)/bin/esp.conf: $(DEPS_54)
	@echo '      [Copy] $(CONFIG)/bin/esp.conf'
	mkdir -p "$(CONFIG)/bin"
	cp src/esp/esp.conf $(CONFIG)/bin/esp.conf
endif

ifeq ($(BIT_PACK_ESP),1)
#
#   esp.conf.server
#
DEPS_55 += src/esp/esp.conf

src/server/esp.conf: $(DEPS_55)
	@echo '      [Copy] src/server/esp.conf'
	mkdir -p "src/server"
	cp src/esp/esp.conf src/server/esp.conf
endif

ifeq ($(BIT_PACK_ESP),1)
#
#   esp.www
#
DEPS_56 += src/esp/esp-www

$(CONFIG)/bin/esp-www: $(DEPS_56)
	@echo '      [Copy] $(CONFIG)/bin/esp-www'
	mkdir -p "$(CONFIG)/bin/esp-www"
	cp src/esp/esp-www/app.conf $(CONFIG)/bin/esp-www/app.conf
	cp src/esp/esp-www/appweb.conf $(CONFIG)/bin/esp-www/appweb.conf
	mkdir -p "$(CONFIG)/bin/esp-www/files/layouts"
	cp src/esp/esp-www/files/layouts/default.esp $(CONFIG)/bin/esp-www/files/layouts/default.esp
	mkdir -p "$(CONFIG)/bin/esp-www/files/static/images"
	cp src/esp/esp-www/files/static/images/banner.jpg $(CONFIG)/bin/esp-www/files/static/images/banner.jpg
	cp src/esp/esp-www/files/static/images/favicon.ico $(CONFIG)/bin/esp-www/files/static/images/favicon.ico
	cp src/esp/esp-www/files/static/images/splash.jpg $(CONFIG)/bin/esp-www/files/static/images/splash.jpg
	mkdir -p "$(CONFIG)/bin/esp-www/files/static"
	cp src/esp/esp-www/files/static/index.esp $(CONFIG)/bin/esp-www/files/static/index.esp
	mkdir -p "$(CONFIG)/bin/esp-www/files/static/js"
	cp src/esp/esp-www/files/static/js/jquery-1.9.1.js $(CONFIG)/bin/esp-www/files/static/js/jquery-1.9.1.js
	cp src/esp/esp-www/files/static/js/jquery-1.9.1.min.js $(CONFIG)/bin/esp-www/files/static/js/jquery-1.9.1.min.js
	cp src/esp/esp-www/files/static/js/jquery.esp.js $(CONFIG)/bin/esp-www/files/static/js/jquery.esp.js
	cp src/esp/esp-www/files/static/js/jquery.js $(CONFIG)/bin/esp-www/files/static/js/jquery.js
	cp src/esp/esp-www/files/static/js/jquery.simplemodal.js $(CONFIG)/bin/esp-www/files/static/js/jquery.simplemodal.js
	cp src/esp/esp-www/files/static/js/jquery.tablesorter.js $(CONFIG)/bin/esp-www/files/static/js/jquery.tablesorter.js
	cp src/esp/esp-www/files/static/layout.css $(CONFIG)/bin/esp-www/files/static/layout.css
	mkdir -p "$(CONFIG)/bin/esp-www/files/static/themes"
	cp src/esp/esp-www/files/static/themes/default.css $(CONFIG)/bin/esp-www/files/static/themes/default.css
endif

ifeq ($(BIT_PACK_ESP),1)
#
#   esp-appweb.conf
#
DEPS_57 += src/esp/esp-appweb.conf

$(CONFIG)/bin/esp-appweb.conf: $(DEPS_57)
	@echo '      [Copy] $(CONFIG)/bin/esp-appweb.conf'
	mkdir -p "$(CONFIG)/bin"
	cp src/esp/esp-appweb.conf $(CONFIG)/bin/esp-appweb.conf
endif

#
#   ejs.h
#
$(CONFIG)/inc/ejs.h: $(DEPS_58)
	@echo '      [Copy] $(CONFIG)/inc/ejs.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/deps/ejs/ejs.h $(CONFIG)/inc/ejs.h

#
#   ejs.slots.h
#
$(CONFIG)/inc/ejs.slots.h: $(DEPS_59)
	@echo '      [Copy] $(CONFIG)/inc/ejs.slots.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/deps/ejs/ejs.slots.h $(CONFIG)/inc/ejs.slots.h

#
#   ejsByteGoto.h
#
$(CONFIG)/inc/ejsByteGoto.h: $(DEPS_60)
	@echo '      [Copy] $(CONFIG)/inc/ejsByteGoto.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/deps/ejs/ejsByteGoto.h $(CONFIG)/inc/ejsByteGoto.h

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
DEPS_62 += $(CONFIG)/bin/libhttp.a
DEPS_62 += $(CONFIG)/bin/libpcre.a
DEPS_62 += $(CONFIG)/bin/libmpr.a
DEPS_62 += $(CONFIG)/inc/ejs.h
DEPS_62 += $(CONFIG)/inc/ejs.slots.h
DEPS_62 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_62 += $(CONFIG)/obj/ejsLib.o

$(CONFIG)/bin/libejs.a: $(DEPS_62)
	@echo '      [Link] libejs'
	ar -cr $(CONFIG)/bin/libejs.a $(CONFIG)/obj/ejsLib.o
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
    DEPS_64 += $(CONFIG)/bin/libejs.a
endif
DEPS_64 += $(CONFIG)/obj/ejs.o

LIBS_64 += -lhttp
LIBS_64 += -lpcre
LIBS_64 += -lmpr
ifeq ($(BIT_PACK_SQLITE),1)
    LIBS_64 += -lsqlite3
endif
ifeq ($(BIT_PACK_EST),1)
    LIBS_64 += -lest
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
    LIBS_64 += -lejs
endif

$(CONFIG)/bin/ejs.out: $(DEPS_64)
	@echo '      [Link] ejs'
	$(CC) -o $(CONFIG)/bin/ejs.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/ejs.o $(LDFLAGS)  $(LIBS_64) $(LIBS_64)
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
    DEPS_66 += $(CONFIG)/bin/libejs.a
endif
DEPS_66 += $(CONFIG)/obj/ejsc.o

LIBS_66 += -lhttp
LIBS_66 += -lpcre
LIBS_66 += -lmpr
ifeq ($(BIT_PACK_SQLITE),1)
    LIBS_66 += -lsqlite3
endif
ifeq ($(BIT_PACK_EST),1)
    LIBS_66 += -lest
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
    LIBS_66 += -lejs
endif

$(CONFIG)/bin/ejsc.out: $(DEPS_66)
	@echo '      [Link] ejsc'
	$(CC) -o $(CONFIG)/bin/ejsc.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/ejsc.o $(LDFLAGS)  $(LIBS_66) $(LIBS_66)
endif

ifeq ($(BIT_PACK_EJSCRIPT),1)
#
#   ejs.mod
#
DEPS_67 += src/deps/ejs/ejs.es
ifeq ($(BIT_PACK_EJSCRIPT),1)
    DEPS_67 += $(CONFIG)/bin/ejsc.out
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
DEPS_69 += $(CONFIG)/bin/libappweb.a
DEPS_69 += $(CONFIG)/obj/cgiHandler.o

$(CONFIG)/bin/libmod_cgi.a: $(DEPS_69)
	@echo '      [Link] libmod_cgi'
	ar -cr $(CONFIG)/bin/libmod_cgi.a $(CONFIG)/obj/cgiHandler.o
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
DEPS_71 += $(CONFIG)/bin/libappweb.a
ifeq ($(BIT_PACK_EJSCRIPT),1)
    DEPS_71 += $(CONFIG)/bin/libejs.a
endif
DEPS_71 += $(CONFIG)/obj/ejsHandler.o

$(CONFIG)/bin/libmod_ejs.a: $(DEPS_71)
	@echo '      [Link] libmod_ejs'
	ar -cr $(CONFIG)/bin/libmod_ejs.a $(CONFIG)/obj/ejsHandler.o
endif

#
#   phpHandler.o
#
DEPS_72 += $(CONFIG)/inc/bit.h
DEPS_72 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/phpHandler.o: \
    src/modules/phpHandler.c $(DEPS_72)
	@echo '   [Compile] src/modules/phpHandler.c'
	$(CC) -c -o $(CONFIG)/obj/phpHandler.o -fno-builtin -fno-defer-pop -fvolatile $(DFLAGS) $(IFLAGS) -I$(BIT_PACK_PHP_PATH) -I$(BIT_PACK_PHP_PATH)/main -I$(BIT_PACK_PHP_PATH)/Zend -I$(BIT_PACK_PHP_PATH)/TSRM src/modules/phpHandler.c

ifeq ($(BIT_PACK_PHP),1)
#
#   libmod_php
#
DEPS_73 += $(CONFIG)/bin/libappweb.a
DEPS_73 += $(CONFIG)/obj/phpHandler.o

$(CONFIG)/bin/libmod_php.a: $(DEPS_73)
	@echo '      [Link] libmod_php'
	ar -cr $(CONFIG)/bin/libmod_php.a $(CONFIG)/obj/phpHandler.o
endif

#
#   sslModule.o
#
DEPS_74 += $(CONFIG)/inc/bit.h
DEPS_74 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/sslModule.o: \
    src/modules/sslModule.c $(DEPS_74)
	@echo '   [Compile] src/modules/sslModule.c'
	$(CC) -c -o $(CONFIG)/obj/sslModule.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/modules/sslModule.c

ifeq ($(BIT_PACK_SSL),1)
#
#   libmod_ssl
#
DEPS_75 += $(CONFIG)/bin/libappweb.a
DEPS_75 += $(CONFIG)/obj/sslModule.o

$(CONFIG)/bin/libmod_ssl.a: $(DEPS_75)
	@echo '      [Link] libmod_ssl'
	ar -cr $(CONFIG)/bin/libmod_ssl.a $(CONFIG)/obj/sslModule.o
endif

#
#   authpass.o
#
DEPS_76 += $(CONFIG)/inc/bit.h
DEPS_76 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/authpass.o: \
    src/utils/authpass.c $(DEPS_76)
	@echo '   [Compile] src/utils/authpass.c'
	$(CC) -c -o $(CONFIG)/obj/authpass.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/utils/authpass.c

#
#   authpass
#
DEPS_77 += $(CONFIG)/bin/libappweb.a
DEPS_77 += $(CONFIG)/obj/authpass.o

LIBS_77 += -lhttp
LIBS_77 += -lpcre
LIBS_77 += -lmpr
LIBS_77 += -lappweb

$(CONFIG)/bin/authpass.out: $(DEPS_77)
	@echo '      [Link] authpass'
	$(CC) -o $(CONFIG)/bin/authpass.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/authpass.o $(LDFLAGS)  $(LIBS_77) $(LIBS_77)

#
#   cgiProgram.o
#
DEPS_78 += $(CONFIG)/inc/bit.h

$(CONFIG)/obj/cgiProgram.o: \
    src/utils/cgiProgram.c $(DEPS_78)
	@echo '   [Compile] src/utils/cgiProgram.c'
	$(CC) -c -o $(CONFIG)/obj/cgiProgram.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/utils/cgiProgram.c

ifeq ($(BIT_PACK_CGI),1)
#
#   cgiProgram
#
DEPS_79 += $(CONFIG)/obj/cgiProgram.o

$(CONFIG)/bin/cgiProgram.out: $(DEPS_79)
	@echo '      [Link] cgiProgram'
	$(CC) -o $(CONFIG)/bin/cgiProgram.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/cgiProgram.o $(LDFLAGS) 
endif

#
#   slink.c
#
src/server/slink.c: $(DEPS_80)
	cd src/server; [ ! -f slink.c ] && cp slink.empty slink.c ; true ; cd ../..

#
#   slink.o
#
DEPS_81 += $(CONFIG)/inc/bit.h
DEPS_81 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/slink.o: \
    src/server/slink.c $(DEPS_81)
	@echo '   [Compile] src/server/slink.c'
	$(CC) -c -o $(CONFIG)/obj/slink.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/server/slink.c

#
#   libslink
#
DEPS_82 += src/server/slink.c
ifeq ($(BIT_PACK_ESP),1)
    DEPS_82 += $(CONFIG)/bin/esp.out
endif
ifeq ($(BIT_PACK_ESP),1)
    DEPS_82 += $(CONFIG)/bin/libmod_esp.a
endif
DEPS_82 += $(CONFIG)/obj/slink.o

$(CONFIG)/bin/libslink.a: $(DEPS_82)
	@echo '      [Link] libslink'
	ar -cr $(CONFIG)/bin/libslink.a $(CONFIG)/obj/slink.o

#
#   appweb.o
#
DEPS_83 += $(CONFIG)/inc/bit.h
DEPS_83 += $(CONFIG)/inc/appweb.h
DEPS_83 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/appweb.o: \
    src/server/appweb.c $(DEPS_83)
	@echo '   [Compile] src/server/appweb.c'
	$(CC) -c -o $(CONFIG)/obj/appweb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) -I$(BIT_PACK_PHP_PATH) -I$(BIT_PACK_PHP_PATH)/main -I$(BIT_PACK_PHP_PATH)/Zend -I$(BIT_PACK_PHP_PATH)/TSRM src/server/appweb.c

#
#   appweb
#
DEPS_84 += $(CONFIG)/bin/libappweb.a
DEPS_84 += $(CONFIG)/bin/libslink.a
ifeq ($(BIT_PACK_ESP),1)
    DEPS_84 += $(CONFIG)/bin/libmod_esp.a
endif
ifeq ($(BIT_PACK_SSL),1)
    DEPS_84 += $(CONFIG)/bin/libmod_ssl.a
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
    DEPS_84 += $(CONFIG)/bin/libmod_ejs.a
endif
ifeq ($(BIT_PACK_PHP),1)
    DEPS_84 += $(CONFIG)/bin/libmod_php.a
endif
ifeq ($(BIT_PACK_CGI),1)
    DEPS_84 += $(CONFIG)/bin/libmod_cgi.a
endif
DEPS_84 += $(CONFIG)/obj/appweb.o

ifeq ($(BIT_PACK_CGI),1)
    LIBS_84 += -lmod_cgi
endif
ifeq ($(BIT_PACK_PHP),1)
    LIBS_84 += -lphp5
endif
ifeq ($(BIT_PACK_PHP),1)
    LIBS_84 += -lmod_php
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
    LIBS_84 += -lejs
endif
ifeq ($(BIT_PACK_EST),1)
    LIBS_84 += -lest
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
    LIBS_84 += -lmod_ejs
endif
ifeq ($(BIT_PACK_SSL),1)
    LIBS_84 += -lmod_ssl
endif
ifeq ($(BIT_PACK_SQLITE),1)
    LIBS_84 += -lsqlite3
endif
ifeq ($(BIT_PACK_ESP),1)
    LIBS_84 += -lmod_esp
endif
LIBS_84 += -lslink
LIBS_84 += -lhttp
LIBS_84 += -lpcre
LIBS_84 += -lmpr
LIBS_84 += -lappweb

$(CONFIG)/bin/appweb.out: $(DEPS_84)
	@echo '      [Link] appweb'
	$(CC) -o $(CONFIG)/bin/appweb.out $(LDFLAGS) $(LIBPATHS) -L$(BIT_PACK_PHP_PATH)/.libs $(CONFIG)/obj/appweb.o $(LDFLAGS)  $(LIBS_84) $(LIBS_84)

#
#   server-cache
#
src/server/cache: $(DEPS_85)
	cd src/server; mkdir -p cache ; cd ../..

#
#   testAppweb.h
#
$(CONFIG)/inc/testAppweb.h: $(DEPS_86)
	@echo '      [Copy] $(CONFIG)/inc/testAppweb.h'
	mkdir -p "$(CONFIG)/inc"
	cp test/testAppweb.h $(CONFIG)/inc/testAppweb.h

#
#   testAppweb.o
#
DEPS_87 += $(CONFIG)/inc/bit.h
DEPS_87 += $(CONFIG)/inc/testAppweb.h
DEPS_87 += $(CONFIG)/inc/mpr.h
DEPS_87 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/testAppweb.o: \
    test/testAppweb.c $(DEPS_87)
	@echo '   [Compile] test/testAppweb.c'
	$(CC) -c -o $(CONFIG)/obj/testAppweb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) test/testAppweb.c

#
#   testHttp.o
#
DEPS_88 += $(CONFIG)/inc/bit.h
DEPS_88 += $(CONFIG)/inc/testAppweb.h

$(CONFIG)/obj/testHttp.o: \
    test/testHttp.c $(DEPS_88)
	@echo '   [Compile] test/testHttp.c'
	$(CC) -c -o $(CONFIG)/obj/testHttp.o $(CFLAGS) $(DFLAGS) $(IFLAGS) test/testHttp.c

#
#   testAppweb
#
DEPS_89 += $(CONFIG)/bin/libappweb.a
DEPS_89 += $(CONFIG)/inc/testAppweb.h
DEPS_89 += $(CONFIG)/obj/testAppweb.o
DEPS_89 += $(CONFIG)/obj/testHttp.o

LIBS_89 += -lhttp
LIBS_89 += -lpcre
LIBS_89 += -lmpr
LIBS_89 += -lappweb

$(CONFIG)/bin/testAppweb.out: $(DEPS_89)
	@echo '      [Link] testAppweb'
	$(CC) -o $(CONFIG)/bin/testAppweb.out $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/testAppweb.o $(CONFIG)/obj/testHttp.o $(LDFLAGS)  $(LIBS_89) $(LIBS_89)

ifeq ($(BIT_PACK_CGI),1)
#
#   test-testScript
#
ifeq ($(BIT_PACK_CGI),1)
    DEPS_90 += $(CONFIG)/bin/cgiProgram.out
endif

test/cgi-bin/testScript: $(DEPS_90)
	cd test; echo '#!../$(CONFIG)/bin/cgiProgram.out' >cgi-bin/testScript ; chmod +x cgi-bin/testScript ; cd ..
endif

ifeq ($(BIT_PACK_CGI),1)
#
#   test-cache.cgi
#
test/web/caching/cache.cgi: $(DEPS_91)
	cd test; echo "#!`type -p ejs`" >web/caching/cache.cgi ; cd ..
	cd test; echo 'print("HTTP/1.0 200 OK\nContent-Type: text/plain\n\n" + Date() + "\n")' >>web/caching/cache.cgi ; cd ..
	cd test; chmod +x web/caching/cache.cgi ; cd ..
endif

ifeq ($(BIT_PACK_CGI),1)
#
#   test-basic.cgi
#
test/web/auth/basic/basic.cgi: $(DEPS_92)
	cd test; echo "#!`type -p ejs`" >web/auth/basic/basic.cgi ; cd ..
	cd test; echo 'print("HTTP/1.0 200 OK\nContent-Type: text/plain\n\n" + serialize(App.env, {pretty: true}) + "\n")' >>web/auth/basic/basic.cgi ; cd ..
	cd test; chmod +x web/auth/basic/basic.cgi ; cd ..
endif

ifeq ($(BIT_PACK_CGI),1)
#
#   test-cgiProgram
#
ifeq ($(BIT_PACK_CGI),1)
    DEPS_93 += $(CONFIG)/bin/cgiProgram.out
endif

test/cgi-bin/cgiProgram.out: $(DEPS_93)
	cd test; cp ../$(CONFIG)/bin/cgiProgram.out cgi-bin/cgiProgram.out ; cd ..
	cd test; cp ../$(CONFIG)/bin/cgiProgram.out cgi-bin/nph-cgiProgram.out ; cd ..
	cd test; cp ../$(CONFIG)/bin/cgiProgram.out 'cgi-bin/cgi Program.out' ; cd ..
	cd test; cp ../$(CONFIG)/bin/cgiProgram.out web/cgiProgram.cgi ; cd ..
	cd test; chmod +x cgi-bin/* web/cgiProgram.cgi ; cd ..
endif

#
#   test.js
#
DEPS_94 += src/esp/esp-www/files/static/js

test/web/js: $(DEPS_94)
	@echo '      [Copy] test/web/js'
	mkdir -p "test/web/js"
	cp src/esp/esp-www/files/static/js/jquery-1.9.1.js test/web/js/jquery-1.9.1.js
	cp src/esp/esp-www/files/static/js/jquery-1.9.1.min.js test/web/js/jquery-1.9.1.min.js
	cp src/esp/esp-www/files/static/js/jquery.esp.js test/web/js/jquery.esp.js
	cp src/esp/esp-www/files/static/js/jquery.js test/web/js/jquery.js
	cp src/esp/esp-www/files/static/js/jquery.simplemodal.js test/web/js/jquery.simplemodal.js
	cp src/esp/esp-www/files/static/js/jquery.tablesorter.js test/web/js/jquery.tablesorter.js

#
#   installBinary
#
installBinary: $(DEPS_95)

#
#   install
#
DEPS_96 += installBinary

install: $(DEPS_96)
	


#
#   uninstall
#
DEPS_97 += build

uninstall: $(DEPS_97)
	rm -f "$(BIT_VAPP_PREFIX)/appweb.conf"
	rm -f "$(BIT_VAPP_PREFIX)/esp.conf"
	rm -f "$(BIT_VAPP_PREFIX)/mine.types"
	rm -f "$(BIT_VAPP_PREFIX)/install.conf"
	rm -fr "$(BIT_VAPP_PREFIX)/inc/appweb"

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

