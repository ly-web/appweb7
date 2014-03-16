#
#   appweb-vxworks-default.mk -- Makefile to build Embedthis Appweb for vxworks
#

NAME                  := appweb
VERSION               := 5.0.0-rc0
PROFILE               ?= default
ARCH                  ?= $(shell echo $(WIND_HOST_TYPE) | sed 's/-.*//')
CPU                   ?= $(subst X86,PENTIUM,$(shell echo $(ARCH) | tr a-z A-Z))
OS                    ?= vxworks
CC                    ?= cc$(subst x86,pentium,$(ARCH))
LD                    ?= link
CONFIG                ?= $(OS)-$(ARCH)-$(PROFILE)
LBIN                  ?= $(CONFIG)/bin
PATH                  := $(LBIN):$(PATH)

ME_EXT_CGI            ?= 1
ME_EXT_EJS            ?= 0
ME_EXT_ESP            ?= 1
ME_EXT_EST            ?= 1
ME_EXT_MATRIXSSL      ?= 0
ME_EXT_MDB            ?= 1
ME_EXT_NANOSSL        ?= 0
ME_EXT_OPENSSL        ?= 0
ME_EXT_PCRE           ?= 1
ME_EXT_PHP            ?= 0
ME_EXT_SQLITE         ?= 0
ME_EXT_SSL            ?= 1
ME_EXT_ZLIB           ?= 1

ME_EXT_CGI_PATH       ?= src/modules/cgiHandler.c
ME_EXT_COMPILER_PATH  ?= cc$(subst x86,pentium,$(ARCH))
ME_EXT_DIR_PATH       ?= src/dirHandler.c
ME_EXT_DOXYGEN_PATH   ?= doxygen
ME_EXT_DSI_PATH       ?= dsi
ME_EXT_EJS_PATH       ?= ejs
ME_EXT_ESP_PATH       ?= src/paks/esp
ME_EXT_EST_PATH       ?= src/paks/est/estLib.c
ME_EXT_GZIP_PATH      ?= gzip
ME_EXT_HTMLMIN_PATH   ?= htmlmin
ME_EXT_HTTP_PATH      ?= src/paks/http
ME_EXT_LIB_PATH       ?= ar
ME_EXT_LINK_PATH      ?= link
ME_EXT_MAN_PATH       ?= man
ME_EXT_MAN2HTML_PATH  ?= man2html
ME_EXT_MATRIXSSL_PATH ?= /usr/src/matrixssl
ME_EXT_MDB_PATH       ?= src/paks/esp/mdb.c
ME_EXT_MPR_PATH       ?= src/paks/mpr
ME_EXT_NANOSSL_PATH   ?= /usr/src/nanossl
ME_EXT_NGMIN_PATH     ?= ngmin
ME_EXT_OPENSSL_PATH   ?= /usr/src/openssl
ME_EXT_OSDEP_PATH     ?= src/paks/osdep
ME_EXT_PAK_PATH       ?= pak
ME_EXT_PCRE_PATH      ?= src/paks/pcre
ME_EXT_PHP_PATH       ?= php
ME_EXT_PMAKER_PATH    ?= pmaker
ME_EXT_RECESS_PATH    ?= recess
ME_EXT_SQLITE_PATH    ?= sqlite
ME_EXT_SSL_PATH       ?= ssl
ME_EXT_UGLIFYJS_PATH  ?= uglifyjs
ME_EXT_UTEST_PATH     ?= utest
ME_EXT_VXWORKS_PATH   ?= $(WIND_BASE)
ME_EXT_WINSDK_PATH    ?= winsdk
ME_EXT_ZIP_PATH       ?= zip

export WIND_HOME      ?= $(WIND_BASE)/..
export PATH           := $(WIND_GNU_PATH)/$(WIND_HOST_TYPE)/bin:$(PATH)

CFLAGS                += -fno-builtin -fno-defer-pop -fvolatile -w
DFLAGS                += -DVXWORKS -DRW_MULTI_THREAD -D_GNU_TOOL -DCPU=PENTIUM $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_EXT_CGI=$(ME_EXT_CGI) -DME_EXT_EJS=$(ME_EXT_EJS) -DME_EXT_ESP=$(ME_EXT_ESP) -DME_EXT_EST=$(ME_EXT_EST) -DME_EXT_MATRIXSSL=$(ME_EXT_MATRIXSSL) -DME_EXT_MDB=$(ME_EXT_MDB) -DME_EXT_NANOSSL=$(ME_EXT_NANOSSL) -DME_EXT_OPENSSL=$(ME_EXT_OPENSSL) -DME_EXT_PCRE=$(ME_EXT_PCRE) -DME_EXT_PHP=$(ME_EXT_PHP) -DME_EXT_SQLITE=$(ME_EXT_SQLITE) -DME_EXT_SSL=$(ME_EXT_SSL) -DME_EXT_ZLIB=$(ME_EXT_ZLIB) 
IFLAGS                += "-I$(CONFIG)/inc -I$(WIND_BASE)/target/h -I$(WIND_BASE)/target/h/wrn/coreip"
LDFLAGS               += '-Wl,-r'
LIBPATHS              += -L$(CONFIG)/bin
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


ifeq ($(ME_EXT_ESP),1)
    TARGETS           += $(CONFIG)/bin/libmod_esp.out
endif
ifeq ($(ME_EXT_ESP),1)
    TARGETS           += $(CONFIG)/bin/esp.out
endif
ifeq ($(ME_EXT_ESP),1)
    TARGETS           += $(CONFIG)/bin/esp.conf
endif
ifeq ($(ME_EXT_ESP),1)
    TARGETS           += $(CONFIG)/paks
endif
ifeq ($(ME_EXT_EST),1)
    TARGETS           += $(CONFIG)/bin/libest.out
endif
TARGETS               += $(CONFIG)/bin/ca.crt
TARGETS               += $(CONFIG)/bin/httpcmd.out
TARGETS               += $(CONFIG)/bin/libmprssl.out
TARGETS               += $(CONFIG)/bin/appman.out
ifeq ($(ME_EXT_ZLIB),1)
    TARGETS           += $(CONFIG)/bin/libzlib.out
endif
TARGETS               += src/slink.c
TARGETS               += $(CONFIG)/bin/libslink.out
ifeq ($(ME_EXT_CGI),1)
    TARGETS           += $(CONFIG)/bin/libmod_cgi.out
endif
ifeq ($(ME_EXT_SSL),1)
    TARGETS           += $(CONFIG)/bin/libmod_ssl.out
endif
TARGETS               += $(CONFIG)/bin/authpass.out
ifeq ($(ME_EXT_CGI),1)
    TARGETS           += $(CONFIG)/bin/cgiProgram.out
endif
TARGETS               += $(CONFIG)/bin/appweb.out
TARGETS               += src/server/cache
TARGETS               += $(CONFIG)/bin/testAppweb.out
ifeq ($(ME_EXT_CGI),1)
    TARGETS           += test/cgi-bin/testScript
endif
ifeq ($(ME_EXT_CGI),1)
    TARGETS           += test/web/caching/cache.cgi
endif
ifeq ($(ME_EXT_CGI),1)
    TARGETS           += test/web/auth/basic/basic.cgi
