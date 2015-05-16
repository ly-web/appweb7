#
#   appweb-vxworks-static.mk -- Makefile to build Embedthis Appweb for vxworks
#

NAME                  := appweb
VERSION               := 5.4.1
PROFILE               ?= static
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
ME_COM_MATRIXSSL      ?= 0
ME_COM_MDB            ?= 1
ME_COM_MPR            ?= 1
ME_COM_NANOSSL        ?= 0
ME_COM_OPENSSL        ?= 1
ME_COM_OSDEP          ?= 1
ME_COM_PCRE           ?= 1
ME_COM_PHP            ?= 0
ME_COM_SQLITE         ?= 0
ME_COM_SSL            ?= 1
ME_COM_VXWORKS        ?= 1
ME_COM_WINSDK         ?= 1
ME_COM_ZLIB           ?= 0

ME_COM_OPENSSL_PATH   ?= "/usr/lib"

ifeq ($(ME_COM_EST),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_LIB),1)
    ME_COM_COMPILER := 1
endif
ifeq ($(ME_COM_LINK),1)
    ME_COM_COMPILER := 1
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    ME_COM_SSL := 1
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
DFLAGS                += -DVXWORKS -DRW_MULTI_THREAD -D_GNU_TOOL -DCPU=PENTIUM $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_CGI=$(ME_COM_CGI) -DME_COM_COMPILER=$(ME_COM_COMPILER) -DME_COM_DIR=$(ME_COM_DIR) -DME_COM_EJS=$(ME_COM_EJS) -DME_COM_ESP=$(ME_COM_ESP) -DME_COM_EST=$(ME_COM_EST) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_LIB=$(ME_COM_LIB) -DME_COM_LINK=$(ME_COM_LINK) -DME_COM_MATRIXSSL=$(ME_COM_MATRIXSSL) -DME_COM_MDB=$(ME_COM_MDB) -DME_COM_MPR=$(ME_COM_MPR) -DME_COM_NANOSSL=$(ME_COM_NANOSSL) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_OSDEP=$(ME_COM_OSDEP) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_PHP=$(ME_COM_PHP) -DME_COM_SQLITE=$(ME_COM_SQLITE) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_VXWORKS=$(ME_COM_VXWORKS) -DME_COM_WINSDK=$(ME_COM_WINSDK) -DME_COM_ZLIB=$(ME_COM_ZLIB) 
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
ifeq ($(ME_COM_SQLITE),1)
    TARGETS           += $(BUILD)/bin/libsql.a
endif
ifeq ($(ME_COM_ZLIB),1)
    TARGETS           += $(BUILD)/bin/libzlib.a
endif
TARGETS               += src/server/cache
TARGETS               += $(BUILD)/bin/appman.out

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
	rm -f "$(BUILD)/obj/mprLib.o"
	rm -f "$(BUILD)/obj/openssl.o"
	rm -f "$(BUILD)/obj/pcre.o"
	rm -f "$(BUILD)/obj/romFiles.o"
	rm -f "$(BUILD)/obj/sqlite.o"
	rm -f "$(BUILD)/obj/sqlite3.o"
	rm -f "$(BUILD)/obj/watchdog.o"
	rm -f "$(BUILD)/obj/zlib.o"
	rm -f "$(BUILD)/bin/appweb.out"
	rm -f "$(BUILD)/bin/authpass.out"
	rm -f "$(BUILD)/bin/esp-compile.json"
	rm -f "$(BUILD)/bin/esp.out"
	rm -f "$(BUILD)/bin/ca.crt"
	rm -f "$(BUILD)/bin/http.out"
	rm -f "$(BUILD)/bin/libappweb.a"
	rm -f "$(BUILD)/bin/libesp.a"
	rm -f "$(BUILD)/bin/libhttp.a"
	rm -f "$(BUILD)/bin/libmpr.a"
	rm -f "$(BUILD)/bin/libpcre.a"
	rm -f "$(BUILD)/bin/libsql.a"
	rm -f "$(BUILD)/bin/libzlib.a"
	rm -f "$(BUILD)/bin/libopenssl.a"
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
DEPS_2 += src/osdep/osdep.h
DEPS_2 += $(BUILD)/inc/me.h

