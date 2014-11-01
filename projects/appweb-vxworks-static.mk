#
#   appweb-vxworks-static.mk -- Makefile to build Embedthis Appweb for vxworks
#

NAME                  := appweb
VERSION               := 5.2.1
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

export WIND_HOME      ?= $(WIND_BASE)/..
export PATH           := $(WIND_GNU_PATH)/$(WIND_HOST_TYPE)/bin:$(PATH)

CFLAGS                += -fno-builtin -fno-defer-pop -fvolatile -w
DFLAGS                += -DVXWORKS -DRW_MULTI_THREAD -D_GNU_TOOL -DCPU=PENTIUM $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_CGI=$(ME_COM_CGI) -DME_COM_DIR=$(ME_COM_DIR) -DME_COM_EJS=$(ME_COM_EJS) -DME_COM_ESP=$(ME_COM_ESP) -DME_COM_EST=$(ME_COM_EST) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_MDB=$(ME_COM_MDB) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_OSDEP=$(ME_COM_OSDEP) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_PHP=$(ME_COM_PHP) -DME_COM_SQLITE=$(ME_COM_SQLITE) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_WINSDK=$(ME_COM_WINSDK) -DME_COM_ZLIB=$(ME_COM_ZLIB) 
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
ifeq ($(ME_COM_EJS),1)
    TARGETS           += $(BUILD)/bin/ejs.mod
endif
ifeq ($(ME_COM_EJS),1)
    TARGETS           += $(BUILD)/bin/ejs.out
endif
ifeq ($(ME_COM_ESP),1)
    TARGETS           += $(BUILD)/esp
endif
ifeq ($(ME_COM_ESP),1)
    TARGETS           += $(BUILD)/bin/esp.conf
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
	rm -f "$(BUILD)/obj/ejs.o"
	rm -f "$(BUILD)/obj/ejsHandler.o"
	rm -f "$(BUILD)/obj/ejsLib.o"
	rm -f "$(BUILD)/obj/ejsc.o"
	rm -f "$(BUILD)/obj/esp.o"
	rm -f "$(BUILD)/obj/espLib.o"
	rm -f "$(BUILD)/obj/estLib.o"
	rm -f "$(BUILD)/obj/http.o"
	rm -f "$(BUILD)/obj/httpLib.o"
	rm -f "$(BUILD)/obj/makerom.o"
	rm -f "$(BUILD)/obj/manager.o"
	rm -f "$(BUILD)/obj/mprLib.o"
	rm -f "$(BUILD)/obj/mprSsl.o"
	rm -f "$(BUILD)/obj/pcre.o"
	rm -f "$(BUILD)/obj/phpHandler.o"
	rm -f "$(BUILD)/obj/slink.o"
	rm -f "$(BUILD)/obj/sqlite.o"
	rm -f "$(BUILD)/obj/sqlite3.o"
	rm -f "$(BUILD)/obj/sslModule.o"
	rm -f "$(BUILD)/obj/zlib.o"
	rm -f "$(BUILD)/bin/appweb.out"
	rm -f "$(BUILD)/bin/authpass.out"
	rm -f "$(BUILD)/bin/ejsc.out"
	rm -f "$(BUILD)/bin/ejs.out"
	rm -f "$(BUILD)/bin/esp.conf"
	rm -f "$(BUILD)/bin/esp.out"
	rm -f "$(BUILD)/bin/ca.crt"
	rm -f "$(BUILD)/bin/http.out"
	rm -f "$(BUILD)/bin/libappweb.out"
	rm -f "$(BUILD)/bin/libejs.out"
	rm -f "$(BUILD)/bin/libest.out"
	rm -f "$(BUILD)/bin/libhttp.out"
	rm -f "$(BUILD)/bin/libmod_cgi.out"
	rm -f "$(BUILD)/bin/libmod_ejs.out"
	rm -f "$(BUILD)/bin/libmod_esp.out"
	rm -f "$(BUILD)/bin/libmod_php.out"
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
DEPS_2 += src/paks/osdep/osdep.h
DEPS_2 += $(BUILD)/inc/me.h

$(BUILD)/inc/osdep.h: $(DEPS_2)
	@echo '      [Copy] $(BUILD)/inc/osdep.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/osdep/osdep.h $(BUILD)/inc/osdep.h

#
#   mpr.h
#
DEPS_3 += src/paks/mpr/mpr.h
DEPS_3 += $(BUILD)/inc/me.h
DEPS_3 += $(BUILD)/inc/osdep.h

$(BUILD)/inc/mpr.h: $(DEPS_3)
	@echo '      [Copy] $(BUILD)/inc/mpr.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/mpr/mpr.h $(BUILD)/inc/mpr.h

#
#   http.h
#
DEPS_4 += src/paks/http/http.h
DEPS_4 += $(BUILD)/inc/mpr.h

$(BUILD)/inc/http.h: $(DEPS_4)
	@echo '      [Copy] $(BUILD)/inc/http.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/http/http.h $(BUILD)/inc/http.h

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
#   ejs.h
#
DEPS_8 += src/paks/ejs/ejs.h

$(BUILD)/inc/ejs.h: $(DEPS_8)
	@echo '      [Copy] $(BUILD)/inc/ejs.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/ejs/ejs.h $(BUILD)/inc/ejs.h

#
#   ejs.slots.h
#
DEPS_9 += src/paks/ejs/ejs.slots.h

