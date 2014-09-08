#
#   appweb-freebsd-default.mk -- Makefile to build Embedthis Appweb for freebsd
#

NAME                  := appweb
VERSION               := 4.6.4
PROFILE               ?= default
ARCH                  ?= $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/')
CC_ARCH               ?= $(shell echo $(ARCH) | sed 's/x86/i686/;s/x64/x86_64/')
OS                    ?= freebsd
CC                    ?= gcc
CONFIG                ?= $(OS)-$(ARCH)-$(PROFILE)
BUILD                 ?= build/$(CONFIG)
LBIN                  ?= $(BUILD)/bin
PATH                  := $(LBIN):$(PATH)

ME_COM_CGI            ?= 1
ME_COM_DIR            ?= 1
ME_COM_EJS            ?= 0
ME_COM_ESP            ?= 1
ME_COM_EST            ?= 1
ME_COM_HTTP           ?= 1
ME_COM_MATRIXSSL      ?= 0
ME_COM_MDB            ?= 1
ME_COM_NANOSSL        ?= 0
ME_COM_OPENSSL        ?= 0
ME_COM_PCRE           ?= 1
ME_COM_PHP            ?= 0
ME_COM_SQLITE         ?= 0
ME_COM_SSL            ?= 1
ME_COM_VXWORKS        ?= 0
ME_COM_WINSDK         ?= 1
ME_COM_ZLIB           ?= 0

ifeq ($(ME_COM_EST),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_NANOSSL),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_OPENSSL),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_EJS),1)
    ME_COM_ZLIB := 1
endif
ifeq ($(ME_COM_ESP),1)
    ME_COM_MDB := 1
endif

ME_COM_CGI_PATH       ?= src/modules/cgiHandler.c
ME_COM_COMPILER_PATH  ?= gcc
ME_COM_DIR_PATH       ?= src/dirHandler.c
ME_COM_LIB_PATH       ?= ar
ME_COM_MATRIXSSL_PATH ?= /usr/src/matrixssl
ME_COM_NANOSSL_PATH   ?= /usr/src/nanossl
ME_COM_OPENSSL_PATH   ?= /usr/src/openssl
ME_COM_PHP_PATH       ?= /usr/src/php

CFLAGS                += -fPIC -w
DFLAGS                += -D_REENTRANT -DPIC $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_CGI=$(ME_COM_CGI) -DME_COM_DIR=$(ME_COM_DIR) -DME_COM_EJS=$(ME_COM_EJS) -DME_COM_ESP=$(ME_COM_ESP) -DME_COM_EST=$(ME_COM_EST) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_MATRIXSSL=$(ME_COM_MATRIXSSL) -DME_COM_MDB=$(ME_COM_MDB) -DME_COM_NANOSSL=$(ME_COM_NANOSSL) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_PHP=$(ME_COM_PHP) -DME_COM_SQLITE=$(ME_COM_SQLITE) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_VXWORKS=$(ME_COM_VXWORKS) -DME_COM_WINSDK=$(ME_COM_WINSDK) -DME_COM_ZLIB=$(ME_COM_ZLIB) 
IFLAGS                += "-Ibuild/$(CONFIG)/inc"
LDFLAGS               += 
LIBPATHS              += -Lbuild/$(CONFIG)/bin
LIBS                  += -ldl -lpthread -lm

DEBUG                 ?= debug
CFLAGS-debug          ?= -g
DFLAGS-debug          ?= -DME_DEBUG
LDFLAGS-debug         ?= -g
DFLAGS-release        ?= 
CFLAGS-release        ?= -O2
LDFLAGS-release       ?= 
CFLAGS                += $(CFLAGS-$(DEBUG))
DFLAGS                += $(DFLAGS-$(DEBUG))
LDFLAGS               += $(LDFLAGS-$(DEBUG))

ME_ROOT_PREFIX        ?= 
ME_BASE_PREFIX        ?= $(ME_ROOT_PREFIX)/usr/local
ME_DATA_PREFIX        ?= $(ME_ROOT_PREFIX)/
ME_STATE_PREFIX       ?= $(ME_ROOT_PREFIX)/var
ME_APP_PREFIX         ?= $(ME_BASE_PREFIX)/lib/$(NAME)
ME_VAPP_PREFIX        ?= $(ME_APP_PREFIX)/$(VERSION)
ME_BIN_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/bin
ME_INC_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/include
ME_LIB_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/lib
ME_MAN_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/local/share/man
ME_SBIN_PREFIX        ?= $(ME_ROOT_PREFIX)/usr/local/sbin
ME_ETC_PREFIX         ?= $(ME_ROOT_PREFIX)/etc/$(NAME)
ME_WEB_PREFIX         ?= $(ME_ROOT_PREFIX)/var/www/$(NAME)-default
ME_LOG_PREFIX         ?= $(ME_ROOT_PREFIX)/var/log/$(NAME)
ME_SPOOL_PREFIX       ?= $(ME_ROOT_PREFIX)/var/spool/$(NAME)
ME_CACHE_PREFIX       ?= $(ME_ROOT_PREFIX)/var/spool/$(NAME)/cache
ME_SRC_PREFIX         ?= $(ME_ROOT_PREFIX)$(NAME)-$(VERSION)


TARGETS               += build/$(CONFIG)/bin/appweb
TARGETS               += build/$(CONFIG)/bin/authpass
ifeq ($(ME_COM_CGI),1)
    TARGETS           += build/$(CONFIG)/bin/cgiProgram
endif
ifeq ($(ME_COM_EJS),1)
    TARGETS           += build/$(CONFIG)/bin/ejs.mod
endif
ifeq ($(ME_COM_EJS),1)
    TARGETS           += build/$(CONFIG)/bin/ejs
endif
ifeq ($(ME_COM_ESP),1)
    TARGETS           += build/$(CONFIG)/esp
endif
ifeq ($(ME_COM_ESP),1)
    TARGETS           += build/$(CONFIG)/bin/esp.conf
endif
ifeq ($(ME_COM_ESP),1)
    TARGETS           += build/$(CONFIG)/bin/esp
endif
TARGETS               += build/$(CONFIG)/bin/ca.crt
ifeq ($(ME_COM_HTTP),1)
    TARGETS           += build/$(CONFIG)/bin/http
endif
ifeq ($(ME_COM_EST),1)
    TARGETS           += build/$(CONFIG)/bin/libest.so
endif
ifeq ($(ME_COM_CGI),1)
    TARGETS           += build/$(CONFIG)/bin/libmod_cgi.so
endif
ifeq ($(ME_COM_EJS),1)
    TARGETS           += build/$(CONFIG)/bin/libmod_ejs.so
endif
ifeq ($(ME_COM_PHP),1)
    TARGETS           += build/$(CONFIG)/bin/libmod_php.so
endif
ifeq ($(ME_COM_SSL),1)
    TARGETS           += build/$(CONFIG)/bin/libmod_ssl.so
endif
ifeq ($(ME_COM_SQLITE),1)
    TARGETS           += build/$(CONFIG)/bin/libsql.so
endif
TARGETS               += build/$(CONFIG)/bin/appman
TARGETS               += src/server/cache
ifeq ($(ME_COM_SQLITE),1)
    TARGETS           += build/$(CONFIG)/bin/sqlite
endif
ifeq ($(ME_COM_CGI),1)
    TARGETS           += test/web/auth/basic/basic.cgi
endif
ifeq ($(ME_COM_CGI),1)
    TARGETS           += test/web/caching/cache.cgi
endif
ifeq ($(ME_COM_CGI),1)
    TARGETS           += test/cgi-bin/cgiProgram
endif
ifeq ($(ME_COM_CGI),1)
    TARGETS           += test/cgi-bin/testScript
endif

unexport CDPATH

ifndef SHOW
.SILENT:
endif

all build compile: prep $(TARGETS)

.PHONY: prep

prep:
	@echo "      [Info] Use "make SHOW=1" to trace executed commands."
	@if [ "$(CONFIG)" = "" ] ; then echo WARNING: CONFIG not set ; exit 255 ; fi
	@if [ "$(ME_APP_PREFIX)" = "" ] ; then echo WARNING: ME_APP_PREFIX not set ; exit 255 ; fi
	@[ ! -x $(BUILD)/bin ] && mkdir -p $(BUILD)/bin; true
	@[ ! -x $(BUILD)/inc ] && mkdir -p $(BUILD)/inc; true
	@[ ! -x $(BUILD)/obj ] && mkdir -p $(BUILD)/obj; true
	@[ ! -f $(BUILD)/inc/me.h ] && cp projects/appweb-freebsd-default-me.h $(BUILD)/inc/me.h ; true
	@if ! diff $(BUILD)/inc/me.h projects/appweb-freebsd-default-me.h >/dev/null ; then\
		cp projects/appweb-freebsd-default-me.h $(BUILD)/inc/me.h  ; \
	fi; true
	@if [ -f "$(BUILD)/.makeflags" ] ; then \
		if [ "$(MAKEFLAGS)" != "`cat $(BUILD)/.makeflags`" ] ; then \
			echo "   [Warning] Make flags have changed since the last build: "`cat $(BUILD)/.makeflags`"" ; \
		fi ; \
	fi
	@echo $(MAKEFLAGS) >$(BUILD)/.makeflags

clean:
	rm -f "build/$(CONFIG)/obj/appweb.o"
	rm -f "build/$(CONFIG)/obj/authpass.o"
	rm -f "build/$(CONFIG)/obj/cgiHandler.o"
	rm -f "build/$(CONFIG)/obj/cgiProgram.o"
	rm -f "build/$(CONFIG)/obj/config.o"
	rm -f "build/$(CONFIG)/obj/convenience.o"
	rm -f "build/$(CONFIG)/obj/dirHandler.o"
	rm -f "build/$(CONFIG)/obj/ejs.o"
	rm -f "build/$(CONFIG)/obj/ejsHandler.o"
	rm -f "build/$(CONFIG)/obj/ejsLib.o"
	rm -f "build/$(CONFIG)/obj/ejsc.o"
	rm -f "build/$(CONFIG)/obj/esp.o"
	rm -f "build/$(CONFIG)/obj/espLib.o"
	rm -f "build/$(CONFIG)/obj/estLib.o"
	rm -f "build/$(CONFIG)/obj/fileHandler.o"
	rm -f "build/$(CONFIG)/obj/http.o"
	rm -f "build/$(CONFIG)/obj/httpLib.o"
	rm -f "build/$(CONFIG)/obj/log.o"
	rm -f "build/$(CONFIG)/obj/makerom.o"
	rm -f "build/$(CONFIG)/obj/manager.o"
	rm -f "build/$(CONFIG)/obj/mprLib.o"
	rm -f "build/$(CONFIG)/obj/mprSsl.o"
	rm -f "build/$(CONFIG)/obj/pcre.o"
	rm -f "build/$(CONFIG)/obj/phpHandler.o"
	rm -f "build/$(CONFIG)/obj/server.o"
	rm -f "build/$(CONFIG)/obj/slink.o"
	rm -f "build/$(CONFIG)/obj/sqlite.o"
	rm -f "build/$(CONFIG)/obj/sqlite3.o"
	rm -f "build/$(CONFIG)/obj/sslModule.o"
	rm -f "build/$(CONFIG)/obj/testAppweb.o"
	rm -f "build/$(CONFIG)/obj/testHttp.o"
	rm -f "build/$(CONFIG)/obj/zlib.o"
	rm -f "build/$(CONFIG)/bin/appweb"
	rm -f "build/$(CONFIG)/bin/authpass"
	rm -f "build/$(CONFIG)/bin/cgiProgram"
	rm -f "build/$(CONFIG)/bin/ejsc"
	rm -f "build/$(CONFIG)/bin/ejs"
	rm -f "build/$(CONFIG)/bin/esp.conf"
	rm -f "build/$(CONFIG)/bin/esp"
	rm -f "build/$(CONFIG)/bin/ca.crt"
	rm -f "build/$(CONFIG)/bin/http"
	rm -f "build/$(CONFIG)/bin/libappweb.so"
	rm -f "build/$(CONFIG)/bin/libejs.so"
	rm -f "build/$(CONFIG)/bin/libest.so"
	rm -f "build/$(CONFIG)/bin/libhttp.so"
	rm -f "build/$(CONFIG)/bin/libmod_cgi.so"
	rm -f "build/$(CONFIG)/bin/libmod_ejs.so"
	rm -f "build/$(CONFIG)/bin/libmod_esp.so"
	rm -f "build/$(CONFIG)/bin/libmod_php.so"
	rm -f "build/$(CONFIG)/bin/libmod_ssl.so"
	rm -f "build/$(CONFIG)/bin/libmpr.so"
	rm -f "build/$(CONFIG)/bin/libmprssl.so"
	rm -f "build/$(CONFIG)/bin/libpcre.so"
	rm -f "build/$(CONFIG)/bin/libslink.so"
	rm -f "build/$(CONFIG)/bin/libsql.so"
	rm -f "build/$(CONFIG)/bin/libzlib.so"
	rm -f "build/$(CONFIG)/bin/makerom"
	rm -f "build/$(CONFIG)/bin/appman"
	rm -f "build/$(CONFIG)/bin/sqlite"
	rm -f "build/$(CONFIG)/bin/testAppweb"

clobber: clean
	rm -fr ./$(BUILD)


#
#   mpr.h
#
DEPS_1 += src/paks/mpr/mpr.h

build/$(CONFIG)/inc/mpr.h: $(DEPS_1)
	@echo '      [Copy] build/$(CONFIG)/inc/mpr.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/mpr/mpr.h build/$(CONFIG)/inc/mpr.h

