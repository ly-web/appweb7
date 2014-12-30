#
#   appweb-macosx-static.mk -- Makefile to build Embedthis Appweb for macosx
#

NAME                  := appweb
VERSION               := 4.6.7
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


TARGETS               += $(BUILD)/bin/appweb
TARGETS               += $(BUILD)/bin/authpass
ifeq ($(ME_COM_CGI),1)
    TARGETS           += $(BUILD)/bin/cgiProgram
endif
ifeq ($(ME_COM_EJS),1)
    TARGETS           += $(BUILD)/bin/ejs.mod
endif
ifeq ($(ME_COM_EJS),1)
    TARGETS           += $(BUILD)/bin/ejs
endif
ifeq ($(ME_COM_ESP),1)
    TARGETS           += $(BUILD)/esp
endif
ifeq ($(ME_COM_ESP),1)
    TARGETS           += $(BUILD)/bin/esp.conf
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
TARGETS               += $(BUILD)/bin/makerom
TARGETS               += $(BUILD)/bin/appman
TARGETS               += src/server/cache
ifeq ($(ME_COM_SQLITE),1)
    TARGETS           += $(BUILD)/bin/sqlite
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
	rm -f "$(BUILD)/obj/dirHandler.o"
	rm -f "$(BUILD)/obj/ejs.o"
	rm -f "$(BUILD)/obj/ejsHandler.o"
	rm -f "$(BUILD)/obj/ejsLib.o"
	rm -f "$(BUILD)/obj/ejsc.o"
	rm -f "$(BUILD)/obj/esp.o"
	rm -f "$(BUILD)/obj/espLib.o"
	rm -f "$(BUILD)/obj/fileHandler.o"
	rm -f "$(BUILD)/obj/http.o"
	rm -f "$(BUILD)/obj/httpLib.o"
	rm -f "$(BUILD)/obj/log.o"
	rm -f "$(BUILD)/obj/makerom.o"
	rm -f "$(BUILD)/obj/manager.o"
	rm -f "$(BUILD)/obj/mprLib.o"
	rm -f "$(BUILD)/obj/mprSsl.o"
	rm -f "$(BUILD)/obj/pcre.o"
	rm -f "$(BUILD)/obj/phpHandler.o"
	rm -f "$(BUILD)/obj/server.o"
	rm -f "$(BUILD)/obj/slink.o"
	rm -f "$(BUILD)/obj/sqlite.o"
	rm -f "$(BUILD)/obj/sqlite3.o"
	rm -f "$(BUILD)/obj/sslModule.o"
	rm -f "$(BUILD)/obj/testAppweb.o"
	rm -f "$(BUILD)/obj/testHttp.o"
	rm -f "$(BUILD)/obj/zlib.o"
	rm -f "$(BUILD)/bin/appweb"
	rm -f "$(BUILD)/bin/authpass"
	rm -f "$(BUILD)/bin/cgiProgram"
	rm -f "$(BUILD)/bin/ejsc"
	rm -f "$(BUILD)/bin/ejs"
	rm -f "$(BUILD)/bin/esp.conf"
	rm -f "$(BUILD)/bin/esp"
	rm -f "$(BUILD)/bin/ca.crt"
	rm -f "$(BUILD)/bin/http"
	rm -f "$(BUILD)/bin/libappweb.dylib"
	rm -f "$(BUILD)/bin/libejs.dylib"
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
	rm -f "$(BUILD)/bin/makerom"
	rm -f "$(BUILD)/bin/appman"
	rm -f "$(BUILD)/bin/sqlite"
	rm -f "$(BUILD)/bin/testAppweb"

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

$(BUILD)/inc/esp.h: $(DEPS_11)
	@echo '      [Copy] $(BUILD)/inc/esp.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/esp/esp.h $(BUILD)/inc/esp.h

#
#   est.h
#

$(BUILD)/inc/est.h: $(DEPS_12)

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
#   testAppweb.h
#
DEPS_15 += test/src/testAppweb.h
DEPS_15 += $(BUILD)/inc/mpr.h
DEPS_15 += $(BUILD)/inc/http.h

$(BUILD)/inc/testAppweb.h: $(DEPS_15)
	@echo '      [Copy] $(BUILD)/inc/testAppweb.h'
	mkdir -p "$(BUILD)/inc"
	cp test/src/testAppweb.h $(BUILD)/inc/testAppweb.h

#
#   zlib.h
#
DEPS_16 += src/paks/zlib/zlib.h

$(BUILD)/inc/zlib.h: $(DEPS_16)
	@echo '      [Copy] $(BUILD)/inc/zlib.h'
	mkdir -p "$(BUILD)/inc"
	cp src/paks/zlib/zlib.h $(BUILD)/inc/zlib.h

#
#   appweb.o
#
DEPS_17 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/appweb.o: \
    src/server/appweb.c $(DEPS_17)
	@echo '   [Compile] $(BUILD)/obj/appweb.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/appweb.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" "-I$(ME_COM_PHP_PATH)" "-I$(ME_COM_PHP_PATH)/main" "-I$(ME_COM_PHP_PATH)/Zend" "-I$(ME_COM_PHP_PATH)/TSRM" src/server/appweb.c

#
#   authpass.o
#
DEPS_18 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/authpass.o: \
    src/utils/authpass.c $(DEPS_18)
	@echo '   [Compile] $(BUILD)/obj/authpass.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/authpass.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/utils/authpass.c

#
#   cgiHandler.o
#
DEPS_19 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/cgiHandler.o: \
    src/modules/cgiHandler.c $(DEPS_19)
	@echo '   [Compile] $(BUILD)/obj/cgiHandler.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/cgiHandler.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/modules/cgiHandler.c

#
#   cgiProgram.o
#

$(BUILD)/obj/cgiProgram.o: \
    src/utils/cgiProgram.c $(DEPS_20)
	@echo '   [Compile] $(BUILD)/obj/cgiProgram.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/cgiProgram.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/utils/cgiProgram.c

#
#   appweb.h
#

src/appweb.h: $(DEPS_21)

#
#   config.o
#
DEPS_22 += src/appweb.h
DEPS_22 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/config.o: \
    src/config.c $(DEPS_22)
	@echo '   [Compile] $(BUILD)/obj/config.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/config.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/config.c

#
#   convenience.o
#
DEPS_23 += src/appweb.h

$(BUILD)/obj/convenience.o: \
    src/convenience.c $(DEPS_23)
	@echo '   [Compile] $(BUILD)/obj/convenience.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/convenience.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/convenience.c

#
#   dirHandler.o
#
DEPS_24 += src/appweb.h

$(BUILD)/obj/dirHandler.o: \
    src/dirHandler.c $(DEPS_24)
	@echo '   [Compile] $(BUILD)/obj/dirHandler.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/dirHandler.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/dirHandler.c

#
#   ejs.h
#

src/paks/ejs/ejs.h: $(DEPS_25)

#
#   ejs.o
#
DEPS_26 += src/paks/ejs/ejs.h

$(BUILD)/obj/ejs.o: \
    src/paks/ejs/ejs.c $(DEPS_26)
	@echo '   [Compile] $(BUILD)/obj/ejs.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/ejs.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/ejs/ejs.c

#
#   ejsHandler.o
#
DEPS_27 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/ejsHandler.o: \
    src/modules/ejsHandler.c $(DEPS_27)
	@echo '   [Compile] $(BUILD)/obj/ejsHandler.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/ejsHandler.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/modules/ejsHandler.c

