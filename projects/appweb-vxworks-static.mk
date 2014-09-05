#
#   appweb-vxworks-static.mk -- Makefile to build Embedthis Appweb for vxworks
#

NAME                  := appweb
VERSION               := 5.2.0
PROFILE               ?= static
ARCH                  ?= $(shell echo $(WIND_HOST_TYPE) | sed 's/-.*//')
CPU                   ?= $(subst X86,PENTIUM,$(shell echo $(ARCH) | tr a-z A-Z))
OS                    ?= vxworks
CC                    ?= cc$(subst x86,pentium,$(ARCH))
LD                    ?= ld
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
ME_COM_MDB            ?= 1
ME_COM_OPENSSL        ?= 0
ME_COM_OSDEP          ?= 1
ME_COM_PCRE           ?= 1
ME_COM_PHP            ?= 0
ME_COM_SQLITE         ?= 0
ME_COM_SSL            ?= 1
ME_COM_WINSDK         ?= 1
ME_COM_ZLIB           ?= 0

ifeq ($(ME_COM_EST),1)
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
ME_COM_OPENSSL_PATH   ?= /usr/src/openssl
ME_COM_PHP_PATH       ?= /usr/src/php
ME_COM_VXWORKS_PATH   ?= $(WIND_BASE)

export WIND_HOME      ?= $(WIND_BASE)/..
export PATH           := $(WIND_GNU_PATH)/$(WIND_HOST_TYPE)/bin:$(PATH)

CFLAGS                += -fno-builtin -fno-defer-pop -fvolatile -w
DFLAGS                += -DVXWORKS -DRW_MULTI_THREAD -D_GNU_TOOL -DCPU=PENTIUM $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_CGI=$(ME_COM_CGI) -DME_COM_DIR=$(ME_COM_DIR) -DME_COM_EJS=$(ME_COM_EJS) -DME_COM_ESP=$(ME_COM_ESP) -DME_COM_EST=$(ME_COM_EST) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_MDB=$(ME_COM_MDB) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_OSDEP=$(ME_COM_OSDEP) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_PHP=$(ME_COM_PHP) -DME_COM_SQLITE=$(ME_COM_SQLITE) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_WINSDK=$(ME_COM_WINSDK) -DME_COM_ZLIB=$(ME_COM_ZLIB) 
IFLAGS                += "-Ibuild/$(CONFIG)/inc -I$(WIND_BASE)/target/h -I$(WIND_BASE)/target/h/wrn/coreip"
LDFLAGS               += '-Wl,-r'
LIBPATHS              += -Lbuild/$(CONFIG)/bin
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


TARGETS               += build/$(CONFIG)/bin/appweb.out
TARGETS               += build/$(CONFIG)/bin/authpass.out
ifeq ($(ME_COM_CGI),1)
    TARGETS           += build/$(CONFIG)/bin/cgiProgram.out
endif
ifeq ($(ME_COM_EJS),1)
    TARGETS           += build/$(CONFIG)/bin/ejs.mod
endif
ifeq ($(ME_COM_EJS),1)
    TARGETS           += build/$(CONFIG)/bin/ejs.out
endif
ifeq ($(ME_COM_ESP),1)
    TARGETS           += build/$(CONFIG)/esp
endif
ifeq ($(ME_COM_ESP),1)
    TARGETS           += build/$(CONFIG)/bin/esp.conf
endif
ifeq ($(ME_COM_ESP),1)
    TARGETS           += build/$(CONFIG)/bin/esp.out
endif
TARGETS               += build/$(CONFIG)/bin/ca.crt
ifeq ($(ME_COM_HTTP),1)
    TARGETS           += build/$(CONFIG)/bin/http.out
endif
ifeq ($(ME_COM_SQLITE),1)
    TARGETS           += build/$(CONFIG)/bin/libsql.a
endif
TARGETS               += build/$(CONFIG)/bin/appman.out
TARGETS               += src/server/cache
ifeq ($(ME_COM_SQLITE),1)
    TARGETS           += build/$(CONFIG)/bin/sqlite.out
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
	@[ ! -x $(BUILD)/bin ] && mkdir -p $(BUILD)/bin; true
	@[ ! -x $(BUILD)/inc ] && mkdir -p $(BUILD)/inc; true
	@[ ! -x $(BUILD)/obj ] && mkdir -p $(BUILD)/obj; true
	@[ ! -f $(BUILD)/inc/me.h ] && cp projects/appweb-vxworks-static-me.h $(BUILD)/inc/me.h ; true
	@if ! diff $(BUILD)/inc/me.h projects/appweb-vxworks-static-me.h >/dev/null ; then\
		cp projects/appweb-vxworks-static-me.h $(BUILD)/inc/me.h  ; \
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
	rm -f "build/$(CONFIG)/bin/appweb.out"
	rm -f "build/$(CONFIG)/bin/authpass.out"
	rm -f "build/$(CONFIG)/bin/cgiProgram.out"
	rm -f "build/$(CONFIG)/bin/ejsc.out"
	rm -f "build/$(CONFIG)/bin/ejs.out"
	rm -f "build/$(CONFIG)/bin/esp.conf"
	rm -f "build/$(CONFIG)/bin/esp.out"
	rm -f "build/$(CONFIG)/bin/ca.crt"
	rm -f "build/$(CONFIG)/bin/http.out"
	rm -f "build/$(CONFIG)/bin/libappweb.a"
	rm -f "build/$(CONFIG)/bin/libejs.a"
	rm -f "build/$(CONFIG)/bin/libest.a"
	rm -f "build/$(CONFIG)/bin/libhttp.a"
	rm -f "build/$(CONFIG)/bin/libmod_cgi.a"
	rm -f "build/$(CONFIG)/bin/libmod_ejs.a"
	rm -f "build/$(CONFIG)/bin/libmod_esp.a"
	rm -f "build/$(CONFIG)/bin/libmod_php.a"
	rm -f "build/$(CONFIG)/bin/libmod_ssl.a"
	rm -f "build/$(CONFIG)/bin/libmpr.a"
	rm -f "build/$(CONFIG)/bin/libmprssl.a"
	rm -f "build/$(CONFIG)/bin/libpcre.a"
	rm -f "build/$(CONFIG)/bin/libslink.a"
	rm -f "build/$(CONFIG)/bin/libsql.a"
	rm -f "build/$(CONFIG)/bin/libzlib.a"
	rm -f "build/$(CONFIG)/bin/makerom.out"
	rm -f "build/$(CONFIG)/bin/appman.out"
	rm -f "build/$(CONFIG)/bin/sqlite.out"

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
	$(CC) -c -o build/$(CONFIG)/obj/mprLib.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/mpr/mprLib.c

#
#   libmpr
#
DEPS_5 += build/$(CONFIG)/inc/mpr.h
DEPS_5 += build/$(CONFIG)/inc/me.h
DEPS_5 += build/$(CONFIG)/inc/osdep.h
DEPS_5 += build/$(CONFIG)/obj/mprLib.o

build/$(CONFIG)/bin/libmpr.a: $(DEPS_5)
	@echo '      [Link] build/$(CONFIG)/bin/libmpr.a'
	ar -cr build/$(CONFIG)/bin/libmpr.a "build/$(CONFIG)/obj/mprLib.o" >>build\nmake.log

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
	$(CC) -c -o build/$(CONFIG)/obj/pcre.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/pcre/pcre.c

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_8 += build/$(CONFIG)/inc/pcre.h
DEPS_8 += build/$(CONFIG)/inc/me.h
DEPS_8 += build/$(CONFIG)/obj/pcre.o

build/$(CONFIG)/bin/libpcre.a: $(DEPS_8)
	@echo '      [Link] build/$(CONFIG)/bin/libpcre.a'
	ar -cr build/$(CONFIG)/bin/libpcre.a "build/$(CONFIG)/obj/pcre.o" >>build\nmake.log
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
	$(CC) -c -o build/$(CONFIG)/obj/httpLib.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/http/httpLib.c

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_11 += build/$(CONFIG)/inc/mpr.h
DEPS_11 += build/$(CONFIG)/inc/me.h
DEPS_11 += build/$(CONFIG)/inc/osdep.h
DEPS_11 += build/$(CONFIG)/obj/mprLib.o
DEPS_11 += build/$(CONFIG)/bin/libmpr.a
DEPS_11 += build/$(CONFIG)/inc/pcre.h
DEPS_11 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_11 += build/$(CONFIG)/bin/libpcre.a
endif
DEPS_11 += build/$(CONFIG)/inc/http.h
DEPS_11 += build/$(CONFIG)/obj/httpLib.o

