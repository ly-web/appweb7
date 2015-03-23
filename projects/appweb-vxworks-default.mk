#
#   appweb-vxworks-default.mk -- Makefile to build Embedthis Appweb for vxworks
#

NAME                  := appweb
VERSION               := 5.4.0
PROFILE               ?= default
ARCH                  ?= $(shell echo $(WIND_HOST_TYPE) | sed 's/-.*$(ME_ROOT_PREFIX)/')
CPU                   ?= $(subst X86,PENTIUM,$(shell echo $(ARCH) | tr a-z A-Z))
OS                    ?= vxworks
CC                    ?= cc$(subst x86,pentium,$(ARCH))
LD                    ?= ld
CONFIG                ?= $(OS)-$(ARCH)-$(PROFILE)
BUILD                 ?= build/$(CONFIG)
LBIN                  ?= $(BUILD)/bin
PATH                  := $(LBIN):$(PATH)

ME_COM_CGI            ?= 1
ME_COM_COMPILER       ?= 1
ME_COM_DIR            ?= 1
ME_COM_EJS            ?= 0
ME_COM_ESP            ?= 1
ME_COM_EST            ?= 0
ME_COM_HTTP           ?= 1
ME_COM_LIB            ?= 1
ME_COM_LINK           ?= 1
ME_COM_MDB            ?= 1
ME_COM_MPR            ?= 1
ME_COM_OPENSSL        ?= 1
ME_COM_OSDEP          ?= 1
ME_COM_PCRE           ?= 1
ME_COM_PHP            ?= 0
ME_COM_SQLITE         ?= 0
ME_COM_SSL            ?= 1
ME_COM_VXWORKS        ?= 1
ME_COM_WINSDK         ?= 1
ME_COM_ZLIB           ?= 0

ME_COM_OPENSSL_PATH   ?= "/usr"

ifeq ($(ME_COM_EST),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_LIB),1)
    ME_COM_COMPILER := 1
endif
ifeq ($(ME_COM_LINK),1)
    ME_COM_COMPILER := 1
endif
ifeq ($(ME_COM_OPENSSL),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_ESP),1)
    ME_COM_MDB := 1
endif

export WIND_HOME      ?= $(WIND_BASE)/..
export PATH           := $(WIND_GNU_PATH)/$(WIND_HOST_TYPE)/bin:$(PATH)

CFLAGS                += -fno-builtin -fno-defer-pop -fvolatile -w
DFLAGS                += -DVXWORKS -DRW_MULTI_THREAD -D_GNU_TOOL -DCPU=PENTIUM $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_CGI=$(ME_COM_CGI) -DME_COM_COMPILER=$(ME_COM_COMPILER) -DME_COM_DIR=$(ME_COM_DIR) -DME_COM_EJS=$(ME_COM_EJS) -DME_COM_ESP=$(ME_COM_ESP) -DME_COM_EST=$(ME_COM_EST) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_LIB=$(ME_COM_LIB) -DME_COM_LINK=$(ME_COM_LINK) -DME_COM_MDB=$(ME_COM_MDB) -DME_COM_MPR=$(ME_COM_MPR) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_OSDEP=$(ME_COM_OSDEP) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_PHP=$(ME_COM_PHP) -DME_COM_SQLITE=$(ME_COM_SQLITE) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_VXWORKS=$(ME_COM_VXWORKS) -DME_COM_WINSDK=$(ME_COM_WINSDK) -DME_COM_ZLIB=$(ME_COM_ZLIB) 
IFLAGS                += "-I$(BUILD)/inc -I$(WIND_BASE)/target/h -I$(WIND_BASE)/target/h/wrn/coreip"
LDFLAGS               += '-Wl,-r'
LIBPATHS              += -L$(BUILD)/bin
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

WEB_USER              ?= $(shell egrep 'www-data|_www|nobody' /etc/passwd | sed 's/:.*$$$(ME_ROOT_PREFIX)/' |  tail -1)
WEB_GROUP             ?= $(shell egrep 'www-data|_www|nobody|nogroup' /etc/group | sed 's/:.*$$$(ME_ROOT_PREFIX)/' |  tail -1)