$(BUILD)/inc/ejs.slots.h: $(DEPS_9)
	@echo '      [Copy] $(BUILD)/inc/ejs.slots.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/ejs/ejs.slots.h $(BUILD)/inc/ejs.slots.h

#
#   ejsByteGoto.h
#
DEPS_10 += src/paks/ejs/ejsByteGoto.h

$(BUILD)/inc/ejsByteGoto.h: $(DEPS_10)
	@echo '      [Copy] $(BUILD)/inc/ejsByteGoto.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/ejs/ejsByteGoto.h $(BUILD)/inc/ejsByteGoto.h

#
#   esp.h
#
DEPS_11 += src/paks/esp/esp.h
DEPS_11 += $(BUILD)/inc/me.h
DEPS_11 += $(BUILD)/inc/osdep.h
DEPS_11 += $(BUILD)/inc/appweb.h
DEPS_11 += $(BUILD)/inc/http.h

$(BUILD)/inc/esp.h: $(DEPS_11)
	@echo '      [Copy] $(BUILD)/inc/esp.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/esp/esp.h $(BUILD)/inc/esp.h

#
#   est.h
#
DEPS_12 += src/paks/est/est.h

$(BUILD)/inc/est.h: $(DEPS_12)
	@echo '      [Copy] $(BUILD)/inc/est.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/est/est.h $(BUILD)/inc/est.h

#
#   pcre.h
#
DEPS_13 += src/paks/pcre/pcre.h

$(BUILD)/inc/pcre.h: $(DEPS_13)
	@echo '      [Copy] $(BUILD)/inc/pcre.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/pcre/pcre.h $(BUILD)/inc/pcre.h

#
#   sqlite3.h
#
DEPS_14 += src/paks/sqlite/sqlite3.h

$(BUILD)/inc/sqlite3.h: $(DEPS_14)
	@echo '      [Copy] $(BUILD)/inc/sqlite3.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/sqlite/sqlite3.h $(BUILD)/inc/sqlite3.h

#
#   zlib.h
#
DEPS_15 += src/paks/zlib/zlib.h

$(BUILD)/inc/zlib.h: $(DEPS_15)
	@echo '      [Copy] $(BUILD)/inc/zlib.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/zlib/zlib.h $(BUILD)/inc/zlib.h

#
#   appweb.o
#
DEPS_16 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/appweb.o: \
    src/server/appweb.c $(DEPS_16)
	@echo '   [Compile] $(BUILD)/obj/appweb.o'
	$(CC) -c -o $(BUILD)/obj/appweb.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_PHP_PATH)" "-I$(ME_COM_PHP_PATH)/main" "-I$(ME_COM_PHP_PATH)/Zend" "-I$(ME_COM_PHP_PATH)/TSRM" src/server/appweb.c

#
#   authpass.o
#
DEPS_17 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/authpass.o: \
    src/utils/authpass.c $(DEPS_17)
	@echo '   [Compile] $(BUILD)/obj/authpass.o'
	$(CC) -c -o $(BUILD)/obj/authpass.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/utils/authpass.c

#
#   cgiHandler.o
#
DEPS_18 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/cgiHandler.o: \
    src/modules/cgiHandler.c $(DEPS_18)
	@echo '   [Compile] $(BUILD)/obj/cgiHandler.o'
	$(CC) -c -o $(BUILD)/obj/cgiHandler.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/modules/cgiHandler.c

#
#   cgiProgram.o
#

$(BUILD)/obj/cgiProgram.o: \
    src/utils/cgiProgram.c $(DEPS_19)
	@echo '   [Compile] $(BUILD)/obj/cgiProgram.o'
	$(CC) -c -o $(BUILD)/obj/cgiProgram.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/utils/cgiProgram.c

#
#   appweb.h
#

src/appweb.h: $(DEPS_20)

#
#   config.o
#
DEPS_21 += src/appweb.h
DEPS_21 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/config.o: \
    src/config.c $(DEPS_21)
	@echo '   [Compile] $(BUILD)/obj/config.o'
	$(CC) -c -o $(BUILD)/obj/config.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/config.c

#
#   convenience.o
#
DEPS_22 += src/appweb.h

$(BUILD)/obj/convenience.o: \
    src/convenience.c $(DEPS_22)
	@echo '   [Compile] $(BUILD)/obj/convenience.o'
	$(CC) -c -o $(BUILD)/obj/convenience.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/convenience.c

#
#   ejs.h
#

src/paks/ejs/ejs.h: $(DEPS_23)

#
#   ejs.o
#
DEPS_24 += src/paks/ejs/ejs.h

$(BUILD)/obj/ejs.o: \
    src/paks/ejs/ejs.c $(DEPS_24)
	@echo '   [Compile] $(BUILD)/obj/ejs.o'
	$(CC) -c -o $(BUILD)/obj/ejs.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/ejs/ejs.c

#
#   ejsHandler.o
#
DEPS_25 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/ejsHandler.o: \
    src/modules/ejsHandler.c $(DEPS_25)
	@echo '   [Compile] $(BUILD)/obj/ejsHandler.o'
	$(CC) -c -o $(BUILD)/obj/ejsHandler.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/modules/ejsHandler.c

