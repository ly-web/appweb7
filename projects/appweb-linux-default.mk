#
#   appweb-linux-default.mk -- Makefile to build Embedthis Appweb for linux
#

NAME                  := appweb
VERSION               := 5.2.0
PROFILE               ?= default
ARCH                  ?= $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/')
CC_ARCH               ?= $(shell echo $(ARCH) | sed 's/x86/i686/;s/x64/x86_64/')
OS                    ?= linux
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
ME_COM_OSDEP          ?= 1
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
DFLAGS                += -D_REENTRANT -DPIC $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_CGI=$(ME_COM_CGI) -DME_COM_DIR=$(ME_COM_DIR) -DME_COM_EJS=$(ME_COM_EJS) -DME_COM_ESP=$(ME_COM_ESP) -DME_COM_EST=$(ME_COM_EST) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_MATRIXSSL=$(ME_COM_MATRIXSSL) -DME_COM_MDB=$(ME_COM_MDB) -DME_COM_NANOSSL=$(ME_COM_NANOSSL) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_OSDEP=$(ME_COM_OSDEP) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_PHP=$(ME_COM_PHP) -DME_COM_SQLITE=$(ME_COM_SQLITE) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_VXWORKS=$(ME_COM_VXWORKS) -DME_COM_WINSDK=$(ME_COM_WINSDK) -DME_COM_ZLIB=$(ME_COM_ZLIB) 
IFLAGS                += "-Ibuild/$(CONFIG)/inc"
LDFLAGS               += '-rdynamic' '-Wl,--enable-new-dtags' '-Wl,-rpath,$$ORIGIN/'
LIBPATHS              += -Lbuild/$(CONFIG)/bin
LIBS                  += -lrt -ldl -lpthread -lm

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
	@[ ! -f $(BUILD)/inc/me.h ] && cp projects/appweb-linux-default-me.h $(BUILD)/inc/me.h ; true
	@if ! diff $(BUILD)/inc/me.h projects/appweb-linux-default-me.h >/dev/null ; then\
		cp projects/appweb-linux-default-me.h $(BUILD)/inc/me.h  ; \
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
	rm -f "build/$(CONFIG)/obj/ejs.o"
	rm -f "build/$(CONFIG)/obj/ejsHandler.o"
	rm -f "build/$(CONFIG)/obj/ejsLib.o"
	rm -f "build/$(CONFIG)/obj/ejsc.o"
	rm -f "build/$(CONFIG)/obj/esp.o"
	rm -f "build/$(CONFIG)/obj/espLib.o"
	rm -f "build/$(CONFIG)/obj/estLib.o"
	rm -f "build/$(CONFIG)/obj/http.o"
	rm -f "build/$(CONFIG)/obj/httpLib.o"
	rm -f "build/$(CONFIG)/obj/makerom.o"
	rm -f "build/$(CONFIG)/obj/manager.o"
	rm -f "build/$(CONFIG)/obj/mprLib.o"
	rm -f "build/$(CONFIG)/obj/mprSsl.o"
	rm -f "build/$(CONFIG)/obj/pcre.o"
	rm -f "build/$(CONFIG)/obj/phpHandler.o"
	rm -f "build/$(CONFIG)/obj/slink.o"
	rm -f "build/$(CONFIG)/obj/sqlite.o"
	rm -f "build/$(CONFIG)/obj/sqlite3.o"
	rm -f "build/$(CONFIG)/obj/sslModule.o"
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

clobber: clean
	rm -fr ./$(BUILD)


#
#   mpr.h
#
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
DEPS_3 += build/$(CONFIG)/inc/me.h

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
	$(CC) -c -o build/$(CONFIG)/obj/mprLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/mpr/mprLib.c

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
	$(CC) -c -o build/$(CONFIG)/obj/pcre.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/pcre/pcre.c

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
	$(CC) -c -o build/$(CONFIG)/obj/httpLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/http/httpLib.c

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
build/$(CONFIG)/inc/appweb.h: $(DEPS_12)
	@echo '      [Copy] build/$(CONFIG)/inc/appweb.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/appweb.h build/$(CONFIG)/inc/appweb.h

#
#   customize.h
#
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
DEPS_14 += build/$(CONFIG)/inc/osdep.h
DEPS_14 += build/$(CONFIG)/inc/mpr.h
DEPS_14 += build/$(CONFIG)/inc/http.h
DEPS_14 += build/$(CONFIG)/inc/customize.h

build/$(CONFIG)/obj/config.o: \
    src/config.c $(DEPS_14)
	@echo '   [Compile] build/$(CONFIG)/obj/config.o'
	$(CC) -c -o build/$(CONFIG)/obj/config.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/config.c

#
#   convenience.o
#
DEPS_15 += build/$(CONFIG)/inc/me.h
DEPS_15 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/convenience.o: \
    src/convenience.c $(DEPS_15)
	@echo '   [Compile] build/$(CONFIG)/obj/convenience.o'
	$(CC) -c -o build/$(CONFIG)/obj/convenience.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/convenience.c

#
#   libappweb
#
DEPS_16 += build/$(CONFIG)/inc/mpr.h
DEPS_16 += build/$(CONFIG)/inc/me.h
DEPS_16 += build/$(CONFIG)/inc/osdep.h
DEPS_16 += build/$(CONFIG)/obj/mprLib.o
DEPS_16 += build/$(CONFIG)/bin/libmpr.so
DEPS_16 += build/$(CONFIG)/inc/pcre.h
DEPS_16 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_16 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_16 += build/$(CONFIG)/inc/http.h
DEPS_16 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_16 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_16 += build/$(CONFIG)/inc/appweb.h
DEPS_16 += build/$(CONFIG)/inc/customize.h
DEPS_16 += build/$(CONFIG)/obj/config.o
DEPS_16 += build/$(CONFIG)/obj/convenience.o

ifeq ($(ME_COM_HTTP),1)
    LIBS_16 += -lhttp
endif
LIBS_16 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_16 += -lpcre
endif

build/$(CONFIG)/bin/libappweb.so: $(DEPS_16)
	@echo '      [Link] build/$(CONFIG)/bin/libappweb.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libappweb.so $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/config.o" "build/$(CONFIG)/obj/convenience.o" $(LIBPATHS_16) $(LIBS_16) $(LIBS_16) $(LIBS) 

#
#   slink.c
#
src/server/slink.c: $(DEPS_17)
	( \
	cd src/server; \
	[ ! -f slink.c ] && cp slink.empty slink.c ; true ; \
	)

#
#   esp.h
#
build/$(CONFIG)/inc/esp.h: $(DEPS_18)
	@echo '      [Copy] build/$(CONFIG)/inc/esp.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/esp/esp.h build/$(CONFIG)/inc/esp.h

#
#   slink.o
#
DEPS_19 += build/$(CONFIG)/inc/me.h
DEPS_19 += build/$(CONFIG)/inc/mpr.h
DEPS_19 += build/$(CONFIG)/inc/esp.h

build/$(CONFIG)/obj/slink.o: \
    src/server/slink.c $(DEPS_19)
	@echo '   [Compile] build/$(CONFIG)/obj/slink.o'
	$(CC) -c -o build/$(CONFIG)/obj/slink.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/server/slink.c