#
#   me.h
#
build/$(CONFIG)/inc/me.h: $(DEPS_2)
	@echo '      [Copy] build/$(CONFIG)/inc/me.h'

#
#   osdep.h
#
DEPS_3 += src/paks/osdep/osdep.h

build/$(CONFIG)/inc/osdep.h: $(DEPS_3)
	@echo '      [Copy] build/$(CONFIG)/inc/osdep.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/osdep/osdep.h build/$(CONFIG)/inc/osdep.h

#
#   mprLib.o
#
DEPS_4 += build/$(CONFIG)/inc/me.h
DEPS_4 += build/$(CONFIG)/inc/mpr.h
DEPS_4 += build/$(CONFIG)/inc/osdep.h

build/$(CONFIG)/obj/mprLib.o: \
    src/paks/mpr/mprLib.c $(DEPS_4)
	@echo '   [Compile] build/$(CONFIG)/obj/mprLib.o'
	$(CC) -c -o build/$(CONFIG)/obj/mprLib.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/mpr/mprLib.c

#
#   libmpr
#
DEPS_5 += build/$(CONFIG)/inc/mpr.h
DEPS_5 += build/$(CONFIG)/inc/me.h
DEPS_5 += build/$(CONFIG)/inc/osdep.h
DEPS_5 += build/$(CONFIG)/obj/mprLib.o

build/$(CONFIG)/bin/libmpr.so: $(DEPS_5)
	@echo '      [Link] build/$(CONFIG)/bin/libmpr.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libmpr.so $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/mprLib.o" $(LIBS) 

#
#   pcre.h
#
DEPS_6 += src/paks/pcre/pcre.h

build/$(CONFIG)/inc/pcre.h: $(DEPS_6)
	@echo '      [Copy] build/$(CONFIG)/inc/pcre.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/pcre/pcre.h build/$(CONFIG)/inc/pcre.h

#
#   pcre.o
#
DEPS_7 += build/$(CONFIG)/inc/me.h
DEPS_7 += build/$(CONFIG)/inc/pcre.h

build/$(CONFIG)/obj/pcre.o: \
    src/paks/pcre/pcre.c $(DEPS_7)
	@echo '   [Compile] build/$(CONFIG)/obj/pcre.o'
	$(CC) -c -o build/$(CONFIG)/obj/pcre.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/pcre/pcre.c

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_8 += build/$(CONFIG)/inc/pcre.h
DEPS_8 += build/$(CONFIG)/inc/me.h
DEPS_8 += build/$(CONFIG)/obj/pcre.o

build/$(CONFIG)/bin/libpcre.so: $(DEPS_8)
	@echo '      [Link] build/$(CONFIG)/bin/libpcre.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libpcre.so $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/pcre.o" $(LIBS) 
endif

#
#   http.h
#
DEPS_9 += src/paks/http/http.h

build/$(CONFIG)/inc/http.h: $(DEPS_9)
	@echo '      [Copy] build/$(CONFIG)/inc/http.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/http/http.h build/$(CONFIG)/inc/http.h

#
#   httpLib.o
#
DEPS_10 += build/$(CONFIG)/inc/me.h
DEPS_10 += build/$(CONFIG)/inc/http.h
DEPS_10 += build/$(CONFIG)/inc/mpr.h

build/$(CONFIG)/obj/httpLib.o: \
    src/paks/http/httpLib.c $(DEPS_10)
	@echo '   [Compile] build/$(CONFIG)/obj/httpLib.o'
	$(CC) -c -o build/$(CONFIG)/obj/httpLib.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/http/httpLib.c

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_11 += build/$(CONFIG)/inc/mpr.h
DEPS_11 += build/$(CONFIG)/inc/me.h
DEPS_11 += build/$(CONFIG)/inc/osdep.h
DEPS_11 += build/$(CONFIG)/obj/mprLib.o
DEPS_11 += build/$(CONFIG)/bin/libmpr.so
DEPS_11 += build/$(CONFIG)/inc/pcre.h
DEPS_11 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_11 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_11 += build/$(CONFIG)/inc/http.h
DEPS_11 += build/$(CONFIG)/obj/httpLib.o

LIBS_11 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_11 += -lpcre
endif

build/$(CONFIG)/bin/libhttp.so: $(DEPS_11)
	@echo '      [Link] build/$(CONFIG)/bin/libhttp.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libhttp.so $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/httpLib.o" $(LIBPATHS_11) $(LIBS_11) $(LIBS_11) $(LIBS) 
endif

#
#   appweb.h
#
DEPS_12 += src/appweb.h

build/$(CONFIG)/inc/appweb.h: $(DEPS_12)
	@echo '      [Copy] build/$(CONFIG)/inc/appweb.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/appweb.h build/$(CONFIG)/inc/appweb.h

#
#   customize.h
#
DEPS_13 += src/customize.h

build/$(CONFIG)/inc/customize.h: $(DEPS_13)
	@echo '      [Copy] build/$(CONFIG)/inc/customize.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/customize.h build/$(CONFIG)/inc/customize.h

#
#   config.o
#
DEPS_14 += build/$(CONFIG)/inc/me.h
DEPS_14 += build/$(CONFIG)/inc/appweb.h
DEPS_14 += build/$(CONFIG)/inc/pcre.h
DEPS_14 += build/$(CONFIG)/inc/mpr.h
DEPS_14 += build/$(CONFIG)/inc/http.h
DEPS_14 += build/$(CONFIG)/inc/customize.h

build/$(CONFIG)/obj/config.o: \
    src/config.c $(DEPS_14)
	@echo '   [Compile] build/$(CONFIG)/obj/config.o'
	$(CC) -c -o build/$(CONFIG)/obj/config.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/config.c

#
#   convenience.o
#
DEPS_15 += build/$(CONFIG)/inc/me.h
DEPS_15 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/convenience.o: \
    src/convenience.c $(DEPS_15)
	@echo '   [Compile] build/$(CONFIG)/obj/convenience.o'
	$(CC) -c -o build/$(CONFIG)/obj/convenience.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/convenience.c

#
#   dirHandler.o
#
DEPS_16 += build/$(CONFIG)/inc/me.h
DEPS_16 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/dirHandler.o: \
    src/dirHandler.c $(DEPS_16)
	@echo '   [Compile] build/$(CONFIG)/obj/dirHandler.o'
	$(CC) -c -o build/$(CONFIG)/obj/dirHandler.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/dirHandler.c

#
#   fileHandler.o
#
DEPS_17 += build/$(CONFIG)/inc/me.h
DEPS_17 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/fileHandler.o: \
    src/fileHandler.c $(DEPS_17)
	@echo '   [Compile] build/$(CONFIG)/obj/fileHandler.o'
	$(CC) -c -o build/$(CONFIG)/obj/fileHandler.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/fileHandler.c

#
#   log.o
#
DEPS_18 += build/$(CONFIG)/inc/me.h
DEPS_18 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/log.o: \
    src/log.c $(DEPS_18)
	@echo '   [Compile] build/$(CONFIG)/obj/log.o'
	$(CC) -c -o build/$(CONFIG)/obj/log.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/log.c

#
#   server.o
#
DEPS_19 += build/$(CONFIG)/inc/me.h
DEPS_19 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/server.o: \
    src/server.c $(DEPS_19)
	@echo '   [Compile] build/$(CONFIG)/obj/server.o'
	$(CC) -c -o build/$(CONFIG)/obj/server.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/server.c

#
#   libappweb
#
DEPS_20 += build/$(CONFIG)/inc/mpr.h
DEPS_20 += build/$(CONFIG)/inc/me.h
DEPS_20 += build/$(CONFIG)/inc/osdep.h
DEPS_20 += build/$(CONFIG)/obj/mprLib.o
DEPS_20 += build/$(CONFIG)/bin/libmpr.so
DEPS_20 += build/$(CONFIG)/inc/pcre.h
DEPS_20 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_20 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_20 += build/$(CONFIG)/inc/http.h
DEPS_20 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_20 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_20 += build/$(CONFIG)/inc/appweb.h
DEPS_20 += build/$(CONFIG)/inc/customize.h
DEPS_20 += build/$(CONFIG)/obj/config.o
DEPS_20 += build/$(CONFIG)/obj/convenience.o
DEPS_20 += build/$(CONFIG)/obj/dirHandler.o
DEPS_20 += build/$(CONFIG)/obj/fileHandler.o
DEPS_20 += build/$(CONFIG)/obj/log.o
DEPS_20 += build/$(CONFIG)/obj/server.o

ifeq ($(ME_COM_HTTP),1)
    LIBS_20 += -lhttp
endif
LIBS_20 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_20 += -lpcre
endif

build/$(CONFIG)/bin/libappweb.so: $(DEPS_20)
	@echo '      [Link] build/$(CONFIG)/bin/libappweb.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libappweb.so $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/config.o" "build/$(CONFIG)/obj/convenience.o" "build/$(CONFIG)/obj/dirHandler.o" "build/$(CONFIG)/obj/fileHandler.o" "build/$(CONFIG)/obj/log.o" "build/$(CONFIG)/obj/server.o" $(LIBPATHS_20) $(LIBS_20) $(LIBS_20) $(LIBS) 

#
#   slink.c
#
src/slink.c: $(DEPS_21)
	( \
	cd src; \
	[ ! -f slink.c ] && cp slink.empty slink.c ; true ; \
	)

#
#   esp.h
#
DEPS_22 += src/paks/esp/esp.h

build/$(CONFIG)/inc/esp.h: $(DEPS_22)
	@echo '      [Copy] build/$(CONFIG)/inc/esp.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/esp/esp.h build/$(CONFIG)/inc/esp.h

#
#   slink.o
#
DEPS_23 += build/$(CONFIG)/inc/me.h
DEPS_23 += build/$(CONFIG)/inc/mpr.h
DEPS_23 += build/$(CONFIG)/inc/esp.h

build/$(CONFIG)/obj/slink.o: \
    src/slink.c $(DEPS_23)
	@echo '   [Compile] build/$(CONFIG)/obj/slink.o'
	$(CC) -c -o build/$(CONFIG)/obj/slink.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/slink.c

#
#   libslink
#
DEPS_24 += src/slink.c
DEPS_24 += build/$(CONFIG)/inc/me.h
DEPS_24 += build/$(CONFIG)/inc/mpr.h
DEPS_24 += build/$(CONFIG)/inc/esp.h
DEPS_24 += build/$(CONFIG)/obj/slink.o

build/$(CONFIG)/bin/libslink.so: $(DEPS_24)
	@echo '      [Link] build/$(CONFIG)/bin/libslink.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libslink.so $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/slink.o" $(LIBS) 

#
#   appweb.o
#
DEPS_25 += build/$(CONFIG)/inc/me.h
DEPS_25 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/appweb.o: \
    src/server/appweb.c $(DEPS_25)
	@echo '   [Compile] build/$(CONFIG)/obj/appweb.o'
	$(CC) -c -o build/$(CONFIG)/obj/appweb.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/server/appweb.c

#
#   appweb
#
DEPS_26 += build/$(CONFIG)/inc/mpr.h
DEPS_26 += build/$(CONFIG)/inc/me.h
DEPS_26 += build/$(CONFIG)/inc/osdep.h
DEPS_26 += build/$(CONFIG)/obj/mprLib.o
DEPS_26 += build/$(CONFIG)/bin/libmpr.so
DEPS_26 += build/$(CONFIG)/inc/pcre.h
DEPS_26 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_26 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_26 += build/$(CONFIG)/inc/http.h
DEPS_26 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_26 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_26 += build/$(CONFIG)/inc/appweb.h
DEPS_26 += build/$(CONFIG)/inc/customize.h
DEPS_26 += build/$(CONFIG)/obj/config.o
DEPS_26 += build/$(CONFIG)/obj/convenience.o
DEPS_26 += build/$(CONFIG)/obj/dirHandler.o
DEPS_26 += build/$(CONFIG)/obj/fileHandler.o
DEPS_26 += build/$(CONFIG)/obj/log.o
DEPS_26 += build/$(CONFIG)/obj/server.o
DEPS_26 += build/$(CONFIG)/bin/libappweb.so
DEPS_26 += src/slink.c
DEPS_26 += build/$(CONFIG)/inc/esp.h
DEPS_26 += build/$(CONFIG)/obj/slink.o
DEPS_26 += build/$(CONFIG)/bin/libslink.so
DEPS_26 += build/$(CONFIG)/obj/appweb.o

LIBS_26 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_26 += -lhttp
endif
LIBS_26 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_26 += -lpcre
endif
LIBS_26 += -lslink

build/$(CONFIG)/bin/appweb: $(DEPS_26)
	@echo '      [Link] build/$(CONFIG)/bin/appweb'
	$(CC) -o build/$(CONFIG)/bin/appweb $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/appweb.o" $(LIBPATHS_26) $(LIBS_26) $(LIBS_26) $(LIBS) $(LIBS) 

#
#   authpass.o
#
DEPS_27 += build/$(CONFIG)/inc/me.h
DEPS_27 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/authpass.o: \
    src/utils/authpass.c $(DEPS_27)
	@echo '   [Compile] build/$(CONFIG)/obj/authpass.o'
	$(CC) -c -o build/$(CONFIG)/obj/authpass.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/utils/authpass.c