build/$(CONFIG)/bin/libhttp.a: $(DEPS_11)
	@echo '      [Link] build/$(CONFIG)/bin/libhttp.a'
	ar -cr build/$(CONFIG)/bin/libhttp.a "build/$(CONFIG)/obj/httpLib.o" >>build\nmake.log
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
DEPS_14 += build/$(CONFIG)/inc/osdep.h
DEPS_14 += build/$(CONFIG)/inc/mpr.h
DEPS_14 += build/$(CONFIG)/inc/http.h
DEPS_14 += build/$(CONFIG)/inc/customize.h

build/$(CONFIG)/obj/config.o: \
    src/config.c $(DEPS_14)
	@echo '   [Compile] build/$(CONFIG)/obj/config.o'
	$(CC) -c -o build/$(CONFIG)/obj/config.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/config.c

#
#   convenience.o
#
DEPS_15 += build/$(CONFIG)/inc/me.h
DEPS_15 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/convenience.o: \
    src/convenience.c $(DEPS_15)
	@echo '   [Compile] build/$(CONFIG)/obj/convenience.o'
	$(CC) -c -o build/$(CONFIG)/obj/convenience.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/convenience.c

#
#   libappweb
#
DEPS_16 += build/$(CONFIG)/inc/mpr.h
DEPS_16 += build/$(CONFIG)/inc/me.h
DEPS_16 += build/$(CONFIG)/inc/osdep.h
DEPS_16 += build/$(CONFIG)/obj/mprLib.o
DEPS_16 += build/$(CONFIG)/bin/libmpr.a
DEPS_16 += build/$(CONFIG)/inc/pcre.h
DEPS_16 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_16 += build/$(CONFIG)/bin/libpcre.a
endif
DEPS_16 += build/$(CONFIG)/inc/http.h
DEPS_16 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_16 += build/$(CONFIG)/bin/libhttp.a
endif
DEPS_16 += build/$(CONFIG)/inc/appweb.h
DEPS_16 += build/$(CONFIG)/inc/customize.h
DEPS_16 += build/$(CONFIG)/obj/config.o
DEPS_16 += build/$(CONFIG)/obj/convenience.o

build/$(CONFIG)/bin/libappweb.a: $(DEPS_16)
	@echo '      [Link] build/$(CONFIG)/bin/libappweb.a'
	ar -cr build/$(CONFIG)/bin/libappweb.a "build/$(CONFIG)/obj/config.o" "build/$(CONFIG)/obj/convenience.o" >>build\nmake.log

#
#   esp.h
#
DEPS_17 += src/paks/esp/esp.h

build/$(CONFIG)/inc/esp.h: $(DEPS_17)
	@echo '      [Copy] build/$(CONFIG)/inc/esp.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/esp/esp.h build/$(CONFIG)/inc/esp.h

#
#   espLib.o
#
DEPS_18 += build/$(CONFIG)/inc/me.h
DEPS_18 += build/$(CONFIG)/inc/esp.h
DEPS_18 += build/$(CONFIG)/inc/pcre.h
DEPS_18 += build/$(CONFIG)/inc/http.h
DEPS_18 += build/$(CONFIG)/inc/osdep.h
DEPS_18 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/espLib.o: \
    src/paks/esp/espLib.c $(DEPS_18)
	@echo '   [Compile] build/$(CONFIG)/obj/espLib.o'
	$(CC) -c -o build/$(CONFIG)/obj/espLib.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/esp/espLib.c

ifeq ($(ME_COM_ESP),1)
#
#   libmod_esp
#
DEPS_19 += build/$(CONFIG)/inc/mpr.h
DEPS_19 += build/$(CONFIG)/inc/me.h
DEPS_19 += build/$(CONFIG)/inc/osdep.h
DEPS_19 += build/$(CONFIG)/obj/mprLib.o
DEPS_19 += build/$(CONFIG)/bin/libmpr.a
DEPS_19 += build/$(CONFIG)/inc/pcre.h
DEPS_19 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_19 += build/$(CONFIG)/bin/libpcre.a
endif
DEPS_19 += build/$(CONFIG)/inc/http.h
DEPS_19 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_19 += build/$(CONFIG)/bin/libhttp.a
endif
DEPS_19 += build/$(CONFIG)/inc/appweb.h
DEPS_19 += build/$(CONFIG)/inc/customize.h
DEPS_19 += build/$(CONFIG)/obj/config.o
DEPS_19 += build/$(CONFIG)/obj/convenience.o
DEPS_19 += build/$(CONFIG)/bin/libappweb.a
DEPS_19 += build/$(CONFIG)/inc/esp.h
DEPS_19 += build/$(CONFIG)/obj/espLib.o

build/$(CONFIG)/bin/libmod_esp.a: $(DEPS_19)
	@echo '      [Link] build/$(CONFIG)/bin/libmod_esp.a'
	ar -cr build/$(CONFIG)/bin/libmod_esp.a "build/$(CONFIG)/obj/espLib.o" >>build\nmake.log
endif

#
#   slink.o
#
DEPS_20 += build/$(CONFIG)/inc/me.h
DEPS_20 += build/$(CONFIG)/inc/mpr.h
DEPS_20 += build/$(CONFIG)/inc/esp.h

build/$(CONFIG)/obj/slink.o: \
    src/server/slink.c $(DEPS_20)
	@echo '   [Compile] build/$(CONFIG)/obj/slink.o'
	$(CC) -c -o build/$(CONFIG)/obj/slink.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/server/slink.c

#
#   libslink
#
DEPS_21 += build/$(CONFIG)/inc/mpr.h
DEPS_21 += build/$(CONFIG)/inc/me.h
DEPS_21 += build/$(CONFIG)/inc/osdep.h
DEPS_21 += build/$(CONFIG)/obj/mprLib.o
DEPS_21 += build/$(CONFIG)/bin/libmpr.a
DEPS_21 += build/$(CONFIG)/inc/pcre.h
DEPS_21 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_21 += build/$(CONFIG)/bin/libpcre.a
endif
DEPS_21 += build/$(CONFIG)/inc/http.h
DEPS_21 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_21 += build/$(CONFIG)/bin/libhttp.a
endif
DEPS_21 += build/$(CONFIG)/inc/appweb.h
DEPS_21 += build/$(CONFIG)/inc/customize.h
DEPS_21 += build/$(CONFIG)/obj/config.o
DEPS_21 += build/$(CONFIG)/obj/convenience.o
DEPS_21 += build/$(CONFIG)/bin/libappweb.a
DEPS_21 += build/$(CONFIG)/inc/esp.h
DEPS_21 += build/$(CONFIG)/obj/espLib.o
ifeq ($(ME_COM_ESP),1)
    DEPS_21 += build/$(CONFIG)/bin/libmod_esp.a
endif
DEPS_21 += build/$(CONFIG)/obj/slink.o

build/$(CONFIG)/bin/libslink.a: $(DEPS_21)
	@echo '      [Link] build/$(CONFIG)/bin/libslink.a'
	ar -cr build/$(CONFIG)/bin/libslink.a "build/$(CONFIG)/obj/slink.o" >>build\nmake.log

#
#   est.h
#
DEPS_22 += src/paks/est/est.h

build/$(CONFIG)/inc/est.h: $(DEPS_22)
	@echo '      [Copy] build/$(CONFIG)/inc/est.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/est/est.h build/$(CONFIG)/inc/est.h

#
#   estLib.o
#
DEPS_23 += build/$(CONFIG)/inc/me.h
DEPS_23 += build/$(CONFIG)/inc/est.h
DEPS_23 += build/$(CONFIG)/inc/osdep.h

build/$(CONFIG)/obj/estLib.o: \
    src/paks/est/estLib.c $(DEPS_23)
	@echo '   [Compile] build/$(CONFIG)/obj/estLib.o'
	$(CC) -c -o build/$(CONFIG)/obj/estLib.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/est/estLib.c

