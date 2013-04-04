#
#   appweb-macosx-static.mk -- Makefile to build Embedthis Appweb for macosx
#

PRODUCT            := appweb
VERSION            := 4.3.2
BUILD_NUMBER       := 0
PROFILE            := static
ARCH               := $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/')
OS                 := macosx
CC                 := clang
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
BIT_PACK_PCRE      := 1
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
BIT_PACK_COMPILER_PATH    := clang
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
BIT_PACK_ZIP_PATH         := zip

CFLAGS             += -w
DFLAGS             +=  $(patsubst %,-D%,$(filter BIT_%,$(MAKEFLAGS))) -DBIT_PACK_CGI=$(BIT_PACK_CGI) -DBIT_PACK_EJSCRIPT=$(BIT_PACK_EJSCRIPT) -DBIT_PACK_ESP=$(BIT_PACK_ESP) -DBIT_PACK_EST=$(BIT_PACK_EST) -DBIT_PACK_MATRIXSSL=$(BIT_PACK_MATRIXSSL) -DBIT_PACK_MDB=$(BIT_PACK_MDB) -DBIT_PACK_NANOSSL=$(BIT_PACK_NANOSSL) -DBIT_PACK_OPENSSL=$(BIT_PACK_OPENSSL) -DBIT_PACK_PCRE=$(BIT_PACK_PCRE) -DBIT_PACK_PHP=$(BIT_PACK_PHP) -DBIT_PACK_SDB=$(BIT_PACK_SDB) -DBIT_PACK_SQLITE=$(BIT_PACK_SQLITE) -DBIT_PACK_SSL=$(BIT_PACK_SSL) 
IFLAGS             += -I$(CONFIG)/inc
LDFLAGS            += '-Wl,-rpath,@executable_path/' '-Wl,-rpath,@loader_path/'
LIBPATHS           += -L$(CONFIG)/bin
LIBS               += -ldl -lpthread -lm

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

BIT_ROOT_PREFIX    := 
BIT_BASE_PREFIX    := $(BIT_ROOT_PREFIX)/usr/local
BIT_DATA_PREFIX    := $(BIT_ROOT_PREFIX)/
BIT_STATE_PREFIX   := $(BIT_ROOT_PREFIX)/var
BIT_APP_PREFIX     := $(BIT_BASE_PREFIX)/lib/$(PRODUCT)
BIT_VAPP_PREFIX    := $(BIT_APP_PREFIX)/$(VERSION)
BIT_BIN_PREFIX     := $(BIT_ROOT_PREFIX)/usr/local/bin
BIT_INC_PREFIX     := $(BIT_ROOT_PREFIX)/usr/local/include
BIT_LIB_PREFIX     := $(BIT_ROOT_PREFIX)/usr/local/lib
BIT_MAN_PREFIX     := $(BIT_ROOT_PREFIX)/usr/local/share/man
BIT_SBIN_PREFIX    := $(BIT_ROOT_PREFIX)/usr/local/sbin
BIT_ETC_PREFIX     := $(BIT_ROOT_PREFIX)/etc/$(PRODUCT)
BIT_WEB_PREFIX     := $(BIT_ROOT_PREFIX)/var/www/$(PRODUCT)-default
BIT_LOG_PREFIX     := $(BIT_ROOT_PREFIX)/var/log/$(PRODUCT)
BIT_SPOOL_PREFIX   := $(BIT_ROOT_PREFIX)/var/spool/$(PRODUCT)
BIT_CACHE_PREFIX   := $(BIT_ROOT_PREFIX)/var/spool/$(PRODUCT)/cache
BIT_SRC_PREFIX     := $(BIT_ROOT_PREFIX)$(PRODUCT)-$(VERSION)


TARGETS            += $(CONFIG)/bin/libmpr.a
TARGETS            += $(CONFIG)/bin/libmprssl.a
TARGETS            += $(CONFIG)/bin/appman
TARGETS            += $(CONFIG)/bin/makerom
TARGETS            += $(CONFIG)/bin/ca.crt
ifeq ($(BIT_PACK_PCRE),1)
TARGETS            += $(CONFIG)/bin/libpcre.a
endif
TARGETS            += $(CONFIG)/bin/libhttp.a
TARGETS            += $(CONFIG)/bin/http
ifeq ($(BIT_PACK_SQLITE),1)
TARGETS            += $(CONFIG)/bin/libsqlite3.a
endif
ifeq ($(BIT_PACK_SQLITE),1)
TARGETS            += $(CONFIG)/bin/sqlite
endif
TARGETS            += $(CONFIG)/bin/libappweb.a
ifeq ($(BIT_PACK_ESP),1)
TARGETS            += $(CONFIG)/bin/libmod_esp.a
endif
ifeq ($(BIT_PACK_ESP),1)
TARGETS            += $(CONFIG)/bin/esp
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
TARGETS            += $(CONFIG)/bin/ejs
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
TARGETS            += $(CONFIG)/bin/ejsc
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
TARGETS            += $(CONFIG)/bin/authpass
ifeq ($(BIT_PACK_CGI),1)
TARGETS            += $(CONFIG)/bin/cgiProgram
endif
TARGETS            += src/server/slink.c
TARGETS            += $(CONFIG)/bin/libslink.a
TARGETS            += $(CONFIG)/bin/appweb
TARGETS            += src/server/cache
TARGETS            += $(CONFIG)/bin/testAppweb
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
TARGETS            += test/cgi-bin/cgiProgram
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
	@[ ! -f $(CONFIG)/inc/bit.h ] && cp projects/appweb-macosx-static-bit.h $(CONFIG)/inc/bit.h ; true
	@[ ! -f $(CONFIG)/inc/bitos.h ] && cp src/bitos.h $(CONFIG)/inc/bitos.h ; true
	@if ! diff $(CONFIG)/inc/bitos.h src/bitos.h >/dev/null ; then\
		cp src/bitos.h $(CONFIG)/inc/bitos.h  ; \
	fi; true
	@if ! diff $(CONFIG)/inc/bit.h projects/appweb-macosx-static-bit.h >/dev/null ; then\
		cp projects/appweb-macosx-static-bit.h $(CONFIG)/inc/bit.h  ; \
	fi; true
	@if [ -f "$(CONFIG)/.makeflags" ] ; then \
		if [ "$(MAKEFLAGS)" != " ` cat $(CONFIG)/.makeflags`" ] ; then \
			echo "   [Warning] Make flags have changed since the last build: "`cat $(CONFIG)/.makeflags`"" ; \
		fi ; \
	fi
	@echo $(MAKEFLAGS) >$(CONFIG)/.makeflags

clean:
	rm -f "$(CONFIG)/bin/libmpr.a"
	rm -f "$(CONFIG)/bin/libmprssl.a"
	rm -f "$(CONFIG)/bin/appman"
	rm -f "$(CONFIG)/bin/makerom"
	rm -f "$(CONFIG)/bin/libest.a"
	rm -f "$(CONFIG)/bin/ca.crt"
	rm -f "$(CONFIG)/bin/libpcre.a"
	rm -f "$(CONFIG)/bin/libhttp.a"
	rm -f "$(CONFIG)/bin/http"
	rm -f "$(CONFIG)/bin/libsqlite3.a"
	rm -f "$(CONFIG)/bin/sqlite"
	rm -f "$(CONFIG)/bin/libappweb.a"
	rm -f "$(CONFIG)/bin/libmod_esp.a"
	rm -f "$(CONFIG)/bin/esp"
	rm -f "$(CONFIG)/bin/esp.conf"
	rm -f "src/server/esp.conf"
	rm -fr "$(CONFIG)/bin/esp-www"
	rm -f "$(CONFIG)/bin/esp-appweb.conf"
	rm -f "$(CONFIG)/bin/libejs.a"
	rm -f "$(CONFIG)/bin/ejs"
	rm -f "$(CONFIG)/bin/ejsc"
	rm -f "$(CONFIG)/bin/libmod_cgi.a"
	rm -f "$(CONFIG)/bin/libmod_ejs.a"
	rm -f "$(CONFIG)/bin/libmod_php.a"
	rm -f "$(CONFIG)/bin/libmod_ssl.a"
	rm -f "$(CONFIG)/bin/authpass"
	rm -f "$(CONFIG)/bin/cgiProgram"
	rm -f "$(CONFIG)/bin/libslink.a"
	rm -f "$(CONFIG)/bin/appweb"
	rm -f "$(CONFIG)/bin/testAppweb"
	rm -fr "test/web/js"
	rm -f "$(CONFIG)/obj/mprLib.o"
	rm -f "$(CONFIG)/obj/mprSsl.o"
	rm -f "$(CONFIG)/obj/manager.o"
	rm -f "$(CONFIG)/obj/makerom.o"
	rm -f "$(CONFIG)/obj/estLib.o"
	rm -f "$(CONFIG)/obj/pcre.o"
	rm -f "$(CONFIG)/obj/httpLib.o"
	rm -f "$(CONFIG)/obj/http.o"
	rm -f "$(CONFIG)/obj/sqlite3.o"
	rm -f "$(CONFIG)/obj/sqlite.o"
	rm -f "$(CONFIG)/obj/config.o"
	rm -f "$(CONFIG)/obj/convenience.o"
	rm -f "$(CONFIG)/obj/dirHandler.o"
	rm -f "$(CONFIG)/obj/fileHandler.o"
	rm -f "$(CONFIG)/obj/log.o"
	rm -f "$(CONFIG)/obj/server.o"
	rm -f "$(CONFIG)/obj/edi.o"
	rm -f "$(CONFIG)/obj/espAbbrev.o"
	rm -f "$(CONFIG)/obj/espFramework.o"
	rm -f "$(CONFIG)/obj/espHandler.o"
	rm -f "$(CONFIG)/obj/espHtml.o"
	rm -f "$(CONFIG)/obj/espTemplate.o"
	rm -f "$(CONFIG)/obj/mdb.o"
	rm -f "$(CONFIG)/obj/sdb.o"
	rm -f "$(CONFIG)/obj/esp.o"
	rm -f "$(CONFIG)/obj/ejsLib.o"
	rm -f "$(CONFIG)/obj/ejs.o"
	rm -f "$(CONFIG)/obj/ejsc.o"
	rm -f "$(CONFIG)/obj/cgiHandler.o"
	rm -f "$(CONFIG)/obj/ejsHandler.o"
	rm -f "$(CONFIG)/obj/phpHandler.o"
	rm -f "$(CONFIG)/obj/sslModule.o"
	rm -f "$(CONFIG)/obj/authpass.o"
	rm -f "$(CONFIG)/obj/cgiProgram.o"
	rm -f "$(CONFIG)/obj/slink.o"
	rm -f "$(CONFIG)/obj/appweb.o"
	rm -f "$(CONFIG)/obj/testAppweb.o"
	rm -f "$(CONFIG)/obj/testHttp.o"

