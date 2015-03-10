#
#   appweb-macosx-static.mk -- Makefile to build Embedthis Appweb for macosx
#

NAME                  := appweb
VERSION               := 5.4.0
PROFILE               ?= static
ARCH                  ?= $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/')
CC_ARCH               ?= $(shell echo $(ARCH) | sed 's/x86/i686/;s/x64/x86_64/')
OS                    ?= macosx
CC                    ?= clang
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

CFLAGS                += -g -w
DFLAGS                +=  $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_CGI=$(ME_COM_CGI) -DME_COM_COMPILER=$(ME_COM_COMPILER) -DME_COM_DIR=$(ME_COM_DIR) -DME_COM_EJS=$(ME_COM_EJS) -DME_COM_ESP=$(ME_COM_ESP) -DME_COM_EST=$(ME_COM_EST) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_LIB=$(ME_COM_LIB) -DME_COM_MDB=$(ME_COM_MDB) -DME_COM_MPR=$(ME_COM_MPR) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_OSDEP=$(ME_COM_OSDEP) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_PHP=$(ME_COM_PHP) -DME_COM_SQLITE=$(ME_COM_SQLITE) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_VXWORKS=$(ME_COM_VXWORKS) -DME_COM_WINSDK=$(ME_COM_WINSDK) -DME_COM_ZLIB=$(ME_COM_ZLIB) 
IFLAGS                += "-I$(BUILD)/inc"
LDFLAGS               += '-Wl,-rpath,@executable_path/' '-Wl,-rpath,@loader_path/'
LIBPATHS              += -L$(BUILD)/bin
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
ME_WEB_PREFIX         ?= $(ME_ROOT_PREFIX)/var/www/$(NAME)
ME_LOG_PREFIX         ?= $(ME_ROOT_PREFIX)/var/log/$(NAME)
ME_SPOOL_PREFIX       ?= $(ME_ROOT_PREFIX)/var/spool/$(NAME)
ME_CACHE_PREFIX       ?= $(ME_ROOT_PREFIX)/var/spool/$(NAME)/cache
ME_SRC_PREFIX         ?= $(ME_ROOT_PREFIX)$(NAME)-$(VERSION)

WEB_USER              ?= $(shell egrep 'www-data|_www|nobody' /etc/passwd | sed 's/:.*$$$(ME_ROOT_PREFIX)/' |  tail -1)
WEB_GROUP             ?= $(shell egrep 'www-data|_www|nobody|nogroup' /etc/group | sed 's/:.*$$$(ME_ROOT_PREFIX)/' |  tail -1)

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
ifeq ($(ME_COM_SQLITE),1)
    TARGETS           += $(BUILD)/bin/libsql.dylib
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
	@[ ! -f $(BUILD)/inc/me.h ] && cp projects/appweb-macosx-static-me.h $(BUILD)/inc/me.h ; true
	@if ! diff $(BUILD)/inc/me.h projects/appweb-macosx-static-me.h >/dev/null ; then\
		cp projects/appweb-macosx-static-me.h $(BUILD)/inc/me.h  ; \
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
	rm -f "$(BUILD)/bin/libappweb.dylib"
	rm -f "$(BUILD)/bin/libejs.dylib"
	rm -f "$(BUILD)/bin/libesp.dylib"
	rm -f "$(BUILD)/bin/libhttp.dylib"
	rm -f "$(BUILD)/bin/libmod_cgi.dylib"
	rm -f "$(BUILD)/bin/libmod_ejs.dylib"
	rm -f "$(BUILD)/bin/libmod_esp.dylib"
	rm -f "$(BUILD)/bin/libmod_php.dylib"
	rm -f "$(BUILD)/bin/libmod_ssl.dylib"
	rm -f "$(BUILD)/bin/libmpr.dylib"
	rm -f "$(BUILD)/bin/libmprssl.dylib"
	rm -f "$(BUILD)/bin/libpcre.dylib"
	rm -f "$(BUILD)/bin/libslink.dylib"
	rm -f "$(BUILD)/bin/libsql.dylib"
	rm -f "$(BUILD)/bin/libzlib.dylib"
	rm -f "$(BUILD)/bin/appman"

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
#   ejs.h
#
DEPS_8 += src/ejs/ejs.h