TARGETS               += $(BUILD)/bin/appweb.out
TARGETS               += $(BUILD)/bin/authpass.out
ifeq ($(ME_COM_ESP),1)
    TARGETS           += $(BUILD)/bin/esp-compile.json
endif
ifeq ($(ME_COM_ESP),1)
    TARGETS           += $(BUILD)/bin/esp.out
endif
TARGETS               += $(BUILD)/bin/ca.crt
ifeq ($(ME_COM_HTTP),1)
    TARGETS           += $(BUILD)/bin/http.out
endif
ifeq ($(ME_COM_CGI),1)
    TARGETS           += $(BUILD)/bin/libmod_cgi.out
endif
ifeq ($(ME_COM_ESP),1)
    TARGETS           += $(BUILD)/bin/libmod_esp.out
endif
ifeq ($(ME_COM_SSL),1)
    TARGETS           += $(BUILD)/bin/libmod_ssl.out
endif
ifeq ($(ME_COM_SQLITE),1)
    TARGETS           += $(BUILD)/bin/libsql.out
endif
ifeq ($(ME_COM_ZLIB),1)
    TARGETS           += $(BUILD)/bin/libzlib.out
endif
TARGETS               += $(BUILD)/bin/appman.out
TARGETS               += src/server/cache

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
	@[ ! -f $(BUILD)/inc/me.h ] && cp projects/appweb-vxworks-default-me.h $(BUILD)/inc/me.h ; true
	@if ! diff $(BUILD)/inc/me.h projects/appweb-vxworks-default-me.h >/dev/null ; then\
		cp projects/appweb-vxworks-default-me.h $(BUILD)/inc/me.h  ; \
	fi; true
	@if [ -f "$(BUILD)/.makeflags" ] ; then \
		if [ "$(MAKEFLAGS)" != "`cat $(BUILD)/.makeflags`" ] ; then \
			echo "   [Warning] Make flags have changed since the last build: "`cat $(BUILD)/.makeflags`"" ; \
		fi ; \
	fi
	@echo "$(MAKEFLAGS)" >$(BUILD)/.makeflags

clean:
	rm -f "$(BUILD)/obj/appweb.o"
	rm -f "$(BUILD)/obj/authpass.o"
	rm -f "$(BUILD)/obj/cgiHandler.o"
	rm -f "$(BUILD)/obj/cgiProgram.o"
	rm -f "$(BUILD)/obj/config.o"
	rm -f "$(BUILD)/obj/convenience.o"
	rm -f "$(BUILD)/obj/esp.o"
	rm -f "$(BUILD)/obj/espHandler.o"
	rm -f "$(BUILD)/obj/espLib.o"
	rm -f "$(BUILD)/obj/http.o"
	rm -f "$(BUILD)/obj/httpLib.o"
	rm -f "$(BUILD)/obj/makerom.o"
	rm -f "$(BUILD)/obj/manager.o"
	rm -f "$(BUILD)/obj/mprLib.o"
	rm -f "$(BUILD)/obj/mprSsl.o"
	rm -f "$(BUILD)/obj/pcre.o"
	rm -f "$(BUILD)/obj/slink.o"
	rm -f "$(BUILD)/obj/sqlite.o"
	rm -f "$(BUILD)/obj/sqlite3.o"
	rm -f "$(BUILD)/obj/sslModule.o"
	rm -f "$(BUILD)/obj/zlib.o"
	rm -f "$(BUILD)/bin/appweb.out"
	rm -f "$(BUILD)/bin/authpass.out"
	rm -f "$(BUILD)/bin/esp-compile.json"
	rm -f "$(BUILD)/bin/esp.out"
	rm -f "$(BUILD)/bin/ca.crt"
	rm -f "$(BUILD)/bin/http.out"
	rm -f "$(BUILD)/bin/libappweb.out"
	rm -f "$(BUILD)/bin/libesp.out"
	rm -f "$(BUILD)/bin/libhttp.out"
	rm -f "$(BUILD)/bin/libmod_cgi.out"
	rm -f "$(BUILD)/bin/libmod_esp.out"
	rm -f "$(BUILD)/bin/libmod_ssl.out"
	rm -f "$(BUILD)/bin/libmpr.out"
	rm -f "$(BUILD)/bin/libmprssl.out"
	rm -f "$(BUILD)/bin/libpcre.out"
	rm -f "$(BUILD)/bin/libslink.out"
	rm -f "$(BUILD)/bin/libsql.out"
	rm -f "$(BUILD)/bin/libzlib.out"
	rm -f "$(BUILD)/bin/appman.out"