#
#   ejsLib.o
#
DEPS_26 += src/paks/ejs/ejs.h
DEPS_26 += $(BUILD)/inc/mpr.h
DEPS_26 += $(BUILD)/inc/pcre.h
DEPS_26 += $(BUILD)/inc/me.h

$(BUILD)/obj/ejsLib.o: \
    src/paks/ejs/ejsLib.c $(DEPS_26)
	@echo '   [Compile] $(BUILD)/obj/ejsLib.o'
	$(CC) -c -o $(BUILD)/obj/ejsLib.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/ejs/ejsLib.c

#
#   ejsc.o
#
DEPS_27 += src/paks/ejs/ejs.h

$(BUILD)/obj/ejsc.o: \
    src/paks/ejs/ejsc.c $(DEPS_27)
	@echo '   [Compile] $(BUILD)/obj/ejsc.o'
	$(CC) -c -o $(BUILD)/obj/ejsc.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/ejs/ejsc.c

#
#   esp.h
#

src/paks/esp/esp.h: $(DEPS_28)

#
#   esp.o
#
DEPS_29 += src/paks/esp/esp.h

$(BUILD)/obj/esp.o: \
    src/paks/esp/esp.c $(DEPS_29)
	@echo '   [Compile] $(BUILD)/obj/esp.o'
	$(CC) -c -o $(BUILD)/obj/esp.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/esp/esp.c

#
#   espLib.o
#
DEPS_30 += src/paks/esp/esp.h
DEPS_30 += $(BUILD)/inc/pcre.h
DEPS_30 += $(BUILD)/inc/http.h

$(BUILD)/obj/espLib.o: \
    src/paks/esp/espLib.c $(DEPS_30)
	@echo '   [Compile] $(BUILD)/obj/espLib.o'
	$(CC) -c -o $(BUILD)/obj/espLib.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/esp/espLib.c

#
#   est.h
#

src/paks/est/est.h: $(DEPS_31)

#
#   estLib.o
#
DEPS_32 += src/paks/est/est.h

$(BUILD)/obj/estLib.o: \
    src/paks/est/estLib.c $(DEPS_32)
	@echo '   [Compile] $(BUILD)/obj/estLib.o'
	$(CC) -c -o $(BUILD)/obj/estLib.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/est/estLib.c

#
#   http.h
#

src/paks/http/http.h: $(DEPS_33)

#
#   http.o
#
DEPS_34 += src/paks/http/http.h

$(BUILD)/obj/http.o: \
    src/paks/http/http.c $(DEPS_34)
	@echo '   [Compile] $(BUILD)/obj/http.o'
	$(CC) -c -o $(BUILD)/obj/http.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/paks/http/http.c

#
#   httpLib.o
#
DEPS_35 += src/paks/http/http.h

$(BUILD)/obj/httpLib.o: \
    src/paks/http/httpLib.c $(DEPS_35)
	@echo '   [Compile] $(BUILD)/obj/httpLib.o'
	$(CC) -c -o $(BUILD)/obj/httpLib.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/http/httpLib.c

#
#   mpr.h
#

src/paks/mpr/mpr.h: $(DEPS_36)

#
#   makerom.o
#
DEPS_37 += src/paks/mpr/mpr.h

$(BUILD)/obj/makerom.o: \
    src/paks/mpr/makerom.c $(DEPS_37)
	@echo '   [Compile] $(BUILD)/obj/makerom.o'
	$(CC) -c -o $(BUILD)/obj/makerom.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/mpr/makerom.c

#
#   manager.o
#
DEPS_38 += src/paks/mpr/mpr.h

$(BUILD)/obj/manager.o: \
    src/paks/mpr/manager.c $(DEPS_38)
	@echo '   [Compile] $(BUILD)/obj/manager.o'
	$(CC) -c -o $(BUILD)/obj/manager.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/mpr/manager.c

#
#   mprLib.o
#
DEPS_39 += src/paks/mpr/mpr.h

$(BUILD)/obj/mprLib.o: \
    src/paks/mpr/mprLib.c $(DEPS_39)
	@echo '   [Compile] $(BUILD)/obj/mprLib.o'
	$(CC) -c -o $(BUILD)/obj/mprLib.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/mpr/mprLib.c

#
#   mprSsl.o
#
DEPS_40 += src/paks/mpr/mpr.h

$(BUILD)/obj/mprSsl.o: \
    src/paks/mpr/mprSsl.c $(DEPS_40)
	@echo '   [Compile] $(BUILD)/obj/mprSsl.o'
	$(CC) -c -o $(BUILD)/obj/mprSsl.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/paks/mpr/mprSsl.c

#
#   pcre.h
#

src/paks/pcre/pcre.h: $(DEPS_41)

#
#   pcre.o
#
DEPS_42 += $(BUILD)/inc/me.h
DEPS_42 += src/paks/pcre/pcre.h

$(BUILD)/obj/pcre.o: \
    src/paks/pcre/pcre.c $(DEPS_42)
	@echo '   [Compile] $(BUILD)/obj/pcre.o'
	$(CC) -c -o $(BUILD)/obj/pcre.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/pcre/pcre.c

#
#   phpHandler.o
#
DEPS_43 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/phpHandler.o: \
    src/modules/phpHandler.c $(DEPS_43)
	@echo '   [Compile] $(BUILD)/obj/phpHandler.o'
	$(CC) -c -o $(BUILD)/obj/phpHandler.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_PHP_PATH)" "-I$(ME_COM_PHP_PATH)/main" "-I$(ME_COM_PHP_PATH)/Zend" "-I$(ME_COM_PHP_PATH)/TSRM" src/modules/phpHandler.c