$(BUILD)/inc/ejs.h: $(DEPS_8)
	@echo '      [Copy] $(BUILD)/inc/ejs.h'
	mkdir -p "$(BUILD)/inc"
	cp src/ejs/ejs.h $(BUILD)/inc/ejs.h

#
#   ejs.slots.h
#
DEPS_9 += src/ejs/ejs.slots.h

$(BUILD)/inc/ejs.slots.h: $(DEPS_9)
	@echo '      [Copy] $(BUILD)/inc/ejs.slots.h'
	mkdir -p "$(BUILD)/inc"
	cp src/ejs/ejs.slots.h $(BUILD)/inc/ejs.slots.h

#
#   ejsByteGoto.h
#
DEPS_10 += src/ejs/ejsByteGoto.h

$(BUILD)/inc/ejsByteGoto.h: $(DEPS_10)
	@echo '      [Copy] $(BUILD)/inc/ejsByteGoto.h'
	mkdir -p "$(BUILD)/inc"
	cp src/ejs/ejsByteGoto.h $(BUILD)/inc/ejsByteGoto.h

#
#   esp.h
#
DEPS_11 += src/esp/esp.h
DEPS_11 += $(BUILD)/inc/me.h
DEPS_11 += $(BUILD)/inc/osdep.h
DEPS_11 += $(BUILD)/inc/http.h

$(BUILD)/inc/esp.h: $(DEPS_11)
	@echo '      [Copy] $(BUILD)/inc/esp.h'
	mkdir -p "$(BUILD)/inc"
	cp src/esp/esp.h $(BUILD)/inc/esp.h

#
#   pcre.h
#
DEPS_12 += src/pcre/pcre.h

$(BUILD)/inc/pcre.h: $(DEPS_12)
	@echo '      [Copy] $(BUILD)/inc/pcre.h'
	mkdir -p "$(BUILD)/inc"
	cp src/pcre/pcre.h $(BUILD)/inc/pcre.h

#
#   sqlite3.h
#
DEPS_13 += src/sqlite/sqlite3.h

$(BUILD)/inc/sqlite3.h: $(DEPS_13)
	@echo '      [Copy] $(BUILD)/inc/sqlite3.h'
	mkdir -p "$(BUILD)/inc"
	cp src/sqlite/sqlite3.h $(BUILD)/inc/sqlite3.h

#
#   zlib.h
#
DEPS_14 += src/zlib/zlib.h

$(BUILD)/inc/zlib.h: $(DEPS_14)
	@echo '      [Copy] $(BUILD)/inc/zlib.h'
	mkdir -p "$(BUILD)/inc"
	cp src/zlib/zlib.h $(BUILD)/inc/zlib.h

#
#   appweb.o
#
DEPS_15 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/appweb.o: \
    src/server/appweb.c $(DEPS_15)
	@echo '   [Compile] $(BUILD)/obj/appweb.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/appweb.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_PHP_PATH)" "-I$(ME_COM_PHP_PATH)/main" "-I$(ME_COM_PHP_PATH)/Zend" "-I$(ME_COM_PHP_PATH)/TSRM" src/server/appweb.c

#
#   authpass.o
#
DEPS_16 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/authpass.o: \
    src/utils/authpass.c $(DEPS_16)
	@echo '   [Compile] $(BUILD)/obj/authpass.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/authpass.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/utils/authpass.c

#
#   cgiHandler.o
#
DEPS_17 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/cgiHandler.o: \
    src/modules/cgiHandler.c $(DEPS_17)
	@echo '   [Compile] $(BUILD)/obj/cgiHandler.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/cgiHandler.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/modules/cgiHandler.c

#
#   cgiProgram.o
#

$(BUILD)/obj/cgiProgram.o: \
    src/utils/cgiProgram.c $(DEPS_18)
	@echo '   [Compile] $(BUILD)/obj/cgiProgram.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/cgiProgram.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/utils/cgiProgram.c

#
#   appweb.h
#

src/appweb.h: $(DEPS_19)

#
#   config.o
#
DEPS_20 += src/appweb.h
DEPS_20 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/config.o: \
    src/config.c $(DEPS_20)
	@echo '   [Compile] $(BUILD)/obj/config.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/config.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/config.c

#
#   convenience.o
#
DEPS_21 += src/appweb.h

$(BUILD)/obj/convenience.o: \
    src/convenience.c $(DEPS_21)
	@echo '   [Compile] $(BUILD)/obj/convenience.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/convenience.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/convenience.c