clobber: clean
	rm -fr ./$(CONFIG)



#
#   version
#
version: $(DEPS_1)
	@echo 4.3.2-0

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
	@echo '   [Compile] $(CONFIG)/obj/mprLib.o'
	$(CC) -c -o $(CONFIG)/obj/mprLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/mpr/mprLib.c

#
#   libmpr
#
DEPS_6 += $(CONFIG)/inc/mpr.h
DEPS_6 += $(CONFIG)/inc/bit.h
DEPS_6 += $(CONFIG)/inc/bitos.h
DEPS_6 += $(CONFIG)/obj/mprLib.o

$(CONFIG)/bin/libmpr.a: $(DEPS_6)
	@echo '      [Link] $(CONFIG)/bin/libmpr.a'
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
	@echo '   [Compile] $(CONFIG)/obj/estLib.o'
	$(CC) -c -o $(CONFIG)/obj/estLib.o $(DFLAGS) $(IFLAGS) src/deps/est/estLib.c

ifeq ($(BIT_PACK_EST),1)
#
#   libest
#
DEPS_9 += $(CONFIG)/inc/est.h
DEPS_9 += $(CONFIG)/inc/bit.h
DEPS_9 += $(CONFIG)/inc/bitos.h
DEPS_9 += $(CONFIG)/obj/estLib.o

$(CONFIG)/bin/libest.a: $(DEPS_9)
	@echo '      [Link] $(CONFIG)/bin/libest.a'
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
	@echo '   [Compile] $(CONFIG)/obj/mprSsl.o'
	$(CC) -c -o $(CONFIG)/obj/mprSsl.o $(CFLAGS) $(DFLAGS) $(IFLAGS) -I$(BIT_PACK_MATRIXSSL_PATH) -I$(BIT_PACK_MATRIXSSL_PATH)/matrixssl -I$(BIT_PACK_NANOSSL_PATH)/src -I$(BIT_PACK_OPENSSL_PATH)/include src/deps/mpr/mprSsl.c

#
#   libmprssl
#
DEPS_11 += $(CONFIG)/inc/mpr.h
DEPS_11 += $(CONFIG)/inc/bit.h
DEPS_11 += $(CONFIG)/inc/bitos.h
DEPS_11 += $(CONFIG)/obj/mprLib.o
DEPS_11 += $(CONFIG)/bin/libmpr.a
DEPS_11 += $(CONFIG)/inc/est.h
DEPS_11 += $(CONFIG)/obj/estLib.o
ifeq ($(BIT_PACK_EST),1)
    DEPS_11 += $(CONFIG)/bin/libest.a
endif
DEPS_11 += $(CONFIG)/obj/mprSsl.o

$(CONFIG)/bin/libmprssl.a: $(DEPS_11)
	@echo '      [Link] $(CONFIG)/bin/libmprssl.a'
	ar -cr $(CONFIG)/bin/libmprssl.a $(CONFIG)/obj/mprSsl.o

#
#   manager.o
#
DEPS_12 += $(CONFIG)/inc/bit.h
DEPS_12 += $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/manager.o: \
    src/deps/mpr/manager.c $(DEPS_12)
	@echo '   [Compile] $(CONFIG)/obj/manager.o'
	$(CC) -c -o $(CONFIG)/obj/manager.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/mpr/manager.c

#
#   manager
#
DEPS_13 += $(CONFIG)/inc/mpr.h
DEPS_13 += $(CONFIG)/inc/bit.h
DEPS_13 += $(CONFIG)/inc/bitos.h
DEPS_13 += $(CONFIG)/obj/mprLib.o
DEPS_13 += $(CONFIG)/bin/libmpr.a
DEPS_13 += $(CONFIG)/obj/manager.o

LIBS_13 += -lmpr

$(CONFIG)/bin/appman: $(DEPS_13)
	@echo '      [Link] $(CONFIG)/bin/appman'
	$(CC) -o $(CONFIG)/bin/appman -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/manager.o $(LIBPATHS_13) $(LIBS_13) $(LIBS_13) $(LIBS) 

#
#   makerom.o
#
DEPS_14 += $(CONFIG)/inc/bit.h
DEPS_14 += $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/makerom.o: \
    src/deps/mpr/makerom.c $(DEPS_14)
	@echo '   [Compile] $(CONFIG)/obj/makerom.o'
	$(CC) -c -o $(CONFIG)/obj/makerom.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/mpr/makerom.c

#
#   makerom
#
DEPS_15 += $(CONFIG)/inc/mpr.h
DEPS_15 += $(CONFIG)/inc/bit.h
DEPS_15 += $(CONFIG)/inc/bitos.h
DEPS_15 += $(CONFIG)/obj/mprLib.o
DEPS_15 += $(CONFIG)/bin/libmpr.a
DEPS_15 += $(CONFIG)/obj/makerom.o

LIBS_15 += -lmpr

$(CONFIG)/bin/makerom: $(DEPS_15)
	@echo '      [Link] $(CONFIG)/bin/makerom'
	$(CC) -o $(CONFIG)/bin/makerom -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/makerom.o $(LIBPATHS_15) $(LIBS_15) $(LIBS_15) $(LIBS) 

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
	@echo '   [Compile] $(CONFIG)/obj/pcre.o'
	$(CC) -c -o $(CONFIG)/obj/pcre.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/pcre/pcre.c

ifeq ($(BIT_PACK_PCRE),1)
#
#   libpcre
#
DEPS_19 += $(CONFIG)/inc/pcre.h
DEPS_19 += $(CONFIG)/inc/bit.h
DEPS_19 += $(CONFIG)/obj/pcre.o

$(CONFIG)/bin/libpcre.a: $(DEPS_19)
	@echo '      [Link] $(CONFIG)/bin/libpcre.a'
	ar -cr $(CONFIG)/bin/libpcre.a $(CONFIG)/obj/pcre.o
endif

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
	@echo '   [Compile] $(CONFIG)/obj/httpLib.o'
	$(CC) -c -o $(CONFIG)/obj/httpLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/http/httpLib.c

#
#   libhttp
#
DEPS_22 += $(CONFIG)/inc/mpr.h
DEPS_22 += $(CONFIG)/inc/bit.h
DEPS_22 += $(CONFIG)/inc/bitos.h
DEPS_22 += $(CONFIG)/obj/mprLib.o
DEPS_22 += $(CONFIG)/bin/libmpr.a
DEPS_22 += $(CONFIG)/inc/pcre.h
DEPS_22 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_22 += $(CONFIG)/bin/libpcre.a
endif
DEPS_22 += $(CONFIG)/inc/http.h
DEPS_22 += $(CONFIG)/obj/httpLib.o

$(CONFIG)/bin/libhttp.a: $(DEPS_22)
	@echo '      [Link] $(CONFIG)/bin/libhttp.a'
	ar -cr $(CONFIG)/bin/libhttp.a $(CONFIG)/obj/httpLib.o

#
#   http.o
#
DEPS_23 += $(CONFIG)/inc/bit.h
DEPS_23 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/http.o: \
    src/deps/http/http.c $(DEPS_23)
	@echo '   [Compile] $(CONFIG)/obj/http.o'
	$(CC) -c -o $(CONFIG)/obj/http.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/http/http.c

#
#   http
#
DEPS_24 += $(CONFIG)/inc/mpr.h
DEPS_24 += $(CONFIG)/inc/bit.h
DEPS_24 += $(CONFIG)/inc/bitos.h
DEPS_24 += $(CONFIG)/obj/mprLib.o
DEPS_24 += $(CONFIG)/bin/libmpr.a
DEPS_24 += $(CONFIG)/inc/pcre.h
DEPS_24 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_24 += $(CONFIG)/bin/libpcre.a
endif
DEPS_24 += $(CONFIG)/inc/http.h
DEPS_24 += $(CONFIG)/obj/httpLib.o
DEPS_24 += $(CONFIG)/bin/libhttp.a
DEPS_24 += $(CONFIG)/obj/http.o

LIBS_24 += -lhttp
LIBS_24 += -lmpr
ifeq ($(BIT_PACK_PCRE),1)
    LIBS_24 += -lpcre
endif

$(CONFIG)/bin/http: $(DEPS_24)
	@echo '      [Link] $(CONFIG)/bin/http'
	$(CC) -o $(CONFIG)/bin/http -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/http.o $(LIBPATHS_24) $(LIBS_24) $(LIBS_24) $(LIBS) -lpam 

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
	@echo '   [Compile] $(CONFIG)/obj/sqlite3.o'
	$(CC) -c -o $(CONFIG)/obj/sqlite3.o $(DFLAGS) $(IFLAGS) src/deps/sqlite/sqlite3.c

ifeq ($(BIT_PACK_SQLITE),1)
#
#   libsqlite3
#
DEPS_27 += $(CONFIG)/inc/sqlite3.h
DEPS_27 += $(CONFIG)/inc/bit.h
DEPS_27 += $(CONFIG)/obj/sqlite3.o

$(CONFIG)/bin/libsqlite3.a: $(DEPS_27)
	@echo '      [Link] $(CONFIG)/bin/libsqlite3.a'
	ar -cr $(CONFIG)/bin/libsqlite3.a $(CONFIG)/obj/sqlite3.o
endif

#
#   sqlite.o
#
DEPS_28 += $(CONFIG)/inc/bit.h
DEPS_28 += $(CONFIG)/inc/sqlite3.h

$(CONFIG)/obj/sqlite.o: \
    src/deps/sqlite/sqlite.c $(DEPS_28)
	@echo '   [Compile] $(CONFIG)/obj/sqlite.o'
	$(CC) -c -o $(CONFIG)/obj/sqlite.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/sqlite/sqlite.c

ifeq ($(BIT_PACK_SQLITE),1)
#
#   sqliteshell
#
DEPS_29 += $(CONFIG)/inc/sqlite3.h
DEPS_29 += $(CONFIG)/inc/bit.h
DEPS_29 += $(CONFIG)/obj/sqlite3.o
DEPS_29 += $(CONFIG)/bin/libsqlite3.a
DEPS_29 += $(CONFIG)/obj/sqlite.o

