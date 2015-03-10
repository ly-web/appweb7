#
#   appweb-linux-default.mk -- Makefile to build Embedthis Appweb for linux
#

NAME                  := appweb
VERSION               := 5.4.0
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
ME_COM_COMPILER       ?= 1
ME_COM_DIR            ?= 1
ME_COM_EJS            ?= 0
ME_COM_ESP            ?= 1
ME_COM_EST            ?= 0
ME_COM_HTTP           ?= 1
ME_COM_LIB            ?= 1
ME_COM_MDB            ?= 1
ME_COM_MPR            ?= 1
ME_COM_OPENSSL        ?= 1
ME_COM_OSDEP          ?= 1
ME_COM_PCRE           ?= 1
ME_COM_PHP            ?= 0
ME_COM_SQLITE         ?= 0
ME_COM_SSL            ?= 1
ME_COM_VXWORKS        ?= 0
ME_COM_WINSDK         ?= 1
ME_COM_ZLIB           ?= 0

ME_COM_OPENSSL_PATH   ?= "/usr"

ifeq ($(ME_COM_EST),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_LIB),1)
    ME_COM_COMPILER := 1
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

CFLAGS                += -fPIC -w
DFLAGS                += -D_REENTRANT -DPIC $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_CGI=$(ME_COM_CGI) -DME_COM_COMPILER=$(ME_COM_COMPILER) -DME_COM_DIR=$(ME_COM_DIR) -DME_COM_EJS=$(ME_COM_EJS) -DME_COM_ESP=$(ME_COM_ESP) -DME_COM_EST=$(ME_COM_EST) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_LIB=$(ME_COM_LIB) -DME_COM_MDB=$(ME_COM_MDB) -DME_COM_MPR=$(ME_COM_MPR) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_OSDEP=$(ME_COM_OSDEP) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_PHP=$(ME_COM_PHP) -DME_COM_SQLITE=$(ME_COM_SQLITE) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_VXWORKS=$(ME_COM_VXWORKS) -DME_COM_WINSDK=$(ME_COM_WINSDK) -DME_COM_ZLIB=$(ME_COM_ZLIB) 
IFLAGS                += "-I$(BUILD)/inc"
LDFLAGS               += '-rdynamic' '-Wl,--enable-new-dtags' '-Wl,-rpath,$$ORIGIN/'
LIBPATHS              += -L$(BUILD)/bin
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
ME_WEB_PREFIX         ?= $(ME_ROOT_PREFIX)/var/www/$(NAME)
ME_LOG_PREFIX         ?= $(ME_ROOT_PREFIX)/var/log/$(NAME)
ME_SPOOL_PREFIX       ?= $(ME_ROOT_PREFIX)/var/spool/$(NAME)
ME_CACHE_PREFIX       ?= $(ME_ROOT_PREFIX)/var/spool/$(NAME)/cache
ME_SRC_PREFIX         ?= $(ME_ROOT_PREFIX)$(NAME)-$(VERSION)

WEB_USER              ?= $(shell egrep 'www-data|_www|nobody' /etc/passwd | sed 's/:.*$$$(ME_ROOT_PREFIX)/' |  tail -1)
WEB_GROUP             ?= $(shell egrep 'www-data|_www|nobody|nogroup' /etc/group | sed 's/:.*$$$(ME_ROOT_PREFIX)/' |  tail -1)

TARGETS               += init
TARGETS               += $(BUILD)/bin/appweb
TARGETS               += $(BUILD)/bin/authpass
ifeq ($(ME_COM_EJS),1)
    TARGETS           += $(BUILD)/bin/ejs.mod
endif
ifeq ($(ME_COM_EJS),1)
    TARGETS           += $(BUILD)/bin/ejs
endif
ifeq ($(ME_COM_ESP),1)
    TARGETS           += $(BUILD)/bin/esp-compile.json
endif
ifeq ($(ME_COM_ESP),1)
    TARGETS           += $(BUILD)/bin/esp
endif
TARGETS               += $(BUILD)/bin/ca.crt
ifeq ($(ME_COM_HTTP),1)
    TARGETS           += $(BUILD)/bin/http
endif
ifeq ($(ME_COM_CGI),1)
    TARGETS           += $(BUILD)/bin/libmod_cgi.so
endif
ifeq ($(ME_COM_EJS),1)
    TARGETS           += $(BUILD)/bin/libmod_ejs.so
endif
ifeq ($(ME_COM_ESP),1)
    TARGETS           += $(BUILD)/bin/libmod_esp.so
endif
ifeq ($(ME_COM_PHP),1)
    TARGETS           += $(BUILD)/bin/libmod_php.so
endif
ifeq ($(ME_COM_SSL),1)
    TARGETS           += $(BUILD)/bin/libmod_ssl.so
endif
ifeq ($(ME_COM_SQLITE),1)
    TARGETS           += $(BUILD)/bin/libsql.so
endif
TARGETS               += $(BUILD)/bin/appman
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
	rm -f "$(BUILD)/obj/espHandler.o"
	rm -f "$(BUILD)/obj/espLib.o"
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
	rm -f "$(BUILD)/bin/appweb"
	rm -f "$(BUILD)/bin/authpass"
	rm -f "$(BUILD)/bin/ejsc"
	rm -f "$(BUILD)/bin/ejs"
	rm -f "$(BUILD)/bin/esp-compile.json"
	rm -f "$(BUILD)/bin/esp"
	rm -f "$(BUILD)/bin/ca.crt"
	rm -f "$(BUILD)/bin/http"
	rm -f "$(BUILD)/bin/libappweb.so"
	rm -f "$(BUILD)/bin/libejs.so"
	rm -f "$(BUILD)/bin/libesp.so"
	rm -f "$(BUILD)/bin/libhttp.so"
	rm -f "$(BUILD)/bin/libmod_cgi.so"
	rm -f "$(BUILD)/bin/libmod_ejs.so"
	rm -f "$(BUILD)/bin/libmod_esp.so"
	rm -f "$(BUILD)/bin/libmod_php.so"
	rm -f "$(BUILD)/bin/libmod_ssl.so"
	rm -f "$(BUILD)/bin/libmpr.so"
	rm -f "$(BUILD)/bin/libmprssl.so"
	rm -f "$(BUILD)/bin/libpcre.so"
	rm -f "$(BUILD)/bin/libslink.so"
	rm -f "$(BUILD)/bin/libsql.so"
	rm -f "$(BUILD)/bin/libzlib.so"
	rm -f "$(BUILD)/bin/appman"

clobber: clean
	rm -fr ./$(BUILD)

