#
#   appweb-macosx-default.mk -- Makefile to build Embedthis Appweb for macosx
#

NAME                  := appweb
VERSION               := 5.2.0
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
ME_COM_VXWORKS        ?= 0
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

CFLAGS                += -g -w
DFLAGS                +=  $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_CGI=$(ME_COM_CGI) -DME_COM_DIR=$(ME_COM_DIR) -DME_COM_EJS=$(ME_COM_EJS) -DME_COM_ESP=$(ME_COM_ESP) -DME_COM_EST=$(ME_COM_EST) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_MDB=$(ME_COM_MDB) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_OSDEP=$(ME_COM_OSDEP) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_PHP=$(ME_COM_PHP) -DME_COM_SQLITE=$(ME_COM_SQLITE) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_VXWORKS=$(ME_COM_VXWORKS) -DME_COM_WINSDK=$(ME_COM_WINSDK) -DME_COM_ZLIB=$(ME_COM_ZLIB) 
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
ifeq ($(ME_COM_EST),1)
    TARGETS           += $(BUILD)/bin/libest.dylib
endif
ifeq ($(ME_COM_CGI),1)
    TARGETS           += $(BUILD)/bin/libmod_cgi.dylib
endif
ifeq ($(ME_COM_EJS),1)
    TARGETS           += $(BUILD)/bin/libmod_ejs.dylib
endif
ifeq ($(ME_COM_PHP),1)
    TARGETS           += $(BUILD)/bin/libmod_php.dylib
endif
ifeq ($(ME_COM_SSL),1)
    TARGETS           += $(BUILD)/bin/libmod_ssl.dylib
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
	rm -f "$(BUILD)/bin/libest.dylib"
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
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/appweb.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/server/appweb.c

#
#   authpass.o
#
DEPS_17 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/authpass.o: \
    src/utils/authpass.c $(DEPS_17)
	@echo '   [Compile] $(BUILD)/obj/authpass.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/authpass.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/utils/authpass.c

#
#   cgiHandler.o
#
DEPS_18 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/cgiHandler.o: \
    src/modules/cgiHandler.c $(DEPS_18)
	@echo '   [Compile] $(BUILD)/obj/cgiHandler.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/cgiHandler.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/modules/cgiHandler.c

#
#   cgiProgram.o
#

$(BUILD)/obj/cgiProgram.o: \
    src/utils/cgiProgram.c $(DEPS_19)
	@echo '   [Compile] $(BUILD)/obj/cgiProgram.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/cgiProgram.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/utils/cgiProgram.c

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
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/config.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/config.c

#
#   convenience.o
#
DEPS_22 += src/appweb.h

$(BUILD)/obj/convenience.o: \
    src/convenience.c $(DEPS_22)
	@echo '   [Compile] $(BUILD)/obj/convenience.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/convenience.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/convenience.c

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
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/ejs.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/ejs/ejs.c

#
#   ejsHandler.o
#
DEPS_25 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/ejsHandler.o: \
    src/modules/ejsHandler.c $(DEPS_25)
	@echo '   [Compile] $(BUILD)/obj/ejsHandler.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/ejsHandler.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/modules/ejsHandler.c

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
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/ejsLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/ejs/ejsLib.c

#
#   ejsc.o
#
DEPS_27 += src/paks/ejs/ejs.h

$(BUILD)/obj/ejsc.o: \
    src/paks/ejs/ejsc.c $(DEPS_27)
	@echo '   [Compile] $(BUILD)/obj/ejsc.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/ejsc.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/ejs/ejsc.c

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
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/esp.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/esp/esp.c

#
#   espLib.o
#
DEPS_30 += src/paks/esp/esp.h
DEPS_30 += $(BUILD)/inc/pcre.h
DEPS_30 += $(BUILD)/inc/http.h

$(BUILD)/obj/espLib.o: \
    src/paks/esp/espLib.c $(DEPS_30)
	@echo '   [Compile] $(BUILD)/obj/espLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/espLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/esp/espLib.c

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
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/estLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/est/estLib.c

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
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/http.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/http/http.c

#
#   httpLib.o
#
DEPS_35 += src/paks/http/http.h

$(BUILD)/obj/httpLib.o: \
    src/paks/http/httpLib.c $(DEPS_35)
	@echo '   [Compile] $(BUILD)/obj/httpLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/httpLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/http/httpLib.c

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
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/makerom.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/mpr/makerom.c

#
#   manager.o
#
DEPS_38 += src/paks/mpr/mpr.h

$(BUILD)/obj/manager.o: \
    src/paks/mpr/manager.c $(DEPS_38)
	@echo '   [Compile] $(BUILD)/obj/manager.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/manager.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/mpr/manager.c

#
#   mprLib.o
#
DEPS_39 += src/paks/mpr/mpr.h

$(BUILD)/obj/mprLib.o: \
    src/paks/mpr/mprLib.c $(DEPS_39)
	@echo '   [Compile] $(BUILD)/obj/mprLib.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/mprLib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/mpr/mprLib.c