LIBS_29 += -lsqlite3

$(CONFIG)/bin/sqlite: $(DEPS_29)
	@echo '      [Link] $(CONFIG)/bin/sqlite'
	$(CC) -o $(CONFIG)/bin/sqlite -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/sqlite.o $(LIBPATHS_29) $(LIBS_29) $(LIBS_29) $(LIBS) 
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
	@echo '   [Compile] $(CONFIG)/obj/config.o'
	$(CC) -c -o $(CONFIG)/obj/config.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/config.c

#
#   convenience.o
#
DEPS_33 += $(CONFIG)/inc/bit.h
DEPS_33 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/convenience.o: \
    src/convenience.c $(DEPS_33)
	@echo '   [Compile] $(CONFIG)/obj/convenience.o'
	$(CC) -c -o $(CONFIG)/obj/convenience.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/convenience.c

#
#   dirHandler.o
#
DEPS_34 += $(CONFIG)/inc/bit.h
DEPS_34 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/dirHandler.o: \
    src/dirHandler.c $(DEPS_34)
	@echo '   [Compile] $(CONFIG)/obj/dirHandler.o'
	$(CC) -c -o $(CONFIG)/obj/dirHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/dirHandler.c

#
#   fileHandler.o
#
DEPS_35 += $(CONFIG)/inc/bit.h
DEPS_35 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/fileHandler.o: \
    src/fileHandler.c $(DEPS_35)
	@echo '   [Compile] $(CONFIG)/obj/fileHandler.o'
	$(CC) -c -o $(CONFIG)/obj/fileHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/fileHandler.c

#
#   log.o
#
DEPS_36 += $(CONFIG)/inc/bit.h
DEPS_36 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/log.o: \
    src/log.c $(DEPS_36)
	@echo '   [Compile] $(CONFIG)/obj/log.o'
	$(CC) -c -o $(CONFIG)/obj/log.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/log.c

#
#   server.o
#
DEPS_37 += $(CONFIG)/inc/bit.h
DEPS_37 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/server.o: \
    src/server.c $(DEPS_37)
	@echo '   [Compile] $(CONFIG)/obj/server.o'
	$(CC) -c -o $(CONFIG)/obj/server.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/server.c

#
#   libappweb
#
DEPS_38 += $(CONFIG)/inc/mpr.h
DEPS_38 += $(CONFIG)/inc/bit.h
DEPS_38 += $(CONFIG)/inc/bitos.h
DEPS_38 += $(CONFIG)/obj/mprLib.o
DEPS_38 += $(CONFIG)/bin/libmpr.a
DEPS_38 += $(CONFIG)/inc/pcre.h
DEPS_38 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_38 += $(CONFIG)/bin/libpcre.a
endif
DEPS_38 += $(CONFIG)/inc/http.h
DEPS_38 += $(CONFIG)/obj/httpLib.o
DEPS_38 += $(CONFIG)/bin/libhttp.a
DEPS_38 += $(CONFIG)/inc/appweb.h
DEPS_38 += $(CONFIG)/inc/customize.h
DEPS_38 += $(CONFIG)/obj/config.o
DEPS_38 += $(CONFIG)/obj/convenience.o
DEPS_38 += $(CONFIG)/obj/dirHandler.o
DEPS_38 += $(CONFIG)/obj/fileHandler.o
DEPS_38 += $(CONFIG)/obj/log.o
DEPS_38 += $(CONFIG)/obj/server.o

$(CONFIG)/bin/libappweb.a: $(DEPS_38)
	@echo '      [Link] $(CONFIG)/bin/libappweb.a'
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
	@echo '   [Compile] $(CONFIG)/obj/edi.o'
	$(CC) -c -o $(CONFIG)/obj/edi.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/edi.c

#
#   espAbbrev.o
#
DEPS_44 += $(CONFIG)/inc/bit.h
DEPS_44 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espAbbrev.o: \
    src/esp/espAbbrev.c $(DEPS_44)
	@echo '   [Compile] $(CONFIG)/obj/espAbbrev.o'
	$(CC) -c -o $(CONFIG)/obj/espAbbrev.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/espAbbrev.c

#
#   espFramework.o
#
DEPS_45 += $(CONFIG)/inc/bit.h
DEPS_45 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espFramework.o: \
    src/esp/espFramework.c $(DEPS_45)
	@echo '   [Compile] $(CONFIG)/obj/espFramework.o'
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
	@echo '   [Compile] $(CONFIG)/obj/espHandler.o'
	$(CC) -c -o $(CONFIG)/obj/espHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/espHandler.c

#
#   espHtml.o
#
DEPS_47 += $(CONFIG)/inc/bit.h
DEPS_47 += $(CONFIG)/inc/esp.h
DEPS_47 += $(CONFIG)/inc/edi.h

$(CONFIG)/obj/espHtml.o: \
    src/esp/espHtml.c $(DEPS_47)
	@echo '   [Compile] $(CONFIG)/obj/espHtml.o'
	$(CC) -c -o $(CONFIG)/obj/espHtml.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/espHtml.c

#
#   espTemplate.o
#
DEPS_48 += $(CONFIG)/inc/bit.h
DEPS_48 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espTemplate.o: \
    src/esp/espTemplate.c $(DEPS_48)
	@echo '   [Compile] $(CONFIG)/obj/espTemplate.o'
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
	@echo '   [Compile] $(CONFIG)/obj/mdb.o'
	$(CC) -c -o $(CONFIG)/obj/mdb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/mdb.c

#
#   sdb.o
#
DEPS_50 += $(CONFIG)/inc/bit.h
DEPS_50 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/sdb.o: \
    src/esp/sdb.c $(DEPS_50)
	@echo '   [Compile] $(CONFIG)/obj/sdb.o'
	$(CC) -c -o $(CONFIG)/obj/sdb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/sdb.c

ifeq ($(BIT_PACK_ESP),1)
#
#   libmod_esp
#
DEPS_51 += $(CONFIG)/inc/mpr.h
DEPS_51 += $(CONFIG)/inc/bit.h
DEPS_51 += $(CONFIG)/inc/bitos.h
DEPS_51 += $(CONFIG)/obj/mprLib.o
DEPS_51 += $(CONFIG)/bin/libmpr.a
DEPS_51 += $(CONFIG)/inc/pcre.h
DEPS_51 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_51 += $(CONFIG)/bin/libpcre.a
endif
DEPS_51 += $(CONFIG)/inc/http.h
DEPS_51 += $(CONFIG)/obj/httpLib.o
DEPS_51 += $(CONFIG)/bin/libhttp.a
DEPS_51 += $(CONFIG)/inc/appweb.h
DEPS_51 += $(CONFIG)/inc/customize.h
DEPS_51 += $(CONFIG)/obj/config.o
DEPS_51 += $(CONFIG)/obj/convenience.o
DEPS_51 += $(CONFIG)/obj/dirHandler.o
DEPS_51 += $(CONFIG)/obj/fileHandler.o
DEPS_51 += $(CONFIG)/obj/log.o
DEPS_51 += $(CONFIG)/obj/server.o
DEPS_51 += $(CONFIG)/bin/libappweb.a
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
	@echo '      [Link] $(CONFIG)/bin/libmod_esp.a'
	ar -cr $(CONFIG)/bin/libmod_esp.a $(CONFIG)/obj/edi.o $(CONFIG)/obj/espAbbrev.o $(CONFIG)/obj/espFramework.o $(CONFIG)/obj/espHandler.o $(CONFIG)/obj/espHtml.o $(CONFIG)/obj/espTemplate.o $(CONFIG)/obj/mdb.o $(CONFIG)/obj/sdb.o
endif

#
#   esp.o
#
DEPS_52 += $(CONFIG)/inc/bit.h
DEPS_52 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/esp.o: \
    src/esp/esp.c $(DEPS_52)
	@echo '   [Compile] $(CONFIG)/obj/esp.o'
	$(CC) -c -o $(CONFIG)/obj/esp.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/esp.c

ifeq ($(BIT_PACK_ESP),1)
#
#   espcmd
#
DEPS_53 += $(CONFIG)/inc/mpr.h
DEPS_53 += $(CONFIG)/inc/bit.h
DEPS_53 += $(CONFIG)/inc/bitos.h
DEPS_53 += $(CONFIG)/obj/mprLib.o
DEPS_53 += $(CONFIG)/bin/libmpr.a
DEPS_53 += $(CONFIG)/inc/pcre.h
DEPS_53 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_53 += $(CONFIG)/bin/libpcre.a
endif
DEPS_53 += $(CONFIG)/inc/http.h
DEPS_53 += $(CONFIG)/obj/httpLib.o
DEPS_53 += $(CONFIG)/bin/libhttp.a
DEPS_53 += $(CONFIG)/inc/appweb.h
DEPS_53 += $(CONFIG)/inc/customize.h
DEPS_53 += $(CONFIG)/obj/config.o
DEPS_53 += $(CONFIG)/obj/convenience.o
DEPS_53 += $(CONFIG)/obj/dirHandler.o
DEPS_53 += $(CONFIG)/obj/fileHandler.o
DEPS_53 += $(CONFIG)/obj/log.o
DEPS_53 += $(CONFIG)/obj/server.o
DEPS_53 += $(CONFIG)/bin/libappweb.a
DEPS_53 += $(CONFIG)/inc/edi.h
DEPS_53 += $(CONFIG)/obj/edi.o
DEPS_53 += $(CONFIG)/inc/esp.h
DEPS_53 += $(CONFIG)/obj/esp.o
DEPS_53 += $(CONFIG)/obj/espAbbrev.o
DEPS_53 += $(CONFIG)/obj/espFramework.o
DEPS_53 += $(CONFIG)/obj/espHandler.o
DEPS_53 += $(CONFIG)/obj/espHtml.o
DEPS_53 += $(CONFIG)/obj/espTemplate.o
DEPS_53 += $(CONFIG)/inc/mdb.h
DEPS_53 += $(CONFIG)/obj/mdb.o
DEPS_53 += $(CONFIG)/obj/sdb.o

LIBS_53 += -lappweb
LIBS_53 += -lhttp
LIBS_53 += -lmpr
ifeq ($(BIT_PACK_PCRE),1)
    LIBS_53 += -lpcre
