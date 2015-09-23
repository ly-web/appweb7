#
#   appweb-vxworks-static.mk -- Makefile to build Embedthis Appweb for vxworks
#

NAME                  := appweb
VERSION               := 6.1.0
PROFILE               ?= static
ARCH                  ?= $(shell echo $(WIND_HOST_TYPE) | sed 's/-.*$(ME_ROOT_PREFIX)/')
CPU                   ?= $(subst X86,PENTIUM,$(shell echo $(ARCH) | tr a-z A-Z))
OS                    ?= vxworks
CC                    ?= cc$(subst x86,pentium,$(ARCH))
LD                    ?= ldundefined
CONFIG                ?= $(OS)-$(ARCH)-$(PROFILE)
BUILD                 ?= build/$(CONFIG)
LBIN                  ?= $(BUILD)/bin
PATH                  := $(LBIN):$(PATH)

ME_COM_CGI            ?= 1
ME_COM_COMPILER       ?= 1
ME_COM_DIR            ?= 1
ME_COM_EJS            ?= 0
ME_COM_ESP            ?= 1
ME_COM_HTTP           ?= 1
ME_COM_LIB            ?= 1
ME_COM_LINK           ?= 1
ME_COM_MATRIXSSL      ?= 0
ME_COM_MBEDTLS        ?= 1
ME_COM_MDB            ?= 1
ME_COM_MPR            ?= 1
ME_COM_NANOSSL        ?= 0
ME_COM_OPENSSL        ?= 0
ME_COM_OSDEP          ?= 1
ME_COM_PCRE           ?= 1
ME_COM_PHP            ?= 0
ME_COM_SSL            ?= 0
ME_COM_VXWORKS        ?= 0
ME_COM_WATCHDOG       ?= 1

ME_COM_OPENSSL_PATH   ?= "/usr/lib"

ifeq ($(ME_COM_LIB),1)
    ME_COM_COMPILER := 1
endif
ifeq ($(ME_COM_LINK),1)
    ME_COM_COMPILER := 1
endif
ifeq ($(ME_COM_MBEDTLS),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_OPENSSL),1)
    ME_COM_SSL := 1
endif
ifeq ($(ME_COM_ESP),1)
    ME_COM_MDB := 1
endif

export PATH           := $(WIND_GNU_PATH)/$(WIND_HOST_TYPE)/bin:$(PATH)
CFLAGS                += -fno-builtin -fno-defer-pop -fvolatile -w
DFLAGS                += -DVXWORKS -DRW_MULTI_THREAD -D_GNU_TOOL -DCPU=PENTIUM $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_COM_CGI=$(ME_COM_CGI) -DME_COM_COMPILER=$(ME_COM_COMPILER) -DME_COM_DIR=$(ME_COM_DIR) -DME_COM_EJS=$(ME_COM_EJS) -DME_COM_ESP=$(ME_COM_ESP) -DME_COM_HTTP=$(ME_COM_HTTP) -DME_COM_LIB=$(ME_COM_LIB) -DME_COM_LINK=$(ME_COM_LINK) -DME_COM_MATRIXSSL=$(ME_COM_MATRIXSSL) -DME_COM_MBEDTLS=$(ME_COM_MBEDTLS) -DME_COM_MDB=$(ME_COM_MDB) -DME_COM_MPR=$(ME_COM_MPR) -DME_COM_NANOSSL=$(ME_COM_NANOSSL) -DME_COM_OPENSSL=$(ME_COM_OPENSSL) -DME_COM_OSDEP=$(ME_COM_OSDEP) -DME_COM_PCRE=$(ME_COM_PCRE) -DME_COM_PHP=$(ME_COM_PHP) -DME_COM_SSL=$(ME_COM_SSL) -DME_COM_VXWORKS=$(ME_COM_VXWORKS) -DME_COM_WATCHDOG=$(ME_COM_WATCHDOG) 
IFLAGS                += "-I$(BUILD)/inc"
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

WEB_USER              ?= $(shell egrep 'www-data|_www|nobody' /etc/passwd | sed 's^:.*^^' |  tail -1)
WEB_GROUP             ?= $(shell egrep 'www-data|_www|nobody|nogroup' /etc/group | sed 's^:.*^^' |  tail -1)