#
#   mprSsl.o
#
DEPS_40 += $(BUILD)/inc/me.h
DEPS_40 += src/paks/mpr/mpr.h

$(BUILD)/obj/mprSsl.o: \
    src/paks/mpr/mprSsl.c $(DEPS_40)
	@echo '   [Compile] $(BUILD)/obj/mprSsl.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/mprSsl.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/paks/mpr/mprSsl.c

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
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/pcre.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/pcre/pcre.c

#
#   phpHandler.o
#
DEPS_43 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/phpHandler.o: \
    src/modules/phpHandler.c $(DEPS_43)
	@echo '   [Compile] $(BUILD)/obj/phpHandler.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/phpHandler.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/modules/phpHandler.c

#
#   slink.o
#
DEPS_44 += $(BUILD)/inc/mpr.h
DEPS_44 += $(BUILD)/inc/esp.h

$(BUILD)/obj/slink.o: \
    src/server/slink.c $(DEPS_44)
	@echo '   [Compile] $(BUILD)/obj/slink.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/slink.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/server/slink.c

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
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/sqlite.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/sqlite/sqlite.c

#
#   sqlite3.o
#
DEPS_47 += $(BUILD)/inc/me.h
DEPS_47 += src/paks/sqlite/sqlite3.h

$(BUILD)/obj/sqlite3.o: \
    src/paks/sqlite/sqlite3.c $(DEPS_47)
	@echo '   [Compile] $(BUILD)/obj/sqlite3.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/sqlite3.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/sqlite/sqlite3.c

#
#   sslModule.o
#
DEPS_48 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/sslModule.o: \
    src/modules/sslModule.c $(DEPS_48)
	@echo '   [Compile] $(BUILD)/obj/sslModule.o'
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/sslModule.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) "-I$(ME_COM_OPENSSL_PATH)/include" src/modules/sslModule.c

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
	$(CC) -c $(DFLAGS) -o $(BUILD)/obj/zlib.o -arch $(CC_ARCH) $(CFLAGS) $(IFLAGS) src/paks/zlib/zlib.c

#
#   libmpr
#
DEPS_51 += $(BUILD)/inc/mpr.h
DEPS_51 += $(BUILD)/obj/mprLib.o

$(BUILD)/bin/libmpr.dylib: $(DEPS_51)
	@echo '      [Link] $(BUILD)/bin/libmpr.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libmpr.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libmpr.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/mprLib.o" $(LIBS) 

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_52 += $(BUILD)/inc/pcre.h
DEPS_52 += $(BUILD)/obj/pcre.o

$(BUILD)/bin/libpcre.dylib: $(DEPS_52)
	@echo '      [Link] $(BUILD)/bin/libpcre.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libpcre.dylib -arch $(CC_ARCH) $(LDFLAGS) -compatibility_version 5.2 -current_version 5.2 $(LIBPATHS) -install_name @rpath/libpcre.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/pcre.o" $(LIBS) 
endif

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_53 += $(BUILD)/bin/libmpr.dylib
ifeq ($(ME_COM_PCRE),1)
    DEPS_53 += $(BUILD)/bin/libpcre.dylib
endif
DEPS_53 += $(BUILD)/inc/http.h
DEPS_53 += $(BUILD)/obj/httpLib.o

LIBS_53 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_53 += -lpcre
endif

$(BUILD)/bin/libhttp.dylib: $(DEPS_53)
	@echo '      [Link] $(BUILD)/bin/libhttp.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libhttp.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libhttp.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/httpLib.o" $(LIBPATHS_53) $(LIBS_53) $(LIBS_53) $(LIBS) -lpam 
endif

#
#   libappweb
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_54 += $(BUILD)/bin/libhttp.dylib
endif
DEPS_54 += $(BUILD)/bin/libmpr.dylib
DEPS_54 += $(BUILD)/inc/appweb.h
DEPS_54 += $(BUILD)/inc/customize.h
DEPS_54 += $(BUILD)/obj/config.o
DEPS_54 += $(BUILD)/obj/convenience.o

ifeq ($(ME_COM_HTTP),1)
    LIBS_54 += -lhttp
endif
LIBS_54 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_54 += -lpcre
endif

$(BUILD)/bin/libappweb.dylib: $(DEPS_54)
	@echo '      [Link] $(BUILD)/bin/libappweb.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libappweb.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libappweb.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/config.o" "$(BUILD)/obj/convenience.o" $(LIBPATHS_54) $(LIBS_54) $(LIBS_54) $(LIBS) -lpam 

#
#   libslink
#
DEPS_55 += $(BUILD)/obj/slink.o

$(BUILD)/bin/libslink.dylib: $(DEPS_55)
	@echo '      [Link] $(BUILD)/bin/libslink.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libslink.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libslink.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/slink.o" $(LIBS) 