endif
ifeq ($(BIT_PACK_SQLITE),1)
    LIBS_53 += -lsqlite3
endif

$(CONFIG)/bin/esp: $(DEPS_53)
	@echo '      [Link] $(CONFIG)/bin/esp'
	$(CC) -o $(CONFIG)/bin/esp -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/edi.o $(CONFIG)/obj/esp.o $(CONFIG)/obj/espAbbrev.o $(CONFIG)/obj/espFramework.o $(CONFIG)/obj/espHandler.o $(CONFIG)/obj/espHtml.o $(CONFIG)/obj/espTemplate.o $(CONFIG)/obj/mdb.o $(CONFIG)/obj/sdb.o $(LIBPATHS_53) $(LIBS_53) $(LIBS_53) $(LIBS) -lpam 
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
	@echo '   [Compile] $(CONFIG)/obj/ejsLib.o'
	$(CC) -c -o $(CONFIG)/obj/ejsLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/ejs/ejsLib.c

ifeq ($(BIT_PACK_EJSCRIPT),1)
#
#   libejs
#
DEPS_62 += $(CONFIG)/inc/mpr.h
DEPS_62 += $(CONFIG)/inc/bit.h
DEPS_62 += $(CONFIG)/inc/bitos.h
DEPS_62 += $(CONFIG)/obj/mprLib.o
DEPS_62 += $(CONFIG)/bin/libmpr.a
DEPS_62 += $(CONFIG)/inc/pcre.h
DEPS_62 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_62 += $(CONFIG)/bin/libpcre.a
endif
DEPS_62 += $(CONFIG)/inc/http.h
DEPS_62 += $(CONFIG)/obj/httpLib.o
DEPS_62 += $(CONFIG)/bin/libhttp.a
DEPS_62 += $(CONFIG)/inc/ejs.h
DEPS_62 += $(CONFIG)/inc/ejs.slots.h
DEPS_62 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_62 += $(CONFIG)/obj/ejsLib.o

$(CONFIG)/bin/libejs.a: $(DEPS_62)
	@echo '      [Link] $(CONFIG)/bin/libejs.a'
	ar -cr $(CONFIG)/bin/libejs.a $(CONFIG)/obj/ejsLib.o
endif

#
#   ejs.o
#
DEPS_63 += $(CONFIG)/inc/bit.h
DEPS_63 += $(CONFIG)/inc/ejs.h

$(CONFIG)/obj/ejs.o: \
    src/deps/ejs/ejs.c $(DEPS_63)
	@echo '   [Compile] $(CONFIG)/obj/ejs.o'
	$(CC) -c -o $(CONFIG)/obj/ejs.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/ejs/ejs.c

ifeq ($(BIT_PACK_EJSCRIPT),1)
#
#   ejs
#
DEPS_64 += $(CONFIG)/inc/mpr.h
DEPS_64 += $(CONFIG)/inc/bit.h
DEPS_64 += $(CONFIG)/inc/bitos.h
DEPS_64 += $(CONFIG)/obj/mprLib.o
DEPS_64 += $(CONFIG)/bin/libmpr.a
DEPS_64 += $(CONFIG)/inc/pcre.h
DEPS_64 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_64 += $(CONFIG)/bin/libpcre.a
endif
DEPS_64 += $(CONFIG)/inc/http.h
DEPS_64 += $(CONFIG)/obj/httpLib.o
DEPS_64 += $(CONFIG)/bin/libhttp.a
DEPS_64 += $(CONFIG)/inc/ejs.h
DEPS_64 += $(CONFIG)/inc/ejs.slots.h
DEPS_64 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_64 += $(CONFIG)/obj/ejsLib.o
DEPS_64 += $(CONFIG)/bin/libejs.a
DEPS_64 += $(CONFIG)/obj/ejs.o

LIBS_64 += -lejs
LIBS_64 += -lhttp
LIBS_64 += -lmpr
ifeq ($(BIT_PACK_PCRE),1)
    LIBS_64 += -lpcre
endif
ifeq ($(BIT_PACK_SQLITE),1)
    LIBS_64 += -lsqlite3
endif

$(CONFIG)/bin/ejs: $(DEPS_64)
	@echo '      [Link] $(CONFIG)/bin/ejs'
	$(CC) -o $(CONFIG)/bin/ejs -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/ejs.o $(LIBPATHS_64) $(LIBS_64) $(LIBS_64) $(LIBS) -lpam -ledit 
endif

#
#   ejsc.o
#
DEPS_65 += $(CONFIG)/inc/bit.h
DEPS_65 += $(CONFIG)/inc/ejs.h

$(CONFIG)/obj/ejsc.o: \
    src/deps/ejs/ejsc.c $(DEPS_65)
	@echo '   [Compile] $(CONFIG)/obj/ejsc.o'
	$(CC) -c -o $(CONFIG)/obj/ejsc.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/deps/ejs/ejsc.c

ifeq ($(BIT_PACK_EJSCRIPT),1)
#
#   ejsc
#
DEPS_66 += $(CONFIG)/inc/mpr.h
DEPS_66 += $(CONFIG)/inc/bit.h
DEPS_66 += $(CONFIG)/inc/bitos.h
DEPS_66 += $(CONFIG)/obj/mprLib.o
DEPS_66 += $(CONFIG)/bin/libmpr.a
DEPS_66 += $(CONFIG)/inc/pcre.h
DEPS_66 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_66 += $(CONFIG)/bin/libpcre.a
endif
DEPS_66 += $(CONFIG)/inc/http.h
DEPS_66 += $(CONFIG)/obj/httpLib.o
DEPS_66 += $(CONFIG)/bin/libhttp.a
DEPS_66 += $(CONFIG)/inc/ejs.h
DEPS_66 += $(CONFIG)/inc/ejs.slots.h
DEPS_66 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_66 += $(CONFIG)/obj/ejsLib.o
DEPS_66 += $(CONFIG)/bin/libejs.a
DEPS_66 += $(CONFIG)/obj/ejsc.o

LIBS_66 += -lejs
LIBS_66 += -lhttp
LIBS_66 += -lmpr
ifeq ($(BIT_PACK_PCRE),1)
    LIBS_66 += -lpcre
endif
ifeq ($(BIT_PACK_SQLITE),1)
    LIBS_66 += -lsqlite3
endif

$(CONFIG)/bin/ejsc: $(DEPS_66)
	@echo '      [Link] $(CONFIG)/bin/ejsc'
	$(CC) -o $(CONFIG)/bin/ejsc -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/ejsc.o $(LIBPATHS_66) $(LIBS_66) $(LIBS_66) $(LIBS) -lpam 
endif

ifeq ($(BIT_PACK_EJSCRIPT),1)
#
#   ejs.mod
#
DEPS_67 += src/deps/ejs/ejs.es
DEPS_67 += $(CONFIG)/inc/mpr.h
DEPS_67 += $(CONFIG)/inc/bit.h
DEPS_67 += $(CONFIG)/inc/bitos.h
DEPS_67 += $(CONFIG)/obj/mprLib.o
DEPS_67 += $(CONFIG)/bin/libmpr.a
DEPS_67 += $(CONFIG)/inc/pcre.h
DEPS_67 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_67 += $(CONFIG)/bin/libpcre.a
endif
DEPS_67 += $(CONFIG)/inc/http.h
DEPS_67 += $(CONFIG)/obj/httpLib.o
DEPS_67 += $(CONFIG)/bin/libhttp.a
DEPS_67 += $(CONFIG)/inc/ejs.h
DEPS_67 += $(CONFIG)/inc/ejs.slots.h
DEPS_67 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_67 += $(CONFIG)/obj/ejsLib.o
DEPS_67 += $(CONFIG)/bin/libejs.a
DEPS_67 += $(CONFIG)/obj/ejsc.o
DEPS_67 += $(CONFIG)/bin/ejsc

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
	@echo '   [Compile] $(CONFIG)/obj/cgiHandler.o'
	$(CC) -c -o $(CONFIG)/obj/cgiHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/modules/cgiHandler.c

ifeq ($(BIT_PACK_CGI),1)
#
#   libmod_cgi
#
DEPS_69 += $(CONFIG)/inc/mpr.h
DEPS_69 += $(CONFIG)/inc/bit.h
DEPS_69 += $(CONFIG)/inc/bitos.h
DEPS_69 += $(CONFIG)/obj/mprLib.o
DEPS_69 += $(CONFIG)/bin/libmpr.a
DEPS_69 += $(CONFIG)/inc/pcre.h
DEPS_69 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_69 += $(CONFIG)/bin/libpcre.a
endif
DEPS_69 += $(CONFIG)/inc/http.h
DEPS_69 += $(CONFIG)/obj/httpLib.o
DEPS_69 += $(CONFIG)/bin/libhttp.a
DEPS_69 += $(CONFIG)/inc/appweb.h
DEPS_69 += $(CONFIG)/inc/customize.h
DEPS_69 += $(CONFIG)/obj/config.o
DEPS_69 += $(CONFIG)/obj/convenience.o
DEPS_69 += $(CONFIG)/obj/dirHandler.o
DEPS_69 += $(CONFIG)/obj/fileHandler.o
DEPS_69 += $(CONFIG)/obj/log.o
DEPS_69 += $(CONFIG)/obj/server.o
DEPS_69 += $(CONFIG)/bin/libappweb.a
DEPS_69 += $(CONFIG)/obj/cgiHandler.o

$(CONFIG)/bin/libmod_cgi.a: $(DEPS_69)
	@echo '      [Link] $(CONFIG)/bin/libmod_cgi.a'
	ar -cr $(CONFIG)/bin/libmod_cgi.a $(CONFIG)/obj/cgiHandler.o
endif

#
#   ejsHandler.o
#
DEPS_70 += $(CONFIG)/inc/bit.h
DEPS_70 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/ejsHandler.o: \
    src/modules/ejsHandler.c $(DEPS_70)
	@echo '   [Compile] $(CONFIG)/obj/ejsHandler.o'
	$(CC) -c -o $(CONFIG)/obj/ejsHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/modules/ejsHandler.c