endif
ifeq ($(ME_EXT_CGI),1)
    TARGETS           += test/cgi-bin/cgiProgram.out
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
	@if [ "$(WIND_BASE)" = "" ] ; then echo WARNING: WIND_BASE not set. Run wrenv.sh. ; exit 255 ; fi
	@if [ "$(WIND_HOST_TYPE)" = "" ] ; then echo WARNING: WIND_HOST_TYPE not set. Run wrenv.sh. ; exit 255 ; fi
	@if [ "$(WIND_GNU_PATH)" = "" ] ; then echo WARNING: WIND_GNU_PATH not set. Run wrenv.sh. ; exit 255 ; fi
	@[ ! -x $(CONFIG)/bin ] && mkdir -p $(CONFIG)/bin; true
	@[ ! -x $(CONFIG)/inc ] && mkdir -p $(CONFIG)/inc; true
	@[ ! -x $(CONFIG)/obj ] && mkdir -p $(CONFIG)/obj; true
	@[ ! -f $(CONFIG)/inc/osdep.h ] && cp src/paks/osdep/osdep.h $(CONFIG)/inc/osdep.h ; true
	@if ! diff $(CONFIG)/inc/osdep.h src/paks/osdep/osdep.h >/dev/null ; then\
		cp src/paks/osdep/osdep.h $(CONFIG)/inc/osdep.h  ; \
	fi; true
	@[ ! -f $(CONFIG)/inc/me.h ] && cp projects/appweb-vxworks-default-me.h $(CONFIG)/inc/me.h ; true
	@if ! diff $(CONFIG)/inc/me.h projects/appweb-vxworks-default-me.h >/dev/null ; then\
		cp projects/appweb-vxworks-default-me.h $(CONFIG)/inc/me.h  ; \
	fi; true
	@if [ -f "$(CONFIG)/.makeflags" ] ; then \
		if [ "$(MAKEFLAGS)" != " ` cat $(CONFIG)/.makeflags`" ] ; then \
			echo "   [Warning] Make flags have changed since the last build: "`cat $(CONFIG)/.makeflags`"" ; \
		fi ; \
	fi
	@echo $(MAKEFLAGS) >$(CONFIG)/.makeflags

clean:
	rm -f "$(CONFIG)/bin/libmod_esp.out"
	rm -f "$(CONFIG)/bin/esp.out"
	rm -f "$(CONFIG)/bin/esp.conf"
	rm -f "$(CONFIG)/bin/libest.out"
	rm -f "$(CONFIG)/bin/ca.crt"
	rm -f "$(CONFIG)/bin/libhttp.out"
	rm -f "$(CONFIG)/bin/httpcmd.out"
	rm -f "$(CONFIG)/bin/libmpr.out"
	rm -f "$(CONFIG)/bin/libmprssl.out"
	rm -f "$(CONFIG)/bin/appman.out"
	rm -f "$(CONFIG)/bin/makerom.out"
	rm -f "$(CONFIG)/bin/libpcre.out"
	rm -f "$(CONFIG)/bin/libzlib.out"
	rm -f "$(CONFIG)/bin/libappweb.out"
	rm -f "$(CONFIG)/bin/libslink.out"
	rm -f "$(CONFIG)/bin/libmod_cgi.out"
	rm -f "$(CONFIG)/bin/libmod_ssl.out"
	rm -f "$(CONFIG)/bin/authpass.out"
	rm -f "$(CONFIG)/bin/cgiProgram.out"
	rm -f "$(CONFIG)/bin/appweb.out"
	rm -f "$(CONFIG)/bin/testAppweb.out"
	rm -f "$(CONFIG)/obj/espLib.o"
	rm -f "$(CONFIG)/obj/esp.o"
	rm -f "$(CONFIG)/obj/estLib.o"
	rm -f "$(CONFIG)/obj/httpLib.o"
	rm -f "$(CONFIG)/obj/http.o"
	rm -f "$(CONFIG)/obj/mprLib.o"
	rm -f "$(CONFIG)/obj/mprSsl.o"
	rm -f "$(CONFIG)/obj/manager.o"
	rm -f "$(CONFIG)/obj/makerom.o"
	rm -f "$(CONFIG)/obj/pcre.o"
	rm -f "$(CONFIG)/obj/zlib.o"
	rm -f "$(CONFIG)/obj/config.o"
	rm -f "$(CONFIG)/obj/convenience.o"
	rm -f "$(CONFIG)/obj/dirHandler.o"
	rm -f "$(CONFIG)/obj/fileHandler.o"
	rm -f "$(CONFIG)/obj/log.o"
	rm -f "$(CONFIG)/obj/server.o"
	rm -f "$(CONFIG)/obj/slink.o"
	rm -f "$(CONFIG)/obj/cgiHandler.o"
	rm -f "$(CONFIG)/obj/sslModule.o"
	rm -f "$(CONFIG)/obj/authpass.o"
	rm -f "$(CONFIG)/obj/cgiProgram.o"
	rm -f "$(CONFIG)/obj/appweb.o"
	rm -f "$(CONFIG)/obj/testAppweb.o"
	rm -f "$(CONFIG)/obj/testHttp.o"

clobber: clean
	rm -fr ./$(CONFIG)



#
#   version
#
version: $(DEPS_1)
	echo 5.0.0-rc0

#
#   mpr.h
#
$(CONFIG)/inc/mpr.h: $(DEPS_2)
	@echo '      [Copy] $(CONFIG)/inc/mpr.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/mpr/mpr.h $(CONFIG)/inc/mpr.h

#
#   me.h
#
$(CONFIG)/inc/me.h: $(DEPS_3)
	@echo '      [Copy] $(CONFIG)/inc/me.h'

#
#   osdep.h
#
$(CONFIG)/inc/osdep.h: $(DEPS_4)
	@echo '      [Copy] $(CONFIG)/inc/osdep.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/osdep/osdep.h $(CONFIG)/inc/osdep.h

#
#   mprLib.o
#
DEPS_5 += $(CONFIG)/inc/me.h
DEPS_5 += $(CONFIG)/inc/mpr.h
DEPS_5 += $(CONFIG)/inc/osdep.h

$(CONFIG)/obj/mprLib.o: \
    src/paks/mpr/mprLib.c $(DEPS_5)
	@echo '   [Compile] $(CONFIG)/obj/mprLib.o'
	 -c -o $(CONFIG)/obj/mprLib.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/mpr/mprLib.c

#
#   libmpr
#
DEPS_6 += $(CONFIG)/inc/mpr.h
DEPS_6 += $(CONFIG)/inc/me.h
DEPS_6 += $(CONFIG)/inc/osdep.h
DEPS_6 += $(CONFIG)/obj/mprLib.o

$(CONFIG)/bin/libmpr.out: $(DEPS_6)
	@echo '      [Link] $(CONFIG)/bin/libmpr.out'
	 -r -o $(CONFIG)/bin/libmpr.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/mprLib.o" $(LIBS) 

#
#   pcre.h
#
$(CONFIG)/inc/pcre.h: $(DEPS_7)
	@echo '      [Copy] $(CONFIG)/inc/pcre.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/pcre/pcre.h $(CONFIG)/inc/pcre.h

#
#   pcre.o
#
DEPS_8 += $(CONFIG)/inc/me.h
DEPS_8 += $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/pcre.o: \
    src/paks/pcre/pcre.c $(DEPS_8)
	@echo '   [Compile] $(CONFIG)/obj/pcre.o'
	 -c -o $(CONFIG)/obj/pcre.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/pcre/pcre.c

ifeq ($(ME_EXT_PCRE),1)
#
#   libpcre
#
DEPS_9 += $(CONFIG)/inc/pcre.h
DEPS_9 += $(CONFIG)/inc/me.h
DEPS_9 += $(CONFIG)/obj/pcre.o

$(CONFIG)/bin/libpcre.out: $(DEPS_9)
	@echo '      [Link] $(CONFIG)/bin/libpcre.out'
	 -r -o $(CONFIG)/bin/libpcre.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/pcre.o" $(LIBS) 
endif

#
#   http.h
#
$(CONFIG)/inc/http.h: $(DEPS_10)
	@echo '      [Copy] $(CONFIG)/inc/http.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/http/http.h $(CONFIG)/inc/http.h

#
#   httpLib.o
#
DEPS_11 += $(CONFIG)/inc/me.h
DEPS_11 += $(CONFIG)/inc/http.h
DEPS_11 += $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/httpLib.o: \
    src/paks/http/httpLib.c $(DEPS_11)
	@echo '   [Compile] $(CONFIG)/obj/httpLib.o'
	 -c -o $(CONFIG)/obj/httpLib.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/http/httpLib.c