ifeq ($(ME_COM_EST),1)
#
#   libest
#
DEPS_24 += build/$(CONFIG)/inc/est.h
DEPS_24 += build/$(CONFIG)/inc/me.h
DEPS_24 += build/$(CONFIG)/inc/osdep.h
DEPS_24 += build/$(CONFIG)/obj/estLib.o

build/$(CONFIG)/bin/libest.a: $(DEPS_24)
	@echo '      [Link] build/$(CONFIG)/bin/libest.a'
	ar -cr build/$(CONFIG)/bin/libest.a "build/$(CONFIG)/obj/estLib.o" >>build\nmake.log
endif

#
#   mprSsl.o
#
DEPS_25 += build/$(CONFIG)/inc/me.h
DEPS_25 += build/$(CONFIG)/inc/mpr.h

build/$(CONFIG)/obj/mprSsl.o: \
    src/paks/mpr/mprSsl.c $(DEPS_25)
	@echo '   [Compile] build/$(CONFIG)/obj/mprSsl.o'
	$(CC) -c -o build/$(CONFIG)/obj/mprSsl.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/paks/mpr/mprSsl.c

#
#   libmprssl
#
DEPS_26 += build/$(CONFIG)/inc/mpr.h
DEPS_26 += build/$(CONFIG)/inc/me.h
DEPS_26 += build/$(CONFIG)/inc/osdep.h
DEPS_26 += build/$(CONFIG)/obj/mprLib.o
DEPS_26 += build/$(CONFIG)/bin/libmpr.a
DEPS_26 += build/$(CONFIG)/inc/est.h
DEPS_26 += build/$(CONFIG)/obj/estLib.o
ifeq ($(ME_COM_EST),1)
    DEPS_26 += build/$(CONFIG)/bin/libest.a
endif
DEPS_26 += build/$(CONFIG)/obj/mprSsl.o

build/$(CONFIG)/bin/libmprssl.a: $(DEPS_26)
	@echo '      [Link] build/$(CONFIG)/bin/libmprssl.a'
	ar -cr build/$(CONFIG)/bin/libmprssl.a "build/$(CONFIG)/obj/mprSsl.o" >>build\nmake.log

#
#   sslModule.o
#
DEPS_27 += build/$(CONFIG)/inc/me.h
DEPS_27 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/sslModule.o: \
    src/modules/sslModule.c $(DEPS_27)
	@echo '   [Compile] build/$(CONFIG)/obj/sslModule.o'
	$(CC) -c -o build/$(CONFIG)/obj/sslModule.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/modules/sslModule.c

ifeq ($(ME_COM_SSL),1)
#
#   libmod_ssl
#
DEPS_28 += build/$(CONFIG)/inc/mpr.h
DEPS_28 += build/$(CONFIG)/inc/me.h
DEPS_28 += build/$(CONFIG)/inc/osdep.h
DEPS_28 += build/$(CONFIG)/obj/mprLib.o
DEPS_28 += build/$(CONFIG)/bin/libmpr.a
DEPS_28 += build/$(CONFIG)/inc/pcre.h
DEPS_28 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_28 += build/$(CONFIG)/bin/libpcre.a
endif
DEPS_28 += build/$(CONFIG)/inc/http.h
DEPS_28 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_28 += build/$(CONFIG)/bin/libhttp.a
endif
DEPS_28 += build/$(CONFIG)/inc/appweb.h
DEPS_28 += build/$(CONFIG)/inc/customize.h
DEPS_28 += build/$(CONFIG)/obj/config.o
DEPS_28 += build/$(CONFIG)/obj/convenience.o
DEPS_28 += build/$(CONFIG)/bin/libappweb.a
DEPS_28 += build/$(CONFIG)/inc/est.h
DEPS_28 += build/$(CONFIG)/obj/estLib.o
ifeq ($(ME_COM_EST),1)
    DEPS_28 += build/$(CONFIG)/bin/libest.a
endif
DEPS_28 += build/$(CONFIG)/obj/mprSsl.o
DEPS_28 += build/$(CONFIG)/bin/libmprssl.a
DEPS_28 += build/$(CONFIG)/obj/sslModule.o

build/$(CONFIG)/bin/libmod_ssl.a: $(DEPS_28)
	@echo '      [Link] build/$(CONFIG)/bin/libmod_ssl.a'
	ar -cr build/$(CONFIG)/bin/libmod_ssl.a "build/$(CONFIG)/obj/sslModule.o" >>build\nmake.log
endif

#
#   zlib.h
#
DEPS_29 += src/paks/zlib/zlib.h

build/$(CONFIG)/inc/zlib.h: $(DEPS_29)
	@echo '      [Copy] build/$(CONFIG)/inc/zlib.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/zlib/zlib.h build/$(CONFIG)/inc/zlib.h

#
#   zlib.o
#
DEPS_30 += build/$(CONFIG)/inc/me.h
DEPS_30 += build/$(CONFIG)/inc/zlib.h

build/$(CONFIG)/obj/zlib.o: \
    src/paks/zlib/zlib.c $(DEPS_30)
	@echo '   [Compile] build/$(CONFIG)/obj/zlib.o'
	$(CC) -c -o build/$(CONFIG)/obj/zlib.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/zlib/zlib.c

ifeq ($(ME_COM_ZLIB),1)
#
#   libzlib
#
DEPS_31 += build/$(CONFIG)/inc/zlib.h
DEPS_31 += build/$(CONFIG)/inc/me.h
DEPS_31 += build/$(CONFIG)/obj/zlib.o

build/$(CONFIG)/bin/libzlib.a: $(DEPS_31)
	@echo '      [Link] build/$(CONFIG)/bin/libzlib.a'
	ar -cr build/$(CONFIG)/bin/libzlib.a "build/$(CONFIG)/obj/zlib.o" >>build\nmake.log
endif

#
#   ejs.h
#
DEPS_32 += src/paks/ejs/ejs.h

build/$(CONFIG)/inc/ejs.h: $(DEPS_32)
	@echo '      [Copy] build/$(CONFIG)/inc/ejs.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/ejs/ejs.h build/$(CONFIG)/inc/ejs.h

#
#   ejs.slots.h
#
DEPS_33 += src/paks/ejs/ejs.slots.h

build/$(CONFIG)/inc/ejs.slots.h: $(DEPS_33)
	@echo '      [Copy] build/$(CONFIG)/inc/ejs.slots.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/ejs/ejs.slots.h build/$(CONFIG)/inc/ejs.slots.h

#
#   ejsByteGoto.h
#
DEPS_34 += src/paks/ejs/ejsByteGoto.h

build/$(CONFIG)/inc/ejsByteGoto.h: $(DEPS_34)
	@echo '      [Copy] build/$(CONFIG)/inc/ejsByteGoto.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/ejs/ejsByteGoto.h build/$(CONFIG)/inc/ejsByteGoto.h

#
#   ejsLib.o
#
DEPS_35 += build/$(CONFIG)/inc/me.h
DEPS_35 += build/$(CONFIG)/inc/ejs.h
DEPS_35 += build/$(CONFIG)/inc/mpr.h
DEPS_35 += build/$(CONFIG)/inc/pcre.h
DEPS_35 += build/$(CONFIG)/inc/osdep.h
DEPS_35 += build/$(CONFIG)/inc/http.h
DEPS_35 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_35 += build/$(CONFIG)/inc/zlib.h

build/$(CONFIG)/obj/ejsLib.o: \
    src/paks/ejs/ejsLib.c $(DEPS_35)
	@echo '   [Compile] build/$(CONFIG)/obj/ejsLib.o'
	$(CC) -c -o build/$(CONFIG)/obj/ejsLib.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/ejs/ejsLib.c