ifeq ($(BIT_PACK_EJSCRIPT),1)
#
#   libmod_ejs
#
DEPS_71 += $(CONFIG)/inc/mpr.h
DEPS_71 += $(CONFIG)/inc/bit.h
DEPS_71 += $(CONFIG)/inc/bitos.h
DEPS_71 += $(CONFIG)/obj/mprLib.o
DEPS_71 += $(CONFIG)/bin/libmpr.a
DEPS_71 += $(CONFIG)/inc/pcre.h
DEPS_71 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_71 += $(CONFIG)/bin/libpcre.a
endif
DEPS_71 += $(CONFIG)/inc/http.h
DEPS_71 += $(CONFIG)/obj/httpLib.o
DEPS_71 += $(CONFIG)/bin/libhttp.a
DEPS_71 += $(CONFIG)/inc/appweb.h
DEPS_71 += $(CONFIG)/inc/customize.h
DEPS_71 += $(CONFIG)/obj/config.o
DEPS_71 += $(CONFIG)/obj/convenience.o
DEPS_71 += $(CONFIG)/obj/dirHandler.o
DEPS_71 += $(CONFIG)/obj/fileHandler.o
DEPS_71 += $(CONFIG)/obj/log.o
DEPS_71 += $(CONFIG)/obj/server.o
DEPS_71 += $(CONFIG)/bin/libappweb.a
DEPS_71 += $(CONFIG)/inc/ejs.h
DEPS_71 += $(CONFIG)/inc/ejs.slots.h
DEPS_71 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_71 += $(CONFIG)/obj/ejsLib.o
DEPS_71 += $(CONFIG)/bin/libejs.a
DEPS_71 += $(CONFIG)/obj/ejsHandler.o

$(CONFIG)/bin/libmod_ejs.a: $(DEPS_71)
	@echo '      [Link] $(CONFIG)/bin/libmod_ejs.a'
	ar -cr $(CONFIG)/bin/libmod_ejs.a $(CONFIG)/obj/ejsHandler.o
endif

#
#   phpHandler.o
#
DEPS_72 += $(CONFIG)/inc/bit.h
DEPS_72 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/phpHandler.o: \
    src/modules/phpHandler.c $(DEPS_72)
	@echo '   [Compile] $(CONFIG)/obj/phpHandler.o'
	$(CC) -c -o $(CONFIG)/obj/phpHandler.o $(DFLAGS) $(IFLAGS) -I$(BIT_PACK_PHP_PATH) -I$(BIT_PACK_PHP_PATH)/main -I$(BIT_PACK_PHP_PATH)/Zend -I$(BIT_PACK_PHP_PATH)/TSRM src/modules/phpHandler.c

ifeq ($(BIT_PACK_PHP),1)
#
#   libmod_php
#
DEPS_73 += $(CONFIG)/inc/mpr.h
DEPS_73 += $(CONFIG)/inc/bit.h
DEPS_73 += $(CONFIG)/inc/bitos.h
DEPS_73 += $(CONFIG)/obj/mprLib.o
DEPS_73 += $(CONFIG)/bin/libmpr.a
DEPS_73 += $(CONFIG)/inc/pcre.h
DEPS_73 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_73 += $(CONFIG)/bin/libpcre.a
endif
DEPS_73 += $(CONFIG)/inc/http.h
DEPS_73 += $(CONFIG)/obj/httpLib.o
DEPS_73 += $(CONFIG)/bin/libhttp.a
DEPS_73 += $(CONFIG)/inc/appweb.h
DEPS_73 += $(CONFIG)/inc/customize.h
DEPS_73 += $(CONFIG)/obj/config.o
DEPS_73 += $(CONFIG)/obj/convenience.o
DEPS_73 += $(CONFIG)/obj/dirHandler.o
DEPS_73 += $(CONFIG)/obj/fileHandler.o
DEPS_73 += $(CONFIG)/obj/log.o
DEPS_73 += $(CONFIG)/obj/server.o
DEPS_73 += $(CONFIG)/bin/libappweb.a
DEPS_73 += $(CONFIG)/obj/phpHandler.o

$(CONFIG)/bin/libmod_php.a: $(DEPS_73)
	@echo '      [Link] $(CONFIG)/bin/libmod_php.a'
	ar -cr $(CONFIG)/bin/libmod_php.a $(CONFIG)/obj/phpHandler.o
endif

#
#   sslModule.o
#
DEPS_74 += $(CONFIG)/inc/bit.h
DEPS_74 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/sslModule.o: \
    src/modules/sslModule.c $(DEPS_74)
	@echo '   [Compile] $(CONFIG)/obj/sslModule.o'
	$(CC) -c -o $(CONFIG)/obj/sslModule.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/modules/sslModule.c

ifeq ($(BIT_PACK_SSL),1)
#
#   libmod_ssl
#
DEPS_75 += $(CONFIG)/inc/mpr.h
DEPS_75 += $(CONFIG)/inc/bit.h
DEPS_75 += $(CONFIG)/inc/bitos.h
DEPS_75 += $(CONFIG)/obj/mprLib.o
DEPS_75 += $(CONFIG)/bin/libmpr.a
DEPS_75 += $(CONFIG)/inc/pcre.h
DEPS_75 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_75 += $(CONFIG)/bin/libpcre.a
endif
DEPS_75 += $(CONFIG)/inc/http.h
DEPS_75 += $(CONFIG)/obj/httpLib.o
DEPS_75 += $(CONFIG)/bin/libhttp.a
DEPS_75 += $(CONFIG)/inc/appweb.h
DEPS_75 += $(CONFIG)/inc/customize.h
DEPS_75 += $(CONFIG)/obj/config.o
DEPS_75 += $(CONFIG)/obj/convenience.o
DEPS_75 += $(CONFIG)/obj/dirHandler.o
DEPS_75 += $(CONFIG)/obj/fileHandler.o
DEPS_75 += $(CONFIG)/obj/log.o
DEPS_75 += $(CONFIG)/obj/server.o
DEPS_75 += $(CONFIG)/bin/libappweb.a
DEPS_75 += $(CONFIG)/obj/sslModule.o

$(CONFIG)/bin/libmod_ssl.a: $(DEPS_75)
	@echo '      [Link] $(CONFIG)/bin/libmod_ssl.a'
	ar -cr $(CONFIG)/bin/libmod_ssl.a $(CONFIG)/obj/sslModule.o
endif

#
#   authpass.o
#
DEPS_76 += $(CONFIG)/inc/bit.h
DEPS_76 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/authpass.o: \
    src/utils/authpass.c $(DEPS_76)
	@echo '   [Compile] $(CONFIG)/obj/authpass.o'
	$(CC) -c -o $(CONFIG)/obj/authpass.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/utils/authpass.c

#
#   authpass
#
DEPS_77 += $(CONFIG)/inc/mpr.h
DEPS_77 += $(CONFIG)/inc/bit.h
DEPS_77 += $(CONFIG)/inc/bitos.h
DEPS_77 += $(CONFIG)/obj/mprLib.o
DEPS_77 += $(CONFIG)/bin/libmpr.a
DEPS_77 += $(CONFIG)/inc/pcre.h
DEPS_77 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_77 += $(CONFIG)/bin/libpcre.a
endif
DEPS_77 += $(CONFIG)/inc/http.h
DEPS_77 += $(CONFIG)/obj/httpLib.o
DEPS_77 += $(CONFIG)/bin/libhttp.a
DEPS_77 += $(CONFIG)/inc/appweb.h
DEPS_77 += $(CONFIG)/inc/customize.h
DEPS_77 += $(CONFIG)/obj/config.o
DEPS_77 += $(CONFIG)/obj/convenience.o
DEPS_77 += $(CONFIG)/obj/dirHandler.o
DEPS_77 += $(CONFIG)/obj/fileHandler.o
DEPS_77 += $(CONFIG)/obj/log.o
DEPS_77 += $(CONFIG)/obj/server.o
DEPS_77 += $(CONFIG)/bin/libappweb.a
DEPS_77 += $(CONFIG)/obj/authpass.o

LIBS_77 += -lappweb
LIBS_77 += -lhttp
LIBS_77 += -lmpr
ifeq ($(BIT_PACK_PCRE),1)
    LIBS_77 += -lpcre
endif

$(CONFIG)/bin/authpass: $(DEPS_77)
	@echo '      [Link] $(CONFIG)/bin/authpass'
	$(CC) -o $(CONFIG)/bin/authpass -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/authpass.o $(LIBPATHS_77) $(LIBS_77) $(LIBS_77) $(LIBS) -lpam 

#
#   cgiProgram.o
#
DEPS_78 += $(CONFIG)/inc/bit.h

$(CONFIG)/obj/cgiProgram.o: \
    src/utils/cgiProgram.c $(DEPS_78)
	@echo '   [Compile] $(CONFIG)/obj/cgiProgram.o'
	$(CC) -c -o $(CONFIG)/obj/cgiProgram.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/utils/cgiProgram.c

ifeq ($(BIT_PACK_CGI),1)
#
#   cgiProgram
#
DEPS_79 += $(CONFIG)/inc/bit.h
DEPS_79 += $(CONFIG)/obj/cgiProgram.o

$(CONFIG)/bin/cgiProgram: $(DEPS_79)
	@echo '      [Link] $(CONFIG)/bin/cgiProgram'
	$(CC) -o $(CONFIG)/bin/cgiProgram -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/cgiProgram.o $(LIBS) 
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
	@echo '   [Compile] $(CONFIG)/obj/slink.o'
	$(CC) -c -o $(CONFIG)/obj/slink.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/server/slink.c