$(BUILD)/inc/osdep.h: $(DEPS_2)
	@echo '      [Copy] $(BUILD)/inc/osdep.h'
	mkdir -p "$(BUILD)/inc"
	cp src/osdep/osdep.h $(BUILD)/inc/osdep.h

#
#   mpr.h
#
DEPS_3 += src/mpr/mpr.h
DEPS_3 += $(BUILD)/inc/me.h
DEPS_3 += $(BUILD)/inc/osdep.h

$(BUILD)/inc/mpr.h: $(DEPS_3)
	@echo '      [Copy] $(BUILD)/inc/mpr.h'
	mkdir -p "$(BUILD)/inc"
	cp src/mpr/mpr.h $(BUILD)/inc/mpr.h

#
#   http.h
#
DEPS_4 += src/http/http.h
DEPS_4 += $(BUILD)/inc/mpr.h

$(BUILD)/inc/http.h: $(DEPS_4)
	@echo '      [Copy] $(BUILD)/inc/http.h'
	mkdir -p "$(BUILD)/inc"
	cp src/http/http.h $(BUILD)/inc/http.h

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
DEPS_8 += src/esp/esp.h
DEPS_8 += $(BUILD)/inc/me.h
DEPS_8 += $(BUILD)/inc/osdep.h
DEPS_8 += $(BUILD)/inc/http.h

$(BUILD)/inc/esp.h: $(DEPS_8)
	@echo '      [Copy] $(BUILD)/inc/esp.h'
	mkdir -p "$(BUILD)/inc"
	cp src/esp/esp.h $(BUILD)/inc/esp.h

#
#   pcre.h
#
DEPS_9 += src/pcre/pcre.h

$(BUILD)/inc/pcre.h: $(DEPS_9)
	@echo '      [Copy] $(BUILD)/inc/pcre.h'
	mkdir -p "$(BUILD)/inc"
	cp src/pcre/pcre.h $(BUILD)/inc/pcre.h

#
#   sqlite3.h
#
DEPS_10 += src/sqlite/sqlite3.h

$(BUILD)/inc/sqlite3.h: $(DEPS_10)
	@echo '      [Copy] $(BUILD)/inc/sqlite3.h'
	mkdir -p "$(BUILD)/inc"
	cp src/sqlite/sqlite3.h $(BUILD)/inc/sqlite3.h

#
#   zlib.h
#
DEPS_11 += src/zlib/zlib.h

$(BUILD)/inc/zlib.h: $(DEPS_11)
	@echo '      [Copy] $(BUILD)/inc/zlib.h'
	mkdir -p "$(BUILD)/inc"
	cp src/zlib/zlib.h $(BUILD)/inc/zlib.h

#
#   appweb.o
#
DEPS_12 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/appweb.o: \
    src/server/appweb.c $(DEPS_12)
	@echo '   [Compile] $(BUILD)/obj/appweb.o'
	$(CC) -c -o $(BUILD)/obj/appweb.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/server/appweb.c

#
#   authpass.o
#
DEPS_13 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/authpass.o: \
    src/utils/authpass.c $(DEPS_13)
	@echo '   [Compile] $(BUILD)/obj/authpass.o'
	$(CC) -c -o $(BUILD)/obj/authpass.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/utils/authpass.c

#
#   appweb.h
#

src/appweb.h: $(DEPS_14)

#
#   cgiHandler.o
#
DEPS_15 += src/appweb.h

$(BUILD)/obj/cgiHandler.o: \
    src/modules/cgiHandler.c $(DEPS_15)
	@echo '   [Compile] $(BUILD)/obj/cgiHandler.o'
	$(CC) -c -o $(BUILD)/obj/cgiHandler.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/modules/cgiHandler.c