ifeq ($(ME_COM_EJS),1)
#
#   libejs
#
DEPS_36 += build/$(CONFIG)/inc/mpr.h
DEPS_36 += build/$(CONFIG)/inc/me.h
DEPS_36 += build/$(CONFIG)/inc/osdep.h
DEPS_36 += build/$(CONFIG)/obj/mprLib.o
DEPS_36 += build/$(CONFIG)/bin/libmpr.a
DEPS_36 += build/$(CONFIG)/inc/pcre.h
DEPS_36 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_36 += build/$(CONFIG)/bin/libpcre.a
endif
DEPS_36 += build/$(CONFIG)/inc/http.h
DEPS_36 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_36 += build/$(CONFIG)/bin/libhttp.a
endif
DEPS_36 += build/$(CONFIG)/inc/zlib.h
DEPS_36 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_36 += build/$(CONFIG)/bin/libzlib.a
endif
DEPS_36 += build/$(CONFIG)/inc/ejs.h
DEPS_36 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_36 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_36 += build/$(CONFIG)/obj/ejsLib.o

build/$(CONFIG)/bin/libejs.a: $(DEPS_36)
	@echo '      [Link] build/$(CONFIG)/bin/libejs.a'
	ar -cr build/$(CONFIG)/bin/libejs.a "build/$(CONFIG)/obj/ejsLib.o" >>build\nmake.log
endif

#
#   ejsHandler.o
#
DEPS_37 += build/$(CONFIG)/inc/me.h
DEPS_37 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/ejsHandler.o: \
    src/modules/ejsHandler.c $(DEPS_37)
	@echo '   [Compile] build/$(CONFIG)/obj/ejsHandler.o'
	$(CC) -c -o build/$(CONFIG)/obj/ejsHandler.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/modules/ejsHandler.c

ifeq ($(ME_COM_EJS),1)
#
#   libmod_ejs
#
DEPS_38 += build/$(CONFIG)/inc/mpr.h
DEPS_38 += build/$(CONFIG)/inc/me.h
DEPS_38 += build/$(CONFIG)/inc/osdep.h
DEPS_38 += build/$(CONFIG)/obj/mprLib.o
DEPS_38 += build/$(CONFIG)/bin/libmpr.a
DEPS_38 += build/$(CONFIG)/inc/pcre.h
DEPS_38 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_38 += build/$(CONFIG)/bin/libpcre.a
endif
DEPS_38 += build/$(CONFIG)/inc/http.h
DEPS_38 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_38 += build/$(CONFIG)/bin/libhttp.a
endif
DEPS_38 += build/$(CONFIG)/inc/appweb.h
DEPS_38 += build/$(CONFIG)/inc/customize.h
DEPS_38 += build/$(CONFIG)/obj/config.o
DEPS_38 += build/$(CONFIG)/obj/convenience.o
DEPS_38 += build/$(CONFIG)/bin/libappweb.a
DEPS_38 += build/$(CONFIG)/inc/zlib.h
DEPS_38 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_38 += build/$(CONFIG)/bin/libzlib.a
endif
DEPS_38 += build/$(CONFIG)/inc/ejs.h
DEPS_38 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_38 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_38 += build/$(CONFIG)/obj/ejsLib.o
DEPS_38 += build/$(CONFIG)/bin/libejs.a
DEPS_38 += build/$(CONFIG)/obj/ejsHandler.o

build/$(CONFIG)/bin/libmod_ejs.a: $(DEPS_38)
	@echo '      [Link] build/$(CONFIG)/bin/libmod_ejs.a'
	ar -cr build/$(CONFIG)/bin/libmod_ejs.a "build/$(CONFIG)/obj/ejsHandler.o" >>build\nmake.log
endif

#
#   phpHandler.o
#
DEPS_39 += build/$(CONFIG)/inc/me.h
DEPS_39 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/phpHandler.o: \
    src/modules/phpHandler.c $(DEPS_39)
	@echo '   [Compile] build/$(CONFIG)/obj/phpHandler.o'
	$(CC) -c -o build/$(CONFIG)/obj/phpHandler.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_PHP_PATH)" "-I$(ME_COM_PHP_PATH)/main" "-I$(ME_COM_PHP_PATH)/Zend" "-I$(ME_COM_PHP_PATH)/TSRM" src/modules/phpHandler.c

ifeq ($(ME_COM_PHP),1)
#
#   libmod_php
#
DEPS_40 += build/$(CONFIG)/inc/mpr.h
DEPS_40 += build/$(CONFIG)/inc/me.h
DEPS_40 += build/$(CONFIG)/inc/osdep.h
DEPS_40 += build/$(CONFIG)/obj/mprLib.o
DEPS_40 += build/$(CONFIG)/bin/libmpr.a
DEPS_40 += build/$(CONFIG)/inc/pcre.h
DEPS_40 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_40 += build/$(CONFIG)/bin/libpcre.a
endif
DEPS_40 += build/$(CONFIG)/inc/http.h
DEPS_40 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_40 += build/$(CONFIG)/bin/libhttp.a
endif
DEPS_40 += build/$(CONFIG)/inc/appweb.h
DEPS_40 += build/$(CONFIG)/inc/customize.h
DEPS_40 += build/$(CONFIG)/obj/config.o
DEPS_40 += build/$(CONFIG)/obj/convenience.o
DEPS_40 += build/$(CONFIG)/bin/libappweb.a
DEPS_40 += build/$(CONFIG)/obj/phpHandler.o

build/$(CONFIG)/bin/libmod_php.a: $(DEPS_40)
	@echo '      [Link] build/$(CONFIG)/bin/libmod_php.a'
	ar -cr build/$(CONFIG)/bin/libmod_php.a "build/$(CONFIG)/obj/phpHandler.o" >>build\nmake.log
endif

#
#   cgiHandler.o
#
DEPS_41 += build/$(CONFIG)/inc/me.h
DEPS_41 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/cgiHandler.o: \
    src/modules/cgiHandler.c $(DEPS_41)
	@echo '   [Compile] build/$(CONFIG)/obj/cgiHandler.o'
	$(CC) -c -o build/$(CONFIG)/obj/cgiHandler.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/modules/cgiHandler.c

ifeq ($(ME_COM_CGI),1)
#
#   libmod_cgi
#
DEPS_42 += build/$(CONFIG)/inc/mpr.h
DEPS_42 += build/$(CONFIG)/inc/me.h
DEPS_42 += build/$(CONFIG)/inc/osdep.h
DEPS_42 += build/$(CONFIG)/obj/mprLib.o
DEPS_42 += build/$(CONFIG)/bin/libmpr.a
DEPS_42 += build/$(CONFIG)/inc/pcre.h
DEPS_42 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_42 += build/$(CONFIG)/bin/libpcre.a
endif
DEPS_42 += build/$(CONFIG)/inc/http.h
DEPS_42 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_42 += build/$(CONFIG)/bin/libhttp.a
endif
DEPS_42 += build/$(CONFIG)/inc/appweb.h
DEPS_42 += build/$(CONFIG)/inc/customize.h
DEPS_42 += build/$(CONFIG)/obj/config.o
DEPS_42 += build/$(CONFIG)/obj/convenience.o
DEPS_42 += build/$(CONFIG)/bin/libappweb.a
DEPS_42 += build/$(CONFIG)/obj/cgiHandler.o

build/$(CONFIG)/bin/libmod_cgi.a: $(DEPS_42)
	@echo '      [Link] build/$(CONFIG)/bin/libmod_cgi.a'
	ar -cr build/$(CONFIG)/bin/libmod_cgi.a "build/$(CONFIG)/obj/cgiHandler.o" >>build\nmake.log
endif

#
#   appweb.o
#
DEPS_43 += build/$(CONFIG)/inc/me.h
DEPS_43 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/appweb.o: \
    src/server/appweb.c $(DEPS_43)
	@echo '   [Compile] build/$(CONFIG)/obj/appweb.o'
	$(CC) -c -o build/$(CONFIG)/obj/appweb.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_PHP_PATH)" "-I$(ME_COM_PHP_PATH)/main" "-I$(ME_COM_PHP_PATH)/Zend" "-I$(ME_COM_PHP_PATH)/TSRM" src/server/appweb.c