#
#   libslink
#
DEPS_20 += src/server/slink.c
DEPS_20 += build/$(CONFIG)/inc/me.h
DEPS_20 += build/$(CONFIG)/inc/mpr.h
DEPS_20 += build/$(CONFIG)/inc/esp.h
DEPS_20 += build/$(CONFIG)/obj/slink.o

build/$(CONFIG)/bin/libslink.so: $(DEPS_20)
	@echo '      [Link] build/$(CONFIG)/bin/libslink.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libslink.so $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/slink.o" $(LIBS) 

#
#   appweb.o
#
DEPS_21 += build/$(CONFIG)/inc/me.h
DEPS_21 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/appweb.o: \
    src/server/appweb.c $(DEPS_21)
	@echo '   [Compile] build/$(CONFIG)/obj/appweb.o'
	$(CC) -c -o build/$(CONFIG)/obj/appweb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/server/appweb.c

#
#   appweb
#
DEPS_22 += build/$(CONFIG)/inc/mpr.h
DEPS_22 += build/$(CONFIG)/inc/me.h
DEPS_22 += build/$(CONFIG)/inc/osdep.h
DEPS_22 += build/$(CONFIG)/obj/mprLib.o
DEPS_22 += build/$(CONFIG)/bin/libmpr.so
DEPS_22 += build/$(CONFIG)/inc/pcre.h
DEPS_22 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_22 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_22 += build/$(CONFIG)/inc/http.h
DEPS_22 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_22 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_22 += build/$(CONFIG)/inc/appweb.h
DEPS_22 += build/$(CONFIG)/inc/customize.h
DEPS_22 += build/$(CONFIG)/obj/config.o
DEPS_22 += build/$(CONFIG)/obj/convenience.o
DEPS_22 += build/$(CONFIG)/bin/libappweb.so
DEPS_22 += src/server/slink.c
DEPS_22 += build/$(CONFIG)/inc/esp.h
DEPS_22 += build/$(CONFIG)/obj/slink.o
DEPS_22 += build/$(CONFIG)/bin/libslink.so
DEPS_22 += build/$(CONFIG)/obj/appweb.o

LIBS_22 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_22 += -lhttp
endif
LIBS_22 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_22 += -lpcre
endif
LIBS_22 += -lslink

build/$(CONFIG)/bin/appweb: $(DEPS_22)
	@echo '      [Link] build/$(CONFIG)/bin/appweb'
	$(CC) -o build/$(CONFIG)/bin/appweb $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/appweb.o" $(LIBPATHS_22) $(LIBS_22) $(LIBS_22) $(LIBS) $(LIBS) 

#
#   authpass.o
#
DEPS_23 += build/$(CONFIG)/inc/me.h
DEPS_23 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/authpass.o: \
    src/utils/authpass.c $(DEPS_23)
	@echo '   [Compile] build/$(CONFIG)/obj/authpass.o'
	$(CC) -c -o build/$(CONFIG)/obj/authpass.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/utils/authpass.c

#
#   authpass
#
DEPS_24 += build/$(CONFIG)/inc/mpr.h
DEPS_24 += build/$(CONFIG)/inc/me.h
DEPS_24 += build/$(CONFIG)/inc/osdep.h
DEPS_24 += build/$(CONFIG)/obj/mprLib.o
DEPS_24 += build/$(CONFIG)/bin/libmpr.so
DEPS_24 += build/$(CONFIG)/inc/pcre.h
DEPS_24 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_24 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_24 += build/$(CONFIG)/inc/http.h
DEPS_24 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_24 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_24 += build/$(CONFIG)/inc/appweb.h
DEPS_24 += build/$(CONFIG)/inc/customize.h
DEPS_24 += build/$(CONFIG)/obj/config.o
DEPS_24 += build/$(CONFIG)/obj/convenience.o
DEPS_24 += build/$(CONFIG)/bin/libappweb.so
DEPS_24 += build/$(CONFIG)/obj/authpass.o

LIBS_24 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_24 += -lhttp
endif
LIBS_24 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_24 += -lpcre
endif

build/$(CONFIG)/bin/authpass: $(DEPS_24)
	@echo '      [Link] build/$(CONFIG)/bin/authpass'
	$(CC) -o build/$(CONFIG)/bin/authpass $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/authpass.o" $(LIBPATHS_24) $(LIBS_24) $(LIBS_24) $(LIBS) $(LIBS) 

#
#   cgiProgram.o
#
DEPS_25 += build/$(CONFIG)/inc/me.h

build/$(CONFIG)/obj/cgiProgram.o: \
    src/utils/cgiProgram.c $(DEPS_25)
	@echo '   [Compile] build/$(CONFIG)/obj/cgiProgram.o'
	$(CC) -c -o build/$(CONFIG)/obj/cgiProgram.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/utils/cgiProgram.c

ifeq ($(ME_COM_CGI),1)
#
#   cgiProgram
#
DEPS_26 += build/$(CONFIG)/inc/me.h
DEPS_26 += build/$(CONFIG)/obj/cgiProgram.o

build/$(CONFIG)/bin/cgiProgram: $(DEPS_26)
	@echo '      [Link] build/$(CONFIG)/bin/cgiProgram'
	$(CC) -o build/$(CONFIG)/bin/cgiProgram $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/cgiProgram.o" $(LIBS) $(LIBS) 
endif

#
#   zlib.h
#
build/$(CONFIG)/inc/zlib.h: $(DEPS_27)
	@echo '      [Copy] build/$(CONFIG)/inc/zlib.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/zlib/zlib.h build/$(CONFIG)/inc/zlib.h

#
#   zlib.o
#
DEPS_28 += build/$(CONFIG)/inc/me.h
DEPS_28 += build/$(CONFIG)/inc/zlib.h

build/$(CONFIG)/obj/zlib.o: \
    src/paks/zlib/zlib.c $(DEPS_28)
	@echo '   [Compile] build/$(CONFIG)/obj/zlib.o'
	$(CC) -c -o build/$(CONFIG)/obj/zlib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/zlib/zlib.c

ifeq ($(ME_COM_ZLIB),1)
#
#   libzlib
#
DEPS_29 += build/$(CONFIG)/inc/zlib.h
DEPS_29 += build/$(CONFIG)/inc/me.h
DEPS_29 += build/$(CONFIG)/obj/zlib.o

build/$(CONFIG)/bin/libzlib.so: $(DEPS_29)
	@echo '      [Link] build/$(CONFIG)/bin/libzlib.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libzlib.so $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/zlib.o" $(LIBS) 
endif

#
#   ejs.h
#
build/$(CONFIG)/inc/ejs.h: $(DEPS_30)
	@echo '      [Copy] build/$(CONFIG)/inc/ejs.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/ejs/ejs.h build/$(CONFIG)/inc/ejs.h

#
#   ejs.slots.h
#
build/$(CONFIG)/inc/ejs.slots.h: $(DEPS_31)
	@echo '      [Copy] build/$(CONFIG)/inc/ejs.slots.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/ejs/ejs.slots.h build/$(CONFIG)/inc/ejs.slots.h