#
#   ejsLib.o
#
DEPS_28 += src/paks/ejs/ejs.h
DEPS_28 += $(BUILD)/inc/mpr.h
DEPS_28 += $(BUILD)/inc/pcre.h
DEPS_28 += $(BUILD)/inc/me.h

$(BUILD)/obj/ejsLib.o: \
    src/paks/ejs/ejsLib.c $(DEPS_28)
	@echo '   [Compile] $(BUILD)/obj/ejsLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/ejsLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/ejs/ejsLib.c

#
#   ejsc.o
#
DEPS_29 += src/paks/ejs/ejs.h

$(BUILD)/obj/ejsc.o: \
    src/paks/ejs/ejsc.c $(DEPS_29)
	@echo '   [Compile] $(BUILD)/obj/ejsc.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/ejsc.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/ejs/ejsc.c

#
#   esp.h
#

src/paks/esp/esp.h: $(DEPS_30)

#
#   esp.o
#
DEPS_31 += src/paks/esp/esp.h

$(BUILD)/obj/esp.o: \
    src/paks/esp/esp.c $(DEPS_31)
	@echo '   [Compile] $(BUILD)/obj/esp.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/esp.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/esp/esp.c

#
#   espLib.o
#
DEPS_32 += src/paks/esp/esp.h
DEPS_32 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/espLib.o: \
    src/paks/esp/espLib.c $(DEPS_32)
	@echo '   [Compile] $(BUILD)/obj/espLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/espLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/esp/espLib.c

#
#   fileHandler.o
#
DEPS_33 += src/appweb.h

$(BUILD)/obj/fileHandler.o: \
    src/fileHandler.c $(DEPS_33)
	@echo '   [Compile] $(BUILD)/obj/fileHandler.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/fileHandler.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/fileHandler.c

#
#   http.h
#

src/paks/http/http.h: $(DEPS_34)

#
#   http.o
#
DEPS_35 += src/paks/http/http.h

$(BUILD)/obj/http.o: \
    src/paks/http/http.c $(DEPS_35)
	@echo '   [Compile] $(BUILD)/obj/http.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/http.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/paks/http/http.c

#
#   httpLib.o
#
DEPS_36 += src/paks/http/http.h

$(BUILD)/obj/httpLib.o: \
    src/paks/http/httpLib.c $(DEPS_36)
	@echo '   [Compile] $(BUILD)/obj/httpLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/httpLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/http/httpLib.c

#
#   log.o
#
DEPS_37 += src/appweb.h

$(BUILD)/obj/log.o: \
    src/log.c $(DEPS_37)
	@echo '   [Compile] $(BUILD)/obj/log.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/log.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/log.c

#
#   mpr.h
#

src/paks/mpr/mpr.h: $(DEPS_38)

#
#   makerom.o
#
DEPS_39 += src/paks/mpr/mpr.h

$(BUILD)/obj/makerom.o: \
    src/paks/mpr/makerom.c $(DEPS_39)
	@echo '   [Compile] $(BUILD)/obj/makerom.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/makerom.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/mpr/makerom.c

#
#   manager.o
#
DEPS_40 += src/paks/mpr/mpr.h

$(BUILD)/obj/manager.o: \
    src/paks/mpr/manager.c $(DEPS_40)
	@echo '   [Compile] $(BUILD)/obj/manager.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/manager.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/mpr/manager.c

#
#   mprLib.o
#
DEPS_41 += src/paks/mpr/mpr.h

$(BUILD)/obj/mprLib.o: \
    src/paks/mpr/mprLib.c $(DEPS_41)
	@echo '   [Compile] $(BUILD)/obj/mprLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/mprLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/mpr/mprLib.c

#
#   mprSsl.o
#
DEPS_42 += $(BUILD)/inc/me.h
DEPS_42 += src/paks/mpr/mpr.h
DEPS_42 += $(BUILD)/inc/est.h

$(BUILD)/obj/mprSsl.o: \
    src/paks/mpr/mprSsl.c $(DEPS_42)
	@echo '   [Compile] $(BUILD)/obj/mprSsl.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/mprSsl.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/paks/mpr/mprSsl.c

#
#   pcre.h
#

src/paks/pcre/pcre.h: $(DEPS_43)

#
#   pcre.o
#
DEPS_44 += $(BUILD)/inc/me.h
DEPS_44 += src/paks/pcre/pcre.h

$(BUILD)/obj/pcre.o: \
    src/paks/pcre/pcre.c $(DEPS_44)
	@echo '   [Compile] $(BUILD)/obj/pcre.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/pcre.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/pcre/pcre.c

#
#   phpHandler.o
#
DEPS_45 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/phpHandler.o: \
    src/modules/phpHandler.c $(DEPS_45)
	@echo '   [Compile] $(BUILD)/obj/phpHandler.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/phpHandler.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) "-I$(ME_COM_PHP_PATH)" "-I$(ME_COM_PHP_PATH)/main" "-I$(ME_COM_PHP_PATH)/Zend" "-I$(ME_COM_PHP_PATH)/TSRM" src/modules/phpHandler.c

#
#   server.o
#
DEPS_46 += src/appweb.h

$(BUILD)/obj/server.o: \
    src/server.c $(DEPS_46)
	@echo '   [Compile] $(BUILD)/obj/server.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/server.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/server.c

#
#   slink.o
#
DEPS_47 += $(BUILD)/inc/mpr.h
DEPS_47 += $(BUILD)/inc/esp.h

$(BUILD)/obj/slink.o: \
    src/slink.c $(DEPS_47)
	@echo '   [Compile] $(BUILD)/obj/slink.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/slink.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/slink.c

#
#   sqlite3.h
#

src/paks/sqlite/sqlite3.h: $(DEPS_48)

#
#   sqlite.o
#
DEPS_49 += $(BUILD)/inc/me.h
DEPS_49 += src/paks/sqlite/sqlite3.h

$(BUILD)/obj/sqlite.o: \
    src/paks/sqlite/sqlite.c $(DEPS_49)
	@echo '   [Compile] $(BUILD)/obj/sqlite.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/sqlite.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/sqlite/sqlite.c

#
#   sqlite3.o
#
DEPS_50 += $(BUILD)/inc/me.h
DEPS_50 += src/paks/sqlite/sqlite3.h

$(BUILD)/obj/sqlite3.o: \
    src/paks/sqlite/sqlite3.c $(DEPS_50)
	@echo '   [Compile] $(BUILD)/obj/sqlite3.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/sqlite3.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/sqlite/sqlite3.c

#
#   sslModule.o
#
DEPS_51 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/sslModule.o: \
    src/modules/sslModule.c $(DEPS_51)
	@echo '   [Compile] $(BUILD)/obj/sslModule.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/sslModule.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/modules/sslModule.c

#
#   testAppweb.o
#
DEPS_52 += $(BUILD)/inc/testAppweb.h

$(BUILD)/obj/testAppweb.o: \
    test/src/testAppweb.c $(DEPS_52)
	@echo '   [Compile] $(BUILD)/obj/testAppweb.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/testAppweb.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) test/src/testAppweb.c

#
#   testHttp.o
#
DEPS_53 += $(BUILD)/inc/testAppweb.h

$(BUILD)/obj/testHttp.o: \
    test/src/testHttp.c $(DEPS_53)
	@echo '   [Compile] $(BUILD)/obj/testHttp.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/testHttp.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) test/src/testHttp.c

#
#   zlib.h
#

src/paks/zlib/zlib.h: $(DEPS_54)