#
#   appweb
#
DEPS_44 += build/$(CONFIG)/inc/mpr.h
DEPS_44 += build/$(CONFIG)/inc/me.h
DEPS_44 += build/$(CONFIG)/inc/osdep.h
DEPS_44 += build/$(CONFIG)/obj/mprLib.o
DEPS_44 += build/$(CONFIG)/bin/libmpr.a
DEPS_44 += build/$(CONFIG)/inc/pcre.h
DEPS_44 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_44 += build/$(CONFIG)/bin/libpcre.a
endif
DEPS_44 += build/$(CONFIG)/inc/http.h
DEPS_44 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_44 += build/$(CONFIG)/bin/libhttp.a
endif
DEPS_44 += build/$(CONFIG)/inc/appweb.h
DEPS_44 += build/$(CONFIG)/inc/customize.h
DEPS_44 += build/$(CONFIG)/obj/config.o
DEPS_44 += build/$(CONFIG)/obj/convenience.o
DEPS_44 += build/$(CONFIG)/bin/libappweb.a
DEPS_44 += build/$(CONFIG)/inc/esp.h
DEPS_44 += build/$(CONFIG)/obj/espLib.o
ifeq ($(ME_COM_ESP),1)
    DEPS_44 += build/$(CONFIG)/bin/libmod_esp.a
endif
DEPS_44 += build/$(CONFIG)/obj/slink.o
DEPS_44 += build/$(CONFIG)/bin/libslink.a
DEPS_44 += build/$(CONFIG)/inc/est.h
DEPS_44 += build/$(CONFIG)/obj/estLib.o
ifeq ($(ME_COM_EST),1)
    DEPS_44 += build/$(CONFIG)/bin/libest.a
endif
DEPS_44 += build/$(CONFIG)/obj/mprSsl.o
DEPS_44 += build/$(CONFIG)/bin/libmprssl.a
DEPS_44 += build/$(CONFIG)/obj/sslModule.o
ifeq ($(ME_COM_SSL),1)
    DEPS_44 += build/$(CONFIG)/bin/libmod_ssl.a
endif
DEPS_44 += build/$(CONFIG)/inc/zlib.h
DEPS_44 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_44 += build/$(CONFIG)/bin/libzlib.a
endif
DEPS_44 += build/$(CONFIG)/inc/ejs.h
DEPS_44 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_44 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_44 += build/$(CONFIG)/obj/ejsLib.o
ifeq ($(ME_COM_EJS),1)
    DEPS_44 += build/$(CONFIG)/bin/libejs.a
endif
DEPS_44 += build/$(CONFIG)/obj/ejsHandler.o
ifeq ($(ME_COM_EJS),1)
    DEPS_44 += build/$(CONFIG)/bin/libmod_ejs.a
endif
DEPS_44 += build/$(CONFIG)/obj/phpHandler.o
ifeq ($(ME_COM_PHP),1)
    DEPS_44 += build/$(CONFIG)/bin/libmod_php.a
endif
DEPS_44 += build/$(CONFIG)/obj/cgiHandler.o
ifeq ($(ME_COM_CGI),1)
    DEPS_44 += build/$(CONFIG)/bin/libmod_cgi.a
endif
DEPS_44 += build/$(CONFIG)/obj/appweb.o

LIBS_44 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_44 += -lhttp
endif
LIBS_44 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_44 += -lpcre
endif
LIBS_44 += -lslink
ifeq ($(ME_COM_ESP),1)
    LIBS_44 += -lmod_esp
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_44 += -lsql
endif
ifeq ($(ME_COM_SSL),1)
    LIBS_44 += -lmod_ssl
endif
LIBS_44 += -lmprssl
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_44 += -lssl
    LIBPATHS_44 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_44 += -lcrypto
    LIBPATHS_44 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_EST),1)
    LIBS_44 += -lest
endif
ifeq ($(ME_COM_EJS),1)
    LIBS_44 += -lmod_ejs
endif
ifeq ($(ME_COM_EJS),1)
    LIBS_44 += -lejs
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_44 += -lzlib
endif
ifeq ($(ME_COM_PHP),1)
    LIBS_44 += -lmod_php
endif
ifeq ($(ME_COM_PHP),1)
    LIBS_44 += -lphp5
    LIBPATHS_44 += -L$(ME_COM_PHP_PATH)/libs
endif
ifeq ($(ME_COM_CGI),1)
    LIBS_44 += -lmod_cgi
endif

build/$(CONFIG)/bin/appweb.out: $(DEPS_44)
	@echo '      [Link] build/$(CONFIG)/bin/appweb.out'
	$(CC) -o build/$(CONFIG)/bin/appweb.out $(LDFLAGS) $(LIBPATHS)   "build/$(CONFIG)/obj/appweb.o" $(LIBPATHS_44) $(LIBS_44) $(LIBS_44) $(LIBS) -Wl,-r 

#
#   authpass.o
#
DEPS_45 += build/$(CONFIG)/inc/me.h
DEPS_45 += build/$(CONFIG)/inc/appweb.h

build/$(CONFIG)/obj/authpass.o: \
    src/utils/authpass.c $(DEPS_45)
	@echo '   [Compile] build/$(CONFIG)/obj/authpass.o'
	$(CC) -c -o build/$(CONFIG)/obj/authpass.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/utils/authpass.c

#
#   authpass
#
DEPS_46 += build/$(CONFIG)/inc/mpr.h
DEPS_46 += build/$(CONFIG)/inc/me.h
DEPS_46 += build/$(CONFIG)/inc/osdep.h
DEPS_46 += build/$(CONFIG)/obj/mprLib.o
DEPS_46 += build/$(CONFIG)/bin/libmpr.a
DEPS_46 += build/$(CONFIG)/inc/pcre.h
DEPS_46 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_46 += build/$(CONFIG)/bin/libpcre.a
endif
DEPS_46 += build/$(CONFIG)/inc/http.h
DEPS_46 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_46 += build/$(CONFIG)/bin/libhttp.a
endif
DEPS_46 += build/$(CONFIG)/inc/appweb.h
DEPS_46 += build/$(CONFIG)/inc/customize.h
DEPS_46 += build/$(CONFIG)/obj/config.o
DEPS_46 += build/$(CONFIG)/obj/convenience.o
DEPS_46 += build/$(CONFIG)/bin/libappweb.a
DEPS_46 += build/$(CONFIG)/obj/authpass.o

LIBS_46 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_46 += -lhttp
endif
LIBS_46 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_46 += -lpcre
endif

build/$(CONFIG)/bin/authpass.out: $(DEPS_46)
	@echo '      [Link] build/$(CONFIG)/bin/authpass.out'
	$(CC) -o build/$(CONFIG)/bin/authpass.out $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/authpass.o" $(LIBPATHS_46) $(LIBS_46) $(LIBS_46) $(LIBS) -Wl,-r 

#
#   cgiProgram.o
#
DEPS_47 += build/$(CONFIG)/inc/me.h

build/$(CONFIG)/obj/cgiProgram.o: \
    src/utils/cgiProgram.c $(DEPS_47)
	@echo '   [Compile] build/$(CONFIG)/obj/cgiProgram.o'
	$(CC) -c -o build/$(CONFIG)/obj/cgiProgram.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/utils/cgiProgram.c

ifeq ($(ME_COM_CGI),1)
#
#   cgiProgram
#
DEPS_48 += build/$(CONFIG)/inc/me.h
DEPS_48 += build/$(CONFIG)/obj/cgiProgram.o

build/$(CONFIG)/bin/cgiProgram.out: $(DEPS_48)
	@echo '      [Link] build/$(CONFIG)/bin/cgiProgram.out'
	$(CC) -o build/$(CONFIG)/bin/cgiProgram.out $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/cgiProgram.o" $(LIBS) -Wl,-r 
endif

#
#   ejsc.o
#
DEPS_49 += build/$(CONFIG)/inc/me.h
DEPS_49 += build/$(CONFIG)/inc/ejs.h

build/$(CONFIG)/obj/ejsc.o: \
    src/paks/ejs/ejsc.c $(DEPS_49)
	@echo '   [Compile] build/$(CONFIG)/obj/ejsc.o'
	$(CC) -c -o build/$(CONFIG)/obj/ejsc.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/ejs/ejsc.c