#
#   libslink
#
DEPS_82 += src/server/slink.c
DEPS_82 += $(CONFIG)/inc/mpr.h
DEPS_82 += $(CONFIG)/inc/bit.h
DEPS_82 += $(CONFIG)/inc/bitos.h
DEPS_82 += $(CONFIG)/obj/mprLib.o
DEPS_82 += $(CONFIG)/bin/libmpr.a
DEPS_82 += $(CONFIG)/inc/pcre.h
DEPS_82 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_82 += $(CONFIG)/bin/libpcre.a
endif
DEPS_82 += $(CONFIG)/inc/http.h
DEPS_82 += $(CONFIG)/obj/httpLib.o
DEPS_82 += $(CONFIG)/bin/libhttp.a
DEPS_82 += $(CONFIG)/inc/appweb.h
DEPS_82 += $(CONFIG)/inc/customize.h
DEPS_82 += $(CONFIG)/obj/config.o
DEPS_82 += $(CONFIG)/obj/convenience.o
DEPS_82 += $(CONFIG)/obj/dirHandler.o
DEPS_82 += $(CONFIG)/obj/fileHandler.o
DEPS_82 += $(CONFIG)/obj/log.o
DEPS_82 += $(CONFIG)/obj/server.o
DEPS_82 += $(CONFIG)/bin/libappweb.a
DEPS_82 += $(CONFIG)/inc/edi.h
DEPS_82 += $(CONFIG)/inc/esp-app.h
DEPS_82 += $(CONFIG)/inc/esp.h
DEPS_82 += $(CONFIG)/inc/mdb.h
DEPS_82 += $(CONFIG)/obj/edi.o
DEPS_82 += $(CONFIG)/obj/espAbbrev.o
DEPS_82 += $(CONFIG)/obj/espFramework.o
DEPS_82 += $(CONFIG)/obj/espHandler.o
DEPS_82 += $(CONFIG)/obj/espHtml.o
DEPS_82 += $(CONFIG)/obj/espTemplate.o
DEPS_82 += $(CONFIG)/obj/mdb.o
DEPS_82 += $(CONFIG)/obj/sdb.o
ifeq ($(BIT_PACK_ESP),1)
    DEPS_82 += $(CONFIG)/bin/libmod_esp.a
endif
DEPS_82 += $(CONFIG)/obj/slink.o

$(CONFIG)/bin/libslink.a: $(DEPS_82)
	@echo '      [Link] $(CONFIG)/bin/libslink.a'
	ar -cr $(CONFIG)/bin/libslink.a $(CONFIG)/obj/slink.o

#
#   appweb.o
#
DEPS_83 += $(CONFIG)/inc/bit.h
DEPS_83 += $(CONFIG)/inc/appweb.h
DEPS_83 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/appweb.o: \
    src/server/appweb.c $(DEPS_83)
	@echo '   [Compile] $(CONFIG)/obj/appweb.o'
	$(CC) -c -o $(CONFIG)/obj/appweb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) -I$(BIT_PACK_PHP_PATH) -I$(BIT_PACK_PHP_PATH)/main -I$(BIT_PACK_PHP_PATH)/Zend -I$(BIT_PACK_PHP_PATH)/TSRM src/server/appweb.c

#
#   appweb
#
DEPS_84 += $(CONFIG)/inc/mpr.h
DEPS_84 += $(CONFIG)/inc/bit.h
DEPS_84 += $(CONFIG)/inc/bitos.h
DEPS_84 += $(CONFIG)/obj/mprLib.o
DEPS_84 += $(CONFIG)/bin/libmpr.a
DEPS_84 += $(CONFIG)/inc/pcre.h
DEPS_84 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_84 += $(CONFIG)/bin/libpcre.a
endif
DEPS_84 += $(CONFIG)/inc/http.h
DEPS_84 += $(CONFIG)/obj/httpLib.o
DEPS_84 += $(CONFIG)/bin/libhttp.a
DEPS_84 += $(CONFIG)/inc/appweb.h
DEPS_84 += $(CONFIG)/inc/customize.h
DEPS_84 += $(CONFIG)/obj/config.o
DEPS_84 += $(CONFIG)/obj/convenience.o
DEPS_84 += $(CONFIG)/obj/dirHandler.o
DEPS_84 += $(CONFIG)/obj/fileHandler.o
DEPS_84 += $(CONFIG)/obj/log.o
DEPS_84 += $(CONFIG)/obj/server.o
DEPS_84 += $(CONFIG)/bin/libappweb.a
DEPS_84 += src/server/slink.c
DEPS_84 += $(CONFIG)/inc/edi.h
DEPS_84 += $(CONFIG)/inc/esp-app.h
DEPS_84 += $(CONFIG)/inc/esp.h
DEPS_84 += $(CONFIG)/inc/mdb.h
DEPS_84 += $(CONFIG)/obj/edi.o
DEPS_84 += $(CONFIG)/obj/espAbbrev.o
DEPS_84 += $(CONFIG)/obj/espFramework.o
DEPS_84 += $(CONFIG)/obj/espHandler.o
DEPS_84 += $(CONFIG)/obj/espHtml.o
DEPS_84 += $(CONFIG)/obj/espTemplate.o
DEPS_84 += $(CONFIG)/obj/mdb.o
DEPS_84 += $(CONFIG)/obj/sdb.o
ifeq ($(BIT_PACK_ESP),1)
    DEPS_84 += $(CONFIG)/bin/libmod_esp.a
endif
DEPS_84 += $(CONFIG)/obj/slink.o
DEPS_84 += $(CONFIG)/bin/libslink.a
DEPS_84 += $(CONFIG)/obj/sslModule.o
ifeq ($(BIT_PACK_SSL),1)
    DEPS_84 += $(CONFIG)/bin/libmod_ssl.a
endif
DEPS_84 += $(CONFIG)/inc/ejs.h
DEPS_84 += $(CONFIG)/inc/ejs.slots.h
DEPS_84 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_84 += $(CONFIG)/obj/ejsLib.o
ifeq ($(BIT_PACK_EJSCRIPT),1)
    DEPS_84 += $(CONFIG)/bin/libejs.a
endif
DEPS_84 += $(CONFIG)/obj/ejsHandler.o
ifeq ($(BIT_PACK_EJSCRIPT),1)
    DEPS_84 += $(CONFIG)/bin/libmod_ejs.a
endif
DEPS_84 += $(CONFIG)/obj/phpHandler.o
ifeq ($(BIT_PACK_PHP),1)
    DEPS_84 += $(CONFIG)/bin/libmod_php.a
endif
DEPS_84 += $(CONFIG)/obj/cgiHandler.o
ifeq ($(BIT_PACK_CGI),1)
    DEPS_84 += $(CONFIG)/bin/libmod_cgi.a
endif
DEPS_84 += $(CONFIG)/obj/appweb.o

LIBS_84 += -lappweb
LIBS_84 += -lhttp
LIBS_84 += -lmpr
ifeq ($(BIT_PACK_PCRE),1)
    LIBS_84 += -lpcre
endif
LIBS_84 += -lslink
ifeq ($(BIT_PACK_ESP),1)
    LIBS_84 += -lmod_esp
endif
ifeq ($(BIT_PACK_SQLITE),1)
    LIBS_84 += -lsqlite3
endif
ifeq ($(BIT_PACK_SSL),1)
    LIBS_84 += -lmod_ssl
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
    LIBS_84 += -lmod_ejs
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
    LIBS_84 += -lejs
endif
ifeq ($(BIT_PACK_PHP),1)
    LIBS_84 += -lmod_php
endif
ifeq ($(BIT_PACK_PHP),1)
    LIBS_84 += -lphp5
    LIBPATHS_84 += -L$(BIT_PACK_PHP_PATH)/libs
endif
ifeq ($(BIT_PACK_CGI),1)
    LIBS_84 += -lmod_cgi
endif

$(CONFIG)/bin/appweb: $(DEPS_84)
	@echo '      [Link] $(CONFIG)/bin/appweb'
	$(CC) -o $(CONFIG)/bin/appweb -arch x86_64 $(LDFLAGS) $(LIBPATHS)  $(CONFIG)/obj/appweb.o $(LIBPATHS_84) $(LIBS_84) $(LIBS_84) $(LIBS) -lpam 

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
	@echo '   [Compile] $(CONFIG)/obj/testAppweb.o'
	$(CC) -c -o $(CONFIG)/obj/testAppweb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) test/testAppweb.c

#
#   testHttp.o
#
DEPS_88 += $(CONFIG)/inc/bit.h
DEPS_88 += $(CONFIG)/inc/testAppweb.h

$(CONFIG)/obj/testHttp.o: \
    test/testHttp.c $(DEPS_88)
	@echo '   [Compile] $(CONFIG)/obj/testHttp.o'
	$(CC) -c -o $(CONFIG)/obj/testHttp.o $(CFLAGS) $(DFLAGS) $(IFLAGS) test/testHttp.c

#
#   testAppweb
#
DEPS_89 += $(CONFIG)/inc/mpr.h
DEPS_89 += $(CONFIG)/inc/bit.h
DEPS_89 += $(CONFIG)/inc/bitos.h
DEPS_89 += $(CONFIG)/obj/mprLib.o
DEPS_89 += $(CONFIG)/bin/libmpr.a
DEPS_89 += $(CONFIG)/inc/pcre.h
DEPS_89 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_89 += $(CONFIG)/bin/libpcre.a
endif
DEPS_89 += $(CONFIG)/inc/http.h
DEPS_89 += $(CONFIG)/obj/httpLib.o
DEPS_89 += $(CONFIG)/bin/libhttp.a
DEPS_89 += $(CONFIG)/inc/appweb.h
DEPS_89 += $(CONFIG)/inc/customize.h
DEPS_89 += $(CONFIG)/obj/config.o
DEPS_89 += $(CONFIG)/obj/convenience.o
DEPS_89 += $(CONFIG)/obj/dirHandler.o
DEPS_89 += $(CONFIG)/obj/fileHandler.o
DEPS_89 += $(CONFIG)/obj/log.o
DEPS_89 += $(CONFIG)/obj/server.o
DEPS_89 += $(CONFIG)/bin/libappweb.a
DEPS_89 += $(CONFIG)/inc/testAppweb.h
DEPS_89 += $(CONFIG)/obj/testAppweb.o
DEPS_89 += $(CONFIG)/obj/testHttp.o

LIBS_89 += -lappweb
LIBS_89 += -lhttp
LIBS_89 += -lmpr
ifeq ($(BIT_PACK_PCRE),1)
    LIBS_89 += -lpcre
endif

$(CONFIG)/bin/testAppweb: $(DEPS_89)
	@echo '      [Link] $(CONFIG)/bin/testAppweb'
	$(CC) -o $(CONFIG)/bin/testAppweb -arch x86_64 $(LDFLAGS) $(LIBPATHS) $(CONFIG)/obj/testAppweb.o $(CONFIG)/obj/testHttp.o $(LIBPATHS_89) $(LIBS_89) $(LIBS_89) $(LIBS) -lpam 

ifeq ($(BIT_PACK_CGI),1)
#
#   test-testScript
#
DEPS_90 += $(CONFIG)/inc/bit.h
DEPS_90 += $(CONFIG)/obj/cgiProgram.o
DEPS_90 += $(CONFIG)/bin/cgiProgram