#
#   appweb
#
DEPS_56 += $(BUILD)/bin/libappweb.dylib
DEPS_56 += $(BUILD)/bin/libslink.dylib
DEPS_56 += $(BUILD)/obj/appweb.o

LIBS_56 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_56 += -lhttp
endif
LIBS_56 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_56 += -lpcre
endif
LIBS_56 += -lslink

$(BUILD)/bin/appweb: $(DEPS_56)
	@echo '      [Link] $(BUILD)/bin/appweb'
	$(CC) -o $(BUILD)/bin/appweb -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/appweb.o" $(LIBPATHS_56) $(LIBS_56) $(LIBS_56) $(LIBS) -lpam 

#
#   authpass
#
DEPS_57 += $(BUILD)/bin/libappweb.dylib
DEPS_57 += $(BUILD)/obj/authpass.o

LIBS_57 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_57 += -lhttp
endif
LIBS_57 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_57 += -lpcre
endif

$(BUILD)/bin/authpass: $(DEPS_57)
	@echo '      [Link] $(BUILD)/bin/authpass'
	$(CC) -o $(BUILD)/bin/authpass -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/authpass.o" $(LIBPATHS_57) $(LIBS_57) $(LIBS_57) $(LIBS) -lpam 

ifeq ($(ME_COM_CGI),1)
#
#   cgiProgram
#
DEPS_58 += $(BUILD)/obj/cgiProgram.o

$(BUILD)/bin/cgiProgram: $(DEPS_58)
	@echo '      [Link] $(BUILD)/bin/cgiProgram'
	$(CC) -o $(BUILD)/bin/cgiProgram -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/cgiProgram.o" $(LIBS) 
endif

ifeq ($(ME_COM_ZLIB),1)
#
#   libzlib
#
DEPS_59 += $(BUILD)/inc/zlib.h
DEPS_59 += $(BUILD)/obj/zlib.o

$(BUILD)/bin/libzlib.dylib: $(DEPS_59)
	@echo '      [Link] $(BUILD)/bin/libzlib.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libzlib.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libzlib.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/zlib.o" $(LIBS) 
endif

ifeq ($(ME_COM_EJS),1)
#
#   libejs
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_60 += $(BUILD)/bin/libhttp.dylib
endif
ifeq ($(ME_COM_PCRE),1)
    DEPS_60 += $(BUILD)/bin/libpcre.dylib
endif
DEPS_60 += $(BUILD)/bin/libmpr.dylib
ifeq ($(ME_COM_ZLIB),1)
    DEPS_60 += $(BUILD)/bin/libzlib.dylib
endif
DEPS_60 += $(BUILD)/inc/ejs.h
DEPS_60 += $(BUILD)/inc/ejs.slots.h
DEPS_60 += $(BUILD)/inc/ejsByteGoto.h
DEPS_60 += $(BUILD)/obj/ejsLib.o

ifeq ($(ME_COM_HTTP),1)
    LIBS_60 += -lhttp
endif
LIBS_60 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_60 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_60 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_60 += -lsql
endif

$(BUILD)/bin/libejs.dylib: $(DEPS_60)
	@echo '      [Link] $(BUILD)/bin/libejs.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libejs.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libejs.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/ejsLib.o" $(LIBPATHS_60) $(LIBS_60) $(LIBS_60) $(LIBS) -lpam 
endif

ifeq ($(ME_COM_EJS),1)
#
#   ejsc
#
DEPS_61 += $(BUILD)/bin/libejs.dylib
DEPS_61 += $(BUILD)/obj/ejsc.o

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

$(BUILD)/bin/ejsc: $(DEPS_61)
	@echo '      [Link] $(BUILD)/bin/ejsc'
	$(CC) -o $(BUILD)/bin/ejsc -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/ejsc.o" $(LIBPATHS_61) $(LIBS_61) $(LIBS_61) $(LIBS) -lpam 
endif

ifeq ($(ME_COM_EJS),1)
#
#   ejs.mod
#
DEPS_62 += src/paks/ejs/ejs.es
DEPS_62 += $(BUILD)/bin/ejsc

$(BUILD)/bin/ejs.mod: $(DEPS_62)
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
DEPS_63 += $(BUILD)/bin/libejs.dylib
DEPS_63 += $(BUILD)/obj/ejs.o

LIBS_63 += -lejs
ifeq ($(ME_COM_HTTP),1)
    LIBS_63 += -lhttp
endif
LIBS_63 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_63 += -lpcre
endif
ifeq ($(ME_COM_ZLIB),1)
    LIBS_63 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_63 += -lsql
endif

$(BUILD)/bin/ejs: $(DEPS_63)
	@echo '      [Link] $(BUILD)/bin/ejs'
	$(CC) -o $(BUILD)/bin/ejs -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/ejs.o" $(LIBPATHS_63) $(LIBS_63) $(LIBS_63) $(LIBS) -lpam -ledit 
endif