#
#   zlib.o
#
DEPS_55 += $(BUILD)/inc/me.h
DEPS_55 += src/paks/zlib/zlib.h

$(BUILD)/obj/zlib.o: \
    src/paks/zlib/zlib.c $(DEPS_55)
	@echo '   [Compile] $(BUILD)/obj/zlib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/zlib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/zlib/zlib.c

#
#   libmpr
#
DEPS_56 += $(BUILD)/inc/mpr.h
DEPS_56 += $(BUILD)/obj/mprLib.o

$(BUILD)/bin/libmpr.dylib: $(DEPS_56)
	@echo '      [Link] $(BUILD)/bin/libmpr.dylib'
	ar -cr $(BUILD)/bin/libmpr.dylib "$(BUILD)/obj/mprLib.o"

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_57 += $(BUILD)/inc/pcre.h
DEPS_57 += $(BUILD)/obj/pcre.o

$(BUILD)/bin/libpcre.dylib: $(DEPS_57)
	@echo '      [Link] $(BUILD)/bin/libpcre.dylib'
	ar -cr $(BUILD)/bin/libpcre.dylib "$(BUILD)/obj/pcre.o"
endif

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_58 += $(BUILD)/bin/libmpr.dylib
ifeq ($(ME_COM_PCRE),1)
    DEPS_58 += $(BUILD)/bin/libpcre.dylib
endif
DEPS_58 += $(BUILD)/inc/http.h
DEPS_58 += $(BUILD)/obj/httpLib.o

$(BUILD)/bin/libhttp.dylib: $(DEPS_58)
	@echo '      [Link] $(BUILD)/bin/libhttp.dylib'
	ar -cr $(BUILD)/bin/libhttp.dylib "$(BUILD)/obj/httpLib.o"
endif

#
#   libappweb
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_59 += $(BUILD)/bin/libhttp.dylib
endif
DEPS_59 += $(BUILD)/bin/libmpr.dylib
DEPS_59 += $(BUILD)/inc/appweb.h
DEPS_59 += $(BUILD)/inc/customize.h
DEPS_59 += $(BUILD)/obj/config.o
DEPS_59 += $(BUILD)/obj/convenience.o
DEPS_59 += $(BUILD)/obj/dirHandler.o
DEPS_59 += $(BUILD)/obj/fileHandler.o
DEPS_59 += $(BUILD)/obj/log.o
DEPS_59 += $(BUILD)/obj/server.o

$(BUILD)/bin/libappweb.dylib: $(DEPS_59)
	@echo '      [Link] $(BUILD)/bin/libappweb.dylib'
	ar -cr $(BUILD)/bin/libappweb.dylib "$(BUILD)/obj/config.o" "$(BUILD)/obj/convenience.o" "$(BUILD)/obj/dirHandler.o" "$(BUILD)/obj/fileHandler.o" "$(BUILD)/obj/log.o" "$(BUILD)/obj/server.o"

#
#   slink.c
#

src/slink.c: $(DEPS_60)
	( \
	cd src; \
	[ ! -f slink.c ] && cp slink.empty slink.c ; true ; \
	)

ifeq ($(ME_COM_ESP),1)
#
#   libmod_esp
#
DEPS_61 += $(BUILD)/bin/libappweb.dylib
DEPS_61 += $(BUILD)/inc/esp.h
DEPS_61 += $(BUILD)/obj/espLib.o

$(BUILD)/bin/libmod_esp.dylib: $(DEPS_61)
	@echo '      [Link] $(BUILD)/bin/libmod_esp.dylib'
	ar -cr $(BUILD)/bin/libmod_esp.dylib "$(BUILD)/obj/espLib.o"
endif

#
#   libslink
#
DEPS_62 += src/slink.c
ifeq ($(ME_COM_ESP),1)
    DEPS_62 += $(BUILD)/bin/libmod_esp.dylib
endif
ifeq ($(ME_COM_ESP),1)
    DEPS_62 += $(BUILD)/bin/libmod_esp.dylib
endif
DEPS_62 += $(BUILD)/obj/slink.o

$(BUILD)/bin/libslink.dylib: $(DEPS_62)
	@echo '      [Link] $(BUILD)/bin/libslink.dylib'
	ar -cr $(BUILD)/bin/libslink.dylib "$(BUILD)/obj/slink.o"

#
#   libmprssl
#
DEPS_63 += $(BUILD)/bin/libmpr.dylib
DEPS_63 += $(BUILD)/obj/mprSsl.o

$(BUILD)/bin/libmprssl.dylib: $(DEPS_63)
	@echo '      [Link] $(BUILD)/bin/libmprssl.dylib'
	ar -cr $(BUILD)/bin/libmprssl.dylib "$(BUILD)/obj/mprSsl.o"

ifeq ($(ME_COM_SSL),1)
#
#   libmod_ssl
#
DEPS_64 += $(BUILD)/bin/libappweb.dylib
DEPS_64 += $(BUILD)/bin/libmprssl.dylib
DEPS_64 += $(BUILD)/obj/sslModule.o

$(BUILD)/bin/libmod_ssl.dylib: $(DEPS_64)
	@echo '      [Link] $(BUILD)/bin/libmod_ssl.dylib'
	ar -cr $(BUILD)/bin/libmod_ssl.dylib "$(BUILD)/obj/sslModule.o"
endif

ifeq ($(ME_COM_ZLIB),1)
#
#   libzlib
#
DEPS_65 += $(BUILD)/inc/zlib.h
DEPS_65 += $(BUILD)/obj/zlib.o

$(BUILD)/bin/libzlib.dylib: $(DEPS_65)
	@echo '      [Link] $(BUILD)/bin/libzlib.dylib'
	ar -cr $(BUILD)/bin/libzlib.dylib "$(BUILD)/obj/zlib.o"
endif

ifeq ($(ME_COM_EJS),1)
#
#   libejs
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_66 += $(BUILD)/bin/libhttp.dylib
endif
ifeq ($(ME_COM_PCRE),1)
    DEPS_66 += $(BUILD)/bin/libpcre.dylib
endif
DEPS_66 += $(BUILD)/bin/libmpr.dylib
ifeq ($(ME_COM_ZLIB),1)
    DEPS_66 += $(BUILD)/bin/libzlib.dylib
endif
DEPS_66 += $(BUILD)/inc/ejs.h
DEPS_66 += $(BUILD)/inc/ejs.slots.h
DEPS_66 += $(BUILD)/inc/ejsByteGoto.h
DEPS_66 += $(BUILD)/obj/ejsLib.o

$(BUILD)/bin/libejs.dylib: $(DEPS_66)
	@echo '      [Link] $(BUILD)/bin/libejs.dylib'
	ar -cr $(BUILD)/bin/libejs.dylib "$(BUILD)/obj/ejsLib.o"
endif

ifeq ($(ME_COM_EJS),1)
#
#   libmod_ejs
#
DEPS_67 += $(BUILD)/bin/libappweb.dylib
DEPS_67 += $(BUILD)/bin/libejs.dylib
DEPS_67 += $(BUILD)/obj/ejsHandler.o

$(BUILD)/bin/libmod_ejs.dylib: $(DEPS_67)
	@echo '      [Link] $(BUILD)/bin/libmod_ejs.dylib'
	ar -cr $(BUILD)/bin/libmod_ejs.dylib "$(BUILD)/obj/ejsHandler.o"
endif

ifeq ($(ME_COM_PHP),1)
#
#   libmod_php
#
DEPS_68 += $(BUILD)/bin/libappweb.dylib
DEPS_68 += $(BUILD)/obj/phpHandler.o