clobber: clean
	rm -fr ./$(BUILD)

#
#   me.h
#

$(BUILD)/inc/me.h: $(DEPS_1)

#
#   osdep.h
#
DEPS_2 += paks/osdep/dist/osdep.h
DEPS_2 += $(BUILD)/inc/me.h

$(BUILD)/inc/osdep.h: $(DEPS_2)
	@echo '      [Copy] $(BUILD)/inc/osdep.h'
	mkdir -p "$(BUILD)/inc"
	cp paks/osdep/dist/osdep.h $(BUILD)/inc/osdep.h

#
#   mpr.h
#
DEPS_3 += paks/mpr/dist/mpr.h
DEPS_3 += $(BUILD)/inc/me.h
DEPS_3 += $(BUILD)/inc/osdep.h

$(BUILD)/inc/mpr.h: $(DEPS_3)
	@echo '      [Copy] $(BUILD)/inc/mpr.h'
	mkdir -p "$(BUILD)/inc"
	cp paks/mpr/dist/mpr.h $(BUILD)/inc/mpr.h

#
#   http.h
#
DEPS_4 += paks/http/dist/http.h
DEPS_4 += $(BUILD)/inc/mpr.h

$(BUILD)/inc/http.h: $(DEPS_4)
	@echo '      [Copy] $(BUILD)/inc/http.h'
	mkdir -p "$(BUILD)/inc"
	cp paks/http/dist/http.h $(BUILD)/inc/http.h

#
#   customize.h
#

src/customize.h: $(DEPS_5)

#
#   appweb.h
#
DEPS_6 += src/appweb.h
DEPS_6 += $(BUILD)/inc/osdep.h
DEPS_6 += $(BUILD)/inc/mpr.h
DEPS_6 += $(BUILD)/inc/http.h
DEPS_6 += src/customize.h

$(BUILD)/inc/appweb.h: $(DEPS_6)
	@echo '      [Copy] $(BUILD)/inc/appweb.h'
	mkdir -p "$(BUILD)/inc"
	cp src/appweb.h $(BUILD)/inc/appweb.h

#
#   customize.h
#
DEPS_7 += src/customize.h

$(BUILD)/inc/customize.h: $(DEPS_7)
	@echo '      [Copy] $(BUILD)/inc/customize.h'
	mkdir -p "$(BUILD)/inc"
	cp src/customize.h $(BUILD)/inc/customize.h

#
#   esp.h
#
DEPS_8 += paks/esp/dist/esp.h
DEPS_8 += $(BUILD)/inc/me.h
DEPS_8 += $(BUILD)/inc/osdep.h
DEPS_8 += $(BUILD)/inc/http.h

$(BUILD)/inc/esp.h: $(DEPS_8)
	@echo '      [Copy] $(BUILD)/inc/esp.h'
	mkdir -p "$(BUILD)/inc"
	cp paks/esp/dist/esp.h $(BUILD)/inc/esp.h

#
#   pcre.h
#
DEPS_9 += paks/pcre/dist/pcre.h

$(BUILD)/inc/pcre.h: $(DEPS_9)
	@echo '      [Copy] $(BUILD)/inc/pcre.h'
	mkdir -p "$(BUILD)/inc"
	cp paks/pcre/dist/pcre.h $(BUILD)/inc/pcre.h

#
#   sqlite3.h
#
DEPS_10 += paks/sqlite/dist/sqlite3.h

$(BUILD)/inc/sqlite3.h: $(DEPS_10)
	@echo '      [Copy] $(BUILD)/inc/sqlite3.h'
	mkdir -p "$(BUILD)/inc"
	cp paks/sqlite/dist/sqlite3.h $(BUILD)/inc/sqlite3.h