#
#   ejsByteGoto.h
#
build/$(CONFIG)/inc/ejsByteGoto.h: $(DEPS_32)
	@echo '      [Copy] build/$(CONFIG)/inc/ejsByteGoto.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/ejs/ejsByteGoto.h build/$(CONFIG)/inc/ejsByteGoto.h

#
#   ejsLib.o
#
DEPS_33 += build/$(CONFIG)/inc/me.h
DEPS_33 += build/$(CONFIG)/inc/ejs.h
DEPS_33 += build/$(CONFIG)/inc/mpr.h
DEPS_33 += build/$(CONFIG)/inc/pcre.h
DEPS_33 += build/$(CONFIG)/inc/osdep.h
DEPS_33 += build/$(CONFIG)/inc/http.h
DEPS_33 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_33 += build/$(CONFIG)/inc/zlib.h

build/$(CONFIG)/obj/ejsLib.o: \
    src/paks/ejs/ejsLib.c $(DEPS_33)
	@echo '   [Compile] build/$(CONFIG)/obj/ejsLib.o'
	$(CC) -c -o build/$(CONFIG)/obj/ejsLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/ejs/ejsLib.c

ifeq ($(ME_COM_EJS),1)
#
#   libejs
#
DEPS_34 += build/$(CONFIG)/inc/mpr.h
DEPS_34 += build/$(CONFIG)/inc/me.h
DEPS_34 += build/$(CONFIG)/inc/osdep.h
DEPS_34 += build/$(CONFIG)/obj/mprLib.o
DEPS_34 += build/$(CONFIG)/bin/libmpr.so
DEPS_34 += build/$(CONFIG)/inc/pcre.h
DEPS_34 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_34 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_34 += build/$(CONFIG)/inc/http.h
DEPS_34 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_34 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_34 += build/$(CONFIG)/inc/zlib.h
DEPS_34 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_34 += build/$(CONFIG)/bin/libzlib.so
endif
DEPS_34 += build/$(CONFIG)/inc/ejs.h
DEPS_34 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_34 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_34 += build/$(CONFIG)/obj/ejsLib.o

ifeq ($(ME_COM_HTTP),1)
    LIBS_34 += -lhttp
endif
LIBS_34 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_34 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_34 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_34 += -lsql
endif

build/$(CONFIG)/bin/libejs.so: $(DEPS_34)
	@echo '      [Link] build/$(CONFIG)/bin/libejs.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libejs.so $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/ejsLib.o" $(LIBPATHS_34) $(LIBS_34) $(LIBS_34) $(LIBS) 
endif

#
#   ejsc.o
#
DEPS_35 += build/$(CONFIG)/inc/me.h
DEPS_35 += build/$(CONFIG)/inc/ejs.h

build/$(CONFIG)/obj/ejsc.o: \
    src/paks/ejs/ejsc.c $(DEPS_35)
	@echo '   [Compile] build/$(CONFIG)/obj/ejsc.o'
	$(CC) -c -o build/$(CONFIG)/obj/ejsc.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/ejs/ejsc.c

ifeq ($(ME_COM_EJS),1)
#
#   ejsc
#
DEPS_36 += build/$(CONFIG)/inc/mpr.h
DEPS_36 += build/$(CONFIG)/inc/me.h
DEPS_36 += build/$(CONFIG)/inc/osdep.h
DEPS_36 += build/$(CONFIG)/obj/mprLib.o
DEPS_36 += build/$(CONFIG)/bin/libmpr.so
DEPS_36 += build/$(CONFIG)/inc/pcre.h
DEPS_36 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_36 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_36 += build/$(CONFIG)/inc/http.h
DEPS_36 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_36 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_36 += build/$(CONFIG)/inc/zlib.h
DEPS_36 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_36 += build/$(CONFIG)/bin/libzlib.so
endif
DEPS_36 += build/$(CONFIG)/inc/ejs.h
DEPS_36 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_36 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_36 += build/$(CONFIG)/obj/ejsLib.o
DEPS_36 += build/$(CONFIG)/bin/libejs.so
DEPS_36 += build/$(CONFIG)/obj/ejsc.o

LIBS_36 += -lejs
ifeq ($(ME_COM_HTTP),1)
    LIBS_36 += -lhttp
endif
LIBS_36 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_36 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_36 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_36 += -lsql
endif

build/$(CONFIG)/bin/ejsc: $(DEPS_36)
	@echo '      [Link] build/$(CONFIG)/bin/ejsc'
	$(CC) -o build/$(CONFIG)/bin/ejsc $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/ejsc.o" $(LIBPATHS_36) $(LIBS_36) $(LIBS_36) $(LIBS) $(LIBS) 
endif

ifeq ($(ME_COM_EJS),1)
#
#   ejs.mod
#
DEPS_37 += src/paks/ejs/ejs.es
DEPS_37 += build/$(CONFIG)/inc/mpr.h
DEPS_37 += build/$(CONFIG)/inc/me.h
DEPS_37 += build/$(CONFIG)/inc/osdep.h
DEPS_37 += build/$(CONFIG)/obj/mprLib.o
DEPS_37 += build/$(CONFIG)/bin/libmpr.so
DEPS_37 += build/$(CONFIG)/inc/pcre.h
DEPS_37 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_37 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_37 += build/$(CONFIG)/inc/http.h
DEPS_37 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_37 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_37 += build/$(CONFIG)/inc/zlib.h
DEPS_37 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_37 += build/$(CONFIG)/bin/libzlib.so
endif
DEPS_37 += build/$(CONFIG)/inc/ejs.h
DEPS_37 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_37 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_37 += build/$(CONFIG)/obj/ejsLib.o
DEPS_37 += build/$(CONFIG)/bin/libejs.so
DEPS_37 += build/$(CONFIG)/obj/ejsc.o
DEPS_37 += build/$(CONFIG)/bin/ejsc

build/$(CONFIG)/bin/ejs.mod: $(DEPS_37)
	( \
	cd src/paks/ejs; \
	../../../$(LBIN)/ejsc --out ../../../build/$(CONFIG)/bin/ejs.mod --optimize 9 --bind --require null ejs.es ; \
	)
endif

#
#   ejs.o
#
DEPS_38 += build/$(CONFIG)/inc/me.h
DEPS_38 += build/$(CONFIG)/inc/ejs.h

build/$(CONFIG)/obj/ejs.o: \
    src/paks/ejs/ejs.c $(DEPS_38)
	@echo '   [Compile] build/$(CONFIG)/obj/ejs.o'
	$(CC) -c -o build/$(CONFIG)/obj/ejs.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/ejs/ejs.c

ifeq ($(ME_COM_EJS),1)
#
#   ejscmd
#
DEPS_39 += build/$(CONFIG)/inc/mpr.h
DEPS_39 += build/$(CONFIG)/inc/me.h
DEPS_39 += build/$(CONFIG)/inc/osdep.h
DEPS_39 += build/$(CONFIG)/obj/mprLib.o
DEPS_39 += build/$(CONFIG)/bin/libmpr.so
DEPS_39 += build/$(CONFIG)/inc/pcre.h
DEPS_39 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_39 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_39 += build/$(CONFIG)/inc/http.h
DEPS_39 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_39 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_39 += build/$(CONFIG)/inc/zlib.h
DEPS_39 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_39 += build/$(CONFIG)/bin/libzlib.so
endif
DEPS_39 += build/$(CONFIG)/inc/ejs.h
DEPS_39 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_39 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_39 += build/$(CONFIG)/obj/ejsLib.o
DEPS_39 += build/$(CONFIG)/bin/libejs.so
DEPS_39 += build/$(CONFIG)/obj/ejs.o

