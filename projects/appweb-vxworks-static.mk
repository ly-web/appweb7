#
#   appweb-vxworks-static.mk -- Makefile to build Embedthis Appweb for vxworks
#

NAME                  := appweb
VERSION               := 5.4.0
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
ifeq ($(ME_COM_SQLITE),1)
    TARGETS           += $(BUILD)/bin/libsql.out
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
	rm -f "$(BUILD)/obj/makerom.o"
	rm -f "$(BUILD)/obj/manager.o"
	rm -f "$(BUILD)/obj/mprLib.o"
	rm -f "$(BUILD)/obj/mprSsl.o"
	rm -f "$(BUILD)/obj/pcre.o"
	rm -f "$(BUILD)/obj/slink.o"
	rm -f "$(BUILD)/obj/sqlite.o"
	rm -f "$(BUILD)/obj/sqlite3.o"
	rm -f "$(BUILD)/obj/sslModule.o"
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
#   appweb.o
#
DEPS_11 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/appweb.o: \
    src/server/appweb.c $(DEPS_11)
	@echo '   [Compile] $(BUILD)/obj/appweb.o'
	$(CC) -c -o $(BUILD)/obj/appweb.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/server/appweb.c

#
#   authpass.o
#
DEPS_12 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/authpass.o: \
    src/utils/authpass.c $(DEPS_12)
	@echo '   [Compile] $(BUILD)/obj/authpass.o'
	$(CC) -c -o $(BUILD)/obj/authpass.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/utils/authpass.c

#
#   cgiHandler.o
#
DEPS_13 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/cgiHandler.o: \
    src/modules/cgiHandler.c $(DEPS_13)
	@echo '   [Compile] $(BUILD)/obj/cgiHandler.o'
	$(CC) -c -o $(BUILD)/obj/cgiHandler.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/modules/cgiHandler.c

#
#   cgiProgram.o
#

$(BUILD)/obj/cgiProgram.o: \
    src/utils/cgiProgram.c $(DEPS_14)
	@echo '   [Compile] $(BUILD)/obj/cgiProgram.o'
	$(CC) -c -o $(BUILD)/obj/cgiProgram.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/utils/cgiProgram.c

#
#   appweb.h
#

src/appweb.h: $(DEPS_15)

#
#   config.o
#
DEPS_16 += src/appweb.h
DEPS_16 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/config.o: \
    src/config.c $(DEPS_16)
	@echo '   [Compile] $(BUILD)/obj/config.o'
	$(CC) -c -o $(BUILD)/obj/config.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/config.c

#
#   convenience.o
#
DEPS_17 += src/appweb.h

$(BUILD)/obj/convenience.o: \
    src/convenience.c $(DEPS_17)
	@echo '   [Compile] $(BUILD)/obj/convenience.o'
	$(CC) -c -o $(BUILD)/obj/convenience.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/convenience.c

#
#   esp.h
#

src/esp/esp.h: $(DEPS_18)

#
#   esp.o
#
DEPS_19 += src/esp/esp.h

$(BUILD)/obj/esp.o: \
    src/esp/esp.c $(DEPS_19)
	@echo '   [Compile] $(BUILD)/obj/esp.o'
	$(CC) -c -o $(BUILD)/obj/esp.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/esp/esp.c

#
#   espHandler.o
#
DEPS_20 += $(BUILD)/inc/appweb.h
DEPS_20 += $(BUILD)/inc/esp.h

$(BUILD)/obj/espHandler.o: \
    src/modules/espHandler.c $(DEPS_20)
	@echo '   [Compile] $(BUILD)/obj/espHandler.o'
	$(CC) -c -o $(BUILD)/obj/espHandler.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/modules/espHandler.c

#
#   espLib.o
#
DEPS_21 += src/esp/esp.h
DEPS_21 += $(BUILD)/inc/pcre.h
DEPS_21 += $(BUILD)/inc/http.h

$(BUILD)/obj/espLib.o: \
    src/esp/espLib.c $(DEPS_21)
	@echo '   [Compile] $(BUILD)/obj/espLib.o'
	$(CC) -c -o $(BUILD)/obj/espLib.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/esp/espLib.c

#
#   http.h
#

src/http/http.h: $(DEPS_22)