#
#   zlib.h
#
DEPS_11 += paks/zlib/dist/zlib.h

$(BUILD)/inc/zlib.h: $(DEPS_11)
	@echo '      [Copy] $(BUILD)/inc/zlib.h'
	mkdir -p "$(BUILD)/inc"
	cp paks/zlib/dist/zlib.h $(BUILD)/inc/zlib.h

#
#   appweb.o
#
DEPS_12 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/appweb.o: \
    src/server/appweb.c $(DEPS_12)
	@echo '   [Compile] $(BUILD)/obj/appweb.o'
	$(CC) -c -o $(BUILD)/obj/appweb.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/server/appweb.c

#
#   authpass.o
#
DEPS_13 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/authpass.o: \
    src/utils/authpass.c $(DEPS_13)
	@echo '   [Compile] $(BUILD)/obj/authpass.o'
	$(CC) -c -o $(BUILD)/obj/authpass.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/utils/authpass.c

#
#   cgiHandler.o
#
DEPS_14 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/cgiHandler.o: \
    src/modules/cgiHandler.c $(DEPS_14)
	@echo '   [Compile] $(BUILD)/obj/cgiHandler.o'
	$(CC) -c -o $(BUILD)/obj/cgiHandler.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/modules/cgiHandler.c

#
#   cgiProgram.o
#

$(BUILD)/obj/cgiProgram.o: \
    src/utils/cgiProgram.c $(DEPS_15)
	@echo '   [Compile] $(BUILD)/obj/cgiProgram.o'
	$(CC) -c -o $(BUILD)/obj/cgiProgram.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/utils/cgiProgram.c

#
#   appweb.h
#

src/appweb.h: $(DEPS_16)

#
#   config.o
#
DEPS_17 += src/appweb.h
DEPS_17 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/config.o: \
    src/config.c $(DEPS_17)
	@echo '   [Compile] $(BUILD)/obj/config.o'
	$(CC) -c -o $(BUILD)/obj/config.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/config.c

#
#   convenience.o
#
DEPS_18 += src/appweb.h

$(BUILD)/obj/convenience.o: \
    src/convenience.c $(DEPS_18)
	@echo '   [Compile] $(BUILD)/obj/convenience.o'
	$(CC) -c -o $(BUILD)/obj/convenience.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/convenience.c

#
#   esp.h
#

paks/esp/dist/esp.h: $(DEPS_19)

#
#   esp.o
#
DEPS_20 += paks/esp/dist/esp.h

$(BUILD)/obj/esp.o: \
    paks/esp/dist/esp.c $(DEPS_20)
	@echo '   [Compile] $(BUILD)/obj/esp.o'
	$(CC) -c -o $(BUILD)/obj/esp.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" paks/esp/dist/esp.c

#
#   espHandler.o
#
DEPS_21 += $(BUILD)/inc/appweb.h
DEPS_21 += $(BUILD)/inc/esp.h

$(BUILD)/obj/espHandler.o: \
    src/modules/espHandler.c $(DEPS_21)
	@echo '   [Compile] $(BUILD)/obj/espHandler.o'
	$(CC) -c -o $(BUILD)/obj/espHandler.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/modules/espHandler.c

#
#   espLib.o
#
DEPS_22 += paks/esp/dist/esp.h
DEPS_22 += $(BUILD)/inc/pcre.h
DEPS_22 += $(BUILD)/inc/http.h

$(BUILD)/obj/espLib.o: \
    paks/esp/dist/espLib.c $(DEPS_22)
	@echo '   [Compile] $(BUILD)/obj/espLib.o'
	$(CC) -c -o $(BUILD)/obj/espLib.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" paks/esp/dist/espLib.c

#
#   http.h
#

paks/http/dist/http.h: $(DEPS_23)

#
#   http.o
#
DEPS_24 += paks/http/dist/http.h

$(BUILD)/obj/http.o: \
    paks/http/dist/http.c $(DEPS_24)
	@echo '   [Compile] $(BUILD)/obj/http.o'
	$(CC) -c -o $(BUILD)/obj/http.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" paks/http/dist/http.c