LIBS_39 += -lejs
ifeq ($(ME_COM_HTTP),1)
    LIBS_39 += -lhttp
endif
LIBS_39 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_39 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_39 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_39 += -lsql
endif

build/$(CONFIG)/bin/ejs: $(DEPS_39)
	@echo '      [Link] build/$(CONFIG)/bin/ejs'
	$(CC) -o build/$(CONFIG)/bin/ejs $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/ejs.o" $(LIBPATHS_39) $(LIBS_39) $(LIBS_39) $(LIBS) $(LIBS) 
endif

ifeq ($(ME_COM_ESP),1)
#
#   esp-paks
#
DEPS_40 += src/paks/esp-html-mvc
DEPS_40 += src/paks/esp-html-mvc/client
DEPS_40 += src/paks/esp-html-mvc/client/assets
DEPS_40 += src/paks/esp-html-mvc/client/assets/favicon.ico
DEPS_40 += src/paks/esp-html-mvc/client/css
DEPS_40 += src/paks/esp-html-mvc/client/css/all.css
DEPS_40 += src/paks/esp-html-mvc/client/css/all.less
DEPS_40 += src/paks/esp-html-mvc/client/index.esp
DEPS_40 += src/paks/esp-html-mvc/css
DEPS_40 += src/paks/esp-html-mvc/css/app.less
DEPS_40 += src/paks/esp-html-mvc/css/theme.less
DEPS_40 += src/paks/esp-html-mvc/generate
DEPS_40 += src/paks/esp-html-mvc/generate/appweb.conf
DEPS_40 += src/paks/esp-html-mvc/generate/controller.c
DEPS_40 += src/paks/esp-html-mvc/generate/controllerSingleton.c
DEPS_40 += src/paks/esp-html-mvc/generate/edit.esp
DEPS_40 += src/paks/esp-html-mvc/generate/list.esp
DEPS_40 += src/paks/esp-html-mvc/layouts
DEPS_40 += src/paks/esp-html-mvc/layouts/default.esp
DEPS_40 += src/paks/esp-html-mvc/LICENSE.md
DEPS_40 += src/paks/esp-html-mvc/package.json
DEPS_40 += src/paks/esp-html-mvc/README.md
DEPS_40 += src/paks/esp-mvc
DEPS_40 += src/paks/esp-mvc/generate
DEPS_40 += src/paks/esp-mvc/generate/appweb.conf
DEPS_40 += src/paks/esp-mvc/generate/controller.c
DEPS_40 += src/paks/esp-mvc/generate/migration.c
DEPS_40 += src/paks/esp-mvc/generate/src
DEPS_40 += src/paks/esp-mvc/generate/src/app.c
DEPS_40 += src/paks/esp-mvc/LICENSE.md
DEPS_40 += src/paks/esp-mvc/package.json
DEPS_40 += src/paks/esp-mvc/README.md
DEPS_40 += src/paks/esp-server
DEPS_40 += src/paks/esp-server/generate
DEPS_40 += src/paks/esp-server/generate/appweb.conf
DEPS_40 += src/paks/esp-server/LICENSE.md
DEPS_40 += src/paks/esp-server/package.json
DEPS_40 += src/paks/esp-server/README.md

build/$(CONFIG)/esp: $(DEPS_40)
	( \
	cd src/paks; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0" ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/client" ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/client/assets" ; \
	cp esp-html-mvc/client/assets/favicon.ico ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/client/assets/favicon.ico ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/client/css" ; \
	cp esp-html-mvc/client/css/all.css ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/client/css/all.css ; \
	cp esp-html-mvc/client/css/all.less ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/client/css/all.less ; \
	cp esp-html-mvc/client/index.esp ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/client/index.esp ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/css" ; \
	cp esp-html-mvc/css/app.less ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/css/app.less ; \
	cp esp-html-mvc/css/theme.less ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/css/theme.less ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/generate" ; \
	cp esp-html-mvc/generate/appweb.conf ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/generate/appweb.conf ; \
	cp esp-html-mvc/generate/controller.c ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/generate/controller.c ; \
	cp esp-html-mvc/generate/controllerSingleton.c ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/generate/controllerSingleton.c ; \
	cp esp-html-mvc/generate/edit.esp ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/generate/edit.esp ; \
	cp esp-html-mvc/generate/list.esp ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/generate/list.esp ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/layouts" ; \
	cp esp-html-mvc/layouts/default.esp ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/layouts/default.esp ; \
	cp esp-html-mvc/LICENSE.md ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/LICENSE.md ; \
	cp esp-html-mvc/package.json ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/package.json ; \
	cp esp-html-mvc/README.md ../../build/$(CONFIG)/esp/esp-html-mvc/5.1.0/README.md ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-mvc/5.1.0" ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-mvc/5.1.0/generate" ; \
	cp esp-mvc/generate/appweb.conf ../../build/$(CONFIG)/esp/esp-mvc/5.1.0/generate/appweb.conf ; \
	cp esp-mvc/generate/controller.c ../../build/$(CONFIG)/esp/esp-mvc/5.1.0/generate/controller.c ; \
	cp esp-mvc/generate/migration.c ../../build/$(CONFIG)/esp/esp-mvc/5.1.0/generate/migration.c ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-mvc/5.1.0/generate/src" ; \
	cp esp-mvc/generate/src/app.c ../../build/$(CONFIG)/esp/esp-mvc/5.1.0/generate/src/app.c ; \
	cp esp-mvc/LICENSE.md ../../build/$(CONFIG)/esp/esp-mvc/5.1.0/LICENSE.md ; \
	cp esp-mvc/package.json ../../build/$(CONFIG)/esp/esp-mvc/5.1.0/package.json ; \
	cp esp-mvc/README.md ../../build/$(CONFIG)/esp/esp-mvc/5.1.0/README.md ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-server/5.1.0" ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-server/5.1.0/generate" ; \
	cp esp-server/generate/appweb.conf ../../build/$(CONFIG)/esp/esp-server/5.1.0/generate/appweb.conf ; \
	cp esp-server/LICENSE.md ../../build/$(CONFIG)/esp/esp-server/5.1.0/LICENSE.md ; \
	cp esp-server/package.json ../../build/$(CONFIG)/esp/esp-server/5.1.0/package.json ; \
	cp esp-server/README.md ../../build/$(CONFIG)/esp/esp-server/5.1.0/README.md ; \
	)
endif

ifeq ($(ME_COM_ESP),1)
#
#   esp.conf
#
DEPS_41 += src/paks/esp/esp.conf

build/$(CONFIG)/bin/esp.conf: $(DEPS_41)
	@echo '      [Copy] build/$(CONFIG)/bin/esp.conf'
	mkdir -p "build/$(CONFIG)/bin"
	cp src/paks/esp/esp.conf build/$(CONFIG)/bin/esp.conf
endif