#
#   authpass
#
DEPS_28 += build/$(CONFIG)/inc/mpr.h
DEPS_28 += build/$(CONFIG)/inc/me.h
DEPS_28 += build/$(CONFIG)/inc/osdep.h
DEPS_28 += build/$(CONFIG)/obj/mprLib.o
DEPS_28 += build/$(CONFIG)/bin/libmpr.so
DEPS_28 += build/$(CONFIG)/inc/pcre.h
DEPS_28 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_28 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_28 += build/$(CONFIG)/inc/http.h
DEPS_28 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_28 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_28 += build/$(CONFIG)/inc/appweb.h
DEPS_28 += build/$(CONFIG)/inc/customize.h
DEPS_28 += build/$(CONFIG)/obj/config.o
DEPS_28 += build/$(CONFIG)/obj/convenience.o
DEPS_28 += build/$(CONFIG)/obj/dirHandler.o
DEPS_28 += build/$(CONFIG)/obj/fileHandler.o
DEPS_28 += build/$(CONFIG)/obj/log.o
DEPS_28 += build/$(CONFIG)/obj/server.o
DEPS_28 += build/$(CONFIG)/bin/libappweb.so
DEPS_28 += build/$(CONFIG)/obj/authpass.o

LIBS_28 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_28 += -lhttp
endif
LIBS_28 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_28 += -lpcre
endif

build/$(CONFIG)/bin/authpass: $(DEPS_28)
	@echo '      [Link] build/$(CONFIG)/bin/authpass'
	$(CC) -o build/$(CONFIG)/bin/authpass $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/authpass.o" $(LIBPATHS_28) $(LIBS_28) $(LIBS_28) $(LIBS) $(LIBS) 

#
#   cgiProgram.o
#
DEPS_29 += build/$(CONFIG)/inc/me.h

build/$(CONFIG)/obj/cgiProgram.o: \
    src/utils/cgiProgram.c $(DEPS_29)
	@echo '   [Compile] build/$(CONFIG)/obj/cgiProgram.o'
	$(CC) -c -o build/$(CONFIG)/obj/cgiProgram.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/utils/cgiProgram.c

ifeq ($(ME_COM_CGI),1)
#
#   cgiProgram
#
DEPS_30 += build/$(CONFIG)/inc/me.h
DEPS_30 += build/$(CONFIG)/obj/cgiProgram.o

build/$(CONFIG)/bin/cgiProgram: $(DEPS_30)
	@echo '      [Link] build/$(CONFIG)/bin/cgiProgram'
	$(CC) -o build/$(CONFIG)/bin/cgiProgram $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/cgiProgram.o" $(LIBS) $(LIBS) 
endif

#
#   zlib.h
#
DEPS_31 += src/paks/zlib/zlib.h

build/$(CONFIG)/inc/zlib.h: $(DEPS_31)
	@echo '      [Copy] build/$(CONFIG)/inc/zlib.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/zlib/zlib.h build/$(CONFIG)/inc/zlib.h

#
#   zlib.o
#
DEPS_32 += build/$(CONFIG)/inc/me.h
DEPS_32 += build/$(CONFIG)/inc/zlib.h

build/$(CONFIG)/obj/zlib.o: \
    src/paks/zlib/zlib.c $(DEPS_32)
	@echo '   [Compile] build/$(CONFIG)/obj/zlib.o'
	$(CC) -c -o build/$(CONFIG)/obj/zlib.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/zlib/zlib.c

ifeq ($(ME_COM_ZLIB),1)
#
#   libzlib
#
DEPS_33 += build/$(CONFIG)/inc/zlib.h
DEPS_33 += build/$(CONFIG)/inc/me.h
DEPS_33 += build/$(CONFIG)/obj/zlib.o

build/$(CONFIG)/bin/libzlib.so: $(DEPS_33)
	@echo '      [Link] build/$(CONFIG)/bin/libzlib.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libzlib.so $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/zlib.o" $(LIBS) 
endif

#
#   ejs.h
#
DEPS_34 += src/paks/ejs/ejs.h

build/$(CONFIG)/inc/ejs.h: $(DEPS_34)
	@echo '      [Copy] build/$(CONFIG)/inc/ejs.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/ejs/ejs.h build/$(CONFIG)/inc/ejs.h

#
#   ejs.slots.h
#
DEPS_35 += src/paks/ejs/ejs.slots.h

build/$(CONFIG)/inc/ejs.slots.h: $(DEPS_35)
	@echo '      [Copy] build/$(CONFIG)/inc/ejs.slots.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/ejs/ejs.slots.h build/$(CONFIG)/inc/ejs.slots.h

#
#   ejsByteGoto.h
#
DEPS_36 += src/paks/ejs/ejsByteGoto.h

build/$(CONFIG)/inc/ejsByteGoto.h: $(DEPS_36)
	@echo '      [Copy] build/$(CONFIG)/inc/ejsByteGoto.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/ejs/ejsByteGoto.h build/$(CONFIG)/inc/ejsByteGoto.h

#
#   ejsLib.o
#
DEPS_37 += build/$(CONFIG)/inc/me.h
DEPS_37 += build/$(CONFIG)/inc/ejs.h
DEPS_37 += build/$(CONFIG)/inc/mpr.h
DEPS_37 += build/$(CONFIG)/inc/pcre.h
DEPS_37 += build/$(CONFIG)/inc/osdep.h
DEPS_37 += build/$(CONFIG)/inc/http.h
DEPS_37 += build/$(CONFIG)/inc/ejs.slots.h

build/$(CONFIG)/obj/ejsLib.o: \
    src/paks/ejs/ejsLib.c $(DEPS_37)
	@echo '   [Compile] build/$(CONFIG)/obj/ejsLib.o'
	$(CC) -c -o build/$(CONFIG)/obj/ejsLib.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/ejs/ejsLib.c

ifeq ($(ME_COM_EJS),1)
#
#   libejs
#
DEPS_38 += build/$(CONFIG)/inc/mpr.h
DEPS_38 += build/$(CONFIG)/inc/me.h
DEPS_38 += build/$(CONFIG)/inc/osdep.h
DEPS_38 += build/$(CONFIG)/obj/mprLib.o
DEPS_38 += build/$(CONFIG)/bin/libmpr.so
DEPS_38 += build/$(CONFIG)/inc/pcre.h
DEPS_38 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_38 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_38 += build/$(CONFIG)/inc/http.h
DEPS_38 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_38 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_38 += build/$(CONFIG)/inc/zlib.h
DEPS_38 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_38 += build/$(CONFIG)/bin/libzlib.so
endif
DEPS_38 += build/$(CONFIG)/inc/ejs.h
DEPS_38 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_38 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_38 += build/$(CONFIG)/obj/ejsLib.o

ifeq ($(ME_COM_HTTP),1)
    LIBS_38 += -lhttp
endif
LIBS_38 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_38 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_38 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_38 += -lsql
endif

build/$(CONFIG)/bin/libejs.so: $(DEPS_38)
	@echo '      [Link] build/$(CONFIG)/bin/libejs.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libejs.so $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/ejsLib.o" $(LIBPATHS_38) $(LIBS_38) $(LIBS_38) $(LIBS) 
endif

#
#   ejsc.o
#
DEPS_39 += build/$(CONFIG)/inc/me.h
DEPS_39 += build/$(CONFIG)/inc/ejs.h

build/$(CONFIG)/obj/ejsc.o: \
    src/paks/ejs/ejsc.c $(DEPS_39)
	@echo '   [Compile] build/$(CONFIG)/obj/ejsc.o'
	$(CC) -c -o build/$(CONFIG)/obj/ejsc.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/ejs/ejsc.c

ifeq ($(ME_COM_EJS),1)
#
#   ejsc
#
DEPS_40 += build/$(CONFIG)/inc/mpr.h
DEPS_40 += build/$(CONFIG)/inc/me.h
DEPS_40 += build/$(CONFIG)/inc/osdep.h
DEPS_40 += build/$(CONFIG)/obj/mprLib.o
DEPS_40 += build/$(CONFIG)/bin/libmpr.so
DEPS_40 += build/$(CONFIG)/inc/pcre.h
DEPS_40 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_40 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_40 += build/$(CONFIG)/inc/http.h
DEPS_40 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_40 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_40 += build/$(CONFIG)/inc/zlib.h
DEPS_40 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_40 += build/$(CONFIG)/bin/libzlib.so
endif
DEPS_40 += build/$(CONFIG)/inc/ejs.h
DEPS_40 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_40 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_40 += build/$(CONFIG)/obj/ejsLib.o
DEPS_40 += build/$(CONFIG)/bin/libejs.so
DEPS_40 += build/$(CONFIG)/obj/ejsc.o

LIBS_40 += -lejs
ifeq ($(ME_COM_HTTP),1)
    LIBS_40 += -lhttp
endif
LIBS_40 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_40 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_40 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_40 += -lsql
endif

build/$(CONFIG)/bin/ejsc: $(DEPS_40)
	@echo '      [Link] build/$(CONFIG)/bin/ejsc'
	$(CC) -o build/$(CONFIG)/bin/ejsc $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/ejsc.o" $(LIBPATHS_40) $(LIBS_40) $(LIBS_40) $(LIBS) $(LIBS) 
endif

ifeq ($(ME_COM_EJS),1)
#
#   ejs.mod
#
DEPS_41 += src/paks/ejs/ejs.es
DEPS_41 += build/$(CONFIG)/inc/mpr.h
DEPS_41 += build/$(CONFIG)/inc/me.h
DEPS_41 += build/$(CONFIG)/inc/osdep.h
DEPS_41 += build/$(CONFIG)/obj/mprLib.o
DEPS_41 += build/$(CONFIG)/bin/libmpr.so
DEPS_41 += build/$(CONFIG)/inc/pcre.h
DEPS_41 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_41 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_41 += build/$(CONFIG)/inc/http.h
DEPS_41 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_41 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_41 += build/$(CONFIG)/inc/zlib.h
DEPS_41 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_41 += build/$(CONFIG)/bin/libzlib.so
endif
DEPS_41 += build/$(CONFIG)/inc/ejs.h
DEPS_41 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_41 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_41 += build/$(CONFIG)/obj/ejsLib.o
DEPS_41 += build/$(CONFIG)/bin/libejs.so
DEPS_41 += build/$(CONFIG)/obj/ejsc.o
DEPS_41 += build/$(CONFIG)/bin/ejsc

build/$(CONFIG)/bin/ejs.mod: $(DEPS_41)
	( \
	cd src/paks/ejs; \
	../../../$(LBIN)/ejsc --out ../../../build/$(CONFIG)/bin/ejs.mod --optimize 9 --bind --require null ejs.es ; \
	)
endif

#
#   ejs.o
#
DEPS_42 += build/$(CONFIG)/inc/me.h
DEPS_42 += build/$(CONFIG)/inc/ejs.h

build/$(CONFIG)/obj/ejs.o: \
    src/paks/ejs/ejs.c $(DEPS_42)
	@echo '   [Compile] build/$(CONFIG)/obj/ejs.o'
	$(CC) -c -o build/$(CONFIG)/obj/ejs.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/ejs/ejs.c

ifeq ($(ME_COM_EJS),1)
#
#   ejscmd
#
DEPS_43 += build/$(CONFIG)/inc/mpr.h
DEPS_43 += build/$(CONFIG)/inc/me.h
DEPS_43 += build/$(CONFIG)/inc/osdep.h
DEPS_43 += build/$(CONFIG)/obj/mprLib.o
DEPS_43 += build/$(CONFIG)/bin/libmpr.so
DEPS_43 += build/$(CONFIG)/inc/pcre.h
DEPS_43 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_43 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_43 += build/$(CONFIG)/inc/http.h
DEPS_43 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_43 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_43 += build/$(CONFIG)/inc/zlib.h
DEPS_43 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_43 += build/$(CONFIG)/bin/libzlib.so
endif
DEPS_43 += build/$(CONFIG)/inc/ejs.h
DEPS_43 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_43 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_43 += build/$(CONFIG)/obj/ejsLib.o
DEPS_43 += build/$(CONFIG)/bin/libejs.so
DEPS_43 += build/$(CONFIG)/obj/ejs.o

LIBS_43 += -lejs
ifeq ($(ME_COM_HTTP),1)
    LIBS_43 += -lhttp
endif
LIBS_43 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_43 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_43 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_43 += -lsql
endif

build/$(CONFIG)/bin/ejs: $(DEPS_43)
	@echo '      [Link] build/$(CONFIG)/bin/ejs'
	$(CC) -o build/$(CONFIG)/bin/ejs $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/ejs.o" $(LIBPATHS_43) $(LIBS_43) $(LIBS_43) $(LIBS) $(LIBS) 
endif