ifeq ($(ME_COM_ESP),1)
#
#   esp-paks
#
DEPS_64 += src/paks/esp-html-mvc/all.css
DEPS_64 += src/paks/esp-html-mvc/all.less
DEPS_64 += src/paks/esp-html-mvc/app.less
DEPS_64 += src/paks/esp-html-mvc/appweb.conf
DEPS_64 += src/paks/esp-html-mvc/controller.c
DEPS_64 += src/paks/esp-html-mvc/controllerSingleton.c
DEPS_64 += src/paks/esp-html-mvc/default.esp
DEPS_64 += src/paks/esp-html-mvc/edit.esp
DEPS_64 += src/paks/esp-html-mvc/favicon.ico
DEPS_64 += src/paks/esp-html-mvc/index.esp
DEPS_64 += src/paks/esp-html-mvc/LICENSE.md
DEPS_64 += src/paks/esp-html-mvc/list.esp
DEPS_64 += src/paks/esp-html-mvc/package.json
DEPS_64 += src/paks/esp-html-mvc/README.md
DEPS_64 += src/paks/esp-html-mvc/theme.less
DEPS_64 += src/paks/esp-mvc/app.c
DEPS_64 += src/paks/esp-mvc/appweb.conf
DEPS_64 += src/paks/esp-mvc/controller.c
DEPS_64 += src/paks/esp-mvc/LICENSE.md
DEPS_64 += src/paks/esp-mvc/migration.c
DEPS_64 += src/paks/esp-mvc/package.json
DEPS_64 += src/paks/esp-mvc/README.md
DEPS_64 += src/paks/esp-server/appweb.conf
DEPS_64 += src/paks/esp-server/LICENSE.md
DEPS_64 += src/paks/esp-server/package.json
DEPS_64 += src/paks/esp-server/README.md

$(BUILD)/esp: $(DEPS_64)
	( \
	cd src/paks; \
	mkdir -p "../../$(BUILD)/esp/esp-html-mvc/5.2.0" ; \
	cp esp-html-mvc/all.css ../../$(BUILD)/esp/esp-html-mvc/5.2.0/all.css ; \
	cp esp-html-mvc/all.less ../../$(BUILD)/esp/esp-html-mvc/5.2.0/all.less ; \
	cp esp-html-mvc/app.less ../../$(BUILD)/esp/esp-html-mvc/5.2.0/app.less ; \
	cp esp-html-mvc/appweb.conf ../../$(BUILD)/esp/esp-html-mvc/5.2.0/appweb.conf ; \
	cp esp-html-mvc/controller.c ../../$(BUILD)/esp/esp-html-mvc/5.2.0/controller.c ; \
	cp esp-html-mvc/controllerSingleton.c ../../$(BUILD)/esp/esp-html-mvc/5.2.0/controllerSingleton.c ; \
	cp esp-html-mvc/default.esp ../../$(BUILD)/esp/esp-html-mvc/5.2.0/default.esp ; \
	cp esp-html-mvc/edit.esp ../../$(BUILD)/esp/esp-html-mvc/5.2.0/edit.esp ; \
	cp esp-html-mvc/favicon.ico ../../$(BUILD)/esp/esp-html-mvc/5.2.0/favicon.ico ; \
	cp esp-html-mvc/index.esp ../../$(BUILD)/esp/esp-html-mvc/5.2.0/index.esp ; \
	cp esp-html-mvc/LICENSE.md ../../$(BUILD)/esp/esp-html-mvc/5.2.0/LICENSE.md ; \
	cp esp-html-mvc/list.esp ../../$(BUILD)/esp/esp-html-mvc/5.2.0/list.esp ; \
	cp esp-html-mvc/package.json ../../$(BUILD)/esp/esp-html-mvc/5.2.0/package.json ; \
	cp esp-html-mvc/README.md ../../$(BUILD)/esp/esp-html-mvc/5.2.0/README.md ; \
	cp esp-html-mvc/theme.less ../../$(BUILD)/esp/esp-html-mvc/5.2.0/theme.less ; \
	mkdir -p "../../$(BUILD)/esp/esp-mvc/5.2.0" ; \
	cp esp-mvc/app.c ../../$(BUILD)/esp/esp-mvc/5.2.0/app.c ; \
	cp esp-mvc/appweb.conf ../../$(BUILD)/esp/esp-mvc/5.2.0/appweb.conf ; \
	cp esp-mvc/controller.c ../../$(BUILD)/esp/esp-mvc/5.2.0/controller.c ; \
	cp esp-mvc/LICENSE.md ../../$(BUILD)/esp/esp-mvc/5.2.0/LICENSE.md ; \
	cp esp-mvc/migration.c ../../$(BUILD)/esp/esp-mvc/5.2.0/migration.c ; \
	cp esp-mvc/package.json ../../$(BUILD)/esp/esp-mvc/5.2.0/package.json ; \
	cp esp-mvc/README.md ../../$(BUILD)/esp/esp-mvc/5.2.0/README.md ; \
	mkdir -p "../../$(BUILD)/esp/esp-server/5.2.0" ; \
	cp esp-server/appweb.conf ../../$(BUILD)/esp/esp-server/5.2.0/appweb.conf ; \
	cp esp-server/LICENSE.md ../../$(BUILD)/esp/esp-server/5.2.0/LICENSE.md ; \
	cp esp-server/package.json ../../$(BUILD)/esp/esp-server/5.2.0/package.json ; \
	cp esp-server/README.md ../../$(BUILD)/esp/esp-server/5.2.0/README.md ; \
	pak -f -q cache esp-html-mvc esp-mvc esp-server ; \
	)