#
#   init
#

init: $(DEPS_1)
	if [ ! -d /usr/include/openssl ] ; then echo ; \
	echo Install libssl-dev to get /usr/include/openssl ; \
	exit 255 ; \
	fi

#
#   me.h
#

$(BUILD)/inc/me.h: $(DEPS_2)

#
#   osdep.h
#
DEPS_3 += src/osdep/osdep.h
DEPS_3 += $(BUILD)/inc/me.h

$(BUILD)/inc/osdep.h: $(DEPS_3)
	@echo '      [Copy] $(BUILD)/inc/osdep.h'
	mkdir -p "$(BUILD)/inc"
	cp src/osdep/osdep.h $(BUILD)/inc/osdep.h

#
#   mpr.h
#
DEPS_4 += src/mpr/mpr.h
DEPS_4 += $(BUILD)/inc/me.h
DEPS_4 += $(BUILD)/inc/osdep.h

$(BUILD)/inc/mpr.h: $(DEPS_4)
	@echo '      [Copy] $(BUILD)/inc/mpr.h'
	mkdir -p "$(BUILD)/inc"
	cp src/mpr/mpr.h $(BUILD)/inc/mpr.h

#
#   http.h
#
DEPS_5 += src/http/http.h
DEPS_5 += $(BUILD)/inc/mpr.h

$(BUILD)/inc/http.h: $(DEPS_5)
	@echo '      [Copy] $(BUILD)/inc/http.h'
	mkdir -p "$(BUILD)/inc"
	cp src/http/http.h $(BUILD)/inc/http.h

#
#   customize.h
#

src/customize.h: $(DEPS_6)

#
#   appweb.h
#
DEPS_7 += src/appweb.h
DEPS_7 += $(BUILD)/inc/osdep.h
DEPS_7 += $(BUILD)/inc/mpr.h
DEPS_7 += $(BUILD)/inc/http.h
DEPS_7 += src/customize.h

$(BUILD)/inc/appweb.h: $(DEPS_7)
	@echo '      [Copy] $(BUILD)/inc/appweb.h'
	mkdir -p "$(BUILD)/inc"
	cp src/appweb.h $(BUILD)/inc/appweb.h

#
#   customize.h
#
DEPS_8 += src/customize.h

$(BUILD)/inc/customize.h: $(DEPS_8)
	@echo '      [Copy] $(BUILD)/inc/customize.h'
	mkdir -p "$(BUILD)/inc"
	cp src/customize.h $(BUILD)/inc/customize.h

#
#   ejs.h
#
DEPS_9 += src/ejs/ejs.h

$(BUILD)/inc/ejs.h: $(DEPS_9)
	@echo '      [Copy] $(BUILD)/inc/ejs.h'
	mkdir -p "$(BUILD)/inc"
	cp src/ejs/ejs.h $(BUILD)/inc/ejs.h

#
#   ejs.slots.h
#
DEPS_10 += src/ejs/ejs.slots.h

$(BUILD)/inc/ejs.slots.h: $(DEPS_10)
	@echo '      [Copy] $(BUILD)/inc/ejs.slots.h'
	mkdir -p "$(BUILD)/inc"
	cp src/ejs/ejs.slots.h $(BUILD)/inc/ejs.slots.h

#
#   ejsByteGoto.h
#
DEPS_11 += src/ejs/ejsByteGoto.h

$(BUILD)/inc/ejsByteGoto.h: $(DEPS_11)
	@echo '      [Copy] $(BUILD)/inc/ejsByteGoto.h'
	mkdir -p "$(BUILD)/inc"
	cp src/ejs/ejsByteGoto.h $(BUILD)/inc/ejsByteGoto.h

#
#   esp.h
#
DEPS_12 += src/esp/esp.h
DEPS_12 += $(BUILD)/inc/me.h
DEPS_12 += $(BUILD)/inc/osdep.h
DEPS_12 += $(BUILD)/inc/http.h

$(BUILD)/inc/esp.h: $(DEPS_12)
	@echo '      [Copy] $(BUILD)/inc/esp.h'
	mkdir -p "$(BUILD)/inc"
	cp src/esp/esp.h $(BUILD)/inc/esp.h

#
#   pcre.h
#
DEPS_13 += src/pcre/pcre.h

$(BUILD)/inc/pcre.h: $(DEPS_13)
	@echo '      [Copy] $(BUILD)/inc/pcre.h'
	mkdir -p "$(BUILD)/inc"
	cp src/pcre/pcre.h $(BUILD)/inc/pcre.h

#
#   sqlite3.h
#
DEPS_14 += src/sqlite/sqlite3.h

$(BUILD)/inc/sqlite3.h: $(DEPS_14)
	@echo '      [Copy] $(BUILD)/inc/sqlite3.h'
	mkdir -p "$(BUILD)/inc"
	cp src/sqlite/sqlite3.h $(BUILD)/inc/sqlite3.h

#
#   zlib.h
#
DEPS_15 += src/zlib/zlib.h

$(BUILD)/inc/zlib.h: $(DEPS_15)
	@echo '      [Copy] $(BUILD)/inc/zlib.h'
	mkdir -p "$(BUILD)/inc"
	cp src/zlib/zlib.h $(BUILD)/inc/zlib.h

#
#   appweb.o
#
DEPS_16 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/appweb.o: \
    src/server/appweb.c $(DEPS_16)
	@echo '   [Compile] $(BUILD)/obj/appweb.o'
	$(CC) -c -o $(BUILD)/obj/appweb.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/server/appweb.c

#
#   authpass.o
#
DEPS_17 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/authpass.o: \
    src/utils/authpass.c $(DEPS_17)
	@echo '   [Compile] $(BUILD)/obj/authpass.o'
	$(CC) -c -o $(BUILD)/obj/authpass.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/utils/authpass.c

#
#   cgiHandler.o
#
DEPS_18 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/cgiHandler.o: \
    src/modules/cgiHandler.c $(DEPS_18)
	@echo '   [Compile] $(BUILD)/obj/cgiHandler.o'
	$(CC) -c -o $(BUILD)/obj/cgiHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/modules/cgiHandler.c

#
#   cgiProgram.o
#

$(BUILD)/obj/cgiProgram.o: \
    src/utils/cgiProgram.c $(DEPS_19)
	@echo '   [Compile] $(BUILD)/obj/cgiProgram.o'
	$(CC) -c -o $(BUILD)/obj/cgiProgram.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/utils/cgiProgram.c

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
	$(CC) -c -o $(BUILD)/obj/config.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/config.c