#
#   ejs.h
#

src/ejs/ejs.h: $(DEPS_22)

#
#   ejs.o
#
DEPS_23 += src/ejs/ejs.h

$(BUILD)/obj/ejs.o: \
    src/ejs/ejs.c $(DEPS_23)
	@echo '   [Compile] $(BUILD)/obj/ejs.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/ejs.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/ejs/ejs.c

#
#   ejsHandler.o
#
DEPS_24 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/ejsHandler.o: \
    src/modules/ejsHandler.c $(DEPS_24)
	@echo '   [Compile] $(BUILD)/obj/ejsHandler.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/ejsHandler.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/modules/ejsHandler.c

#
#   ejsLib.o
#
DEPS_25 += src/ejs/ejs.h
DEPS_25 += $(BUILD)/inc/mpr.h
DEPS_25 += $(BUILD)/inc/pcre.h
DEPS_25 += $(BUILD)/inc/me.h

$(BUILD)/obj/ejsLib.o: \
    src/ejs/ejsLib.c $(DEPS_25)
	@echo '   [Compile] $(BUILD)/obj/ejsLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/ejsLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/ejs/ejsLib.c

#
#   ejsc.o
#
DEPS_26 += src/ejs/ejs.h

$(BUILD)/obj/ejsc.o: \
    src/ejs/ejsc.c $(DEPS_26)
	@echo '   [Compile] $(BUILD)/obj/ejsc.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/ejsc.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/ejs/ejsc.c

#
#   esp.h
#

src/esp/esp.h: $(DEPS_27)

#
#   esp.o
#
DEPS_28 += src/esp/esp.h

$(BUILD)/obj/esp.o: \
    src/esp/esp.c $(DEPS_28)
	@echo '   [Compile] $(BUILD)/obj/esp.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/esp.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/esp/esp.c

#
#   espHandler.o
#
DEPS_29 += $(BUILD)/inc/appweb.h
DEPS_29 += $(BUILD)/inc/esp.h

$(BUILD)/obj/espHandler.o: \
    src/modules/espHandler.c $(DEPS_29)
	@echo '   [Compile] $(BUILD)/obj/espHandler.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/espHandler.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/modules/espHandler.c

#
#   espLib.o
#
DEPS_30 += src/esp/esp.h
DEPS_30 += $(BUILD)/inc/pcre.h
DEPS_30 += $(BUILD)/inc/http.h

$(BUILD)/obj/espLib.o: \
    src/esp/espLib.c $(DEPS_30)
	@echo '   [Compile] $(BUILD)/obj/espLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/espLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/esp/espLib.c

#
#   http.h
#

src/http/http.h: $(DEPS_31)

#
#   http.o
#
DEPS_32 += src/http/http.h

$(BUILD)/obj/http.o: \
    src/http/http.c $(DEPS_32)
	@echo '   [Compile] $(BUILD)/obj/http.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/http.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/http/http.c

#
#   httpLib.o
#
DEPS_33 += src/http/http.h

$(BUILD)/obj/httpLib.o: \
    src/http/httpLib.c $(DEPS_33)
	@echo '   [Compile] $(BUILD)/obj/httpLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/httpLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/http/httpLib.c

#
#   mpr.h
#

src/mpr/mpr.h: $(DEPS_34)

#
#   makerom.o
#
DEPS_35 += src/mpr/mpr.h

$(BUILD)/obj/makerom.o: \
    src/mpr/makerom.c $(DEPS_35)
	@echo '   [Compile] $(BUILD)/obj/makerom.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/makerom.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/mpr/makerom.c

#
#   manager.o
#
DEPS_36 += src/mpr/mpr.h

$(BUILD)/obj/manager.o: \
    src/mpr/manager.c $(DEPS_36)
	@echo '   [Compile] $(BUILD)/obj/manager.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/manager.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/mpr/manager.c

#
#   mprLib.o
#
DEPS_37 += src/mpr/mpr.h

$(BUILD)/obj/mprLib.o: \
    src/mpr/mprLib.c $(DEPS_37)
	@echo '   [Compile] $(BUILD)/obj/mprLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/mprLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/mpr/mprLib.c

#
#   mprSsl.o
#
DEPS_38 += src/mpr/mpr.h