#
#   slink.o
#
DEPS_44 += $(BUILD)/inc/mpr.h
DEPS_44 += $(BUILD)/inc/esp.h

$(BUILD)/obj/slink.o: \
    src/server/slink.c $(DEPS_44)
	@echo '   [Compile] $(BUILD)/obj/slink.o'
	$(CC) -c -o $(BUILD)/obj/slink.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/server/slink.c

#
#   sqlite3.h
#

src/paks/sqlite/sqlite3.h: $(DEPS_45)

#
#   sqlite.o
#
DEPS_46 += $(BUILD)/inc/me.h
DEPS_46 += src/paks/sqlite/sqlite3.h

$(BUILD)/obj/sqlite.o: \
    src/paks/sqlite/sqlite.c $(DEPS_46)
	@echo '   [Compile] $(BUILD)/obj/sqlite.o'
	$(CC) -c -o $(BUILD)/obj/sqlite.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/sqlite/sqlite.c

#
#   sqlite3.o
#
DEPS_47 += $(BUILD)/inc/me.h
DEPS_47 += src/paks/sqlite/sqlite3.h

$(BUILD)/obj/sqlite3.o: \
    src/paks/sqlite/sqlite3.c $(DEPS_47)
	@echo '   [Compile] $(BUILD)/obj/sqlite3.o'
	$(CC) -c -o $(BUILD)/obj/sqlite3.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/sqlite/sqlite3.c

#
#   sslModule.o
#
DEPS_48 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/sslModule.o: \
    src/modules/sslModule.c $(DEPS_48)
	@echo '   [Compile] $(BUILD)/obj/sslModule.o'
	$(CC) -c -o $(BUILD)/obj/sslModule.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(ME_COM_OPENSSL_PATH)/include" src/modules/sslModule.c

#
#   zlib.h
#

src/paks/zlib/zlib.h: $(DEPS_49)

#
#   zlib.o
#
DEPS_50 += $(BUILD)/inc/me.h
DEPS_50 += src/paks/zlib/zlib.h

$(BUILD)/obj/zlib.o: \
    src/paks/zlib/zlib.c $(DEPS_50)
	@echo '   [Compile] $(BUILD)/obj/zlib.o'
	$(CC) -c -o $(BUILD)/obj/zlib.o $(CFLAGS) $(DFLAGS) "-I$(BUILD)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/zlib/zlib.c

#
#   libmpr
#
DEPS_51 += $(BUILD)/inc/osdep.h
DEPS_51 += $(BUILD)/inc/mpr.h
DEPS_51 += $(BUILD)/obj/mprLib.o

$(BUILD)/bin/libmpr.out: $(DEPS_51)
	@echo '      [Link] $(BUILD)/bin/libmpr.out'
	ar -cr $(BUILD)/bin/libmpr.out "$(BUILD)/obj/mprLib.o"

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_52 += $(BUILD)/inc/pcre.h
DEPS_52 += $(BUILD)/obj/pcre.o

$(BUILD)/bin/libpcre.out: $(DEPS_52)
	@echo '      [Link] $(BUILD)/bin/libpcre.out'
	ar -cr $(BUILD)/bin/libpcre.out "$(BUILD)/obj/pcre.o"
endif

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_53 += $(BUILD)/bin/libmpr.out
ifeq ($(ME_COM_PCRE),1)
    DEPS_53 += $(BUILD)/bin/libpcre.out
endif
DEPS_53 += $(BUILD)/inc/http.h
DEPS_53 += $(BUILD)/obj/httpLib.o

$(BUILD)/bin/libhttp.out: $(DEPS_53)
	@echo '      [Link] $(BUILD)/bin/libhttp.out'
	ar -cr $(BUILD)/bin/libhttp.out "$(BUILD)/obj/httpLib.o"
endif

#
#   libappweb
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_54 += $(BUILD)/bin/libhttp.out
endif
DEPS_54 += $(BUILD)/bin/libmpr.out
DEPS_54 += $(BUILD)/inc/appweb.h
DEPS_54 += $(BUILD)/inc/customize.h
DEPS_54 += $(BUILD)/obj/config.o
DEPS_54 += $(BUILD)/obj/convenience.o

$(BUILD)/bin/libappweb.out: $(DEPS_54)
	@echo '      [Link] $(BUILD)/bin/libappweb.out'
	ar -cr $(BUILD)/bin/libappweb.out "$(BUILD)/obj/config.o" "$(BUILD)/obj/convenience.o"

ifeq ($(ME_COM_ESP),1)
#
#   libmod_esp
#
DEPS_55 += $(BUILD)/bin/libappweb.out
DEPS_55 += $(BUILD)/inc/esp.h
DEPS_55 += $(BUILD)/obj/espLib.o

$(BUILD)/bin/libmod_esp.out: $(DEPS_55)
	@echo '      [Link] $(BUILD)/bin/libmod_esp.out'
	ar -cr $(BUILD)/bin/libmod_esp.out "$(BUILD)/obj/espLib.o"
endif

#
#   libslink
#
ifeq ($(ME_COM_ESP),1)
    DEPS_56 += $(BUILD)/bin/libmod_esp.out