$(BUILD)/bin/libmod_php.dylib: $(DEPS_68)
	@echo '      [Link] $(BUILD)/bin/libmod_php.dylib'
	ar -cr $(BUILD)/bin/libmod_php.dylib "$(BUILD)/obj/phpHandler.o"
endif

ifeq ($(ME_COM_CGI),1)
#
#   libmod_cgi
#
DEPS_69 += $(BUILD)/bin/libappweb.dylib
DEPS_69 += $(BUILD)/obj/cgiHandler.o

$(BUILD)/bin/libmod_cgi.dylib: $(DEPS_69)
	@echo '      [Link] $(BUILD)/bin/libmod_cgi.dylib'
	ar -cr $(BUILD)/bin/libmod_cgi.dylib "$(BUILD)/obj/cgiHandler.o"
endif

#
#   appweb
#
DEPS_70 += $(BUILD)/bin/libappweb.dylib
DEPS_70 += $(BUILD)/bin/libslink.dylib
ifeq ($(ME_COM_ESP),1)
    DEPS_70 += $(BUILD)/bin/libmod_esp.dylib
endif
ifeq ($(ME_COM_SSL),1)
    DEPS_70 += $(BUILD)/bin/libmod_ssl.dylib
endif
ifeq ($(ME_COM_EJS),1)
    DEPS_70 += $(BUILD)/bin/libmod_ejs.dylib
endif
ifeq ($(ME_COM_PHP),1)
    DEPS_70 += $(BUILD)/bin/libmod_php.dylib
endif
ifeq ($(ME_COM_CGI),1)
    DEPS_70 += $(BUILD)/bin/libmod_cgi.dylib
endif
DEPS_70 += $(BUILD)/obj/appweb.o

LIBS_70 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_70 += -lhttp
endif
LIBS_70 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_70 += -lpcre
endif
LIBS_70 += -lslink
ifeq ($(ME_COM_ESP),1)
    LIBS_70 += -lmod_esp
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_70 += -lsql
endif
ifeq ($(ME_COM_SSL),1)
    LIBS_70 += -lmod_ssl
endif
LIBS_70 += -lmprssl
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_70 += -lssl
    LIBPATHS_70 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_70 += -lcrypto
    LIBPATHS_70 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_70 += -lest
endif
ifeq ($(ME_COM_EJS),1)
    LIBS_70 += -lmod_ejs
endif
ifeq ($(ME_COM_EJS),1)
    LIBS_70 += -lejs
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_70 += -lzlib
endif
ifeq ($(ME_COM_PHP),1)
    LIBS_70 += -lmod_php
endif
ifeq ($(ME_COM_PHP),1)
    LIBS_70 += -lphp5
    LIBPATHS_70 += -L"$(ME_COM_PHP_PATH)/libs"
endif
ifeq ($(ME_COM_CGI),1)
    LIBS_70 += -lmod_cgi
endif

$(BUILD)/bin/appweb: $(DEPS_70)
	@echo '      [Link] $(BUILD)/bin/appweb'
	$(CC) -o $(BUILD)/bin/appweb -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)   "$(BUILD)/obj/appweb.o" $(LIBPATHS_70) $(LIBS_70) $(LIBS_70) $(LIBS) -lpam 

#
#   authpass
#
DEPS_71 += $(BUILD)/bin/libappweb.dylib
DEPS_71 += $(BUILD)/obj/authpass.o

LIBS_71 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_71 += -lhttp
endif
LIBS_71 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_71 += -lpcre
endif

$(BUILD)/bin/authpass: $(DEPS_71)
	@echo '      [Link] $(BUILD)/bin/authpass'
	$(CC) -o $(BUILD)/bin/authpass -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/authpass.o" $(LIBPATHS_71) $(LIBS_71) $(LIBS_71) $(LIBS) -lpam 

ifeq ($(ME_COM_CGI),1)
#
#   cgiProgram
#
DEPS_72 += $(BUILD)/obj/cgiProgram.o

$(BUILD)/bin/cgiProgram: $(DEPS_72)
	@echo '      [Link] $(BUILD)/bin/cgiProgram'
	$(CC) -o $(BUILD)/bin/cgiProgram -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/cgiProgram.o" $(LIBS) 
endif

ifeq ($(ME_COM_EJS),1)
#
#   ejsc
#
DEPS_73 += $(BUILD)/bin/libejs.dylib
DEPS_73 += $(BUILD)/obj/ejsc.o

LIBS_73 += -lejs
ifeq ($(ME_COM_HTTP),1)
    LIBS_73 += -lhttp
endif
LIBS_73 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_73 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_73 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_73 += -lsql
endif

$(BUILD)/bin/ejsc: $(DEPS_73)
	@echo '      [Link] $(BUILD)/bin/ejsc'
	$(CC) -o $(BUILD)/bin/ejsc -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/ejsc.o" $(LIBPATHS_73) $(LIBS_73) $(LIBS_73) $(LIBS) -lpam 
endif

ifeq ($(ME_COM_EJS),1)
#
#   ejs.mod
#
DEPS_74 += src/paks/ejs/ejs.es
DEPS_74 += $(BUILD)/bin/ejsc

$(BUILD)/bin/ejs.mod: $(DEPS_74)
	( \
	cd src/paks/ejs; \
	../../../$(BUILD)/bin/ejsc --out ../../../$(BUILD)/bin/ejs.mod --optimize 9 --bind --require null ejs.es ; \
	)
endif

ifeq ($(ME_COM_EJS),1)
#
#   ejscmd
#
DEPS_75 += $(BUILD)/bin/libejs.dylib
DEPS_75 += $(BUILD)/obj/ejs.o

LIBS_75 += -lejs
ifeq ($(ME_COM_HTTP),1)
    LIBS_75 += -lhttp
endif
LIBS_75 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_75 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_75 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_75 += -lsql
endif

$(BUILD)/bin/ejs: $(DEPS_75)
	@echo '      [Link] $(BUILD)/bin/ejs'
	$(CC) -o $(BUILD)/bin/ejs -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/ejs.o" $(LIBPATHS_75) $(LIBS_75) $(LIBS_75) $(LIBS) -lpam -ledit 
endif