ifeq ($(ME_COM_ESP),1)
#
#   esp-paks
#
DEPS_44 += src/paks/esp-html-mvc
DEPS_44 += src/paks/esp-html-mvc/client
DEPS_44 += src/paks/esp-html-mvc/client/assets
DEPS_44 += src/paks/esp-html-mvc/client/assets/favicon.ico
DEPS_44 += src/paks/esp-html-mvc/client/css
DEPS_44 += src/paks/esp-html-mvc/client/css/all.css
DEPS_44 += src/paks/esp-html-mvc/client/css/all.less
DEPS_44 += src/paks/esp-html-mvc/client/index.esp
DEPS_44 += src/paks/esp-html-mvc/css
DEPS_44 += src/paks/esp-html-mvc/css/app.less
DEPS_44 += src/paks/esp-html-mvc/css/theme.less
DEPS_44 += src/paks/esp-html-mvc/generate
DEPS_44 += src/paks/esp-html-mvc/generate/appweb.conf
DEPS_44 += src/paks/esp-html-mvc/generate/controller.c
DEPS_44 += src/paks/esp-html-mvc/generate/controllerSingleton.c
DEPS_44 += src/paks/esp-html-mvc/generate/edit.esp
DEPS_44 += src/paks/esp-html-mvc/generate/list.esp
DEPS_44 += src/paks/esp-html-mvc/layouts
DEPS_44 += src/paks/esp-html-mvc/layouts/default.esp
DEPS_44 += src/paks/esp-html-mvc/package.json
DEPS_44 += src/paks/esp-legacy-mvc
DEPS_44 += src/paks/esp-legacy-mvc/generate
DEPS_44 += src/paks/esp-legacy-mvc/generate/appweb.conf
DEPS_44 += src/paks/esp-legacy-mvc/generate/controller.c
DEPS_44 += src/paks/esp-legacy-mvc/generate/edit.esp
DEPS_44 += src/paks/esp-legacy-mvc/generate/list.esp
DEPS_44 += src/paks/esp-legacy-mvc/generate/migration.c
DEPS_44 += src/paks/esp-legacy-mvc/generate/src
DEPS_44 += src/paks/esp-legacy-mvc/generate/src/app.c
DEPS_44 += src/paks/esp-legacy-mvc/layouts
DEPS_44 += src/paks/esp-legacy-mvc/layouts/default.esp
DEPS_44 += src/paks/esp-legacy-mvc/package.json
DEPS_44 += src/paks/esp-legacy-mvc/static
DEPS_44 += src/paks/esp-legacy-mvc/static/css
DEPS_44 += src/paks/esp-legacy-mvc/static/css/all.css
DEPS_44 += src/paks/esp-legacy-mvc/static/images
DEPS_44 += src/paks/esp-legacy-mvc/static/images/banner.jpg
DEPS_44 += src/paks/esp-legacy-mvc/static/images/favicon.ico
DEPS_44 += src/paks/esp-legacy-mvc/static/images/splash.jpg
DEPS_44 += src/paks/esp-legacy-mvc/static/index.esp
DEPS_44 += src/paks/esp-legacy-mvc/static/js
DEPS_44 += src/paks/esp-legacy-mvc/static/js/jquery.esp.js
DEPS_44 += src/paks/esp-legacy-mvc/static/js/jquery.js
DEPS_44 += src/paks/esp-mvc
DEPS_44 += src/paks/esp-mvc/LICENSE.md
DEPS_44 += src/paks/esp-mvc/README.md
DEPS_44 += src/paks/esp-mvc/generate
DEPS_44 += src/paks/esp-mvc/generate/appweb.conf
DEPS_44 += src/paks/esp-mvc/generate/controller.c
DEPS_44 += src/paks/esp-mvc/generate/migration.c
DEPS_44 += src/paks/esp-mvc/generate/src
DEPS_44 += src/paks/esp-mvc/generate/src/app.c
DEPS_44 += src/paks/esp-mvc/package.json
DEPS_44 += src/paks/esp-server
DEPS_44 += src/paks/esp-server/generate
DEPS_44 += src/paks/esp-server/generate/appweb.conf
DEPS_44 += src/paks/esp-server/package.json

build/$(CONFIG)/esp: $(DEPS_44)
	( \
	cd src/paks; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/4.6.4" ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/4.6.4/client" ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/4.6.4/client/assets" ; \
	cp esp-html-mvc/client/assets/favicon.ico ../../build/$(CONFIG)/esp/esp-html-mvc/4.6.4/client/assets/favicon.ico ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/4.6.4/client/css" ; \
	cp esp-html-mvc/client/css/all.css ../../build/$(CONFIG)/esp/esp-html-mvc/4.6.4/client/css/all.css ; \
	cp esp-html-mvc/client/css/all.less ../../build/$(CONFIG)/esp/esp-html-mvc/4.6.4/client/css/all.less ; \
	cp esp-html-mvc/client/index.esp ../../build/$(CONFIG)/esp/esp-html-mvc/4.6.4/client/index.esp ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/4.6.4/css" ; \
	cp esp-html-mvc/css/app.less ../../build/$(CONFIG)/esp/esp-html-mvc/4.6.4/css/app.less ; \
	cp esp-html-mvc/css/theme.less ../../build/$(CONFIG)/esp/esp-html-mvc/4.6.4/css/theme.less ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/4.6.4/generate" ; \
	cp esp-html-mvc/generate/appweb.conf ../../build/$(CONFIG)/esp/esp-html-mvc/4.6.4/generate/appweb.conf ; \
	cp esp-html-mvc/generate/controller.c ../../build/$(CONFIG)/esp/esp-html-mvc/4.6.4/generate/controller.c ; \
	cp esp-html-mvc/generate/controllerSingleton.c ../../build/$(CONFIG)/esp/esp-html-mvc/4.6.4/generate/controllerSingleton.c ; \
	cp esp-html-mvc/generate/edit.esp ../../build/$(CONFIG)/esp/esp-html-mvc/4.6.4/generate/edit.esp ; \
	cp esp-html-mvc/generate/list.esp ../../build/$(CONFIG)/esp/esp-html-mvc/4.6.4/generate/list.esp ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/4.6.4/layouts" ; \
	cp esp-html-mvc/layouts/default.esp ../../build/$(CONFIG)/esp/esp-html-mvc/4.6.4/layouts/default.esp ; \
	cp esp-html-mvc/package.json ../../build/$(CONFIG)/esp/esp-html-mvc/4.6.4/package.json ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-legacy-mvc/4.6.4" ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-legacy-mvc/4.6.4/generate" ; \
	cp esp-legacy-mvc/generate/appweb.conf ../../build/$(CONFIG)/esp/esp-legacy-mvc/4.6.4/generate/appweb.conf ; \
	cp esp-legacy-mvc/generate/controller.c ../../build/$(CONFIG)/esp/esp-legacy-mvc/4.6.4/generate/controller.c ; \
	cp esp-legacy-mvc/generate/edit.esp ../../build/$(CONFIG)/esp/esp-legacy-mvc/4.6.4/generate/edit.esp ; \
	cp esp-legacy-mvc/generate/list.esp ../../build/$(CONFIG)/esp/esp-legacy-mvc/4.6.4/generate/list.esp ; \
	cp esp-legacy-mvc/generate/migration.c ../../build/$(CONFIG)/esp/esp-legacy-mvc/4.6.4/generate/migration.c ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-legacy-mvc/4.6.4/generate/src" ; \
	cp esp-legacy-mvc/generate/src/app.c ../../build/$(CONFIG)/esp/esp-legacy-mvc/4.6.4/generate/src/app.c ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-legacy-mvc/4.6.4/layouts" ; \
	cp esp-legacy-mvc/layouts/default.esp ../../build/$(CONFIG)/esp/esp-legacy-mvc/4.6.4/layouts/default.esp ; \
	cp esp-legacy-mvc/package.json ../../build/$(CONFIG)/esp/esp-legacy-mvc/4.6.4/package.json ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-legacy-mvc/4.6.4/static" ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-legacy-mvc/4.6.4/static/css" ; \
	cp esp-legacy-mvc/static/css/all.css ../../build/$(CONFIG)/esp/esp-legacy-mvc/4.6.4/static/css/all.css ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-legacy-mvc/4.6.4/static/images" ; \
	cp esp-legacy-mvc/static/images/banner.jpg ../../build/$(CONFIG)/esp/esp-legacy-mvc/4.6.4/static/images/banner.jpg ; \
	cp esp-legacy-mvc/static/images/favicon.ico ../../build/$(CONFIG)/esp/esp-legacy-mvc/4.6.4/static/images/favicon.ico ; \
	cp esp-legacy-mvc/static/images/splash.jpg ../../build/$(CONFIG)/esp/esp-legacy-mvc/4.6.4/static/images/splash.jpg ; \
	cp esp-legacy-mvc/static/index.esp ../../build/$(CONFIG)/esp/esp-legacy-mvc/4.6.4/static/index.esp ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-legacy-mvc/4.6.4/static/js" ; \
	cp esp-legacy-mvc/static/js/jquery.esp.js ../../build/$(CONFIG)/esp/esp-legacy-mvc/4.6.4/static/js/jquery.esp.js ; \
	cp esp-legacy-mvc/static/js/jquery.js ../../build/$(CONFIG)/esp/esp-legacy-mvc/4.6.4/static/js/jquery.js ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-mvc/4.6.4" ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-mvc/4.6.4/generate" ; \
	cp esp-mvc/generate/appweb.conf ../../build/$(CONFIG)/esp/esp-mvc/4.6.4/generate/appweb.conf ; \
	cp esp-mvc/generate/controller.c ../../build/$(CONFIG)/esp/esp-mvc/4.6.4/generate/controller.c ; \
	cp esp-mvc/generate/migration.c ../../build/$(CONFIG)/esp/esp-mvc/4.6.4/generate/migration.c ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-mvc/4.6.4/generate/src" ; \
	cp esp-mvc/generate/src/app.c ../../build/$(CONFIG)/esp/esp-mvc/4.6.4/generate/src/app.c ; \
	cp esp-mvc/LICENSE.md ../../build/$(CONFIG)/esp/esp-mvc/4.6.4/LICENSE.md ; \
	cp esp-mvc/package.json ../../build/$(CONFIG)/esp/esp-mvc/4.6.4/package.json ; \
	cp esp-mvc/README.md ../../build/$(CONFIG)/esp/esp-mvc/4.6.4/README.md ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-server/4.6.4" ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-server/4.6.4/generate" ; \
	cp esp-server/generate/appweb.conf ../../build/$(CONFIG)/esp/esp-server/4.6.4/generate/appweb.conf ; \
	cp esp-server/package.json ../../build/$(CONFIG)/esp/esp-server/4.6.4/package.json ; \
	)
endif

ifeq ($(ME_COM_ESP),1)
#
#   esp.conf
#
DEPS_45 += src/paks/esp/esp.conf

build/$(CONFIG)/bin/esp.conf: $(DEPS_45)
	@echo '      [Copy] build/$(CONFIG)/bin/esp.conf'
	mkdir -p "build/$(CONFIG)/bin"
	cp src/paks/esp/esp.conf build/$(CONFIG)/bin/esp.conf
endif

#
#   espLib.o
#
DEPS_46 += build/$(CONFIG)/inc/me.h
DEPS_46 += build/$(CONFIG)/inc/esp.h
DEPS_46 += build/$(CONFIG)/inc/pcre.h
DEPS_46 += build/$(CONFIG)/inc/osdep.h
DEPS_46 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/espLib.o: \
    src/paks/esp/espLib.c $(DEPS_46)
	@echo '   [Compile] build/$(CONFIG)/obj/espLib.o'
	$(CC) -c -o build/$(CONFIG)/obj/espLib.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/esp/espLib.c

ifeq ($(ME_COM_ESP),1)
#
#   libmod_esp
#
DEPS_47 += build/$(CONFIG)/inc/mpr.h
DEPS_47 += build/$(CONFIG)/inc/me.h
DEPS_47 += build/$(CONFIG)/inc/osdep.h
DEPS_47 += build/$(CONFIG)/obj/mprLib.o
DEPS_47 += build/$(CONFIG)/bin/libmpr.so
DEPS_47 += build/$(CONFIG)/inc/pcre.h
DEPS_47 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_47 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_47 += build/$(CONFIG)/inc/http.h
DEPS_47 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_47 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_47 += build/$(CONFIG)/inc/appweb.h
DEPS_47 += build/$(CONFIG)/inc/customize.h
DEPS_47 += build/$(CONFIG)/obj/config.o
DEPS_47 += build/$(CONFIG)/obj/convenience.o
DEPS_47 += build/$(CONFIG)/obj/dirHandler.o
DEPS_47 += build/$(CONFIG)/obj/fileHandler.o
DEPS_47 += build/$(CONFIG)/obj/log.o
DEPS_47 += build/$(CONFIG)/obj/server.o
DEPS_47 += build/$(CONFIG)/bin/libappweb.so
DEPS_47 += build/$(CONFIG)/inc/esp.h
DEPS_47 += build/$(CONFIG)/obj/espLib.o

LIBS_47 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_47 += -lhttp
endif
LIBS_47 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_47 += -lpcre
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_47 += -lsql
endif

build/$(CONFIG)/bin/libmod_esp.so: $(DEPS_47)
	@echo '      [Link] build/$(CONFIG)/bin/libmod_esp.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libmod_esp.so $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/espLib.o" $(LIBPATHS_47) $(LIBS_47) $(LIBS_47) $(LIBS) 
endif

#
#   esp.o
#
DEPS_48 += build/$(CONFIG)/inc/me.h
DEPS_48 += build/$(CONFIG)/inc/esp.h

build/$(CONFIG)/obj/esp.o: \
    src/paks/esp/esp.c $(DEPS_48)
	@echo '   [Compile] build/$(CONFIG)/obj/esp.o'
	$(CC) -c -o build/$(CONFIG)/obj/esp.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/esp/esp.c

ifeq ($(ME_COM_ESP),1)
#
#   espcmd
#
DEPS_49 += build/$(CONFIG)/inc/mpr.h
DEPS_49 += build/$(CONFIG)/inc/me.h
DEPS_49 += build/$(CONFIG)/inc/osdep.h
DEPS_49 += build/$(CONFIG)/obj/mprLib.o
DEPS_49 += build/$(CONFIG)/bin/libmpr.so
DEPS_49 += build/$(CONFIG)/inc/pcre.h
DEPS_49 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_49 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_49 += build/$(CONFIG)/inc/http.h
DEPS_49 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_49 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_49 += build/$(CONFIG)/inc/appweb.h
DEPS_49 += build/$(CONFIG)/inc/customize.h
DEPS_49 += build/$(CONFIG)/obj/config.o
DEPS_49 += build/$(CONFIG)/obj/convenience.o
DEPS_49 += build/$(CONFIG)/obj/dirHandler.o
DEPS_49 += build/$(CONFIG)/obj/fileHandler.o
DEPS_49 += build/$(CONFIG)/obj/log.o
DEPS_49 += build/$(CONFIG)/obj/server.o
DEPS_49 += build/$(CONFIG)/bin/libappweb.so
DEPS_49 += build/$(CONFIG)/inc/esp.h
DEPS_49 += build/$(CONFIG)/obj/espLib.o
DEPS_49 += build/$(CONFIG)/bin/libmod_esp.so
DEPS_49 += build/$(CONFIG)/obj/esp.o