#
#   httpLib.o
#
DEPS_25 += paks/http/dist/http.h

$(BUILD)/obj/httpLib.o: \
    paks/http/dist/httpLib.c $(DEPS_25)
	@echo '   [Compile] $(BUILD)/obj/httpLib.o'
	$(CC) -c -o $(BUILD)/obj/httpLib.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" paks/http/dist/httpLib.c

#
#   mpr.h
#

paks/mpr/dist/mpr.h: $(DEPS_26)

#
#   makerom.o
#
DEPS_27 += paks/mpr/dist/mpr.h

$(BUILD)/obj/makerom.o: \
    paks/mpr/dist/makerom.c $(DEPS_27)
	@echo '   [Compile] $(BUILD)/obj/makerom.o'
	$(CC) -c -o $(BUILD)/obj/makerom.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" paks/mpr/dist/makerom.c

#
#   manager.o
#
DEPS_28 += paks/mpr/dist/mpr.h

$(BUILD)/obj/manager.o: \
    paks/mpr/dist/manager.c $(DEPS_28)
	@echo '   [Compile] $(BUILD)/obj/manager.o'
	$(CC) -c -o $(BUILD)/obj/manager.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" paks/mpr/dist/manager.c

#
#   mprLib.o
#
DEPS_29 += paks/mpr/dist/mpr.h

$(BUILD)/obj/mprLib.o: \
    paks/mpr/dist/mprLib.c $(DEPS_29)
	@echo '   [Compile] $(BUILD)/obj/mprLib.o'
	$(CC) -c -o $(BUILD)/obj/mprLib.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" paks/mpr/dist/mprLib.c

#
#   mprSsl.o
#
DEPS_30 += paks/mpr/dist/mpr.h

$(BUILD)/obj/mprSsl.o: \
    paks/mpr/dist/mprSsl.c $(DEPS_30)
	@echo '   [Compile] $(BUILD)/obj/mprSsl.o'
	$(CC) -c -o $(BUILD)/obj/mprSsl.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" paks/mpr/dist/mprSsl.c

#
#   pcre.h
#

paks/pcre/dist/pcre.h: $(DEPS_31)

#
#   pcre.o
#
DEPS_32 += $(BUILD)/inc/me.h
DEPS_32 += paks/pcre/dist/pcre.h

$(BUILD)/obj/pcre.o: \
    paks/pcre/dist/pcre.c $(DEPS_32)
	@echo '   [Compile] $(BUILD)/obj/pcre.o'
	$(CC) -c -o $(BUILD)/obj/pcre.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" paks/pcre/dist/pcre.c

#
#   slink.o
#
DEPS_33 += $(BUILD)/inc/mpr.h
DEPS_33 += $(BUILD)/inc/esp.h

$(BUILD)/obj/slink.o: \
    src/server/slink.c $(DEPS_33)
	@echo '   [Compile] $(BUILD)/obj/slink.o'
	$(CC) -c -o $(BUILD)/obj/slink.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/server/slink.c

#
#   sqlite3.h
#

paks/sqlite/dist/sqlite3.h: $(DEPS_34)

#
#   sqlite.o
#
DEPS_35 += $(BUILD)/inc/me.h
DEPS_35 += paks/sqlite/dist/sqlite3.h

$(BUILD)/obj/sqlite.o: \
    paks/sqlite/dist/sqlite.c $(DEPS_35)
	@echo '   [Compile] $(BUILD)/obj/sqlite.o'
	$(CC) -c -o $(BUILD)/obj/sqlite.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" paks/sqlite/dist/sqlite.c

#
#   sqlite3.o
#
DEPS_36 += $(BUILD)/inc/me.h
DEPS_36 += paks/sqlite/dist/sqlite3.h

$(BUILD)/obj/sqlite3.o: \
    paks/sqlite/dist/sqlite3.c $(DEPS_36)
	@echo '   [Compile] $(BUILD)/obj/sqlite3.o'
	$(CC) -c -o $(BUILD)/obj/sqlite3.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" paks/sqlite/dist/sqlite3.c

