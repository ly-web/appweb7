#
#   appweb-vxworks-default.mk -- Makefile to build Embedthis Appweb for vxworks
#

NAME                  := appweb
VERSION               := 5.0.0-rc2
PROFILE               ?= default
ARCH                  ?= $(shell echo $(WIND_HOST_TYPE) | sed 's/-.*//')
CPU                   ?= $(subst X86,PENTIUM,$(shell echo $(ARCH) | tr a-z A-Z))
OS                    ?= vxworks
CC                    ?= cc$(subst x86,pentium,$(ARCH))
LD                    ?= ld
CONFIG                ?= $(OS)-$(ARCH)-$(PROFILE)
LBIN                  ?= $(CONFIG)/bin
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
ME_COM_COMPILER_PATH  ?= cc$(subst x86,pentium,$(ARCH))
ME_COM_DIR_PATH       ?= src/dirHandler.c
ME_COM_LIB_PATH       ?= ar
ME_COM_LINK_PATH      ?= ld
ME_COM_MATRIXSSL_PATH ?= /usr/src/matrixssl
ME_COM_NANOSSL_PATH   ?= /usr/src/nanossl
ME_COM_OPENSSL_PATH   ?= /usr/src/openssl
ME_COM_PHP_PATH       ?= /usr/src/php
ME_COM_VXWORKS_PATH   ?= $(WIND_BASE)

export WIND_HOME      ?= $(WIND_BASE)/..
export PATH           := $(WIND_GNU_PATH)/$(WIND_HOST_TYPE)/bin:$(PATH)

CFLAGS                += -fno-builtin -fno-defer-pop -fvolatile -w
DFLAGS                += -DVXWORKS -DRW_MULTI_THREAD -D_GNU_TOOL -DCPU=PENTIUM $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_CGI=$(ME_COM_CGI) -DME_COM_DIR=$(ME_COM_DIR) -DME_COM_EJS=$(ME_COM_EJS) -DME_COM_ESP=$(ME_COM_ESP) -DME_COM_EST=$(ME_COM_EST) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_MATRIXSSL=$(ME_COM_MATRIXSSL) -DME_COM_MDB=$(ME_COM_MDB) -DME_COM_NANOSSL=$(ME_COM_NANOSSL) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_PHP=$(ME_COM_PHP) -DME_COM_SQLITE=$(ME_COM_SQLITE) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_WINSDK=$(ME_COM_WINSDK) -DME_COM_ZLIB=$(ME_COM_ZLIB) 
IFLAGS                += "-I$(CONFIG)/inc -I$(WIND_BASE)/target/h -I$(WIND_BASE)/target/h/wrn/coreip"
LDFLAGS               += '-Wl,-r'
LIBPATHS              += -L$(CONFIG)/bin
LIBS                  += -lgcc

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

ME_ROOT_PREFIX        ?= deploy
ME_BASE_PREFIX        ?= $(ME_ROOT_PREFIX)
ME_DATA_PREFIX        ?= $(ME_VAPP_PREFIX)
ME_STATE_PREFIX       ?= $(ME_VAPP_PREFIX)
ME_BIN_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_INC_PREFIX         ?= $(ME_VAPP_PREFIX)/inc
ME_LIB_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_MAN_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_SBIN_PREFIX        ?= $(ME_VAPP_PREFIX)
ME_ETC_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_WEB_PREFIX         ?= $(ME_VAPP_PREFIX)/web
ME_LOG_PREFIX         ?= $(ME_VAPP_PREFIX)
ME_SPOOL_PREFIX       ?= $(ME_VAPP_PREFIX)
ME_CACHE_PREFIX       ?= $(ME_VAPP_PREFIX)
ME_APP_PREFIX         ?= $(ME_BASE_PREFIX)
ME_VAPP_PREFIX        ?= $(ME_APP_PREFIX)
ME_SRC_PREFIX         ?= $(ME_ROOT_PREFIX)/usr/src/$(NAME)-$(VERSION)


TARGETS               += $(CONFIG)/bin/appweb.out
TARGETS               += $(CONFIG)/bin/authpass.out
ifeq ($(ME_COM_CGI),1)
    TARGETS           += $(CONFIG)/bin/cgiProgram.out
endif
ifeq ($(ME_COM_EJS),1)
    TARGETS           += $(CONFIG)/bin/ejs.mod
endif
ifeq ($(ME_COM_EJS),1)
    TARGETS           += $(CONFIG)/bin/ejs.out
endif
ifeq ($(ME_COM_ESP),1)
    TARGETS           += $(CONFIG)/esp
endif
ifeq ($(ME_COM_ESP),1)
    TARGETS           += $(CONFIG)/bin/esp.conf
endif
ifeq ($(ME_COM_ESP),1)
    TARGETS           += $(CONFIG)/bin/esp.out
endif
TARGETS               += $(CONFIG)/bin/ca.crt
ifeq ($(ME_COM_HTTP),1)
    TARGETS           += $(CONFIG)/bin/http.out
endif
ifeq ($(ME_COM_EST),1)
    TARGETS           += $(CONFIG)/bin/libest.out
endif
ifeq ($(ME_COM_CGI),1)
    TARGETS           += $(CONFIG)/bin/libmod_cgi.out
endif
ifeq ($(ME_COM_EJS),1)
    TARGETS           += $(CONFIG)/bin/libmod_ejs.out
endif
ifeq ($(ME_COM_PHP),1)
    TARGETS           += $(CONFIG)/bin/libmod_php.out
endif
ifeq ($(ME_COM_SSL),1)
    TARGETS           += $(CONFIG)/bin/libmod_ssl.out
endif
ifeq ($(ME_COM_SQLITE),1)
    TARGETS           += $(CONFIG)/bin/libsql.out
endif
TARGETS               += $(CONFIG)/bin/appman.out
TARGETS               += src/server/cache
ifeq ($(ME_COM_SQLITE),1)
    TARGETS           += $(CONFIG)/bin/sqlite.out
endif
ifeq ($(ME_COM_CGI),1)
    TARGETS           += test/web/auth/basic/basic.cgi
endif
ifeq ($(ME_COM_CGI),1)
    TARGETS           += test/web/caching/cache.cgi
endif
ifeq ($(ME_COM_CGI),1)
    TARGETS           += test/cgi-bin/cgiProgram.out
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
	@if [ "$(WIND_BASE)" = "" ] ; then echo WARNING: WIND_BASE not set. Run wrenv.sh. ; exit 255 ; fi
	@if [ "$(WIND_HOST_TYPE)" = "" ] ; then echo WARNING: WIND_HOST_TYPE not set. Run wrenv.sh. ; exit 255 ; fi
	@if [ "$(WIND_GNU_PATH)" = "" ] ; then echo WARNING: WIND_GNU_PATH not set. Run wrenv.sh. ; exit 255 ; fi
	@[ ! -x $(CONFIG)/bin ] && mkdir -p $(CONFIG)/bin; true
	@[ ! -x $(CONFIG)/inc ] && mkdir -p $(CONFIG)/inc; true
	@[ ! -x $(CONFIG)/obj ] && mkdir -p $(CONFIG)/obj; true
	@[ ! -f $(CONFIG)/inc/osdep.h ] && cp src/paks/osdep/osdep.h $(CONFIG)/inc/osdep.h ; true
	@if ! diff $(CONFIG)/inc/osdep.h src/paks/osdep/osdep.h >/dev/null ; then\
		cp src/paks/osdep/osdep.h $(CONFIG)/inc/osdep.h  ; \
	fi; true
	@[ ! -f $(CONFIG)/inc/me.h ] && cp projects/appweb-vxworks-default-me.h $(CONFIG)/inc/me.h ; true
	@if ! diff $(CONFIG)/inc/me.h projects/appweb-vxworks-default-me.h >/dev/null ; then\
		cp projects/appweb-vxworks-default-me.h $(CONFIG)/inc/me.h  ; \
	fi; true
	@if [ -f "$(CONFIG)/.makeflags" ] ; then \
		if [ "$(MAKEFLAGS)" != " ` cat $(CONFIG)/.makeflags`" ] ; then \
			echo "   [Warning] Make flags have changed since the last build: "`cat $(CONFIG)/.makeflags`"" ; \
		fi ; \
	fi
	@echo $(MAKEFLAGS) >$(CONFIG)/.makeflags