LIBS_49 += -lmod_esp
LIBS_49 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_49 += -lhttp
endif
LIBS_49 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_49 += -lpcre
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_49 += -lsql
endif

build/$(CONFIG)/bin/esp: $(DEPS_49)
	@echo '      [Link] build/$(CONFIG)/bin/esp'
	$(CC) -o build/$(CONFIG)/bin/esp $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/esp.o" $(LIBPATHS_49) $(LIBS_49) $(LIBS_49) $(LIBS) $(LIBS) 
endif


#
#   genslink
#
genslink: $(DEPS_50)
	( \
	cd src; \
	esp --static --genlink slink.c compile ; \
	)

#
#   http-ca-crt
#
DEPS_51 += src/paks/http/ca.crt

build/$(CONFIG)/bin/ca.crt: $(DEPS_51)
	@echo '      [Copy] build/$(CONFIG)/bin/ca.crt'
	mkdir -p "build/$(CONFIG)/bin"
	cp src/paks/http/ca.crt build/$(CONFIG)/bin/ca.crt

#
#   http.o
#
DEPS_52 += build/$(CONFIG)/inc/me.h
DEPS_52 += build/$(CONFIG)/inc/http.h

build/$(CONFIG)/obj/http.o: \
    src/paks/http/http.c $(DEPS_52)
	@echo '   [Compile] build/$(CONFIG)/obj/http.o'
	$(CC) -c -o build/$(CONFIG)/obj/http.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/http/http.c

ifeq ($(ME_COM_HTTP),1)
#
#   httpcmd
#
DEPS_53 += build/$(CONFIG)/inc/mpr.h
DEPS_53 += build/$(CONFIG)/inc/me.h
DEPS_53 += build/$(CONFIG)/inc/osdep.h
DEPS_53 += build/$(CONFIG)/obj/mprLib.o
DEPS_53 += build/$(CONFIG)/bin/libmpr.so
DEPS_53 += build/$(CONFIG)/inc/pcre.h
DEPS_53 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_53 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_53 += build/$(CONFIG)/inc/http.h
DEPS_53 += build/$(CONFIG)/obj/httpLib.o
DEPS_53 += build/$(CONFIG)/bin/libhttp.so
DEPS_53 += build/$(CONFIG)/obj/http.o

LIBS_53 += -lhttp
LIBS_53 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_53 += -lpcre
endif

build/$(CONFIG)/bin/http: $(DEPS_53)
	@echo '      [Link] build/$(CONFIG)/bin/http'
	$(CC) -o build/$(CONFIG)/bin/http $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/http.o" $(LIBPATHS_53) $(LIBS_53) $(LIBS_53) $(LIBS) $(LIBS) 
endif

#
#   est.h
#
DEPS_54 += src/paks/est/est.h

build/$(CONFIG)/inc/est.h: $(DEPS_54)
	@echo '      [Copy] build/$(CONFIG)/inc/est.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/est/est.h build/$(CONFIG)/inc/est.h

#
#   estLib.o
#
DEPS_55 += build/$(CONFIG)/inc/me.h
DEPS_55 += build/$(CONFIG)/inc/est.h
DEPS_55 += build/$(CONFIG)/inc/osdep.h

build/$(CONFIG)/obj/estLib.o: \
    src/paks/est/estLib.c $(DEPS_55)
	@echo '   [Compile] build/$(CONFIG)/obj/estLib.o'
	$(CC) -c -o build/$(CONFIG)/obj/estLib.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/est/estLib.c

ifeq ($(ME_COM_EST),1)
#
#   libest
#
DEPS_56 += build/$(CONFIG)/inc/est.h
DEPS_56 += build/$(CONFIG)/inc/me.h
DEPS_56 += build/$(CONFIG)/inc/osdep.h
DEPS_56 += build/$(CONFIG)/obj/estLib.o

build/$(CONFIG)/bin/libest.so: $(DEPS_56)
	@echo '      [Link] build/$(CONFIG)/bin/libest.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libest.so $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/estLib.o" $(LIBS) 
endif

#
#   cgiHandler.o
#
DEPS_57 += build/$(CONFIG)/inc/me.h
DEPS_57 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/cgiHandler.o: \
    src/modules/cgiHandler.c $(DEPS_57)
	@echo '   [Compile] build/$(CONFIG)/obj/cgiHandler.o'
	$(CC) -c -o build/$(CONFIG)/obj/cgiHandler.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/modules/cgiHandler.c

ifeq ($(ME_COM_CGI),1)
#
#   libmod_cgi
#
DEPS_58 += build/$(CONFIG)/inc/mpr.h
DEPS_58 += build/$(CONFIG)/inc/me.h
DEPS_58 += build/$(CONFIG)/inc/osdep.h
DEPS_58 += build/$(CONFIG)/obj/mprLib.o
DEPS_58 += build/$(CONFIG)/bin/libmpr.so
DEPS_58 += build/$(CONFIG)/inc/pcre.h
DEPS_58 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_58 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_58 += build/$(CONFIG)/inc/http.h
DEPS_58 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_58 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_58 += build/$(CONFIG)/inc/appweb.h
DEPS_58 += build/$(CONFIG)/inc/customize.h
DEPS_58 += build/$(CONFIG)/obj/config.o
DEPS_58 += build/$(CONFIG)/obj/convenience.o
DEPS_58 += build/$(CONFIG)/obj/dirHandler.o
DEPS_58 += build/$(CONFIG)/obj/fileHandler.o
DEPS_58 += build/$(CONFIG)/obj/log.o
DEPS_58 += build/$(CONFIG)/obj/server.o
DEPS_58 += build/$(CONFIG)/bin/libappweb.so
DEPS_58 += build/$(CONFIG)/obj/cgiHandler.o

LIBS_58 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_58 += -lhttp
endif
LIBS_58 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_58 += -lpcre
endif

build/$(CONFIG)/bin/libmod_cgi.so: $(DEPS_58)
	@echo '      [Link] build/$(CONFIG)/bin/libmod_cgi.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libmod_cgi.so $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/cgiHandler.o" $(LIBPATHS_58) $(LIBS_58) $(LIBS_58) $(LIBS) 
endif

#
#   ejsHandler.o
#
DEPS_59 += build/$(CONFIG)/inc/me.h
DEPS_59 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/ejsHandler.o: \
    src/modules/ejsHandler.c $(DEPS_59)
	@echo '   [Compile] build/$(CONFIG)/obj/ejsHandler.o'
	$(CC) -c -o build/$(CONFIG)/obj/ejsHandler.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/modules/ejsHandler.c

ifeq ($(ME_COM_EJS),1)
#
#   libmod_ejs
#
DEPS_60 += build/$(CONFIG)/inc/mpr.h
DEPS_60 += build/$(CONFIG)/inc/me.h
DEPS_60 += build/$(CONFIG)/inc/osdep.h
DEPS_60 += build/$(CONFIG)/obj/mprLib.o
DEPS_60 += build/$(CONFIG)/bin/libmpr.so
DEPS_60 += build/$(CONFIG)/inc/pcre.h
DEPS_60 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_60 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_60 += build/$(CONFIG)/inc/http.h
DEPS_60 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_60 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_60 += build/$(CONFIG)/inc/appweb.h
DEPS_60 += build/$(CONFIG)/inc/customize.h
DEPS_60 += build/$(CONFIG)/obj/config.o
DEPS_60 += build/$(CONFIG)/obj/convenience.o
DEPS_60 += build/$(CONFIG)/obj/dirHandler.o
DEPS_60 += build/$(CONFIG)/obj/fileHandler.o
DEPS_60 += build/$(CONFIG)/obj/log.o
DEPS_60 += build/$(CONFIG)/obj/server.o
DEPS_60 += build/$(CONFIG)/bin/libappweb.so
DEPS_60 += build/$(CONFIG)/inc/zlib.h
DEPS_60 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_60 += build/$(CONFIG)/bin/libzlib.so
endif
DEPS_60 += build/$(CONFIG)/inc/ejs.h
DEPS_60 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_60 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_60 += build/$(CONFIG)/obj/ejsLib.o
DEPS_60 += build/$(CONFIG)/bin/libejs.so
DEPS_60 += build/$(CONFIG)/obj/ejsHandler.o

LIBS_60 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_60 += -lhttp
endif
LIBS_60 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_60 += -lpcre
endif
LIBS_60 += -lejs
ifeq ($(ME_COM_ZLIB),1)
    LIBS_60 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_60 += -lsql
endif

build/$(CONFIG)/bin/libmod_ejs.so: $(DEPS_60)
	@echo '      [Link] build/$(CONFIG)/bin/libmod_ejs.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libmod_ejs.so $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/ejsHandler.o" $(LIBPATHS_60) $(LIBS_60) $(LIBS_60) $(LIBS) 
endif

#
#   phpHandler.o
#
DEPS_61 += build/$(CONFIG)/inc/me.h
DEPS_61 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/phpHandler.o: \
    src/modules/phpHandler.c $(DEPS_61)
	@echo '   [Compile] build/$(CONFIG)/obj/phpHandler.o'
	$(CC) -c -o build/$(CONFIG)/obj/phpHandler.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) "-I$(ME_COM_PHP_PATH)" "-I$(ME_COM_PHP_PATH)/main" "-I$(ME_COM_PHP_PATH)/Zend" "-I$(ME_COM_PHP_PATH)/TSRM" src/modules/phpHandler.c

ifeq ($(ME_COM_PHP),1)
#
#   libmod_php
#
DEPS_62 += build/$(CONFIG)/inc/mpr.h
DEPS_62 += build/$(CONFIG)/inc/me.h
DEPS_62 += build/$(CONFIG)/inc/osdep.h
DEPS_62 += build/$(CONFIG)/obj/mprLib.o
DEPS_62 += build/$(CONFIG)/bin/libmpr.so
DEPS_62 += build/$(CONFIG)/inc/pcre.h
DEPS_62 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_62 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_62 += build/$(CONFIG)/inc/http.h
DEPS_62 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_62 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_62 += build/$(CONFIG)/inc/appweb.h
DEPS_62 += build/$(CONFIG)/inc/customize.h
DEPS_62 += build/$(CONFIG)/obj/config.o
DEPS_62 += build/$(CONFIG)/obj/convenience.o
DEPS_62 += build/$(CONFIG)/obj/dirHandler.o
DEPS_62 += build/$(CONFIG)/obj/fileHandler.o
DEPS_62 += build/$(CONFIG)/obj/log.o
DEPS_62 += build/$(CONFIG)/obj/server.o
DEPS_62 += build/$(CONFIG)/bin/libappweb.so
DEPS_62 += build/$(CONFIG)/obj/phpHandler.o

LIBS_62 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_62 += -lhttp
endif
LIBS_62 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_62 += -lpcre
endif
LIBS_62 += -lphp5
LIBPATHS_62 += -L$(ME_COM_PHP_PATH)/libs

build/$(CONFIG)/bin/libmod_php.so: $(DEPS_62)
	@echo '      [Link] build/$(CONFIG)/bin/libmod_php.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libmod_php.so $(LDFLAGS) $(LIBPATHS)  "build/$(CONFIG)/obj/phpHandler.o" $(LIBPATHS_62) $(LIBS_62) $(LIBS_62) $(LIBS) 
endif

#
#   mprSsl.o
#
DEPS_63 += build/$(CONFIG)/inc/me.h
DEPS_63 += build/$(CONFIG)/inc/mpr.h
DEPS_63 += build/$(CONFIG)/inc/est.h

build/$(CONFIG)/obj/mprSsl.o: \
    src/paks/mpr/mprSsl.c $(DEPS_63)
	@echo '   [Compile] build/$(CONFIG)/obj/mprSsl.o'
	$(CC) -c -o build/$(CONFIG)/obj/mprSsl.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" "-I$(ME_COM_NANOSSL_PATH)/src" src/paks/mpr/mprSsl.c

#
#   libmprssl
#
DEPS_64 += build/$(CONFIG)/inc/mpr.h
DEPS_64 += build/$(CONFIG)/inc/me.h
DEPS_64 += build/$(CONFIG)/inc/osdep.h
DEPS_64 += build/$(CONFIG)/obj/mprLib.o
DEPS_64 += build/$(CONFIG)/bin/libmpr.so
DEPS_64 += build/$(CONFIG)/inc/est.h
DEPS_64 += build/$(CONFIG)/obj/estLib.o
ifeq ($(ME_COM_EST),1)
    DEPS_64 += build/$(CONFIG)/bin/libest.so
endif
DEPS_64 += build/$(CONFIG)/obj/mprSsl.o

LIBS_64 += -lmpr
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_64 += -lssl
    LIBPATHS_64 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_64 += -lcrypto
    LIBPATHS_64 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_EST),1)
    LIBS_64 += -lest
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_64 += -lmatrixssl
    LIBPATHS_64 += -L$(ME_COM_MATRIXSSL_PATH)
endif
ifeq ($(ME_COM_NANOSSL),1)
    LIBS_64 += -lssls
    LIBPATHS_64 += -L$(ME_COM_NANOSSL_PATH)/bin