#
#   convenience.o
#
DEPS_22 += src/appweb.h

$(BUILD)/obj/convenience.o: \
    src/convenience.c $(DEPS_22)
	@echo '   [Compile] $(BUILD)/obj/convenience.o'
	$(CC) -c -o $(BUILD)/obj/convenience.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/convenience.c

#
#   ejs.h
#

src/ejs/ejs.h: $(DEPS_23)

#
#   ejs.o
#
DEPS_24 += src/ejs/ejs.h

$(BUILD)/obj/ejs.o: \
    src/ejs/ejs.c $(DEPS_24)
	@echo '   [Compile] $(BUILD)/obj/ejs.o'
	$(CC) -c -o $(BUILD)/obj/ejs.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/ejs/ejs.c

#
#   ejsHandler.o
#
DEPS_25 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/ejsHandler.o: \
    src/modules/ejsHandler.c $(DEPS_25)
	@echo '   [Compile] $(BUILD)/obj/ejsHandler.o'
	$(CC) -c -o $(BUILD)/obj/ejsHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/modules/ejsHandler.c

#
#   ejsLib.o
#
DEPS_26 += src/ejs/ejs.h
DEPS_26 += $(BUILD)/inc/mpr.h
DEPS_26 += $(BUILD)/inc/pcre.h
DEPS_26 += $(BUILD)/inc/me.h

$(BUILD)/obj/ejsLib.o: \
    src/ejs/ejsLib.c $(DEPS_26)
	@echo '   [Compile] $(BUILD)/obj/ejsLib.o'
	$(CC) -c -o $(BUILD)/obj/ejsLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/ejs/ejsLib.c

#
#   ejsc.o
#
DEPS_27 += src/ejs/ejs.h

$(BUILD)/obj/ejsc.o: \
    src/ejs/ejsc.c $(DEPS_27)
	@echo '   [Compile] $(BUILD)/obj/ejsc.o'
	$(CC) -c -o $(BUILD)/obj/ejsc.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/ejs/ejsc.c

#
#   esp.h
#

src/esp/esp.h: $(DEPS_28)

#
#   esp.o
#
DEPS_29 += src/esp/esp.h

$(BUILD)/obj/esp.o: \
    src/esp/esp.c $(DEPS_29)
	@echo '   [Compile] $(BUILD)/obj/esp.o'
	$(CC) -c -o $(BUILD)/obj/esp.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/esp.c

#
#   espHandler.o
#
DEPS_30 += $(BUILD)/inc/appweb.h
DEPS_30 += $(BUILD)/inc/esp.h

$(BUILD)/obj/espHandler.o: \
    src/modules/espHandler.c $(DEPS_30)
	@echo '   [Compile] $(BUILD)/obj/espHandler.o'
	$(CC) -c -o $(BUILD)/obj/espHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/modules/espHandler.c

#
#   espLib.o
#
DEPS_31 += src/esp/esp.h
DEPS_31 += $(BUILD)/inc/pcre.h
DEPS_31 += $(BUILD)/inc/http.h

$(BUILD)/obj/espLib.o: \
    src/esp/espLib.c $(DEPS_31)
	@echo '   [Compile] $(BUILD)/obj/espLib.o'
	$(CC) -c -o $(BUILD)/obj/espLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/esp/espLib.c

#
#   http.h
#

src/http/http.h: $(DEPS_32)

#
#   http.o
#
DEPS_33 += src/http/http.h

$(BUILD)/obj/http.o: \
    src/http/http.c $(DEPS_33)
	@echo '   [Compile] $(BUILD)/obj/http.o'
	$(CC) -c -o $(BUILD)/obj/http.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/http/http.c

#
#   httpLib.o
#
DEPS_34 += src/http/http.h

$(BUILD)/obj/httpLib.o: \
    src/http/httpLib.c $(DEPS_34)
	@echo '   [Compile] $(BUILD)/obj/httpLib.o'
	$(CC) -c -o $(BUILD)/obj/httpLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/http/httpLib.c

#
#   mpr.h
#

src/mpr/mpr.h: $(DEPS_35)

#
#   makerom.o
#
DEPS_36 += src/mpr/mpr.h

$(BUILD)/obj/makerom.o: \
    src/mpr/makerom.c $(DEPS_36)
	@echo '   [Compile] $(BUILD)/obj/makerom.o'
	$(CC) -c -o $(BUILD)/obj/makerom.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/mpr/makerom.c

#
#   manager.o
#
DEPS_37 += src/mpr/mpr.h

$(BUILD)/obj/manager.o: \
    src/mpr/manager.c $(DEPS_37)
	@echo '   [Compile] $(BUILD)/obj/manager.o'
	$(CC) -c -o $(BUILD)/obj/manager.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/mpr/manager.c

#
#   mprLib.o
#
DEPS_38 += src/mpr/mpr.h

$(BUILD)/obj/mprLib.o: \
    src/mpr/mprLib.c $(DEPS_38)
	@echo '   [Compile] $(BUILD)/obj/mprLib.o'
	$(CC) -c -o $(BUILD)/obj/mprLib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/mpr/mprLib.c

#
#   mprSsl.o
#
DEPS_39 += src/mpr/mpr.h

$(BUILD)/obj/mprSsl.o: \
    src/mpr/mprSsl.c $(DEPS_39)
	@echo '   [Compile] $(BUILD)/obj/mprSsl.o'
	$(CC) -c -o $(BUILD)/obj/mprSsl.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/mpr/mprSsl.c

#
#   pcre.h
#

src/pcre/pcre.h: $(DEPS_40)

#
#   pcre.o
#
DEPS_41 += $(BUILD)/inc/me.h
DEPS_41 += src/pcre/pcre.h

$(BUILD)/obj/pcre.o: \
    src/pcre/pcre.c $(DEPS_41)
	@echo '   [Compile] $(BUILD)/obj/pcre.o'
	$(CC) -c -o $(BUILD)/obj/pcre.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/pcre/pcre.c

#
#   phpHandler.o
#
DEPS_42 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/phpHandler.o: \
    src/modules/phpHandler.c $(DEPS_42)
	@echo '   [Compile] $(BUILD)/obj/phpHandler.o'
	$(CC) -c -o $(BUILD)/obj/phpHandler.o $(CFLAGS) $(DFLAGS) $(IFLAGS) "-I$(ME_COM_PHP_PATH)" "-I$(ME_COM_PHP_PATH)/main" "-I$(ME_COM_PHP_PATH)/Zend" "-I$(ME_COM_PHP_PATH)/TSRM" src/modules/phpHandler.c