TARGETS               += $(BUILD)/bin/appweb.out
TARGETS               += $(BUILD)/bin/authpass.out
ifeq ($(ME_COM_ESP),1)
    TARGETS           += $(BUILD)/bin/appweb-esp.out
endif
ifeq ($(ME_COM_ESP),1)
    TARGETS           += $(BUILD)/.extras-modified
endif
ifeq ($(ME_COM_HTTP),1)
    TARGETS           += $(BUILD)/bin/http.out
endif
TARGETS               += $(BUILD)/.install-certs-modified
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
			echo "   [Warning] Make flags have changed since the last build" ; \
			echo "   [Warning] Previous build command: "`cat $(BUILD)/.makeflags`"" ; \
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
	rm -f "$(BUILD)/obj/mbedtls.o"
	rm -f "$(BUILD)/obj/mpr-mbedtls.o"
	rm -f "$(BUILD)/obj/mpr-openssl.o"
	rm -f "$(BUILD)/obj/mpr-version.o"
	rm -f "$(BUILD)/obj/mprLib.o"
	rm -f "$(BUILD)/obj/pcre.o"
	rm -f "$(BUILD)/obj/romFiles.o"
	rm -f "$(BUILD)/obj/watchdog.o"
	rm -f "$(BUILD)/bin/appweb.out"
	rm -f "$(BUILD)/bin/authpass.out"
	rm -f "$(BUILD)/bin/appweb-esp.out"
	rm -f "$(BUILD)/.extras-modified"
	rm -f "$(BUILD)/bin/http.out"
	rm -f "$(BUILD)/.install-certs-modified"
	rm -f "$(BUILD)/bin/libappweb.a"
	rm -f "$(BUILD)/bin/libesp.a"
	rm -f "$(BUILD)/bin/libhttp.a"
	rm -f "$(BUILD)/bin/libmbedtls.a"
	rm -f "$(BUILD)/bin/libmpr.a"
	rm -f "$(BUILD)/bin/libmpr-mbedtls.a"
	rm -f "$(BUILD)/bin/libmpr-version.a"
	rm -f "$(BUILD)/bin/libpcre.a"
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
#   appweb.h
#
DEPS_5 += src/appweb.h
DEPS_5 += $(BUILD)/inc/osdep.h
DEPS_5 += $(BUILD)/inc/mpr.h
DEPS_5 += $(BUILD)/inc/http.h

$(BUILD)/inc/appweb.h: $(DEPS_5)
	@echo '      [Copy] $(BUILD)/inc/appweb.h'
	mkdir -p "$(BUILD)/inc"
	cp src/appweb.h $(BUILD)/inc/appweb.h

#
#   customize.h
#
DEPS_6 += src/customize.h

$(BUILD)/inc/customize.h: $(DEPS_6)
	@echo '      [Copy] $(BUILD)/inc/customize.h'
	mkdir -p "$(BUILD)/inc"
	cp src/customize.h $(BUILD)/inc/customize.h

#
#   embedtls.h
#
DEPS_7 += src/mbedtls/embedtls.h

$(BUILD)/inc/embedtls.h: $(DEPS_7)
	@echo '      [Copy] $(BUILD)/inc/embedtls.h'
	mkdir -p "$(BUILD)/inc"
	cp src/mbedtls/embedtls.h $(BUILD)/inc/embedtls.h

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
#   mbedtls.h
#
DEPS_9 += src/mbedtls/mbedtls.h

$(BUILD)/inc/mbedtls.h: $(DEPS_9)
	@echo '      [Copy] $(BUILD)/inc/mbedtls.h'
	mkdir -p "$(BUILD)/inc"
	cp src/mbedtls/mbedtls.h $(BUILD)/inc/mbedtls.h

#
#   mpr-version.h
#
DEPS_10 += src/mpr-version/mpr-version.h
DEPS_10 += $(BUILD)/inc/mpr.h

$(BUILD)/inc/mpr-version.h: $(DEPS_10)
	@echo '      [Copy] $(BUILD)/inc/mpr-version.h'
	mkdir -p "$(BUILD)/inc"
	cp src/mpr-version/mpr-version.h $(BUILD)/inc/mpr-version.h