test/cgi-bin/testScript: $(DEPS_90)
	cd test; echo '#!../$(CONFIG)/bin/cgiProgram' >cgi-bin/testScript ; chmod +x cgi-bin/testScript ; cd ..
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
DEPS_93 += $(CONFIG)/inc/bit.h
DEPS_93 += $(CONFIG)/obj/cgiProgram.o
DEPS_93 += $(CONFIG)/bin/cgiProgram

test/cgi-bin/cgiProgram: $(DEPS_93)
	cd test; cp ../$(CONFIG)/bin/cgiProgram cgi-bin/cgiProgram ; cd ..
	cd test; cp ../$(CONFIG)/bin/cgiProgram cgi-bin/nph-cgiProgram ; cd ..
	cd test; cp ../$(CONFIG)/bin/cgiProgram 'cgi-bin/cgi Program' ; cd ..
	cd test; cp ../$(CONFIG)/bin/cgiProgram web/cgiProgram.cgi ; cd ..
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
#   stop
#
DEPS_95 += compile

stop: $(DEPS_95)
	@./$(CONFIG)/bin/appman stop disable uninstall >/dev/null 2>&1 ; true

#
#   installBinary
#
installBinary: $(DEPS_96)
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
	ln -s "4.3.2" "$(BIT_APP_PREFIX)/latest"
	mkdir -p "$(BIT_LOG_PREFIX)"
	chmod 755 "$(BIT_LOG_PREFIX)"
	[ `id -u` = 0 ] && chown $(WEB_USER):$(WEB_GROUP) "$(BIT_LOG_PREFIX)"; true
	mkdir -p "$(BIT_CACHE_PREFIX)"
	chmod 755 "$(BIT_CACHE_PREFIX)"
	[ `id -u` = 0 ] && chown $(WEB_USER):$(WEB_GROUP) "$(BIT_CACHE_PREFIX)"; true
	mkdir -p "$(BIT_VAPP_PREFIX)/bin"
	cp $(CONFIG)/bin/appweb $(BIT_VAPP_PREFIX)/bin/appweb
	mkdir -p "$(BIT_BIN_PREFIX)"
	rm -f "$(BIT_BIN_PREFIX)/appweb"
	ln -s "$(BIT_VAPP_PREFIX)/bin/appweb" "$(BIT_BIN_PREFIX)/appweb"
	cp $(CONFIG)/bin/appman $(BIT_VAPP_PREFIX)/bin/appman
	rm -f "$(BIT_BIN_PREFIX)/appman"
	ln -s "$(BIT_VAPP_PREFIX)/bin/appman" "$(BIT_BIN_PREFIX)/appman"
	cp $(CONFIG)/bin/http $(BIT_VAPP_PREFIX)/bin/http
	rm -f "$(BIT_BIN_PREFIX)/http"
	ln -s "$(BIT_VAPP_PREFIX)/bin/http" "$(BIT_BIN_PREFIX)/http"
ifeq ($(BIT_PACK_ESP),1)
	cp $(CONFIG)/bin/esp $(BIT_VAPP_PREFIX)/bin/esp
	rm -f "$(BIT_BIN_PREFIX)/esp"
	ln -s "$(BIT_VAPP_PREFIX)/bin/esp" "$(BIT_BIN_PREFIX)/esp"
endif
ifeq ($(BIT_PACK_SSL),1)
	cp $(CONFIG)/bin/ca.crt $(BIT_VAPP_PREFIX)/bin/ca.crt
endif
ifeq ($(BIT_PACK_OPENSSL),1)
	cp $(CONFIG)/bin/libssl*.dylib* $(BIT_VAPP_PREFIX)/bin/libssl*.dylib*
	cp $(CONFIG)/bin/libcrypto*.dylib* $(BIT_VAPP_PREFIX)/bin/libcrypto*.dylib*
endif
ifeq ($(BIT_PACK_PHP),1)
	cp $(CONFIG)/bin/libphp5.dylib $(BIT_VAPP_PREFIX)/bin/libphp5.dylib
endif
ifeq ($(BIT_PACK_ESP),1)
	mkdir -p "$(BIT_VAPP_PREFIX)/bin/esp-www"
	cp src/esp/esp-www/app.conf $(BIT_VAPP_PREFIX)/bin/esp-www/app.conf
	cp src/esp/esp-www/appweb.conf $(BIT_VAPP_PREFIX)/bin/esp-www/appweb.conf
	mkdir -p "$(BIT_VAPP_PREFIX)/bin/esp-www/files/layouts"
	cp src/esp/esp-www/files/layouts/default.esp $(BIT_VAPP_PREFIX)/bin/esp-www/files/layouts/default.esp
	mkdir -p "$(BIT_VAPP_PREFIX)/bin/esp-www/files/static/images"
	cp src/esp/esp-www/files/static/images/banner.jpg $(BIT_VAPP_PREFIX)/bin/esp-www/files/static/images/banner.jpg
	cp src/esp/esp-www/files/static/images/favicon.ico $(BIT_VAPP_PREFIX)/bin/esp-www/files/static/images/favicon.ico
	cp src/esp/esp-www/files/static/images/splash.jpg $(BIT_VAPP_PREFIX)/bin/esp-www/files/static/images/splash.jpg
	mkdir -p "$(BIT_VAPP_PREFIX)/bin/esp-www/files/static"
	cp src/esp/esp-www/files/static/index.esp $(BIT_VAPP_PREFIX)/bin/esp-www/files/static/index.esp
	mkdir -p "$(BIT_VAPP_PREFIX)/bin/esp-www/files/static/js"
	cp src/esp/esp-www/files/static/js/jquery-1.9.1.js $(BIT_VAPP_PREFIX)/bin/esp-www/files/static/js/jquery-1.9.1.js
	cp src/esp/esp-www/files/static/js/jquery-1.9.1.min.js $(BIT_VAPP_PREFIX)/bin/esp-www/files/static/js/jquery-1.9.1.min.js
	cp src/esp/esp-www/files/static/js/jquery.esp.js $(BIT_VAPP_PREFIX)/bin/esp-www/files/static/js/jquery.esp.js
	cp src/esp/esp-www/files/static/js/jquery.js $(BIT_VAPP_PREFIX)/bin/esp-www/files/static/js/jquery.js
	cp src/esp/esp-www/files/static/js/jquery.simplemodal.js $(BIT_VAPP_PREFIX)/bin/esp-www/files/static/js/jquery.simplemodal.js
	cp src/esp/esp-www/files/static/js/jquery.tablesorter.js $(BIT_VAPP_PREFIX)/bin/esp-www/files/static/js/jquery.tablesorter.js
	cp src/esp/esp-www/files/static/layout.css $(BIT_VAPP_PREFIX)/bin/esp-www/files/static/layout.css
	mkdir -p "$(BIT_VAPP_PREFIX)/bin/esp-www/files/static/themes"
	cp src/esp/esp-www/files/static/themes/default.css $(BIT_VAPP_PREFIX)/bin/esp-www/files/static/themes/default.css
	cp src/esp/esp-appweb.conf $(BIT_VAPP_PREFIX)/bin/esp-appweb.conf
endif
ifeq ($(BIT_PACK_ESP),1)
	cp $(CONFIG)/bin/esp.conf $(BIT_VAPP_PREFIX)/bin/esp.conf
endif
	mkdir -p "$(BIT_WEB_PREFIX)/bench"
	cp src/server/web/bench/1b.html $(BIT_WEB_PREFIX)/bench/1b.html
	cp src/server/web/bench/4k.html $(BIT_WEB_PREFIX)/bench/4k.html
	cp src/server/web/bench/64k.html $(BIT_WEB_PREFIX)/bench/64k.html
	mkdir -p "$(BIT_WEB_PREFIX)"
	cp src/server/web/favicon.ico $(BIT_WEB_PREFIX)/favicon.ico
	mkdir -p "$(BIT_WEB_PREFIX)/icons"
	cp src/server/web/icons/back.gif $(BIT_WEB_PREFIX)/icons/back.gif
	cp src/server/web/icons/blank.gif $(BIT_WEB_PREFIX)/icons/blank.gif
	cp src/server/web/icons/compressed.gif $(BIT_WEB_PREFIX)/icons/compressed.gif
	cp src/server/web/icons/folder.gif $(BIT_WEB_PREFIX)/icons/folder.gif
	cp src/server/web/icons/parent.gif $(BIT_WEB_PREFIX)/icons/parent.gif
	cp src/server/web/icons/space.gif $(BIT_WEB_PREFIX)/icons/space.gif
	cp src/server/web/icons/text.gif $(BIT_WEB_PREFIX)/icons/text.gif
	cp src/server/web/iehacks.css $(BIT_WEB_PREFIX)/iehacks.css
	mkdir -p "$(BIT_WEB_PREFIX)/images"
	cp src/server/web/images/banner.jpg $(BIT_WEB_PREFIX)/images/banner.jpg
	cp src/server/web/images/bottomShadow.jpg $(BIT_WEB_PREFIX)/images/bottomShadow.jpg
	cp src/server/web/images/shadow.jpg $(BIT_WEB_PREFIX)/images/shadow.jpg
	cp src/server/web/index.html $(BIT_WEB_PREFIX)/index.html
	cp src/server/web/min-index.html $(BIT_WEB_PREFIX)/min-index.html
	cp src/server/web/print.css $(BIT_WEB_PREFIX)/print.css
	cp src/server/web/screen.css $(BIT_WEB_PREFIX)/screen.css
	mkdir -p "$(BIT_WEB_PREFIX)/test"
	cp src/server/web/test/bench.html $(BIT_WEB_PREFIX)/test/bench.html
	cp src/server/web/test/test.cgi $(BIT_WEB_PREFIX)/test/test.cgi
	cp src/server/web/test/test.ejs $(BIT_WEB_PREFIX)/test/test.ejs
	cp src/server/web/test/test.esp $(BIT_WEB_PREFIX)/test/test.esp
	cp src/server/web/test/test.html $(BIT_WEB_PREFIX)/test/test.html
	cp src/server/web/test/test.php $(BIT_WEB_PREFIX)/test/test.php
	cp src/server/web/test/test.pl $(BIT_WEB_PREFIX)/test/test.pl
	cp src/server/web/test/test.py $(BIT_WEB_PREFIX)/test/test.py
	mkdir -p "$(BIT_WEB_PREFIX)/test"
	cp src/server/web/test/test.cgi $(BIT_WEB_PREFIX)/test/test.cgi
	chmod 755 "$(BIT_WEB_PREFIX)/test/test.cgi"
	cp src/server/web/test/test.pl $(BIT_WEB_PREFIX)/test/test.pl
	chmod 755 "$(BIT_WEB_PREFIX)/test/test.pl"
	cp src/server/web/test/test.py $(BIT_WEB_PREFIX)/test/test.py
	chmod 755 "$(BIT_WEB_PREFIX)/test/test.py"
	mkdir -p "$(BIT_ETC_PREFIX)"
	cp src/server/mime.types $(BIT_ETC_PREFIX)/mime.types
