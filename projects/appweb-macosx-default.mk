#
#   appweb-macosx-default.mk -- Makefile to build Embedthis Appweb for macosx
#

NAME                  := appweb
VERSION               := 5.4.1
PROFILE               ?= default
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
ME_COM_VXWORKS        ?= 0
ME_COM_WINSDK         ?= 1
ME_COM_ZLIB           ?= 0

ME_COM_OPENSSL_PATH   ?= "/usr/lib"

ifeq ($(ME_COM_EST),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_LIB),1)
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

CFLAGS                += -g -w
DFLAGS                +=  $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_CGI=$(ME_COM_CGI) -DME_COM_COMPILER=$(ME_COM_COMPILER) -DME_COM_DIR=$(ME_COM_DIR) -DME_COM_EJS=$(ME_COM_EJS) -DME_COM_ESP=$(ME_COM_ESP) -DME_COM_EST=$(ME_COM_EST) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_LIB=$(ME_COM_LIB) -DME_COM_MATRIXSSL=$(ME_COM_MATRIXSSL) -DME_COM_MDB=$(ME_COM_MDB) -DME_COM_MPR=$(ME_COM_MPR) -DME_COM_NANOSSL=$(ME_COM_NANOSSL) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_OSDEP=$(ME_COM_OSDEP) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_PHP=$(ME_COM_PHP) -DME_COM_SQLITE=$(ME_COM_SQLITE) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_VXWORKS=$(ME_COM_VXWORKS) -DME_COM_WINSDK=$(ME_COM_WINSDK) -DME_COM_ZLIB=$(ME_COM_ZLIB) 
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
ifeq ($(ME_COM_ZLIB),1)
    TARGETS           += $(BUILD)/bin/libzlib.dylib
endif
TARGETS               += src/server/cache
TARGETS               += $(BUILD)/bin/appman

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
	@[ ! -f $(BUILD)/inc/me.h ] && cp projects/appweb-macosx-default-me.h $(BUILD)/inc/me.h ; true
	@if ! diff $(BUILD)/inc/me.h projects/appweb-macosx-default-me.h >/dev/null ; then\
		cp projects/appweb-macosx-default-me.h $(BUILD)/inc/me.h  ; \
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
	rm -f "$(BUILD)/bin/appweb"
	rm -f "$(BUILD)/bin/authpass"
	rm -f "$(BUILD)/bin/esp-compile.json"
	rm -f "$(BUILD)/bin/esp"
	rm -f "$(BUILD)/bin/ca.crt"
	rm -f "$(BUILD)/bin/http"
	rm -f "$(BUILD)/bin/libappweb.dylib"
	rm -f "$(BUILD)/bin/libesp.dylib"
	rm -f "$(BUILD)/bin/libhttp.dylib"
	rm -f "$(BUILD)/bin/libmpr.dylib"
	rm -f "$(BUILD)/bin/libpcre.dylib"
	rm -f "$(BUILD)/bin/libsql.dylib"
	rm -f "$(BUILD)/bin/libzlib.dylib"
	rm -f "$(BUILD)/bin/libopenssl.a"
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
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/appweb.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/server/appweb.c

#
#   authpass.o
#
DEPS_13 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/authpass.o: \
    src/utils/authpass.c $(DEPS_13)
	@echo '   [Compile] $(BUILD)/obj/authpass.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/authpass.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/utils/authpass.c

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
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/cgiHandler.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/modules/cgiHandler.c

#
#   cgiProgram.o
#

$(BUILD)/obj/cgiProgram.o: \
    test/cgiProgram.c $(DEPS_16)
	@echo '   [Compile] $(BUILD)/obj/cgiProgram.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/cgiProgram.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) test/cgiProgram.c

#
#   config.o
#
DEPS_17 += src/appweb.h
DEPS_17 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/config.o: \
    src/config.c $(DEPS_17)
	@echo '   [Compile] $(BUILD)/obj/config.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/config.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/config.c

#
#   convenience.o
#
DEPS_18 += src/appweb.h

$(BUILD)/obj/convenience.o: \
    src/convenience.c $(DEPS_18)
	@echo '   [Compile] $(BUILD)/obj/convenience.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/convenience.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/convenience.c

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
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/esp.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/esp/esp.c