ifeq ($(ME_COM_ESP),1)
#
#   esp-paks
#
DEPS_76 += src/paks/esp-html-mvc/client/assets/favicon.ico
DEPS_76 += src/paks/esp-html-mvc/client/css/all.css
DEPS_76 += src/paks/esp-html-mvc/client/css/all.less
DEPS_76 += src/paks/esp-html-mvc/client/index.esp
DEPS_76 += src/paks/esp-html-mvc/css/app.less
DEPS_76 += src/paks/esp-html-mvc/css/theme.less
DEPS_76 += src/paks/esp-html-mvc/generate/appweb.conf
DEPS_76 += src/paks/esp-html-mvc/generate/controller.c
DEPS_76 += src/paks/esp-html-mvc/generate/controllerSingleton.c
DEPS_76 += src/paks/esp-html-mvc/generate/edit.esp
DEPS_76 += src/paks/esp-html-mvc/generate/list.esp
DEPS_76 += src/paks/esp-html-mvc/layouts/default.esp
DEPS_76 += src/paks/esp-html-mvc/package.json
DEPS_76 += src/paks/esp-legacy-mvc/generate/appweb.conf
DEPS_76 += src/paks/esp-legacy-mvc/generate/controller.c
DEPS_76 += src/paks/esp-legacy-mvc/generate/edit.esp
DEPS_76 += src/paks/esp-legacy-mvc/generate/list.esp
DEPS_76 += src/paks/esp-legacy-mvc/generate/migration.c
DEPS_76 += src/paks/esp-legacy-mvc/generate/src/app.c
DEPS_76 += src/paks/esp-legacy-mvc/layouts/default.esp
DEPS_76 += src/paks/esp-legacy-mvc/package.json
DEPS_76 += src/paks/esp-legacy-mvc/static/css/all.css
DEPS_76 += src/paks/esp-legacy-mvc/static/images/banner.jpg
DEPS_76 += src/paks/esp-legacy-mvc/static/images/favicon.ico
DEPS_76 += src/paks/esp-legacy-mvc/static/images/splash.jpg
DEPS_76 += src/paks/esp-legacy-mvc/static/index.esp
DEPS_76 += src/paks/esp-legacy-mvc/static/js/jquery.esp.js
DEPS_76 += src/paks/esp-legacy-mvc/static/js/jquery.js
DEPS_76 += src/paks/esp-mvc/generate/appweb.conf
DEPS_76 += src/paks/esp-mvc/generate/controller.c
DEPS_76 += src/paks/esp-mvc/generate/migration.c
DEPS_76 += src/paks/esp-mvc/generate/src/app.c
DEPS_76 += src/paks/esp-mvc/LICENSE.md
DEPS_76 += src/paks/esp-mvc/package.json
DEPS_76 += src/paks/esp-mvc/README.md
DEPS_76 += src/paks/esp-server/generate/appweb.conf
DEPS_76 += src/paks/esp-server/package.json

$(BUILD)/esp: $(DEPS_76)
	( \
	cd src/paks; \
	mkdir -p "../../$(BUILD)/esp/esp-html-mvc/4.6.7" ; \
	mkdir -p "../../$(BUILD)/esp/esp-html-mvc/4.6.7/client" ; \
	mkdir -p "../../$(BUILD)/esp/esp-html-mvc/4.6.7/client/assets" ; \
	cp esp-html-mvc/client/assets/favicon.ico ../../$(BUILD)/esp/esp-html-mvc/4.6.7/client/assets/favicon.ico ; \
	mkdir -p "../../$(BUILD)/esp/esp-html-mvc/4.6.7/client/css" ; \
	cp esp-html-mvc/client/css/all.css ../../$(BUILD)/esp/esp-html-mvc/4.6.7/client/css/all.css ; \
	cp esp-html-mvc/client/css/all.less ../../$(BUILD)/esp/esp-html-mvc/4.6.7/client/css/all.less ; \
	cp esp-html-mvc/client/index.esp ../../$(BUILD)/esp/esp-html-mvc/4.6.7/client/index.esp ; \
	mkdir -p "../../$(BUILD)/esp/esp-html-mvc/4.6.7/css" ; \
	cp esp-html-mvc/css/app.less ../../$(BUILD)/esp/esp-html-mvc/4.6.7/css/app.less ; \
	cp esp-html-mvc/css/theme.less ../../$(BUILD)/esp/esp-html-mvc/4.6.7/css/theme.less ; \
	mkdir -p "../../$(BUILD)/esp/esp-html-mvc/4.6.7/generate" ; \
	cp esp-html-mvc/generate/appweb.conf ../../$(BUILD)/esp/esp-html-mvc/4.6.7/generate/appweb.conf ; \
	cp esp-html-mvc/generate/controller.c ../../$(BUILD)/esp/esp-html-mvc/4.6.7/generate/controller.c ; \
	cp esp-html-mvc/generate/controllerSingleton.c ../../$(BUILD)/esp/esp-html-mvc/4.6.7/generate/controllerSingleton.c ; \
	cp esp-html-mvc/generate/edit.esp ../../$(BUILD)/esp/esp-html-mvc/4.6.7/generate/edit.esp ; \
	cp esp-html-mvc/generate/list.esp ../../$(BUILD)/esp/esp-html-mvc/4.6.7/generate/list.esp ; \
	mkdir -p "../../$(BUILD)/esp/esp-html-mvc/4.6.7/layouts" ; \
	cp esp-html-mvc/layouts/default.esp ../../$(BUILD)/esp/esp-html-mvc/4.6.7/layouts/default.esp ; \
	cp esp-html-mvc/package.json ../../$(BUILD)/esp/esp-html-mvc/4.6.7/package.json ; \
	mkdir -p "../../$(BUILD)/esp/esp-legacy-mvc/4.6.7" ; \
	mkdir -p "../../$(BUILD)/esp/esp-legacy-mvc/4.6.7/generate" ; \
	cp esp-legacy-mvc/generate/appweb.conf ../../$(BUILD)/esp/esp-legacy-mvc/4.6.7/generate/appweb.conf ; \
	cp esp-legacy-mvc/generate/controller.c ../../$(BUILD)/esp/esp-legacy-mvc/4.6.7/generate/controller.c ; \
	cp esp-legacy-mvc/generate/edit.esp ../../$(BUILD)/esp/esp-legacy-mvc/4.6.7/generate/edit.esp ; \
	cp esp-legacy-mvc/generate/list.esp ../../$(BUILD)/esp/esp-legacy-mvc/4.6.7/generate/list.esp ; \
	cp esp-legacy-mvc/generate/migration.c ../../$(BUILD)/esp/esp-legacy-mvc/4.6.7/generate/migration.c ; \
	mkdir -p "../../$(BUILD)/esp/esp-legacy-mvc/4.6.7/generate/src" ; \
	cp esp-legacy-mvc/generate/src/app.c ../../$(BUILD)/esp/esp-legacy-mvc/4.6.7/generate/src/app.c ; \
	mkdir -p "../../$(BUILD)/esp/esp-legacy-mvc/4.6.7/layouts" ; \
	cp esp-legacy-mvc/layouts/default.esp ../../$(BUILD)/esp/esp-legacy-mvc/4.6.7/layouts/default.esp ; \
	cp esp-legacy-mvc/package.json ../../$(BUILD)/esp/esp-legacy-mvc/4.6.7/package.json ; \
	mkdir -p "../../$(BUILD)/esp/esp-legacy-mvc/4.6.7/static" ; \
	mkdir -p "../../$(BUILD)/esp/esp-legacy-mvc/4.6.7/static/css" ; \
	cp esp-legacy-mvc/static/css/all.css ../../$(BUILD)/esp/esp-legacy-mvc/4.6.7/static/css/all.css ; \
	mkdir -p "../../$(BUILD)/esp/esp-legacy-mvc/4.6.7/static/images" ; \
	cp esp-legacy-mvc/static/images/banner.jpg ../../$(BUILD)/esp/esp-legacy-mvc/4.6.7/static/images/banner.jpg ; \
	cp esp-legacy-mvc/static/images/favicon.ico ../../$(BUILD)/esp/esp-legacy-mvc/4.6.7/static/images/favicon.ico ; \
	cp esp-legacy-mvc/static/images/splash.jpg ../../$(BUILD)/esp/esp-legacy-mvc/4.6.7/static/images/splash.jpg ; \
	cp esp-legacy-mvc/static/index.esp ../../$(BUILD)/esp/esp-legacy-mvc/4.6.7/static/index.esp ; \
	mkdir -p "../../$(BUILD)/esp/esp-legacy-mvc/4.6.7/static/js" ; \
	cp esp-legacy-mvc/static/js/jquery.esp.js ../../$(BUILD)/esp/esp-legacy-mvc/4.6.7/static/js/jquery.esp.js ; \
	cp esp-legacy-mvc/static/js/jquery.js ../../$(BUILD)/esp/esp-legacy-mvc/4.6.7/static/js/jquery.js ; \
	mkdir -p "../../$(BUILD)/esp/esp-mvc/4.6.7" ; \
	mkdir -p "../../$(BUILD)/esp/esp-mvc/4.6.7/generate" ; \
	cp esp-mvc/generate/appweb.conf ../../$(BUILD)/esp/esp-mvc/4.6.7/generate/appweb.conf ; \
	cp esp-mvc/generate/controller.c ../../$(BUILD)/esp/esp-mvc/4.6.7/generate/controller.c ; \
	cp esp-mvc/generate/migration.c ../../$(BUILD)/esp/esp-mvc/4.6.7/generate/migration.c ; \
	mkdir -p "../../$(BUILD)/esp/esp-mvc/4.6.7/generate/src" ; \
	cp esp-mvc/generate/src/app.c ../../$(BUILD)/esp/esp-mvc/4.6.7/generate/src/app.c ; \
	cp esp-mvc/LICENSE.md ../../$(BUILD)/esp/esp-mvc/4.6.7/LICENSE.md ; \
	cp esp-mvc/package.json ../../$(BUILD)/esp/esp-mvc/4.6.7/package.json ; \
	cp esp-mvc/README.md ../../$(BUILD)/esp/esp-mvc/4.6.7/README.md ; \
	mkdir -p "../../$(BUILD)/esp/esp-server/4.6.7" ; \
	mkdir -p "../../$(BUILD)/esp/esp-server/4.6.7/generate" ; \
	cp esp-server/generate/appweb.conf ../../$(BUILD)/esp/esp-server/4.6.7/generate/appweb.conf ; \
	cp esp-server/package.json ../../$(BUILD)/esp/esp-server/4.6.7/package.json ; \
	pak -f -q cache esp-html-mvc esp-legacy-mvc esp-mvc esp-server ; \
	)