#
#   cgiProgram.o
#

$(BUILD)/obj/cgiProgram.o: \
    test/cgiProgram.c $(DEPS_16)
	@echo '   [Compile] $(BUILD)/obj/cgiProgram.o'
	$(CC) -c -o $(BUILD)/obj/cgiProgram.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" test/cgiProgram.c

#
#   config.o
#
DEPS_17 += src/appweb.h
DEPS_17 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/config.o: \
    src/config.c $(DEPS_17)
	@echo '   [Compile] $(BUILD)/obj/config.o'
	$(CC) -c -o $(BUILD)/obj/config.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/config.c

#
#   convenience.o
#
DEPS_18 += src/appweb.h

$(BUILD)/obj/convenience.o: \
    src/convenience.c $(DEPS_18)
	@echo '   [Compile] $(BUILD)/obj/convenience.o'
	$(CC) -c -o $(BUILD)/obj/convenience.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/convenience.c

#
#   esp.h
#

src/esp/esp.h: $(DEPS_19)

#
#   esp.o
#
DEPS_20 += src/esp/esp.h

$(BUILD)/obj/esp.o: \
    src/esp/esp.c $(DEPS_20)
	@echo '   [Compile] $(BUILD)/obj/esp.o'
	$(CC) -c -o $(BUILD)/obj/esp.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/esp/esp.c

#
#   espHandler.o
#
DEPS_21 += src/appweb.h
DEPS_21 += $(BUILD)/inc/esp.h

$(BUILD)/obj/espHandler.o: \
    src/modules/espHandler.c $(DEPS_21)
	@echo '   [Compile] $(BUILD)/obj/espHandler.o'
	$(CC) -c -o $(BUILD)/obj/espHandler.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/modules/espHandler.c

#
#   espLib.o
#
DEPS_22 += src/esp/esp.h
DEPS_22 += $(BUILD)/inc/pcre.h
DEPS_22 += $(BUILD)/inc/http.h

$(BUILD)/obj/espLib.o: \
    src/esp/espLib.c $(DEPS_22)
	@echo '   [Compile] $(BUILD)/obj/espLib.o'
	$(CC) -c -o $(BUILD)/obj/espLib.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/esp/espLib.c

#
#   http.h
#

src/http/http.h: $(DEPS_23)

#
#   http.o
#
DEPS_24 += src/http/http.h

$(BUILD)/obj/http.o: \
    src/http/http.c $(DEPS_24)
	@echo '   [Compile] $(BUILD)/obj/http.o'
	$(CC) -c -o $(BUILD)/obj/http.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/http/http.c

#
#   httpLib.o
#
DEPS_25 += src/http/http.h
DEPS_25 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/httpLib.o: \
    src/http/httpLib.c $(DEPS_25)
	@echo '   [Compile] $(BUILD)/obj/httpLib.o'
	$(CC) -c -o $(BUILD)/obj/httpLib.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/http/httpLib.c

#
#   mpr.h
#

src/mpr/mpr.h: $(DEPS_26)

#
#   mprLib.o
#
DEPS_27 += src/mpr/mpr.h

$(BUILD)/obj/mprLib.o: \
    src/mpr/mprLib.c $(DEPS_27)
	@echo '   [Compile] $(BUILD)/obj/mprLib.o'
	$(CC) -c -o $(BUILD)/obj/mprLib.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/mpr/mprLib.c

#
#   openssl.o
#
DEPS_28 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/openssl.o: \
    src/mpr-openssl/openssl.c $(DEPS_28)
	@echo '   [Compile] $(BUILD)/obj/openssl.o'
	$(CC) -c -o $(BUILD)/obj/openssl.o $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(ME_COM_OPENSSL_PATH)/include" src/mpr-openssl/openssl.c

#
#   pcre.h
#

src/pcre/pcre.h: $(DEPS_29)