#
#   pcre.h
#
DEPS_11 += src/pcre/pcre.h

$(BUILD)/inc/pcre.h: $(DEPS_11)
	@echo '      [Copy] $(BUILD)/inc/pcre.h'
	mkdir -p "$(BUILD)/inc"
	cp src/pcre/pcre.h $(BUILD)/inc/pcre.h

#
#   appweb.o
#
DEPS_12 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/appweb.o: \
    src/server/appweb.c $(DEPS_12)
	@echo '   [Compile] $(BUILD)/obj/appweb.o'
	$(CC) -c -o $(BUILD)/obj/appweb.o $(CFLAGS) $(DFLAGS) -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/server/appweb.c

#
#   authpass.o
#
DEPS_13 += $(BUILD)/inc/appweb.h

$(BUILD)/obj/authpass.o: \
    src/utils/authpass.c $(DEPS_13)
	@echo '   [Compile] $(BUILD)/obj/authpass.o'
	$(CC) -c -o $(BUILD)/obj/authpass.o $(CFLAGS) $(DFLAGS) -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/utils/authpass.c

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
	$(CC) -c -o $(BUILD)/obj/cgiHandler.o $(CFLAGS) $(DFLAGS) -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/modules/cgiHandler.c

#
#   cgiProgram.o
#

$(BUILD)/obj/cgiProgram.o: \
    test/cgiProgram.c $(DEPS_16)
	@echo '   [Compile] $(BUILD)/obj/cgiProgram.o'
	$(CC) -c -o $(BUILD)/obj/cgiProgram.o $(CFLAGS) $(DFLAGS) $(IFLAGS) test/cgiProgram.c

#
#   config.o
#
DEPS_17 += src/appweb.h
DEPS_17 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/config.o: \
    src/config.c $(DEPS_17)
	@echo '   [Compile] $(BUILD)/obj/config.o'
	$(CC) -c -o $(BUILD)/obj/config.o $(CFLAGS) $(DFLAGS) -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/config.c

#
#   convenience.o
#
DEPS_18 += src/appweb.h

$(BUILD)/obj/convenience.o: \
    src/convenience.c $(DEPS_18)
	@echo '   [Compile] $(BUILD)/obj/convenience.o'
	$(CC) -c -o $(BUILD)/obj/convenience.o $(CFLAGS) $(DFLAGS) -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/convenience.c

#
#   esp.h
#

src/esp/esp.h: $(DEPS_19)

#
#   esp.o
#
DEPS_20 += src/esp/esp.h
DEPS_20 += $(BUILD)/inc/mpr-version.h

$(BUILD)/obj/esp.o: \
    src/esp/esp.c $(DEPS_20)
	@echo '   [Compile] $(BUILD)/obj/esp.o'
	$(CC) -c -o $(BUILD)/obj/esp.o $(CFLAGS) $(DFLAGS) -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/esp/esp.c

#
#   espHandler.o
#
DEPS_21 += src/appweb.h
DEPS_21 += $(BUILD)/inc/esp.h

$(BUILD)/obj/espHandler.o: \
    src/modules/espHandler.c $(DEPS_21)
	@echo '   [Compile] $(BUILD)/obj/espHandler.o'
	$(CC) -c -o $(BUILD)/obj/espHandler.o $(CFLAGS) $(DFLAGS) -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/modules/espHandler.c

#
#   espLib.o
#
DEPS_22 += src/esp/esp.h
DEPS_22 += $(BUILD)/inc/pcre.h
DEPS_22 += $(BUILD)/inc/http.h

$(BUILD)/obj/espLib.o: \
    src/esp/espLib.c $(DEPS_22)
	@echo '   [Compile] $(BUILD)/obj/espLib.o'
	$(CC) -c -o $(BUILD)/obj/espLib.o $(CFLAGS) $(DFLAGS) -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/esp/espLib.c

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
	$(CC) -c -o $(BUILD)/obj/http.o $(CFLAGS) $(DFLAGS) -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/http/http.c