ifeq ($(BIT_PACK_PHP),1)
	cp src/server/php.ini $(BIT_ETC_PREFIX)/php.ini
endif
	cp src/server/appweb.conf $(BIT_ETC_PREFIX)/appweb.conf
	cp src/server/self.crt $(BIT_ETC_PREFIX)/self.crt
	cp src/server/self.key $(BIT_ETC_PREFIX)/self.key
	mkdir -p "$(BIT_VAPP_PREFIX)/inc"
	cp $(CONFIG)/inc/bit.h $(BIT_VAPP_PREFIX)/inc/bit.h
	mkdir -p "$(BIT_INC_PREFIX)/appweb"
	rm -f "$(BIT_INC_PREFIX)/appweb/bit.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/bit.h" "$(BIT_INC_PREFIX)/appweb/bit.h"
	cp src/bitos.h $(BIT_VAPP_PREFIX)/inc/bitos.h
	rm -f "$(BIT_INC_PREFIX)/appweb/bitos.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/bitos.h" "$(BIT_INC_PREFIX)/appweb/bitos.h"
	cp src/appweb.h $(BIT_VAPP_PREFIX)/inc/appweb.h
	rm -f "$(BIT_INC_PREFIX)/appweb/appweb.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/appweb.h" "$(BIT_INC_PREFIX)/appweb/appweb.h"
	cp src/customize.h $(BIT_VAPP_PREFIX)/inc/customize.h
	rm -f "$(BIT_INC_PREFIX)/appweb/customize.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/customize.h" "$(BIT_INC_PREFIX)/appweb/customize.h"
	cp src/deps/est/est.h $(BIT_VAPP_PREFIX)/inc/est.h
	rm -f "$(BIT_INC_PREFIX)/appweb/est.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/est.h" "$(BIT_INC_PREFIX)/appweb/est.h"
	cp src/deps/http/http.h $(BIT_VAPP_PREFIX)/inc/http.h
	rm -f "$(BIT_INC_PREFIX)/appweb/http.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/http.h" "$(BIT_INC_PREFIX)/appweb/http.h"
	cp src/deps/mpr/mpr.h $(BIT_VAPP_PREFIX)/inc/mpr.h
	rm -f "$(BIT_INC_PREFIX)/appweb/mpr.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/mpr.h" "$(BIT_INC_PREFIX)/appweb/mpr.h"
	cp src/deps/pcre/pcre.h $(BIT_VAPP_PREFIX)/inc/pcre.h
	rm -f "$(BIT_INC_PREFIX)/appweb/pcre.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/pcre.h" "$(BIT_INC_PREFIX)/appweb/pcre.h"
	cp src/deps/sqlite/sqlite3.h $(BIT_VAPP_PREFIX)/inc/sqlite3.h
	rm -f "$(BIT_INC_PREFIX)/appweb/sqlite3.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/sqlite3.h" "$(BIT_INC_PREFIX)/appweb/sqlite3.h"
ifeq ($(BIT_PACK_ESP),1)
	cp src/esp/edi.h $(BIT_VAPP_PREFIX)/inc/edi.h
	rm -f "$(BIT_INC_PREFIX)/appweb/edi.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/edi.h" "$(BIT_INC_PREFIX)/appweb/edi.h"
	cp src/esp/esp-app.h $(BIT_VAPP_PREFIX)/inc/esp-app.h
	rm -f "$(BIT_INC_PREFIX)/appweb/esp-app.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/esp-app.h" "$(BIT_INC_PREFIX)/appweb/esp-app.h"
	cp src/esp/esp.h $(BIT_VAPP_PREFIX)/inc/esp.h
	rm -f "$(BIT_INC_PREFIX)/appweb/esp.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/esp.h" "$(BIT_INC_PREFIX)/appweb/esp.h"
	cp src/esp/mdb.h $(BIT_VAPP_PREFIX)/inc/mdb.h
	rm -f "$(BIT_INC_PREFIX)/appweb/mdb.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/mdb.h" "$(BIT_INC_PREFIX)/appweb/mdb.h"
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
	cp src/deps/ejs/ejs.h $(BIT_VAPP_PREFIX)/inc/ejs.h
	rm -f "$(BIT_INC_PREFIX)/appweb/ejs.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/ejs.h" "$(BIT_INC_PREFIX)/appweb/ejs.h"
	cp src/deps/ejs/ejs.slots.h $(BIT_VAPP_PREFIX)/inc/ejs.slots.h
	rm -f "$(BIT_INC_PREFIX)/appweb/ejs.slots.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/ejs.slots.h" "$(BIT_INC_PREFIX)/appweb/ejs.slots.h"
	cp src/deps/ejs/ejsByteGoto.h $(BIT_VAPP_PREFIX)/inc/ejsByteGoto.h
	rm -f "$(BIT_INC_PREFIX)/appweb/ejsByteGoto.h"
	ln -s "$(BIT_VAPP_PREFIX)/inc/ejsByteGoto.h" "$(BIT_INC_PREFIX)/appweb/ejsByteGoto.h"
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
	cp $(CONFIG)/bin/ejs.mod $(BIT_VAPP_PREFIX)/bin/ejs.mod
endif
	mkdir -p "$(BIT_VAPP_PREFIX)/doc/man1"
	cp doc/man/appman.1 $(BIT_VAPP_PREFIX)/doc/man1/appman.1
	mkdir -p "$(BIT_MAN_PREFIX)/man1"
	rm -f "$(BIT_MAN_PREFIX)/man1/appman.1"
	ln -s "$(BIT_VAPP_PREFIX)/doc/man1/appman.1" "$(BIT_MAN_PREFIX)/man1/appman.1"
	cp doc/man/appweb.1 $(BIT_VAPP_PREFIX)/doc/man1/appweb.1
	rm -f "$(BIT_MAN_PREFIX)/man1/appweb.1"
	ln -s "$(BIT_VAPP_PREFIX)/doc/man1/appweb.1" "$(BIT_MAN_PREFIX)/man1/appweb.1"
	cp doc/man/appwebMonitor.1 $(BIT_VAPP_PREFIX)/doc/man1/appwebMonitor.1
	rm -f "$(BIT_MAN_PREFIX)/man1/appwebMonitor.1"
	ln -s "$(BIT_VAPP_PREFIX)/doc/man1/appwebMonitor.1" "$(BIT_MAN_PREFIX)/man1/appwebMonitor.1"
	cp doc/man/authpass.1 $(BIT_VAPP_PREFIX)/doc/man1/authpass.1
	rm -f "$(BIT_MAN_PREFIX)/man1/authpass.1"
	ln -s "$(BIT_VAPP_PREFIX)/doc/man1/authpass.1" "$(BIT_MAN_PREFIX)/man1/authpass.1"
	cp doc/man/esp.1 $(BIT_VAPP_PREFIX)/doc/man1/esp.1
	rm -f "$(BIT_MAN_PREFIX)/man1/esp.1"
	ln -s "$(BIT_VAPP_PREFIX)/doc/man1/esp.1" "$(BIT_MAN_PREFIX)/man1/esp.1"
	cp doc/man/http.1 $(BIT_VAPP_PREFIX)/doc/man1/http.1
	rm -f "$(BIT_MAN_PREFIX)/man1/http.1"
	ln -s "$(BIT_VAPP_PREFIX)/doc/man1/http.1" "$(BIT_MAN_PREFIX)/man1/http.1"
	cp doc/man/makerom.1 $(BIT_VAPP_PREFIX)/doc/man1/makerom.1
	rm -f "$(BIT_MAN_PREFIX)/man1/makerom.1"
	ln -s "$(BIT_VAPP_PREFIX)/doc/man1/makerom.1" "$(BIT_MAN_PREFIX)/man1/makerom.1"
	cp doc/man/manager.1 $(BIT_VAPP_PREFIX)/doc/man1/manager.1
	rm -f "$(BIT_MAN_PREFIX)/man1/manager.1"
	ln -s "$(BIT_VAPP_PREFIX)/doc/man1/manager.1" "$(BIT_MAN_PREFIX)/man1/manager.1"
	mkdir -p "$(BIT_ROOT_PREFIX)/Library/LaunchDaemons"
	cp package/macosx/com.embedthis.appweb.plist $(BIT_ROOT_PREFIX)/Library/LaunchDaemons/com.embedthis.appweb.plist
	[ `id -u` = 0 ] && chown root:wheel "$(BIT_ROOT_PREFIX)/Library/LaunchDaemons/com.embedthis.appweb.plist"; true
	chmod 644 "$(BIT_ROOT_PREFIX)/Library/LaunchDaemons/com.embedthis.appweb.plist"
	echo 'set LOG_DIR "$(BIT_LOG_PREFIX)"\nset CACHE_DIR "$(BIT_CACHE_PREFIX)"\nDocuments "$(BIT_WEB_PREFIX)\nListen 80\nListenSecure 443\n' >$(BIT_ETC_PREFIX)/install.conf

#
#   start
#
DEPS_97 += compile
DEPS_97 += stop

start: $(DEPS_97)
	./$(CONFIG)/bin/appman install enable start

#
#   install
#
DEPS_98 += compile
DEPS_98 += stop
DEPS_98 += installBinary
DEPS_98 += start

install: $(DEPS_98)
	


#
#   uninstall
#
DEPS_99 += build
DEPS_99 += compile
DEPS_99 += stop

uninstall: $(DEPS_99)
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
genslink: $(DEPS_100)
	cd src/server; esp --static --genlink slink.c --flat compile ; cd ../..

#
#   run
#
DEPS_101 += compile

run: $(DEPS_101)
	cd src/server; sudo ../../$(CONFIG)/bin/appweb -v ; cd ../..

#
#   test-run
#
DEPS_102 += compile

test-run: $(DEPS_102)
	cd test; ../$(CONFIG)/bin/appweb -v ; cd ..