#
#   libhttp
#
DEPS_12 += $(CONFIG)/inc/mpr.h
DEPS_12 += $(CONFIG)/inc/me.h
DEPS_12 += $(CONFIG)/inc/osdep.h
DEPS_12 += $(CONFIG)/obj/mprLib.o
DEPS_12 += $(CONFIG)/bin/libmpr.out
DEPS_12 += $(CONFIG)/inc/pcre.h
DEPS_12 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_12 += $(CONFIG)/bin/libpcre.out
endif
DEPS_12 += $(CONFIG)/inc/http.h
DEPS_12 += $(CONFIG)/obj/httpLib.o

$(CONFIG)/bin/libhttp.out: $(DEPS_12)
	@echo '      [Link] $(CONFIG)/bin/libhttp.out'
	 -r -o $(CONFIG)/bin/libhttp.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/httpLib.o" $(LIBS) 

#
#   appweb.h
#
$(CONFIG)/inc/appweb.h: $(DEPS_13)
	@echo '      [Copy] $(CONFIG)/inc/appweb.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/appweb.h $(CONFIG)/inc/appweb.h

#
#   customize.h
#
$(CONFIG)/inc/customize.h: $(DEPS_14)
	@echo '      [Copy] $(CONFIG)/inc/customize.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/customize.h $(CONFIG)/inc/customize.h

#
#   config.o
#
DEPS_15 += $(CONFIG)/inc/me.h
DEPS_15 += $(CONFIG)/inc/appweb.h
DEPS_15 += $(CONFIG)/inc/pcre.h
DEPS_15 += $(CONFIG)/inc/mpr.h
DEPS_15 += $(CONFIG)/inc/http.h
DEPS_15 += $(CONFIG)/inc/customize.h

$(CONFIG)/obj/config.o: \
    src/config.c $(DEPS_15)
	@echo '   [Compile] $(CONFIG)/obj/config.o'
	 -c -o $(CONFIG)/obj/config.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/config.c

#
#   convenience.o
#
DEPS_16 += $(CONFIG)/inc/me.h
DEPS_16 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/convenience.o: \
    src/convenience.c $(DEPS_16)
	@echo '   [Compile] $(CONFIG)/obj/convenience.o'
	 -c -o $(CONFIG)/obj/convenience.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/convenience.c

#
#   dirHandler.o
#
DEPS_17 += $(CONFIG)/inc/me.h
DEPS_17 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/dirHandler.o: \
    src/dirHandler.c $(DEPS_17)
	@echo '   [Compile] $(CONFIG)/obj/dirHandler.o'
	 -c -o $(CONFIG)/obj/dirHandler.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/dirHandler.c

#
#   fileHandler.o
#
DEPS_18 += $(CONFIG)/inc/me.h
DEPS_18 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/fileHandler.o: \
    src/fileHandler.c $(DEPS_18)
	@echo '   [Compile] $(CONFIG)/obj/fileHandler.o'
	 -c -o $(CONFIG)/obj/fileHandler.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/fileHandler.c

#
#   log.o
#
DEPS_19 += $(CONFIG)/inc/me.h
DEPS_19 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/log.o: \
    src/log.c $(DEPS_19)
	@echo '   [Compile] $(CONFIG)/obj/log.o'
	 -c -o $(CONFIG)/obj/log.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/log.c

#
#   server.o
#
DEPS_20 += $(CONFIG)/inc/me.h
DEPS_20 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/server.o: \
    src/server.c $(DEPS_20)
	@echo '   [Compile] $(CONFIG)/obj/server.o'
	 -c -o $(CONFIG)/obj/server.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/server.c

#
#   libappweb
#
DEPS_21 += $(CONFIG)/inc/mpr.h
DEPS_21 += $(CONFIG)/inc/me.h
DEPS_21 += $(CONFIG)/inc/osdep.h
DEPS_21 += $(CONFIG)/obj/mprLib.o
DEPS_21 += $(CONFIG)/bin/libmpr.out
DEPS_21 += $(CONFIG)/inc/pcre.h
DEPS_21 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_21 += $(CONFIG)/bin/libpcre.out
endif
DEPS_21 += $(CONFIG)/inc/http.h
DEPS_21 += $(CONFIG)/obj/httpLib.o
DEPS_21 += $(CONFIG)/bin/libhttp.out
DEPS_21 += $(CONFIG)/inc/appweb.h
DEPS_21 += $(CONFIG)/inc/customize.h
DEPS_21 += $(CONFIG)/obj/config.o
DEPS_21 += $(CONFIG)/obj/convenience.o
DEPS_21 += $(CONFIG)/obj/dirHandler.o
DEPS_21 += $(CONFIG)/obj/fileHandler.o
DEPS_21 += $(CONFIG)/obj/log.o
DEPS_21 += $(CONFIG)/obj/server.o

$(CONFIG)/bin/libappweb.out: $(DEPS_21)
	@echo '      [Link] $(CONFIG)/bin/libappweb.out'
	 -r -o $(CONFIG)/bin/libappweb.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/config.o" "$(CONFIG)/obj/convenience.o" "$(CONFIG)/obj/dirHandler.o" "$(CONFIG)/obj/fileHandler.o" "$(CONFIG)/obj/log.o" "$(CONFIG)/obj/server.o" $(LIBS) 

#
#   esp.h
#
$(CONFIG)/inc/esp.h: $(DEPS_22)
	@echo '      [Copy] $(CONFIG)/inc/esp.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/esp/esp.h $(CONFIG)/inc/esp.h

#
#   espLib.o
#
DEPS_23 += $(CONFIG)/inc/me.h
DEPS_23 += $(CONFIG)/inc/esp.h
DEPS_23 += $(CONFIG)/inc/pcre.h
DEPS_23 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/espLib.o: \
    src/paks/esp/espLib.c $(DEPS_23)
	@echo '   [Compile] $(CONFIG)/obj/espLib.o'
	 -c -o $(CONFIG)/obj/espLib.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/esp/espLib.c

ifeq ($(ME_EXT_ESP),1)
#
#   libmod_esp
#
DEPS_24 += $(CONFIG)/inc/mpr.h
DEPS_24 += $(CONFIG)/inc/me.h
DEPS_24 += $(CONFIG)/inc/osdep.h
DEPS_24 += $(CONFIG)/obj/mprLib.o
DEPS_24 += $(CONFIG)/bin/libmpr.out
DEPS_24 += $(CONFIG)/inc/pcre.h
DEPS_24 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_24 += $(CONFIG)/bin/libpcre.out
endif
DEPS_24 += $(CONFIG)/inc/http.h
DEPS_24 += $(CONFIG)/obj/httpLib.o
DEPS_24 += $(CONFIG)/bin/libhttp.out
DEPS_24 += $(CONFIG)/inc/appweb.h
DEPS_24 += $(CONFIG)/inc/customize.h
DEPS_24 += $(CONFIG)/obj/config.o
DEPS_24 += $(CONFIG)/obj/convenience.o
DEPS_24 += $(CONFIG)/obj/dirHandler.o
DEPS_24 += $(CONFIG)/obj/fileHandler.o
DEPS_24 += $(CONFIG)/obj/log.o
DEPS_24 += $(CONFIG)/obj/server.o
DEPS_24 += $(CONFIG)/bin/libappweb.out
DEPS_24 += $(CONFIG)/inc/esp.h
DEPS_24 += $(CONFIG)/obj/espLib.o

$(CONFIG)/bin/libmod_esp.out: $(DEPS_24)
	@echo '      [Link] $(CONFIG)/bin/libmod_esp.out'
	 -r -o $(CONFIG)/bin/libmod_esp.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/espLib.o" $(LIBS) 
endif