#
#   httpLib.o
#
DEPS_25 += src/http/http.h
DEPS_25 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/httpLib.o: \
    src/http/httpLib.c $(DEPS_25)
	@echo '   [Compile] $(BUILD)/obj/httpLib.o'
	$(CC) -c -o $(BUILD)/obj/httpLib.o $(CFLAGS) $(DFLAGS) -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/http/httpLib.c

#
#   mbedtls.h
#

src/mbedtls/mbedtls.h: $(DEPS_26)

#
#   mbedtls.o
#
DEPS_27 += src/mbedtls/mbedtls.h

$(BUILD)/obj/mbedtls.o: \
    src/mbedtls/mbedtls.c $(DEPS_27)
	@echo '   [Compile] $(BUILD)/obj/mbedtls.o'
	$(CC) -c -o $(BUILD)/obj/mbedtls.o $(CFLAGS) $(DFLAGS) -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/mbedtls/mbedtls.c

#
#   mpr-mbedtls.o
#
DEPS_28 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/mpr-mbedtls.o: \
    src/mpr-mbedtls/mpr-mbedtls.c $(DEPS_28)
	@echo '   [Compile] $(BUILD)/obj/mpr-mbedtls.o'
	$(CC) -c -o $(BUILD)/obj/mpr-mbedtls.o $(CFLAGS) $(DFLAGS) -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/mpr-mbedtls/mpr-mbedtls.c

#
#   mpr-openssl.o
#
DEPS_29 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/mpr-openssl.o: \
    src/mpr-openssl/mpr-openssl.c $(DEPS_29)
	@echo '   [Compile] $(BUILD)/obj/mpr-openssl.o'
	$(CC) -c -o $(BUILD)/obj/mpr-openssl.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/mpr-openssl/mpr-openssl.c

#
#   mpr-version.h
#

src/mpr-version/mpr-version.h: $(DEPS_30)

#
#   mpr-version.o
#
DEPS_31 += src/mpr-version/mpr-version.h
DEPS_31 += $(BUILD)/inc/pcre.h

$(BUILD)/obj/mpr-version.o: \
    src/mpr-version/mpr-version.c $(DEPS_31)
	@echo '   [Compile] $(BUILD)/obj/mpr-version.o'
	$(CC) -c -o $(BUILD)/obj/mpr-version.o $(CFLAGS) $(DFLAGS) -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/mpr-version/mpr-version.c

#
#   mpr.h
#

src/mpr/mpr.h: $(DEPS_32)

#
#   mprLib.o
#
DEPS_33 += src/mpr/mpr.h

$(BUILD)/obj/mprLib.o: \
    src/mpr/mprLib.c $(DEPS_33)
	@echo '   [Compile] $(BUILD)/obj/mprLib.o'
	$(CC) -c -o $(BUILD)/obj/mprLib.o $(CFLAGS) $(DFLAGS) -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/mpr/mprLib.c

#
#   pcre.h
#

src/pcre/pcre.h: $(DEPS_34)

#
#   pcre.o
#
DEPS_35 += $(BUILD)/inc/me.h
DEPS_35 += src/pcre/pcre.h

$(BUILD)/obj/pcre.o: \
    src/pcre/pcre.c $(DEPS_35)
	@echo '   [Compile] $(BUILD)/obj/pcre.o'
	$(CC) -c -o $(BUILD)/obj/pcre.o $(CFLAGS) $(DFLAGS) $(IFLAGS) src/pcre/pcre.c

#
#   romFiles.o
#
DEPS_36 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/romFiles.o: \
    src/romFiles.c $(DEPS_36)
	@echo '   [Compile] $(BUILD)/obj/romFiles.o'
	$(CC) -c -o $(BUILD)/obj/romFiles.o $(CFLAGS) $(DFLAGS) -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/romFiles.c

#
#   watchdog.o
#
DEPS_37 += $(BUILD)/inc/mpr.h

$(BUILD)/obj/watchdog.o: \
    src/watchdog/watchdog.c $(DEPS_37)
	@echo '   [Compile] $(BUILD)/obj/watchdog.o'
	$(CC) -c -o $(BUILD)/obj/watchdog.o $(CFLAGS) $(DFLAGS) -D_FILE_OFFSET_BITS=64 -DMBEDTLS_USER_CONFIG_FILE=\"embedtls.h\" $(IFLAGS) src/watchdog/watchdog.c