endif
ifeq ($(ME_COM_ESP),1)
    DEPS_56 += $(BUILD)/bin/libmod_esp.out
endif
DEPS_56 += $(BUILD)/obj/slink.o

$(BUILD)/bin/libslink.out: $(DEPS_56)
	@echo '      [Link] $(BUILD)/bin/libslink.out'
	ar -cr $(BUILD)/bin/libslink.out "$(BUILD)/obj/slink.o"

ifeq ($(ME_COM_EST),1)
#
#   libest
#
DEPS_57 += $(BUILD)/inc/osdep.h
DEPS_57 += $(BUILD)/inc/est.h
DEPS_57 += $(BUILD)/obj/estLib.o

$(BUILD)/bin/libest.out: $(DEPS_57)
	@echo '      [Link] $(BUILD)/bin/libest.out'
	ar -cr $(BUILD)/bin/libest.out "$(BUILD)/obj/estLib.o"
endif

#
#   libmprssl
#
DEPS_58 += $(BUILD)/bin/libmpr.out
ifeq ($(ME_COM_EST),1)
    DEPS_58 += $(BUILD)/bin/libest.out
endif
DEPS_58 += $(BUILD)/obj/mprSsl.o

$(BUILD)/bin/libmprssl.out: $(DEPS_58)
	@echo '      [Link] $(BUILD)/bin/libmprssl.out'
	ar -cr $(BUILD)/bin/libmprssl.out "$(BUILD)/obj/mprSsl.o"

ifeq ($(ME_COM_SSL),1)
#
#   libmod_ssl
#
DEPS_59 += $(BUILD)/bin/libappweb.out
DEPS_59 += $(BUILD)/bin/libmprssl.out
DEPS_59 += $(BUILD)/obj/sslModule.o

$(BUILD)/bin/libmod_ssl.out: $(DEPS_59)
	@echo '      [Link] $(BUILD)/bin/libmod_ssl.out'
	ar -cr $(BUILD)/bin/libmod_ssl.out "$(BUILD)/obj/sslModule.o"
endif

ifeq ($(ME_COM_ZLIB),1)
#
#   libzlib
#
DEPS_60 += $(BUILD)/inc/zlib.h
DEPS_60 += $(BUILD)/obj/zlib.o

$(BUILD)/bin/libzlib.out: $(DEPS_60)
	@echo '      [Link] $(BUILD)/bin/libzlib.out'
	ar -cr $(BUILD)/bin/libzlib.out "$(BUILD)/obj/zlib.o"
endif

ifeq ($(ME_COM_EJS),1)
#
#   libejs
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_61 += $(BUILD)/bin/libhttp.out
endif
ifeq ($(ME_COM_PCRE),1)
    DEPS_61 += $(BUILD)/bin/libpcre.out
endif
DEPS_61 += $(BUILD)/bin/libmpr.out
ifeq ($(ME_COM_ZLIB),1)
    DEPS_61 += $(BUILD)/bin/libzlib.out
endif
DEPS_61 += $(BUILD)/inc/ejs.h
DEPS_61 += $(BUILD)/inc/ejs.slots.h
DEPS_61 += $(BUILD)/inc/ejsByteGoto.h
DEPS_61 += $(BUILD)/obj/ejsLib.o

$(BUILD)/bin/libejs.out: $(DEPS_61)
	@echo '      [Link] $(BUILD)/bin/libejs.out'
	ar -cr $(BUILD)/bin/libejs.out "$(BUILD)/obj/ejsLib.o"
endif

ifeq ($(ME_COM_EJS),1)
#
#   libmod_ejs
#
DEPS_62 += $(BUILD)/bin/libappweb.out
DEPS_62 += $(BUILD)/bin/libejs.out
DEPS_62 += $(BUILD)/obj/ejsHandler.o

$(BUILD)/bin/libmod_ejs.out: $(DEPS_62)
	@echo '      [Link] $(BUILD)/bin/libmod_ejs.out'
	ar -cr $(BUILD)/bin/libmod_ejs.out "$(BUILD)/obj/ejsHandler.o"
endif

ifeq ($(ME_COM_PHP),1)
#
#   libmod_php
#
DEPS_63 += $(BUILD)/bin/libappweb.out
DEPS_63 += $(BUILD)/obj/phpHandler.o

$(BUILD)/bin/libmod_php.out: $(DEPS_63)
	@echo '      [Link] $(BUILD)/bin/libmod_php.out'
	ar -cr $(BUILD)/bin/libmod_php.out "$(BUILD)/obj/phpHandler.o"
endif

ifeq ($(ME_COM_CGI),1)
#
#   libmod_cgi
#
DEPS_64 += $(BUILD)/bin/libappweb.out
DEPS_64 += $(BUILD)/obj/cgiHandler.o

$(BUILD)/bin/libmod_cgi.out: $(DEPS_64)
	@echo '      [Link] $(BUILD)/bin/libmod_cgi.out'
	ar -cr $(BUILD)/bin/libmod_cgi.out "$(BUILD)/obj/cgiHandler.o"
endif

#
#   appweb
#
DEPS_65 += $(BUILD)/bin/libappweb.out
DEPS_65 += $(BUILD)/bin/libslink.out
ifeq ($(ME_COM_ESP),1)
    DEPS_65 += $(BUILD)/bin/libmod_esp.out