$(BUILD)/obj/mprSsl.o: \
    src/mpr/mprSsl.c $(DEPS_38)
	@echo '   [Compile] $(BUILD)/obj/mprSsl.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/mprSsl.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/mpr/mprSsl.c

#
#   pcre.h
#

src/pcre/pcre.h: $(DEPS_39)

#
#   pcre.o
#
DEPS_40 += $(BUILD)/inc/me.h
DEPS_40 += src/pcre/pcre.h

$(BUILD)/obj/pcre.o: \
    src/pcre/pcre.c $(DEPS_40)
	@echo '   [Compile] $(BUILD)/obj/pcre.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/pcre.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/pcre/pcre.c

#
#   phpHandler.o
#
DEPS_41 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/phpHandler.o: \
    src/modules/phpHandler.c $(DEPS_41)
	@echo '   [Compile] $(BUILD)/obj/phpHandler.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/phpHandler.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) "-I$(ME_COM_PHP_PATH)" "-I$(ME_COM_PHP_PATH)/main" "-I$(ME_COM_PHP_PATH)/Zend" "-I$(ME_COM_PHP_PATH)/TSRM" src/modules/phpHandler.c

#
#   slink.o
#
DEPS_42 += $(BUILD)/inc/mpr.h
DEPS_42 += $(BUILD)/inc/esp.h

$(BUILD)/obj/slink.o: \
    src/server/slink.c $(DEPS_42)
	@echo '   [Compile] $(BUILD)/obj/slink.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/slink.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/server/slink.c

#
#   sqlite3.h
#

src/sqlite/sqlite3.h: $(DEPS_43)

#
#   sqlite.o
#
DEPS_44 += $(BUILD)/inc/me.h
DEPS_44 += src/sqlite/sqlite3.h

$(BUILD)/obj/sqlite.o: \
    src/sqlite/sqlite.c $(DEPS_44)
	@echo '   [Compile] $(BUILD)/obj/sqlite.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/sqlite.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/sqlite/sqlite.c

#
#   sqlite3.o
#
DEPS_45 += $(BUILD)/inc/me.h
DEPS_45 += src/sqlite/sqlite3.h

$(BUILD)/obj/sqlite3.o: \
    src/sqlite/sqlite3.c $(DEPS_45)
	@echo '   [Compile] $(BUILD)/obj/sqlite3.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/sqlite3.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/sqlite/sqlite3.c

#
#   sslModule.o
#
DEPS_46 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/sslModule.o: \
    src/modules/sslModule.c $(DEPS_46)
	@echo '   [Compile] $(BUILD)/obj/sslModule.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/sslModule.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/modules/sslModule.c

#
#   zlib.h
#

src/zlib/zlib.h: $(DEPS_47)

#
#   zlib.o
#
DEPS_48 += $(BUILD)/inc/me.h
DEPS_48 += src/zlib/zlib.h

$(BUILD)/obj/zlib.o: \
    src/zlib/zlib.c $(DEPS_48)
	@echo '   [Compile] $(BUILD)/obj/zlib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/zlib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/zlib/zlib.c

#
#   libmpr
#
DEPS_49 += $(BUILD)/inc/osdep.h
DEPS_49 += $(BUILD)/inc/mpr.h
DEPS_49 += $(BUILD)/obj/mprLib.o

$(BUILD)/bin/libmpr.dylib: $(DEPS_49)
	@echo '      [Link] $(BUILD)/bin/libmpr.dylib'
	ar -cr $(BUILD)/bin/libmpr.dylib "$(BUILD)/obj/mprLib.o"

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_50 += $(BUILD)/inc/pcre.h
DEPS_50 += $(BUILD)/obj/pcre.o

$(BUILD)/bin/libpcre.dylib: $(DEPS_50)
	@echo '      [Link] $(BUILD)/bin/libpcre.dylib'
	ar -cr $(BUILD)/bin/libpcre.dylib "$(BUILD)/obj/pcre.o"
endif

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_51 += $(BUILD)/bin/libmpr.dylib
ifeq ($(ME_COM_PCRE),1)
    DEPS_51 += $(BUILD)/bin/libpcre.dylib
endif
DEPS_51 += $(BUILD)/inc/http.h
DEPS_51 += $(BUILD)/obj/httpLib.o