#
#   pcre.o
#
DEPS_30 += $(BUILD)/inc/me.h
DEPS_30 += src/pcre/pcre.h

$(BUILD)/obj/pcre.o: \
    src/pcre/pcre.c $(DEPS_30)
	@echo '   [Compile] $(BUILD)/obj/pcre.o'
	$(CC) -c -o $(BUILD)/obj/pcre.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/pcre/pcre.c

#
#   romFiles.o
#
DEPS_31 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/romFiles.o: \
    src/romFiles.c $(DEPS_31)
	@echo '   [Compile] $(BUILD)/obj/romFiles.o'
	$(CC) -c -o $(BUILD)/obj/romFiles.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/romFiles.c

#
#   sqlite3.h
#

src/sqlite/sqlite3.h: $(DEPS_32)

#
#   sqlite.o
#
DEPS_33 += $(BUILD)/inc/me.h
DEPS_33 += src/sqlite/sqlite3.h

$(BUILD)/obj/sqlite.o: \
    src/sqlite/sqlite.c $(DEPS_33)
	@echo '   [Compile] $(BUILD)/obj/sqlite.o'
	$(CC) -c -o $(BUILD)/obj/sqlite.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/sqlite/sqlite.c

#
#   sqlite3.o
#
DEPS_34 += $(BUILD)/inc/me.h
DEPS_34 += src/sqlite/sqlite3.h

$(BUILD)/obj/sqlite3.o: \
    src/sqlite/sqlite3.c $(DEPS_34)
	@echo '   [Compile] $(BUILD)/obj/sqlite3.o'
	$(CC) -c -o $(BUILD)/obj/sqlite3.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/sqlite/sqlite3.c

#
#   watchdog.o
#
DEPS_35 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/watchdog.o: \
    src/watchdog/watchdog.c $(DEPS_35)
	@echo '   [Compile] $(BUILD)/obj/watchdog.o'
	$(CC) -c -o $(BUILD)/obj/watchdog.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/watchdog/watchdog.c

#
#   zlib.h
#

src/zlib/zlib.h: $(DEPS_36)

#
#   zlib.o
#
DEPS_37 += $(BUILD)/inc/me.h
DEPS_37 += src/zlib/zlib.h

$(BUILD)/obj/zlib.o: \
    src/zlib/zlib.c $(DEPS_37)
	@echo '   [Compile] $(BUILD)/obj/zlib.o'
	$(CC) -c -o $(BUILD)/obj/zlib.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/zlib/zlib.c

ifeq ($(ME_COM_SSL),1)
#
#   openssl
#
DEPS_38 += $(BUILD)/obj/openssl.o

$(BUILD)/bin/libopenssl.a: $(DEPS_38)
	@echo '      [Link] $(BUILD)/bin/libopenssl.a'
	ar -cr $(BUILD)/bin/libopenssl.a "$(BUILD)/obj/openssl.o"
endif

#
#   libmpr
#
DEPS_39 += $(BUILD)/inc/osdep.h
ifeq ($(ME_COM_SSL),1)
    DEPS_39 += $(BUILD)/bin/libopenssl.a
endif
DEPS_39 += $(BUILD)/inc/mpr.h
DEPS_39 += $(BUILD)/obj/mprLib.o

$(BUILD)/bin/libmpr.a: $(DEPS_39)
	@echo '      [Link] $(BUILD)/bin/libmpr.a'
	ar -cr $(BUILD)/bin/libmpr.a "$(BUILD)/obj/mprLib.o"

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_40 += $(BUILD)/inc/pcre.h
DEPS_40 += $(BUILD)/obj/pcre.o

$(BUILD)/bin/libpcre.a: $(DEPS_40)
	@echo '      [Link] $(BUILD)/bin/libpcre.a'
	ar -cr $(BUILD)/bin/libpcre.a "$(BUILD)/obj/pcre.o"
endif

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_41 += $(BUILD)/bin/libmpr.a
ifeq ($(ME_COM_PCRE),1)
    DEPS_41 += $(BUILD)/bin/libpcre.a