#
#   sslModule.o
#
DEPS_37 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/sslModule.o: \
    src/modules/sslModule.c $(DEPS_37)
	@echo '   [Compile] $(BUILD)/obj/sslModule.o'
	$(CC) -c -o $(BUILD)/obj/sslModule.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/modules/sslModule.c

#
#   zlib.h
#

paks/zlib/dist/zlib.h: $(DEPS_38)

#
#   zlib.o
#
DEPS_39 += $(BUILD)/inc/me.h
DEPS_39 += paks/zlib/dist/zlib.h

$(BUILD)/obj/zlib.o: \
    paks/zlib/dist/zlib.c $(DEPS_39)
	@echo '   [Compile] $(BUILD)/obj/zlib.o'
	$(CC) -c -o $(BUILD)/obj/zlib.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" paks/zlib/dist/zlib.c

#
#   libmpr
#
DEPS_40 += $(BUILD)/inc/osdep.h
DEPS_40 += $(BUILD)/inc/mpr.h
DEPS_40 += $(BUILD)/obj/mprLib.o

$(BUILD)/bin/libmpr.out: $(DEPS_40)
	@echo '      [Link] $(BUILD)/bin/libmpr.out'
	$(CC) -r -o $(BUILD)/bin/libmpr.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/mprLib.o" $(LIBS) 

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_41 += $(BUILD)/inc/pcre.h
DEPS_41 += $(BUILD)/obj/pcre.o

$(BUILD)/bin/libpcre.out: $(DEPS_41)
	@echo '      [Link] $(BUILD)/bin/libpcre.out'
	$(CC) -r -o $(BUILD)/bin/libpcre.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/pcre.o" $(LIBS) 
endif

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_42 += $(BUILD)/bin/libmpr.out
ifeq ($(ME_COM_PCRE),1)
    DEPS_42 += $(BUILD)/bin/libpcre.out
endif
DEPS_42 += $(BUILD)/inc/http.h
DEPS_42 += $(BUILD)/obj/httpLib.o

$(BUILD)/bin/libhttp.out: $(DEPS_42)
	@echo '      [Link] $(BUILD)/bin/libhttp.out'
	$(CC) -r -o $(BUILD)/bin/libhttp.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/httpLib.o" $(LIBS) 
endif

#
#   libappweb
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_43 += $(BUILD)/bin/libhttp.out
endif
DEPS_43 += $(BUILD)/bin/libmpr.out
DEPS_43 += $(BUILD)/inc/appweb.h
DEPS_43 += $(BUILD)/inc/customize.h
DEPS_43 += $(BUILD)/obj/config.o
DEPS_43 += $(BUILD)/obj/convenience.o

$(BUILD)/bin/libappweb.out: $(DEPS_43)
	@echo '      [Link] $(BUILD)/bin/libappweb.out'
	$(CC) -r -o $(BUILD)/bin/libappweb.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/config.o" "$(BUILD)/obj/convenience.o" $(LIBS) 

#
#   libslink
#
DEPS_44 += $(BUILD)/obj/slink.o

$(BUILD)/bin/libslink.out: $(DEPS_44)
	@echo '      [Link] $(BUILD)/bin/libslink.out'
	$(CC) -r -o $(BUILD)/bin/libslink.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/slink.o" $(LIBS) 

#
#   appweb
#
DEPS_45 += $(BUILD)/bin/libappweb.out
DEPS_45 += $(BUILD)/bin/libslink.out
DEPS_45 += $(BUILD)/obj/appweb.o

$(BUILD)/bin/appweb.out: $(DEPS_45)
	@echo '      [Link] $(BUILD)/bin/appweb.out'
	$(CC) -o $(BUILD)/bin/appweb.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/appweb.o" $(LIBS) -Wl,-r 

#
#   authpass
#
DEPS_46 += $(BUILD)/bin/libappweb.out
DEPS_46 += $(BUILD)/obj/authpass.o

$(BUILD)/bin/authpass.out: $(DEPS_46)
	@echo '      [Link] $(BUILD)/bin/authpass.out'
	$(CC) -o $(BUILD)/bin/authpass.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/authpass.o" $(LIBS) -Wl,-r 

ifeq ($(ME_COM_ESP),1)
#
#   esp-compile.json
#
DEPS_47 += paks/esp/dist/esp-compile.json