endif

ifeq ($(ME_COM_ESP),1)
#
#   esp.conf
#
DEPS_65 += src/paks/esp/esp.conf

$(BUILD)/bin/esp.conf: $(DEPS_65)
	@echo '      [Copy] $(BUILD)/bin/esp.conf'
	mkdir -p "$(BUILD)/bin"
	cp src/paks/esp/esp.conf $(BUILD)/bin/esp.conf
endif

ifeq ($(ME_COM_ESP),1)
#
#   libmod_esp
#
DEPS_66 += $(BUILD)/bin/libappweb.dylib
DEPS_66 += $(BUILD)/inc/esp.h
DEPS_66 += $(BUILD)/obj/espLib.o

LIBS_66 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_66 += -lhttp
endif
LIBS_66 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_66 += -lpcre
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_66 += -lsql
endif

$(BUILD)/bin/libmod_esp.dylib: $(DEPS_66)
	@echo '      [Link] $(BUILD)/bin/libmod_esp.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libmod_esp.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libmod_esp.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/espLib.o" $(LIBPATHS_66) $(LIBS_66) $(LIBS_66) $(LIBS) -lpam 
endif

ifeq ($(ME_COM_ESP),1)
#
#   espcmd
#
DEPS_67 += $(BUILD)/bin/libmod_esp.dylib
DEPS_67 += $(BUILD)/obj/esp.o

LIBS_67 += -lmod_esp
LIBS_67 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_67 += -lhttp
endif
LIBS_67 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_67 += -lpcre
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_67 += -lsql
endif

$(BUILD)/bin/esp: $(DEPS_67)
	@echo '      [Link] $(BUILD)/bin/esp'
	$(CC) -o $(BUILD)/bin/esp -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/esp.o" $(LIBPATHS_67) $(LIBS_67) $(LIBS_67) $(LIBS) -lpam 
endif

ifeq ($(ME_COM_ESP),1)
#
#   genslink
#
DEPS_68 += $(BUILD)/bin/libmod_esp.dylib

genslink: $(DEPS_68)
	( \
	cd src/server; \
	echo '    [Create] slink.c' ; \
	esp --static --genlink slink.c compile ; \
	)
endif

#
#   http-ca-crt
#
DEPS_69 += src/paks/http/ca.crt

$(BUILD)/bin/ca.crt: $(DEPS_69)
	@echo '      [Copy] $(BUILD)/bin/ca.crt'
	mkdir -p "$(BUILD)/bin"
	cp src/paks/http/ca.crt $(BUILD)/bin/ca.crt

ifeq ($(ME_COM_HTTP),1)
#
#   httpcmd
#
DEPS_70 += $(BUILD)/bin/libhttp.dylib
DEPS_70 += $(BUILD)/obj/http.o

LIBS_70 += -lhttp
LIBS_70 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_70 += -lpcre
endif

$(BUILD)/bin/http: $(DEPS_70)
	@echo '      [Link] $(BUILD)/bin/http'
	$(CC) -o $(BUILD)/bin/http -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/http.o" $(LIBPATHS_70) $(LIBS_70) $(LIBS_70) $(LIBS) -lpam 
endif

ifeq ($(ME_COM_EST),1)
#
#   libest
#
DEPS_71 += $(BUILD)/inc/est.h
DEPS_71 += $(BUILD)/obj/estLib.o

$(BUILD)/bin/libest.dylib: $(DEPS_71)
	@echo '      [Link] $(BUILD)/bin/libest.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libest.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libest.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/estLib.o" $(LIBS) 
endif

ifeq ($(ME_COM_CGI),1)
#
#   libmod_cgi
#
DEPS_72 += $(BUILD)/bin/libappweb.dylib
DEPS_72 += $(BUILD)/obj/cgiHandler.o

LIBS_72 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_72 += -lhttp
endif
LIBS_72 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_72 += -lpcre
endif

$(BUILD)/bin/libmod_cgi.dylib: $(DEPS_72)
	@echo '      [Link] $(BUILD)/bin/libmod_cgi.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libmod_cgi.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libmod_cgi.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/cgiHandler.o" $(LIBPATHS_72) $(LIBS_72) $(LIBS_72) $(LIBS) -lpam 
endif

ifeq ($(ME_COM_EJS),1)
#
#   libmod_ejs
#
DEPS_73 += $(BUILD)/bin/libappweb.dylib
DEPS_73 += $(BUILD)/bin/libejs.dylib
DEPS_73 += $(BUILD)/obj/ejsHandler.o