$(BUILD)/bin/libhttp.dylib: $(DEPS_51)
	@echo '      [Link] $(BUILD)/bin/libhttp.dylib'
	ar -cr $(BUILD)/bin/libhttp.dylib "$(BUILD)/obj/httpLib.o"
endif

#
#   libappweb
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_52 += $(BUILD)/bin/libhttp.dylib
endif
DEPS_52 += $(BUILD)/bin/libmpr.dylib
DEPS_52 += $(BUILD)/inc/appweb.h
DEPS_52 += $(BUILD)/inc/customize.h
DEPS_52 += $(BUILD)/obj/config.o
DEPS_52 += $(BUILD)/obj/convenience.o

$(BUILD)/bin/libappweb.dylib: $(DEPS_52)
	@echo '      [Link] $(BUILD)/bin/libappweb.dylib'
	ar -cr $(BUILD)/bin/libappweb.dylib "$(BUILD)/obj/config.o" "$(BUILD)/obj/convenience.o"

ifeq ($(ME_COM_ESP),1)
#
#   libesp
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_53 += $(BUILD)/bin/libhttp.dylib
endif
DEPS_53 += $(BUILD)/inc/esp.h
DEPS_53 += $(BUILD)/obj/espLib.o

$(BUILD)/bin/libesp.dylib: $(DEPS_53)
	@echo '      [Link] $(BUILD)/bin/libesp.dylib'
	ar -cr $(BUILD)/bin/libesp.dylib "$(BUILD)/obj/espLib.o"
endif

ifeq ($(ME_COM_ESP),1)
#
#   libmod_esp
#
DEPS_54 += $(BUILD)/bin/libappweb.dylib
DEPS_54 += $(BUILD)/bin/libesp.dylib
DEPS_54 += $(BUILD)/obj/espHandler.o

$(BUILD)/bin/libmod_esp.dylib: $(DEPS_54)
	@echo '      [Link] $(BUILD)/bin/libmod_esp.dylib'
	ar -cr $(BUILD)/bin/libmod_esp.dylib "$(BUILD)/obj/espHandler.o"
endif

#
#   libslink
#
ifeq ($(ME_COM_ESP),1)
    DEPS_55 += $(BUILD)/bin/libesp.dylib
endif
ifeq ($(ME_COM_ESP),1)
    DEPS_55 += $(BUILD)/bin/libmod_esp.dylib
endif
DEPS_55 += $(BUILD)/obj/slink.o

$(BUILD)/bin/libslink.dylib: $(DEPS_55)
	@echo '      [Link] $(BUILD)/bin/libslink.dylib'
	ar -cr $(BUILD)/bin/libslink.dylib "$(BUILD)/obj/slink.o"

#
#   libmprssl
#
DEPS_56 += $(BUILD)/bin/libmpr.dylib
DEPS_56 += $(BUILD)/obj/mprSsl.o

$(BUILD)/bin/libmprssl.dylib: $(DEPS_56)
	@echo '      [Link] $(BUILD)/bin/libmprssl.dylib'
	ar -cr $(BUILD)/bin/libmprssl.dylib "$(BUILD)/obj/mprSsl.o"

ifeq ($(ME_COM_SSL),1)
#
#   libmod_ssl
#
DEPS_57 += $(BUILD)/bin/libappweb.dylib
DEPS_57 += $(BUILD)/bin/libmprssl.dylib
DEPS_57 += $(BUILD)/obj/sslModule.o

$(BUILD)/bin/libmod_ssl.dylib: $(DEPS_57)
	@echo '      [Link] $(BUILD)/bin/libmod_ssl.dylib'
	ar -cr $(BUILD)/bin/libmod_ssl.dylib "$(BUILD)/obj/sslModule.o"
endif

ifeq ($(ME_COM_ZLIB),1)
#
#   libzlib
#
DEPS_58 += $(BUILD)/inc/zlib.h
DEPS_58 += $(BUILD)/obj/zlib.o

$(BUILD)/bin/libzlib.dylib: $(DEPS_58)
	@echo '      [Link] $(BUILD)/bin/libzlib.dylib'
	ar -cr $(BUILD)/bin/libzlib.dylib "$(BUILD)/obj/zlib.o"
endif

ifeq ($(ME_COM_EJS),1)
#
#   libejs
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_59 += $(BUILD)/bin/libhttp.dylib
endif
ifeq ($(ME_COM_PCRE),1)
    DEPS_59 += $(BUILD)/bin/libpcre.dylib