endif

build/$(CONFIG)/bin/libmprssl.so: $(DEPS_64)
	@echo '      [Link] build/$(CONFIG)/bin/libmprssl.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libmprssl.so $(LDFLAGS) $(LIBPATHS)    "build/$(CONFIG)/obj/mprSsl.o" $(LIBPATHS_64) $(LIBS_64) $(LIBS_64) $(LIBS) 

#
#   sslModule.o
#
DEPS_65 += build/$(CONFIG)/inc/me.h
DEPS_65 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/sslModule.o: \
    src/modules/sslModule.c $(DEPS_65)
	@echo '   [Compile] build/$(CONFIG)/obj/sslModule.o'
	$(CC) -c -o build/$(CONFIG)/obj/sslModule.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" "-I$(ME_COM_NANOSSL_PATH)/src" src/modules/sslModule.c

ifeq ($(ME_COM_SSL),1)
#
#   libmod_ssl
#
DEPS_66 += build/$(CONFIG)/inc/mpr.h
DEPS_66 += build/$(CONFIG)/inc/me.h
DEPS_66 += build/$(CONFIG)/inc/osdep.h
DEPS_66 += build/$(CONFIG)/obj/mprLib.o
DEPS_66 += build/$(CONFIG)/bin/libmpr.so
DEPS_66 += build/$(CONFIG)/inc/pcre.h
DEPS_66 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_66 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_66 += build/$(CONFIG)/inc/http.h
DEPS_66 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_66 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_66 += build/$(CONFIG)/inc/appweb.h
DEPS_66 += build/$(CONFIG)/inc/customize.h
DEPS_66 += build/$(CONFIG)/obj/config.o
DEPS_66 += build/$(CONFIG)/obj/convenience.o
DEPS_66 += build/$(CONFIG)/obj/dirHandler.o
DEPS_66 += build/$(CONFIG)/obj/fileHandler.o
DEPS_66 += build/$(CONFIG)/obj/log.o
DEPS_66 += build/$(CONFIG)/obj/server.o
DEPS_66 += build/$(CONFIG)/bin/libappweb.so
DEPS_66 += build/$(CONFIG)/inc/est.h
DEPS_66 += build/$(CONFIG)/obj/estLib.o
ifeq ($(ME_COM_EST),1)
    DEPS_66 += build/$(CONFIG)/bin/libest.so
endif
DEPS_66 += build/$(CONFIG)/obj/mprSsl.o
DEPS_66 += build/$(CONFIG)/bin/libmprssl.so
DEPS_66 += build/$(CONFIG)/obj/sslModule.o

LIBS_66 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_66 += -lhttp
endif
LIBS_66 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_66 += -lpcre
endif
LIBS_66 += -lmprssl
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_66 += -lssl
    LIBPATHS_66 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_66 += -lcrypto
    LIBPATHS_66 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_EST),1)
    LIBS_66 += -lest
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_66 += -lmatrixssl
    LIBPATHS_66 += -L$(ME_COM_MATRIXSSL_PATH)
endif
ifeq ($(ME_COM_NANOSSL),1)
    LIBS_66 += -lssls
    LIBPATHS_66 += -L$(ME_COM_NANOSSL_PATH)/bin
endif

build/$(CONFIG)/bin/libmod_ssl.so: $(DEPS_66)
	@echo '      [Link] build/$(CONFIG)/bin/libmod_ssl.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libmod_ssl.so $(LDFLAGS) $(LIBPATHS)    "build/$(CONFIG)/obj/sslModule.o" $(LIBPATHS_66) $(LIBS_66) $(LIBS_66) $(LIBS) 
endif

#
#   sqlite3.h
#
DEPS_67 += src/paks/sqlite/sqlite3.h

build/$(CONFIG)/inc/sqlite3.h: $(DEPS_67)
	@echo '      [Copy] build/$(CONFIG)/inc/sqlite3.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/sqlite/sqlite3.h build/$(CONFIG)/inc/sqlite3.h

#
#   sqlite3.o
#
DEPS_68 += build/$(CONFIG)/inc/me.h
DEPS_68 += build/$(CONFIG)/inc/sqlite3.h

build/$(CONFIG)/obj/sqlite3.o: \
    src/paks/sqlite/sqlite3.c $(DEPS_68)
	@echo '   [Compile] build/$(CONFIG)/obj/sqlite3.o'
	$(CC) -c -o build/$(CONFIG)/obj/sqlite3.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/sqlite/sqlite3.c

ifeq ($(ME_COM_SQLITE),1)
#
#   libsql
#
DEPS_69 += build/$(CONFIG)/inc/sqlite3.h
DEPS_69 += build/$(CONFIG)/inc/me.h
DEPS_69 += build/$(CONFIG)/obj/sqlite3.o

build/$(CONFIG)/bin/libsql.so: $(DEPS_69)
	@echo '      [Link] build/$(CONFIG)/bin/libsql.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libsql.so $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/sqlite3.o" $(LIBS) 
endif

#
#   manager.o
#
DEPS_70 += build/$(CONFIG)/inc/me.h
DEPS_70 += build/$(CONFIG)/inc/mpr.h

build/$(CONFIG)/obj/manager.o: \
    src/paks/mpr/manager.c $(DEPS_70)
	@echo '   [Compile] build/$(CONFIG)/obj/manager.o'
	$(CC) -c -o build/$(CONFIG)/obj/manager.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/mpr/manager.c

#
#   manager
#
DEPS_71 += build/$(CONFIG)/inc/mpr.h
DEPS_71 += build/$(CONFIG)/inc/me.h
DEPS_71 += build/$(CONFIG)/inc/osdep.h
DEPS_71 += build/$(CONFIG)/obj/mprLib.o
DEPS_71 += build/$(CONFIG)/bin/libmpr.so
DEPS_71 += build/$(CONFIG)/obj/manager.o

LIBS_71 += -lmpr

build/$(CONFIG)/bin/appman: $(DEPS_71)
	@echo '      [Link] build/$(CONFIG)/bin/appman'
	$(CC) -o build/$(CONFIG)/bin/appman $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/manager.o" $(LIBPATHS_71) $(LIBS_71) $(LIBS_71) $(LIBS) $(LIBS) 

#
#   server-cache
#
src/server/cache: $(DEPS_72)
	( \
	cd src/server; \
	mkdir -p cache ; \
	)

#
#   sqlite.o
#
DEPS_73 += build/$(CONFIG)/inc/me.h
DEPS_73 += build/$(CONFIG)/inc/sqlite3.h

build/$(CONFIG)/obj/sqlite.o: \
    src/paks/sqlite/sqlite.c $(DEPS_73)
	@echo '   [Compile] build/$(CONFIG)/obj/sqlite.o'
	$(CC) -c -o build/$(CONFIG)/obj/sqlite.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/sqlite/sqlite.c

ifeq ($(ME_COM_SQLITE),1)
#
#   sqliteshell
#
DEPS_74 += build/$(CONFIG)/inc/sqlite3.h
DEPS_74 += build/$(CONFIG)/inc/me.h
DEPS_74 += build/$(CONFIG)/obj/sqlite3.o
DEPS_74 += build/$(CONFIG)/bin/libsql.so
DEPS_74 += build/$(CONFIG)/obj/sqlite.o

LIBS_74 += -lsql

build/$(CONFIG)/bin/sqlite: $(DEPS_74)
	@echo '      [Link] build/$(CONFIG)/bin/sqlite'
	$(CC) -o build/$(CONFIG)/bin/sqlite $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/sqlite.o" $(LIBPATHS_74) $(LIBS_74) $(LIBS_74) $(LIBS) $(LIBS) 
endif

#
#   testAppweb.h
#
DEPS_75 += test/src/testAppweb.h

build/$(CONFIG)/inc/testAppweb.h: $(DEPS_75)
	@echo '      [Copy] build/$(CONFIG)/inc/testAppweb.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp test/src/testAppweb.h build/$(CONFIG)/inc/testAppweb.h

#
#   testAppweb.o
#
DEPS_76 += build/$(CONFIG)/inc/me.h
DEPS_76 += build/$(CONFIG)/inc/testAppweb.h
DEPS_76 += build/$(CONFIG)/inc/mpr.h
DEPS_76 += build/$(CONFIG)/inc/http.h

build/$(CONFIG)/obj/testAppweb.o: \
    test/src/testAppweb.c $(DEPS_76)
	@echo '   [Compile] build/$(CONFIG)/obj/testAppweb.o'
	$(CC) -c -o build/$(CONFIG)/obj/testAppweb.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) test/src/testAppweb.c

#
#   testHttp.o
#
DEPS_77 += build/$(CONFIG)/inc/me.h
DEPS_77 += build/$(CONFIG)/inc/testAppweb.h

build/$(CONFIG)/obj/testHttp.o: \
    test/src/testHttp.c $(DEPS_77)
	@echo '   [Compile] build/$(CONFIG)/obj/testHttp.o'
	$(CC) -c -o build/$(CONFIG)/obj/testHttp.o $(LDFLAGS) $(CFLAGS) $(DFLAGS) $(IFLAGS) test/src/testHttp.c

#
#   testAppweb
#
DEPS_78 += build/$(CONFIG)/inc/mpr.h
DEPS_78 += build/$(CONFIG)/inc/me.h
DEPS_78 += build/$(CONFIG)/inc/osdep.h
DEPS_78 += build/$(CONFIG)/obj/mprLib.o
DEPS_78 += build/$(CONFIG)/bin/libmpr.so
DEPS_78 += build/$(CONFIG)/inc/pcre.h
DEPS_78 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_78 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_78 += build/$(CONFIG)/inc/http.h
DEPS_78 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_78 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_78 += build/$(CONFIG)/inc/appweb.h
DEPS_78 += build/$(CONFIG)/inc/customize.h
DEPS_78 += build/$(CONFIG)/obj/config.o
DEPS_78 += build/$(CONFIG)/obj/convenience.o
DEPS_78 += build/$(CONFIG)/obj/dirHandler.o
DEPS_78 += build/$(CONFIG)/obj/fileHandler.o
DEPS_78 += build/$(CONFIG)/obj/log.o
DEPS_78 += build/$(CONFIG)/obj/server.o
DEPS_78 += build/$(CONFIG)/bin/libappweb.so
DEPS_78 += build/$(CONFIG)/inc/testAppweb.h
DEPS_78 += build/$(CONFIG)/obj/testAppweb.o
DEPS_78 += build/$(CONFIG)/obj/testHttp.o

LIBS_78 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_78 += -lhttp
endif
LIBS_78 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_78 += -lpcre
endif

build/$(CONFIG)/bin/testAppweb: $(DEPS_78)
	@echo '      [Link] build/$(CONFIG)/bin/testAppweb'
	$(CC) -o build/$(CONFIG)/bin/testAppweb $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/testAppweb.o" "build/$(CONFIG)/obj/testHttp.o" $(LIBPATHS_78) $(LIBS_78) $(LIBS_78) $(LIBS) $(LIBS) 

ifeq ($(ME_COM_CGI),1)
#
#   test-basic.cgi
#
DEPS_79 += build/$(CONFIG)/inc/mpr.h
DEPS_79 += build/$(CONFIG)/inc/me.h
DEPS_79 += build/$(CONFIG)/inc/osdep.h
DEPS_79 += build/$(CONFIG)/obj/mprLib.o
DEPS_79 += build/$(CONFIG)/bin/libmpr.so
DEPS_79 += build/$(CONFIG)/inc/pcre.h
DEPS_79 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_79 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_79 += build/$(CONFIG)/inc/http.h
DEPS_79 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_79 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_79 += build/$(CONFIG)/inc/appweb.h
DEPS_79 += build/$(CONFIG)/inc/customize.h
DEPS_79 += build/$(CONFIG)/obj/config.o
DEPS_79 += build/$(CONFIG)/obj/convenience.o
DEPS_79 += build/$(CONFIG)/obj/dirHandler.o
DEPS_79 += build/$(CONFIG)/obj/fileHandler.o
DEPS_79 += build/$(CONFIG)/obj/log.o
DEPS_79 += build/$(CONFIG)/obj/server.o
DEPS_79 += build/$(CONFIG)/bin/libappweb.so
DEPS_79 += build/$(CONFIG)/inc/testAppweb.h
DEPS_79 += build/$(CONFIG)/obj/testAppweb.o
DEPS_79 += build/$(CONFIG)/obj/testHttp.o
DEPS_79 += build/$(CONFIG)/bin/testAppweb

test/web/auth/basic/basic.cgi: $(DEPS_79)
	( \
	cd test; \
	echo "#!`type -p ejs`" >web/auth/basic/basic.cgi ; \
	echo 'print("HTTP/1.0 200 OK\nContent-Type: text/plain\n\n" + serialize(App.env, {pretty: true}) + "\n")' >>web/auth/basic/basic.cgi ; \
	chmod +x web/auth/basic/basic.cgi ; \
	)
endif