$(BUILD)/bin/esp-compile.json: $(DEPS_47)
	@echo '      [Copy] $(BUILD)/bin/esp-compile.json'
	mkdir -p "$(BUILD)/bin"
	cp paks/esp/dist/esp-compile.json $(BUILD)/bin/esp-compile.json
endif

ifeq ($(ME_COM_ESP),1)
#
#   libesp
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_48 += $(BUILD)/bin/libhttp.out
endif
DEPS_48 += $(BUILD)/inc/esp.h
DEPS_48 += $(BUILD)/obj/espLib.o

$(BUILD)/bin/libesp.out: $(DEPS_48)
	@echo '      [Link] $(BUILD)/bin/libesp.out'
	$(CC) -r -o $(BUILD)/bin/libesp.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/espLib.o" $(LIBS) 
endif

ifeq ($(ME_COM_ESP),1)
#
#   espcmd
#
DEPS_49 += $(BUILD)/bin/libesp.out
DEPS_49 += $(BUILD)/obj/esp.o

$(BUILD)/bin/esp.out: $(DEPS_49)
	@echo '      [Link] $(BUILD)/bin/esp.out'
	$(CC) -o $(BUILD)/bin/esp.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/esp.o" $(LIBS) -Wl,-r 
endif

ifeq ($(ME_COM_ESP),1)
#
#   genslink
#
DEPS_50 += $(BUILD)/bin/libesp.out

genslink: $(DEPS_50)
	( \
	cd src/server; \
	echo '    [Create] slink.c' ; \
	esp --static --genlink slink.c compile ; \
	)
endif

#
#   http-ca-crt
#
DEPS_51 += paks/http/dist/ca.crt

$(BUILD)/bin/ca.crt: $(DEPS_51)
	@echo '      [Copy] $(BUILD)/bin/ca.crt'
	mkdir -p "$(BUILD)/bin"
	cp paks/http/dist/ca.crt $(BUILD)/bin/ca.crt

ifeq ($(ME_COM_HTTP),1)
#
#   httpcmd
#
DEPS_52 += $(BUILD)/bin/libhttp.out
DEPS_52 += $(BUILD)/obj/http.o

$(BUILD)/bin/http.out: $(DEPS_52)
	@echo '      [Link] $(BUILD)/bin/http.out'
	$(CC) -o $(BUILD)/bin/http.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/http.o" $(LIBS) -Wl,-r 
endif

ifeq ($(ME_COM_CGI),1)
#
#   libmod_cgi
#
DEPS_53 += $(BUILD)/bin/libappweb.out
DEPS_53 += $(BUILD)/obj/cgiHandler.o

$(BUILD)/bin/libmod_cgi.out: $(DEPS_53)
	@echo '      [Link] $(BUILD)/bin/libmod_cgi.out'
	$(CC) -r -o $(BUILD)/bin/libmod_cgi.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/cgiHandler.o" $(LIBS) 
endif

ifeq ($(ME_COM_ESP),1)
#
#   libmod_esp
#
DEPS_54 += $(BUILD)/bin/libappweb.out
DEPS_54 += $(BUILD)/bin/libesp.out
DEPS_54 += $(BUILD)/obj/espHandler.o

$(BUILD)/bin/libmod_esp.out: $(DEPS_54)
	@echo '      [Link] $(BUILD)/bin/libmod_esp.out'
	$(CC) -r -o $(BUILD)/bin/libmod_esp.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/espHandler.o" $(LIBS) 
endif

#
#   libmprssl
#
DEPS_55 += $(BUILD)/bin/libmpr.out
DEPS_55 += $(BUILD)/obj/mprSsl.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_55 += -lssl
    LIBPATHS_55 += -L"$(ME_COM_OPENSSL_PATH)/lib"
    LIBPATHS_55 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_55 += -lcrypto
    LIBPATHS_55 += -L"$(ME_COM_OPENSSL_PATH)/lib"
    LIBPATHS_55 += -L"$(ME_COM_OPENSSL_PATH)"
endif