endif
DEPS_59 += $(BUILD)/bin/libmpr.dylib
ifeq ($(ME_COM_ZLIB),1)
    DEPS_59 += $(BUILD)/bin/libzlib.dylib
endif
DEPS_59 += $(BUILD)/inc/ejs.h
DEPS_59 += $(BUILD)/inc/ejs.slots.h
DEPS_59 += $(BUILD)/inc/ejsByteGoto.h
DEPS_59 += $(BUILD)/obj/ejsLib.o

$(BUILD)/bin/libejs.dylib: $(DEPS_59)
	@echo '      [Link] $(BUILD)/bin/libejs.dylib'
	ar -cr $(BUILD)/bin/libejs.dylib "$(BUILD)/obj/ejsLib.o"
endif

ifeq ($(ME_COM_EJS),1)
#
#   libmod_ejs
#
DEPS_60 += $(BUILD)/bin/libappweb.dylib
DEPS_60 += $(BUILD)/bin/libejs.dylib
DEPS_60 += $(BUILD)/obj/ejsHandler.o

$(BUILD)/bin/libmod_ejs.dylib: $(DEPS_60)
	@echo '      [Link] $(BUILD)/bin/libmod_ejs.dylib'
	ar -cr $(BUILD)/bin/libmod_ejs.dylib "$(BUILD)/obj/ejsHandler.o"
endif

ifeq ($(ME_COM_PHP),1)
#
#   libmod_php
#
DEPS_61 += $(BUILD)/bin/libappweb.dylib
DEPS_61 += $(BUILD)/obj/phpHandler.o

$(BUILD)/bin/libmod_php.dylib: $(DEPS_61)
	@echo '      [Link] $(BUILD)/bin/libmod_php.dylib'
	ar -cr $(BUILD)/bin/libmod_php.dylib "$(BUILD)/obj/phpHandler.o"
endif

ifeq ($(ME_COM_CGI),1)
#
#   libmod_cgi
#
DEPS_62 += $(BUILD)/bin/libappweb.dylib
DEPS_62 += $(BUILD)/obj/cgiHandler.o

$(BUILD)/bin/libmod_cgi.dylib: $(DEPS_62)
	@echo '      [Link] $(BUILD)/bin/libmod_cgi.dylib'
	ar -cr $(BUILD)/bin/libmod_cgi.dylib "$(BUILD)/obj/cgiHandler.o"
endif

#
#   appweb
#
DEPS_63 += $(BUILD)/bin/libappweb.dylib
DEPS_63 += $(BUILD)/bin/libslink.dylib
ifeq ($(ME_COM_ESP),1)
    DEPS_63 += $(BUILD)/bin/libmod_esp.dylib
endif
ifeq ($(ME_COM_SSL),1)
    DEPS_63 += $(BUILD)/bin/libmod_ssl.dylib
endif
ifeq ($(ME_COM_EJS),1)
    DEPS_63 += $(BUILD)/bin/libmod_ejs.dylib
endif
ifeq ($(ME_COM_PHP),1)
    DEPS_63 += $(BUILD)/bin/libmod_php.dylib
endif
ifeq ($(ME_COM_CGI),1)
    DEPS_63 += $(BUILD)/bin/libmod_cgi.dylib
endif
DEPS_63 += $(BUILD)/obj/appweb.o

LIBS_63 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_63 += -lhttp
endif
LIBS_63 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_63 += -lpcre
endif
LIBS_63 += -lslink
ifeq ($(ME_COM_ESP),1)
    LIBS_63 += -lesp
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_63 += -lsql
endif
ifeq ($(ME_COM_ESP),1)
    LIBS_63 += -lmod_esp
endif
ifeq ($(ME_COM_SSL),1)
    LIBS_63 += -lmod_ssl
endif
LIBS_63 += -lmprssl
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_63 += -lssl
    LIBPATHS_63 += -L"$(ME_COM_OPENSSL_PATH)/lib"
    LIBPATHS_63 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_63 += -lcrypto
    LIBPATHS_63 += -L"$(ME_COM_OPENSSL_PATH)/lib"
    LIBPATHS_63 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_63 += -lest
endif
ifeq ($(ME_COM_EJS),1)
    LIBS_63 += -lmod_ejs