endif
ifeq ($(ME_COM_SSL),1)
    DEPS_65 += $(BUILD)/bin/libmod_ssl.out
endif
ifeq ($(ME_COM_EJS),1)
    DEPS_65 += $(BUILD)/bin/libmod_ejs.out
endif
ifeq ($(ME_COM_PHP),1)
    DEPS_65 += $(BUILD)/bin/libmod_php.out
endif
ifeq ($(ME_COM_CGI),1)
    DEPS_65 += $(BUILD)/bin/libmod_cgi.out
endif
DEPS_65 += $(BUILD)/obj/appweb.o

LIBS_65 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_65 += -lhttp
endif
LIBS_65 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_65 += -lpcre
endif
LIBS_65 += -lslink
ifeq ($(ME_COM_ESP),1)
    LIBS_65 += -lmod_esp
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_65 += -lsql
endif
ifeq ($(ME_COM_SSL),1)
    LIBS_65 += -lmod_ssl
endif
LIBS_65 += -lmprssl
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_65 += -lssl
    LIBPATHS_65 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_65 += -lcrypto
    LIBPATHS_65 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_EST),1)
    LIBS_65 += -lest
endif
ifeq ($(ME_COM_EJS),1)
    LIBS_65 += -lmod_ejs
endif
ifeq ($(ME_COM_EJS),1)
    LIBS_65 += -lejs
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_65 += -lzlib
endif
ifeq ($(ME_COM_PHP),1)
    LIBS_65 += -lmod_php
endif
ifeq ($(ME_COM_PHP),1)
    LIBS_65 += -lphp5
    LIBPATHS_65 += -L$(ME_COM_PHP_PATH)/libs
endif
ifeq ($(ME_COM_CGI),1)
    LIBS_65 += -lmod_cgi
endif

$(BUILD)/bin/appweb.out: $(DEPS_65)
	@echo '      [Link] $(BUILD)/bin/appweb.out'
	$(CC) -o $(BUILD)/bin/appweb.out $(LDFLAGS) $(LIBPATHS)   "$(BUILD)/obj/appweb.o" $(LIBPATHS_65) $(LIBS_65) $(LIBS_65) $(LIBS) -Wl,-r 

#
#   authpass
#
DEPS_66 += $(BUILD)/bin/libappweb.out
DEPS_66 += $(BUILD)/obj/authpass.o

LIBS_66 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_66 += -lhttp
endif
LIBS_66 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_66 += -lpcre
endif

$(BUILD)/bin/authpass.out: $(DEPS_66)
	@echo '      [Link] $(BUILD)/bin/authpass.out'
	$(CC) -o $(BUILD)/bin/authpass.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/authpass.o" $(LIBPATHS_66) $(LIBS_66) $(LIBS_66) $(LIBS) -Wl,-r 

ifeq ($(ME_COM_EJS),1)
#
#   ejsc
#
DEPS_67 += $(BUILD)/bin/libejs.out
DEPS_67 += $(BUILD)/obj/ejsc.o

LIBS_67 += -lejs
ifeq ($(ME_COM_HTTP),1)
    LIBS_67 += -lhttp
endif
LIBS_67 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_67 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_67 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_67 += -lsql
endif

$(BUILD)/bin/ejsc.out: $(DEPS_67)
	@echo '      [Link] $(BUILD)/bin/ejsc.out'
	$(CC) -o $(BUILD)/bin/ejsc.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/ejsc.o" $(LIBPATHS_67) $(LIBS_67) $(LIBS_67) $(LIBS) -Wl,-r 
endif

ifeq ($(ME_COM_EJS),1)
#
#   ejs.mod
#
DEPS_68 += src/paks/ejs/ejs.es
DEPS_68 += $(BUILD)/bin/ejsc.out

$(BUILD)/bin/ejs.mod: $(DEPS_68)
	( \
	cd src/paks/ejs; \
	echo '   [Compile] ejs.mod' ; \
	../../../$(BUILD)/bin/ejsc --out ../../../$(BUILD)/bin/ejs.mod --optimize 9 --bind --require null ejs.es ; \
	)
endif

ifeq ($(ME_COM_EJS),1)
#
#   ejscmd
#
DEPS_69 += $(BUILD)/bin/libejs.out
DEPS_69 += $(BUILD)/obj/ejs.o

LIBS_69 += -lejs
ifeq ($(ME_COM_HTTP),1)
    LIBS_69 += -lhttp
endif
LIBS_69 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_69 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_69 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_69 += -lsql
endif

$(BUILD)/bin/ejs.out: $(DEPS_69)
	@echo '      [Link] $(BUILD)/bin/ejs.out'
	$(CC) -o $(BUILD)/bin/ejs.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/ejs.o" $(LIBPATHS_69) $(LIBS_69) $(LIBS_69) $(LIBS) -Wl,-r 
endif