#
#   espHandler.o
#
DEPS_21 += src/appweb.h
DEPS_21 += $(BUILD)/inc/esp.h

$(BUILD)/obj/espHandler.o: \
    src/modules/espHandler.c $(DEPS_21)
	@echo '   [Compile] $(BUILD)/obj/espHandler.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/espHandler.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/modules/espHandler.c

#
#   espLib.o
#
DEPS_22 += src/esp/esp.h
DEPS_22 += $(BUILD)/inc/pcre.h
DEPS_22 += $(BUILD)/inc/http.h

$(BUILD)/obj/espLib.o: \
    src/esp/espLib.c $(DEPS_22)
	@echo '   [Compile] $(BUILD)/obj/espLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/espLib.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/esp/espLib.c

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
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/http.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/http/http.c

#
#   httpLib.o
#
DEPS_25 += src/http/http.h
DEPS_25 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/httpLib.o: \
    src/http/httpLib.c $(DEPS_25)
	@echo '   [Compile] $(BUILD)/obj/httpLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/httpLib.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/http/httpLib.c

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
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/mprLib.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/mpr/mprLib.c

#
#   openssl.o
#
DEPS_28 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/openssl.o: \
    src/mpr-openssl/openssl.c $(DEPS_28)
	@echo '   [Compile] $(BUILD)/obj/openssl.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/openssl.o -arch $(CC_ARCH) -Wno-deprecated-declarations -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/mpr-openssl/openssl.c

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
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/pcre.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/pcre/pcre.c

#
#   romFiles.o
#
DEPS_31 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/romFiles.o: \
    src/romFiles.c $(DEPS_31)
	@echo '   [Compile] $(BUILD)/obj/romFiles.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/romFiles.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/romFiles.c

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
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/sqlite.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/sqlite/sqlite.c

#
#   sqlite3.o
#
DEPS_34 += $(BUILD)/inc/me.h
DEPS_34 += src/sqlite/sqlite3.h

$(BUILD)/obj/sqlite3.o: \
    src/sqlite/sqlite3.c $(DEPS_34)
	@echo '   [Compile] $(BUILD)/obj/sqlite3.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/sqlite3.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/sqlite/sqlite3.c

#
#   watchdog.o
#
DEPS_35 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/watchdog.o: \
    src/watchdog/watchdog.c $(DEPS_35)
	@echo '   [Compile] $(BUILD)/obj/watchdog.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/watchdog.o -arch $(CC_ARCH) $(CFLAGS) -DME_COM_OPENSSL_PATH="$(ME_COM_OPENSSL_PATH)" $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_MATRIXSSL_PATH)" "-I$(ME_COM_MATRIXSSL_PATH)/matrixssl" src/watchdog/watchdog.c

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
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/zlib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/zlib/zlib.c

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

ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_39 += -lmatrixssl
    LIBPATHS_39 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_39 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_39 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_39 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_39 += -lestssl
endif
ifeq ($(ME_COM_EST),1)
    LIBS_39 += -lest
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_39 += -lopenssl
    LIBPATHS_39 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_39 += -lssl
    LIBPATHS_39 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_39 += -lcrypto
    LIBPATHS_39 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_39 += -lcore_s
    LIBPATHS_39 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_39 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_39 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_39 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_39 += -lcrypt_s
    LIBPATHS_39 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_39 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_39 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_39 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_39 += -lssl_s
    LIBPATHS_39 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_39 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_39 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_39 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif

$(BUILD)/bin/libmpr.dylib: $(DEPS_39)
	@echo '      [Link] $(BUILD)/bin/libmpr.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libmpr.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)      -install_name @rpath/libmpr.dylib -compatibility_version 5.4 -current_version 5.4 "$(BUILD)/obj/mprLib.o" $(LIBPATHS_39) $(LIBS_39) $(LIBS_39) $(LIBS) 

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_40 += $(BUILD)/inc/pcre.h
DEPS_40 += $(BUILD)/obj/pcre.o

$(BUILD)/bin/libpcre.dylib: $(DEPS_40)
	@echo '      [Link] $(BUILD)/bin/libpcre.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libpcre.dylib -arch $(CC_ARCH) $(LDFLAGS) -compatibility_version 5.4 -current_version 5.4 $(LIBPATHS) -install_name @rpath/libpcre.dylib -compatibility_version 5.4 -current_version 5.4 "$(BUILD)/obj/pcre.o" $(LIBS) 