endif
ifeq ($(ME_COM_EJS),1)
    LIBS_63 += -lejs
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_63 += -lzlib
endif
ifeq ($(ME_COM_PHP),1)
    LIBS_63 += -lmod_php
endif
ifeq ($(ME_COM_PHP),1)
    LIBS_63 += -lphp5
    LIBPATHS_63 += -L"$(ME_COM_PHP_PATH)/libs"
endif
ifeq ($(ME_COM_CGI),1)
    LIBS_63 += -lmod_cgi
endif

$(BUILD)/bin/appweb: $(DEPS_63)
	@echo '      [Link] $(BUILD)/bin/appweb'
	$(CC) -o $(BUILD)/bin/appweb -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)    "$(BUILD)/obj/appweb.o" $(LIBPATHS_63) $(LIBS_63) $(LIBS_63) $(LIBS) -lpam 

#
#   authpass
#
DEPS_64 += $(BUILD)/bin/libappweb.dylib
DEPS_64 += $(BUILD)/obj/authpass.o

LIBS_64 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_64 += -lhttp
endif
LIBS_64 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_64 += -lpcre
endif

$(BUILD)/bin/authpass: $(DEPS_64)
	@echo '      [Link] $(BUILD)/bin/authpass'
	$(CC) -o $(BUILD)/bin/authpass -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/authpass.o" $(LIBPATHS_64) $(LIBS_64) $(LIBS_64) $(LIBS) -lpam 

ifeq ($(ME_COM_EJS),1)
#
#   ejsc
#
DEPS_65 += $(BUILD)/bin/libejs.dylib
DEPS_65 += $(BUILD)/obj/ejsc.o

LIBS_65 += -lejs
ifeq ($(ME_COM_HTTP),1)
    LIBS_65 += -lhttp
endif
LIBS_65 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_65 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_65 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_65 += -lsql
endif

$(BUILD)/bin/ejsc: $(DEPS_65)
	@echo '      [Link] $(BUILD)/bin/ejsc'
	$(CC) -o $(BUILD)/bin/ejsc -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/ejsc.o" $(LIBPATHS_65) $(LIBS_65) $(LIBS_65) $(LIBS) -lpam 
endif

ifeq ($(ME_COM_EJS),1)
#
#   ejs.mod
#
DEPS_66 += src/ejs/ejs.es
DEPS_66 += $(BUILD)/bin/ejsc

$(BUILD)/bin/ejs.mod: $(DEPS_66)
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
DEPS_67 += $(BUILD)/bin/libejs.dylib
DEPS_67 += $(BUILD)/obj/ejs.o

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

$(BUILD)/bin/ejs: $(DEPS_67)
	@echo '      [Link] $(BUILD)/bin/ejs'
	$(CC) -o $(BUILD)/bin/ejs -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/ejs.o" $(LIBPATHS_67) $(LIBS_67) $(LIBS_67) $(LIBS) -lpam -ledit 
endif

ifeq ($(ME_COM_ESP),1)
#
#   esp-compile.json
#
DEPS_68 += src/esp/esp-compile.json

$(BUILD)/bin/esp-compile.json: $(DEPS_68)
	@echo '      [Copy] $(BUILD)/bin/esp-compile.json'
	mkdir -p "$(BUILD)/bin"
	cp src/esp/esp-compile.json $(BUILD)/bin/esp-compile.json
endif

ifeq ($(ME_COM_ESP),1)
#
#   espcmd
#
DEPS_69 += $(BUILD)/bin/libesp.dylib
DEPS_69 += $(BUILD)/obj/esp.o

LIBS_69 += -lesp
ifeq ($(ME_COM_HTTP),1)
    LIBS_69 += -lhttp
endif
LIBS_69 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_69 += -lpcre
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_69 += -lsql
endif

$(BUILD)/bin/esp: $(DEPS_69)
	@echo '      [Link] $(BUILD)/bin/esp'
	$(CC) -o $(BUILD)/bin/esp -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/esp.o" $(LIBPATHS_69) $(LIBS_69) $(LIBS_69) $(LIBS) -lpam 
endif

ifeq ($(ME_COM_ESP),1)
#
#   genslink
#
DEPS_70 += $(BUILD)/bin/libesp.dylib

genslink: $(DEPS_70)
	( \
	cd src/server; \
	echo '    [Create] slink.c' ; \
	esp --static --genlink slink.c compile ; \
	)