endif
DEPS_41 += $(BUILD)/inc/http.h
DEPS_41 += $(BUILD)/obj/httpLib.o

$(BUILD)/bin/libhttp.a: $(DEPS_41)
	@echo '      [Link] $(BUILD)/bin/libhttp.a'
	ar -cr $(BUILD)/bin/libhttp.a "$(BUILD)/obj/httpLib.o"
endif

ifeq ($(ME_COM_ESP),1)
#
#   libesp
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_42 += $(BUILD)/bin/libhttp.a
endif
DEPS_42 += $(BUILD)/inc/esp.h
DEPS_42 += $(BUILD)/obj/espLib.o

$(BUILD)/bin/libesp.a: $(DEPS_42)
	@echo '      [Link] $(BUILD)/bin/libesp.a'
	ar -cr $(BUILD)/bin/libesp.a "$(BUILD)/obj/espLib.o"
endif

#
#   libappweb
#
ifeq ($(ME_COM_ESP),1)
    DEPS_43 += $(BUILD)/bin/libesp.a
endif
ifeq ($(ME_COM_HTTP),1)
    DEPS_43 += $(BUILD)/bin/libhttp.a
endif
DEPS_43 += $(BUILD)/bin/libmpr.a
DEPS_43 += $(BUILD)/inc/appweb.h
DEPS_43 += $(BUILD)/inc/customize.h
DEPS_43 += $(BUILD)/obj/config.o
DEPS_43 += $(BUILD)/obj/convenience.o
DEPS_43 += $(BUILD)/obj/romFiles.o
DEPS_43 += $(BUILD)/obj/cgiHandler.o
DEPS_43 += $(BUILD)/obj/espHandler.o

$(BUILD)/bin/libappweb.a: $(DEPS_43)
	@echo '      [Link] $(BUILD)/bin/libappweb.a'
	ar -cr $(BUILD)/bin/libappweb.a "$(BUILD)/obj/config.o" "$(BUILD)/obj/convenience.o" "$(BUILD)/obj/romFiles.o" "$(BUILD)/obj/cgiHandler.o" "$(BUILD)/obj/espHandler.o"

#
#   appweb
#
DEPS_44 += $(BUILD)/bin/libappweb.a
DEPS_44 += $(BUILD)/obj/appweb.o

LIBS_44 += -lappweb
ifeq ($(ME_COM_ESP),1)
    LIBS_44 += -lesp
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_44 += -lsql
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_44 += -lhttp
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_44 += -lpcre
endif
LIBS_44 += -lmpr
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_44 += -lmatrixssl
    LIBPATHS_44 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_44 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_44 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_44 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_44 += -lestssl
endif
ifeq ($(ME_COM_EST),1)
    LIBS_44 += -lest
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_44 += -lopenssl
    LIBPATHS_44 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_44 += -lssl
    LIBPATHS_44 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_44 += -lcrypto
    LIBPATHS_44 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_44 += -lcore_s
    LIBPATHS_44 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_44 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_44 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_44 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_44 += -lcrypt_s
    LIBPATHS_44 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_44 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_44 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_44 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_44 += -lssl_s
    LIBPATHS_44 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_44 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_44 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_44 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif

$(BUILD)/bin/appweb.out: $(DEPS_44)
	@echo '      [Link] $(BUILD)/bin/appweb.out'
	$(CC) -o $(BUILD)/bin/appweb.out $(LDFLAGS) $(LIBPATHS)      "$(BUILD)/obj/appweb.o" $(LIBPATHS_44) $(LIBS_44) $(LIBS_44) $(LIBS) -Wl,-r 

#
#   authpass
#
DEPS_45 += $(BUILD)/bin/libappweb.a
DEPS_45 += $(BUILD)/obj/authpass.o