ifeq ($(ME_COM_CGI),1)
#
#   test-cache.cgi
#
DEPS_80 += build/$(CONFIG)/inc/mpr.h
DEPS_80 += build/$(CONFIG)/inc/me.h
DEPS_80 += build/$(CONFIG)/inc/osdep.h
DEPS_80 += build/$(CONFIG)/obj/mprLib.o
DEPS_80 += build/$(CONFIG)/bin/libmpr.so
DEPS_80 += build/$(CONFIG)/inc/pcre.h
DEPS_80 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_80 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_80 += build/$(CONFIG)/inc/http.h
DEPS_80 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_80 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_80 += build/$(CONFIG)/inc/appweb.h
DEPS_80 += build/$(CONFIG)/inc/customize.h
DEPS_80 += build/$(CONFIG)/obj/config.o
DEPS_80 += build/$(CONFIG)/obj/convenience.o
DEPS_80 += build/$(CONFIG)/obj/dirHandler.o
DEPS_80 += build/$(CONFIG)/obj/fileHandler.o
DEPS_80 += build/$(CONFIG)/obj/log.o
DEPS_80 += build/$(CONFIG)/obj/server.o
DEPS_80 += build/$(CONFIG)/bin/libappweb.so
DEPS_80 += build/$(CONFIG)/inc/testAppweb.h
DEPS_80 += build/$(CONFIG)/obj/testAppweb.o
DEPS_80 += build/$(CONFIG)/obj/testHttp.o
DEPS_80 += build/$(CONFIG)/bin/testAppweb

test/web/caching/cache.cgi: $(DEPS_80)
	( \
	cd test; \
	echo "#!`type -p ejs`" >web/caching/cache.cgi ; \
	echo 'print("HTTP/1.0 200 OK\nContent-Type: text/plain\n\n{number:" + Date().now() + "}\n")' >>web/caching/cache.cgi ; \
	chmod +x web/caching/cache.cgi ; \
	)
endif

ifeq ($(ME_COM_CGI),1)
#
#   test-cgiProgram
#
DEPS_81 += build/$(CONFIG)/inc/me.h
DEPS_81 += build/$(CONFIG)/obj/cgiProgram.o
DEPS_81 += build/$(CONFIG)/bin/cgiProgram