clean:
	rm -f "$(CONFIG)/obj/appweb.o"
	rm -f "$(CONFIG)/obj/authpass.o"
	rm -f "$(CONFIG)/obj/cgiHandler.o"
	rm -f "$(CONFIG)/obj/cgiProgram.o"
	rm -f "$(CONFIG)/obj/config.o"
	rm -f "$(CONFIG)/obj/convenience.o"
	rm -f "$(CONFIG)/obj/dirHandler.o"
	rm -f "$(CONFIG)/obj/ejs.o"
	rm -f "$(CONFIG)/obj/ejsHandler.o"
	rm -f "$(CONFIG)/obj/ejsLib.o"
	rm -f "$(CONFIG)/obj/ejsc.o"
	rm -f "$(CONFIG)/obj/esp.o"
	rm -f "$(CONFIG)/obj/espLib.o"
	rm -f "$(CONFIG)/obj/estLib.o"
	rm -f "$(CONFIG)/obj/fileHandler.o"
	rm -f "$(CONFIG)/obj/http.o"
	rm -f "$(CONFIG)/obj/httpLib.o"
	rm -f "$(CONFIG)/obj/makerom.o"
	rm -f "$(CONFIG)/obj/manager.o"
	rm -f "$(CONFIG)/obj/mprLib.o"
	rm -f "$(CONFIG)/obj/mprSsl.o"
	rm -f "$(CONFIG)/obj/pcre.o"
	rm -f "$(CONFIG)/obj/phpHandler.o"
	rm -f "$(CONFIG)/obj/server.o"
	rm -f "$(CONFIG)/obj/slink.o"
	rm -f "$(CONFIG)/obj/sqlite.o"
	rm -f "$(CONFIG)/obj/sqlite3.o"
	rm -f "$(CONFIG)/obj/sslModule.o"
	rm -f "$(CONFIG)/obj/testAppweb.o"
	rm -f "$(CONFIG)/obj/testHttp.o"
	rm -f "$(CONFIG)/obj/zlib.o"
	rm -f "$(CONFIG)/bin/appweb.out"
	rm -f "$(CONFIG)/bin/authpass.out"
	rm -f "$(CONFIG)/bin/cgiProgram.out"
	rm -f "$(CONFIG)/bin/ejsc.out"
	rm -f "$(CONFIG)/bin/ejs.out"
	rm -f "$(CONFIG)/bin/esp.conf"
	rm -f "$(CONFIG)/bin/esp.out"
	rm -f "$(CONFIG)/bin/ca.crt"
	rm -f "$(CONFIG)/bin/http.out"
	rm -f "$(CONFIG)/bin/libappweb.out"
	rm -f "$(CONFIG)/bin/libejs.out"
	rm -f "$(CONFIG)/bin/libest.out"
	rm -f "$(CONFIG)/bin/libhttp.out"
	rm -f "$(CONFIG)/bin/libmod_cgi.out"
	rm -f "$(CONFIG)/bin/libmod_ejs.out"
	rm -f "$(CONFIG)/bin/libmod_esp.out"
	rm -f "$(CONFIG)/bin/libmod_php.out"
	rm -f "$(CONFIG)/bin/libmod_ssl.out"
	rm -f "$(CONFIG)/bin/libmpr.out"
	rm -f "$(CONFIG)/bin/libmprssl.out"
	rm -f "$(CONFIG)/bin/libpcre.out"
	rm -f "$(CONFIG)/bin/libslink.out"
	rm -f "$(CONFIG)/bin/libsql.out"
	rm -f "$(CONFIG)/bin/libzlib.out"
	rm -f "$(CONFIG)/bin/makerom.out"
	rm -f "$(CONFIG)/bin/appman.out"
	rm -f "$(CONFIG)/bin/sqlite.out"
	rm -f "$(CONFIG)/bin/testAppweb.out"

clobber: clean
	rm -fr ./$(CONFIG)


#
#   mpr.h
#
$(CONFIG)/inc/mpr.h: $(DEPS_1)
	@echo '      [Copy] $(CONFIG)/inc/mpr.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/mpr/mpr.h $(CONFIG)/inc/mpr.h

#
#   me.h
#
$(CONFIG)/inc/me.h: $(DEPS_2)
	@echo '      [Copy] $(CONFIG)/inc/me.h'

#
#   osdep.h
#
$(CONFIG)/inc/osdep.h: $(DEPS_3)
	@echo '      [Copy] $(CONFIG)/inc/osdep.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/osdep/osdep.h $(CONFIG)/inc/osdep.h

#
#   mprLib.o
#
DEPS_4 += $(CONFIG)/inc/me.h
DEPS_4 += $(CONFIG)/inc/mpr.h
DEPS_4 += $(CONFIG)/inc/osdep.h

$(CONFIG)/obj/mprLib.o: \
    src/paks/mpr/mprLib.c $(DEPS_4)
	@echo '   [Compile] $(CONFIG)/obj/mprLib.o'
	$(CC) -c -o $(CONFIG)/obj/mprLib.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/mpr/mprLib.c

#
#   libmpr
#
DEPS_5 += $(CONFIG)/inc/mpr.h
DEPS_5 += $(CONFIG)/inc/me.h
DEPS_5 += $(CONFIG)/inc/osdep.h
DEPS_5 += $(CONFIG)/obj/mprLib.o

$(CONFIG)/bin/libmpr.out: $(DEPS_5)
	@echo '      [Link] $(CONFIG)/bin/libmpr.out'
	$(CC) -r -o $(CONFIG)/bin/libmpr.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/mprLib.o" $(LIBS) 

#
#   pcre.h
#
$(CONFIG)/inc/pcre.h: $(DEPS_6)
	@echo '      [Copy] $(CONFIG)/inc/pcre.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/pcre/pcre.h $(CONFIG)/inc/pcre.h

#
#   pcre.o
#
DEPS_7 += $(CONFIG)/inc/me.h
DEPS_7 += $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/pcre.o: \
    src/paks/pcre/pcre.c $(DEPS_7)
	@echo '   [Compile] $(CONFIG)/obj/pcre.o'
	$(CC) -c -o $(CONFIG)/obj/pcre.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/pcre/pcre.c

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_8 += $(CONFIG)/inc/pcre.h
DEPS_8 += $(CONFIG)/inc/me.h
DEPS_8 += $(CONFIG)/obj/pcre.o

$(CONFIG)/bin/libpcre.out: $(DEPS_8)
	@echo '      [Link] $(CONFIG)/bin/libpcre.out'
	$(CC) -r -o $(CONFIG)/bin/libpcre.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/pcre.o" $(LIBS) 
endif

#
#   http.h
#
$(CONFIG)/inc/http.h: $(DEPS_9)
	@echo '      [Copy] $(CONFIG)/inc/http.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/http/http.h $(CONFIG)/inc/http.h

#
#   httpLib.o
#
DEPS_10 += $(CONFIG)/inc/me.h
DEPS_10 += $(CONFIG)/inc/http.h
DEPS_10 += $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/httpLib.o: \
    src/paks/http/httpLib.c $(DEPS_10)
	@echo '   [Compile] $(CONFIG)/obj/httpLib.o'
	$(CC) -c -o $(CONFIG)/obj/httpLib.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/http/httpLib.c

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_11 += $(CONFIG)/inc/mpr.h
DEPS_11 += $(CONFIG)/inc/me.h
DEPS_11 += $(CONFIG)/inc/osdep.h
DEPS_11 += $(CONFIG)/obj/mprLib.o
DEPS_11 += $(CONFIG)/bin/libmpr.out
DEPS_11 += $(CONFIG)/inc/pcre.h
DEPS_11 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_11 += $(CONFIG)/bin/libpcre.out
endif
DEPS_11 += $(CONFIG)/inc/http.h
DEPS_11 += $(CONFIG)/obj/httpLib.o

$(CONFIG)/bin/libhttp.out: $(DEPS_11)
	@echo '      [Link] $(CONFIG)/bin/libhttp.out'
	$(CC) -r -o $(CONFIG)/bin/libhttp.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/httpLib.o" $(LIBS) 
endif

#
#   appweb.h
#
$(CONFIG)/inc/appweb.h: $(DEPS_12)
	@echo '      [Copy] $(CONFIG)/inc/appweb.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/appweb.h $(CONFIG)/inc/appweb.h

#
#   customize.h
#
$(CONFIG)/inc/customize.h: $(DEPS_13)
	@echo '      [Copy] $(CONFIG)/inc/customize.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/customize.h $(CONFIG)/inc/customize.h

#
#   config.o
#
DEPS_14 += $(CONFIG)/inc/me.h
DEPS_14 += $(CONFIG)/inc/appweb.h
DEPS_14 += $(CONFIG)/inc/pcre.h
DEPS_14 += $(CONFIG)/inc/mpr.h
DEPS_14 += $(CONFIG)/inc/http.h
DEPS_14 += $(CONFIG)/inc/customize.h

$(CONFIG)/obj/config.o: \
    src/config.c $(DEPS_14)
	@echo '   [Compile] $(CONFIG)/obj/config.o'
	$(CC) -c -o $(CONFIG)/obj/config.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/config.c

#
#   convenience.o
#
DEPS_15 += $(CONFIG)/inc/me.h
DEPS_15 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/convenience.o: \
    src/convenience.c $(DEPS_15)
	@echo '   [Compile] $(CONFIG)/obj/convenience.o'
	$(CC) -c -o $(CONFIG)/obj/convenience.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/convenience.c

#
#   dirHandler.o
#
DEPS_16 += $(CONFIG)/inc/me.h
DEPS_16 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/dirHandler.o: \
    src/dirHandler.c $(DEPS_16)
	@echo '   [Compile] $(CONFIG)/obj/dirHandler.o'
	$(CC) -c -o $(CONFIG)/obj/dirHandler.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/dirHandler.c

#
#   fileHandler.o
#
DEPS_17 += $(CONFIG)/inc/me.h
DEPS_17 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/fileHandler.o: \
    src/fileHandler.c $(DEPS_17)
	@echo '   [Compile] $(CONFIG)/obj/fileHandler.o'
	$(CC) -c -o $(CONFIG)/obj/fileHandler.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/fileHandler.c

#
#   server.o
#
DEPS_18 += $(CONFIG)/inc/me.h
DEPS_18 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/server.o: \
    src/server.c $(DEPS_18)
	@echo '   [Compile] $(CONFIG)/obj/server.o'
	$(CC) -c -o $(CONFIG)/obj/server.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/server.c