#
#   http.o
#
DEPS_23 += src/http/http.h

$(BUILD)/obj/http.o: \
    src/http/http.c $(DEPS_23)
	@echo '   [Compile] $(BUILD)/obj/http.o'
	$(CC) -c -o $(BUILD)/obj/http.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/http/http.c

#
#   httpLib.o
#
DEPS_24 += src/http/http.h

$(BUILD)/obj/httpLib.o: \
    src/http/httpLib.c $(DEPS_24)
	@echo '   [Compile] $(BUILD)/obj/httpLib.o'
	$(CC) -c -o $(BUILD)/obj/httpLib.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/http/httpLib.c

#
#   mpr.h
#

src/mpr/mpr.h: $(DEPS_25)

#
#   makerom.o
#
DEPS_26 += src/mpr/mpr.h

$(BUILD)/obj/makerom.o: \
    src/mpr/makerom.c $(DEPS_26)
	@echo '   [Compile] $(BUILD)/obj/makerom.o'
	$(CC) -c -o $(BUILD)/obj/makerom.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/mpr/makerom.c

#
#   manager.o
#
DEPS_27 += src/mpr/mpr.h

$(BUILD)/obj/manager.o: \
    src/mpr/manager.c $(DEPS_27)
	@echo '   [Compile] $(BUILD)/obj/manager.o'
	$(CC) -c -o $(BUILD)/obj/manager.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/mpr/manager.c

#
#   mprLib.o
#
DEPS_28 += src/mpr/mpr.h

$(BUILD)/obj/mprLib.o: \
    src/mpr/mprLib.c $(DEPS_28)
	@echo '   [Compile] $(BUILD)/obj/mprLib.o'
	$(CC) -c -o $(BUILD)/obj/mprLib.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/mpr/mprLib.c

#
#   mprSsl.o
#
DEPS_29 += src/mpr/mpr.h

$(BUILD)/obj/mprSsl.o: \
    src/mpr/mprSsl.c $(DEPS_29)
	@echo '   [Compile] $(BUILD)/obj/mprSsl.o'
	$(CC) -c -o $(BUILD)/obj/mprSsl.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/mpr/mprSsl.c

#
#   pcre.h
#

src/pcre/pcre.h: $(DEPS_30)

#
#   pcre.o
#
DEPS_31 += $(BUILD)/inc/me.h
DEPS_31 += src/pcre/pcre.h

$(BUILD)/obj/pcre.o: \
    src/pcre/pcre.c $(DEPS_31)
	@echo '   [Compile] $(BUILD)/obj/pcre.o'
	$(CC) -c -o $(BUILD)/obj/pcre.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/pcre/pcre.c

#
#   slink.o
#
DEPS_32 += $(BUILD)/inc/mpr.h
DEPS_32 += $(BUILD)/inc/esp.h

$(BUILD)/obj/slink.o: \
    src/server/slink.c $(DEPS_32)
	@echo '   [Compile] $(BUILD)/obj/slink.o'
	$(CC) -c -o $(BUILD)/obj/slink.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/server/slink.c

#
#   sqlite3.h
#

src/sqlite/sqlite3.h: $(DEPS_33)

#
#   sqlite.o
#
DEPS_34 += $(BUILD)/inc/me.h
DEPS_34 += src/sqlite/sqlite3.h

$(BUILD)/obj/sqlite.o: \
    src/sqlite/sqlite.c $(DEPS_34)
	@echo '   [Compile] $(BUILD)/obj/sqlite.o'
	$(CC) -c -o $(BUILD)/obj/sqlite.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/sqlite/sqlite.c

#
#   sqlite3.o
#
DEPS_35 += $(BUILD)/inc/me.h
DEPS_35 += src/sqlite/sqlite3.h

$(BUILD)/obj/sqlite3.o: \
    src/sqlite/sqlite3.c $(DEPS_35)
	@echo '   [Compile] $(BUILD)/obj/sqlite3.o'
	$(CC) -c -o $(BUILD)/obj/sqlite3.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/sqlite/sqlite3.c

#
#   sslModule.o
#
DEPS_36 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/sslModule.o: \
    src/modules/sslModule.c $(DEPS_36)
	@echo '   [Compile] $(BUILD)/obj/sslModule.o'
	$(CC) -c -o $(BUILD)/obj/sslModule.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/modules/sslModule.c