endif

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_41 += $(BUILD)/bin/libmpr.dylib
ifeq ($(ME_COM_PCRE),1)
    DEPS_41 += $(BUILD)/bin/libpcre.dylib
endif
DEPS_41 += $(BUILD)/inc/http.h
DEPS_41 += $(BUILD)/obj/httpLib.o

ifeq ($(ME_COM_PCRE),1)
    LIBS_41 += -lpcre
endif
LIBS_41 += -lmpr
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_41 += -lmatrixssl
    LIBPATHS_41 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_41 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_41 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_41 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_41 += -lestssl
endif
ifeq ($(ME_COM_EST),1)
    LIBS_41 += -lest
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_41 += -lopenssl
    LIBPATHS_41 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_41 += -lssl
    LIBPATHS_41 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_41 += -lcrypto
    LIBPATHS_41 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_41 += -lcore_s
    LIBPATHS_41 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_41 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_41 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_41 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_41 += -lcrypt_s
    LIBPATHS_41 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_41 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_41 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_41 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_41 += -lssl_s
    LIBPATHS_41 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_41 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_41 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_41 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif

$(BUILD)/bin/libhttp.dylib: $(DEPS_41)
	@echo '      [Link] $(BUILD)/bin/libhttp.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libhttp.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)      -install_name @rpath/libhttp.dylib -compatibility_version 5.4 -current_version 5.4 "$(BUILD)/obj/httpLib.o" $(LIBPATHS_41) $(LIBS_41) $(LIBS_41) $(LIBS) -lpam 
endif

ifeq ($(ME_COM_ESP),1)
#
#   libesp
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_42 += $(BUILD)/bin/libhttp.dylib
endif
DEPS_42 += $(BUILD)/inc/esp.h
DEPS_42 += $(BUILD)/obj/espLib.o

ifeq ($(ME_COM_SQLITE),1)
    LIBS_42 += -lsql
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_42 += -lhttp
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_42 += -lpcre
endif
LIBS_42 += -lmpr
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_42 += -lmatrixssl
    LIBPATHS_42 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_42 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_42 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_42 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_42 += -lestssl
endif
ifeq ($(ME_COM_EST),1)
    LIBS_42 += -lest
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_42 += -lopenssl
    LIBPATHS_42 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_42 += -lssl
    LIBPATHS_42 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_42 += -lcrypto
    LIBPATHS_42 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_42 += -lcore_s
    LIBPATHS_42 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_42 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_42 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_42 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_42 += -lcrypt_s
    LIBPATHS_42 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_42 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_42 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_42 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_42 += -lssl_s
    LIBPATHS_42 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_42 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_42 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_42 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif

$(BUILD)/bin/libesp.dylib: $(DEPS_42)
	@echo '      [Link] $(BUILD)/bin/libesp.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libesp.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)      -install_name @rpath/libesp.dylib -compatibility_version 5.4 -current_version 5.4 "$(BUILD)/obj/espLib.o" $(LIBPATHS_42) $(LIBS_42) $(LIBS_42) $(LIBS) -lpam 
endif

#
#   libappweb
#
ifeq ($(ME_COM_ESP),1)
    DEPS_43 += $(BUILD)/bin/libesp.dylib
endif
ifeq ($(ME_COM_HTTP),1)
    DEPS_43 += $(BUILD)/bin/libhttp.dylib
endif
DEPS_43 += $(BUILD)/bin/libmpr.dylib
DEPS_43 += $(BUILD)/inc/appweb.h
DEPS_43 += $(BUILD)/inc/customize.h
DEPS_43 += $(BUILD)/obj/config.o
DEPS_43 += $(BUILD)/obj/convenience.o
DEPS_43 += $(BUILD)/obj/romFiles.o
DEPS_43 += $(BUILD)/obj/cgiHandler.o
DEPS_43 += $(BUILD)/obj/espHandler.o

ifeq ($(ME_COM_ESP),1)
    LIBS_43 += -lesp
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_43 += -lsql
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_43 += -lhttp
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_43 += -lpcre
endif
LIBS_43 += -lmpr
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_43 += -lmatrixssl
    LIBPATHS_43 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_43 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_43 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_43 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_43 += -lestssl