LIBS_45 += -lappweb
ifeq ($(ME_COM_ESP),1)
    LIBS_45 += -lesp
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_45 += -lsql
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_45 += -lhttp
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_45 += -lpcre
endif
LIBS_45 += -lmpr
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_45 += -lmatrixssl
    LIBPATHS_45 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_45 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_45 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_45 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_45 += -lestssl
endif
ifeq ($(ME_COM_EST),1)
    LIBS_45 += -lest
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_45 += -lopenssl
    LIBPATHS_45 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_45 += -lssl
    LIBPATHS_45 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_45 += -lcrypto
    LIBPATHS_45 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_45 += -lcore_s
    LIBPATHS_45 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_45 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_45 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_45 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_45 += -lcrypt_s
    LIBPATHS_45 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_45 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_45 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_45 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_45 += -lssl_s
    LIBPATHS_45 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_45 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_45 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_45 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif

$(BUILD)/bin/authpass.out: $(DEPS_45)
	@echo '      [Link] $(BUILD)/bin/authpass.out'
	$(CC) -o $(BUILD)/bin/authpass.out $(LDFLAGS) $(LIBPATHS)      "$(BUILD)/obj/authpass.o" $(LIBPATHS_45) $(LIBS_45) $(LIBS_45) $(LIBS) -Wl,-r 

ifeq ($(ME_COM_ESP),1)
#
#   esp-compile.json
#
DEPS_46 += src/esp/esp-compile.json

$(BUILD)/bin/esp-compile.json: $(DEPS_46)
	@echo '      [Copy] $(BUILD)/bin/esp-compile.json'
	mkdir -p "$(BUILD)/bin"
	cp src/esp/esp-compile.json $(BUILD)/bin/esp-compile.json
endif

ifeq ($(ME_COM_ESP),1)
#
#   espcmd
#
DEPS_47 += $(BUILD)/bin/libesp.a
DEPS_47 += $(BUILD)/obj/esp.o

LIBS_47 += -lesp
ifeq ($(ME_COM_SQLITE),1)
    LIBS_47 += -lsql
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_47 += -lhttp
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_47 += -lpcre
endif
LIBS_47 += -lmpr
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_47 += -lmatrixssl
    LIBPATHS_47 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_47 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_47 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_47 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_47 += -lestssl
endif
ifeq ($(ME_COM_EST),1)
    LIBS_47 += -lest
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_47 += -lopenssl
    LIBPATHS_47 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_47 += -lssl
    LIBPATHS_47 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_47 += -lcrypto
    LIBPATHS_47 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_47 += -lcore_s
    LIBPATHS_47 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_47 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_47 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_47 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_47 += -lcrypt_s
    LIBPATHS_47 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_47 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_47 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_47 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_47 += -lssl_s
    LIBPATHS_47 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_47 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_47 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_47 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif

$(BUILD)/bin/esp.out: $(DEPS_47)
	@echo '      [Link] $(BUILD)/bin/esp.out'
	$(CC) -o $(BUILD)/bin/esp.out $(LDFLAGS) $(LIBPATHS)      "$(BUILD)/obj/esp.o" $(LIBPATHS_47) $(LIBS_47) $(LIBS_47) $(LIBS) -Wl,-r 
endif

#
#   http-ca-crt
#
DEPS_48 += src/http/ca.crt

$(BUILD)/bin/ca.crt: $(DEPS_48)
	@echo '      [Copy] $(BUILD)/bin/ca.crt'
	mkdir -p "$(BUILD)/bin"
	cp src/http/src/http/ca.crt $(BUILD)/bin/ca.crt

ifeq ($(ME_COM_HTTP),1)
#
#   httpcmd
#
DEPS_49 += $(BUILD)/bin/libhttp.a
DEPS_49 += $(BUILD)/obj/http.o

LIBS_49 += -lhttp
ifeq ($(ME_COM_PCRE),1)
    LIBS_49 += -lpcre
endif
LIBS_49 += -lmpr
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_49 += -lmatrixssl
    LIBPATHS_49 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_49 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_49 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_49 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_49 += -lestssl