#
#   espLib.o
#
DEPS_42 += build/$(CONFIG)/inc/me.h
DEPS_42 += build/$(CONFIG)/inc/esp.h
DEPS_42 += build/$(CONFIG)/inc/pcre.h
DEPS_42 += build/$(CONFIG)/inc/http.h
DEPS_42 += build/$(CONFIG)/inc/osdep.h
DEPS_42 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/espLib.o: \
    src/paks/esp/espLib.c $(DEPS_42)
	@echo '   [Compile] build/$(CONFIG)/obj/espLib.o'
	$(CC) -c -o build/$(CONFIG)/obj/espLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/esp/espLib.c

ifeq ($(ME_COM_ESP),1)
#
#   libmod_esp
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
DEPS_43 += build/$(CONFIG)/inc/appweb.h
DEPS_43 += build/$(CONFIG)/inc/customize.h
DEPS_43 += build/$(CONFIG)/obj/config.o
DEPS_43 += build/$(CONFIG)/obj/convenience.o
DEPS_43 += build/$(CONFIG)/bin/libappweb.so
DEPS_43 += build/$(CONFIG)/inc/esp.h
DEPS_43 += build/$(CONFIG)/obj/espLib.o

LIBS_43 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_43 += -lhttp
endif
LIBS_43 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_43 += -lpcre
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_43 += -lsql
endif

build/$(CONFIG)/bin/libmod_esp.so: $(DEPS_43)
	@echo '      [Link] build/$(CONFIG)/bin/libmod_esp.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libmod_esp.so $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/espLib.o" $(LIBPATHS_43) $(LIBS_43) $(LIBS_43) $(LIBS) 
endif

#
#   esp.o
#
DEPS_44 += build/$(CONFIG)/inc/me.h
DEPS_44 += build/$(CONFIG)/inc/esp.h

build/$(CONFIG)/obj/esp.o: \
    src/paks/esp/esp.c $(DEPS_44)
	@echo '   [Compile] build/$(CONFIG)/obj/esp.o'
	$(CC) -c -o build/$(CONFIG)/obj/esp.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/esp/esp.c

ifeq ($(ME_COM_ESP),1)
#
#   espcmd
#
DEPS_45 += build/$(CONFIG)/inc/mpr.h
DEPS_45 += build/$(CONFIG)/inc/me.h
DEPS_45 += build/$(CONFIG)/inc/osdep.h
DEPS_45 += build/$(CONFIG)/obj/mprLib.o
DEPS_45 += build/$(CONFIG)/bin/libmpr.so
DEPS_45 += build/$(CONFIG)/inc/pcre.h
DEPS_45 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_45 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_45 += build/$(CONFIG)/inc/http.h
DEPS_45 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_45 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_45 += build/$(CONFIG)/inc/appweb.h
DEPS_45 += build/$(CONFIG)/inc/customize.h
DEPS_45 += build/$(CONFIG)/obj/config.o
DEPS_45 += build/$(CONFIG)/obj/convenience.o
DEPS_45 += build/$(CONFIG)/bin/libappweb.so
DEPS_45 += build/$(CONFIG)/inc/esp.h
DEPS_45 += build/$(CONFIG)/obj/espLib.o
DEPS_45 += build/$(CONFIG)/bin/libmod_esp.so
DEPS_45 += build/$(CONFIG)/obj/esp.o

LIBS_45 += -lmod_esp
LIBS_45 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_45 += -lhttp
endif
LIBS_45 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_45 += -lpcre
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_45 += -lsql
endif

build/$(CONFIG)/bin/esp: $(DEPS_45)
	@echo '      [Link] build/$(CONFIG)/bin/esp'
	$(CC) -o build/$(CONFIG)/bin/esp $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/esp.o" $(LIBPATHS_45) $(LIBS_45) $(LIBS_45) $(LIBS) $(LIBS) 
endif


#
#   genslink
#
genslink: $(DEPS_46)
	( \
	cd src/server; \
	esp --static --genlink slink.c compile ; \
	)

#
#   http-ca-crt
#
DEPS_47 += src/paks/http/ca.crt

build/$(CONFIG)/bin/ca.crt: $(DEPS_47)
	@echo '      [Copy] build/$(CONFIG)/bin/ca.crt'
	mkdir -p "build/$(CONFIG)/bin"
	cp src/paks/http/ca.crt build/$(CONFIG)/bin/ca.crt

#
#   http.o
#
DEPS_48 += build/$(CONFIG)/inc/me.h
DEPS_48 += build/$(CONFIG)/inc/http.h

build/$(CONFIG)/obj/http.o: \
    src/paks/http/http.c $(DEPS_48)
	@echo '   [Compile] build/$(CONFIG)/obj/http.o'
	$(CC) -c -o build/$(CONFIG)/obj/http.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/http/http.c

ifeq ($(ME_COM_HTTP),1)
#
#   httpcmd
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
DEPS_49 += build/$(CONFIG)/bin/libhttp.so
DEPS_49 += build/$(CONFIG)/obj/http.o

LIBS_49 += -lhttp
LIBS_49 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_49 += -lpcre
endif

build/$(CONFIG)/bin/http: $(DEPS_49)
	@echo '      [Link] build/$(CONFIG)/bin/http'
	$(CC) -o build/$(CONFIG)/bin/http $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/http.o" $(LIBPATHS_49) $(LIBS_49) $(LIBS_49) $(LIBS) $(LIBS) 
endif

#
#   est.h
#
build/$(CONFIG)/inc/est.h: $(DEPS_50)
	@echo '      [Copy] build/$(CONFIG)/inc/est.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/est/est.h build/$(CONFIG)/inc/est.h

#
#   estLib.o
#
DEPS_51 += build/$(CONFIG)/inc/me.h
DEPS_51 += build/$(CONFIG)/inc/est.h
DEPS_51 += build/$(CONFIG)/inc/osdep.h

build/$(CONFIG)/obj/estLib.o: \
    src/paks/est/estLib.c $(DEPS_51)
	@echo '   [Compile] build/$(CONFIG)/obj/estLib.o'
	$(CC) -c -o build/$(CONFIG)/obj/estLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/est/estLib.c

ifeq ($(ME_COM_EST),1)
#
#   libest
#
DEPS_52 += build/$(CONFIG)/inc/est.h
DEPS_52 += build/$(CONFIG)/inc/me.h
DEPS_52 += build/$(CONFIG)/inc/osdep.h
DEPS_52 += build/$(CONFIG)/obj/estLib.o

build/$(CONFIG)/bin/libest.so: $(DEPS_52)
	@echo '      [Link] build/$(CONFIG)/bin/libest.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libest.so $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/estLib.o" $(LIBS) 
endif

#
#   cgiHandler.o
#
DEPS_53 += build/$(CONFIG)/inc/me.h
DEPS_53 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/cgiHandler.o: \
    src/modules/cgiHandler.c $(DEPS_53)
	@echo '   [Compile] build/$(CONFIG)/obj/cgiHandler.o'
	$(CC) -c -o build/$(CONFIG)/obj/cgiHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/modules/cgiHandler.c