test/cgi-bin/cgiProgram: $(DEPS_81)
	( \
	cd test; \
	cp ../build/$(CONFIG)/bin/cgiProgram cgi-bin/cgiProgram ; \
	cp ../build/$(CONFIG)/bin/cgiProgram cgi-bin/nph-cgiProgram ; \
	cp ../build/$(CONFIG)/bin/cgiProgram 'cgi-bin/cgi Program' ; \
	cp ../build/$(CONFIG)/bin/cgiProgram web/cgiProgram.cgi ; \
	chmod +x cgi-bin/* web/cgiProgram.cgi ; \
	)
endif

ifeq ($(ME_COM_CGI),1)
#
#   test-testScript
#
DEPS_82 += build/$(CONFIG)/inc/mpr.h
DEPS_82 += build/$(CONFIG)/inc/me.h
DEPS_82 += build/$(CONFIG)/inc/osdep.h
DEPS_82 += build/$(CONFIG)/obj/mprLib.o
DEPS_82 += build/$(CONFIG)/bin/libmpr.so
DEPS_82 += build/$(CONFIG)/inc/pcre.h
DEPS_82 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_82 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_82 += build/$(CONFIG)/inc/http.h
DEPS_82 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_82 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_82 += build/$(CONFIG)/inc/appweb.h
DEPS_82 += build/$(CONFIG)/inc/customize.h
DEPS_82 += build/$(CONFIG)/obj/config.o
DEPS_82 += build/$(CONFIG)/obj/convenience.o
DEPS_82 += build/$(CONFIG)/obj/dirHandler.o
DEPS_82 += build/$(CONFIG)/obj/fileHandler.o
DEPS_82 += build/$(CONFIG)/obj/log.o
DEPS_82 += build/$(CONFIG)/obj/server.o
DEPS_82 += build/$(CONFIG)/bin/libappweb.so
DEPS_82 += build/$(CONFIG)/inc/testAppweb.h
DEPS_82 += build/$(CONFIG)/obj/testAppweb.o
DEPS_82 += build/$(CONFIG)/obj/testHttp.o
DEPS_82 += build/$(CONFIG)/bin/testAppweb

test/cgi-bin/testScript: $(DEPS_82)
	( \
	cd test; \
	echo '#!../build/$(CONFIG)/bin/cgiProgram' >cgi-bin/testScript ; chmod +x cgi-bin/testScript ; \
	)
endif


#
#   stop
#
DEPS_83 += compile

stop: $(DEPS_83)
	( \
	cd .; \
	@./build/$(CONFIG)/bin/appman stop disable uninstall >/dev/null 2>&1 ; true ; \
	)

#
#   installBinary
#
installBinary: $(DEPS_84)
	( \
	cd .; \
	mkdir -p "$(ME_APP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	ln -s "4.6.4" "$(ME_APP_PREFIX)/latest" ; \
	mkdir -p "$(ME_LOG_PREFIX)" ; \
	chmod 755 "$(ME_LOG_PREFIX)" ; \
	[ `id -u` = 0 ] && chown $(WEB_USER):$(WEB_GROUP) "$(ME_LOG_PREFIX)"; true ; \
	mkdir -p "$(ME_CACHE_PREFIX)" ; \
	chmod 755 "$(ME_CACHE_PREFIX)" ; \
	[ `id -u` = 0 ] && chown $(WEB_USER):$(WEB_GROUP) "$(ME_CACHE_PREFIX)"; true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp build/$(CONFIG)/bin/appweb $(ME_VAPP_PREFIX)/bin/appweb ; \
	mkdir -p "$(ME_BIN_PREFIX)" ; \
	rm -f "$(ME_BIN_PREFIX)/appweb" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/appweb" "$(ME_BIN_PREFIX)/appweb" ; \
	cp build/$(CONFIG)/bin/appman $(ME_VAPP_PREFIX)/bin/appman ; \
	rm -f "$(ME_BIN_PREFIX)/appman" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/appman" "$(ME_BIN_PREFIX)/appman" ; \
	cp build/$(CONFIG)/bin/http $(ME_VAPP_PREFIX)/bin/http ; \
	rm -f "$(ME_BIN_PREFIX)/http" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/http" "$(ME_BIN_PREFIX)/http" ; \
	if [ "$(ME_COM_ESP)" = 1 ]; then true ; \
	cp build/$(CONFIG)/bin/esp $(ME_VAPP_PREFIX)/bin/appesp ; \
	rm -f "$(ME_BIN_PREFIX)/appesp" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/appesp" "$(ME_BIN_PREFIX)/appesp" ; \
	fi ; \
	cp build/$(CONFIG)/bin/libappweb.so $(ME_VAPP_PREFIX)/bin/libappweb.so ; \
	cp build/$(CONFIG)/bin/libhttp.so $(ME_VAPP_PREFIX)/bin/libhttp.so ; \
	cp build/$(CONFIG)/bin/libmpr.so $(ME_VAPP_PREFIX)/bin/libmpr.so ; \
	cp build/$(CONFIG)/bin/libpcre.so $(ME_VAPP_PREFIX)/bin/libpcre.so ; \
	cp build/$(CONFIG)/bin/libslink.so $(ME_VAPP_PREFIX)/bin/libslink.so ; \
	if [ "$(ME_COM_SSL)" = 1 ]; then true ; \
	cp build/$(CONFIG)/bin/libmprssl.so $(ME_VAPP_PREFIX)/bin/libmprssl.so ; \
	cp build/$(CONFIG)/bin/libmod_ssl.so $(ME_VAPP_PREFIX)/bin/libmod_ssl.so ; \
	fi ; \
	if [ "$(ME_COM_SSL)" = 1 ]; then true ; \
	cp src/paks/est/ca.crt $(ME_VAPP_PREFIX)/bin/ca.crt ; \
	fi ; \
	if [ "$(ME_COM_OPENSSL)" = 1 ]; then true ; \
	cp build/$(CONFIG)/bin/libssl*.so* $(ME_VAPP_PREFIX)/bin/libssl*.so* ; \
	cp build/$(CONFIG)/bin/libcrypto*.so* $(ME_VAPP_PREFIX)/bin/libcrypto*.so* ; \
	fi ; \
	if [ "$(ME_COM_EST)" = 1 ]; then true ; \
	cp build/$(CONFIG)/bin/libest.so $(ME_VAPP_PREFIX)/bin/libest.so ; \
	fi ; \
	if [ "$(ME_COM_SQLITE)" = 1 ]; then true ; \
	cp build/$(CONFIG)/bin/libsql.so $(ME_VAPP_PREFIX)/bin/libsql.so ; \
	fi ; \
	if [ "$(ME_COM_ESP)" = 1 ]; then true ; \
	cp build/$(CONFIG)/bin/libmod_esp.so $(ME_VAPP_PREFIX)/bin/libmod_esp.so ; \
	fi ; \
	if [ "$(ME_COM_CGI)" = 1 ]; then true ; \
	cp build/$(CONFIG)/bin/libmod_cgi.so $(ME_VAPP_PREFIX)/bin/libmod_cgi.so ; \
	fi ; \
	if [ "$(ME_COM_EJS)" = 1 ]; then true ; \
	cp build/$(CONFIG)/bin/libejs.so $(ME_VAPP_PREFIX)/bin/libejs.so ; \
	cp build/$(CONFIG)/bin/libmod_ejs.so $(ME_VAPP_PREFIX)/bin/libmod_ejs.so ; \
	cp build/$(CONFIG)/bin/libzlib.so $(ME_VAPP_PREFIX)/bin/libzlib.so ; \
	fi ; \
	if [ "$(ME_COM_PHP)" = 1 ]; then true ; \
	cp build/$(CONFIG)/bin/libmod_php.so $(ME_VAPP_PREFIX)/bin/libmod_php.so ; \
	fi ; \
	if [ "$(ME_COM_PHP)" = 1 ]; then true ; \
	cp build/$(CONFIG)/bin/libphp5.so $(ME_VAPP_PREFIX)/bin/libphp5.so ; \
	fi ; \
	if [ "$(ME_COM_ESP)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/angular/1.2.6" ; \
	cp src/paks/angular/angular-animate.js $(ME_VAPP_PREFIX)/esp/angular/1.2.6/angular-animate.js ; \
	cp src/paks/angular/angular-csp.css $(ME_VAPP_PREFIX)/esp/angular/1.2.6/angular-csp.css ; \
	cp src/paks/angular/angular-route.js $(ME_VAPP_PREFIX)/esp/angular/1.2.6/angular-route.js ; \
	cp src/paks/angular/angular.js $(ME_VAPP_PREFIX)/esp/angular/1.2.6/angular.js ; \
	cp src/paks/angular/package.json $(ME_VAPP_PREFIX)/esp/angular/1.2.6/package.json ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.4" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.4/client" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.4/client/assets" ; \
	cp src/paks/esp-html-mvc/client/assets/favicon.ico $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.4/client/assets/favicon.ico ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.4/client/css" ; \
	cp src/paks/esp-html-mvc/client/css/all.css $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.4/client/css/all.css ; \
	cp src/paks/esp-html-mvc/client/css/all.less $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.4/client/css/all.less ; \
	cp src/paks/esp-html-mvc/client/index.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.4/client/index.esp ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.4/css" ; \
	cp src/paks/esp-html-mvc/css/app.less $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.4/css/app.less ; \
	cp src/paks/esp-html-mvc/css/theme.less $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.4/css/theme.less ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.4/generate" ; \
	cp src/paks/esp-html-mvc/generate/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.4/generate/appweb.conf ; \
	cp src/paks/esp-html-mvc/generate/controller.c $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.4/generate/controller.c ; \
	cp src/paks/esp-html-mvc/generate/controllerSingleton.c $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.4/generate/controllerSingleton.c ; \
	cp src/paks/esp-html-mvc/generate/edit.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.4/generate/edit.esp ; \
	cp src/paks/esp-html-mvc/generate/list.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.4/generate/list.esp ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.4/layouts" ; \
	cp src/paks/esp-html-mvc/layouts/default.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.4/layouts/default.esp ; \
	cp src/paks/esp-html-mvc/package.json $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.4/package.json ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.4" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.4/generate" ; \
	cp src/paks/esp-legacy-mvc/generate/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.4/generate/appweb.conf ; \
	cp src/paks/esp-legacy-mvc/generate/controller.c $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.4/generate/controller.c ; \
	cp src/paks/esp-legacy-mvc/generate/edit.esp $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.4/generate/edit.esp ; \
	cp src/paks/esp-legacy-mvc/generate/list.esp $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.4/generate/list.esp ; \
	cp src/paks/esp-legacy-mvc/generate/migration.c $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.4/generate/migration.c ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.4/generate/src" ; \
	cp src/paks/esp-legacy-mvc/generate/src/app.c $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.4/generate/src/app.c ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.4/layouts" ; \
	cp src/paks/esp-legacy-mvc/layouts/default.esp $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.4/layouts/default.esp ; \
	cp src/paks/esp-legacy-mvc/package.json $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.4/package.json ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.4/static" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.4/static/css" ; \
	cp src/paks/esp-legacy-mvc/static/css/all.css $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.4/static/css/all.css ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.4/static/images" ; \
	cp src/paks/esp-legacy-mvc/static/images/banner.jpg $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.4/static/images/banner.jpg ; \
	cp src/paks/esp-legacy-mvc/static/images/favicon.ico $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.4/static/images/favicon.ico ; \
	cp src/paks/esp-legacy-mvc/static/images/splash.jpg $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.4/static/images/splash.jpg ; \
	cp src/paks/esp-legacy-mvc/static/index.esp $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.4/static/index.esp ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.4/static/js" ; \
	cp src/paks/esp-legacy-mvc/static/js/jquery.esp.js $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.4/static/js/jquery.esp.js ; \
	cp src/paks/esp-legacy-mvc/static/js/jquery.js $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.4/static/js/jquery.js ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-mvc/4.6.4" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-mvc/4.6.4/generate" ; \
	cp src/paks/esp-mvc/generate/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-mvc/4.6.4/generate/appweb.conf ; \
	cp src/paks/esp-mvc/generate/controller.c $(ME_VAPP_PREFIX)/esp/esp-mvc/4.6.4/generate/controller.c ; \
	cp src/paks/esp-mvc/generate/migration.c $(ME_VAPP_PREFIX)/esp/esp-mvc/4.6.4/generate/migration.c ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-mvc/4.6.4/generate/src" ; \
	cp src/paks/esp-mvc/generate/src/app.c $(ME_VAPP_PREFIX)/esp/esp-mvc/4.6.4/generate/src/app.c ; \
	cp src/paks/esp-mvc/LICENSE.md $(ME_VAPP_PREFIX)/esp/esp-mvc/4.6.4/LICENSE.md ; \
	cp src/paks/esp-mvc/package.json $(ME_VAPP_PREFIX)/esp/esp-mvc/4.6.4/package.json ; \
	cp src/paks/esp-mvc/README.md $(ME_VAPP_PREFIX)/esp/esp-mvc/4.6.4/README.md ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-server/4.6.4" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-server/4.6.4/generate" ; \
	cp src/paks/esp-server/generate/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-server/4.6.4/generate/appweb.conf ; \
	cp src/paks/esp-server/package.json $(ME_VAPP_PREFIX)/esp/esp-server/4.6.4/package.json ; \
	fi ; \
	if [ "$(ME_COM_ESP)" = 1 ]; then true ; \
	cp build/$(CONFIG)/bin/esp.conf $(ME_VAPP_PREFIX)/bin/esp.conf ; \
	fi ; \
	mkdir -p "$(ME_WEB_PREFIX)/bench" ; \
	cp src/server/web/bench/1b.html $(ME_WEB_PREFIX)/bench/1b.html ; \
	cp src/server/web/bench/4k.html $(ME_WEB_PREFIX)/bench/4k.html ; \
	cp src/server/web/bench/64k.html $(ME_WEB_PREFIX)/bench/64k.html ; \
	mkdir -p "$(ME_WEB_PREFIX)" ; \
	cp src/server/web/favicon.ico $(ME_WEB_PREFIX)/favicon.ico ; \
	mkdir -p "$(ME_WEB_PREFIX)/icons" ; \
	cp src/server/web/icons/back.gif $(ME_WEB_PREFIX)/icons/back.gif ; \
	cp src/server/web/icons/blank.gif $(ME_WEB_PREFIX)/icons/blank.gif ; \
	cp src/server/web/icons/compressed.gif $(ME_WEB_PREFIX)/icons/compressed.gif ; \
	cp src/server/web/icons/folder.gif $(ME_WEB_PREFIX)/icons/folder.gif ; \
	cp src/server/web/icons/parent.gif $(ME_WEB_PREFIX)/icons/parent.gif ; \
	cp src/server/web/icons/space.gif $(ME_WEB_PREFIX)/icons/space.gif ; \
	cp src/server/web/icons/text.gif $(ME_WEB_PREFIX)/icons/text.gif ; \
	cp src/server/web/iehacks.css $(ME_WEB_PREFIX)/iehacks.css ; \
	mkdir -p "$(ME_WEB_PREFIX)/images" ; \
	cp src/server/web/images/banner.jpg $(ME_WEB_PREFIX)/images/banner.jpg ; \
	cp src/server/web/images/bottomShadow.jpg $(ME_WEB_PREFIX)/images/bottomShadow.jpg ; \
	cp src/server/web/images/shadow.jpg $(ME_WEB_PREFIX)/images/shadow.jpg ; \
	cp src/server/web/index.html $(ME_WEB_PREFIX)/index.html ; \
	cp src/server/web/min-index.html $(ME_WEB_PREFIX)/min-index.html ; \
	cp src/server/web/print.css $(ME_WEB_PREFIX)/print.css ; \
	cp src/server/web/screen.css $(ME_WEB_PREFIX)/screen.css ; \
	mkdir -p "$(ME_WEB_PREFIX)/test" ; \
	cp src/server/web/test/bench.html $(ME_WEB_PREFIX)/test/bench.html ; \
	cp src/server/web/test/test.cgi $(ME_WEB_PREFIX)/test/test.cgi ; \
	cp src/server/web/test/test.ejs $(ME_WEB_PREFIX)/test/test.ejs ; \
	cp src/server/web/test/test.esp $(ME_WEB_PREFIX)/test/test.esp ; \
	cp src/server/web/test/test.html $(ME_WEB_PREFIX)/test/test.html ; \
	cp src/server/web/test/test.php $(ME_WEB_PREFIX)/test/test.php ; \
	cp src/server/web/test/test.pl $(ME_WEB_PREFIX)/test/test.pl ; \
	cp src/server/web/test/test.py $(ME_WEB_PREFIX)/test/test.py ; \
	mkdir -p "$(ME_WEB_PREFIX)/test" ; \
	cp src/server/web/test/test.cgi $(ME_WEB_PREFIX)/test/test.cgi ; \
	chmod 755 "$(ME_WEB_PREFIX)/test/test.cgi" ; \
	cp src/server/web/test/test.pl $(ME_WEB_PREFIX)/test/test.pl ; \
	chmod 755 "$(ME_WEB_PREFIX)/test/test.pl" ; \
	cp src/server/web/test/test.py $(ME_WEB_PREFIX)/test/test.py ; \
	chmod 755 "$(ME_WEB_PREFIX)/test/test.py" ; \
	mkdir -p "$(ME_ETC_PREFIX)" ; \
	cp src/server/mime.types $(ME_ETC_PREFIX)/mime.types ; \
	cp src/server/self.crt $(ME_ETC_PREFIX)/self.crt ; \
	cp src/server/self.key $(ME_ETC_PREFIX)/self.key ; \
	if [ "$(ME_COM_PHP)" = 1 ]; then true ; \
	cp src/server/php.ini $(ME_ETC_PREFIX)/php.ini ; \
	fi ; \
	cp src/server/appweb.conf $(ME_ETC_PREFIX)/appweb.conf ; \
	cp src/server/sample.conf $(ME_ETC_PREFIX)/sample.conf ; \
	cp src/server/self.crt $(ME_ETC_PREFIX)/self.crt ; \
	cp src/server/self.key $(ME_ETC_PREFIX)/self.key ; \
	echo 'set LOG_DIR "$(ME_LOG_PREFIX)"\nset CACHE_DIR "$(ME_CACHE_PREFIX)"\nDocuments "$(ME_WEB_PREFIX)\nListen 80\n<if SSL_MODULE>\nListenSecure 443\n</if>\n' >$(ME_ETC_PREFIX)/install.conf ; \
	mkdir -p "$(ME_VAPP_PREFIX)/inc" ; \
	cp build/$(CONFIG)/inc/me.h $(ME_VAPP_PREFIX)/inc/me.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/me.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/me.h" "$(ME_INC_PREFIX)/appweb/me.h" ; \
	cp src/paks/osdep/osdep.h $(ME_VAPP_PREFIX)/inc/osdep.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/osdep.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/osdep.h" "$(ME_INC_PREFIX)/appweb/osdep.h" ; \
	cp src/appweb.h $(ME_VAPP_PREFIX)/inc/appweb.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/appweb.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/appweb.h" "$(ME_INC_PREFIX)/appweb/appweb.h" ; \
	cp src/customize.h $(ME_VAPP_PREFIX)/inc/customize.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/customize.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/customize.h" "$(ME_INC_PREFIX)/appweb/customize.h" ; \
	cp src/paks/est/est.h $(ME_VAPP_PREFIX)/inc/est.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/est.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/est.h" "$(ME_INC_PREFIX)/appweb/est.h" ; \
	cp src/paks/http/http.h $(ME_VAPP_PREFIX)/inc/http.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/http.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/http.h" "$(ME_INC_PREFIX)/appweb/http.h" ; \
	cp src/paks/mpr/mpr.h $(ME_VAPP_PREFIX)/inc/mpr.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/mpr.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/mpr.h" "$(ME_INC_PREFIX)/appweb/mpr.h" ; \
	cp src/paks/pcre/pcre.h $(ME_VAPP_PREFIX)/inc/pcre.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/pcre.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/pcre.h" "$(ME_INC_PREFIX)/appweb/pcre.h" ; \
	cp src/paks/sqlite/sqlite3.h $(ME_VAPP_PREFIX)/inc/sqlite3.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/sqlite3.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/sqlite3.h" "$(ME_INC_PREFIX)/appweb/sqlite3.h" ; \
	if [ "$(ME_COM_ESP)" = 1 ]; then true ; \
	cp src/paks/esp/esp.h $(ME_VAPP_PREFIX)/inc/esp.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/esp.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/esp.h" "$(ME_INC_PREFIX)/appweb/esp.h" ; \
	fi ; \
	if [ "$(ME_COM_EJS)" = 1 ]; then true ; \
	cp src/paks/ejs/ejs.h $(ME_VAPP_PREFIX)/inc/ejs.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/ejs.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/ejs.h" "$(ME_INC_PREFIX)/appweb/ejs.h" ; \
	cp src/paks/ejs/ejs.slots.h $(ME_VAPP_PREFIX)/inc/ejs.slots.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/ejs.slots.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/ejs.slots.h" "$(ME_INC_PREFIX)/appweb/ejs.slots.h" ; \
	cp src/paks/ejs/ejsByteGoto.h $(ME_VAPP_PREFIX)/inc/ejsByteGoto.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/ejsByteGoto.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/ejsByteGoto.h" "$(ME_INC_PREFIX)/appweb/ejsByteGoto.h" ; \
	fi ; \
	if [ "$(ME_COM_EJS)" = 1 ]; then true ; \
	cp build/$(CONFIG)/bin/ejs.mod $(ME_VAPP_PREFIX)/bin/ejs.mod ; \
	fi ; \
	mkdir -p "$(ME_VAPP_PREFIX)/doc/man1" ; \
	cp doc/man/appman.1 $(ME_VAPP_PREFIX)/doc/man1/appman.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/appman.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/appman.1" "$(ME_MAN_PREFIX)/man1/appman.1" ; \
	cp doc/man/appweb.1 $(ME_VAPP_PREFIX)/doc/man1/appweb.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/appweb.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/appweb.1" "$(ME_MAN_PREFIX)/man1/appweb.1" ; \
	cp doc/man/appwebMonitor.1 $(ME_VAPP_PREFIX)/doc/man1/appwebMonitor.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/appwebMonitor.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/appwebMonitor.1" "$(ME_MAN_PREFIX)/man1/appwebMonitor.1" ; \
	cp doc/man/authpass.1 $(ME_VAPP_PREFIX)/doc/man1/authpass.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/authpass.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/authpass.1" "$(ME_MAN_PREFIX)/man1/authpass.1" ; \
	cp doc/man/esp.1 $(ME_VAPP_PREFIX)/doc/man1/esp.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/esp.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/esp.1" "$(ME_MAN_PREFIX)/man1/esp.1" ; \
	cp doc/man/http.1 $(ME_VAPP_PREFIX)/doc/man1/http.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/http.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/http.1" "$(ME_MAN_PREFIX)/man1/http.1" ; \
	cp doc/man/makerom.1 $(ME_VAPP_PREFIX)/doc/man1/makerom.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/makerom.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/makerom.1" "$(ME_MAN_PREFIX)/man1/makerom.1" ; \
	cp doc/man/manager.1 $(ME_VAPP_PREFIX)/doc/man1/manager.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/manager.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/manager.1" "$(ME_MAN_PREFIX)/man1/manager.1" ; \
	)

#
#   start
#
DEPS_85 += compile
DEPS_85 += stop

start: $(DEPS_85)
	( \
	cd .; \
	./build/$(CONFIG)/bin/appman install enable start ; \
	)

#
#   install
#
DEPS_86 += compile
DEPS_86 += stop
DEPS_86 += installBinary
DEPS_86 += start

install: $(DEPS_86)

#
#   run
#
DEPS_87 += compile

run: $(DEPS_87)
	( \
	cd src/server; \
	sudo ../../build/$(CONFIG)/bin/appweb -v ; \
	)


#
#   uninstall
#
DEPS_88 += build
DEPS_88 += compile
DEPS_88 += stop

uninstall: $(DEPS_88)
	( \
	cd package; \
	rm -f "$(ME_ETC_PREFIX)/appweb.conf" ; \
	rm -f "$(ME_ETC_PREFIX)/esp.conf" ; \
	rm -f "$(ME_ETC_PREFIX)/mine.types" ; \
	rm -f "$(ME_ETC_PREFIX)/install.conf" ; \
	rm -fr "$(ME_INC_PREFIX)/appweb" ; \
	rm -fr "$(ME_WEB_PREFIX)" ; \
	rm -fr "$(ME_SPOOL_PREFIX)" ; \
	rm -fr "$(ME_CACHE_PREFIX)" ; \
	rm -fr "$(ME_LOG_PREFIX)" ; \
	rm -fr "$(ME_VAPP_PREFIX)" ; \
	rmdir -p "$(ME_ETC_PREFIX)" 2>/dev/null ; true ; \
	rmdir -p "$(ME_WEB_PREFIX)" 2>/dev/null ; true ; \
	rmdir -p "$(ME_LOG_PREFIX)" 2>/dev/null ; true ; \
	rmdir -p "$(ME_SPOOL_PREFIX)" 2>/dev/null ; true ; \
	rmdir -p "$(ME_CACHE_PREFIX)" 2>/dev/null ; true ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	rmdir -p "$(ME_APP_PREFIX)" 2>/dev/null ; true ; \
	)

#
#   version
#
version: $(DEPS_89)
	echo 4.6.4