LIBS_73 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_73 += -lhttp
endif
LIBS_73 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_73 += -lpcre
endif
LIBS_73 += -lejs
ifeq ($(ME_COM_ZLIB),1)
    LIBS_73 += -lzlib
endif
ifeq ($(ME_COM_SQLITE),1)
    LIBS_73 += -lsql
endif

$(BUILD)/bin/libmod_ejs.dylib: $(DEPS_73)
	@echo '      [Link] $(BUILD)/bin/libmod_ejs.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libmod_ejs.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libmod_ejs.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/ejsHandler.o" $(LIBPATHS_73) $(LIBS_73) $(LIBS_73) $(LIBS) -lpam 
endif

ifeq ($(ME_COM_PHP),1)
#
#   libmod_php
#
DEPS_74 += $(BUILD)/bin/libappweb.dylib
DEPS_74 += $(BUILD)/obj/phpHandler.o

LIBS_74 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_74 += -lhttp
endif
LIBS_74 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_74 += -lpcre
endif

$(BUILD)/bin/libmod_php.dylib: $(DEPS_74)
	@echo '      [Link] $(BUILD)/bin/libmod_php.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libmod_php.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libmod_php.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/phpHandler.o" $(LIBPATHS_74) $(LIBS_74) $(LIBS_74) $(LIBS) -lpam 
endif

#
#   libmprssl
#
DEPS_75 += $(BUILD)/bin/libmpr.dylib
ifeq ($(ME_COM_EST),1)
    DEPS_75 += $(BUILD)/bin/libest.dylib
endif
DEPS_75 += $(BUILD)/obj/mprSsl.o

LIBS_75 += -lmpr
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

$(BUILD)/bin/libmprssl.dylib: $(DEPS_75)
	@echo '      [Link] $(BUILD)/bin/libmprssl.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libmprssl.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)  -install_name @rpath/libmprssl.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/mprSsl.o" $(LIBPATHS_75) $(LIBS_75) $(LIBS_75) $(LIBS) 

ifeq ($(ME_COM_SSL),1)
#
#   libmod_ssl
#
DEPS_76 += $(BUILD)/bin/libappweb.dylib
DEPS_76 += $(BUILD)/bin/libmprssl.dylib
DEPS_76 += $(BUILD)/obj/sslModule.o

LIBS_76 += -lappweb
ifeq ($(ME_COM_HTTP),1)
    LIBS_76 += -lhttp
endif
LIBS_76 += -lmpr
ifeq ($(ME_COM_PCRE),1)
    LIBS_76 += -lpcre
endif
LIBS_76 += -lmprssl
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_76 += -lssl
    LIBPATHS_76 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_76 += -lcrypto
    LIBPATHS_76 += -L$(ME_COM_OPENSSL_PATH)
endif
ifeq ($(ME_COM_EST),1)
    LIBS_76 += -lest
endif

$(BUILD)/bin/libmod_ssl.dylib: $(DEPS_76)
	@echo '      [Link] $(BUILD)/bin/libmod_ssl.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libmod_ssl.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS)  -install_name @rpath/libmod_ssl.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/sslModule.o" $(LIBPATHS_76) $(LIBS_76) $(LIBS_76) $(LIBS) -lpam 
endif

ifeq ($(ME_COM_SQLITE),1)
#
#   libsql
#
DEPS_77 += $(BUILD)/inc/sqlite3.h
DEPS_77 += $(BUILD)/obj/sqlite3.o

$(BUILD)/bin/libsql.dylib: $(DEPS_77)
	@echo '      [Link] $(BUILD)/bin/libsql.dylib'
	$(CC) -dynamiclib -o $(BUILD)/bin/libsql.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libsql.dylib -compatibility_version 5.2 -current_version 5.2 "$(BUILD)/obj/sqlite3.o" $(LIBS) 
endif

#
#   makerom
#
DEPS_78 += $(BUILD)/bin/libmpr.dylib
DEPS_78 += $(BUILD)/obj/makerom.o

LIBS_78 += -lmpr

$(BUILD)/bin/makerom: $(DEPS_78)
	@echo '      [Link] $(BUILD)/bin/makerom'
	$(CC) -o $(BUILD)/bin/makerom -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/makerom.o" $(LIBPATHS_78) $(LIBS_78) $(LIBS_78) $(LIBS) 

#
#   manager
#
DEPS_79 += $(BUILD)/bin/libmpr.dylib
DEPS_79 += $(BUILD)/obj/manager.o

LIBS_79 += -lmpr

$(BUILD)/bin/appman: $(DEPS_79)
	@echo '      [Link] $(BUILD)/bin/appman'
	$(CC) -o $(BUILD)/bin/appman -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/manager.o" $(LIBPATHS_79) $(LIBS_79) $(LIBS_79) $(LIBS) 

#
#   server-cache
#

src/server/cache: $(DEPS_80)
	( \
	cd src/server; \
	mkdir -p "cache" ; \
	)