ifeq ($(ME_COM_CGI),1)
#
#   libmod_cgi
#
DEPS_54 += build/$(CONFIG)/inc/mpr.h
DEPS_54 += build/$(CONFIG)/inc/me.h
DEPS_54 += build/$(CONFIG)/inc/osdep.h
DEPS_54 += build/$(CONFIG)/obj/mprLib.o
DEPS_54 += build/$(CONFIG)/bin/libmpr.so
DEPS_54 += build/$(CONFIG)/inc/pcre.h
DEPS_54 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_54 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_54 += build/$(CONFIG)/inc/http.h
DEPS_54 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_54 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_54 += build/$(CONFIG)/inc/appweb.h
DEPS_54 += build/$(CONFIG)/inc/customize.h
DEPS_54 += build/$(CONFIG)/obj/config.o
DEPS_54 += build/$(CONFIG)/obj/convenience.o
DEPS_54 += build/$(CONFIG)/bin/libappweb.so
DEPS_54 += build/$(CONFIG)/obj/cgiHandler.o

LIBS_54 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_54 += -lhttp
endif
LIBS_54 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_54 += -lpcre
endif

build/$(CONFIG)/bin/libmod_cgi.so: $(DEPS_54)
	@echo '      [Link] build/$(CONFIG)/bin/libmod_cgi.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libmod_cgi.so $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/cgiHandler.o" $(LIBPATHS_54) $(LIBS_54) $(LIBS_54) $(LIBS) 
endif

#
#   ejsHandler.o
#
DEPS_55 += build/$(CONFIG)/inc/me.h
DEPS_55 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/ejsHandler.o: \
    src/modules/ejsHandler.c $(DEPS_55)
	@echo '   [Compile] build/$(CONFIG)/obj/ejsHandler.o'
	$(CC) -c -o build/$(CONFIG)/obj/ejsHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/modules/ejsHandler.c

ifeq ($(ME_COM_EJS),1)
#
#   libmod_ejs
#
DEPS_56 += build/$(CONFIG)/inc/mpr.h
DEPS_56 += build/$(CONFIG)/inc/me.h
DEPS_56 += build/$(CONFIG)/inc/osdep.h
DEPS_56 += build/$(CONFIG)/obj/mprLib.o
DEPS_56 += build/$(CONFIG)/bin/libmpr.so
DEPS_56 += build/$(CONFIG)/inc/pcre.h
DEPS_56 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_56 += build/$(CONFIG)/bin/libpcre.so
endif
DEPS_56 += build/$(CONFIG)/inc/http.h
DEPS_56 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_56 += build/$(CONFIG)/bin/libhttp.so
endif
DEPS_56 += build/$(CONFIG)/inc/appweb.h
DEPS_56 += build/$(CONFIG)/inc/customize.h
DEPS_56 += build/$(CONFIG)/obj/config.o
DEPS_56 += build/$(CONFIG)/obj/convenience.o
DEPS_56 += build/$(CONFIG)/bin/libappweb.so
DEPS_56 += build/$(CONFIG)/inc/zlib.h
DEPS_56 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_56 += build/$(CONFIG)/bin/libzlib.so
endif
DEPS_56 += build/$(CONFIG)/inc/ejs.h
DEPS_56 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_56 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_56 += build/$(CONFIG)/obj/ejsLib.o
DEPS_56 += build/$(CONFIG)/bin/libejs.so
DEPS_56 += build/$(CONFIG)/obj/ejsHandler.o

LIBS_56 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_56 += -lhttp
endif
LIBS_56 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_56 += -lpcre
endif
LIBS_56 += -lejs
ifeq ($(ME_COM_ZLIB),1)
    LIBS_56 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_56 += -lsql
endif

build/$(CONFIG)/bin/libmod_ejs.so: $(DEPS_56)
	@echo '      [Link] build/$(CONFIG)/bin/libmod_ejs.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libmod_ejs.so $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/ejsHandler.o" $(LIBPATHS_56) $(LIBS_56) $(LIBS_56) $(LIBS) 
endif

#
#   phpHandler.o
#
DEPS_57 += build/$(CONFIG)/inc/me.h
DEPS_57 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/phpHandler.o: \
    src/modules/phpHandler.c $(DEPS_57)
	@echo '   [Compile] build/$(CONFIG)/obj/phpHandler.o'
	$(CC) -c -o build/$(CONFIG)/obj/phpHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) "-I$(ME_COM_PHP_PATH)" "-I$(ME_COM_PHP_PATH)/main" "-I$(ME_COM_PHP_PATH)/Zend" "-I$(ME_COM_PHP_PATH)/TSRM" src/modules/phpHandler.c

ifeq ($(ME_COM_PHP),1)
#
#   libmod_php
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
DEPS_58 += build/$(CONFIG)/bin/libappweb.so
DEPS_58 += build/$(CONFIG)/obj/phpHandler.o

LIBS_58 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_58 += -lhttp
endif
LIBS_58 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_58 += -lpcre
endif
LIBS_58 += -lphp5
LIBPATHS_58 += -L$(ME_COM_PHP_PATH)/libs

build/$(CONFIG)/bin/libmod_php.so: $(DEPS_58)
	@echo '      [Link] build/$(CONFIG)/bin/libmod_php.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libmod_php.so $(LDFLAGS) $(LIBPATHS)  "build/$(CONFIG)/obj/phpHandler.o" $(LIBPATHS_58) $(LIBS_58) $(LIBS_58) $(LIBS) 
endif

#
#   mprSsl.o
#
DEPS_59 += build/$(CONFIG)/inc/me.h
DEPS_59 += build/$(CONFIG)/inc/mpr.h

build/$(CONFIG)/obj/mprSsl.o: \
    src/paks/mpr/mprSsl.c $(DEPS_59)
	@echo '   [Compile] build/$(CONFIG)/obj/mprSsl.o'
	$(CC) -c -o build/$(CONFIG)/obj/mprSsl.o $(CFLAGS) $(DFLAGS) $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" "-I$(ME_COM_NANOSSL_PATH)/src" src/paks/mpr/mprSsl.c

#
#   libmprssl
#
DEPS_60 += build/$(CONFIG)/inc/mpr.h
DEPS_60 += build/$(CONFIG)/inc/me.h
DEPS_60 += build/$(CONFIG)/inc/osdep.h
DEPS_60 += build/$(CONFIG)/obj/mprLib.o
DEPS_60 += build/$(CONFIG)/bin/libmpr.so
DEPS_60 += build/$(CONFIG)/inc/est.h
DEPS_60 += build/$(CONFIG)/obj/estLib.o
ifeq ($(ME_COM_EST),1)
    DEPS_60 += build/$(CONFIG)/bin/libest.so
endif
DEPS_60 += build/$(CONFIG)/obj/mprSsl.o

LIBS_60 += -lmpr
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_60 += -lssl
    LIBPATHS_60 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_60 += -lcrypto
    LIBPATHS_60 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_EST),1)
    LIBS_60 += -lest
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_60 += -lmatrixssl
    LIBPATHS_60 += -L$(ME_COM_MATRIXSSL_PATH)
endif
ifeq ($(ME_COM_NANOSSL),1)
    LIBS_60 += -lssls
    LIBPATHS_60 += -L$(ME_COM_NANOSSL_PATH)/bin
endif