endif

ifeq ($(ME_COM_ESP),1)
#
#   esp.conf
#
DEPS_77 += src/paks/esp/esp.conf

$(BUILD)/bin/esp.conf: $(DEPS_77)
	@echo '      [Copy] $(BUILD)/bin/esp.conf'
	mkdir -p "$(BUILD)/bin"
	cp src/paks/esp/esp.conf $(BUILD)/bin/esp.conf
endif

ifeq ($(ME_COM_ESP),1)
#
#   espcmd
#
DEPS_78 += $(BUILD)/bin/libmod_esp.dylib
DEPS_78 += $(BUILD)/obj/esp.o

LIBS_78 += -lmod_esp
LIBS_78 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_78 += -lhttp
endif
LIBS_78 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_78 += -lpcre
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_78 += -lsql
endif

$(BUILD)/bin/esp: $(DEPS_78)
	@echo '      [Link] $(BUILD)/bin/esp'
	$(CC) -o $(BUILD)/bin/esp -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/esp.o" $(LIBPATHS_78) $(LIBS_78) $(LIBS_78) $(LIBS) -lpam 
endif

#
#   genslink
#

genslink: $(DEPS_79)
	( \
	cd src; \
	esp --static --genlink slink.c compile ; \
	)

#
#   http-ca-crt
#
DEPS_80 += src/paks/http/ca.crt

$(BUILD)/bin/ca.crt: $(DEPS_80)
	@echo '      [Copy] $(BUILD)/bin/ca.crt'
	mkdir -p "$(BUILD)/bin"
	cp src/paks/http/ca.crt $(BUILD)/bin/ca.crt

ifeq ($(ME_COM_HTTP),1)
#
#   httpcmd
#
DEPS_81 += $(BUILD)/bin/libhttp.dylib
DEPS_81 += $(BUILD)/bin/libmprssl.dylib
DEPS_81 += $(BUILD)/obj/http.o

LIBS_81 += -lhttp
LIBS_81 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_81 += -lpcre
endif
LIBS_81 += -lmprssl
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_81 += -lssl
    LIBPATHS_81 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_81 += -lcrypto
    LIBPATHS_81 += -L"$(ME_COM_OPENSSL_PATH)"
endif
ifeq ($(ME_COM_EST),1)
    LIBS_81 += -lest
endif

$(BUILD)/bin/http: $(DEPS_81)
	@echo '      [Link] $(BUILD)/bin/http'
	$(CC) -o $(BUILD)/bin/http -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)  "$(BUILD)/obj/http.o" $(LIBPATHS_81) $(LIBS_81) $(LIBS_81) $(LIBS) -lpam 
endif

ifeq ($(ME_COM_SQLITE),1)
#
#   libsql
#
DEPS_82 += $(BUILD)/inc/sqlite3.h
DEPS_82 += $(BUILD)/obj/sqlite3.o

$(BUILD)/bin/libsql.dylib: $(DEPS_82)
	@echo '      [Link] $(BUILD)/bin/libsql.dylib'
	ar -cr $(BUILD)/bin/libsql.dylib "$(BUILD)/obj/sqlite3.o"
endif

#
#   makerom
#
DEPS_83 += $(BUILD)/bin/libmpr.dylib
DEPS_83 += $(BUILD)/obj/makerom.o

LIBS_83 += -lmpr

$(BUILD)/bin/makerom: $(DEPS_83)
	@echo '      [Link] $(BUILD)/bin/makerom'
	$(CC) -o $(BUILD)/bin/makerom -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/makerom.o" $(LIBPATHS_83) $(LIBS_83) $(LIBS_83) $(LIBS) 

#
#   manager
#
DEPS_84 += $(BUILD)/bin/libmpr.dylib
DEPS_84 += $(BUILD)/obj/manager.o

LIBS_84 += -lmpr

$(BUILD)/bin/appman: $(DEPS_84)
	@echo '      [Link] $(BUILD)/bin/appman'
	$(CC) -o $(BUILD)/bin/appman -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/manager.o" $(LIBPATHS_84) $(LIBS_84) $(LIBS_84) $(LIBS) 

#
#   server-cache
#

src/server/cache: $(DEPS_85)
	( \
	cd src/server; \
	mkdir -p cache ; \
	)

ifeq ($(ME_COM_SQLITE),1)
#
#   sqliteshell
#
DEPS_86 += $(BUILD)/bin/libsql.dylib
DEPS_86 += $(BUILD)/obj/sqlite.o

LIBS_86 += -lsql

$(BUILD)/bin/sqlite: $(DEPS_86)
	@echo '      [Link] $(BUILD)/bin/sqlite'
	$(CC) -o $(BUILD)/bin/sqlite -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/sqlite.o" $(LIBPATHS_86) $(LIBS_86) $(LIBS_86) $(LIBS) 
endif

#
#   testAppweb
#
DEPS_87 += $(BUILD)/bin/libappweb.dylib
DEPS_87 += $(BUILD)/inc/testAppweb.h
DEPS_87 += $(BUILD)/obj/testAppweb.o
DEPS_87 += $(BUILD)/obj/testHttp.o

LIBS_87 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_87 += -lhttp
endif
LIBS_87 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_87 += -lpcre
endif

$(BUILD)/bin/testAppweb: $(DEPS_87)
	@echo '      [Link] $(BUILD)/bin/testAppweb'
	$(CC) -o $(BUILD)/bin/testAppweb -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/testAppweb.o" "$(BUILD)/obj/testHttp.o" $(LIBPATHS_87) $(LIBS_87) $(LIBS_87) $(LIBS) -lpam 