#
#   esp.o
#
DEPS_25 += $(CONFIG)/inc/me.h
DEPS_25 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/esp.o: \
    src/paks/esp/esp.c $(DEPS_25)
	@echo '   [Compile] $(CONFIG)/obj/esp.o'
	 -c -o $(CONFIG)/obj/esp.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/esp/esp.c

ifeq ($(ME_EXT_ESP),1)
#
#   espcmd
#
DEPS_26 += $(CONFIG)/inc/mpr.h
DEPS_26 += $(CONFIG)/inc/me.h
DEPS_26 += $(CONFIG)/inc/osdep.h
DEPS_26 += $(CONFIG)/obj/mprLib.o
DEPS_26 += $(CONFIG)/bin/libmpr.out
DEPS_26 += $(CONFIG)/inc/pcre.h
DEPS_26 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_26 += $(CONFIG)/bin/libpcre.out
endif
DEPS_26 += $(CONFIG)/inc/http.h
DEPS_26 += $(CONFIG)/obj/httpLib.o
DEPS_26 += $(CONFIG)/bin/libhttp.out
DEPS_26 += $(CONFIG)/inc/appweb.h
DEPS_26 += $(CONFIG)/inc/customize.h
DEPS_26 += $(CONFIG)/obj/config.o
DEPS_26 += $(CONFIG)/obj/convenience.o
DEPS_26 += $(CONFIG)/obj/dirHandler.o
DEPS_26 += $(CONFIG)/obj/fileHandler.o
DEPS_26 += $(CONFIG)/obj/log.o
DEPS_26 += $(CONFIG)/obj/server.o
DEPS_26 += $(CONFIG)/bin/libappweb.out
DEPS_26 += $(CONFIG)/inc/esp.h
DEPS_26 += $(CONFIG)/obj/espLib.o
DEPS_26 += $(CONFIG)/bin/libmod_esp.out
DEPS_26 += $(CONFIG)/obj/esp.o

$(CONFIG)/bin/esp.out: $(DEPS_26)
	@echo '      [Link] $(CONFIG)/bin/esp.out'
	 -o $(CONFIG)/bin/esp.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/esp.o" "$(CONFIG)/obj/espLib.o" $(LIBS) -Wl,-r 
endif

ifeq ($(ME_EXT_ESP),1)
#
#   esp.conf
#
DEPS_27 += src/paks/esp/esp.conf

$(CONFIG)/bin/esp.conf: $(DEPS_27)
	@echo '      [Copy] $(CONFIG)/bin/esp.conf'
	mkdir -p "$(CONFIG)/bin"
	cp src/paks/esp/esp.conf $(CONFIG)/bin/esp.conf
endif

ifeq ($(ME_EXT_ESP),1)
#
#   esp-paks
#
DEPS_28 += src/paks/angular
DEPS_28 += src/paks/angular/angular-animate.js
DEPS_28 += src/paks/angular/angular-csp.css
DEPS_28 += src/paks/angular/angular-route.js
DEPS_28 += src/paks/angular/angular.js
DEPS_28 += src/paks/angular/package.json
DEPS_28 += src/paks/ejs
DEPS_28 += src/paks/ejs/bower.json
DEPS_28 += src/paks/ejs/ejs.c
DEPS_28 += src/paks/ejs/ejs.es
DEPS_28 += src/paks/ejs/ejs.h
DEPS_28 += src/paks/ejs/ejs.me
DEPS_28 += src/paks/ejs/ejs.slots.h
DEPS_28 += src/paks/ejs/ejsByteGoto.h
DEPS_28 += src/paks/ejs/ejsc.c
DEPS_28 += src/paks/ejs/ejsLib.c
DEPS_28 += src/paks/ejs/LICENSE.md
DEPS_28 += src/paks/ejs/package.json
DEPS_28 += src/paks/ejs/README.md
DEPS_28 += src/paks/esp
DEPS_28 += src/paks/esp/bower.json
DEPS_28 += src/paks/esp/esp.c
DEPS_28 += src/paks/esp/esp.conf
DEPS_28 += src/paks/esp/esp.h
DEPS_28 += src/paks/esp/esp.me
DEPS_28 += src/paks/esp/espLib.c
DEPS_28 += src/paks/esp/LICENSE.md
DEPS_28 += src/paks/esp/package.json
DEPS_28 += src/paks/esp/README.md
DEPS_28 += src/paks/esp-angular
DEPS_28 += src/paks/esp-angular/esp-click.js
DEPS_28 += src/paks/esp-angular/esp-edit.js
DEPS_28 += src/paks/esp-angular/esp-field-errors.js
DEPS_28 += src/paks/esp-angular/esp-fixnum.js
DEPS_28 += src/paks/esp-angular/esp-format.js
DEPS_28 += src/paks/esp-angular/esp-input-group.js
DEPS_28 += src/paks/esp-angular/esp-input.js
DEPS_28 += src/paks/esp-angular/esp-resource.js
DEPS_28 += src/paks/esp-angular/esp-session.js
DEPS_28 += src/paks/esp-angular/esp-titlecase.js
DEPS_28 += src/paks/esp-angular/esp.js
DEPS_28 += src/paks/esp-angular/package.json
DEPS_28 += src/paks/esp-angular-mvc
DEPS_28 += src/paks/esp-angular-mvc/package.json
DEPS_28 += src/paks/esp-html-mvc
DEPS_28 += src/paks/esp-html-mvc/package.json
DEPS_28 += src/paks/esp-legacy-mvc
DEPS_28 += src/paks/esp-legacy-mvc/package.json
DEPS_28 += src/paks/esp-server
DEPS_28 += src/paks/esp-server/package.json
DEPS_28 += src/paks/est
DEPS_28 += src/paks/est/bower.json
DEPS_28 += src/paks/est/ca.crt
DEPS_28 += src/paks/est/est.h
DEPS_28 += src/paks/est/est.me
DEPS_28 += src/paks/est/estLib.c
DEPS_28 += src/paks/est/LICENSE.md
DEPS_28 += src/paks/est/package.json
DEPS_28 += src/paks/est/README.md
DEPS_28 += src/paks/http
DEPS_28 += src/paks/http/bower.json
DEPS_28 += src/paks/http/http.c
DEPS_28 += src/paks/http/http.h
DEPS_28 += src/paks/http/http.me
DEPS_28 += src/paks/http/httpLib.c
DEPS_28 += src/paks/http/LICENSE.md
DEPS_28 += src/paks/http/package.json
DEPS_28 += src/paks/http/README.md
DEPS_28 += src/paks/mpr
DEPS_28 += src/paks/mpr/bower.json
DEPS_28 += src/paks/mpr/LICENSE.md
DEPS_28 += src/paks/mpr/makerom.c
DEPS_28 += src/paks/mpr/manager.c
DEPS_28 += src/paks/mpr/mpr.h
DEPS_28 += src/paks/mpr/mpr.me
DEPS_28 += src/paks/mpr/mprLib.c
DEPS_28 += src/paks/mpr/mprSsl.c
DEPS_28 += src/paks/mpr/package.json
DEPS_28 += src/paks/mpr/README.md
DEPS_28 += src/paks/osdep
DEPS_28 += src/paks/osdep/bower.json
DEPS_28 += src/paks/osdep/LICENSE.md
DEPS_28 += src/paks/osdep/osdep.h
DEPS_28 += src/paks/osdep/osdep.me
DEPS_28 += src/paks/osdep/package.json
DEPS_28 += src/paks/osdep/README.md
DEPS_28 += src/paks/pcre
DEPS_28 += src/paks/pcre/bower.json
DEPS_28 += src/paks/pcre/LICENSE.md
DEPS_28 += src/paks/pcre/package.json
DEPS_28 += src/paks/pcre/pcre.c
DEPS_28 += src/paks/pcre/pcre.h
DEPS_28 += src/paks/pcre/pcre.me
DEPS_28 += src/paks/pcre/README.md
DEPS_28 += src/paks/sqlite
DEPS_28 += src/paks/sqlite/bower.json
DEPS_28 += src/paks/sqlite/LICENSE.md
DEPS_28 += src/paks/sqlite/package.json
DEPS_28 += src/paks/sqlite/README.md
DEPS_28 += src/paks/sqlite/sqlite.c
DEPS_28 += src/paks/sqlite/sqlite.me
DEPS_28 += src/paks/sqlite/sqlite3.c
DEPS_28 += src/paks/sqlite/sqlite3.h
DEPS_28 += src/paks/zlib
DEPS_28 += src/paks/zlib/bower.json
DEPS_28 += src/paks/zlib/LICENSE.md
DEPS_28 += src/paks/zlib/package.json
DEPS_28 += src/paks/zlib/README.md
DEPS_28 += src/paks/zlib/zlib.c
DEPS_28 += src/paks/zlib/zlib.h
DEPS_28 += src/paks/zlib/zlib.me