ifeq ($(ME_COM_SQLITE),1)
#
#   sqliteshell
#
DEPS_81 += $(BUILD)/bin/libsql.dylib
DEPS_81 += $(BUILD)/obj/sqlite.o

LIBS_81 += -lsql

$(BUILD)/bin/sqlite: $(DEPS_81)
	@echo '      [Link] $(BUILD)/bin/sqlite'
	$(CC) -o $(BUILD)/bin/sqlite -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/sqlite.o" $(LIBPATHS_81) $(LIBS_81) $(LIBS_81) $(LIBS) 
endif


#
#   stop
#

stop: $(DEPS_82)
	@./$(BUILD)/bin/appman stop disable uninstall >/dev/null 2>&1 ; true

#
#   installBinary
#

installBinary: $(DEPS_83)
	( \
	cd ../../.paks/me-package/0.8.3; \
	mkdir -p "$(ME_APP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	ln -s "5.2.0" "$(ME_APP_PREFIX)/latest" ; \
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
	cp src/paks/est/ca.crt $(ME_VAPP_PREFIX)/bin/ca.crt ; \
	fi ; \
	if [ "$(ME_COM_OPENSSL)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libssl*.dylib* $(ME_VAPP_PREFIX)/bin/libssl*.dylib* ; \
	cp $(BUILD)/bin/libcrypto*.dylib* $(ME_VAPP_PREFIX)/bin/libcrypto*.dylib* ; \
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
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libappweb.dylib $(ME_VAPP_PREFIX)/bin/libappweb.dylib ; \
	cp $(BUILD)/bin/libhttp.dylib $(ME_VAPP_PREFIX)/bin/libhttp.dylib ; \
	cp $(BUILD)/bin/libmpr.dylib $(ME_VAPP_PREFIX)/bin/libmpr.dylib ; \
	cp $(BUILD)/bin/libpcre.dylib $(ME_VAPP_PREFIX)/bin/libpcre.dylib ; \
	cp $(BUILD)/bin/libslink.dylib $(ME_VAPP_PREFIX)/bin/libslink.dylib ; \
	if [ "$(ME_COM_SSL)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libmprssl.dylib $(ME_VAPP_PREFIX)/bin/libmprssl.dylib ; \
	cp $(BUILD)/bin/libmod_ssl.dylib $(ME_VAPP_PREFIX)/bin/libmod_ssl.dylib ; \
	fi ; \
	if [ "$(ME_COM_EST)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libest.dylib $(ME_VAPP_PREFIX)/bin/libest.dylib ; \
	fi ; \
	if [ "$(ME_COM_SQLITE)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libsql.dylib $(ME_VAPP_PREFIX)/bin/libsql.dylib ; \
	fi ; \
	if [ "$(ME_COM_ESP)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libmod_esp.dylib $(ME_VAPP_PREFIX)/bin/libmod_esp.dylib ; \
	fi ; \
	if [ "$(ME_COM_CGI)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libmod_cgi.dylib $(ME_VAPP_PREFIX)/bin/libmod_cgi.dylib ; \
	fi ; \
	if [ "$(ME_COM_EJS)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libejs.dylib $(ME_VAPP_PREFIX)/bin/libejs.dylib ; \
	cp $(BUILD)/bin/libmod_ejs.dylib $(ME_VAPP_PREFIX)/bin/libmod_ejs.dylib ; \
	cp $(BUILD)/bin/libzlib.dylib $(ME_VAPP_PREFIX)/bin/libzlib.dylib ; \
	fi ; \
	if [ "$(ME_COM_PHP)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(BUILD)/bin/libmod_php.dylib $(ME_VAPP_PREFIX)/bin/libmod_php.dylib ; \
	fi ; \
	mkdir -p "$(ME_WEB_PREFIX)" ; \
	cp src/server/web/bench $(ME_WEB_PREFIX)/bench ; \
	cp src/server/web/favicon.ico $(ME_WEB_PREFIX)/favicon.ico ; \
	cp src/server/web/icons $(ME_WEB_PREFIX)/icons ; \
	cp src/server/web/iehacks.css $(ME_WEB_PREFIX)/iehacks.css ; \
	cp src/server/web/images $(ME_WEB_PREFIX)/images ; \
	cp src/server/web/index.html $(ME_WEB_PREFIX)/index.html ; \
	cp src/server/web/min-index.html $(ME_WEB_PREFIX)/min-index.html ; \
	cp src/server/web/print.css $(ME_WEB_PREFIX)/print.css ; \
	cp src/server/web/screen.css $(ME_WEB_PREFIX)/screen.css ; \
	cp src/server/web/test $(ME_WEB_PREFIX)/test ; \
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
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0" ; \
	cp ../../../git/appweb/src/paks/esp-html-mvc/all.css $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/all.css ; \
	cp ../../../git/appweb/src/paks/esp-html-mvc/all.less $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/all.less ; \
	cp ../../../git/appweb/src/paks/esp-html-mvc/app.less $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/app.less ; \
	cp ../../../git/appweb/src/paks/esp-html-mvc/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/appweb.conf ; \
	cp ../../../git/appweb/src/paks/esp-html-mvc/controller.c $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/controller.c ; \
	cp ../../../git/appweb/src/paks/esp-html-mvc/controllerSingleton.c $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/controllerSingleton.c ; \
	cp ../../../git/appweb/src/paks/esp-html-mvc/default.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/default.esp ; \
	cp ../../../git/appweb/src/paks/esp-html-mvc/edit.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/edit.esp ; \
	cp ../../../git/appweb/src/paks/esp-html-mvc/favicon.ico $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/favicon.ico ; \
	cp ../../../git/appweb/src/paks/esp-html-mvc/index.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/index.esp ; \
	cp ../../../git/appweb/src/paks/esp-html-mvc/LICENSE.md $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/LICENSE.md ; \
	cp ../../../git/appweb/src/paks/esp-html-mvc/list.esp $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/list.esp ; \
	cp ../../../git/appweb/src/paks/esp-html-mvc/package.json $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/package.json ; \
	cp ../../../git/appweb/src/paks/esp-html-mvc/README.md $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/README.md ; \
	cp ../../../git/appweb/src/paks/esp-html-mvc/theme.less $(ME_VAPP_PREFIX)/esp/esp-html-mvc/5.2.0/theme.less ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0" ; \
	cp ../../../git/appweb/src/paks/esp-mvc/app.c $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/app.c ; \
	cp ../../../git/appweb/src/paks/esp-mvc/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/appweb.conf ; \
	cp ../../../git/appweb/src/paks/esp-mvc/controller.c $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/controller.c ; \
	cp ../../../git/appweb/src/paks/esp-mvc/LICENSE.md $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/LICENSE.md ; \
	cp ../../../git/appweb/src/paks/esp-mvc/migration.c $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/migration.c ; \
	cp ../../../git/appweb/src/paks/esp-mvc/package.json $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/package.json ; \
	cp ../../../git/appweb/src/paks/esp-mvc/README.md $(ME_VAPP_PREFIX)/esp/esp-mvc/5.2.0/README.md ; \
	mkdir -p "$(ME_VAPP_PREFIX)/esp/esp-server/5.2.0" ; \
	cp ../../../git/appweb/src/paks/esp-server/appweb.conf $(ME_VAPP_PREFIX)/esp/esp-server/5.2.0/appweb.conf ; \
	cp ../../../git/appweb/src/paks/esp-server/LICENSE.md $(ME_VAPP_PREFIX)/esp/esp-server/5.2.0/LICENSE.md ; \
	cp ../../../git/appweb/src/paks/esp-server/package.json $(ME_VAPP_PREFIX)/esp/esp-server/5.2.0/package.json ; \
	cp ../../../git/appweb/src/paks/esp-server/README.md $(ME_VAPP_PREFIX)/esp/esp-server/5.2.0/README.md ; \
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
	mkdir -p "$(ME_BIN_PREFIX)" ; \
	rm -f "$(ME_BIN_PREFIX)/http" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/http" "$(ME_BIN_PREFIX)/http" ; \
	mkdir -p "$(ME_VAPP_PREFIX)/inc" ; \
	cp $(BUILD)/inc/me.h $(ME_VAPP_PREFIX)/inc/me.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/me.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/me.h" "$(ME_INC_PREFIX)/appweb/me.h" ; \
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
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/manager.1" "$(ME_MAN_PREFIX)/man1/manager.1" ; \
	)

#
#   start
#
DEPS_84 += stop

start: $(DEPS_84)
	./$(BUILD)/bin/appman install enable start

#
#   install
#
DEPS_85 += stop
DEPS_85 += installBinary
DEPS_85 += start

install: $(DEPS_85)

#
#   run
#

run: $(DEPS_86)
	( \
	cd src/server; \
	appweb --log stdout:2 ; \
	)


#
#   uninstall
#
DEPS_87 += stop

uninstall: $(DEPS_87)
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
	rm -f "$(ME_CACHE_PREFIX)/view_7d8f413d270493ba141b22da61c498dd.c" ; \
	rm -f "$(ME_CACHE_PREFIX)/view_7d8f413d270493ba141b22da61c498dd.dylib" ; \
	rm -f "$(ME_CACHE_PREFIX)/view_7d8f413d270493ba141b22da61c498dd.o" ; \
	rm -f "$(ME_ETC_PREFIX)/appweb.conf" ; \
	rm -f "$(ME_ETC_PREFIX)/esp.conf" ; \
	rm -f "$(ME_ETC_PREFIX)/mine.types" ; \
	rm -f "$(ME_ETC_PREFIX)/install.conf" ; \
	rm -fr "$(ME_INC_PREFIX)/appweb" ; \
	)

#
#   version
#

version: $(DEPS_88)
	echo 5.2.0