#
#   slink.o
#
DEPS_43 += $(BUILD)/inc/mpr.h
DEPS_43 += $(BUILD)/inc/esp.h

$(BUILD)/obj/slink.o: \
    src/server/slink.c $(DEPS_43)
	@echo '   [Compile] $(BUILD)/obj/slink.o'
	$(CC) -c -o $(BUILD)/obj/slink.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/server/slink.c

#
#   sqlite3.h
#

src/sqlite/sqlite3.h: $(DEPS_44)

#
#   sqlite.o
#
DEPS_45 += $(BUILD)/inc/me.h
DEPS_45 += src/sqlite/sqlite3.h

$(BUILD)/obj/sqlite.o: \
    src/sqlite/sqlite.c $(DEPS_45)
	@echo '   [Compile] $(BUILD)/obj/sqlite.o'
	$(CC) -c -o $(BUILD)/obj/sqlite.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/sqlite/sqlite.c

#
#   sqlite3.o
#
DEPS_46 += $(BUILD)/inc/me.h
DEPS_46 += src/sqlite/sqlite3.h

$(BUILD)/obj/sqlite3.o: \
    src/sqlite/sqlite3.c $(DEPS_46)
	@echo '   [Compile] $(BUILD)/obj/sqlite3.o'
	$(CC) -c -o $(BUILD)/obj/sqlite3.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/sqlite/sqlite3.c