build/$(CONFIG)/bin/libmprssl.so: $(DEPS_60)
	@echo '      [Link] build/$(CONFIG)/bin/libmprssl.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libmprssl.so $(LDFLAGS) $(LIBPATHS)    "build/$(CONFIG)/obj/mprSsl.o" $(LIBPATHS_60) $(LIBS_60) $(LIBS_60) $(LIBS) 

#
#   sslModule.o
#
DEPS_61 += build/$(CONFIG)/inc/me.h
DEPS_61 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/sslModule.o: \
    src/modules/sslModule.c $(DEPS_61)
	@echo '   [Compile] build/$(CONFIG)/obj/sslModule.o'
	$(CC) -c -o build/$(CONFIG)/obj/sslModule.o $(CFLAGS) $(DFLAGS) $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" "-I$(ME_COM_NANOSSL_PATH)/src" src/modules/sslModule.c

ifeq ($(ME_COM_SSL),1)
#
#   libmod_ssl
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
DEPS_62 += build/$(CONFIG)/bin/libappweb.so
DEPS_62 += build/$(CONFIG)/inc/est.h
DEPS_62 += build/$(CONFIG)/obj/estLib.o
ifeq ($(ME_COM_EST),1)
    DEPS_62 += build/$(CONFIG)/bin/libest.so
endif
DEPS_62 += build/$(CONFIG)/obj/mprSsl.o
DEPS_62 += build/$(CONFIG)/bin/libmprssl.so
DEPS_62 += build/$(CONFIG)/obj/sslModule.o

LIBS_62 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_62 += -lhttp
endif
LIBS_62 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_62 += -lpcre
endif
LIBS_62 += -lmprssl
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_62 += -lssl
    LIBPATHS_62 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_62 += -lcrypto
    LIBPATHS_62 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_EST),1)
    LIBS_62 += -lest
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_62 += -lmatrixssl
    LIBPATHS_62 += -L$(ME_COM_MATRIXSSL_PATH)
endif
ifeq ($(ME_COM_NANOSSL),1)
    LIBS_62 += -lssls
    LIBPATHS_62 += -L$(ME_COM_NANOSSL_PATH)/bin
endif

build/$(CONFIG)/bin/libmod_ssl.so: $(DEPS_62)
	@echo '      [Link] build/$(CONFIG)/bin/libmod_ssl.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libmod_ssl.so $(LDFLAGS) $(LIBPATHS)    "build/$(CONFIG)/obj/sslModule.o" $(LIBPATHS_62) $(LIBS_62) $(LIBS_62) $(LIBS) 
endif

#
#   sqlite3.h
#
build/$(CONFIG)/inc/sqlite3.h: $(DEPS_63)
	@echo '      [Copy] build/$(CONFIG)/inc/sqlite3.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/sqlite/sqlite3.h build/$(CONFIG)/inc/sqlite3.h

#
#   sqlite3.o
#
DEPS_64 += build/$(CONFIG)/inc/me.h
DEPS_64 += build/$(CONFIG)/inc/sqlite3.h

build/$(CONFIG)/obj/sqlite3.o: \
    src/paks/sqlite/sqlite3.c $(DEPS_64)
	@echo '   [Compile] build/$(CONFIG)/obj/sqlite3.o'
	$(CC) -c -o build/$(CONFIG)/obj/sqlite3.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/sqlite/sqlite3.c

ifeq ($(ME_COM_SQLITE),1)
#
#   libsql
#
DEPS_65 += build/$(CONFIG)/inc/sqlite3.h
DEPS_65 += build/$(CONFIG)/inc/me.h
DEPS_65 += build/$(CONFIG)/obj/sqlite3.o

build/$(CONFIG)/bin/libsql.so: $(DEPS_65)
	@echo '      [Link] build/$(CONFIG)/bin/libsql.so'
	$(CC) -shared -o build/$(CONFIG)/bin/libsql.so $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/sqlite3.o" $(LIBS) 
endif

#
#   manager.o
#
DEPS_66 += build/$(CONFIG)/inc/me.h
DEPS_66 += build/$(CONFIG)/inc/mpr.h

build/$(CONFIG)/obj/manager.o: \
    src/paks/mpr/manager.c $(DEPS_66)
	@echo '   [Compile] build/$(CONFIG)/obj/manager.o'
	$(CC) -c -o build/$(CONFIG)/obj/manager.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/mpr/manager.c

#
#   manager
#
DEPS_67 += build/$(CONFIG)/inc/mpr.h
DEPS_67 += build/$(CONFIG)/inc/me.h
DEPS_67 += build/$(CONFIG)/inc/osdep.h
DEPS_67 += build/$(CONFIG)/obj/mprLib.o
DEPS_67 += build/$(CONFIG)/bin/libmpr.so
DEPS_67 += build/$(CONFIG)/obj/manager.o

LIBS_67 += -lmpr

build/$(CONFIG)/bin/appman: $(DEPS_67)
	@echo '      [Link] build/$(CONFIG)/bin/appman'
	$(CC) -o build/$(CONFIG)/bin/appman $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/manager.o" $(LIBPATHS_67) $(LIBS_67) $(LIBS_67) $(LIBS) $(LIBS) 

#
#   server-cache
#
src/server/cache: $(DEPS_68)
	( \
	cd src/server; \
	mkdir -p cache ; \
	)

#
#   sqlite.o
#
DEPS_69 += build/$(CONFIG)/inc/me.h
DEPS_69 += build/$(CONFIG)/inc/sqlite3.h

build/$(CONFIG)/obj/sqlite.o: \
    src/paks/sqlite/sqlite.c $(DEPS_69)
	@echo '   [Compile] build/$(CONFIG)/obj/sqlite.o'
	$(CC) -c -o build/$(CONFIG)/obj/sqlite.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/paks/sqlite/sqlite.c

ifeq ($(ME_COM_SQLITE),1)
#
#   sqliteshell
#
DEPS_70 += build/$(CONFIG)/inc/sqlite3.h
DEPS_70 += build/$(CONFIG)/inc/me.h
DEPS_70 += build/$(CONFIG)/obj/sqlite3.o
DEPS_70 += build/$(CONFIG)/bin/libsql.so
DEPS_70 += build/$(CONFIG)/obj/sqlite.o

LIBS_70 += -lsql

build/$(CONFIG)/bin/sqlite: $(DEPS_70)
	@echo '      [Link] build/$(CONFIG)/bin/sqlite'
	$(CC) -o build/$(CONFIG)/bin/sqlite $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/sqlite.o" $(LIBPATHS_70) $(LIBS_70) $(LIBS_70) $(LIBS) $(LIBS) 
endif

ifeq ($(ME_COM_CGI),1)
#
#   test-basic.cgi
#
test/web/auth/basic/basic.cgi: $(DEPS_71)
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
test/web/caching/cache.cgi: $(DEPS_72)
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
DEPS_73 += build/$(CONFIG)/inc/me.h
DEPS_73 += build/$(CONFIG)/obj/cgiProgram.o
DEPS_73 += build/$(CONFIG)/bin/cgiProgram

test/cgi-bin/cgiProgram: $(DEPS_73)
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
DEPS_74 += build/$(CONFIG)/inc/me.h
DEPS_74 += build/$(CONFIG)/obj/cgiProgram.o
DEPS_74 += build/$(CONFIG)/bin/cgiProgram