#
#   libmpr
#
DEPS_37 += $(BUILD)/inc/osdep.h
DEPS_37 += $(BUILD)/inc/mpr.h
DEPS_37 += $(BUILD)/obj/mprLib.o

$(BUILD)/bin/libmpr.out: $(DEPS_37)
	@echo '      [Link] $(BUILD)/bin/libmpr.out'
	ar -cr $(BUILD)/bin/libmpr.out "$(BUILD)/obj/mprLib.o"

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_38 += $(BUILD)/inc/pcre.h
DEPS_38 += $(BUILD)/obj/pcre.o

$(BUILD)/bin/libpcre.out: $(DEPS_38)
	@echo '      [Link] $(BUILD)/bin/libpcre.out'
	ar -cr $(BUILD)/bin/libpcre.out "$(BUILD)/obj/pcre.o"
endif

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_39 += $(BUILD)/bin/libmpr.out
ifeq ($(ME_COM_PCRE),1)
    DEPS_39 += $(BUILD)/bin/libpcre.out
endif
DEPS_39 += $(BUILD)/inc/http.h
DEPS_39 += $(BUILD)/obj/httpLib.o

$(BUILD)/bin/libhttp.out: $(DEPS_39)
	@echo '      [Link] $(BUILD)/bin/libhttp.out'
	ar -cr $(BUILD)/bin/libhttp.out "$(BUILD)/obj/httpLib.o"
endif

#
#   libappweb
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_40 += $(BUILD)/bin/libhttp.out
endif
DEPS_40 += $(BUILD)/bin/libmpr.out
DEPS_40 += $(BUILD)/inc/appweb.h
DEPS_40 += $(BUILD)/inc/customize.h
DEPS_40 += $(BUILD)/obj/config.o
DEPS_40 += $(BUILD)/obj/convenience.o

$(BUILD)/bin/libappweb.out: $(DEPS_40)
	@echo '      [Link] $(BUILD)/bin/libappweb.out'
	ar -cr $(BUILD)/bin/libappweb.out "$(BUILD)/obj/config.o" "$(BUILD)/obj/convenience.o"

ifeq ($(ME_COM_ESP),1)
#
#   libesp
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_41 += $(BUILD)/bin/libhttp.out
endif
DEPS_41 += $(BUILD)/inc/esp.h
DEPS_41 += $(BUILD)/obj/espLib.o

$(BUILD)/bin/libesp.out: $(DEPS_41)
	@echo '      [Link] $(BUILD)/bin/libesp.out'
	ar -cr $(BUILD)/bin/libesp.out "$(BUILD)/obj/espLib.o"
endif

ifeq ($(ME_COM_ESP),1)
#
#   libmod_esp
#
DEPS_42 += $(BUILD)/bin/libappweb.out
DEPS_42 += $(BUILD)/bin/libesp.out
DEPS_42 += $(BUILD)/obj/espHandler.o

$(BUILD)/bin/libmod_esp.out: $(DEPS_42)
	@echo '      [Link] $(BUILD)/bin/libmod_esp.out'
	ar -cr $(BUILD)/bin/libmod_esp.out "$(BUILD)/obj/espHandler.o"
endif

#
#   libslink
#
ifeq ($(ME_COM_ESP),1)
    DEPS_43 += $(BUILD)/bin/libesp.out
endif
ifeq ($(ME_COM_ESP),1)
    DEPS_43 += $(BUILD)/bin/libmod_esp.out
endif
DEPS_43 += $(BUILD)/obj/slink.o

$(BUILD)/bin/libslink.out: $(DEPS_43)
	@echo '      [Link] $(BUILD)/bin/libslink.out'
	ar -cr $(BUILD)/bin/libslink.out "$(BUILD)/obj/slink.o"

#
#   libmprssl
#
DEPS_44 += $(BUILD)/bin/libmpr.out
DEPS_44 += $(BUILD)/obj/mprSsl.o

$(BUILD)/bin/libmprssl.out: $(DEPS_44)
	@echo '      [Link] $(BUILD)/bin/libmprssl.out'
	ar -cr $(BUILD)/bin/libmprssl.out "$(BUILD)/obj/mprSsl.o"