ifeq ($(ME_COM_ESP),1)
#
#   esp-paks
#
DEPS_70 += src/paks/esp-html-mvc/client/assets/favicon.ico
DEPS_70 += src/paks/esp-html-mvc/client/css/all.css
DEPS_70 += src/paks/esp-html-mvc/client/css/all.less
DEPS_70 += src/paks/esp-html-mvc/client/index.esp
DEPS_70 += src/paks/esp-html-mvc/css/app.less
DEPS_70 += src/paks/esp-html-mvc/css/theme.less
DEPS_70 += src/paks/esp-html-mvc/generate/appweb.conf
DEPS_70 += src/paks/esp-html-mvc/generate/controller.c
DEPS_70 += src/paks/esp-html-mvc/generate/controllerSingleton.c
DEPS_70 += src/paks/esp-html-mvc/generate/edit.esp
DEPS_70 += src/paks/esp-html-mvc/generate/list.esp
DEPS_70 += src/paks/esp-html-mvc/layouts/default.esp
DEPS_70 += src/paks/esp-html-mvc/LICENSE.md
DEPS_70 += src/paks/esp-html-mvc/package.json
DEPS_70 += src/paks/esp-html-mvc/README.md
DEPS_70 += src/paks/esp-mvc/generate/appweb.conf
DEPS_70 += src/paks/esp-mvc/generate/controller.c
DEPS_70 += src/paks/esp-mvc/generate/migration.c
DEPS_70 += src/paks/esp-mvc/generate/src/app.c
DEPS_70 += src/paks/esp-mvc/LICENSE.md
DEPS_70 += src/paks/esp-mvc/package.json
DEPS_70 += src/paks/esp-mvc/README.md
DEPS_70 += src/paks/esp-server/generate/appweb.conf
DEPS_70 += src/paks/esp-server/LICENSE.md
DEPS_70 += src/paks/esp-server/package.json
DEPS_70 += src/paks/esp-server/README.md

$(BUILD)/esp: $(DEPS_70)
	( \
	cd src/paks; \
	mkdir -p "../../$(BUILD)/esp/esp-html-mvc/5.2.0" ; \
	mkdir -p "../../$(BUILD)/esp/esp-html-mvc/5.2.0/client" ; \
	mkdir -p "../../$(BUILD)/esp/esp-html-mvc/5.2.0/client/assets" ; \
	cp esp-html-mvc/client/assets/favicon.ico ../../$(BUILD)/esp/esp-html-mvc/5.2.0/client/assets/favicon.ico ; \
	mkdir -p "../../$(BUILD)/esp/esp-html-mvc/5.2.0/client/css" ; \
	cp esp-html-mvc/client/css/all.css ../../$(BUILD)/esp/esp-html-mvc/5.2.0/client/css/all.css ; \
	cp esp-html-mvc/client/css/all.less ../../$(BUILD)/esp/esp-html-mvc/5.2.0/client/css/all.less ; \
	cp esp-html-mvc/client/index.esp ../../$(BUILD)/esp/esp-html-mvc/5.2.0/client/index.esp ; \
	mkdir -p "../../$(BUILD)/esp/esp-html-mvc/5.2.0/css" ; \
	cp esp-html-mvc/css/app.less ../../$(BUILD)/esp/esp-html-mvc/5.2.0/css/app.less ; \
	cp esp-html-mvc/css/theme.less ../../$(BUILD)/esp/esp-html-mvc/5.2.0/css/theme.less ; \
	mkdir -p "../../$(BUILD)/esp/esp-html-mvc/5.2.0/generate" ; \
	cp esp-html-mvc/generate/appweb.conf ../../$(BUILD)/esp/esp-html-mvc/5.2.0/generate/appweb.conf ; \
	cp esp-html-mvc/generate/controller.c ../../$(BUILD)/esp/esp-html-mvc/5.2.0/generate/controller.c ; \
	cp esp-html-mvc/generate/controllerSingleton.c ../../$(BUILD)/esp/esp-html-mvc/5.2.0/generate/controllerSingleton.c ; \
	cp esp-html-mvc/generate/edit.esp ../../$(BUILD)/esp/esp-html-mvc/5.2.0/generate/edit.esp ; \
	cp esp-html-mvc/generate/list.esp ../../$(BUILD)/esp/esp-html-mvc/5.2.0/generate/list.esp ; \
	mkdir -p "../../$(BUILD)/esp/esp-html-mvc/5.2.0/layouts" ; \
	cp esp-html-mvc/layouts/default.esp ../../$(BUILD)/esp/esp-html-mvc/5.2.0/layouts/default.esp ; \
	cp esp-html-mvc/LICENSE.md ../../$(BUILD)/esp/esp-html-mvc/5.2.0/LICENSE.md ; \
	cp esp-html-mvc/package.json ../../$(BUILD)/esp/esp-html-mvc/5.2.0/package.json ; \
	cp esp-html-mvc/README.md ../../$(BUILD)/esp/esp-html-mvc/5.2.0/README.md ; \
	mkdir -p "../../$(BUILD)/esp/esp-mvc/5.2.0" ; \
	mkdir -p "../../$(BUILD)/esp/esp-mvc/5.2.0/generate" ; \
	cp esp-mvc/generate/appweb.conf ../../$(BUILD)/esp/esp-mvc/5.2.0/generate/appweb.conf ; \
	cp esp-mvc/generate/controller.c ../../$(BUILD)/esp/esp-mvc/5.2.0/generate/controller.c ; \
	cp esp-mvc/generate/migration.c ../../$(BUILD)/esp/esp-mvc/5.2.0/generate/migration.c ; \
	mkdir -p "../../$(BUILD)/esp/esp-mvc/5.2.0/generate/src" ; \
	cp esp-mvc/generate/src/app.c ../../$(BUILD)/esp/esp-mvc/5.2.0/generate/src/app.c ; \
	cp esp-mvc/LICENSE.md ../../$(BUILD)/esp/esp-mvc/5.2.0/LICENSE.md ; \
	cp esp-mvc/package.json ../../$(BUILD)/esp/esp-mvc/5.2.0/package.json ; \
	cp esp-mvc/README.md ../../$(BUILD)/esp/esp-mvc/5.2.0/README.md ; \
	mkdir -p "../../$(BUILD)/esp/esp-server/5.2.0" ; \
	mkdir -p "../../$(BUILD)/esp/esp-server/5.2.0/generate" ; \
	cp esp-server/generate/appweb.conf ../../$(BUILD)/esp/esp-server/5.2.0/generate/appweb.conf ; \
	cp esp-server/LICENSE.md ../../$(BUILD)/esp/esp-server/5.2.0/LICENSE.md ; \
	cp esp-server/package.json ../../$(BUILD)/esp/esp-server/5.2.0/package.json ; \
	cp esp-server/README.md ../../$(BUILD)/esp/esp-server/5.2.0/README.md ; \
	)