test/cgi-bin/testScript: $(DEPS_74)
	( \
	cd test; \
	echo '#!../build/$(CONFIG)/bin/cgiProgram' >cgi-bin/testScript ; chmod +x cgi-bin/testScript ; \
	)
endif


#
#   stop
#
DEPS_75 += compile

stop: $(DEPS_75)
	( \
	cd .; \
	@./build/$(CONFIG)/bin/appman stop disable uninstall >/dev/null 2>&1 ; true ; \
	)

#
#   installBinary
#
installBinary: $(DEPS_76)
	( \
	cd .; \
	mkdir -p "$(ME_APP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	ln -s "5.2.0" "$(ME_APP_PREFIX)/latest" ; \
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
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.1.0" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.1.0/client" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.1.0/client/assets" ; \
	cp src/paks/esp-html-mvc/client/assets/favicon.ico $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.1.0/client/assets/favicon.ico ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.1.0/client/css" ; \
	cp src/paks/esp-html-mvc/client/css/all.css $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.1.0/client/css/all.css ; \
	cp src/paks/esp-html-mvc/client/css/all.less $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.1.0/client/css/all.less ; \
	cp src/paks/esp-html-mvc/client/index.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.1.0/client/index.esp ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.1.0/css" ; \
	cp src/paks/esp-html-mvc/css/app.less $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.1.0/css/app.less ; \
	cp src/paks/esp-html-mvc/css/theme.less $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.1.0/css/theme.less ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.1.0/generate" ; \
	cp src/paks/esp-html-mvc/generate/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.1.0/generate/appweb.conf ; \
	cp src/paks/esp-html-mvc/generate/controller.c $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.1.0/generate/controller.c ; \
	cp src/paks/esp-html-mvc/generate/controllerSingleton.c $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.1.0/generate/controllerSingleton.c ; \
	cp src/paks/esp-html-mvc/generate/edit.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.1.0/generate/edit.esp ; \
	cp src/paks/esp-html-mvc/generate/list.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.1.0/generate/list.esp ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.1.0/layouts" ; \
	cp src/paks/esp-html-mvc/layouts/default.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.1.0/layouts/default.esp ; \
	cp src/paks/esp-html-mvc/LICENSE.md $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.1.0/LICENSE.md ; \
	cp src/paks/esp-html-mvc/package.json $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.1.0/package.json ; \
	cp src/paks/esp-html-mvc/README.md $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.1.0/README.md ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-mvc/5.1.0" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-mvc/5.1.0/generate" ; \
	cp src/paks/esp-mvc/generate/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-mvc/5.1.0/generate/appweb.conf ; \
	cp src/paks/esp-mvc/generate/controller.c $(ME_VAPP_PREFIX)/esp/esp-mvc/5.1.0/generate/controller.c ; \
	cp src/paks/esp-mvc/generate/migration.c $(ME_VAPP_PREFIX)/esp/esp-mvc/5.1.0/generate/migration.c ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-mvc/5.1.0/generate/src" ; \
	cp src/paks/esp-mvc/generate/src/app.c $(ME_VAPP_PREFIX)/esp/esp-mvc/5.1.0/generate/src/app.c ; \
	cp src/paks/esp-mvc/LICENSE.md $(ME_VAPP_PREFIX)/esp/esp-mvc/5.1.0/LICENSE.md ; \
	cp src/paks/esp-mvc/package.json $(ME_VAPP_PREFIX)/esp/esp-mvc/5.1.0/package.json ; \
	cp src/paks/esp-mvc/README.md $(ME_VAPP_PREFIX)/esp/esp-mvc/5.1.0/README.md ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-server/5.1.0" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-server/5.1.0/generate" ; \
	cp src/paks/esp-server/generate/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-server/5.1.0/generate/appweb.conf ; \
	cp src/paks/esp-server/LICENSE.md $(ME_VAPP_PREFIX)/esp/esp-server/5.1.0/LICENSE.md ; \
	cp src/paks/esp-server/package.json $(ME_VAPP_PREFIX)/esp/esp-server/5.1.0/package.json ; \
	cp src/paks/esp-server/README.md $(ME_VAPP_PREFIX)/esp/esp-server/5.1.0/README.md ; \
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
	cp doc/final/man/appman.1 $(ME_VAPP_PREFIX)/doc/man1/appman.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/appman.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/appman.1" "$(ME_MAN_PREFIX)/man1/appman.1" ; \
	cp doc/final/man/appweb.1 $(ME_VAPP_PREFIX)/doc/man1/appweb.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/appweb.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/appweb.1" "$(ME_MAN_PREFIX)/man1/appweb.1" ; \
	cp doc/final/man/appwebMonitor.1 $(ME_VAPP_PREFIX)/doc/man1/appwebMonitor.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/appwebMonitor.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/appwebMonitor.1" "$(ME_MAN_PREFIX)/man1/appwebMonitor.1" ; \
	cp doc/final/man/authpass.1 $(ME_VAPP_PREFIX)/doc/man1/authpass.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/authpass.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/authpass.1" "$(ME_MAN_PREFIX)/man1/authpass.1" ; \
	cp doc/final/man/esp.1 $(ME_VAPP_PREFIX)/doc/man1/esp.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/esp.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/esp.1" "$(ME_MAN_PREFIX)/man1/esp.1" ; \
	cp doc/final/man/http.1 $(ME_VAPP_PREFIX)/doc/man1/http.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/http.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/http.1" "$(ME_MAN_PREFIX)/man1/http.1" ; \
	cp doc/final/man/makerom.1 $(ME_VAPP_PREFIX)/doc/man1/makerom.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/makerom.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/makerom.1" "$(ME_MAN_PREFIX)/man1/makerom.1" ; \
	cp doc/final/man/manager.1 $(ME_VAPP_PREFIX)/doc/man1/manager.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/manager.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/manager.1" "$(ME_MAN_PREFIX)/man1/manager.1" ; \
	mkdir -p "$(ME_ROOT_PREFIX)/etc/init.d" ; \
	cp package/linux/appweb.init $(ME_ROOT_PREFIX)/etc/init.d/appweb ; \
	[ `id -u` = 0 ] && chown root:root "$(ME_ROOT_PREFIX)/etc/init.d/appweb"; true ; \
	chmod 755 "$(ME_ROOT_PREFIX)/etc/init.d/appweb" ; \
	)

#
#   start
#
DEPS_77 += compile
DEPS_77 += stop

start: $(DEPS_77)
	( \
	cd .; \
	./build/$(CONFIG)/bin/appman install enable start ; \
	)

#
#   install
#
DEPS_78 += compile
DEPS_78 += stop
DEPS_78 += installBinary
DEPS_78 += start

install: $(DEPS_78)

#
#   run
#
DEPS_79 += compile

run: $(DEPS_79)
	( \
	cd src/server; \
	sudo ../../build/$(CONFIG)/bin/appweb -v ; \
	)


#
#   uninstall
#
DEPS_80 += build
DEPS_80 += compile
DEPS_80 += stop

uninstall: $(DEPS_80)
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
version: $(DEPS_81)
	echo 5.2.0