#
#   sslModule.o
#
DEPS_47 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/sslModule.o: \
    src/modules/sslModule.c $(DEPS_47)
	@echo '   [Compile] $(BUILD)/obj/sslModule.o'
	$(CC) -c -o $(BUILD)/obj/sslModule.o $(CFLAGS) $(DFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/modules/sslModule.c

#
#   zlib.h
#

src/zlib/zlib.h: $(DEPS_48)

#
#   zlib.o
#
DEPS_49 += $(BUILD)/inc/me.h
DEPS_49 += src/zlib/zlib.h

$(BUILD)/obj/zlib.o: \
    src/zlib/zlib.c $(DEPS_49)
	@echo '   [Compile] $(BUILD)/obj/zlib.o'
	$(CC) -c -o $(BUILD)/obj/zlib.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/zlib/zlib.c

#
#   libmpr
#
DEPS_50 += $(BUILD)/inc/osdep.h
DEPS_50 += $(BUILD)/inc/mpr.h
DEPS_50 += $(BUILD)/obj/mprLib.o

$(BUILD)/bin/libmpr.so: $(DEPS_50)
	@echo '      [Link] $(BUILD)/bin/libmpr.so'
	$(CC) -shared -o $(BUILD)/bin/libmpr.so $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/mprLib.o" $(LIBS) 

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_51 += $(BUILD)/inc/pcre.h
DEPS_51 += $(BUILD)/obj/pcre.o

$(BUILD)/bin/libpcre.so: $(DEPS_51)
	@echo '      [Link] $(BUILD)/bin/libpcre.so'
	$(CC) -shared -o $(BUILD)/bin/libpcre.so $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/pcre.o" $(LIBS) 
endif

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_52 += $(BUILD)/bin/libmpr.so
ifeq ($(ME_COM_PCRE),1)
    DEPS_52 += $(BUILD)/bin/libpcre.so
endif
DEPS_52 += $(BUILD)/inc/http.h
DEPS_52 += $(BUILD)/obj/httpLib.o

LIBS_52 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_52 += -lpcre
endif

$(BUILD)/bin/libhttp.so: $(DEPS_52)
	@echo '      [Link] $(BUILD)/bin/libhttp.so'
	$(CC) -shared -o $(BUILD)/bin/libhttp.so $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/httpLib.o" $(LIBPATHS_52) $(LIBS_52) $(LIBS_52) $(LIBS) 
endif

#
#   libappweb
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_53 += $(BUILD)/bin/libhttp.so
endif
DEPS_53 += $(BUILD)/bin/libmpr.so
DEPS_53 += $(BUILD)/inc/appweb.h
DEPS_53 += $(BUILD)/inc/customize.h
DEPS_53 += $(BUILD)/obj/config.o
DEPS_53 += $(BUILD)/obj/convenience.o

ifeq ($(ME_COM_HTTP),1)
    LIBS_53 += -lhttp
endif
LIBS_53 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_53 += -lpcre
endif

$(BUILD)/bin/libappweb.so: $(DEPS_53)
	@echo '      [Link] $(BUILD)/bin/libappweb.so'
	$(CC) -shared -o $(BUILD)/bin/libappweb.so $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/config.o" "$(BUILD)/obj/convenience.o" $(LIBPATHS_53) $(LIBS_53) $(LIBS_53) $(LIBS) 

#
#   libslink
#
DEPS_54 += $(BUILD)/obj/slink.o

$(BUILD)/bin/libslink.so: $(DEPS_54)
	@echo '      [Link] $(BUILD)/bin/libslink.so'
	$(CC) -shared -o $(BUILD)/bin/libslink.so $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/slink.o" $(LIBS) 

#
#   appweb
#
DEPS_55 += $(BUILD)/bin/libappweb.so
DEPS_55 += $(BUILD)/bin/libslink.so
DEPS_55 += $(BUILD)/obj/appweb.o

LIBS_55 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_55 += -lhttp
endif
LIBS_55 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_55 += -lpcre
endif
LIBS_55 += -lslink

$(BUILD)/bin/appweb: $(DEPS_55)
	@echo '      [Link] $(BUILD)/bin/appweb'
	$(CC) -o $(BUILD)/bin/appweb $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/appweb.o" $(LIBPATHS_55) $(LIBS_55) $(LIBS_55) $(LIBS) $(LIBS) 

#
#   authpass
#
DEPS_56 += $(BUILD)/bin/libappweb.so
DEPS_56 += $(BUILD)/obj/authpass.o

LIBS_56 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_56 += -lhttp
endif
LIBS_56 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_56 += -lpcre
endif

$(BUILD)/bin/authpass: $(DEPS_56)
	@echo '      [Link] $(BUILD)/bin/authpass'
	$(CC) -o $(BUILD)/bin/authpass $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/authpass.o" $(LIBPATHS_56) $(LIBS_56) $(LIBS_56) $(LIBS) $(LIBS) 

ifeq ($(ME_COM_ZLIB),1)
#
#   libzlib
#
DEPS_57 += $(BUILD)/inc/zlib.h
DEPS_57 += $(BUILD)/obj/zlib.o

$(BUILD)/bin/libzlib.so: $(DEPS_57)
	@echo '      [Link] $(BUILD)/bin/libzlib.so'
	$(CC) -shared -o $(BUILD)/bin/libzlib.so $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/zlib.o" $(LIBS) 
endif

ifeq ($(ME_COM_EJS),1)
#
#   libejs
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_58 += $(BUILD)/bin/libhttp.so
endif
ifeq ($(ME_COM_PCRE),1)
    DEPS_58 += $(BUILD)/bin/libpcre.so
endif
DEPS_58 += $(BUILD)/bin/libmpr.so
ifeq ($(ME_COM_ZLIB),1)
    DEPS_58 += $(BUILD)/bin/libzlib.so
endif
DEPS_58 += $(BUILD)/inc/ejs.h
DEPS_58 += $(BUILD)/inc/ejs.slots.h
DEPS_58 += $(BUILD)/inc/ejsByteGoto.h
DEPS_58 += $(BUILD)/obj/ejsLib.o

ifeq ($(ME_COM_HTTP),1)
    LIBS_58 += -lhttp
endif
LIBS_58 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_58 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_58 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_58 += -lsql
endif

$(BUILD)/bin/libejs.so: $(DEPS_58)
	@echo '      [Link] $(BUILD)/bin/libejs.so'
	$(CC) -shared -o $(BUILD)/bin/libejs.so $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/ejsLib.o" $(LIBPATHS_58) $(LIBS_58) $(LIBS_58) $(LIBS) 
endif

ifeq ($(ME_COM_EJS),1)
#
#   ejsc
#
DEPS_59 += $(BUILD)/bin/libejs.so
DEPS_59 += $(BUILD)/obj/ejsc.o

LIBS_59 += -lejs
ifeq ($(ME_COM_HTTP),1)
    LIBS_59 += -lhttp
endif
LIBS_59 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_59 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_59 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_59 += -lsql
endif

$(BUILD)/bin/ejsc: $(DEPS_59)
	@echo '      [Link] $(BUILD)/bin/ejsc'
	$(CC) -o $(BUILD)/bin/ejsc $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/ejsc.o" $(LIBPATHS_59) $(LIBS_59) $(LIBS_59) $(LIBS) $(LIBS) 
endif

ifeq ($(ME_COM_EJS),1)
#
#   ejs.mod
#
DEPS_60 += src/ejs/ejs.es
DEPS_60 += $(BUILD)/bin/ejsc

$(BUILD)/bin/ejs.mod: $(DEPS_60)
	( \
	cd src/ejs; \
	echo '   [Compile] ejs.mod' ; \
	../../$(BUILD)/bin/ejsc --out ../../$(BUILD)/bin/ejs.mod --optimize 9 --bind --require null ejs.es ; \
	)
endif

ifeq ($(ME_COM_EJS),1)
#
#   ejscmd
#
DEPS_61 += $(BUILD)/bin/libejs.so
DEPS_61 += $(BUILD)/obj/ejs.o

LIBS_61 += -lejs
ifeq ($(ME_COM_HTTP),1)
    LIBS_61 += -lhttp
endif
LIBS_61 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_61 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_61 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_61 += -lsql
endif

$(BUILD)/bin/ejs: $(DEPS_61)
	@echo '      [Link] $(BUILD)/bin/ejs'
	$(CC) -o $(BUILD)/bin/ejs $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/ejs.o" $(LIBPATHS_61) $(LIBS_61) $(LIBS_61) $(LIBS) $(LIBS) 
endif

ifeq ($(ME_COM_ESP),1)
#
#   esp-compile.json
#
DEPS_62 += src/esp/esp-compile.json

$(BUILD)/bin/esp-compile.json: $(DEPS_62)
	@echo '      [Copy] $(BUILD)/bin/esp-compile.json'
	mkdir -p "$(BUILD)/bin"
	cp src/esp/esp-compile.json $(BUILD)/bin/esp-compile.json
endif

ifeq ($(ME_COM_ESP),1)
#
#   libesp
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_63 += $(BUILD)/bin/libhttp.so
endif
DEPS_63 += $(BUILD)/inc/esp.h
DEPS_63 += $(BUILD)/obj/espLib.o

ifeq ($(ME_COM_HTTP),1)
    LIBS_63 += -lhttp
endif
LIBS_63 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_63 += -lpcre
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_63 += -lsql
endif

$(BUILD)/bin/libesp.so: $(DEPS_63)
	@echo '      [Link] $(BUILD)/bin/libesp.so'
	$(CC) -shared -o $(BUILD)/bin/libesp.so $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/espLib.o" $(LIBPATHS_63) $(LIBS_63) $(LIBS_63) $(LIBS) 
endif

ifeq ($(ME_COM_ESP),1)
#
#   espcmd
#
DEPS_64 += $(BUILD)/bin/libesp.so
DEPS_64 += $(BUILD)/obj/esp.o

LIBS_64 += -lesp
ifeq ($(ME_COM_HTTP),1)
    LIBS_64 += -lhttp
endif
LIBS_64 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_64 += -lpcre
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_64 += -lsql
endif

$(BUILD)/bin/esp: $(DEPS_64)
	@echo '      [Link] $(BUILD)/bin/esp'
	$(CC) -o $(BUILD)/bin/esp $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/esp.o" $(LIBPATHS_64) $(LIBS_64) $(LIBS_64) $(LIBS) $(LIBS) 
endif

ifeq ($(ME_COM_ESP),1)
#
#   genslink
#
DEPS_65 += $(BUILD)/bin/libesp.so

genslink: $(DEPS_65)
	( \
	cd src/server; \
	echo '    [Create] slink.c' ; \
	esp --static --genlink slink.c compile ; \
	)
endif

#
#   http-ca-crt
#
DEPS_66 += src/http/ca.crt

$(BUILD)/bin/ca.crt: $(DEPS_66)
	@echo '      [Copy] $(BUILD)/bin/ca.crt'
	mkdir -p "$(BUILD)/bin"
	cp src/http/ca.crt $(BUILD)/bin/ca.crt

ifeq ($(ME_COM_HTTP),1)
#
#   httpcmd
#
DEPS_67 += $(BUILD)/bin/libhttp.so
DEPS_67 += $(BUILD)/obj/http.o

LIBS_67 += -lhttp
LIBS_67 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_67 += -lpcre
endif

$(BUILD)/bin/http: $(DEPS_67)
	@echo '      [Link] $(BUILD)/bin/http'
	$(CC) -o $(BUILD)/bin/http $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/http.o" $(LIBPATHS_67) $(LIBS_67) $(LIBS_67) $(LIBS) $(LIBS) 
endif

ifeq ($(ME_COM_CGI),1)
#
#   libmod_cgi
#
DEPS_68 += $(BUILD)/bin/libappweb.so
DEPS_68 += $(BUILD)/obj/cgiHandler.o

LIBS_68 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_68 += -lhttp
endif
LIBS_68 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_68 += -lpcre
endif

$(BUILD)/bin/libmod_cgi.so: $(DEPS_68)
	@echo '      [Link] $(BUILD)/bin/libmod_cgi.so'
	$(CC) -shared -o $(BUILD)/bin/libmod_cgi.so $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/cgiHandler.o" $(LIBPATHS_68) $(LIBS_68) $(LIBS_68) $(LIBS) 
endif

ifeq ($(ME_COM_EJS),1)
#
#   libmod_ejs
#
DEPS_69 += $(BUILD)/bin/libappweb.so
DEPS_69 += $(BUILD)/bin/libejs.so
DEPS_69 += $(BUILD)/obj/ejsHandler.o

LIBS_69 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_69 += -lhttp
endif
LIBS_69 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_69 += -lpcre
endif
LIBS_69 += -lejs
ifeq ($(ME_COM_ZLIB),1)
    LIBS_69 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_69 += -lsql
endif

$(BUILD)/bin/libmod_ejs.so: $(DEPS_69)
	@echo '      [Link] $(BUILD)/bin/libmod_ejs.so'
	$(CC) -shared -o $(BUILD)/bin/libmod_ejs.so $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/ejsHandler.o" $(LIBPATHS_69) $(LIBS_69) $(LIBS_69) $(LIBS) 
endif

ifeq ($(ME_COM_ESP),1)
#
#   libmod_esp
#
DEPS_70 += $(BUILD)/bin/libappweb.so
DEPS_70 += $(BUILD)/bin/libesp.so
DEPS_70 += $(BUILD)/obj/espHandler.o

LIBS_70 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_70 += -lhttp
endif
LIBS_70 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_70 += -lpcre
endif
LIBS_70 += -lesp
ifeq ($(ME_COM_SQLITE),1)
    LIBS_70 += -lsql
endif

$(BUILD)/bin/libmod_esp.so: $(DEPS_70)
	@echo '      [Link] $(BUILD)/bin/libmod_esp.so'
	$(CC) -shared -o $(BUILD)/bin/libmod_esp.so $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/espHandler.o" $(LIBPATHS_70) $(LIBS_70) $(LIBS_70) $(LIBS) 
endif

ifeq ($(ME_COM_PHP),1)
#
#   libmod_php
#
DEPS_71 += $(BUILD)/bin/libappweb.so
DEPS_71 += $(BUILD)/obj/phpHandler.o

LIBS_71 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_71 += -lhttp
endif
LIBS_71 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_71 += -lpcre
endif
LIBS_71 += -lphp5
LIBPATHS_71 += -L"$(ME_COM_PHP_PATH)/libs"

$(BUILD)/bin/libmod_php.so: $(DEPS_71)
	@echo '      [Link] $(BUILD)/bin/libmod_php.so'
	$(CC) -shared -o $(BUILD)/bin/libmod_php.so $(LDFLAGS) $(LIBPATHS)  "$(BUILD)/obj/phpHandler.o" $(LIBPATHS_71) $(LIBS_71) $(LIBS_71) $(LIBS) 
endif

#
#   libmprssl
#
DEPS_72 += $(BUILD)/bin/libmpr.so
DEPS_72 += $(BUILD)/obj/mprSsl.o

LIBS_72 += -lmpr
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_72 += -lssl
    LIBPATHS_72 += -L"$(ME_COM_OPENSSL_PATH)/lib"
    LIBPATHS_72 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_72 += -lcrypto
    LIBPATHS_72 += -L"$(ME_COM_OPENSSL_PATH)/lib"
    LIBPATHS_72 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_72 += -lest
endif

$(BUILD)/bin/libmprssl.so: $(DEPS_72)
	@echo '      [Link] $(BUILD)/bin/libmprssl.so'
	$(CC) -shared -o $(BUILD)/bin/libmprssl.so $(LDFLAGS) $(LIBPATHS)   "$(BUILD)/obj/mprSsl.o" $(LIBPATHS_72) $(LIBS_72) $(LIBS_72) $(LIBS) 

ifeq ($(ME_COM_SSL),1)
#
#   libmod_ssl
#
DEPS_73 += $(BUILD)/bin/libappweb.so
DEPS_73 += $(BUILD)/bin/libmprssl.so
DEPS_73 += $(BUILD)/obj/sslModule.o

LIBS_73 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_73 += -lhttp
endif
LIBS_73 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_73 += -lpcre
endif
LIBS_73 += -lmprssl
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_73 += -lssl
    LIBPATHS_73 += -L"$(ME_COM_OPENSSL_PATH)/lib"
    LIBPATHS_73 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_73 += -lcrypto
    LIBPATHS_73 += -L"$(ME_COM_OPENSSL_PATH)/lib"
    LIBPATHS_73 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_73 += -lest
endif

$(BUILD)/bin/libmod_ssl.so: $(DEPS_73)
	@echo '      [Link] $(BUILD)/bin/libmod_ssl.so'
	$(CC) -shared -o $(BUILD)/bin/libmod_ssl.so $(LDFLAGS) $(LIBPATHS)   "$(BUILD)/obj/sslModule.o" $(LIBPATHS_73) $(LIBS_73) $(LIBS_73) $(LIBS) 
endif

ifeq ($(ME_COM_SQLITE),1)
#
#   libsql
#
DEPS_74 += $(BUILD)/inc/sqlite3.h
DEPS_74 += $(BUILD)/obj/sqlite3.o

$(BUILD)/bin/libsql.so: $(DEPS_74)
	@echo '      [Link] $(BUILD)/bin/libsql.so'
	$(CC) -shared -o $(BUILD)/bin/libsql.so $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/sqlite3.o" $(LIBS) 
endif

#
#   manager
#
DEPS_75 += $(BUILD)/bin/libmpr.so
DEPS_75 += $(BUILD)/obj/manager.o

LIBS_75 += -lmpr

$(BUILD)/bin/appman: $(DEPS_75)
	@echo '      [Link] $(BUILD)/bin/appman'
	$(CC) -o $(BUILD)/bin/appman $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/manager.o" $(LIBPATHS_75) $(LIBS_75) $(LIBS_75) $(LIBS) $(LIBS) 

#
#   server-cache
#

src/server/cache: $(DEPS_76)
	( \
	cd src/server; \
	mkdir -p "cache" ; \
	)


#
#   stop
#

stop: $(DEPS_77)
	@./$(BUILD)/bin/appman stop disable uninstall >/dev/null 2>&1 ; true

#
#   installBinary
#

installBinary: $(DEPS_78)
	mkdir -p "$(ME_APP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	ln -s "5.4.0" "$(ME_APP_PREFIX)/latest" ; \
	mkdir -p "$(ME_LOG_PREFIX)" ; \
	chmod 755 "$(ME_LOG_PREFIX)" ; \
	[ `id -u` = 0 ] && chown nobody:nogroup "$(ME_LOG_PREFIX)"; true ; \
	mkdir -p "$(ME_CACHE_PREFIX)" ; \
	chmod 755 "$(ME_CACHE_PREFIX)" ; \
	[ `id -u` = 0 ] && chown nobody:nogroup "$(ME_CACHE_PREFIX)"; true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/appweb $(ME_VAPP_PREFIX)/bin/appweb ; \
	mkdir -p "$(ME_BIN_PREFIX)" ; \
	rm -f "$(ME_BIN_PREFIX)/appweb" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/appweb" "$(ME_BIN_PREFIX)/appweb" ; \
	if [ "$(ME_COM_SSL)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp src/est/ca.crt $(ME_VAPP_PREFIX)/bin/ca.crt ; \
	fi ; \
	if [ "$(ME_COM_PHP)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libphp5.so $(ME_VAPP_PREFIX)/bin/libphp5.so ; \
	fi ; \
	mkdir -p "$(ME_ETC_PREFIX)" ; \
	cp src/server/mime.types $(ME_ETC_PREFIX)/mime.types ; \
	mkdir -p "$(ME_ETC_PREFIX)" ; \
	cp src/server/self.crt $(ME_ETC_PREFIX)/self.crt ; \
	cp src/server/self.key $(ME_ETC_PREFIX)/self.key ; \
	mkdir -p "$(ME_ETC_PREFIX)" ; \
	cp src/server/appweb.conf $(ME_ETC_PREFIX)/appweb.conf ; \
	mkdir -p "$(ME_ETC_PREFIX)" ; \
	cp src/server/sample.conf $(ME_ETC_PREFIX)/sample.conf ; \
	mkdir -p "$(ME_ETC_PREFIX)" ; \
	cp src/server/self.crt $(ME_ETC_PREFIX)/self.crt ; \
	cp src/server/self.key $(ME_ETC_PREFIX)/self.key ; \
	echo 'set LOG_DIR "$(ME_LOG_PREFIX)"\nset CACHE_DIR "$(ME_CACHE_PREFIX)"\nDocuments "$(ME_WEB_PREFIX)\nListen 80\n<if SSL_MODULE>\nListenSecure 443\n</if>\n' >$(ME_ETC_PREFIX)/install.conf ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libappweb.so $(ME_VAPP_PREFIX)/bin/libappweb.so ; \
	cp $(BUILD)/bin/libesp.so $(ME_VAPP_PREFIX)/bin/libesp.so ; \
	cp $(BUILD)/bin/libhttp.so $(ME_VAPP_PREFIX)/bin/libhttp.so ; \
	cp $(BUILD)/bin/libmpr.so $(ME_VAPP_PREFIX)/bin/libmpr.so ; \
	cp $(BUILD)/bin/libpcre.so $(ME_VAPP_PREFIX)/bin/libpcre.so ; \
	cp $(BUILD)/bin/libslink.so $(ME_VAPP_PREFIX)/bin/libslink.so ; \
	if [ "$(ME_COM_SSL)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libmprssl.so $(ME_VAPP_PREFIX)/bin/libmprssl.so ; \
	cp $(BUILD)/bin/libmod_ssl.so $(ME_VAPP_PREFIX)/bin/libmod_ssl.so ; \
	fi ; \
	if [ "$(ME_COM_EST)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libest.so $(ME_VAPP_PREFIX)/bin/libest.so ; \
	fi ; \
	if [ "$(ME_COM_SQLITE)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libsql.so $(ME_VAPP_PREFIX)/bin/libsql.so ; \
	fi ; \
	if [ "$(ME_COM_ESP)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libmod_esp.so $(ME_VAPP_PREFIX)/bin/libmod_esp.so ; \
	fi ; \
	if [ "$(ME_COM_CGI)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libmod_cgi.so $(ME_VAPP_PREFIX)/bin/libmod_cgi.so ; \
	fi ; \
	if [ "$(ME_COM_EJS)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libejs.so $(ME_VAPP_PREFIX)/bin/libejs.so ; \
	cp $(BUILD)/bin/libmod_ejs.so $(ME_VAPP_PREFIX)/bin/libmod_ejs.so ; \
	cp $(BUILD)/bin/libzlib.so $(ME_VAPP_PREFIX)/bin/libzlib.so ; \
	fi ; \
	if [ "$(ME_COM_PHP)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libmod_php.so $(ME_VAPP_PREFIX)/bin/libmod_php.so ; \
	fi ; \
	mkdir -p "$(ME_WEB_PREFIX)" ; \
	mkdir -p "$(ME_WEB_PREFIX)/bench" ; \
	cp src/server/web/bench/1b.html $(ME_WEB_PREFIX)/bench/1b.html ; \
	cp src/server/web/bench/4k.html $(ME_WEB_PREFIX)/bench/4k.html ; \
	cp src/server/web/bench/64k.html $(ME_WEB_PREFIX)/bench/64k.html ; \
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
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/appman $(ME_VAPP_PREFIX)/bin/appman ; \
	mkdir -p "$(ME_BIN_PREFIX)" ; \
	rm -f "$(ME_BIN_PREFIX)/appman" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/appman" "$(ME_BIN_PREFIX)/appman" ; \
	mkdir -p "$(ME_ROOT_PREFIX)/etc/init.d" ; \
	cp installs/linux/appweb.init $(ME_ROOT_PREFIX)/etc/init.d/appweb ; \
	chmod 755 "$(ME_ROOT_PREFIX)/etc/init.d/appweb" ; \
	if [ "$(ME_COM_ESP)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/esp $(ME_VAPP_PREFIX)/bin/appesp ; \
	mkdir -p "$(ME_BIN_PREFIX)" ; \
	rm -f "$(ME_BIN_PREFIX)/appesp" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/appesp" "$(ME_BIN_PREFIX)/appesp" ; \
	fi ; \
	if [ "$(ME_COM_ESP)" = 1 ]; then true ; \
	fi ; \
	if [ "$(ME_COM_ESP)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/esp-compile.json $(ME_VAPP_PREFIX)/bin/esp-compile.json ; \
	fi ; \
	if [ "$(ME_COM_EJS)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/ejs.mod $(ME_VAPP_PREFIX)/bin/ejs.mod ; \
	fi ; \
	if [ "$(ME_COM_PHP)" = 1 ]; then true ; \
	mkdir -p "$(ME_ETC_PREFIX)" ; \
	cp src/server/php.ini $(ME_ETC_PREFIX)/php.ini ; \
	fi ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/http $(ME_VAPP_PREFIX)/bin/http ; \
	mkdir -p "$(ME_VAPP_PREFIX)/inc" ; \
	cp $(BUILD)/inc/me.h $(ME_VAPP_PREFIX)/inc/me.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/me.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/me.h" "$(ME_INC_PREFIX)/appweb/me.h" ; \
	cp src/osdep/osdep.h $(ME_VAPP_PREFIX)/inc/osdep.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/osdep.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/osdep.h" "$(ME_INC_PREFIX)/appweb/osdep.h" ; \
	cp src/appweb.h $(ME_VAPP_PREFIX)/inc/appweb.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/appweb.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/appweb.h" "$(ME_INC_PREFIX)/appweb/appweb.h" ; \
	cp src/customize.h $(ME_VAPP_PREFIX)/inc/customize.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/customize.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/customize.h" "$(ME_INC_PREFIX)/appweb/customize.h" ; \
	cp src/est/est.h $(ME_VAPP_PREFIX)/inc/est.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/est.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/est.h" "$(ME_INC_PREFIX)/appweb/est.h" ; \
	cp src/http/http.h $(ME_VAPP_PREFIX)/inc/http.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/http.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/http.h" "$(ME_INC_PREFIX)/appweb/http.h" ; \
	cp src/mpr/mpr.h $(ME_VAPP_PREFIX)/inc/mpr.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/mpr.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/mpr.h" "$(ME_INC_PREFIX)/appweb/mpr.h" ; \
	cp src/pcre/pcre.h $(ME_VAPP_PREFIX)/inc/pcre.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/pcre.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/pcre.h" "$(ME_INC_PREFIX)/appweb/pcre.h" ; \
	cp src/sqlite/sqlite3.h $(ME_VAPP_PREFIX)/inc/sqlite3.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/sqlite3.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/sqlite3.h" "$(ME_INC_PREFIX)/appweb/sqlite3.h" ; \
	if [ "$(ME_COM_ESP)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/inc" ; \
	cp src/esp/esp.h $(ME_VAPP_PREFIX)/inc/esp.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/esp.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/esp.h" "$(ME_INC_PREFIX)/appweb/esp.h" ; \
	fi ; \
	if [ "$(ME_COM_EJS)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/inc" ; \
	cp src/ejs/ejs.h $(ME_VAPP_PREFIX)/inc/ejs.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/ejs.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/ejs.h" "$(ME_INC_PREFIX)/appweb/ejs.h" ; \
	cp src/ejs/ejs.slots.h $(ME_VAPP_PREFIX)/inc/ejs.slots.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/ejs.slots.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/ejs.slots.h" "$(ME_INC_PREFIX)/appweb/ejs.slots.h" ; \
	cp src/ejs/ejsByteGoto.h $(ME_VAPP_PREFIX)/inc/ejsByteGoto.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/ejsByteGoto.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/ejsByteGoto.h" "$(ME_INC_PREFIX)/appweb/ejsByteGoto.h" ; \
	fi ; \
	mkdir -p "$(ME_VAPP_PREFIX)/doc/man1" ; \
	cp doc/dist/man/appman.1 $(ME_VAPP_PREFIX)/doc/man1/appman.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/appman.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/appman.1" "$(ME_MAN_PREFIX)/man1/appman.1" ; \
	cp doc/dist/man/appweb.1 $(ME_VAPP_PREFIX)/doc/man1/appweb.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/appweb.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/appweb.1" "$(ME_MAN_PREFIX)/man1/appweb.1" ; \
	cp doc/dist/man/appwebMonitor.1 $(ME_VAPP_PREFIX)/doc/man1/appwebMonitor.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/appwebMonitor.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/appwebMonitor.1" "$(ME_MAN_PREFIX)/man1/appwebMonitor.1" ; \
	cp doc/dist/man/authpass.1 $(ME_VAPP_PREFIX)/doc/man1/authpass.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/authpass.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/authpass.1" "$(ME_MAN_PREFIX)/man1/authpass.1" ; \
	cp doc/dist/man/esp.1 $(ME_VAPP_PREFIX)/doc/man1/esp.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/esp.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/esp.1" "$(ME_MAN_PREFIX)/man1/esp.1" ; \
	cp doc/dist/man/http.1 $(ME_VAPP_PREFIX)/doc/man1/http.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/http.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/http.1" "$(ME_MAN_PREFIX)/man1/http.1" ; \
	cp doc/dist/man/makerom.1 $(ME_VAPP_PREFIX)/doc/man1/makerom.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/makerom.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/makerom.1" "$(ME_MAN_PREFIX)/man1/makerom.1" ; \
	cp doc/dist/man/manager.1 $(ME_VAPP_PREFIX)/doc/man1/manager.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/manager.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/manager.1" "$(ME_MAN_PREFIX)/man1/manager.1"

#
#   start
#
DEPS_79 += stop

start: $(DEPS_79)
	./$(BUILD)/bin/appman install enable start

#
#   install
#
DEPS_80 += stop
DEPS_80 += installBinary
DEPS_80 += start

install: $(DEPS_80)

#
#   installPrep
#

installPrep: $(DEPS_81)
	if [ "`id -u`" != 0 ] ; \
	then echo "Must run as root. Rerun with "sudo"" ; \
	exit 255 ; \
	fi

#
#   run
#

run: $(DEPS_82)
	( \
	cd src/server; \
	../../$(BUILD)/bin/appweb --log stdout:2 ; \
	)


#
#   uninstall
#
DEPS_83 += stop

uninstall: $(DEPS_83)
	( \
	cd installs; \
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
	rm -f "$(ME_ETC_PREFIX)/appweb.conf" ; \
	rm -f "$(ME_ETC_PREFIX)/esp.conf" ; \
	rm -f "$(ME_ETC_PREFIX)/mine.types" ; \
	rm -f "$(ME_ETC_PREFIX)/install.conf" ; \
	rm -fr "$(ME_INC_PREFIX)/appweb" ; \
	)

#
#   version
#

version: $(DEPS_84)
	echo 5.4.0