ifeq ($(ME_COM_CGI),1)
#
#   test-basic.cgi
#
DEPS_88 += $(BUILD)/bin/testAppweb

test/web/auth/basic/basic.cgi: $(DEPS_88)
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
DEPS_89 += $(BUILD)/bin/testAppweb

test/web/caching/cache.cgi: $(DEPS_89)
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
DEPS_90 += $(BUILD)/bin/cgiProgram

test/cgi-bin/cgiProgram: $(DEPS_90)
	( \
	cd test; \
	cp ../$(BUILD)/bin/cgiProgram cgi-bin/cgiProgram ; \
	cp ../$(BUILD)/bin/cgiProgram cgi-bin/nph-cgiProgram ; \
	cp ../$(BUILD)/bin/cgiProgram 'cgi-bin/cgi Program' ; \
	cp ../$(BUILD)/bin/cgiProgram web/cgiProgram.cgi ; \
	chmod +x cgi-bin/* web/cgiProgram.cgi ; \
	)
endif

ifeq ($(ME_COM_CGI),1)
#
#   test-testScript
#
DEPS_91 += $(BUILD)/bin/testAppweb

test/cgi-bin/testScript: $(DEPS_91)
	( \
	cd test; \
	echo '#!../$(BUILD)/bin/cgiProgram' >cgi-bin/testScript ; chmod +x cgi-bin/testScript ; \
	)
endif


#
#   stop
#

stop: $(DEPS_92)
	@./$(BUILD)/bin/appman stop disable uninstall >/dev/null 2>&1 ; true

#
#   installBinary
#

installBinary: $(DEPS_93)
	mkdir -p "$(ME_APP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	ln -s "4.6.7" "$(ME_APP_PREFIX)/latest" ; \
	mkdir -p "$(ME_LOG_PREFIX)" ; \
	chmod 755 "$(ME_LOG_PREFIX)" ; \
	[ `id -u` = 0 ] && chown $(WEB_USER):$(WEB_GROUP) "$(ME_LOG_PREFIX)"; true ; \
	mkdir -p "$(ME_CACHE_PREFIX)" ; \
	chmod 755 "$(ME_CACHE_PREFIX)" ; \
	[ `id -u` = 0 ] && chown $(WEB_USER):$(WEB_GROUP) "$(ME_CACHE_PREFIX)"; true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/appweb $(ME_VAPP_PREFIX)/bin/appweb ; \
	mkdir -p "$(ME_BIN_PREFIX)" ; \
	rm -f "$(ME_BIN_PREFIX)/appweb" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/appweb" "$(ME_BIN_PREFIX)/appweb" ; \
	if [ "$(ME_COM_SSL)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp src/paks/est/ca.crt $(ME_VAPP_PREFIX)/bin/ca.crt ; \
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
	cp src/server/web/favicon.ico $(ME_WEB_PREFIX)/favicon.ico ; \
	cp src/server/web/iehacks.css $(ME_WEB_PREFIX)/iehacks.css ; \
	cp src/server/web/index.html $(ME_WEB_PREFIX)/index.html ; \
	cp src/server/web/min-index.html $(ME_WEB_PREFIX)/min-index.html ; \
	cp src/server/web/print.css $(ME_WEB_PREFIX)/print.css ; \
	cp src/server/web/screen.css $(ME_WEB_PREFIX)/screen.css ; \
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
	cp package/macosx/com.embedthis.appweb.plist $(ME_ROOT_PREFIX)/Library/LaunchDaemons/com.embedthis.appweb.plist ; \
	chmod 644 "$(ME_ROOT_PREFIX)/Library/LaunchDaemons/com.embedthis.appweb.plist" ; \
	if [ "$(ME_COM_ESP)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/esp $(ME_VAPP_PREFIX)/bin/appesp ; \
	mkdir -p "$(ME_BIN_PREFIX)" ; \
	rm -f "$(ME_BIN_PREFIX)/appesp" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/appesp" "$(ME_BIN_PREFIX)/appesp" ; \
	fi ; \
	if [ "$(ME_COM_ESP)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/angular/1.2.6" ; \
	cp ./src/paks/angular/angular-animate.js $(ME_VAPP_PREFIX)/esp/angular/1.2.6/angular-animate.js ; \
	cp ./src/paks/angular/angular-csp.css $(ME_VAPP_PREFIX)/esp/angular/1.2.6/angular-csp.css ; \
	cp ./src/paks/angular/angular-route.js $(ME_VAPP_PREFIX)/esp/angular/1.2.6/angular-route.js ; \
	cp ./src/paks/angular/angular.js $(ME_VAPP_PREFIX)/esp/angular/1.2.6/angular.js ; \
	cp ./src/paks/angular/package.json $(ME_VAPP_PREFIX)/esp/angular/1.2.6/package.json ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.7" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.7/client" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.7/client/assets" ; \
	cp ./src/paks/esp-html-mvc/client/assets/favicon.ico $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.7/client/assets/favicon.ico ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.7/client/css" ; \
	cp ./src/paks/esp-html-mvc/client/css/all.css $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.7/client/css/all.css ; \
	cp ./src/paks/esp-html-mvc/client/css/all.less $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.7/client/css/all.less ; \
	cp ./src/paks/esp-html-mvc/client/index.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.7/client/index.esp ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.7/css" ; \
	cp ./src/paks/esp-html-mvc/css/app.less $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.7/css/app.less ; \
	cp ./src/paks/esp-html-mvc/css/theme.less $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.7/css/theme.less ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.7/generate" ; \
	cp ./src/paks/esp-html-mvc/generate/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.7/generate/appweb.conf ; \
	cp ./src/paks/esp-html-mvc/generate/controller.c $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.7/generate/controller.c ; \
	cp ./src/paks/esp-html-mvc/generate/controllerSingleton.c $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.7/generate/controllerSingleton.c ; \
	cp ./src/paks/esp-html-mvc/generate/edit.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.7/generate/edit.esp ; \
	cp ./src/paks/esp-html-mvc/generate/list.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.7/generate/list.esp ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.7/layouts" ; \
	cp ./src/paks/esp-html-mvc/layouts/default.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.7/layouts/default.esp ; \
	cp ./src/paks/esp-html-mvc/package.json $(ME_VAPP_PREFIX)/esp/esp-html-mvc/4.6.7/package.json ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.7" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.7/generate" ; \
	cp ./src/paks/esp-legacy-mvc/generate/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.7/generate/appweb.conf ; \
	cp ./src/paks/esp-legacy-mvc/generate/controller.c $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.7/generate/controller.c ; \
	cp ./src/paks/esp-legacy-mvc/generate/edit.esp $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.7/generate/edit.esp ; \
	cp ./src/paks/esp-legacy-mvc/generate/list.esp $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.7/generate/list.esp ; \
	cp ./src/paks/esp-legacy-mvc/generate/migration.c $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.7/generate/migration.c ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.7/generate/src" ; \
	cp ./src/paks/esp-legacy-mvc/generate/src/app.c $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.7/generate/src/app.c ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.7/layouts" ; \
	cp ./src/paks/esp-legacy-mvc/layouts/default.esp $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.7/layouts/default.esp ; \
	cp ./src/paks/esp-legacy-mvc/package.json $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.7/package.json ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.7/static" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.7/static/css" ; \
	cp ./src/paks/esp-legacy-mvc/static/css/all.css $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.7/static/css/all.css ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.7/static/images" ; \
	cp ./src/paks/esp-legacy-mvc/static/images/banner.jpg $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.7/static/images/banner.jpg ; \
	cp ./src/paks/esp-legacy-mvc/static/images/favicon.ico $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.7/static/images/favicon.ico ; \
	cp ./src/paks/esp-legacy-mvc/static/images/splash.jpg $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.7/static/images/splash.jpg ; \
	cp ./src/paks/esp-legacy-mvc/static/index.esp $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.7/static/index.esp ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.7/static/js" ; \
	cp ./src/paks/esp-legacy-mvc/static/js/jquery.esp.js $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.7/static/js/jquery.esp.js ; \
	cp ./src/paks/esp-legacy-mvc/static/js/jquery.js $(ME_VAPP_PREFIX)/esp/esp-legacy-mvc/4.6.7/static/js/jquery.js ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-mvc/4.6.7" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-mvc/4.6.7/generate" ; \
	cp ./src/paks/esp-mvc/generate/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-mvc/4.6.7/generate/appweb.conf ; \
	cp ./src/paks/esp-mvc/generate/controller.c $(ME_VAPP_PREFIX)/esp/esp-mvc/4.6.7/generate/controller.c ; \
	cp ./src/paks/esp-mvc/generate/migration.c $(ME_VAPP_PREFIX)/esp/esp-mvc/4.6.7/generate/migration.c ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-mvc/4.6.7/generate/src" ; \
	cp ./src/paks/esp-mvc/generate/src/app.c $(ME_VAPP_PREFIX)/esp/esp-mvc/4.6.7/generate/src/app.c ; \
	cp ./src/paks/esp-mvc/LICENSE.md $(ME_VAPP_PREFIX)/esp/esp-mvc/4.6.7/LICENSE.md ; \
	cp ./src/paks/esp-mvc/package.json $(ME_VAPP_PREFIX)/esp/esp-mvc/4.6.7/package.json ; \
	cp ./src/paks/esp-mvc/README.md $(ME_VAPP_PREFIX)/esp/esp-mvc/4.6.7/README.md ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-server/4.6.7" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-server/4.6.7/generate" ; \
	cp ./src/paks/esp-server/generate/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-server/4.6.7/generate/appweb.conf ; \
	cp ./src/paks/esp-server/package.json $(ME_VAPP_PREFIX)/esp/esp-server/4.6.7/package.json ; \
	fi ; \
	if [ "$(ME_COM_ESP)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/esp.conf $(ME_VAPP_PREFIX)/bin/esp.conf ; \
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
	cp src/paks/osdep/osdep.h $(ME_VAPP_PREFIX)/inc/osdep.h ; \
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
	cp src/paks/est/est.h $(ME_VAPP_PREFIX)/inc/est.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/est.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/est.h" "$(ME_INC_PREFIX)/appweb/est.h" ; \
	cp src/paks/http/http.h $(ME_VAPP_PREFIX)/inc/http.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/http.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/http.h" "$(ME_INC_PREFIX)/appweb/http.h" ; \
	cp src/paks/mpr/mpr.h $(ME_VAPP_PREFIX)/inc/mpr.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/mpr.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/mpr.h" "$(ME_INC_PREFIX)/appweb/mpr.h" ; \
	cp src/paks/pcre/pcre.h $(ME_VAPP_PREFIX)/inc/pcre.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/pcre.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/pcre.h" "$(ME_INC_PREFIX)/appweb/pcre.h" ; \
	cp src/paks/sqlite/sqlite3.h $(ME_VAPP_PREFIX)/inc/sqlite3.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/sqlite3.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/sqlite3.h" "$(ME_INC_PREFIX)/appweb/sqlite3.h" ; \
	if [ "$(ME_COM_ESP)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/inc" ; \
	cp src/paks/esp/esp.h $(ME_VAPP_PREFIX)/inc/esp.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/esp.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/esp.h" "$(ME_INC_PREFIX)/appweb/esp.h" ; \
	fi ; \
	if [ "$(ME_COM_EJS)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/inc" ; \
	cp src/paks/ejs/ejs.h $(ME_VAPP_PREFIX)/inc/ejs.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/ejs.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/ejs.h" "$(ME_INC_PREFIX)/appweb/ejs.h" ; \
	cp src/paks/ejs/ejs.slots.h $(ME_VAPP_PREFIX)/inc/ejs.slots.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/ejs.slots.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/ejs.slots.h" "$(ME_INC_PREFIX)/appweb/ejs.slots.h" ; \
	cp src/paks/ejs/ejsByteGoto.h $(ME_VAPP_PREFIX)/inc/ejsByteGoto.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/ejsByteGoto.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/ejsByteGoto.h" "$(ME_INC_PREFIX)/appweb/ejsByteGoto.h" ; \
	fi ; \
	mkdir -p "$(ME_VAPP_PREFIX)/doc/man1" ; \
	cp doc/public/man/appman.1 $(ME_VAPP_PREFIX)/doc/man1/appman.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/appman.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/appman.1" "$(ME_MAN_PREFIX)/man1/appman.1" ; \
	cp doc/public/man/appweb.1 $(ME_VAPP_PREFIX)/doc/man1/appweb.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/appweb.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/appweb.1" "$(ME_MAN_PREFIX)/man1/appweb.1" ; \
	cp doc/public/man/appwebMonitor.1 $(ME_VAPP_PREFIX)/doc/man1/appwebMonitor.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/appwebMonitor.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/appwebMonitor.1" "$(ME_MAN_PREFIX)/man1/appwebMonitor.1" ; \
	cp doc/public/man/authpass.1 $(ME_VAPP_PREFIX)/doc/man1/authpass.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/authpass.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/authpass.1" "$(ME_MAN_PREFIX)/man1/authpass.1" ; \
	cp doc/public/man/esp.1 $(ME_VAPP_PREFIX)/doc/man1/esp.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/esp.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/esp.1" "$(ME_MAN_PREFIX)/man1/esp.1" ; \
	cp doc/public/man/http.1 $(ME_VAPP_PREFIX)/doc/man1/http.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/http.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/http.1" "$(ME_MAN_PREFIX)/man1/http.1" ; \
	cp doc/public/man/makerom.1 $(ME_VAPP_PREFIX)/doc/man1/makerom.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/makerom.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/makerom.1" "$(ME_MAN_PREFIX)/man1/makerom.1" ; \
	cp doc/public/man/manager.1 $(ME_VAPP_PREFIX)/doc/man1/manager.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/manager.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/manager.1" "$(ME_MAN_PREFIX)/man1/manager.1"

#
#   start
#
DEPS_94 += stop

start: $(DEPS_94)
	./$(BUILD)/bin/appman install enable start

#
#   install
#
DEPS_95 += stop
DEPS_95 += installBinary
DEPS_95 += start

install: $(DEPS_95)

#
#   installPrep
#

installPrep: $(DEPS_96)
	if [ "`id -u`" != 0 ] ; \
	then echo "Must run as root. Rerun with "sudo"" ; \
	exit 255 ; \
	fi

#
#   run
#

run: $(DEPS_97)
	( \
	cd src/server; \
	sudo ../../$(BUILD)/bin/appweb -v ; \
	)

#
#   test-run
#

test-run: $(DEPS_98)
	( \
	cd test; \
	../$(BUILD)/bin/appweb -v ; \
	)


#
#   uninstall
#
DEPS_99 += stop

uninstall: $(DEPS_99)
	( \
	cd package; \
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

version: $(DEPS_100)
	echo 4.6.7