ifeq ($(ME_COM_EJS),1)
#
#   ejsc
#
DEPS_50 += build/$(CONFIG)/inc/mpr.h
DEPS_50 += build/$(CONFIG)/inc/me.h
DEPS_50 += build/$(CONFIG)/inc/osdep.h
DEPS_50 += build/$(CONFIG)/obj/mprLib.o
DEPS_50 += build/$(CONFIG)/bin/libmpr.a
DEPS_50 += build/$(CONFIG)/inc/pcre.h
DEPS_50 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_50 += build/$(CONFIG)/bin/libpcre.a
endif
DEPS_50 += build/$(CONFIG)/inc/http.h
DEPS_50 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_50 += build/$(CONFIG)/bin/libhttp.a
endif
DEPS_50 += build/$(CONFIG)/inc/zlib.h
DEPS_50 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_50 += build/$(CONFIG)/bin/libzlib.a
endif
DEPS_50 += build/$(CONFIG)/inc/ejs.h
DEPS_50 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_50 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_50 += build/$(CONFIG)/obj/ejsLib.o
DEPS_50 += build/$(CONFIG)/bin/libejs.a
DEPS_50 += build/$(CONFIG)/obj/ejsc.o

LIBS_50 += -lejs
ifeq ($(ME_COM_HTTP),1)
    LIBS_50 += -lhttp
endif
LIBS_50 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_50 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_50 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_50 += -lsql
endif

build/$(CONFIG)/bin/ejsc.out: $(DEPS_50)
	@echo '      [Link] build/$(CONFIG)/bin/ejsc.out'
	$(CC) -o build/$(CONFIG)/bin/ejsc.out $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/ejsc.o" $(LIBPATHS_50) $(LIBS_50) $(LIBS_50) $(LIBS) -Wl,-r 
endif

ifeq ($(ME_COM_EJS),1)
#
#   ejs.mod
#
DEPS_51 += src/paks/ejs/ejs.es
DEPS_51 += build/$(CONFIG)/inc/mpr.h
DEPS_51 += build/$(CONFIG)/inc/me.h
DEPS_51 += build/$(CONFIG)/inc/osdep.h
DEPS_51 += build/$(CONFIG)/obj/mprLib.o
DEPS_51 += build/$(CONFIG)/bin/libmpr.a
DEPS_51 += build/$(CONFIG)/inc/pcre.h
DEPS_51 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_51 += build/$(CONFIG)/bin/libpcre.a
endif
DEPS_51 += build/$(CONFIG)/inc/http.h
DEPS_51 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_51 += build/$(CONFIG)/bin/libhttp.a
endif
DEPS_51 += build/$(CONFIG)/inc/zlib.h
DEPS_51 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_51 += build/$(CONFIG)/bin/libzlib.a
endif
DEPS_51 += build/$(CONFIG)/inc/ejs.h
DEPS_51 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_51 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_51 += build/$(CONFIG)/obj/ejsLib.o
DEPS_51 += build/$(CONFIG)/bin/libejs.a
DEPS_51 += build/$(CONFIG)/obj/ejsc.o
DEPS_51 += build/$(CONFIG)/bin/ejsc.out

build/$(CONFIG)/bin/ejs.mod: $(DEPS_51)
	( \
	cd src/paks/ejs; \
	../../../build/$(CONFIG)/bin/ejsc --out ../../../build/$(CONFIG)/bin/ejs.mod --optimize 9 --bind --require null ejs.es ; \
	)
endif

#
#   ejs.o
#
DEPS_52 += build/$(CONFIG)/inc/me.h
DEPS_52 += build/$(CONFIG)/inc/ejs.h

build/$(CONFIG)/obj/ejs.o: \
    src/paks/ejs/ejs.c $(DEPS_52)
	@echo '   [Compile] build/$(CONFIG)/obj/ejs.o'
	$(CC) -c -o build/$(CONFIG)/obj/ejs.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/ejs/ejs.c

ifeq ($(ME_COM_EJS),1)
#
#   ejscmd
#
DEPS_53 += build/$(CONFIG)/inc/mpr.h
DEPS_53 += build/$(CONFIG)/inc/me.h
DEPS_53 += build/$(CONFIG)/inc/osdep.h
DEPS_53 += build/$(CONFIG)/obj/mprLib.o
DEPS_53 += build/$(CONFIG)/bin/libmpr.a
DEPS_53 += build/$(CONFIG)/inc/pcre.h
DEPS_53 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_53 += build/$(CONFIG)/bin/libpcre.a
endif
DEPS_53 += build/$(CONFIG)/inc/http.h
DEPS_53 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_53 += build/$(CONFIG)/bin/libhttp.a
endif
DEPS_53 += build/$(CONFIG)/inc/zlib.h
DEPS_53 += build/$(CONFIG)/obj/zlib.o
ifeq ($(ME_COM_ZLIB),1)
    DEPS_53 += build/$(CONFIG)/bin/libzlib.a
endif
DEPS_53 += build/$(CONFIG)/inc/ejs.h
DEPS_53 += build/$(CONFIG)/inc/ejs.slots.h
DEPS_53 += build/$(CONFIG)/inc/ejsByteGoto.h
DEPS_53 += build/$(CONFIG)/obj/ejsLib.o
DEPS_53 += build/$(CONFIG)/bin/libejs.a
DEPS_53 += build/$(CONFIG)/obj/ejs.o

LIBS_53 += -lejs
ifeq ($(ME_COM_HTTP),1)
    LIBS_53 += -lhttp
endif
LIBS_53 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_53 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_53 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_53 += -lsql
endif

build/$(CONFIG)/bin/ejs.out: $(DEPS_53)
	@echo '      [Link] build/$(CONFIG)/bin/ejs.out'
	$(CC) -o build/$(CONFIG)/bin/ejs.out $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/ejs.o" $(LIBPATHS_53) $(LIBS_53) $(LIBS_53) $(LIBS) -Wl,-r 
endif

ifeq ($(ME_COM_ESP),1)
#
#   esp-paks
#
DEPS_54 += src/paks/esp-html-mvc
DEPS_54 += src/paks/esp-html-mvc/LICENSE.md
DEPS_54 += src/paks/esp-html-mvc/README.md
DEPS_54 += src/paks/esp-html-mvc/client
DEPS_54 += src/paks/esp-html-mvc/client/assets
DEPS_54 += src/paks/esp-html-mvc/client/assets/favicon.ico
DEPS_54 += src/paks/esp-html-mvc/client/css
DEPS_54 += src/paks/esp-html-mvc/client/css/all.css
DEPS_54 += src/paks/esp-html-mvc/client/css/all.less
DEPS_54 += src/paks/esp-html-mvc/client/index.esp
DEPS_54 += src/paks/esp-html-mvc/css
DEPS_54 += src/paks/esp-html-mvc/css/app.less
DEPS_54 += src/paks/esp-html-mvc/css/theme.less
DEPS_54 += src/paks/esp-html-mvc/generate
DEPS_54 += src/paks/esp-html-mvc/generate/appweb.conf
DEPS_54 += src/paks/esp-html-mvc/generate/controller.c
DEPS_54 += src/paks/esp-html-mvc/generate/controllerSingleton.c
DEPS_54 += src/paks/esp-html-mvc/generate/edit.esp
DEPS_54 += src/paks/esp-html-mvc/generate/list.esp
DEPS_54 += src/paks/esp-html-mvc/layouts
DEPS_54 += src/paks/esp-html-mvc/layouts/default.esp
DEPS_54 += src/paks/esp-html-mvc/package.json
DEPS_54 += src/paks/esp-mvc
DEPS_54 += src/paks/esp-mvc/LICENSE.md
DEPS_54 += src/paks/esp-mvc/README.md
DEPS_54 += src/paks/esp-mvc/generate
DEPS_54 += src/paks/esp-mvc/generate/appweb.conf
DEPS_54 += src/paks/esp-mvc/generate/controller.c
DEPS_54 += src/paks/esp-mvc/generate/migration.c
DEPS_54 += src/paks/esp-mvc/generate/src
DEPS_54 += src/paks/esp-mvc/generate/src/app.c
DEPS_54 += src/paks/esp-mvc/package.json
DEPS_54 += src/paks/esp-server
DEPS_54 += src/paks/esp-server/LICENSE.md
DEPS_54 += src/paks/esp-server/README.md
DEPS_54 += src/paks/esp-server/generate
DEPS_54 += src/paks/esp-server/generate/appweb.conf
DEPS_54 += src/paks/esp-server/package.json