#
#   libappweb
#
DEPS_19 += $(CONFIG)/inc/mpr.h
DEPS_19 += $(CONFIG)/inc/me.h
DEPS_19 += $(CONFIG)/inc/osdep.h
DEPS_19 += $(CONFIG)/obj/mprLib.o
DEPS_19 += $(CONFIG)/bin/libmpr.out
DEPS_19 += $(CONFIG)/inc/pcre.h
DEPS_19 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_19 += $(CONFIG)/bin/libpcre.out
endif
DEPS_19 += $(CONFIG)/inc/http.h
DEPS_19 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_19 += $(CONFIG)/bin/libhttp.out
endif
DEPS_19 += $(CONFIG)/inc/appweb.h
DEPS_19 += $(CONFIG)/inc/customize.h
DEPS_19 += $(CONFIG)/obj/config.o
DEPS_19 += $(CONFIG)/obj/convenience.o
DEPS_19 += $(CONFIG)/obj/dirHandler.o
DEPS_19 += $(CONFIG)/obj/fileHandler.o
DEPS_19 += $(CONFIG)/obj/server.o

$(CONFIG)/bin/libappweb.out: $(DEPS_19)
	@echo '      [Link] $(CONFIG)/bin/libappweb.out'
	$(CC) -r -o $(CONFIG)/bin/libappweb.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/config.o" "$(CONFIG)/obj/convenience.o" "$(CONFIG)/obj/dirHandler.o" "$(CONFIG)/obj/fileHandler.o" "$(CONFIG)/obj/server.o" $(LIBS) 

#
#   slink.c
#
src/slink.c: $(DEPS_20)
	( \
	cd src; \
	[ ! -f slink.c ] && cp slink.empty slink.c ; true ; \
	)

#
#   esp.h
#
$(CONFIG)/inc/esp.h: $(DEPS_21)
	@echo '      [Copy] $(CONFIG)/inc/esp.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/esp/esp.h $(CONFIG)/inc/esp.h

#
#   slink.o
#
DEPS_22 += $(CONFIG)/inc/me.h
DEPS_22 += $(CONFIG)/inc/mpr.h
DEPS_22 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/slink.o: \
    src/slink.c $(DEPS_22)
	@echo '   [Compile] $(CONFIG)/obj/slink.o'
	$(CC) -c -o $(CONFIG)/obj/slink.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/slink.c

#
#   libslink
#
DEPS_23 += src/slink.c
DEPS_23 += $(CONFIG)/inc/me.h
DEPS_23 += $(CONFIG)/inc/mpr.h
DEPS_23 += $(CONFIG)/inc/esp.h
DEPS_23 += $(CONFIG)/obj/slink.o

$(CONFIG)/bin/libslink.out: $(DEPS_23)
	@echo '      [Link] $(CONFIG)/bin/libslink.out'
	$(CC) -r -o $(CONFIG)/bin/libslink.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/slink.o" $(LIBS) 

#
#   appweb.o
#
DEPS_24 += $(CONFIG)/inc/me.h
DEPS_24 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/appweb.o: \
    src/server/appweb.c $(DEPS_24)
	@echo '   [Compile] $(CONFIG)/obj/appweb.o'
	$(CC) -c -o $(CONFIG)/obj/appweb.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/server/appweb.c

#
#   appweb
#
DEPS_25 += $(CONFIG)/inc/mpr.h
DEPS_25 += $(CONFIG)/inc/me.h
DEPS_25 += $(CONFIG)/inc/osdep.h
DEPS_25 += $(CONFIG)/obj/mprLib.o
DEPS_25 += $(CONFIG)/bin/libmpr.out
DEPS_25 += $(CONFIG)/inc/pcre.h
DEPS_25 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_25 += $(CONFIG)/bin/libpcre.out
endif
DEPS_25 += $(CONFIG)/inc/http.h
DEPS_25 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_25 += $(CONFIG)/bin/libhttp.out
endif
DEPS_25 += $(CONFIG)/inc/appweb.h
DEPS_25 += $(CONFIG)/inc/customize.h
DEPS_25 += $(CONFIG)/obj/config.o
DEPS_25 += $(CONFIG)/obj/convenience.o
DEPS_25 += $(CONFIG)/obj/dirHandler.o
DEPS_25 += $(CONFIG)/obj/fileHandler.o
DEPS_25 += $(CONFIG)/obj/server.o
DEPS_25 += $(CONFIG)/bin/libappweb.out
DEPS_25 += src/slink.c
DEPS_25 += $(CONFIG)/inc/esp.h
DEPS_25 += $(CONFIG)/obj/slink.o
DEPS_25 += $(CONFIG)/bin/libslink.out
DEPS_25 += $(CONFIG)/obj/appweb.o

$(CONFIG)/bin/appweb.out: $(DEPS_25)
	@echo '      [Link] $(CONFIG)/bin/appweb.out'
	$(CC) -o $(CONFIG)/bin/appweb.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/appweb.o" $(LIBS) -Wl,-r 

#
#   authpass.o
#
DEPS_26 += $(CONFIG)/inc/me.h
DEPS_26 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/authpass.o: \
    src/utils/authpass.c $(DEPS_26)
	@echo '   [Compile] $(CONFIG)/obj/authpass.o'
	$(CC) -c -o $(CONFIG)/obj/authpass.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/utils/authpass.c

#
#   authpass
#
DEPS_27 += $(CONFIG)/inc/mpr.h
DEPS_27 += $(CONFIG)/inc/me.h
DEPS_27 += $(CONFIG)/inc/osdep.h
DEPS_27 += $(CONFIG)/obj/mprLib.o
DEPS_27 += $(CONFIG)/bin/libmpr.out
DEPS_27 += $(CONFIG)/inc/pcre.h
DEPS_27 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_27 += $(CONFIG)/bin/libpcre.out
endif
DEPS_27 += $(CONFIG)/inc/http.h
DEPS_27 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_27 += $(CONFIG)/bin/libhttp.out
endif
DEPS_27 += $(CONFIG)/inc/appweb.h
DEPS_27 += $(CONFIG)/inc/customize.h
DEPS_27 += $(CONFIG)/obj/config.o
DEPS_27 += $(CONFIG)/obj/convenience.o
DEPS_27 += $(CONFIG)/obj/dirHandler.o
DEPS_27 += $(CONFIG)/obj/fileHandler.o
DEPS_27 += $(CONFIG)/obj/server.o
DEPS_27 += $(CONFIG)/bin/libappweb.out
DEPS_27 += $(CONFIG)/obj/authpass.o

$(CONFIG)/bin/authpass.out: $(DEPS_27)
	@echo '      [Link] $(CONFIG)/bin/authpass.out'
	$(CC) -o $(CONFIG)/bin/authpass.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/authpass.o" $(LIBS) -Wl,-r 

#
#   cgiProgram.o
#
DEPS_28 += $(CONFIG)/inc/me.h

$(CONFIG)/obj/cgiProgram.o: \
    src/utils/cgiProgram.c $(DEPS_28)
	@echo '   [Compile] $(CONFIG)/obj/cgiProgram.o'
	$(CC) -c -o $(CONFIG)/obj/cgiProgram.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/utils/cgiProgram.c

ifeq ($(ME_COM_CGI),1)
#
#   cgiProgram
#
DEPS_29 += $(CONFIG)/inc/me.h
DEPS_29 += $(CONFIG)/obj/cgiProgram.o

$(CONFIG)/bin/cgiProgram.out: $(DEPS_29)
	@echo '      [Link] $(CONFIG)/bin/cgiProgram.out'
	$(CC) -o $(CONFIG)/bin/cgiProgram.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/cgiProgram.o" $(LIBS) -Wl,-r 
endif

#
#   zlib.h
#
$(CONFIG)/inc/zlib.h: $(DEPS_30)
	@echo '      [Copy] $(CONFIG)/inc/zlib.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/zlib/zlib.h $(CONFIG)/inc/zlib.h

#
#   zlib.o
#
DEPS_31 += $(CONFIG)/inc/me.h
DEPS_31 += $(CONFIG)/inc/zlib.h

$(CONFIG)/obj/zlib.o: \
    src/paks/zlib/zlib.c $(DEPS_31)
	@echo '   [Compile] $(CONFIG)/obj/zlib.o'
	$(CC) -c -o $(CONFIG)/obj/zlib.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/zlib/zlib.c

ifeq ($(ME_COM_ZLIB),1)
#
#   libzlib
#
DEPS_32 += $(CONFIG)/inc/zlib.h
DEPS_32 += $(CONFIG)/inc/me.h
DEPS_32 += $(CONFIG)/obj/zlib.o

$(CONFIG)/bin/libzlib.out: $(DEPS_32)
	@echo '      [Link] $(CONFIG)/bin/libzlib.out'
	$(CC) -r -o $(CONFIG)/bin/libzlib.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/zlib.o" $(LIBS) 
endif

#
#   ejs.h
#
$(CONFIG)/inc/ejs.h: $(DEPS_33)
	@echo '      [Copy] $(CONFIG)/inc/ejs.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/ejs/ejs.h $(CONFIG)/inc/ejs.h

#
#   ejs.slots.h
#
$(CONFIG)/inc/ejs.slots.h: $(DEPS_34)
	@echo '      [Copy] $(CONFIG)/inc/ejs.slots.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/ejs/ejs.slots.h $(CONFIG)/inc/ejs.slots.h