$(CONFIG)/paks: $(DEPS_28)
	( \
	cd src/paks; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular/4.5.1" ; \
	cp esp-angular/esp-click.js ../../$(CONFIG)/paks/esp-angular/4.5.1/esp-click.js ; \
	cp esp-angular/esp-edit.js ../../$(CONFIG)/paks/esp-angular/4.5.1/esp-edit.js ; \
	cp esp-angular/esp-field-errors.js ../../$(CONFIG)/paks/esp-angular/4.5.1/esp-field-errors.js ; \
	cp esp-angular/esp-fixnum.js ../../$(CONFIG)/paks/esp-angular/4.5.1/esp-fixnum.js ; \
	cp esp-angular/esp-format.js ../../$(CONFIG)/paks/esp-angular/4.5.1/esp-format.js ; \
	cp esp-angular/esp-input-group.js ../../$(CONFIG)/paks/esp-angular/4.5.1/esp-input-group.js ; \
	cp esp-angular/esp-input.js ../../$(CONFIG)/paks/esp-angular/4.5.1/esp-input.js ; \
	cp esp-angular/esp-resource.js ../../$(CONFIG)/paks/esp-angular/4.5.1/esp-resource.js ; \
	cp esp-angular/esp-session.js ../../$(CONFIG)/paks/esp-angular/4.5.1/esp-session.js ; \
	cp esp-angular/esp-titlecase.js ../../$(CONFIG)/paks/esp-angular/4.5.1/esp-titlecase.js ; \
	cp esp-angular/esp.js ../../$(CONFIG)/paks/esp-angular/4.5.1/esp.js ; \
	cp esp-angular/package.json ../../$(CONFIG)/paks/esp-angular/4.5.1/package.json ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/4.5.1" ; \
	cp esp-angular-mvc/package.json ../../$(CONFIG)/paks/esp-angular-mvc/4.5.1/package.json ; \
	mkdir -p "../../$(CONFIG)/paks/esp-html-mvc/4.5.1" ; \
	cp esp-html-mvc/package.json ../../$(CONFIG)/paks/esp-html-mvc/4.5.1/package.json ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/4.5.1" ; \
	cp esp-legacy-mvc/package.json ../../$(CONFIG)/paks/esp-legacy-mvc/4.5.1/package.json ; \
	mkdir -p "../../$(CONFIG)/paks/esp-server/4.5.1" ; \
	cp esp-server/package.json ../../$(CONFIG)/paks/esp-server/4.5.1/package.json ; \
	)
endif

#
#   est.h
#
$(CONFIG)/inc/est.h: $(DEPS_29)
	@echo '      [Copy] $(CONFIG)/inc/est.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/est/est.h $(CONFIG)/inc/est.h

#
#   estLib.o
#
DEPS_30 += $(CONFIG)/inc/me.h
DEPS_30 += $(CONFIG)/inc/est.h
DEPS_30 += $(CONFIG)/inc/osdep.h

$(CONFIG)/obj/estLib.o: \
    src/paks/est/estLib.c $(DEPS_30)
	@echo '   [Compile] $(CONFIG)/obj/estLib.o'
	 -c -o $(CONFIG)/obj/estLib.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/est/estLib.c

ifeq ($(ME_EXT_EST),1)
#
#   libest
#
DEPS_31 += $(CONFIG)/inc/est.h
DEPS_31 += $(CONFIG)/inc/me.h
DEPS_31 += $(CONFIG)/inc/osdep.h
DEPS_31 += $(CONFIG)/obj/estLib.o

$(CONFIG)/bin/libest.out: $(DEPS_31)
	@echo '      [Link] $(CONFIG)/bin/libest.out'
	 -r -o $(CONFIG)/bin/libest.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/estLib.o" $(LIBS) 
endif

#
#   ca-crt
#
DEPS_32 += src/paks/est/ca.crt

$(CONFIG)/bin/ca.crt: $(DEPS_32)
	@echo '      [Copy] $(CONFIG)/bin/ca.crt'
	mkdir -p "$(CONFIG)/bin"
	cp src/paks/est/ca.crt $(CONFIG)/bin/ca.crt

#
#   http.o
#
DEPS_33 += $(CONFIG)/inc/me.h
DEPS_33 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/http.o: \
    src/paks/http/http.c $(DEPS_33)
	@echo '   [Compile] $(CONFIG)/obj/http.o'
	 -c -o $(CONFIG)/obj/http.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/http/http.c

#
#   httpcmd
#
DEPS_34 += $(CONFIG)/inc/mpr.h
DEPS_34 += $(CONFIG)/inc/me.h
DEPS_34 += $(CONFIG)/inc/osdep.h
DEPS_34 += $(CONFIG)/obj/mprLib.o
DEPS_34 += $(CONFIG)/bin/libmpr.out
DEPS_34 += $(CONFIG)/inc/pcre.h
DEPS_34 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_34 += $(CONFIG)/bin/libpcre.out
endif
DEPS_34 += $(CONFIG)/inc/http.h
DEPS_34 += $(CONFIG)/obj/httpLib.o
DEPS_34 += $(CONFIG)/bin/libhttp.out
DEPS_34 += $(CONFIG)/obj/http.o

$(CONFIG)/bin/httpcmd.out: $(DEPS_34)
	@echo '      [Link] $(CONFIG)/bin/httpcmd.out'
	 -o $(CONFIG)/bin/httpcmd.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/http.o" $(LIBS) -Wl,-r 

#
#   mprSsl.o
#
DEPS_35 += $(CONFIG)/inc/me.h
DEPS_35 += $(CONFIG)/inc/mpr.h
DEPS_35 += $(CONFIG)/inc/est.h

$(CONFIG)/obj/mprSsl.o: \
    src/paks/mpr/mprSsl.c $(DEPS_35)
	@echo '   [Compile] $(CONFIG)/obj/mprSsl.o'
	 -c -o $(CONFIG)/obj/mprSsl.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/mpr/mprSsl.c

#
#   libmprssl
#
DEPS_36 += $(CONFIG)/inc/mpr.h
DEPS_36 += $(CONFIG)/inc/me.h
DEPS_36 += $(CONFIG)/inc/osdep.h
DEPS_36 += $(CONFIG)/obj/mprLib.o
DEPS_36 += $(CONFIG)/bin/libmpr.out
DEPS_36 += $(CONFIG)/inc/est.h
DEPS_36 += $(CONFIG)/obj/estLib.o
ifeq ($(ME_EXT_EST),1)
    DEPS_36 += $(CONFIG)/bin/libest.out
endif
DEPS_36 += $(CONFIG)/obj/mprSsl.o

$(CONFIG)/bin/libmprssl.out: $(DEPS_36)
	@echo '      [Link] $(CONFIG)/bin/libmprssl.out'
	 -r -o $(CONFIG)/bin/libmprssl.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/mprSsl.o" $(LIBS) 

#
#   manager.o
#
DEPS_37 += $(CONFIG)/inc/me.h
DEPS_37 += $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/manager.o: \
    src/paks/mpr/manager.c $(DEPS_37)
	@echo '   [Compile] $(CONFIG)/obj/manager.o'
	 -c -o $(CONFIG)/obj/manager.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/mpr/manager.c

#
#   manager
#
DEPS_38 += $(CONFIG)/inc/mpr.h
DEPS_38 += $(CONFIG)/inc/me.h
DEPS_38 += $(CONFIG)/inc/osdep.h
DEPS_38 += $(CONFIG)/obj/mprLib.o
DEPS_38 += $(CONFIG)/bin/libmpr.out
DEPS_38 += $(CONFIG)/obj/manager.o

$(CONFIG)/bin/appman.out: $(DEPS_38)
	@echo '      [Link] $(CONFIG)/bin/appman.out'
	 -o $(CONFIG)/bin/appman.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/manager.o" $(LIBS) -Wl,-r 

#
#   zlib.h
#
$(CONFIG)/inc/zlib.h: $(DEPS_39)
	@echo '      [Copy] $(CONFIG)/inc/zlib.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/paks/zlib/zlib.h $(CONFIG)/inc/zlib.h

#
#   zlib.o
#
DEPS_40 += $(CONFIG)/inc/me.h
DEPS_40 += $(CONFIG)/inc/zlib.h

$(CONFIG)/obj/zlib.o: \
    src/paks/zlib/zlib.c $(DEPS_40)
	@echo '   [Compile] $(CONFIG)/obj/zlib.o'
	 -c -o $(CONFIG)/obj/zlib.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/paks/zlib/zlib.c

ifeq ($(ME_EXT_ZLIB),1)
#
#   libzlib
#
DEPS_41 += $(CONFIG)/inc/zlib.h
DEPS_41 += $(CONFIG)/inc/me.h
DEPS_41 += $(CONFIG)/obj/zlib.o

$(CONFIG)/bin/libzlib.out: $(DEPS_41)
	@echo '      [Link] $(CONFIG)/bin/libzlib.out'
	 -r -o $(CONFIG)/bin/libzlib.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/zlib.o" $(LIBS) 
endif

#
#   slink.c
#
src/slink.c: $(DEPS_42)
	( \
	cd src; \
	[ ! -f slink.c ] && cp slink.empty slink.c ; true ; \
	)

#
#   slink.o
#
DEPS_43 += $(CONFIG)/inc/me.h
DEPS_43 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/slink.o: \
    src/slink.c $(DEPS_43)
	@echo '   [Compile] $(CONFIG)/obj/slink.o'
	 -c -o $(CONFIG)/obj/slink.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/slink.c

#
#   libslink
#
DEPS_44 += src/slink.c
DEPS_44 += $(CONFIG)/inc/me.h
DEPS_44 += $(CONFIG)/inc/esp.h
DEPS_44 += $(CONFIG)/obj/slink.o

$(CONFIG)/bin/libslink.out: $(DEPS_44)
	@echo '      [Link] $(CONFIG)/bin/libslink.out'
	 -r -o $(CONFIG)/bin/libslink.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/slink.o" $(LIBS) 

#
#   cgiHandler.o
#
DEPS_45 += $(CONFIG)/inc/me.h
DEPS_45 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/cgiHandler.o: \
    src/modules/cgiHandler.c $(DEPS_45)
	@echo '   [Compile] $(CONFIG)/obj/cgiHandler.o'
	 -c -o $(CONFIG)/obj/cgiHandler.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/modules/cgiHandler.c

ifeq ($(ME_EXT_CGI),1)
#
#   libmod_cgi
#
DEPS_46 += $(CONFIG)/inc/mpr.h
DEPS_46 += $(CONFIG)/inc/me.h
DEPS_46 += $(CONFIG)/inc/osdep.h
DEPS_46 += $(CONFIG)/obj/mprLib.o
DEPS_46 += $(CONFIG)/bin/libmpr.out
DEPS_46 += $(CONFIG)/inc/pcre.h
DEPS_46 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_46 += $(CONFIG)/bin/libpcre.out
endif
DEPS_46 += $(CONFIG)/inc/http.h
DEPS_46 += $(CONFIG)/obj/httpLib.o
DEPS_46 += $(CONFIG)/bin/libhttp.out
DEPS_46 += $(CONFIG)/inc/appweb.h
DEPS_46 += $(CONFIG)/inc/customize.h
DEPS_46 += $(CONFIG)/obj/config.o
DEPS_46 += $(CONFIG)/obj/convenience.o
DEPS_46 += $(CONFIG)/obj/dirHandler.o
DEPS_46 += $(CONFIG)/obj/fileHandler.o
DEPS_46 += $(CONFIG)/obj/log.o
DEPS_46 += $(CONFIG)/obj/server.o
DEPS_46 += $(CONFIG)/bin/libappweb.out
DEPS_46 += $(CONFIG)/obj/cgiHandler.o

$(CONFIG)/bin/libmod_cgi.out: $(DEPS_46)
	@echo '      [Link] $(CONFIG)/bin/libmod_cgi.out'
	 -r -o $(CONFIG)/bin/libmod_cgi.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/cgiHandler.o" $(LIBS) 
endif

#
#   sslModule.o
#
DEPS_47 += $(CONFIG)/inc/me.h
DEPS_47 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/sslModule.o: \
    src/modules/sslModule.c $(DEPS_47)
	@echo '   [Compile] $(CONFIG)/obj/sslModule.o'
	 -c -o $(CONFIG)/obj/sslModule.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/modules/sslModule.c

ifeq ($(ME_EXT_SSL),1)
#
#   libmod_ssl
#
DEPS_48 += $(CONFIG)/inc/mpr.h
DEPS_48 += $(CONFIG)/inc/me.h
DEPS_48 += $(CONFIG)/inc/osdep.h
DEPS_48 += $(CONFIG)/obj/mprLib.o
DEPS_48 += $(CONFIG)/bin/libmpr.out
DEPS_48 += $(CONFIG)/inc/pcre.h
DEPS_48 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_48 += $(CONFIG)/bin/libpcre.out
endif
DEPS_48 += $(CONFIG)/inc/http.h
DEPS_48 += $(CONFIG)/obj/httpLib.o
DEPS_48 += $(CONFIG)/bin/libhttp.out
DEPS_48 += $(CONFIG)/inc/appweb.h
DEPS_48 += $(CONFIG)/inc/customize.h
DEPS_48 += $(CONFIG)/obj/config.o
DEPS_48 += $(CONFIG)/obj/convenience.o
DEPS_48 += $(CONFIG)/obj/dirHandler.o
DEPS_48 += $(CONFIG)/obj/fileHandler.o
DEPS_48 += $(CONFIG)/obj/log.o
DEPS_48 += $(CONFIG)/obj/server.o
DEPS_48 += $(CONFIG)/bin/libappweb.out
DEPS_48 += $(CONFIG)/inc/est.h
DEPS_48 += $(CONFIG)/obj/estLib.o
ifeq ($(ME_EXT_EST),1)
    DEPS_48 += $(CONFIG)/bin/libest.out
endif
DEPS_48 += $(CONFIG)/obj/mprSsl.o
DEPS_48 += $(CONFIG)/bin/libmprssl.out
DEPS_48 += $(CONFIG)/obj/sslModule.o

$(CONFIG)/bin/libmod_ssl.out: $(DEPS_48)
	@echo '      [Link] $(CONFIG)/bin/libmod_ssl.out'
	 -r -o $(CONFIG)/bin/libmod_ssl.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/sslModule.o" $(LIBS) 
endif

#
#   authpass.o
#
DEPS_49 += $(CONFIG)/inc/me.h
DEPS_49 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/authpass.o: \
    src/utils/authpass.c $(DEPS_49)
	@echo '   [Compile] $(CONFIG)/obj/authpass.o'
	 -c -o $(CONFIG)/obj/authpass.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/utils/authpass.c

#
#   authpass
#
DEPS_50 += $(CONFIG)/inc/mpr.h
DEPS_50 += $(CONFIG)/inc/me.h
DEPS_50 += $(CONFIG)/inc/osdep.h
DEPS_50 += $(CONFIG)/obj/mprLib.o
DEPS_50 += $(CONFIG)/bin/libmpr.out
DEPS_50 += $(CONFIG)/inc/pcre.h
DEPS_50 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_50 += $(CONFIG)/bin/libpcre.out
endif
DEPS_50 += $(CONFIG)/inc/http.h
DEPS_50 += $(CONFIG)/obj/httpLib.o
DEPS_50 += $(CONFIG)/bin/libhttp.out
DEPS_50 += $(CONFIG)/inc/appweb.h
DEPS_50 += $(CONFIG)/inc/customize.h
DEPS_50 += $(CONFIG)/obj/config.o
DEPS_50 += $(CONFIG)/obj/convenience.o
DEPS_50 += $(CONFIG)/obj/dirHandler.o
DEPS_50 += $(CONFIG)/obj/fileHandler.o
DEPS_50 += $(CONFIG)/obj/log.o
DEPS_50 += $(CONFIG)/obj/server.o
DEPS_50 += $(CONFIG)/bin/libappweb.out
DEPS_50 += $(CONFIG)/obj/authpass.o

$(CONFIG)/bin/authpass.out: $(DEPS_50)
	@echo '      [Link] $(CONFIG)/bin/authpass.out'
	 -o $(CONFIG)/bin/authpass.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/authpass.o" $(LIBS) -Wl,-r 

#
#   cgiProgram.o
#
DEPS_51 += $(CONFIG)/inc/me.h

$(CONFIG)/obj/cgiProgram.o: \
    src/utils/cgiProgram.c $(DEPS_51)
	@echo '   [Compile] $(CONFIG)/obj/cgiProgram.o'
	 -c -o $(CONFIG)/obj/cgiProgram.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/utils/cgiProgram.c

ifeq ($(ME_EXT_CGI),1)
#
#   cgiProgram
#
DEPS_52 += $(CONFIG)/inc/me.h
DEPS_52 += $(CONFIG)/obj/cgiProgram.o

$(CONFIG)/bin/cgiProgram.out: $(DEPS_52)
	@echo '      [Link] $(CONFIG)/bin/cgiProgram.out'
	 -o $(CONFIG)/bin/cgiProgram.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/cgiProgram.o" $(LIBS) -Wl,-r 
endif

#
#   appweb.o
#
DEPS_53 += $(CONFIG)/inc/me.h
DEPS_53 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/appweb.o: \
    src/server/appweb.c $(DEPS_53)
	@echo '   [Compile] $(CONFIG)/obj/appweb.o'
	 -c -o $(CONFIG)/obj/appweb.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/server/appweb.c

#
#   appweb
#
DEPS_54 += $(CONFIG)/inc/mpr.h
DEPS_54 += $(CONFIG)/inc/me.h
DEPS_54 += $(CONFIG)/inc/osdep.h
DEPS_54 += $(CONFIG)/obj/mprLib.o
DEPS_54 += $(CONFIG)/bin/libmpr.out
DEPS_54 += $(CONFIG)/inc/pcre.h
DEPS_54 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_54 += $(CONFIG)/bin/libpcre.out
endif
DEPS_54 += $(CONFIG)/inc/http.h
DEPS_54 += $(CONFIG)/obj/httpLib.o
DEPS_54 += $(CONFIG)/bin/libhttp.out
DEPS_54 += $(CONFIG)/inc/appweb.h
DEPS_54 += $(CONFIG)/inc/customize.h
DEPS_54 += $(CONFIG)/obj/config.o
DEPS_54 += $(CONFIG)/obj/convenience.o
DEPS_54 += $(CONFIG)/obj/dirHandler.o
DEPS_54 += $(CONFIG)/obj/fileHandler.o
DEPS_54 += $(CONFIG)/obj/log.o
DEPS_54 += $(CONFIG)/obj/server.o
DEPS_54 += $(CONFIG)/bin/libappweb.out
DEPS_54 += src/slink.c
DEPS_54 += $(CONFIG)/inc/esp.h
DEPS_54 += $(CONFIG)/obj/slink.o
DEPS_54 += $(CONFIG)/bin/libslink.out
DEPS_54 += $(CONFIG)/obj/appweb.o

$(CONFIG)/bin/appweb.out: $(DEPS_54)
	@echo '      [Link] $(CONFIG)/bin/appweb.out'
	 -o $(CONFIG)/bin/appweb.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/appweb.o" $(LIBS) -Wl,-r 

#
#   server-cache
#
src/server/cache: $(DEPS_55)
	( \
	cd src/server; \
	mkdir -p cache ; \
	)

#
#   testAppweb.h
#
$(CONFIG)/inc/testAppweb.h: $(DEPS_56)
	@echo '      [Copy] $(CONFIG)/inc/testAppweb.h'
	mkdir -p "$(CONFIG)/inc"
	cp test/src/testAppweb.h $(CONFIG)/inc/testAppweb.h

#
#   testAppweb.o
#
DEPS_57 += $(CONFIG)/inc/me.h
DEPS_57 += $(CONFIG)/inc/testAppweb.h
DEPS_57 += $(CONFIG)/inc/mpr.h
DEPS_57 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/testAppweb.o: \
    test/src/testAppweb.c $(DEPS_57)
	@echo '   [Compile] $(CONFIG)/obj/testAppweb.o'
	 -c -o $(CONFIG)/obj/testAppweb.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" test/src/testAppweb.c

#
#   testHttp.o
#
DEPS_58 += $(CONFIG)/inc/me.h
DEPS_58 += $(CONFIG)/inc/testAppweb.h

$(CONFIG)/obj/testHttp.o: \
    test/src/testHttp.c $(DEPS_58)
	@echo '   [Compile] $(CONFIG)/obj/testHttp.o'
	 -c -o $(CONFIG)/obj/testHttp.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" test/src/testHttp.c

#
#   testAppweb
#
DEPS_59 += $(CONFIG)/inc/mpr.h
DEPS_59 += $(CONFIG)/inc/me.h
DEPS_59 += $(CONFIG)/inc/osdep.h
DEPS_59 += $(CONFIG)/obj/mprLib.o
DEPS_59 += $(CONFIG)/bin/libmpr.out
DEPS_59 += $(CONFIG)/inc/pcre.h
DEPS_59 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_59 += $(CONFIG)/bin/libpcre.out
endif
DEPS_59 += $(CONFIG)/inc/http.h
DEPS_59 += $(CONFIG)/obj/httpLib.o
DEPS_59 += $(CONFIG)/bin/libhttp.out
DEPS_59 += $(CONFIG)/inc/appweb.h
DEPS_59 += $(CONFIG)/inc/customize.h
DEPS_59 += $(CONFIG)/obj/config.o
DEPS_59 += $(CONFIG)/obj/convenience.o
DEPS_59 += $(CONFIG)/obj/dirHandler.o
DEPS_59 += $(CONFIG)/obj/fileHandler.o
DEPS_59 += $(CONFIG)/obj/log.o
DEPS_59 += $(CONFIG)/obj/server.o
DEPS_59 += $(CONFIG)/bin/libappweb.out
DEPS_59 += $(CONFIG)/inc/testAppweb.h
DEPS_59 += $(CONFIG)/obj/testAppweb.o
DEPS_59 += $(CONFIG)/obj/testHttp.o

$(CONFIG)/bin/testAppweb.out: $(DEPS_59)
	@echo '      [Link] $(CONFIG)/bin/testAppweb.out'
	 -o $(CONFIG)/bin/testAppweb.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/testAppweb.o" "$(CONFIG)/obj/testHttp.o" $(LIBS) -Wl,-r 

ifeq ($(ME_EXT_CGI),1)
#
#   test-testScript
#
DEPS_60 += $(CONFIG)/inc/mpr.h
DEPS_60 += $(CONFIG)/inc/me.h
DEPS_60 += $(CONFIG)/inc/osdep.h
DEPS_60 += $(CONFIG)/obj/mprLib.o
DEPS_60 += $(CONFIG)/bin/libmpr.out
DEPS_60 += $(CONFIG)/inc/pcre.h
DEPS_60 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_60 += $(CONFIG)/bin/libpcre.out
endif
DEPS_60 += $(CONFIG)/inc/http.h
DEPS_60 += $(CONFIG)/obj/httpLib.o
DEPS_60 += $(CONFIG)/bin/libhttp.out
DEPS_60 += $(CONFIG)/inc/appweb.h
DEPS_60 += $(CONFIG)/inc/customize.h
DEPS_60 += $(CONFIG)/obj/config.o
DEPS_60 += $(CONFIG)/obj/convenience.o
DEPS_60 += $(CONFIG)/obj/dirHandler.o
DEPS_60 += $(CONFIG)/obj/fileHandler.o
DEPS_60 += $(CONFIG)/obj/log.o
DEPS_60 += $(CONFIG)/obj/server.o
DEPS_60 += $(CONFIG)/bin/libappweb.out
DEPS_60 += $(CONFIG)/inc/testAppweb.h
DEPS_60 += $(CONFIG)/obj/testAppweb.o
DEPS_60 += $(CONFIG)/obj/testHttp.o
DEPS_60 += $(CONFIG)/bin/testAppweb.out

test/cgi-bin/testScript: $(DEPS_60)
	( \
	cd test; \
	echo '#!../$(CONFIG)/bin/cgiProgram.out' >cgi-bin/testScript ; chmod +x cgi-bin/testScript ; \
	)
endif

ifeq ($(ME_EXT_CGI),1)
#
#   test-cache.cgi
#
DEPS_61 += $(CONFIG)/inc/mpr.h
DEPS_61 += $(CONFIG)/inc/me.h
DEPS_61 += $(CONFIG)/inc/osdep.h
DEPS_61 += $(CONFIG)/obj/mprLib.o
DEPS_61 += $(CONFIG)/bin/libmpr.out
DEPS_61 += $(CONFIG)/inc/pcre.h
DEPS_61 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_61 += $(CONFIG)/bin/libpcre.out
endif
DEPS_61 += $(CONFIG)/inc/http.h
DEPS_61 += $(CONFIG)/obj/httpLib.o
DEPS_61 += $(CONFIG)/bin/libhttp.out
DEPS_61 += $(CONFIG)/inc/appweb.h
DEPS_61 += $(CONFIG)/inc/customize.h
DEPS_61 += $(CONFIG)/obj/config.o
DEPS_61 += $(CONFIG)/obj/convenience.o
DEPS_61 += $(CONFIG)/obj/dirHandler.o
DEPS_61 += $(CONFIG)/obj/fileHandler.o
DEPS_61 += $(CONFIG)/obj/log.o
DEPS_61 += $(CONFIG)/obj/server.o
DEPS_61 += $(CONFIG)/bin/libappweb.out
DEPS_61 += $(CONFIG)/inc/testAppweb.h
DEPS_61 += $(CONFIG)/obj/testAppweb.o
DEPS_61 += $(CONFIG)/obj/testHttp.o
DEPS_61 += $(CONFIG)/bin/testAppweb.out

test/web/caching/cache.cgi: $(DEPS_61)
	( \
	cd test; \
	echo "#!`type -p ejs`" >web/caching/cache.cgi ; \
	echo 'print("HTTP/1.0 200 OK\nContent-Type: text/plain\n\n{number:" + Date().now() + "}\n")' >>web/caching/cache.cgi ; \
	chmod +x web/caching/cache.cgi ; \
	)
endif

ifeq ($(ME_EXT_CGI),1)
#
#   test-basic.cgi
#
DEPS_62 += $(CONFIG)/inc/mpr.h
DEPS_62 += $(CONFIG)/inc/me.h
DEPS_62 += $(CONFIG)/inc/osdep.h
DEPS_62 += $(CONFIG)/obj/mprLib.o
DEPS_62 += $(CONFIG)/bin/libmpr.out
DEPS_62 += $(CONFIG)/inc/pcre.h
DEPS_62 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_62 += $(CONFIG)/bin/libpcre.out
endif
DEPS_62 += $(CONFIG)/inc/http.h
DEPS_62 += $(CONFIG)/obj/httpLib.o
DEPS_62 += $(CONFIG)/bin/libhttp.out
DEPS_62 += $(CONFIG)/inc/appweb.h
DEPS_62 += $(CONFIG)/inc/customize.h
DEPS_62 += $(CONFIG)/obj/config.o
DEPS_62 += $(CONFIG)/obj/convenience.o
DEPS_62 += $(CONFIG)/obj/dirHandler.o
DEPS_62 += $(CONFIG)/obj/fileHandler.o
DEPS_62 += $(CONFIG)/obj/log.o
DEPS_62 += $(CONFIG)/obj/server.o
DEPS_62 += $(CONFIG)/bin/libappweb.out
DEPS_62 += $(CONFIG)/inc/testAppweb.h
DEPS_62 += $(CONFIG)/obj/testAppweb.o
DEPS_62 += $(CONFIG)/obj/testHttp.o
DEPS_62 += $(CONFIG)/bin/testAppweb.out

test/web/auth/basic/basic.cgi: $(DEPS_62)
	( \
	cd test; \
	echo "#!`type -p ejs`" >web/auth/basic/basic.cgi ; \
	echo 'print("HTTP/1.0 200 OK\nContent-Type: text/plain\n\n" + serialize(App.env, {pretty: true}) + "\n")' >>web/auth/basic/basic.cgi ; \
	chmod +x web/auth/basic/basic.cgi ; \
	)
endif

ifeq ($(ME_EXT_CGI),1)
#
#   test-cgiProgram
#
DEPS_63 += $(CONFIG)/inc/me.h
DEPS_63 += $(CONFIG)/obj/cgiProgram.o
DEPS_63 += $(CONFIG)/bin/cgiProgram.out

test/cgi-bin/cgiProgram.out: $(DEPS_63)
	( \
	cd test; \
	cp ../$(CONFIG)/bin/cgiProgram.out cgi-bin/cgiProgram.out ; \
	cp ../$(CONFIG)/bin/cgiProgram.out cgi-bin/nph-cgiProgram.out ; \
	cp ../$(CONFIG)/bin/cgiProgram.out 'cgi-bin/cgi Program.out' ; \
	cp ../$(CONFIG)/bin/cgiProgram.out web/cgiProgram.cgi ; \
	chmod +x cgi-bin/* web/cgiProgram.cgi ; \
	)
endif

#
#   installBinary
#
installBinary: $(DEPS_64)

#
#   install
#
DEPS_65 += installBinary

install: $(DEPS_65)


#
#   uninstall
#
DEPS_66 += build

uninstall: $(DEPS_66)
	( \
	cd package; \
	rm -f "$(ME_VAPP_PREFIX)/appweb.conf" ; \
	rm -f "$(ME_VAPP_PREFIX)/esp.conf" ; \
	rm -f "$(ME_VAPP_PREFIX)/mine.types" ; \
	rm -f "$(ME_VAPP_PREFIX)/install.conf" ; \
	rm -fr "$(ME_VAPP_PREFIX)/inc/appweb" ; \
	)

#
#   genslink
#
genslink: $(DEPS_67)
	( \
	cd src; \
	esp --static --genlink slink.c compile ; \
	)


#
#   run
#
DEPS_68 += compile

run: $(DEPS_68)
	( \
	cd src/server; \
	sudo ../../$(CONFIG)/bin/appweb -v ; \
	)