build/$(CONFIG)/esp: $(DEPS_54)
	( \
	cd src/paks; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/5.2.0" ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/5.2.0/client" ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/5.2.0/client/assets" ; \
	cp esp-html-mvc/client/assets/favicon.ico ../../build/$(CONFIG)/esp/esp-html-mvc/5.2.0/client/assets/favicon.ico ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/5.2.0/client/css" ; \
	cp esp-html-mvc/client/css/all.css ../../build/$(CONFIG)/esp/esp-html-mvc/5.2.0/client/css/all.css ; \
	cp esp-html-mvc/client/css/all.less ../../build/$(CONFIG)/esp/esp-html-mvc/5.2.0/client/css/all.less ; \
	cp esp-html-mvc/client/index.esp ../../build/$(CONFIG)/esp/esp-html-mvc/5.2.0/client/index.esp ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/5.2.0/css" ; \
	cp esp-html-mvc/css/app.less ../../build/$(CONFIG)/esp/esp-html-mvc/5.2.0/css/app.less ; \
	cp esp-html-mvc/css/theme.less ../../build/$(CONFIG)/esp/esp-html-mvc/5.2.0/css/theme.less ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/5.2.0/generate" ; \
	cp esp-html-mvc/generate/appweb.conf ../../build/$(CONFIG)/esp/esp-html-mvc/5.2.0/generate/appweb.conf ; \
	cp esp-html-mvc/generate/controller.c ../../build/$(CONFIG)/esp/esp-html-mvc/5.2.0/generate/controller.c ; \
	cp esp-html-mvc/generate/controllerSingleton.c ../../build/$(CONFIG)/esp/esp-html-mvc/5.2.0/generate/controllerSingleton.c ; \
	cp esp-html-mvc/generate/edit.esp ../../build/$(CONFIG)/esp/esp-html-mvc/5.2.0/generate/edit.esp ; \
	cp esp-html-mvc/generate/list.esp ../../build/$(CONFIG)/esp/esp-html-mvc/5.2.0/generate/list.esp ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-html-mvc/5.2.0/layouts" ; \
	cp esp-html-mvc/layouts/default.esp ../../build/$(CONFIG)/esp/esp-html-mvc/5.2.0/layouts/default.esp ; \
	cp esp-html-mvc/LICENSE.md ../../build/$(CONFIG)/esp/esp-html-mvc/5.2.0/LICENSE.md ; \
	cp esp-html-mvc/package.json ../../build/$(CONFIG)/esp/esp-html-mvc/5.2.0/package.json ; \
	cp esp-html-mvc/README.md ../../build/$(CONFIG)/esp/esp-html-mvc/5.2.0/README.md ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-mvc/5.2.0" ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-mvc/5.2.0/generate" ; \
	cp esp-mvc/generate/appweb.conf ../../build/$(CONFIG)/esp/esp-mvc/5.2.0/generate/appweb.conf ; \
	cp esp-mvc/generate/controller.c ../../build/$(CONFIG)/esp/esp-mvc/5.2.0/generate/controller.c ; \
	cp esp-mvc/generate/migration.c ../../build/$(CONFIG)/esp/esp-mvc/5.2.0/generate/migration.c ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-mvc/5.2.0/generate/src" ; \
	cp esp-mvc/generate/src/app.c ../../build/$(CONFIG)/esp/esp-mvc/5.2.0/generate/src/app.c ; \
	cp esp-mvc/LICENSE.md ../../build/$(CONFIG)/esp/esp-mvc/5.2.0/LICENSE.md ; \
	cp esp-mvc/package.json ../../build/$(CONFIG)/esp/esp-mvc/5.2.0/package.json ; \
	cp esp-mvc/README.md ../../build/$(CONFIG)/esp/esp-mvc/5.2.0/README.md ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-server/5.2.0" ; \
	mkdir -p "../../build/$(CONFIG)/esp/esp-server/5.2.0/generate" ; \
	cp esp-server/generate/appweb.conf ../../build/$(CONFIG)/esp/esp-server/5.2.0/generate/appweb.conf ; \
	cp esp-server/LICENSE.md ../../build/$(CONFIG)/esp/esp-server/5.2.0/LICENSE.md ; \
	cp esp-server/package.json ../../build/$(CONFIG)/esp/esp-server/5.2.0/package.json ; \
	cp esp-server/README.md ../../build/$(CONFIG)/esp/esp-server/5.2.0/README.md ; \
	)
endif

ifeq ($(ME_COM_ESP),1)
#
#   esp.conf
#
DEPS_55 += src/paks/esp/esp.conf

build/$(CONFIG)/bin/esp.conf: $(DEPS_55)
	@echo '      [Copy] build/$(CONFIG)/bin/esp.conf'
	mkdir -p "build/$(CONFIG)/bin"
	cp src/paks/esp/esp.conf build/$(CONFIG)/bin/esp.conf
endif

#
#   esp.o
#
DEPS_56 += build/$(CONFIG)/inc/me.h
DEPS_56 += build/$(CONFIG)/inc/esp.h

build/$(CONFIG)/obj/esp.o: \
    src/paks/esp/esp.c $(DEPS_56)
	@echo '   [Compile] build/$(CONFIG)/obj/esp.o'
	$(CC) -c -o build/$(CONFIG)/obj/esp.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/esp/esp.c

ifeq ($(ME_COM_ESP),1)
#
#   espcmd
#
DEPS_57 += build/$(CONFIG)/inc/mpr.h
DEPS_57 += build/$(CONFIG)/inc/me.h
DEPS_57 += build/$(CONFIG)/inc/osdep.h
DEPS_57 += build/$(CONFIG)/obj/mprLib.o
DEPS_57 += build/$(CONFIG)/bin/libmpr.a
DEPS_57 += build/$(CONFIG)/inc/pcre.h
DEPS_57 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_57 += build/$(CONFIG)/bin/libpcre.a
endif
DEPS_57 += build/$(CONFIG)/inc/http.h
DEPS_57 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_57 += build/$(CONFIG)/bin/libhttp.a
endif
DEPS_57 += build/$(CONFIG)/inc/appweb.h
DEPS_57 += build/$(CONFIG)/inc/customize.h
DEPS_57 += build/$(CONFIG)/obj/config.o
DEPS_57 += build/$(CONFIG)/obj/convenience.o
DEPS_57 += build/$(CONFIG)/bin/libappweb.a
DEPS_57 += build/$(CONFIG)/inc/esp.h
DEPS_57 += build/$(CONFIG)/obj/espLib.o
DEPS_57 += build/$(CONFIG)/bin/libmod_esp.a
DEPS_57 += build/$(CONFIG)/obj/esp.o

LIBS_57 += -lmod_esp
LIBS_57 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_57 += -lhttp
endif
LIBS_57 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_57 += -lpcre
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_57 += -lsql
endif

build/$(CONFIG)/bin/esp.out: $(DEPS_57)
	@echo '      [Link] build/$(CONFIG)/bin/esp.out'
	$(CC) -o build/$(CONFIG)/bin/esp.out $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/esp.o" $(LIBPATHS_57) $(LIBS_57) $(LIBS_57) $(LIBS) -Wl,-r 
endif


ifeq ($(ME_COM_ESP),1)
#
#   genslink
#
DEPS_58 += build/$(CONFIG)/inc/mpr.h
DEPS_58 += build/$(CONFIG)/inc/me.h
DEPS_58 += build/$(CONFIG)/inc/osdep.h
DEPS_58 += build/$(CONFIG)/obj/mprLib.o
DEPS_58 += build/$(CONFIG)/bin/libmpr.a
DEPS_58 += build/$(CONFIG)/inc/pcre.h
DEPS_58 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_58 += build/$(CONFIG)/bin/libpcre.a
endif
DEPS_58 += build/$(CONFIG)/inc/http.h
DEPS_58 += build/$(CONFIG)/obj/httpLib.o
ifeq ($(ME_COM_HTTP),1)
    DEPS_58 += build/$(CONFIG)/bin/libhttp.a
endif
DEPS_58 += build/$(CONFIG)/inc/appweb.h
DEPS_58 += build/$(CONFIG)/inc/customize.h
DEPS_58 += build/$(CONFIG)/obj/config.o
DEPS_58 += build/$(CONFIG)/obj/convenience.o
DEPS_58 += build/$(CONFIG)/bin/libappweb.a
DEPS_58 += build/$(CONFIG)/inc/esp.h
DEPS_58 += build/$(CONFIG)/obj/espLib.o
DEPS_58 += build/$(CONFIG)/bin/libmod_esp.a

genslink: $(DEPS_58)
	( \
	cd src/server; \
	echo '    [Create] slink.c' ; \
	esp --static --genlink slink.c compile ; \
	)
endif

#
#   http-ca-crt
#
DEPS_59 += src/paks/http/ca.crt

build/$(CONFIG)/bin/ca.crt: $(DEPS_59)
	@echo '      [Copy] build/$(CONFIG)/bin/ca.crt'
	mkdir -p "build/$(CONFIG)/bin"
	cp src/paks/http/ca.crt build/$(CONFIG)/bin/ca.crt

#
#   http.o
#
DEPS_60 += build/$(CONFIG)/inc/me.h
DEPS_60 += build/$(CONFIG)/inc/http.h

build/$(CONFIG)/obj/http.o: \
    src/paks/http/http.c $(DEPS_60)
	@echo '   [Compile] build/$(CONFIG)/obj/http.o'
	$(CC) -c -o build/$(CONFIG)/obj/http.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/paks/http/http.c

ifeq ($(ME_COM_HTTP),1)
#
#   httpcmd
#
DEPS_61 += build/$(CONFIG)/inc/mpr.h
DEPS_61 += build/$(CONFIG)/inc/me.h
DEPS_61 += build/$(CONFIG)/inc/osdep.h
DEPS_61 += build/$(CONFIG)/obj/mprLib.o
DEPS_61 += build/$(CONFIG)/bin/libmpr.a
DEPS_61 += build/$(CONFIG)/inc/pcre.h
DEPS_61 += build/$(CONFIG)/obj/pcre.o
ifeq ($(ME_COM_PCRE),1)
    DEPS_61 += build/$(CONFIG)/bin/libpcre.a
endif
DEPS_61 += build/$(CONFIG)/inc/http.h
DEPS_61 += build/$(CONFIG)/obj/httpLib.o
DEPS_61 += build/$(CONFIG)/bin/libhttp.a
DEPS_61 += build/$(CONFIG)/inc/est.h
DEPS_61 += build/$(CONFIG)/obj/estLib.o
ifeq ($(ME_COM_EST),1)
    DEPS_61 += build/$(CONFIG)/bin/libest.a
endif
DEPS_61 += build/$(CONFIG)/obj/mprSsl.o
DEPS_61 += build/$(CONFIG)/bin/libmprssl.a
DEPS_61 += build/$(CONFIG)/obj/http.o

LIBS_61 += -lhttp
LIBS_61 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_61 += -lpcre
endif
LIBS_61 += -lmprssl
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_61 += -lssl
    LIBPATHS_61 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_61 += -lcrypto
    LIBPATHS_61 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_EST),1)
    LIBS_61 += -lest