endif
ifeq ($(ME_COM_EST),1)
    LIBS_43 += -lest
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_43 += -lopenssl
    LIBPATHS_43 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_43 += -lssl
    LIBPATHS_43 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_43 += -lcrypto
    LIBPATHS_43 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_43 += -lcore_s
    LIBPATHS_43 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_43 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_43 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_43 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_43 += -lcrypt_s
    LIBPATHS_43 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_43 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_43 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_43 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif
ifeq ($(ME_COM_MATRIXSSL),1)
    LIBS_43 += -lssl_s
    LIBPATHS_43 += -L"$(ME_COM_MATRIXSSL_PATH)"
    LIBPATHS_43 += -L"$(ME_COM_MATRIXSSL_PATH)/matrixssl"
    LIBPATHS_43 += -L"$(ME_COM_MATRIXSSL_PATH)/core"
    LIBPATHS_43 += -L"$(ME_COM_MATRIXSSL_PATH)/crypto"
endif

$(BUILD)/bin/libappweb.dylib: $(DEPS_43)
	@echo '      [Link] $(BUILD)/bin/libappweb.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libappweb.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)      -install_name @rpath/libappweb.dylib -compatibility_version 5.4 -current_version 5.4 "$(BUILD)/obj/config.o" "$(BUILD)/obj/convenience.o" "$(BUILD)/obj/romFiles.o" "$(BUILD)/obj/cgiHandler.o" "$(BUILD)/obj/espHandler.o" $(LIBPATHS_43) $(LIBS_43) $(LIBS_43) $(LIBS) -lpam 

#
#   appweb
#
DEPS_44 += $(BUILD)/bin/libappweb.dylib
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

$(BUILD)/bin/appweb: $(DEPS_44)
	@echo '      [Link] $(BUILD)/bin/appweb'
	$(CC) -o $(BUILD)/bin/appweb -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)      "$(BUILD)/obj/appweb.o" $(LIBPATHS_44) $(LIBS_44) $(LIBS_44) $(LIBS) -lpam 

#
#   authpass
#
DEPS_45 += $(BUILD)/bin/libappweb.dylib
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

$(BUILD)/bin/authpass: $(DEPS_45)
	@echo '      [Link] $(BUILD)/bin/authpass'
	$(CC) -o $(BUILD)/bin/authpass -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)      "$(BUILD)/obj/authpass.o" $(LIBPATHS_45) $(LIBS_45) $(LIBS_45) $(LIBS) -lpam 

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
DEPS_47 += $(BUILD)/bin/libesp.dylib
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

$(BUILD)/bin/esp: $(DEPS_47)
	@echo '      [Link] $(BUILD)/bin/esp'
	$(CC) -o $(BUILD)/bin/esp -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)      "$(BUILD)/obj/esp.o" $(LIBPATHS_47) $(LIBS_47) $(LIBS_47) $(LIBS) -lpam 
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
DEPS_49 += $(BUILD)/bin/libhttp.dylib
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

$(BUILD)/bin/http: $(DEPS_49)
	@echo '      [Link] $(BUILD)/bin/http'
	$(CC) -o $(BUILD)/bin/http -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)      "$(BUILD)/obj/http.o" $(LIBPATHS_49) $(LIBS_49) $(LIBS_49) $(LIBS) -lpam 
endif

ifeq ($(ME_COM_SQLITE),1)
#
#   libsql
#
DEPS_50 += $(BUILD)/inc/sqlite3.h
DEPS_50 += $(BUILD)/obj/sqlite3.o

$(BUILD)/bin/libsql.dylib: $(DEPS_50)
	@echo '      [Link] $(BUILD)/bin/libsql.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libsql.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libsql.dylib -compatibility_version 5.4 -current_version 5.4 "$(BUILD)/obj/sqlite3.o" $(LIBS) 
endif

ifeq ($(ME_COM_ZLIB),1)
#
#   libzlib
#
DEPS_51 += $(BUILD)/inc/zlib.h
DEPS_51 += $(BUILD)/obj/zlib.o