endif

#
#   http-ca-crt
#
DEPS_71 += src/http/ca.crt

$(BUILD)/bin/ca.crt: $(DEPS_71)
	@echo '      [Copy] $(BUILD)/bin/ca.crt'
	mkdir -p "$(BUILD)/bin"
	cp src/http/ca.crt $(BUILD)/bin/ca.crt

ifeq ($(ME_COM_HTTP),1)
#
#   httpcmd
#
DEPS_72 += $(BUILD)/bin/libhttp.dylib
DEPS_72 += $(BUILD)/bin/libmprssl.dylib
DEPS_72 += $(BUILD)/obj/http.o

LIBS_72 += -lhttp
LIBS_72 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_72 += -lpcre
endif
LIBS_72 += -lmprssl
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

$(BUILD)/bin/http: $(DEPS_72)
	@echo '      [Link] $(BUILD)/bin/http'
	$(CC) -o $(BUILD)/bin/http -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)   "$(BUILD)/obj/http.o" $(LIBPATHS_72) $(LIBS_72) $(LIBS_72) $(LIBS) -lpam 
endif

ifeq ($(ME_COM_SQLITE),1)
#
#   libsql
#
DEPS_73 += $(BUILD)/inc/sqlite3.h
DEPS_73 += $(BUILD)/obj/sqlite3.o

$(BUILD)/bin/libsql.dylib: $(DEPS_73)
	@echo '      [Link] $(BUILD)/bin/libsql.dylib'
	ar -cr $(BUILD)/bin/libsql.dylib "$(BUILD)/obj/sqlite3.o"
endif

#
#   manager
#
DEPS_74 += $(BUILD)/bin/libmpr.dylib
DEPS_74 += $(BUILD)/obj/manager.o

LIBS_74 += -lmpr

$(BUILD)/bin/appman: $(DEPS_74)
	@echo '      [Link] $(BUILD)/bin/appman'
	$(CC) -o $(BUILD)/bin/appman -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/manager.o" $(LIBPATHS_74) $(LIBS_74) $(LIBS_74) $(LIBS) 

#
#   server-cache
#

src/server/cache: $(DEPS_75)
	( \
	cd src/server; \
	mkdir -p "cache" ; \
	)


#
#   stop
#

stop: $(DEPS_76)
	@./$(BUILD)/bin/appman stop disable uninstall >/dev/null 2>&1 ; true

#
#   installBinary
#

installBinary: $(DEPS_77)
	mkdir -p "$(ME_APP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	ln -s "5.4.0" "$(ME_APP_PREFIX)/latest" ; \
	mkdir -p "$(ME_LOG_PREFIX)" ; \
	chmod 755 "$(ME_LOG_PREFIX)" ; \
	[ `id -u` = 0 ] && chown _www:_www "$(ME_LOG_PREFIX)"; true ; \
	mkdir -p "$(ME_CACHE_PREFIX)" ; \
	chmod 755 "$(ME_CACHE_PREFIX)" ; \
	[ `id -u` = 0 ] && chown _www:_www "$(ME_CACHE_PREFIX)"; true ; \
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
	cp $(BUILD)/bin/libphp5.dylib $(ME_VAPP_PREFIX)/bin/libphp5.dylib ; \
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
	mkdir -p "$(ME_ROOT_PREFIX)/Library/LaunchDaemons" ; \
	cp installs/macosx/com.embedthis.appweb.plist $(ME_ROOT_PREFIX)/Library/LaunchDaemons/com.embedthis.appweb.plist ; \
	chmod 644 "$(ME_ROOT_PREFIX)/Library/LaunchDaemons/com.embedthis.appweb.plist" ; \
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
DEPS_78 += stop

start: $(DEPS_78)
	./$(BUILD)/bin/appman install enable start

#
#   install
#
DEPS_79 += stop
DEPS_79 += installBinary
DEPS_79 += start

install: $(DEPS_79)

#
#   installPrep
#

installPrep: $(DEPS_80)
	if [ "`id -u`" != 0 ] ; \
	then echo "Must run as root. Rerun with "sudo"" ; \
	exit 255 ; \
	fi

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
DEPS_82 += stop

uninstall: $(DEPS_82)
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

version: $(DEPS_83)
	echo 5.4.0