endif

build/$(CONFIG)/bin/http.out: $(DEPS_61)
	@echo '      [Link] build/$(CONFIG)/bin/http.out'
	$(CC) -o build/$(CONFIG)/bin/http.out $(LDFLAGS) $(LIBPATHS)  "build/$(CONFIG)/obj/http.o" $(LIBPATHS_61) $(LIBS_61) $(LIBS_61) $(LIBS) -Wl,-r 
endif

#
#   sqlite3.h
#
DEPS_62 += src/paks/sqlite/sqlite3.h

build/$(CONFIG)/inc/sqlite3.h: $(DEPS_62)
	@echo '      [Copy] build/$(CONFIG)/inc/sqlite3.h'
	mkdir -p "build/$(CONFIG)/inc"
	cp src/paks/sqlite/sqlite3.h build/$(CONFIG)/inc/sqlite3.h

#
#   sqlite3.o
#
DEPS_63 += build/$(CONFIG)/inc/me.h
DEPS_63 += build/$(CONFIG)/inc/sqlite3.h

build/$(CONFIG)/obj/sqlite3.o: \
    src/paks/sqlite/sqlite3.c $(DEPS_63)
	@echo '   [Compile] build/$(CONFIG)/obj/sqlite3.o'
	$(CC) -c -o build/$(CONFIG)/obj/sqlite3.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/sqlite/sqlite3.c

ifeq ($(ME_COM_SQLITE),1)
#
#   libsql
#
DEPS_64 += build/$(CONFIG)/inc/sqlite3.h
DEPS_64 += build/$(CONFIG)/inc/me.h
DEPS_64 += build/$(CONFIG)/obj/sqlite3.o

build/$(CONFIG)/bin/libsql.a: $(DEPS_64)
	@echo '      [Link] build/$(CONFIG)/bin/libsql.a'
	ar -cr build/$(CONFIG)/bin/libsql.a "build/$(CONFIG)/obj/sqlite3.o" >>build\nmake.log
endif

#
#   manager.o
#
DEPS_65 += build/$(CONFIG)/inc/me.h
DEPS_65 += build/$(CONFIG)/inc/mpr.h

build/$(CONFIG)/obj/manager.o: \
    src/paks/mpr/manager.c $(DEPS_65)
	@echo '   [Compile] build/$(CONFIG)/obj/manager.o'
	$(CC) -c -o build/$(CONFIG)/obj/manager.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/mpr/manager.c

#
#   manager
#
DEPS_66 += build/$(CONFIG)/inc/mpr.h
DEPS_66 += build/$(CONFIG)/inc/me.h
DEPS_66 += build/$(CONFIG)/inc/osdep.h
DEPS_66 += build/$(CONFIG)/obj/mprLib.o
DEPS_66 += build/$(CONFIG)/bin/libmpr.a
DEPS_66 += build/$(CONFIG)/obj/manager.o

LIBS_66 += -lmpr

build/$(CONFIG)/bin/appman.out: $(DEPS_66)
	@echo '      [Link] build/$(CONFIG)/bin/appman.out'
	$(CC) -o build/$(CONFIG)/bin/appman.out $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/manager.o" $(LIBPATHS_66) $(LIBS_66) $(LIBS_66) $(LIBS) -Wl,-r 

#
#   server-cache
#
src/server/cache: $(DEPS_67)
	( \
	cd src/server; \
	mkdir -p "cache" ; \
	)

#
#   sqlite.o
#
DEPS_68 += build/$(CONFIG)/inc/me.h
DEPS_68 += build/$(CONFIG)/inc/sqlite3.h

build/$(CONFIG)/obj/sqlite.o: \
    src/paks/sqlite/sqlite.c $(DEPS_68)
	@echo '   [Compile] build/$(CONFIG)/obj/sqlite.o'
	$(CC) -c -o build/$(CONFIG)/obj/sqlite.o $(CFLAGS) $(DFLAGS) "-Ibuild/$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/sqlite/sqlite.c

ifeq ($(ME_COM_SQLITE),1)
#
#   sqliteshell
#
DEPS_69 += build/$(CONFIG)/inc/sqlite3.h
DEPS_69 += build/$(CONFIG)/inc/me.h
DEPS_69 += build/$(CONFIG)/obj/sqlite3.o
DEPS_69 += build/$(CONFIG)/bin/libsql.a
DEPS_69 += build/$(CONFIG)/obj/sqlite.o

LIBS_69 += -lsql

build/$(CONFIG)/bin/sqlite.out: $(DEPS_69)
	@echo '      [Link] build/$(CONFIG)/bin/sqlite.out'
	$(CC) -o build/$(CONFIG)/bin/sqlite.out $(LDFLAGS) $(LIBPATHS) "build/$(CONFIG)/obj/sqlite.o" $(LIBPATHS_69) $(LIBS_69) $(LIBS_69) $(LIBS) -Wl,-r 
endif

#
#   installBinary
#
installBinary: $(DEPS_70)

#
#   install
#
DEPS_71 += installBinary

install: $(DEPS_71)


#
#   run
#
DEPS_72 += compile

run: $(DEPS_72)
	( \
	cd src/server; \
	sudo ../../build/$(CONFIG)/bin/appweb -v ; \
	)


#
#   uninstall
#
DEPS_73 += build

uninstall: $(DEPS_73)
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
version: $(DEPS_74)
	echo 5.2.0