$(BUILD)/bin/libzlib.dylib: $(DEPS_51)
	@echo '      [Link] $(BUILD)/bin/libzlib.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libzlib.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libzlib.dylib -compatibility_version 5.4 -current_version 5.4 "$(BUILD)/obj/zlib.o" $(LIBS) 
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
DEPS_53 += $(BUILD)/bin/libmpr.dylib
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

$(BUILD)/bin/appman: $(DEPS_53)
	@echo '      [Link] $(BUILD)/bin/appman'
	$(CC) -o $(BUILD)/bin/appman -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)      "$(BUILD)/obj/watchdog.o" $(LIBPATHS_53) $(LIBS_53) $(LIBS_53) $(LIBS) 

#
#   stop
#

stop: $(DEPS_54)
	@./$(BUILD)/bin/appman stop disable uninstall >/dev/null 2>&1 ; true

#
#   installBinary
#

installBinary: $(DEPS_55)
	mkdir -p "$(ME_APP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	ln -s "$(VERSION)" "$(ME_APP_PREFIX)/latest" ; \
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
	cp src/certs/roots.crt $(ME_VAPP_PREFIX)/bin/roots.crt ; \
	fi ; \
	mkdir -p "$(ME_ETC_PREFIX)" ; \
	cp src/server/mime.types $(ME_ETC_PREFIX)/mime.types ; \
	mkdir -p "$(ME_ETC_PREFIX)" ; \
	cp src/certs/self.crt $(ME_ETC_PREFIX)/self.crt ; \
	cp src/certs/self.key $(ME_ETC_PREFIX)/self.key ; \
	mkdir -p "$(ME_ETC_PREFIX)" ; \
	cp src/server/appweb.conf $(ME_ETC_PREFIX)/appweb.conf ; \
	mkdir -p "$(ME_ETC_PREFIX)" ; \
	cp src/server/sample.conf $(ME_ETC_PREFIX)/sample.conf ; \
	mkdir -p "$(ME_ETC_PREFIX)" ; \
	cp src/certs/self.crt $(ME_ETC_PREFIX)/self.crt ; \
	cp src/certs/self.key $(ME_ETC_PREFIX)/self.key ; \
	echo 'set LOG_DIR "$(ME_LOG_PREFIX)"\nset CACHE_DIR "$(ME_CACHE_PREFIX)"\nDocuments "$(ME_WEB_PREFIX)\nListen 80\n<if SSL_MODULE>\nListenSecure 443\n</if>\n' >$(ME_ETC_PREFIX)/install.conf ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libappweb.dylib $(ME_VAPP_PREFIX)/bin/libappweb.dylib ; \
	cp $(BUILD)/bin/libesp.dylib $(ME_VAPP_PREFIX)/bin/libesp.dylib ; \
	cp $(BUILD)/bin/libhttp.dylib $(ME_VAPP_PREFIX)/bin/libhttp.dylib ; \
	cp $(BUILD)/bin/libmpr.dylib $(ME_VAPP_PREFIX)/bin/libmpr.dylib ; \
	cp $(BUILD)/bin/libpcre.dylib $(ME_VAPP_PREFIX)/bin/libpcre.dylib ; \
	if [ "$(ME_COM_EST)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libest.dylib $(ME_VAPP_PREFIX)/bin/libest.dylib ; \
	fi ; \
	if [ "$(ME_COM_SQLITE)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libsql.dylib $(ME_VAPP_PREFIX)/bin/libsql.dylib ; \
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
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/http.1" "$(ME_MAN_PREFIX)/man1/http.1"

#
#   start
#
DEPS_56 += stop

start: $(DEPS_56)
	./$(BUILD)/bin/appman install enable start

#
#   install
#
DEPS_57 += stop
DEPS_57 += installBinary
DEPS_57 += start

install: $(DEPS_57)

#
#   installPrep
#

installPrep: $(DEPS_58)
	if [ "`id -u`" != 0 ] ; \
	then echo "Must run as root. Rerun with "sudo"" ; \
	exit 255 ; \
	fi

#
#   run
#

run: $(DEPS_59)
	( \
	cd src/server; \
	../../$(BUILD)/bin/appweb --log stdout:2 ; \
	)

#
#   uninstall
#
DEPS_60 += stop

uninstall: $(DEPS_60)
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

version: $(DEPS_61)
	echo $(VERSION)