ifeq ($(ME_COM_MBEDTLS),1)
#
#   libmbedtls
#
DEPS_38 += $(BUILD)/inc/osdep.h
DEPS_38 += $(BUILD)/inc/embedtls.h
DEPS_38 += $(BUILD)/inc/mbedtls.h
DEPS_38 += $(BUILD)/obj/mbedtls.o

$(BUILD)/bin/libmbedtls.a: $(DEPS_38)
	@echo '      [Link] $(BUILD)/bin/libmbedtls.a'
	arundefined -cr $(BUILD)/bin/libmbedtls.a "$(BUILD)/obj/mbedtls.o"
endif

ifeq ($(ME_COM_MBEDTLS),1)
#
#   libmpr-mbedtls
#
DEPS_39 += $(BUILD)/bin/libmbedtls.a
DEPS_39 += $(BUILD)/obj/mpr-mbedtls.o

$(BUILD)/bin/libmpr-mbedtls.a: $(DEPS_39)
	@echo '      [Link] $(BUILD)/bin/libmpr-mbedtls.a'
	arundefined -cr $(BUILD)/bin/libmpr-mbedtls.a "$(BUILD)/obj/mpr-mbedtls.o"
endif

ifeq ($(ME_COM_OPENSSL),1)
#
#   libmpr-openssl
#
DEPS_40 += $(BUILD)/obj/mpr-openssl.o

$(BUILD)/bin/libmpr-openssl.a: $(DEPS_40)
	@echo '      [Link] $(BUILD)/bin/libmpr-openssl.a'
	arundefined -cr $(BUILD)/bin/libmpr-openssl.a "$(BUILD)/obj/mpr-openssl.o"
endif

#
#   libmpr
#
DEPS_41 += $(BUILD)/inc/osdep.h
ifeq ($(ME_COM_MBEDTLS),1)
    DEPS_41 += $(BUILD)/bin/libmpr-mbedtls.a
endif
ifeq ($(ME_COM_MBEDTLS),1)
    DEPS_41 += $(BUILD)/bin/libmbedtls.a
endif
ifeq ($(ME_COM_OPENSSL),1)
    DEPS_41 += $(BUILD)/bin/libmpr-openssl.a
endif
DEPS_41 += $(BUILD)/inc/mpr.h
DEPS_41 += $(BUILD)/obj/mprLib.o

$(BUILD)/bin/libmpr.a: $(DEPS_41)
	@echo '      [Link] $(BUILD)/bin/libmpr.a'
	arundefined -cr $(BUILD)/bin/libmpr.a "$(BUILD)/obj/mprLib.o"

ifeq ($(ME_COM_PCRE),1)
#
#   libpcre
#
DEPS_42 += $(BUILD)/inc/pcre.h
DEPS_42 += $(BUILD)/obj/pcre.o

$(BUILD)/bin/libpcre.a: $(DEPS_42)
	@echo '      [Link] $(BUILD)/bin/libpcre.a'
	arundefined -cr $(BUILD)/bin/libpcre.a "$(BUILD)/obj/pcre.o"
endif

ifeq ($(ME_COM_HTTP),1)
#
#   libhttp
#
DEPS_43 += $(BUILD)/bin/libmpr.a
ifeq ($(ME_COM_PCRE),1)
    DEPS_43 += $(BUILD)/bin/libpcre.a
endif
DEPS_43 += $(BUILD)/inc/http.h
DEPS_43 += $(BUILD)/obj/httpLib.o

$(BUILD)/bin/libhttp.a: $(DEPS_43)
	@echo '      [Link] $(BUILD)/bin/libhttp.a'
	arundefined -cr $(BUILD)/bin/libhttp.a "$(BUILD)/obj/httpLib.o"
endif

#
#   libmpr-version
#
DEPS_44 += $(BUILD)/bin/libmpr.a
ifeq ($(ME_COM_PCRE),1)
    DEPS_44 += $(BUILD)/bin/libpcre.a