endif
ifeq ($(ME_COM_EST),1)
    LIBS_49 += -lest
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_49 += -lopenssl
    LIBPATHS_49 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_49 += -lssl
    LIBPATHS_49 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_49 += -lcrypto
    LIBPATHS_49 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_49 += -lcore_s
    LIBPATHS_49 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_49 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_49 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_49 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_49 += -lcrypt_s
    LIBPATHS_49 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_49 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_49 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_49 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_49 += -lssl_s
    LIBPATHS_49 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_49 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_49 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_49 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif

$(BUILD)/bin/http.out: $(DEPS_49)
	@echo '      [Link] $(BUILD)/bin/http.out'
	$(CC) -o $(BUILD)/bin/http.out $(LDFLAGS) $(LIBPATHS)      "$(BUILD)/obj/http.o" $(LIBPATHS_49) $(LIBS_49) $(LIBS_49) $(LIBS) -Wl,-r 
endif

ifeq ($(ME_COM_SQLITE),1)
#
#   libsql
#
DEPS_50 += $(BUILD)/inc/sqlite3.h
DEPS_50 += $(BUILD)/obj/sqlite3.o

$(BUILD)/bin/libsql.a: $(DEPS_50)
	@echo '      [Link] $(BUILD)/bin/libsql.a'
	ar -cr $(BUILD)/bin/libsql.a "$(BUILD)/obj/sqlite3.o"
endif

ifeq ($(ME_COM_ZLIB),1)
#
#   libzlib
#
DEPS_51 += $(BUILD)/inc/zlib.h
DEPS_51 += $(BUILD)/obj/zlib.o

$(BUILD)/bin/libzlib.a: $(DEPS_51)
	@echo '      [Link] $(BUILD)/bin/libzlib.a'
	ar -cr $(BUILD)/bin/libzlib.a "$(BUILD)/obj/zlib.o"
endif

#
#   server-cache
#

src/server/cache: $(DEPS_52)
	( \
	cd src/server; \
	mkdir -p "cache" ; \
	)

#
#   watchdog
#
DEPS_53 += $(BUILD)/bin/libmpr.a
DEPS_53 += $(BUILD)/obj/watchdog.o

LIBS_53 += -lmpr
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_53 += -lmatrixssl
    LIBPATHS_53 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_53 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_53 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_53 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_53 += -lestssl
endif
ifeq ($(ME_COM_EST),1)
    LIBS_53 += -lest
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_53 += -lopenssl
    LIBPATHS_53 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_53 += -lssl
    LIBPATHS_53 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_53 += -lcrypto
    LIBPATHS_53 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_53 += -lcore_s
    LIBPATHS_53 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_53 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_53 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_53 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_53 += -lcrypt_s
    LIBPATHS_53 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_53 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_53 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_53 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_53 += -lssl_s
    LIBPATHS_53 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_53 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_53 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_53 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif

$(BUILD)/bin/appman.out: $(DEPS_53)
	@echo '      [Link] $(BUILD)/bin/appman.out'
	$(CC) -o $(BUILD)/bin/appman.out $(LDFLAGS) $(LIBPATHS)      "$(BUILD)/obj/watchdog.o" $(LIBPATHS_53) $(LIBS_53) $(LIBS_53) $(LIBS) -Wl,-r 

#
#   installBinary
#

installBinary: $(DEPS_54)

#
#   install
#
DEPS_55 += installBinary

install: $(DEPS_55)

#
#   installPrep
#

installPrep: $(DEPS_56)
	if [ "`id -u`" != 0 ] ; \
	then echo "Must run as root. Rerun with "sudo"" ; \
	exit 255 ; \
	fi

#
#   run
#

run: $(DEPS_57)
	( \
	cd src/server; \
	../../$(BUILD)/bin/appweb --log stdout:2 ; \
	)

#
#   uninstall
#

uninstall: $(DEPS_58)
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

version: $(DEPS_59)
	echo $(VERSION)