#
#   ejsByteGoto.h
#
$(CONFIG)/inc/ejsByteGoto.h: $(DEPS_35)
	@echo '      [Copy] $(CONFIG)/inc/ejsByteGoto.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/ejs/ejsByteGoto.h $(CONFIG)/inc/ejsByteGoto.h

#
#   ejsLib.o
#
DEPS_36 += $(CONFIG)/inc/me.h
DEPS_36 += $(CONFIG)/inc/ejs.h
DEPS_36 += $(CONFIG)/inc/mpr.h
DEPS_36 += $(CONFIG)/inc/pcre.h
DEPS_36 += $(CONFIG)/inc/osdep.h
DEPS_36 += $(CONFIG)/inc/http.h
DEPS_36 += $(CONFIG)/inc/ejs.slots.h
DEPS_36 += $(CONFIG)/inc/zlib.h

$(CONFIG)/obj/ejsLib.o: \
    src/paks/ejs/ejsLib.c $(DEPS_36)
	@echo '   [Compile] $(CONFIG)/obj/ejsLib.o'
	$(CC) -c -o $(CONFIG)/obj/ejsLib.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/ejs/ejsLib.c

ifeq ($(ME_COM_EJS),1)
#
#   libejs
#
DEPS_37 += $(CONFIG)/inc/mpr.h
DEPS_37 += $(CONFIG)/inc/me.h
DEPS_37 += $(CONFIG)/inc/osdep.h
DEPS_37 += $(CONFIG)/obj/mprLib.o
DEPS_37 += $(CONFIG)/bin/libmpr.out
DEPS_37 += $(CONFIG)/inc/pcre.h
DEPS_37 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_37 += $(CONFIG)/bin/libpcre.out
endif
DEPS_37 += $(CONFIG)/inc/http.h
DEPS_37 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_37 += $(CONFIG)/bin/libhttp.out
endif
DEPS_37 += $(CONFIG)/inc/zlib.h
DEPS_37 += $(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_37 += $(CONFIG)/bin/libzlib.out
endif
DEPS_37 += $(CONFIG)/inc/ejs.h
DEPS_37 += $(CONFIG)/inc/ejs.slots.h
DEPS_37 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_37 += $(CONFIG)/obj/ejsLib.o

$(CONFIG)/bin/libejs.out: $(DEPS_37)
	@echo '      [Link] $(CONFIG)/bin/libejs.out'
	$(CC) -r -o $(CONFIG)/bin/libejs.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/ejsLib.o" $(LIBS) 
endif

#
#   ejsc.o
#
DEPS_38 += $(CONFIG)/inc/me.h
DEPS_38 += $(CONFIG)/inc/ejs.h

$(CONFIG)/obj/ejsc.o: \
    src/paks/ejs/ejsc.c $(DEPS_38)
	@echo '   [Compile] $(CONFIG)/obj/ejsc.o'
	$(CC) -c -o $(CONFIG)/obj/ejsc.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/ejs/ejsc.c

ifeq ($(ME_COM_EJS),1)
#
#   ejsc
#
DEPS_39 += $(CONFIG)/inc/mpr.h
DEPS_39 += $(CONFIG)/inc/me.h
DEPS_39 += $(CONFIG)/inc/osdep.h
DEPS_39 += $(CONFIG)/obj/mprLib.o
DEPS_39 += $(CONFIG)/bin/libmpr.out
DEPS_39 += $(CONFIG)/inc/pcre.h
DEPS_39 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_39 += $(CONFIG)/bin/libpcre.out
endif
DEPS_39 += $(CONFIG)/inc/http.h
DEPS_39 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_39 += $(CONFIG)/bin/libhttp.out
endif
DEPS_39 += $(CONFIG)/inc/zlib.h
DEPS_39 += $(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_39 += $(CONFIG)/bin/libzlib.out
endif
DEPS_39 += $(CONFIG)/inc/ejs.h
DEPS_39 += $(CONFIG)/inc/ejs.slots.h
DEPS_39 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_39 += $(CONFIG)/obj/ejsLib.o
DEPS_39 += $(CONFIG)/bin/libejs.out
DEPS_39 += $(CONFIG)/obj/ejsc.o

$(CONFIG)/bin/ejsc.out: $(DEPS_39)
	@echo '      [Link] $(CONFIG)/bin/ejsc.out'
	$(CC) -o $(CONFIG)/bin/ejsc.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/ejsc.o" $(LIBS) -Wl,-r 
endif

ifeq ($(ME_COM_EJS),1)
#
#   ejs.mod
#
DEPS_40 += src/paks/ejs/ejs.es
DEPS_40 += $(CONFIG)/inc/mpr.h
DEPS_40 += $(CONFIG)/inc/me.h
DEPS_40 += $(CONFIG)/inc/osdep.h
DEPS_40 += $(CONFIG)/obj/mprLib.o
DEPS_40 += $(CONFIG)/bin/libmpr.out
DEPS_40 += $(CONFIG)/inc/pcre.h
DEPS_40 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_40 += $(CONFIG)/bin/libpcre.out
endif
DEPS_40 += $(CONFIG)/inc/http.h
DEPS_40 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_40 += $(CONFIG)/bin/libhttp.out
endif
DEPS_40 += $(CONFIG)/inc/zlib.h
DEPS_40 += $(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_40 += $(CONFIG)/bin/libzlib.out
endif
DEPS_40 += $(CONFIG)/inc/ejs.h
DEPS_40 += $(CONFIG)/inc/ejs.slots.h
DEPS_40 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_40 += $(CONFIG)/obj/ejsLib.o
DEPS_40 += $(CONFIG)/bin/libejs.out
DEPS_40 += $(CONFIG)/obj/ejsc.o
DEPS_40 += $(CONFIG)/bin/ejsc.out

$(CONFIG)/bin/ejs.mod: $(DEPS_40)
	( \
	cd src/paks/ejs; \
	../../../$(LBIN)/ejsc --out ../../../$(CONFIG)/bin/ejs.mod --optimize 9 --bind --require null ejs.es ; \
	)
endif

#
#   ejs.o
#
DEPS_41 += $(CONFIG)/inc/me.h
DEPS_41 += $(CONFIG)/inc/ejs.h

$(CONFIG)/obj/ejs.o: \
    src/paks/ejs/ejs.c $(DEPS_41)
	@echo '   [Compile] $(CONFIG)/obj/ejs.o'
	$(CC) -c -o $(CONFIG)/obj/ejs.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/ejs/ejs.c

ifeq ($(ME_COM_EJS),1)
#
#   ejscmd
#
DEPS_42 += $(CONFIG)/inc/mpr.h
DEPS_42 += $(CONFIG)/inc/me.h
DEPS_42 += $(CONFIG)/inc/osdep.h
DEPS_42 += $(CONFIG)/obj/mprLib.o
DEPS_42 += $(CONFIG)/bin/libmpr.out
DEPS_42 += $(CONFIG)/inc/pcre.h
DEPS_42 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_42 += $(CONFIG)/bin/libpcre.out
endif
DEPS_42 += $(CONFIG)/inc/http.h
DEPS_42 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_42 += $(CONFIG)/bin/libhttp.out
endif
DEPS_42 += $(CONFIG)/inc/zlib.h
DEPS_42 += $(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_42 += $(CONFIG)/bin/libzlib.out
endif
DEPS_42 += $(CONFIG)/inc/ejs.h
DEPS_42 += $(CONFIG)/inc/ejs.slots.h
DEPS_42 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_42 += $(CONFIG)/obj/ejsLib.o
DEPS_42 += $(CONFIG)/bin/libejs.out
DEPS_42 += $(CONFIG)/obj/ejs.o

$(CONFIG)/bin/ejs.out: $(DEPS_42)
	@echo '      [Link] $(CONFIG)/bin/ejs.out'
	$(CC) -o $(CONFIG)/bin/ejs.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/ejs.o" $(LIBS) -Wl,-r 
endif

ifeq ($(ME_COM_ESP),1)
#
#   esp-paks
#
DEPS_43 += src/paks/esp-html-mvc
DEPS_43 += src/paks/esp-html-mvc/client
DEPS_43 += src/paks/esp-html-mvc/client/assets
DEPS_43 += src/paks/esp-html-mvc/client/assets/favicon.ico
DEPS_43 += src/paks/esp-html-mvc/client/css
DEPS_43 += src/paks/esp-html-mvc/client/css/all.css
DEPS_43 += src/paks/esp-html-mvc/client/css/all.less
DEPS_43 += src/paks/esp-html-mvc/client/index.esp
DEPS_43 += src/paks/esp-html-mvc/css
DEPS_43 += src/paks/esp-html-mvc/css/app.less
DEPS_43 += src/paks/esp-html-mvc/css/theme.less
DEPS_43 += src/paks/esp-html-mvc/generate
DEPS_43 += src/paks/esp-html-mvc/generate/appweb.conf
DEPS_43 += src/paks/esp-html-mvc/generate/controller.c
DEPS_43 += src/paks/esp-html-mvc/generate/controllerSingleton.c
DEPS_43 += src/paks/esp-html-mvc/generate/edit.esp
DEPS_43 += src/paks/esp-html-mvc/generate/list.esp
DEPS_43 += src/paks/esp-html-mvc/layouts
DEPS_43 += src/paks/esp-html-mvc/layouts/default.esp
DEPS_43 += src/paks/esp-html-mvc/LICENSE.md
DEPS_43 += src/paks/esp-html-mvc/package.json
DEPS_43 += src/paks/esp-html-mvc/README.md
DEPS_43 += src/paks/esp-mvc
DEPS_43 += src/paks/esp-mvc/generate
DEPS_43 += src/paks/esp-mvc/generate/appweb.conf
DEPS_43 += src/paks/esp-mvc/generate/controller.c
DEPS_43 += src/paks/esp-mvc/generate/migration.c
DEPS_43 += src/paks/esp-mvc/generate/src
DEPS_43 += src/paks/esp-mvc/generate/src/app.c
DEPS_43 += src/paks/esp-mvc/LICENSE.md
DEPS_43 += src/paks/esp-mvc/package.json
DEPS_43 += src/paks/esp-mvc/README.md
DEPS_43 += src/paks/esp-server
DEPS_43 += src/paks/esp-server/generate
DEPS_43 += src/paks/esp-server/generate/appweb.conf
DEPS_43 += src/paks/esp-server/LICENSE.md
DEPS_43 += src/paks/esp-server/package.json
DEPS_43 += src/paks/esp-server/README.md

$(CONFIG)/esp: $(DEPS_43)
	( \
	cd src/paks; \
	mkdir -p "../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2" ; \
	mkdir -p "../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/client" ; \
	mkdir -p "../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/client/assets" ; \
	cp esp-html-mvc/client/assets/favicon.ico ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/client/assets/favicon.ico ; \
	mkdir -p "../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/client/css" ; \
	cp esp-html-mvc/client/css/all.css ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/client/css/all.css ; \
	cp esp-html-mvc/client/css/all.less ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/client/css/all.less ; \
	cp esp-html-mvc/client/index.esp ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/client/index.esp ; \
	mkdir -p "../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/css" ; \
	cp esp-html-mvc/css/app.less ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/css/app.less ; \
	cp esp-html-mvc/css/theme.less ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/css/theme.less ; \
	mkdir -p "../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/generate" ; \
	cp esp-html-mvc/generate/appweb.conf ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/generate/appweb.conf ; \
	cp esp-html-mvc/generate/controller.c ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/generate/controller.c ; \
	cp esp-html-mvc/generate/controllerSingleton.c ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/generate/controllerSingleton.c ; \
	cp esp-html-mvc/generate/edit.esp ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/generate/edit.esp ; \
	cp esp-html-mvc/generate/list.esp ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/generate/list.esp ; \
	mkdir -p "../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/layouts" ; \
	cp esp-html-mvc/layouts/default.esp ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/layouts/default.esp ; \
	cp esp-html-mvc/LICENSE.md ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/LICENSE.md ; \
	cp esp-html-mvc/package.json ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/package.json ; \
	cp esp-html-mvc/README.md ../../$(CONFIG)/esp/esp-html-mvc/5.0.0-rc2/README.md ; \
	mkdir -p "../../$(CONFIG)/esp/esp-mvc/5.0.0-rc2" ; \
	mkdir -p "../../$(CONFIG)/esp/esp-mvc/5.0.0-rc2/generate" ; \
	cp esp-mvc/generate/appweb.conf ../../$(CONFIG)/esp/esp-mvc/5.0.0-rc2/generate/appweb.conf ; \
	cp esp-mvc/generate/controller.c ../../$(CONFIG)/esp/esp-mvc/5.0.0-rc2/generate/controller.c ; \
	cp esp-mvc/generate/migration.c ../../$(CONFIG)/esp/esp-mvc/5.0.0-rc2/generate/migration.c ; \
	mkdir -p "../../$(CONFIG)/esp/esp-mvc/5.0.0-rc2/generate/src" ; \
	cp esp-mvc/generate/src/app.c ../../$(CONFIG)/esp/esp-mvc/5.0.0-rc2/generate/src/app.c ; \
	cp esp-mvc/LICENSE.md ../../$(CONFIG)/esp/esp-mvc/5.0.0-rc2/LICENSE.md ; \
	cp esp-mvc/package.json ../../$(CONFIG)/esp/esp-mvc/5.0.0-rc2/package.json ; \
	cp esp-mvc/README.md ../../$(CONFIG)/esp/esp-mvc/5.0.0-rc2/README.md ; \
	mkdir -p "../../$(CONFIG)/esp/esp-server/5.0.0-rc2" ; \
	mkdir -p "../../$(CONFIG)/esp/esp-server/5.0.0-rc2/generate" ; \
	cp esp-server/generate/appweb.conf ../../$(CONFIG)/esp/esp-server/5.0.0-rc2/generate/appweb.conf ; \
	cp esp-server/LICENSE.md ../../$(CONFIG)/esp/esp-server/5.0.0-rc2/LICENSE.md ; \
	cp esp-server/package.json ../../$(CONFIG)/esp/esp-server/5.0.0-rc2/package.json ; \
	cp esp-server/README.md ../../$(CONFIG)/esp/esp-server/5.0.0-rc2/README.md ; \
	)
endif

ifeq ($(ME_COM_ESP),1)
#
#   esp.conf
#
DEPS_44 += src/paks/esp/esp.conf

$(CONFIG)/bin/esp.conf: $(DEPS_44)
	@echo '      [Copy] $(CONFIG)/bin/esp.conf'
	mkdir -p "$(CONFIG)/bin"
	cp src/paks/esp/esp.conf $(CONFIG)/bin/esp.conf
endif

#
#   espLib.o
#
DEPS_45 += $(CONFIG)/inc/me.h
DEPS_45 += $(CONFIG)/inc/esp.h
DEPS_45 += $(CONFIG)/inc/pcre.h
DEPS_45 += $(CONFIG)/inc/http.h
DEPS_45 += $(CONFIG)/inc/osdep.h
DEPS_45 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/espLib.o: \
    src/paks/esp/espLib.c $(DEPS_45)
	@echo '   [Compile] $(CONFIG)/obj/espLib.o'
	$(CC) -c -o $(CONFIG)/obj/espLib.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/esp/espLib.c

ifeq ($(ME_COM_ESP),1)
#
#   libmod_esp
#
DEPS_46 += $(CONFIG)/inc/mpr.h
DEPS_46 += $(CONFIG)/inc/me.h
DEPS_46 += $(CONFIG)/inc/osdep.h
DEPS_46 += $(CONFIG)/obj/mprLib.o
DEPS_46 += $(CONFIG)/bin/libmpr.out
DEPS_46 += $(CONFIG)/inc/pcre.h
DEPS_46 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_46 += $(CONFIG)/bin/libpcre.out
endif
DEPS_46 += $(CONFIG)/inc/http.h
DEPS_46 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_46 += $(CONFIG)/bin/libhttp.out
endif
DEPS_46 += $(CONFIG)/inc/appweb.h
DEPS_46 += $(CONFIG)/inc/customize.h
DEPS_46 += $(CONFIG)/obj/config.o
DEPS_46 += $(CONFIG)/obj/convenience.o
DEPS_46 += $(CONFIG)/obj/dirHandler.o
DEPS_46 += $(CONFIG)/obj/fileHandler.o
DEPS_46 += $(CONFIG)/obj/server.o
DEPS_46 += $(CONFIG)/bin/libappweb.out
DEPS_46 += $(CONFIG)/inc/esp.h
DEPS_46 += $(CONFIG)/obj/espLib.o

$(CONFIG)/bin/libmod_esp.out: $(DEPS_46)
	@echo '      [Link] $(CONFIG)/bin/libmod_esp.out'
	$(CC) -r -o $(CONFIG)/bin/libmod_esp.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/espLib.o" $(LIBS) 
endif

#
#   esp.o
#
DEPS_47 += $(CONFIG)/inc/me.h
DEPS_47 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/esp.o: \
    src/paks/esp/esp.c $(DEPS_47)
	@echo '   [Compile] $(CONFIG)/obj/esp.o'
	$(CC) -c -o $(CONFIG)/obj/esp.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/esp/esp.c

ifeq ($(ME_COM_ESP),1)
#
#   espcmd
#
DEPS_48 += $(CONFIG)/inc/mpr.h
DEPS_48 += $(CONFIG)/inc/me.h
DEPS_48 += $(CONFIG)/inc/osdep.h
DEPS_48 += $(CONFIG)/obj/mprLib.o
DEPS_48 += $(CONFIG)/bin/libmpr.out
DEPS_48 += $(CONFIG)/inc/pcre.h
DEPS_48 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_48 += $(CONFIG)/bin/libpcre.out
endif
DEPS_48 += $(CONFIG)/inc/http.h
DEPS_48 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_48 += $(CONFIG)/bin/libhttp.out
endif
DEPS_48 += $(CONFIG)/inc/appweb.h
DEPS_48 += $(CONFIG)/inc/customize.h
DEPS_48 += $(CONFIG)/obj/config.o
DEPS_48 += $(CONFIG)/obj/convenience.o
DEPS_48 += $(CONFIG)/obj/dirHandler.o
DEPS_48 += $(CONFIG)/obj/fileHandler.o
DEPS_48 += $(CONFIG)/obj/server.o
DEPS_48 += $(CONFIG)/bin/libappweb.out
DEPS_48 += $(CONFIG)/inc/esp.h
DEPS_48 += $(CONFIG)/obj/espLib.o
DEPS_48 += $(CONFIG)/bin/libmod_esp.out
DEPS_48 += $(CONFIG)/obj/esp.o

$(CONFIG)/bin/esp.out: $(DEPS_48)
	@echo '      [Link] $(CONFIG)/bin/esp.out'
	$(CC) -o $(CONFIG)/bin/esp.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/esp.o" $(LIBS) -Wl,-r 
endif


#
#   genslink
#
genslink: $(DEPS_49)
	( \
	cd src; \
	esp --static --genlink slink.c compile ; \
	)

#
#   http-ca-crt
#
DEPS_50 += src/paks/http/ca.crt

$(CONFIG)/bin/ca.crt: $(DEPS_50)
	@echo '      [Copy] $(CONFIG)/bin/ca.crt'
	mkdir -p "$(CONFIG)/bin"
	cp src/paks/http/ca.crt $(CONFIG)/bin/ca.crt

#
#   http.o
#
DEPS_51 += $(CONFIG)/inc/me.h
DEPS_51 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/http.o: \
    src/paks/http/http.c $(DEPS_51)
	@echo '   [Compile] $(CONFIG)/obj/http.o'
	$(CC) -c -o $(CONFIG)/obj/http.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/http/http.c

ifeq ($(ME_COM_HTTP),1)
#
#   httpcmd
#
DEPS_52 += $(CONFIG)/inc/mpr.h
DEPS_52 += $(CONFIG)/inc/me.h
DEPS_52 += $(CONFIG)/inc/osdep.h
DEPS_52 += $(CONFIG)/obj/mprLib.o
DEPS_52 += $(CONFIG)/bin/libmpr.out
DEPS_52 += $(CONFIG)/inc/pcre.h
DEPS_52 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_52 += $(CONFIG)/bin/libpcre.out
endif
DEPS_52 += $(CONFIG)/inc/http.h
DEPS_52 += $(CONFIG)/obj/httpLib.o
DEPS_52 += $(CONFIG)/bin/libhttp.out
DEPS_52 += $(CONFIG)/obj/http.o

$(CONFIG)/bin/http.out: $(DEPS_52)
	@echo '      [Link] $(CONFIG)/bin/http.out'
	$(CC) -o $(CONFIG)/bin/http.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/http.o" $(LIBS) -Wl,-r 
endif

#
#   est.h
#
$(CONFIG)/inc/est.h: $(DEPS_53)
	@echo '      [Copy] $(CONFIG)/inc/est.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/est/est.h $(CONFIG)/inc/est.h

#
#   estLib.o
#
DEPS_54 += $(CONFIG)/inc/me.h
DEPS_54 += $(CONFIG)/inc/est.h
DEPS_54 += $(CONFIG)/inc/osdep.h

$(CONFIG)/obj/estLib.o: \
    src/paks/est/estLib.c $(DEPS_54)
	@echo '   [Compile] $(CONFIG)/obj/estLib.o'
	$(CC) -c -o $(CONFIG)/obj/estLib.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/est/estLib.c

ifeq ($(ME_COM_EST),1)
#
#   libest
#
DEPS_55 += $(CONFIG)/inc/est.h
DEPS_55 += $(CONFIG)/inc/me.h
DEPS_55 += $(CONFIG)/inc/osdep.h
DEPS_55 += $(CONFIG)/obj/estLib.o

$(CONFIG)/bin/libest.out: $(DEPS_55)
	@echo '      [Link] $(CONFIG)/bin/libest.out'
	$(CC) -r -o $(CONFIG)/bin/libest.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/estLib.o" $(LIBS) 
endif

#
#   cgiHandler.o
#
DEPS_56 += $(CONFIG)/inc/me.h
DEPS_56 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/cgiHandler.o: \
    src/modules/cgiHandler.c $(DEPS_56)
	@echo '   [Compile] $(CONFIG)/obj/cgiHandler.o'
	$(CC) -c -o $(CONFIG)/obj/cgiHandler.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/modules/cgiHandler.c

ifeq ($(ME_COM_CGI),1)
#
#   libmod_cgi
#
DEPS_57 += $(CONFIG)/inc/mpr.h
DEPS_57 += $(CONFIG)/inc/me.h
DEPS_57 += $(CONFIG)/inc/osdep.h
DEPS_57 += $(CONFIG)/obj/mprLib.o
DEPS_57 += $(CONFIG)/bin/libmpr.out
DEPS_57 += $(CONFIG)/inc/pcre.h
DEPS_57 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_57 += $(CONFIG)/bin/libpcre.out
endif
DEPS_57 += $(CONFIG)/inc/http.h
DEPS_57 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_57 += $(CONFIG)/bin/libhttp.out
endif
DEPS_57 += $(CONFIG)/inc/appweb.h
DEPS_57 += $(CONFIG)/inc/customize.h
DEPS_57 += $(CONFIG)/obj/config.o
DEPS_57 += $(CONFIG)/obj/convenience.o
DEPS_57 += $(CONFIG)/obj/dirHandler.o
DEPS_57 += $(CONFIG)/obj/fileHandler.o
DEPS_57 += $(CONFIG)/obj/server.o
DEPS_57 += $(CONFIG)/bin/libappweb.out
DEPS_57 += $(CONFIG)/obj/cgiHandler.o

$(CONFIG)/bin/libmod_cgi.out: $(DEPS_57)
	@echo '      [Link] $(CONFIG)/bin/libmod_cgi.out'
	$(CC) -r -o $(CONFIG)/bin/libmod_cgi.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/cgiHandler.o" $(LIBS) 
endif

#
#   ejsHandler.o
#
DEPS_58 += $(CONFIG)/inc/me.h
DEPS_58 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/ejsHandler.o: \
    src/modules/ejsHandler.c $(DEPS_58)
	@echo '   [Compile] $(CONFIG)/obj/ejsHandler.o'
	$(CC) -c -o $(CONFIG)/obj/ejsHandler.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/modules/ejsHandler.c

ifeq ($(ME_COM_EJS),1)
#
#   libmod_ejs
#
DEPS_59 += $(CONFIG)/inc/mpr.h
DEPS_59 += $(CONFIG)/inc/me.h
DEPS_59 += $(CONFIG)/inc/osdep.h
DEPS_59 += $(CONFIG)/obj/mprLib.o
DEPS_59 += $(CONFIG)/bin/libmpr.out
DEPS_59 += $(CONFIG)/inc/pcre.h
DEPS_59 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_59 += $(CONFIG)/bin/libpcre.out
endif
DEPS_59 += $(CONFIG)/inc/http.h
DEPS_59 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_59 += $(CONFIG)/bin/libhttp.out
endif
DEPS_59 += $(CONFIG)/inc/appweb.h
DEPS_59 += $(CONFIG)/inc/customize.h
DEPS_59 += $(CONFIG)/obj/config.o
DEPS_59 += $(CONFIG)/obj/convenience.o
DEPS_59 += $(CONFIG)/obj/dirHandler.o
DEPS_59 += $(CONFIG)/obj/fileHandler.o
DEPS_59 += $(CONFIG)/obj/server.o
DEPS_59 += $(CONFIG)/bin/libappweb.out
DEPS_59 += $(CONFIG)/inc/zlib.h
DEPS_59 += $(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_59 += $(CONFIG)/bin/libzlib.out
endif
DEPS_59 += $(CONFIG)/inc/ejs.h
DEPS_59 += $(CONFIG)/inc/ejs.slots.h
DEPS_59 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_59 += $(CONFIG)/obj/ejsLib.o
DEPS_59 += $(CONFIG)/bin/libejs.out
DEPS_59 += $(CONFIG)/obj/ejsHandler.o

$(CONFIG)/bin/libmod_ejs.out: $(DEPS_59)
	@echo '      [Link] $(CONFIG)/bin/libmod_ejs.out'
	$(CC) -r -o $(CONFIG)/bin/libmod_ejs.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/ejsHandler.o" $(LIBS) 
endif

#
#   phpHandler.o
#
DEPS_60 += $(CONFIG)/inc/me.h
DEPS_60 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/phpHandler.o: \
    src/modules/phpHandler.c $(DEPS_60)
	@echo '   [Compile] $(CONFIG)/obj/phpHandler.o'
	$(CC) -c -o $(CONFIG)/obj/phpHandler.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_PHP_PATH)" "-I$(ME_COM_PHP_PATH)/main" "-I$(ME_COM_PHP_PATH)/Zend" "-I$(ME_COM_PHP_PATH)/TSRM" src/modules/phpHandler.c

ifeq ($(ME_COM_PHP),1)
#
#   libmod_php
#
DEPS_61 += $(CONFIG)/inc/mpr.h
DEPS_61 += $(CONFIG)/inc/me.h
DEPS_61 += $(CONFIG)/inc/osdep.h
DEPS_61 += $(CONFIG)/obj/mprLib.o
DEPS_61 += $(CONFIG)/bin/libmpr.out
DEPS_61 += $(CONFIG)/inc/pcre.h
DEPS_61 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_61 += $(CONFIG)/bin/libpcre.out
endif
DEPS_61 += $(CONFIG)/inc/http.h
DEPS_61 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_61 += $(CONFIG)/bin/libhttp.out
endif
DEPS_61 += $(CONFIG)/inc/appweb.h
DEPS_61 += $(CONFIG)/inc/customize.h
DEPS_61 += $(CONFIG)/obj/config.o
DEPS_61 += $(CONFIG)/obj/convenience.o
DEPS_61 += $(CONFIG)/obj/dirHandler.o
DEPS_61 += $(CONFIG)/obj/fileHandler.o
DEPS_61 += $(CONFIG)/obj/server.o
DEPS_61 += $(CONFIG)/bin/libappweb.out
DEPS_61 += $(CONFIG)/obj/phpHandler.o

LIBS_61 += -lphp5
LIBPATHS_61 += -L$(ME_COM_PHP_PATH)/libs

$(CONFIG)/bin/libmod_php.out: $(DEPS_61)
	@echo '      [Link] $(CONFIG)/bin/libmod_php.out'
	$(CC) -r -o $(CONFIG)/bin/libmod_php.out $(LDFLAGS) $(LIBPATHS)  "$(CONFIG)/obj/phpHandler.o" $(LIBPATHS_61) $(LIBS_61) $(LIBS_61) $(LIBS) 
endif

#
#   mprSsl.o
#
DEPS_62 += $(CONFIG)/inc/me.h
DEPS_62 += $(CONFIG)/inc/mpr.h
DEPS_62 += $(CONFIG)/inc/est.h

$(CONFIG)/obj/mprSsl.o: \
    src/paks/mpr/mprSsl.c $(DEPS_62)
	@echo '   [Compile] $(CONFIG)/obj/mprSsl.o'
	$(CC) -c -o $(CONFIG)/obj/mprSsl.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" "-I$(ME_COM_NANOSSL_PATH)/src" src/paks/mpr/mprSsl.c

#
#   libmprssl
#
DEPS_63 += $(CONFIG)/inc/mpr.h
DEPS_63 += $(CONFIG)/inc/me.h
DEPS_63 += $(CONFIG)/inc/osdep.h
DEPS_63 += $(CONFIG)/obj/mprLib.o
DEPS_63 += $(CONFIG)/bin/libmpr.out
DEPS_63 += $(CONFIG)/inc/est.h
DEPS_63 += $(CONFIG)/obj/estLib.o
ifeq ($(ME_COM_EST),1)
    DEPS_63 += $(CONFIG)/bin/libest.out
endif
DEPS_63 += $(CONFIG)/obj/mprSsl.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_63 += -lssl
    LIBPATHS_63 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_63 += -lcrypto
    LIBPATHS_63 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_63 += -lmatrixssl
    LIBPATHS_63 += -L$(ME_COM_MATRIXSSL_PATH)
endif
ifeq ($(ME_COM_NANOSSL),1)
    LIBS_63 += -lssls
    LIBPATHS_63 += -L$(ME_COM_NANOSSL_PATH)/bin
endif

$(CONFIG)/bin/libmprssl.out: $(DEPS_63)
	@echo '      [Link] $(CONFIG)/bin/libmprssl.out'
	$(CC) -r -o $(CONFIG)/bin/libmprssl.out $(LDFLAGS) $(LIBPATHS)    "$(CONFIG)/obj/mprSsl.o" $(LIBPATHS_63) $(LIBS_63) $(LIBS_63) $(LIBS) 

#
#   sslModule.o
#
DEPS_64 += $(CONFIG)/inc/me.h
DEPS_64 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/sslModule.o: \
    src/modules/sslModule.c $(DEPS_64)
	@echo '   [Compile] $(CONFIG)/obj/sslModule.o'
	$(CC) -c -o $(CONFIG)/obj/sslModule.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" "-I$(ME_COM_NANOSSL_PATH)/src" src/modules/sslModule.c

ifeq ($(ME_COM_SSL),1)
#
#   libmod_ssl
#
DEPS_65 += $(CONFIG)/inc/mpr.h
DEPS_65 += $(CONFIG)/inc/me.h
DEPS_65 += $(CONFIG)/inc/osdep.h
DEPS_65 += $(CONFIG)/obj/mprLib.o
DEPS_65 += $(CONFIG)/bin/libmpr.out
DEPS_65 += $(CONFIG)/inc/pcre.h
DEPS_65 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_65 += $(CONFIG)/bin/libpcre.out
endif
DEPS_65 += $(CONFIG)/inc/http.h
DEPS_65 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_65 += $(CONFIG)/bin/libhttp.out
endif
DEPS_65 += $(CONFIG)/inc/appweb.h
DEPS_65 += $(CONFIG)/inc/customize.h
DEPS_65 += $(CONFIG)/obj/config.o
DEPS_65 += $(CONFIG)/obj/convenience.o
DEPS_65 += $(CONFIG)/obj/dirHandler.o
DEPS_65 += $(CONFIG)/obj/fileHandler.o
DEPS_65 += $(CONFIG)/obj/server.o
DEPS_65 += $(CONFIG)/bin/libappweb.out
DEPS_65 += $(CONFIG)/inc/est.h
DEPS_65 += $(CONFIG)/obj/estLib.o
ifeq ($(ME_COM_EST),1)
    DEPS_65 += $(CONFIG)/bin/libest.out
endif
DEPS_65 += $(CONFIG)/obj/mprSsl.o
DEPS_65 += $(CONFIG)/bin/libmprssl.out
DEPS_65 += $(CONFIG)/obj/sslModule.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_65 += -lssl
    LIBPATHS_65 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_65 += -lcrypto
    LIBPATHS_65 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_65 += -lmatrixssl
    LIBPATHS_65 += -L$(ME_COM_MATRIXSSL_PATH)
endif
ifeq ($(ME_COM_NANOSSL),1)
    LIBS_65 += -lssls
    LIBPATHS_65 += -L$(ME_COM_NANOSSL_PATH)/bin
endif

$(CONFIG)/bin/libmod_ssl.out: $(DEPS_65)
	@echo '      [Link] $(CONFIG)/bin/libmod_ssl.out'
	$(CC) -r -o $(CONFIG)/bin/libmod_ssl.out $(LDFLAGS) $(LIBPATHS)    "$(CONFIG)/obj/sslModule.o" $(LIBPATHS_65) $(LIBS_65) $(LIBS_65) $(LIBS) 
endif

#
#   sqlite3.h
#
$(CONFIG)/inc/sqlite3.h: $(DEPS_66)
	@echo '      [Copy] $(CONFIG)/inc/sqlite3.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/sqlite/sqlite3.h $(CONFIG)/inc/sqlite3.h

#
#   sqlite3.o
#
DEPS_67 += $(CONFIG)/inc/me.h
DEPS_67 += $(CONFIG)/inc/sqlite3.h

$(CONFIG)/obj/sqlite3.o: \
    src/paks/sqlite/sqlite3.c $(DEPS_67)
	@echo '   [Compile] $(CONFIG)/obj/sqlite3.o'
	$(CC) -c -o $(CONFIG)/obj/sqlite3.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/sqlite/sqlite3.c

ifeq ($(ME_COM_SQLITE),1)
#
#   libsql
#
DEPS_68 += $(CONFIG)/inc/sqlite3.h
DEPS_68 += $(CONFIG)/inc/me.h
DEPS_68 += $(CONFIG)/obj/sqlite3.o

$(CONFIG)/bin/libsql.out: $(DEPS_68)
	@echo '      [Link] $(CONFIG)/bin/libsql.out'
	$(CC) -r -o $(CONFIG)/bin/libsql.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/sqlite3.o" $(LIBS) 
endif

#
#   manager.o
#
DEPS_69 += $(CONFIG)/inc/me.h
DEPS_69 += $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/manager.o: \
    src/paks/mpr/manager.c $(DEPS_69)
	@echo '   [Compile] $(CONFIG)/obj/manager.o'
	$(CC) -c -o $(CONFIG)/obj/manager.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/mpr/manager.c

#
#   manager
#
DEPS_70 += $(CONFIG)/inc/mpr.h
DEPS_70 += $(CONFIG)/inc/me.h
DEPS_70 += $(CONFIG)/inc/osdep.h
DEPS_70 += $(CONFIG)/obj/mprLib.o
DEPS_70 += $(CONFIG)/bin/libmpr.out
DEPS_70 += $(CONFIG)/obj/manager.o

$(CONFIG)/bin/appman.out: $(DEPS_70)
	@echo '      [Link] $(CONFIG)/bin/appman.out'
	$(CC) -o $(CONFIG)/bin/appman.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/manager.o" $(LIBS) -Wl,-r 

#
#   server-cache
#
src/server/cache: $(DEPS_71)
	( \
	cd src/server; \
	mkdir -p cache ; \
	)

#
#   sqlite.o
#
DEPS_72 += $(CONFIG)/inc/me.h
DEPS_72 += $(CONFIG)/inc/sqlite3.h

$(CONFIG)/obj/sqlite.o: \
    src/paks/sqlite/sqlite.c $(DEPS_72)
	@echo '   [Compile] $(CONFIG)/obj/sqlite.o'
	$(CC) -c -o $(CONFIG)/obj/sqlite.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/sqlite/sqlite.c

ifeq ($(ME_COM_SQLITE),1)
#
#   sqliteshell
#
DEPS_73 += $(CONFIG)/inc/sqlite3.h
DEPS_73 += $(CONFIG)/inc/me.h
DEPS_73 += $(CONFIG)/obj/sqlite3.o
DEPS_73 += $(CONFIG)/bin/libsql.out
DEPS_73 += $(CONFIG)/obj/sqlite.o

$(CONFIG)/bin/sqlite.out: $(DEPS_73)
	@echo '      [Link] $(CONFIG)/bin/sqlite.out'
	$(CC) -o $(CONFIG)/bin/sqlite.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/sqlite.o" $(LIBS) -Wl,-r 
endif

#
#   testAppweb.h
#
$(CONFIG)/inc/testAppweb.h: $(DEPS_74)
	@echo '      [Copy] $(CONFIG)/inc/testAppweb.h'
	mkdir -p "$(CONFIG)/inc"
	cp test/src/testAppweb.h $(CONFIG)/inc/testAppweb.h

#
#   testAppweb.o
#
DEPS_75 += $(CONFIG)/inc/me.h
DEPS_75 += $(CONFIG)/inc/testAppweb.h
DEPS_75 += $(CONFIG)/inc/mpr.h
DEPS_75 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/testAppweb.o: \
    test/src/testAppweb.c $(DEPS_75)
	@echo '   [Compile] $(CONFIG)/obj/testAppweb.o'
	$(CC) -c -o $(CONFIG)/obj/testAppweb.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" test/src/testAppweb.c

#
#   testHttp.o
#
DEPS_76 += $(CONFIG)/inc/me.h
DEPS_76 += $(CONFIG)/inc/testAppweb.h

$(CONFIG)/obj/testHttp.o: \
    test/src/testHttp.c $(DEPS_76)
	@echo '   [Compile] $(CONFIG)/obj/testHttp.o'
	$(CC) -c -o $(CONFIG)/obj/testHttp.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" test/src/testHttp.c

#
#   testAppweb
#
DEPS_77 += $(CONFIG)/inc/mpr.h
DEPS_77 += $(CONFIG)/inc/me.h
DEPS_77 += $(CONFIG)/inc/osdep.h
DEPS_77 += $(CONFIG)/obj/mprLib.o
DEPS_77 += $(CONFIG)/bin/libmpr.out
DEPS_77 += $(CONFIG)/inc/pcre.h
DEPS_77 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_77 += $(CONFIG)/bin/libpcre.out
endif
DEPS_77 += $(CONFIG)/inc/http.h
DEPS_77 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_77 += $(CONFIG)/bin/libhttp.out
endif
DEPS_77 += $(CONFIG)/inc/appweb.h
DEPS_77 += $(CONFIG)/inc/customize.h
DEPS_77 += $(CONFIG)/obj/config.o
DEPS_77 += $(CONFIG)/obj/convenience.o
DEPS_77 += $(CONFIG)/obj/dirHandler.o
DEPS_77 += $(CONFIG)/obj/fileHandler.o
DEPS_77 += $(CONFIG)/obj/server.o
DEPS_77 += $(CONFIG)/bin/libappweb.out
DEPS_77 += $(CONFIG)/inc/testAppweb.h
DEPS_77 += $(CONFIG)/obj/testAppweb.o
DEPS_77 += $(CONFIG)/obj/testHttp.o

$(CONFIG)/bin/testAppweb.out: $(DEPS_77)
	@echo '      [Link] $(CONFIG)/bin/testAppweb.out'
	$(CC) -o $(CONFIG)/bin/testAppweb.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/testAppweb.o" "$(CONFIG)/obj/testHttp.o" $(LIBS) -Wl,-r 

ifeq ($(ME_COM_CGI),1)
#
#   test-basic.cgi
#
DEPS_78 += $(CONFIG)/inc/mpr.h
DEPS_78 += $(CONFIG)/inc/me.h
DEPS_78 += $(CONFIG)/inc/osdep.h
DEPS_78 += $(CONFIG)/obj/mprLib.o
DEPS_78 += $(CONFIG)/bin/libmpr.out
DEPS_78 += $(CONFIG)/inc/pcre.h
DEPS_78 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_78 += $(CONFIG)/bin/libpcre.out
endif
DEPS_78 += $(CONFIG)/inc/http.h
DEPS_78 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_78 += $(CONFIG)/bin/libhttp.out
endif
DEPS_78 += $(CONFIG)/inc/appweb.h
DEPS_78 += $(CONFIG)/inc/customize.h
DEPS_78 += $(CONFIG)/obj/config.o
DEPS_78 += $(CONFIG)/obj/convenience.o
DEPS_78 += $(CONFIG)/obj/dirHandler.o
DEPS_78 += $(CONFIG)/obj/fileHandler.o
DEPS_78 += $(CONFIG)/obj/server.o
DEPS_78 += $(CONFIG)/bin/libappweb.out
DEPS_78 += $(CONFIG)/inc/testAppweb.h
DEPS_78 += $(CONFIG)/obj/testAppweb.o
DEPS_78 += $(CONFIG)/obj/testHttp.o
DEPS_78 += $(CONFIG)/bin/testAppweb.out

test/web/auth/basic/basic.cgi: $(DEPS_78)
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
DEPS_79 += $(CONFIG)/inc/mpr.h
DEPS_79 += $(CONFIG)/inc/me.h
DEPS_79 += $(CONFIG)/inc/osdep.h
DEPS_79 += $(CONFIG)/obj/mprLib.o
DEPS_79 += $(CONFIG)/bin/libmpr.out
DEPS_79 += $(CONFIG)/inc/pcre.h
DEPS_79 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_79 += $(CONFIG)/bin/libpcre.out
endif
DEPS_79 += $(CONFIG)/inc/http.h
DEPS_79 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_79 += $(CONFIG)/bin/libhttp.out
endif
DEPS_79 += $(CONFIG)/inc/appweb.h
DEPS_79 += $(CONFIG)/inc/customize.h
DEPS_79 += $(CONFIG)/obj/config.o
DEPS_79 += $(CONFIG)/obj/convenience.o
DEPS_79 += $(CONFIG)/obj/dirHandler.o
DEPS_79 += $(CONFIG)/obj/fileHandler.o
DEPS_79 += $(CONFIG)/obj/server.o
DEPS_79 += $(CONFIG)/bin/libappweb.out
DEPS_79 += $(CONFIG)/inc/testAppweb.h
DEPS_79 += $(CONFIG)/obj/testAppweb.o
DEPS_79 += $(CONFIG)/obj/testHttp.o
DEPS_79 += $(CONFIG)/bin/testAppweb.out

test/web/caching/cache.cgi: $(DEPS_79)
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
DEPS_80 += $(CONFIG)/inc/me.h
DEPS_80 += $(CONFIG)/obj/cgiProgram.o
DEPS_80 += $(CONFIG)/bin/cgiProgram.out

test/cgi-bin/cgiProgram.out: $(DEPS_80)
	( \
	cd test; \
	cp ../$(CONFIG)/bin/cgiProgram.out cgi-bin/cgiProgram.out ; \
	cp ../$(CONFIG)/bin/cgiProgram.out cgi-bin/nph-cgiProgram.out ; \
	cp ../$(CONFIG)/bin/cgiProgram.out 'cgi-bin/cgi Program.out' ; \
	cp ../$(CONFIG)/bin/cgiProgram.out web/cgiProgram.cgi ; \
	chmod +x cgi-bin/* web/cgiProgram.cgi ; \
	)
endif

ifeq ($(ME_COM_CGI),1)
#
#   test-testScript
#
DEPS_81 += $(CONFIG)/inc/mpr.h
DEPS_81 += $(CONFIG)/inc/me.h
DEPS_81 += $(CONFIG)/inc/osdep.h
DEPS_81 += $(CONFIG)/obj/mprLib.o
DEPS_81 += $(CONFIG)/bin/libmpr.out
DEPS_81 += $(CONFIG)/inc/pcre.h
DEPS_81 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_81 += $(CONFIG)/bin/libpcre.out
endif
DEPS_81 += $(CONFIG)/inc/http.h
DEPS_81 += $(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_81 += $(CONFIG)/bin/libhttp.out
endif
DEPS_81 += $(CONFIG)/inc/appweb.h
DEPS_81 += $(CONFIG)/inc/customize.h
DEPS_81 += $(CONFIG)/obj/config.o
DEPS_81 += $(CONFIG)/obj/convenience.o
DEPS_81 += $(CONFIG)/obj/dirHandler.o
DEPS_81 += $(CONFIG)/obj/fileHandler.o
DEPS_81 += $(CONFIG)/obj/server.o
DEPS_81 += $(CONFIG)/bin/libappweb.out
DEPS_81 += $(CONFIG)/inc/testAppweb.h
DEPS_81 += $(CONFIG)/obj/testAppweb.o
DEPS_81 += $(CONFIG)/obj/testHttp.o
DEPS_81 += $(CONFIG)/bin/testAppweb.out

test/cgi-bin/testScript: $(DEPS_81)
	( \
	cd test; \
	echo '#!../$(CONFIG)/bin/cgiProgram.out' >cgi-bin/testScript ; chmod +x cgi-bin/testScript ; \
	)
endif

#
#   installBinary
#
installBinary: $(DEPS_82)

#
#   install
#
DEPS_83 += installBinary

install: $(DEPS_83)


#
#   run
#
DEPS_84 += compile

run: $(DEPS_84)
	( \
	cd src/server; \
	sudo ../../$(CONFIG)/bin/appweb -v ; \
	)


#
#   uninstall
#
DEPS_85 += build

uninstall: $(DEPS_85)
	( \
	cd package; \
	rm -f "$(ME_VAPP_PREFIX)/appweb.conf" ; \
	rm -f "$(ME_VAPP_PREFIX)/esp.conf" ; \
	rm -f "$(ME_VAPP_PREFIX)/mine.types" ; \
	rm -f "$(ME_VAPP_PREFIX)/install.conf" ; \
	rm -fr "$(ME_VAPP_PREFIX)/inc/appweb" ; \
	)

#
#   version
#
version: $(DEPS_86)
	echo 5.0.0-rc2