endif
DEPS_44 += $(BUILD)/inc/mpr-version.h
DEPS_44 += $(BUILD)/obj/mpr-version.o

$(BUILD)/bin/libmpr-version.a: $(DEPS_44)
	@echo '      [Link] $(BUILD)/bin/libmpr-version.a'
	arundefined -cr $(BUILD)/bin/libmpr-version.a "$(BUILD)/obj/mpr-version.o"

ifeq ($(ME_COM_ESP),1)
#
#   libesp
#
ifeq ($(ME_COM_HTTP),1)
    DEPS_45 += $(BUILD)/bin/libhttp.a
endif
DEPS_45 += $(BUILD)/bin/libmpr-version.a
DEPS_45 += $(BUILD)/inc/esp.h
DEPS_45 += $(BUILD)/obj/espLib.o

$(BUILD)/bin/libesp.a: $(DEPS_45)
	@echo '      [Link] $(BUILD)/bin/libesp.a'
	arundefined -cr $(BUILD)/bin/libesp.a "$(BUILD)/obj/espLib.o"
endif

#
#   libappweb
#
ifeq ($(ME_COM_ESP),1)
    DEPS_46 += $(BUILD)/bin/libesp.a
endif
ifeq ($(ME_COM_HTTP),1)
    DEPS_46 += $(BUILD)/bin/libhttp.a
endif
DEPS_46 += $(BUILD)/bin/libmpr.a
DEPS_46 += $(BUILD)/inc/appweb.h
DEPS_46 += $(BUILD)/inc/customize.h
DEPS_46 += $(BUILD)/obj/config.o
DEPS_46 += $(BUILD)/obj/convenience.o
DEPS_46 += $(BUILD)/obj/romFiles.o
DEPS_46 += $(BUILD)/obj/cgiHandler.o
DEPS_46 += $(BUILD)/obj/espHandler.o

$(BUILD)/bin/libappweb.a: $(DEPS_46)
	@echo '      [Link] $(BUILD)/bin/libappweb.a'
	arundefined -cr $(BUILD)/bin/libappweb.a "$(BUILD)/obj/config.o" "$(BUILD)/obj/convenience.o" "$(BUILD)/obj/romFiles.o" "$(BUILD)/obj/cgiHandler.o" "$(BUILD)/obj/espHandler.o"

#
#   appweb
#
DEPS_47 += $(BUILD)/bin/libappweb.a
DEPS_47 += $(BUILD)/obj/appweb.o

ifeq ($(ME_COM_MBEDTLS),1)
    LIBS_47 += -lmbedtls
endif
ifeq ($(ME_COM_MBEDTLS),1)
    LIBS_47 += -lmpr-mbedtls
endif
ifeq ($(ME_COM_MBEDTLS),1)
    LIBS_47 += -lmbedtls
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_47 += -lmpr-openssl
endif
LIBS_47 += -lmpr
ifeq ($(ME_COM_MBEDTLS),1)
    LIBS_47 += -lmpr-mbedtls
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_47 += -lpcre
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_47 += -lhttp
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_47 += -lpcre
endif
LIBS_47 += -lmpr
LIBS_47 += -lmpr-version
ifeq ($(ME_COM_ESP),1)
    LIBS_47 += -lesp
endif
LIBS_47 += -lmpr-version
ifeq ($(ME_COM_HTTP),1)
    LIBS_47 += -lhttp
endif
LIBS_47 += -lappweb
ifeq ($(ME_COM_ESP),1)
    LIBS_47 += -lesp
endif

$(BUILD)/bin/appweb.out: $(DEPS_47)
	@echo '      [Link] $(BUILD)/bin/appweb.out'
	$(CC) -o $(BUILD)/bin/appweb.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/appweb.o" $(LIBPATHS_47) $(LIBS_47) $(LIBS_47) $(LIBS) -Wl,-r 

#
#   authpass
#
DEPS_48 += $(BUILD)/bin/libappweb.a
DEPS_48 += $(BUILD)/obj/authpass.o

ifeq ($(ME_COM_MBEDTLS),1)
    LIBS_48 += -lmbedtls