ifeq ($(ME_COM_SSL),1)
#
#   libmod_ssl
#
DEPS_45 += $(BUILD)/bin/libappweb.out
DEPS_45 += $(BUILD)/bin/libmprssl.out
DEPS_45 += $(BUILD)/obj/sslModule.o

$(BUILD)/bin/libmod_ssl.out: $(DEPS_45)
	@echo '      [Link] $(BUILD)/bin/libmod_ssl.out'
	ar -cr $(BUILD)/bin/libmod_ssl.out "$(BUILD)/obj/sslModule.o"
endif

ifeq ($(ME_COM_CGI),1)
#
#   libmod_cgi
#
DEPS_46 += $(BUILD)/bin/libappweb.out
DEPS_46 += $(BUILD)/obj/cgiHandler.o

$(BUILD)/bin/libmod_cgi.out: $(DEPS_46)
	@echo '      [Link] $(BUILD)/bin/libmod_cgi.out'
	ar -cr $(BUILD)/bin/libmod_cgi.out "$(BUILD)/obj/cgiHandler.o"
endif

#
#   appweb
#
DEPS_47 += $(BUILD)/bin/libappweb.out
DEPS_47 += $(BUILD)/bin/libslink.out
ifeq ($(ME_COM_ESP),1)
    DEPS_47 += $(BUILD)/bin/libmod_esp.out
endif
ifeq ($(ME_COM_SSL),1)
    DEPS_47 += $(BUILD)/bin/libmod_ssl.out
endif
ifeq ($(ME_COM_CGI),1)
    DEPS_47 += $(BUILD)/bin/libmod_cgi.out
endif
DEPS_47 += $(BUILD)/obj/appweb.o

LIBS_47 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_47 += -lhttp
endif
LIBS_47 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_47 += -lpcre
endif
LIBS_47 += -lslink
ifeq ($(ME_COM_ESP),1)
    LIBS_47 += -lesp
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_47 += -lsql
endif
ifeq ($(ME_COM_ESP),1)
    LIBS_47 += -lmod_esp
endif
ifeq ($(ME_COM_SSL),1)
    LIBS_47 += -lmod_ssl
endif
LIBS_47 += -lmprssl
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_47 += -lssl
    LIBPATHS_47 += -L"$(ME_COM_OPENSSL_PATH)/lib"
    LIBPATHS_47 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_47 += -lcrypto
    LIBPATHS_47 += -L"$(ME_COM_OPENSSL_PATH)/lib"
    LIBPATHS_47 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_47 += -lest
endif
ifeq ($(ME_COM_CGI),1)
    LIBS_47 += -lmod_cgi
endif

$(BUILD)/bin/appweb.out: $(DEPS_47)
	@echo '      [Link] $(BUILD)/bin/appweb.out'
	$(CC) -o $(BUILD)/bin/appweb.out $(LDFLAGS) $(LIBPATHS)   "$(BUILD)/obj/appweb.o" $(LIBPATHS_47) $(LIBS_47) $(LIBS_47) $(LIBS) -Wl,-r 

#
#   authpass
#
DEPS_48 += $(BUILD)/bin/libappweb.out
DEPS_48 += $(BUILD)/obj/authpass.o

LIBS_48 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_48 += -lhttp
endif
LIBS_48 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_48 += -lpcre
endif

$(BUILD)/bin/authpass.out: $(DEPS_48)
	@echo '      [Link] $(BUILD)/bin/authpass.out'
	$(CC) -o $(BUILD)/bin/authpass.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/authpass.o" $(LIBPATHS_48) $(LIBS_48) $(LIBS_48) $(LIBS) -Wl,-r 

ifeq ($(ME_COM_ESP),1)
#
#   esp-compile.json
#
DEPS_49 += src/esp/esp-compile.json

$(BUILD)/bin/esp-compile.json: $(DEPS_49)
	@echo '      [Copy] $(BUILD)/bin/esp-compile.json'
	mkdir -p "$(BUILD)/bin"
	cp src/esp/esp-compile.json $(BUILD)/bin/esp-compile.json
endif