endif

ifeq ($(ME_COM_ESP),1)
#
#   esp.conf
#
DEPS_71 += src/paks/esp/esp.conf

$(BUILD)/bin/esp.conf: $(DEPS_71)
	@echo '      [Copy] $(BUILD)/bin/esp.conf'
	mkdir -p "$(BUILD)/bin"
	cp src/paks/esp/esp.conf $(BUILD)/bin/esp.conf
endif

ifeq ($(ME_COM_ESP),1)
#
#   espcmd
#
DEPS_72 += $(BUILD)/bin/libmod_esp.out
DEPS_72 += $(BUILD)/obj/esp.o

LIBS_72 += -lmod_esp
LIBS_72 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_72 += -lhttp
endif
LIBS_72 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_72 += -lpcre
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_72 += -lsql
endif

$(BUILD)/bin/esp.out: $(DEPS_72)
	@echo '      [Link] $(BUILD)/bin/esp.out'
	$(CC) -o $(BUILD)/bin/esp.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/esp.o" $(LIBPATHS_72) $(LIBS_72) $(LIBS_72) $(LIBS) -Wl,-r 
endif

ifeq ($(ME_COM_ESP),1)
#
#   genslink
#
DEPS_73 += $(BUILD)/bin/libmod_esp.out

genslink: $(DEPS_73)
	( \
	cd src/server; \
	echo '    [Create] slink.c' ; \
	esp --static --genlink slink.c compile ; \
	)
endif

#
#   http-ca-crt
#
DEPS_74 += src/paks/http/ca.crt

$(BUILD)/bin/ca.crt: $(DEPS_74)
	@echo '      [Copy] $(BUILD)/bin/ca.crt'
	mkdir -p "$(BUILD)/bin"
	cp src/paks/http/ca.crt $(BUILD)/bin/ca.crt

ifeq ($(ME_COM_HTTP),1)
#
#   httpcmd
#
DEPS_75 += $(BUILD)/bin/libhttp.out
DEPS_75 += $(BUILD)/bin/libmprssl.out
DEPS_75 += $(BUILD)/obj/http.o

LIBS_75 += -lhttp
LIBS_75 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_75 += -lpcre
endif
LIBS_75 += -lmprssl
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_75 += -lssl
    LIBPATHS_75 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_75 += -lcrypto
    LIBPATHS_75 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_EST),1)
    LIBS_75 += -lest
endif

$(BUILD)/bin/http.out: $(DEPS_75)
	@echo '      [Link] $(BUILD)/bin/http.out'
	$(CC) -o $(BUILD)/bin/http.out $(LDFLAGS) $(LIBPATHS)  "$(BUILD)/obj/http.o" $(LIBPATHS_75) $(LIBS_75) $(LIBS_75) $(LIBS) -Wl,-r 
endif

ifeq ($(ME_COM_SQLITE),1)
#
#   libsql
#
DEPS_76 += $(BUILD)/inc/sqlite3.h
DEPS_76 += $(BUILD)/obj/sqlite3.o

$(BUILD)/bin/libsql.out: $(DEPS_76)
	@echo '      [Link] $(BUILD)/bin/libsql.out'
	ar -cr $(BUILD)/bin/libsql.out "$(BUILD)/obj/sqlite3.o"
endif

#
#   manager
#
DEPS_77 += $(BUILD)/bin/libmpr.out
DEPS_77 += $(BUILD)/obj/manager.o

LIBS_77 += -lmpr

$(BUILD)/bin/appman.out: $(DEPS_77)
	@echo '      [Link] $(BUILD)/bin/appman.out'
	$(CC) -o $(BUILD)/bin/appman.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/manager.o" $(LIBPATHS_77) $(LIBS_77) $(LIBS_77) $(LIBS) -Wl,-r 

#
#   server-cache
#

src/server/cache: $(DEPS_78)
	( \
	cd src/server; \
	mkdir -p "cache" ; \
	)

#
#   installBinary
#

installBinary: $(DEPS_79)

#
#   install
#
DEPS_80 += installBinary

install: $(DEPS_80)


#
#   run
#

run: $(DEPS_81)
	( \
	cd src/server; \
	../../$(BUILD)/bin/appweb --log stdout:2 ; \
	)


#
#   uninstall
#

uninstall: $(DEPS_82)
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

version: $(DEPS_83)
	echo 5.2.1