endif
ifeq ($(ME_COM_MBEDTLS),1)
    LIBS_48 += -lmpr-mbedtls
endif
ifeq ($(ME_COM_MBEDTLS),1)
    LIBS_48 += -lmbedtls
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_48 += -lmpr-openssl
endif
LIBS_48 += -lmpr
ifeq ($(ME_COM_MBEDTLS),1)
    LIBS_48 += -lmpr-mbedtls
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_48 += -lpcre
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_48 += -lhttp
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_48 += -lpcre
endif
LIBS_48 += -lmpr
LIBS_48 += -lmpr-version
ifeq ($(ME_COM_ESP),1)
    LIBS_48 += -lesp
endif
LIBS_48 += -lmpr-version
ifeq ($(ME_COM_HTTP),1)
    LIBS_48 += -lhttp
endif
LIBS_48 += -lappweb
ifeq ($(ME_COM_ESP),1)
    LIBS_48 += -lesp
endif

$(BUILD)/bin/authpass.out: $(DEPS_48)
	@echo '      [Link] $(BUILD)/bin/authpass.out'
	$(CC) -o $(BUILD)/bin/authpass.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/authpass.o" $(LIBPATHS_48) $(LIBS_48) $(LIBS_48) $(LIBS) -Wl,-r 

ifeq ($(ME_COM_ESP),1)
#
#   espcmd
#
DEPS_49 += $(BUILD)/bin/libesp.a
DEPS_49 += $(BUILD)/obj/esp.o

ifeq ($(ME_COM_MBEDTLS),1)
    LIBS_49 += -lmbedtls
endif
ifeq ($(ME_COM_MBEDTLS),1)
    LIBS_49 += -lmpr-mbedtls
endif
ifeq ($(ME_COM_MBEDTLS),1)
    LIBS_49 += -lmbedtls
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_49 += -lmpr-openssl
endif
LIBS_49 += -lmpr
ifeq ($(ME_COM_MBEDTLS),1)
    LIBS_49 += -lmpr-mbedtls
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_49 += -lpcre
endif
ifeq ($(ME_COM_HTTP),1)
    LIBS_49 += -lhttp
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_49 += -lpcre
endif
LIBS_49 += -lmpr
LIBS_49 += -lmpr-version
LIBS_49 += -lesp
LIBS_49 += -lmpr-version
ifeq ($(ME_COM_HTTP),1)
    LIBS_49 += -lhttp
endif

$(BUILD)/bin/appweb-esp.out: $(DEPS_49)
	@echo '      [Link] $(BUILD)/bin/appweb-esp.out'
	$(CC) -o $(BUILD)/bin/appweb-esp.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/esp.o" $(LIBPATHS_49) $(LIBS_49) $(LIBS_49) $(LIBS) -Wl,-r 
endif

ifeq ($(ME_COM_ESP),1)
#
#   extras
#
DEPS_50 += src/esp/esp-compile.json
DEPS_50 += src/esp/vcvars.bat

$(BUILD)/.extras-modified: $(DEPS_50)
	@echo '      [Copy] $(BUILD)/bin'
	mkdir -p "$(BUILD)/bin"
	cp src/esp/esp-compile.json $(BUILD)/bin/esp-compile.json
	cp src/esp/vcvars.bat $(BUILD)/bin/vcvars.bat
	touch "$(BUILD)/.extras-modified"
endif

ifeq ($(ME_COM_HTTP),1)
#
#   httpcmd
#
DEPS_51 += $(BUILD)/bin/libhttp.a
DEPS_51 += $(BUILD)/obj/http.o

ifeq ($(ME_COM_MBEDTLS),1)
    LIBS_51 += -lmbedtls
endif
ifeq ($(ME_COM_MBEDTLS),1)
    LIBS_51 += -lmpr-mbedtls
endif
ifeq ($(ME_COM_MBEDTLS),1)
    LIBS_51 += -lmbedtls
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_51 += -lmpr-openssl
endif
LIBS_51 += -lmpr
ifeq ($(ME_COM_MBEDTLS),1)
    LIBS_51 += -lmpr-mbedtls