$(BUILD)/bin/libmprssl.out: $(DEPS_55)
	@echo '      [Link] $(BUILD)/bin/libmprssl.out'
	$(CC) -r -o $(BUILD)/bin/libmprssl.out $(LDFLAGS) $(LIBPATHS)   "$(BUILD)/obj/mprSsl.o" $(LIBPATHS_55) $(LIBS_55) $(LIBS_55) $(LIBS) 

ifeq ($(ME_COM_SSL),1)
#
#   libmod_ssl
#
DEPS_56 += $(BUILD)/bin/libappweb.out
DEPS_56 += $(BUILD)/bin/libmprssl.out
DEPS_56 += $(BUILD)/obj/sslModule.o

ifeq ($(ME_COM_OPENSSL),1)
    LIBS_56 += -lssl
    LIBPATHS_56 += -L"$(ME_COM_OPENSSL_PATH)/lib"
    LIBPATHS_56 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_56 += -lcrypto
    LIBPATHS_56 += -L"$(ME_COM_OPENSSL_PATH)/lib"
    LIBPATHS_56 += -L"$(ME_COM_OPENSSL_PATH)"
endif

$(BUILD)/bin/libmod_ssl.out: $(DEPS_56)
	@echo '      [Link] $(BUILD)/bin/libmod_ssl.out'
	$(CC) -r -o $(BUILD)/bin/libmod_ssl.out $(LDFLAGS) $(LIBPATHS)   "$(BUILD)/obj/sslModule.o" $(LIBPATHS_56) $(LIBS_56) $(LIBS_56) $(LIBS) 
endif

ifeq ($(ME_COM_SQLITE),1)
#
#   libsql
#
DEPS_57 += $(BUILD)/inc/sqlite3.h
DEPS_57 += $(BUILD)/obj/sqlite3.o

$(BUILD)/bin/libsql.out: $(DEPS_57)
	@echo '      [Link] $(BUILD)/bin/libsql.out'
	$(CC) -r -o $(BUILD)/bin/libsql.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/sqlite3.o" $(LIBS) 
endif

ifeq ($(ME_COM_ZLIB),1)
#
#   libzlib
#
DEPS_58 += $(BUILD)/inc/zlib.h
DEPS_58 += $(BUILD)/obj/zlib.o

$(BUILD)/bin/libzlib.out: $(DEPS_58)
	@echo '      [Link] $(BUILD)/bin/libzlib.out'
	$(CC) -r -o $(BUILD)/bin/libzlib.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/zlib.o" $(LIBS) 
endif

#
#   manager
#
DEPS_59 += $(BUILD)/bin/libmpr.out
DEPS_59 += $(BUILD)/obj/manager.o

$(BUILD)/bin/appman.out: $(DEPS_59)
	@echo '      [Link] $(BUILD)/bin/appman.out'
	$(CC) -o $(BUILD)/bin/appman.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/manager.o" $(LIBS) -Wl,-r 

#
#   server-cache
#

src/server/cache: $(DEPS_60)
	( \
	cd src/server; \
	mkdir -p "cache" ; \
	)

#
#   installBinary
#

installBinary: $(DEPS_61)

#
#   install
#
DEPS_62 += installBinary

install: $(DEPS_62)

#
#   installPrep
#

installPrep: $(DEPS_63)
	if [ "`id -u`" != 0 ] ; \
	then echo "Must run as root. Rerun with "sudo"" ; \
	exit 255 ; \
	fi


#
#   run
#

run: $(DEPS_64)
	( \
	cd src/server; \
	../../$(BUILD)/bin/appweb --log stdout:2 ; \
	)


#
#   uninstall
#

uninstall: $(DEPS_65)
	( \
	cd installs; \
	rm -f "$(ME_VAPP_PREFIX)/appweb.conf" ; \
	rm -f "$(ME_VAPP_PREFIX)/esp.conf" ; \
	rm -f "$(ME_VAPP_PREFIX)/mine.types" ; \
	rm -f "$(ME_VAPP_PREFIX)/install.conf" ; \
	rm -fr "$(ME_VAPP_PREFIX)/inc/appweb" ; \
	)

#
#   version
#

version: $(DEPS_66)
	echo 5.4.0