ifeq ($(ME_COM_ESP),1)
#
#   espcmd
#
DEPS_50 += $(BUILD)/bin/libesp.out
DEPS_50 += $(BUILD)/obj/esp.o

LIBS_50 += -lesp
ifeq ($(ME_COM_HTTP),1)
    LIBS_50 += -lhttp
endif
LIBS_50 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_50 += -lpcre
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_50 += -lsql
endif

$(BUILD)/bin/esp.out: $(DEPS_50)
	@echo '      [Link] $(BUILD)/bin/esp.out'
	$(CC) -o $(BUILD)/bin/esp.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/esp.o" $(LIBPATHS_50) $(LIBS_50) $(LIBS_50) $(LIBS) -Wl,-r 
endif

ifeq ($(ME_COM_ESP),1)
#
#   genslink
#
DEPS_51 += $(BUILD)/bin/libesp.out

genslink: $(DEPS_51)
	( \
	cd src/server; \
	echo '    [Create] slink.c' ; \
	esp --static --genlink slink.c compile ; \
	)
endif

#
#   http-ca-crt
#
DEPS_52 += src/http/ca.crt

$(BUILD)/bin/ca.crt: $(DEPS_52)
	@echo '      [Copy] $(BUILD)/bin/ca.crt'
	mkdir -p "$(BUILD)/bin"
	cp src/http/ca.crt $(BUILD)/bin/ca.crt

ifeq ($(ME_COM_HTTP),1)
#
#   httpcmd
#
DEPS_53 += $(BUILD)/bin/libhttp.out
DEPS_53 += $(BUILD)/bin/libmprssl.out
DEPS_53 += $(BUILD)/obj/http.o

LIBS_53 += -lhttp
LIBS_53 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_53 += -lpcre
endif
LIBS_53 += -lmprssl
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_53 += -lssl
    LIBPATHS_53 += -L"$(ME_COM_OPENSSL_PATH)/lib"
    LIBPATHS_53 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_53 += -lcrypto
    LIBPATHS_53 += -L"$(ME_COM_OPENSSL_PATH)/lib"
    LIBPATHS_53 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_53 += -lest
endif

$(BUILD)/bin/http.out: $(DEPS_53)
	@echo '      [Link] $(BUILD)/bin/http.out'
	$(CC) -o $(BUILD)/bin/http.out $(LDFLAGS) $(LIBPATHS)   "$(BUILD)/obj/http.o" $(LIBPATHS_53) $(LIBS_53) $(LIBS_53) $(LIBS) -Wl,-r 
endif

ifeq ($(ME_COM_SQLITE),1)
#
#   libsql
#
DEPS_54 += $(BUILD)/inc/sqlite3.h
DEPS_54 += $(BUILD)/obj/sqlite3.o

$(BUILD)/bin/libsql.out: $(DEPS_54)
	@echo '      [Link] $(BUILD)/bin/libsql.out'
	ar -cr $(BUILD)/bin/libsql.out "$(BUILD)/obj/sqlite3.o"
endif

#
#   manager
#
DEPS_55 += $(BUILD)/bin/libmpr.out
DEPS_55 += $(BUILD)/obj/manager.o

LIBS_55 += -lmpr

$(BUILD)/bin/appman.out: $(DEPS_55)
	@echo '      [Link] $(BUILD)/bin/appman.out'
	$(CC) -o $(BUILD)/bin/appman.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/manager.o" $(LIBPATHS_55) $(LIBS_55) $(LIBS_55) $(LIBS) -Wl,-r 

#
#   server-cache
#

src/server/cache: $(DEPS_56)
	( \
	cd src/server; \
	mkdir -p "cache" ; \
	)

#
#   installBinary
#

installBinary: $(DEPS_57)

#
#   install
#
DEPS_58 += installBinary

install: $(DEPS_58)

#
#   installPrep
#

installPrep: $(DEPS_59)
	if [ "`id -u`" != 0 ] ; \
	then echo "Must run as root. Rerun with "sudo"" ; \
	exit 255 ; \
	fi


#
#   run
#

run: $(DEPS_60)
	( \
	cd src/server; \
	../../$(BUILD)/bin/appweb --log stdout:2 ; \
	)


#
#   uninstall
#

uninstall: $(DEPS_61)
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

version: $(DEPS_62)
	echo 5.4.0