endif
ifeq ($(ME_COM_PCRE),1)
    LIBS_51 += -lpcre
endif
LIBS_51 += -lhttp
ifeq ($(ME_COM_PCRE),1)
    LIBS_51 += -lpcre
endif
LIBS_51 += -lmpr

$(BUILD)/bin/http.out: $(DEPS_51)
	@echo '      [Link] $(BUILD)/bin/http.out'
	$(CC) -o $(BUILD)/bin/http.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/http.o" $(LIBPATHS_51) $(LIBS_51) $(LIBS_51) $(LIBS) -Wl,-r 
endif

#
#   install-certs
#
DEPS_52 += src/certs/samples/ca.crt
DEPS_52 += src/certs/samples/ca.key
DEPS_52 += src/certs/samples/ec.crt
DEPS_52 += src/certs/samples/ec.key
DEPS_52 += src/certs/samples/roots.crt
DEPS_52 += src/certs/samples/self.crt
DEPS_52 += src/certs/samples/self.key
DEPS_52 += src/certs/samples/test.crt
DEPS_52 += src/certs/samples/test.key

$(BUILD)/.install-certs-modified: $(DEPS_52)
	@echo '      [Copy] $(BUILD)/bin'
	mkdir -p "$(BUILD)/bin"
	cp src/certs/samples/ca.crt $(BUILD)/bin/ca.crt
	cp src/certs/samples/ca.key $(BUILD)/bin/ca.key
	cp src/certs/samples/ec.crt $(BUILD)/bin/ec.crt
	cp src/certs/samples/ec.key $(BUILD)/bin/ec.key
	cp src/certs/samples/roots.crt $(BUILD)/bin/roots.crt
	cp src/certs/samples/self.crt $(BUILD)/bin/self.crt
	cp src/certs/samples/self.key $(BUILD)/bin/self.key
	cp src/certs/samples/test.crt $(BUILD)/bin/test.crt
	cp src/certs/samples/test.key $(BUILD)/bin/test.key
	touch "$(BUILD)/.install-certs-modified"

#
#   server-cache
#

src/server/cache: $(DEPS_53)
	( \
	cd src/server; \
	mkdir -p "cache" ; \
	)

ifeq ($(ME_COM_WATCHDOG),1)
#
#   watchdog
#
DEPS_54 += $(BUILD)/bin/libmpr.a
DEPS_54 += $(BUILD)/obj/watchdog.o

ifeq ($(ME_COM_MBEDTLS),1)
    LIBS_54 += -lmbedtls
endif
ifeq ($(ME_COM_MBEDTLS),1)
    LIBS_54 += -lmpr-mbedtls
endif
ifeq ($(ME_COM_MBEDTLS),1)
    LIBS_54 += -lmbedtls
endif
ifeq ($(ME_COM_OPENSSL),1)
    LIBS_54 += -lmpr-openssl
endif
LIBS_54 += -lmpr
ifeq ($(ME_COM_MBEDTLS),1)
    LIBS_54 += -lmpr-mbedtls
endif

$(BUILD)/bin/appman.out: $(DEPS_54)
	@echo '      [Link] $(BUILD)/bin/appman.out'
	$(CC) -o $(BUILD)/bin/appman.out $(LDFLAGS) $(LIBPATHS) "$(BUILD)/obj/watchdog.o" $(LIBPATHS_54) $(LIBS_54) $(LIBS_54) $(LIBS) -Wl,-r 
endif

#
#   installBinary
#

installBinary: $(DEPS_55)

#
#   install
#
DEPS_56 += stop
DEPS_56 += installBinary
DEPS_56 += start

install: $(DEPS_56)

#
#   installPrep
#

installPrep: $(DEPS_57)
	if [ "`id -u`" != 0 ] ; \
	then echo "Must run as root. Rerun with "sudo"" ; \
	exit 255 ; \
	fi

#
#   run
#

run: $(DEPS_58)
	( \
	cd src/server; \
	../../$(BUILD)/bin/appweb --log stdout:2 ; \
	)

#
#   uninstall
#
DEPS_59 += stop

uninstall: $(DEPS_59)
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

version: $(DEPS_60)
	echo $(VERSION)

