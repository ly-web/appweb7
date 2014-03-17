#
#   appweb-macosx-default.mk -- Makefile to build Embedthis Appweb for macosx
#

NAME                  := appweb
VERSION               := 5.0.0-rc0
PROFILE               ?= default
ARCH                  ?= $(shell uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/')
CC_ARCH               ?= $(shell echo $(ARCH) | sed 's/x86/i686/;s/x64/x86_64/')
OS                    ?= macosx
CC                    ?= clang
LD                    ?= ld
CONFIG                ?= $(OS)-$(ARCH)-$(PROFILE)
LBIN                  ?= $(CONFIG)/bin
PATH                  := $(LBIN):$(PATH)

ME_EXT_CGI            ?= 0
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

ME_EXT_COMPILER_PATH  ?= clang
ME_EXT_DOXYGEN_PATH   ?= doxygen
ME_EXT_DSI_PATH       ?= dsi
ME_EXT_ESP_PATH       ?= src/paks/esp/esp.me
ME_EXT_EST_PATH       ?= src/paks/est/estLib.c
ME_EXT_GZIP_PATH      ?= gzip
ME_EXT_HTMLMIN_PATH   ?= htmlmin
ME_EXT_HTTP_PATH      ?= src/paks/http/http.me
ME_EXT_LIB_PATH       ?= ar
ME_EXT_LINK_PATH      ?= ld
ME_EXT_MAN_PATH       ?= man
ME_EXT_MAN2HTML_PATH  ?= man2html
ME_EXT_MATRIXSSL_PATH ?= /usr/src/matrixssl
ME_EXT_MDB_PATH       ?= src/mdb.c
ME_EXT_MPR_PATH       ?= src/paks/mpr/mpr.me
ME_EXT_NANOSSL_PATH   ?= /usr/src/nanossl
ME_EXT_NGMIN_PATH     ?= ngmin
ME_EXT_OPENSSL_PATH   ?= /usr/src/openssl
ME_EXT_OSDEP_PATH     ?= src/paks/osdep/osdep.me
ME_EXT_PAK_PATH       ?= pak
ME_EXT_PCRE_PATH      ?= src/paks/pcre/pcre.me
ME_EXT_PMAKER_PATH    ?= /Applications/PackageMaker.app/Contents/MacOS/PackageMaker
ME_EXT_RECESS_PATH    ?= recess
ME_EXT_UGLIFYJS_PATH  ?= uglifyjs
ME_EXT_UTEST_PATH     ?= utest
ME_EXT_VXWORKS_PATH   ?= $(WIND_BASE)
ME_EXT_ZIP_PATH       ?= zip

export WIND_HOME      ?= $(WIND_BASE)/..

CFLAGS                += -w
DFLAGS                +=  $(patsubst %,-D%,$(filter ME_%,$(MAKEFLAGS))) -DME_EXT_CGI=$(ME_EXT_CGI) -DME_EXT_EJS=$(ME_EXT_EJS) -DME_EXT_ESP=$(ME_EXT_ESP) -DME_EXT_EST=$(ME_EXT_EST) -DME_EXT_MATRIXSSL=$(ME_EXT_MATRIXSSL) -DME_EXT_MDB=$(ME_EXT_MDB) -DME_EXT_NANOSSL=$(ME_EXT_NANOSSL) -DME_EXT_OPENSSL=$(ME_EXT_OPENSSL) -DME_EXT_PCRE=$(ME_EXT_PCRE) -DME_EXT_PHP=$(ME_EXT_PHP) -DME_EXT_SQLITE=$(ME_EXT_SQLITE) -DME_EXT_SSL=$(ME_EXT_SSL) -DME_EXT_ZLIB=$(ME_EXT_ZLIB) 
IFLAGS                += "-I$(CONFIG)/inc"
LDFLAGS               += '-Wl,-rpath,@executable_path/' '-Wl,-rpath,@loader_path/'
LIBPATHS              += -L$(CONFIG)/bin
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
ME_WEB_PREFIX         ?= $(ME_ROOT_PREFIX)/var/www/$(NAME)-default
ME_LOG_PREFIX         ?= $(ME_ROOT_PREFIX)/var/log/$(NAME)
ME_SPOOL_PREFIX       ?= $(ME_ROOT_PREFIX)/var/spool/$(NAME)
ME_CACHE_PREFIX       ?= $(ME_ROOT_PREFIX)/var/spool/$(NAME)/cache
ME_SRC_PREFIX         ?= $(ME_ROOT_PREFIX)$(NAME)-$(VERSION)


ifeq ($(ME_EXT_ESP),1)
    TARGETS           += $(CONFIG)/bin/libmod_esp.dylib
endif
ifeq ($(ME_EXT_ESP),1)
    TARGETS           += $(CONFIG)/bin/esp
endif
ifeq ($(ME_EXT_ESP),1)
    TARGETS           += $(CONFIG)/bin/esp.conf
endif
ifeq ($(ME_EXT_ESP),1)
    TARGETS           += $(CONFIG)/paks
endif
ifeq ($(ME_EXT_EST),1)
    TARGETS           += $(CONFIG)/bin/libest.dylib
endif
TARGETS               += $(CONFIG)/bin/ca.crt
TARGETS               += $(CONFIG)/bin/http
TARGETS               += $(CONFIG)/bin/libmprssl.dylib
TARGETS               += $(CONFIG)/bin/appman
ifeq ($(ME_EXT_ZLIB),1)
    TARGETS           += $(CONFIG)/bin/libzlib.dylib
endif
TARGETS               += src/slink.c
TARGETS               += $(CONFIG)/bin/libslink.dylib
ifeq ($(ME_EXT_SSL),1)
    TARGETS           += $(CONFIG)/bin/libmod_ssl.dylib
endif
TARGETS               += $(CONFIG)/bin/authpass
TARGETS               += $(CONFIG)/bin/appweb
TARGETS               += src/server/cache
TARGETS               += $(CONFIG)/bin/testAppweb

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
	@[ ! -x $(CONFIG)/bin ] && mkdir -p $(CONFIG)/bin; true
	@[ ! -x $(CONFIG)/inc ] && mkdir -p $(CONFIG)/inc; true
	@[ ! -x $(CONFIG)/obj ] && mkdir -p $(CONFIG)/obj; true
	@[ ! -f $(CONFIG)/inc/osdep.h ] && cp src/paks/osdep/osdep.h $(CONFIG)/inc/osdep.h ; true
	@if ! diff $(CONFIG)/inc/osdep.h src/paks/osdep/osdep.h >/dev/null ; then\
		cp src/paks/osdep/osdep.h $(CONFIG)/inc/osdep.h  ; \
	fi; true
	@[ ! -f $(CONFIG)/inc/me.h ] && cp projects/appweb-macosx-default-me.h $(CONFIG)/inc/me.h ; true
	@if ! diff $(CONFIG)/inc/me.h projects/appweb-macosx-default-me.h >/dev/null ; then\
		cp projects/appweb-macosx-default-me.h $(CONFIG)/inc/me.h  ; \
	fi; true
	@if [ -f "$(CONFIG)/.makeflags" ] ; then \
		if [ "$(MAKEFLAGS)" != " ` cat $(CONFIG)/.makeflags`" ] ; then \
			echo "   [Warning] Make flags have changed since the last build: "`cat $(CONFIG)/.makeflags`"" ; \
		fi ; \
	fi
	@echo $(MAKEFLAGS) >$(CONFIG)/.makeflags

clean:
	rm -f "$(CONFIG)/bin/libmod_esp.dylib"
	rm -f "$(CONFIG)/bin/esp"
	rm -f "$(CONFIG)/bin/esp.conf"
	rm -f "$(CONFIG)/bin/libest.dylib"
	rm -f "$(CONFIG)/bin/ca.crt"
	rm -f "$(CONFIG)/bin/libhttp.dylib"
	rm -f "$(CONFIG)/bin/http"
	rm -f "$(CONFIG)/bin/libmpr.dylib"
	rm -f "$(CONFIG)/bin/libmprssl.dylib"
	rm -f "$(CONFIG)/bin/appman"
	rm -f "$(CONFIG)/bin/makerom"
	rm -f "$(CONFIG)/bin/libpcre.dylib"
	rm -f "$(CONFIG)/bin/libzlib.dylib"
	rm -f "$(CONFIG)/bin/libappweb.dylib"
	rm -f "$(CONFIG)/bin/libslink.dylib"
	rm -f "$(CONFIG)/bin/libmod_ssl.dylib"
	rm -f "$(CONFIG)/bin/authpass"
	rm -f "$(CONFIG)/bin/appweb"
	rm -f "$(CONFIG)/bin/testAppweb"
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
	rm -f "$(CONFIG)/obj/sslModule.o"
	rm -f "$(CONFIG)/obj/authpass.o"
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
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/mprLib.o -arch $(CC_ARCH) $(IFLAGS) src/paks/mpr/mprLib.c

#
#   libmpr
#
DEPS_6 += $(CONFIG)/inc/mpr.h
DEPS_6 += $(CONFIG)/inc/me.h
DEPS_6 += $(CONFIG)/inc/osdep.h
DEPS_6 += $(CONFIG)/obj/mprLib.o

$(CONFIG)/bin/libmpr.dylib: $(DEPS_6)
	@echo '      [Link] $(CONFIG)/bin/libmpr.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmpr.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libmpr.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/mprLib.o" $(LIBS) 

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
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/pcre.o -arch $(CC_ARCH) $(IFLAGS) src/paks/pcre/pcre.c

ifeq ($(ME_EXT_PCRE),1)
#
#   libpcre
#
DEPS_9 += $(CONFIG)/inc/pcre.h
DEPS_9 += $(CONFIG)/inc/me.h
DEPS_9 += $(CONFIG)/obj/pcre.o

$(CONFIG)/bin/libpcre.dylib: $(DEPS_9)
	@echo '      [Link] $(CONFIG)/bin/libpcre.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libpcre.dylib -arch $(CC_ARCH) $(LDFLAGS) -compatibility_version 5.0.0 -current_version 5.0.0 $(LIBPATHS) -install_name @rpath/libpcre.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/pcre.o" $(LIBS) 
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
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/httpLib.o -arch $(CC_ARCH) $(IFLAGS) src/paks/http/httpLib.c

#
#   libhttp
#
DEPS_12 += $(CONFIG)/inc/mpr.h
DEPS_12 += $(CONFIG)/inc/me.h
DEPS_12 += $(CONFIG)/inc/osdep.h
DEPS_12 += $(CONFIG)/obj/mprLib.o
DEPS_12 += $(CONFIG)/bin/libmpr.dylib
DEPS_12 += $(CONFIG)/inc/pcre.h
DEPS_12 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_12 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_12 += $(CONFIG)/inc/http.h
DEPS_12 += $(CONFIG)/obj/httpLib.o

LIBS_12 += -lmpr
ifeq ($(ME_EXT_PCRE),1)
    LIBS_12 += -lpcre
endif

$(CONFIG)/bin/libhttp.dylib: $(DEPS_12)
	@echo '      [Link] $(CONFIG)/bin/libhttp.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libhttp.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libhttp.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/httpLib.o" $(LIBPATHS_12) $(LIBS_12) $(LIBS_12) $(LIBS) -lpam 

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
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/config.o -arch $(CC_ARCH) $(IFLAGS) src/config.c

#
#   convenience.o
#
DEPS_16 += $(CONFIG)/inc/me.h
DEPS_16 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/convenience.o: \
    src/convenience.c $(DEPS_16)
	@echo '   [Compile] $(CONFIG)/obj/convenience.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/convenience.o -arch $(CC_ARCH) $(IFLAGS) src/convenience.c

#
#   dirHandler.o
#
DEPS_17 += $(CONFIG)/inc/me.h
DEPS_17 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/dirHandler.o: \
    src/dirHandler.c $(DEPS_17)
	@echo '   [Compile] $(CONFIG)/obj/dirHandler.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/dirHandler.o -arch $(CC_ARCH) $(IFLAGS) src/dirHandler.c

#
#   fileHandler.o
#
DEPS_18 += $(CONFIG)/inc/me.h
DEPS_18 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/fileHandler.o: \
    src/fileHandler.c $(DEPS_18)
	@echo '   [Compile] $(CONFIG)/obj/fileHandler.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/fileHandler.o -arch $(CC_ARCH) $(IFLAGS) src/fileHandler.c

#
#   log.o
#
DEPS_19 += $(CONFIG)/inc/me.h
DEPS_19 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/log.o: \
    src/log.c $(DEPS_19)
	@echo '   [Compile] $(CONFIG)/obj/log.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/log.o -arch $(CC_ARCH) $(IFLAGS) src/log.c

#
#   server.o
#
DEPS_20 += $(CONFIG)/inc/me.h
DEPS_20 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/server.o: \
    src/server.c $(DEPS_20)
	@echo '   [Compile] $(CONFIG)/obj/server.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/server.o -arch $(CC_ARCH) $(IFLAGS) src/server.c

#
#   libappweb
#
DEPS_21 += $(CONFIG)/inc/mpr.h
DEPS_21 += $(CONFIG)/inc/me.h
DEPS_21 += $(CONFIG)/inc/osdep.h
DEPS_21 += $(CONFIG)/obj/mprLib.o
DEPS_21 += $(CONFIG)/bin/libmpr.dylib
DEPS_21 += $(CONFIG)/inc/pcre.h
DEPS_21 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_21 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_21 += $(CONFIG)/inc/http.h
DEPS_21 += $(CONFIG)/obj/httpLib.o
DEPS_21 += $(CONFIG)/bin/libhttp.dylib
DEPS_21 += $(CONFIG)/inc/appweb.h
DEPS_21 += $(CONFIG)/inc/customize.h
DEPS_21 += $(CONFIG)/obj/config.o
DEPS_21 += $(CONFIG)/obj/convenience.o
DEPS_21 += $(CONFIG)/obj/dirHandler.o
DEPS_21 += $(CONFIG)/obj/fileHandler.o
DEPS_21 += $(CONFIG)/obj/log.o
DEPS_21 += $(CONFIG)/obj/server.o

LIBS_21 += -lhttp
LIBS_21 += -lmpr
ifeq ($(ME_EXT_PCRE),1)
    LIBS_21 += -lpcre
endif

$(CONFIG)/bin/libappweb.dylib: $(DEPS_21)
	@echo '      [Link] $(CONFIG)/bin/libappweb.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libappweb.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libappweb.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/config.o" "$(CONFIG)/obj/convenience.o" "$(CONFIG)/obj/dirHandler.o" "$(CONFIG)/obj/fileHandler.o" "$(CONFIG)/obj/log.o" "$(CONFIG)/obj/server.o" $(LIBPATHS_21) $(LIBS_21) $(LIBS_21) $(LIBS) -lpam 

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
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/espLib.o -arch $(CC_ARCH) $(IFLAGS) src/paks/esp/espLib.c

ifeq ($(ME_EXT_ESP),1)
#
#   libmod_esp
#
DEPS_24 += $(CONFIG)/inc/mpr.h
DEPS_24 += $(CONFIG)/inc/me.h
DEPS_24 += $(CONFIG)/inc/osdep.h
DEPS_24 += $(CONFIG)/obj/mprLib.o
DEPS_24 += $(CONFIG)/bin/libmpr.dylib
DEPS_24 += $(CONFIG)/inc/pcre.h
DEPS_24 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_24 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_24 += $(CONFIG)/inc/http.h
DEPS_24 += $(CONFIG)/obj/httpLib.o
DEPS_24 += $(CONFIG)/bin/libhttp.dylib
DEPS_24 += $(CONFIG)/inc/appweb.h
DEPS_24 += $(CONFIG)/inc/customize.h
DEPS_24 += $(CONFIG)/obj/config.o
DEPS_24 += $(CONFIG)/obj/convenience.o
DEPS_24 += $(CONFIG)/obj/dirHandler.o
DEPS_24 += $(CONFIG)/obj/fileHandler.o
DEPS_24 += $(CONFIG)/obj/log.o
DEPS_24 += $(CONFIG)/obj/server.o
DEPS_24 += $(CONFIG)/bin/libappweb.dylib
DEPS_24 += $(CONFIG)/inc/esp.h
DEPS_24 += $(CONFIG)/obj/espLib.o

LIBS_24 += -lappweb
LIBS_24 += -lhttp
LIBS_24 += -lmpr
ifeq ($(ME_EXT_PCRE),1)
    LIBS_24 += -lpcre
endif

$(CONFIG)/bin/libmod_esp.dylib: $(DEPS_24)
	@echo '      [Link] $(CONFIG)/bin/libmod_esp.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmod_esp.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libmod_esp.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/espLib.o" $(LIBPATHS_24) $(LIBS_24) $(LIBS_24) $(LIBS) -lpam 
endif

#
#   esp.o
#
DEPS_25 += $(CONFIG)/inc/me.h
DEPS_25 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/esp.o: \
    src/paks/esp/esp.c $(DEPS_25)
	@echo '   [Compile] $(CONFIG)/obj/esp.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/esp.o -arch $(CC_ARCH) $(IFLAGS) src/paks/esp/esp.c

ifeq ($(ME_EXT_ESP),1)
#
#   espcmd
#
DEPS_26 += $(CONFIG)/inc/mpr.h
DEPS_26 += $(CONFIG)/inc/me.h
DEPS_26 += $(CONFIG)/inc/osdep.h
DEPS_26 += $(CONFIG)/obj/mprLib.o
DEPS_26 += $(CONFIG)/bin/libmpr.dylib
DEPS_26 += $(CONFIG)/inc/pcre.h
DEPS_26 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_26 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_26 += $(CONFIG)/inc/http.h
DEPS_26 += $(CONFIG)/obj/httpLib.o
DEPS_26 += $(CONFIG)/bin/libhttp.dylib
DEPS_26 += $(CONFIG)/inc/appweb.h
DEPS_26 += $(CONFIG)/inc/customize.h
DEPS_26 += $(CONFIG)/obj/config.o
DEPS_26 += $(CONFIG)/obj/convenience.o
DEPS_26 += $(CONFIG)/obj/dirHandler.o
DEPS_26 += $(CONFIG)/obj/fileHandler.o
DEPS_26 += $(CONFIG)/obj/log.o
DEPS_26 += $(CONFIG)/obj/server.o
DEPS_26 += $(CONFIG)/bin/libappweb.dylib
DEPS_26 += $(CONFIG)/inc/esp.h
DEPS_26 += $(CONFIG)/obj/espLib.o
DEPS_26 += $(CONFIG)/bin/libmod_esp.dylib
DEPS_26 += $(CONFIG)/obj/esp.o

LIBS_26 += -lappweb
LIBS_26 += -lhttp
LIBS_26 += -lmpr
ifeq ($(ME_EXT_PCRE),1)
    LIBS_26 += -lpcre
endif
LIBS_26 += -lmod_esp

$(CONFIG)/bin/esp: $(DEPS_26)
	@echo '      [Link] $(CONFIG)/bin/esp'
	$(CC) -o $(CONFIG)/bin/esp -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/esp.o" "$(CONFIG)/obj/espLib.o" $(LIBPATHS_26) $(LIBS_26) $(LIBS_26) $(LIBS) -lpam 
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
DEPS_28 += src/paks/esp-angular-mvc/templates
DEPS_28 += src/paks/esp-angular-mvc/templates/esp-angular-mvc
DEPS_28 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/appweb.conf
DEPS_28 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client
DEPS_28 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/app
DEPS_28 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/app/main.js
DEPS_28 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/assets
DEPS_28 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/assets/favicon.ico
DEPS_28 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/css
DEPS_28 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/css/all.css
DEPS_28 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/css/all.less
DEPS_28 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/css/app.less
DEPS_28 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/css/fix.css
DEPS_28 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/css/theme.less
DEPS_28 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/index.esp
DEPS_28 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/pages
DEPS_28 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/client/pages/splash.html
DEPS_28 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/controller-singleton.c
DEPS_28 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/controller.c
DEPS_28 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/controller.js
DEPS_28 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/edit.html
DEPS_28 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/list.html
DEPS_28 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/model.js
DEPS_28 += src/paks/esp-angular-mvc/templates/esp-angular-mvc/start.me
DEPS_28 += src/paks/esp-html-mvc
DEPS_28 += src/paks/esp-html-mvc/package.json
DEPS_28 += src/paks/esp-html-mvc/templates
DEPS_28 += src/paks/esp-html-mvc/templates/esp-html-mvc
DEPS_28 += src/paks/esp-html-mvc/templates/esp-html-mvc/appweb.conf
DEPS_28 += src/paks/esp-html-mvc/templates/esp-html-mvc/client
DEPS_28 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/assets
DEPS_28 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/assets/favicon.ico
DEPS_28 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/css
DEPS_28 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/css/all.css
DEPS_28 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/css/all.less
DEPS_28 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/css/app.less
DEPS_28 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/css/theme.less
DEPS_28 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/index.esp
DEPS_28 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/layouts
DEPS_28 += src/paks/esp-html-mvc/templates/esp-html-mvc/client/layouts/default.esp
DEPS_28 += src/paks/esp-html-mvc/templates/esp-html-mvc/controller-singleton.c
DEPS_28 += src/paks/esp-html-mvc/templates/esp-html-mvc/controller.c
DEPS_28 += src/paks/esp-html-mvc/templates/esp-html-mvc/edit.esp
DEPS_28 += src/paks/esp-html-mvc/templates/esp-html-mvc/list.esp
DEPS_28 += src/paks/esp-html-mvc/templates/esp-html-mvc/start.me
DEPS_28 += src/paks/esp-legacy-mvc
DEPS_28 += src/paks/esp-legacy-mvc/package.json
DEPS_28 += src/paks/esp-legacy-mvc/templates
DEPS_28 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc
DEPS_28 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/appweb.conf
DEPS_28 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/controller.c
DEPS_28 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/edit.esp
DEPS_28 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/layouts
DEPS_28 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/layouts/default.esp
DEPS_28 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/list.esp
DEPS_28 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/migration.c
DEPS_28 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/src
DEPS_28 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/src/app.c
DEPS_28 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static
DEPS_28 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/css
DEPS_28 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/css/all.css
DEPS_28 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/images
DEPS_28 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/images/banner.jpg
DEPS_28 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/images/favicon.ico
DEPS_28 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/images/splash.jpg
DEPS_28 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/index.esp
DEPS_28 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/js
DEPS_28 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/js/jquery.esp.js
DEPS_28 += src/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/js/jquery.js
DEPS_28 += src/paks/esp-server
DEPS_28 += src/paks/esp-server/package.json
DEPS_28 += src/paks/esp-server/templates
DEPS_28 += src/paks/esp-server/templates/esp-server
DEPS_28 += src/paks/esp-server/templates/esp-server/appweb.conf
DEPS_28 += src/paks/esp-server/templates/esp-server/controller.c
DEPS_28 += src/paks/esp-server/templates/esp-server/migration.c
DEPS_28 += src/paks/esp-server/templates/esp-server/src
DEPS_28 += src/paks/esp-server/templates/esp-server/src/app.c
DEPS_28 += src/paks/est
DEPS_28 += src/paks/est/ca.crt
DEPS_28 += src/paks/est/est.h
DEPS_28 += src/paks/est/est.me
DEPS_28 += src/paks/est/estLib.c
DEPS_28 += src/paks/est/LICENSE.md
DEPS_28 += src/paks/est/package.json
DEPS_28 += src/paks/est/README.md
DEPS_28 += src/paks/http
DEPS_28 += src/paks/http/http.c
DEPS_28 += src/paks/http/http.h
DEPS_28 += src/paks/http/http.me
DEPS_28 += src/paks/http/httpLib.c
DEPS_28 += src/paks/http/LICENSE.md
DEPS_28 += src/paks/http/package.json
DEPS_28 += src/paks/http/README.md
DEPS_28 += src/paks/me-dev
DEPS_28 += src/paks/me-dev/dev.es
DEPS_28 += src/paks/me-dev/dev.me
DEPS_28 += src/paks/me-dev/package.json
DEPS_28 += src/paks/me-doc
DEPS_28 += src/paks/me-doc/doc.es
DEPS_28 += src/paks/me-doc/doc.me
DEPS_28 += src/paks/me-doc/package.json
DEPS_28 += src/paks/me-package
DEPS_28 += src/paks/me-package/manifest.me
DEPS_28 += src/paks/me-package/package.es
DEPS_28 += src/paks/me-package/package.json
DEPS_28 += src/paks/me-package/package.me
DEPS_28 += src/paks/mpr
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
DEPS_28 += src/paks/osdep/LICENSE.md
DEPS_28 += src/paks/osdep/osdep.h
DEPS_28 += src/paks/osdep/osdep.me
DEPS_28 += src/paks/osdep/package.json
DEPS_28 += src/paks/osdep/README.md
DEPS_28 += src/paks/pcre
DEPS_28 += src/paks/pcre/LICENSE.md
DEPS_28 += src/paks/pcre/package.json
DEPS_28 += src/paks/pcre/pcre.c
DEPS_28 += src/paks/pcre/pcre.h
DEPS_28 += src/paks/pcre/pcre.me
DEPS_28 += src/paks/pcre/README.md
DEPS_28 += src/paks/sqlite
DEPS_28 += src/paks/sqlite/LICENSE.md
DEPS_28 += src/paks/sqlite/package.json
DEPS_28 += src/paks/sqlite/README.md
DEPS_28 += src/paks/sqlite/sqlite.c
DEPS_28 += src/paks/sqlite/sqlite.me
DEPS_28 += src/paks/sqlite/sqlite3.c
DEPS_28 += src/paks/sqlite/sqlite3.h
DEPS_28 += src/paks/zlib
DEPS_28 += src/paks/zlib/LICENSE.md
DEPS_28 += src/paks/zlib/package.json
DEPS_28 += src/paks/zlib/README.md
DEPS_28 += src/paks/zlib/zlib.c
DEPS_28 += src/paks/zlib/zlib.h
DEPS_28 += src/paks/zlib/zlib.me

$(CONFIG)/paks: $(DEPS_28)
	( \
	cd src/paks; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular/0.9.0" ; \
	cp esp-angular/esp-click.js ../../$(CONFIG)/paks/esp-angular/0.9.0/esp-click.js ; \
	cp esp-angular/esp-edit.js ../../$(CONFIG)/paks/esp-angular/0.9.0/esp-edit.js ; \
	cp esp-angular/esp-field-errors.js ../../$(CONFIG)/paks/esp-angular/0.9.0/esp-field-errors.js ; \
	cp esp-angular/esp-fixnum.js ../../$(CONFIG)/paks/esp-angular/0.9.0/esp-fixnum.js ; \
	cp esp-angular/esp-format.js ../../$(CONFIG)/paks/esp-angular/0.9.0/esp-format.js ; \
	cp esp-angular/esp-input-group.js ../../$(CONFIG)/paks/esp-angular/0.9.0/esp-input-group.js ; \
	cp esp-angular/esp-input.js ../../$(CONFIG)/paks/esp-angular/0.9.0/esp-input.js ; \
	cp esp-angular/esp-resource.js ../../$(CONFIG)/paks/esp-angular/0.9.0/esp-resource.js ; \
	cp esp-angular/esp-session.js ../../$(CONFIG)/paks/esp-angular/0.9.0/esp-session.js ; \
	cp esp-angular/esp-titlecase.js ../../$(CONFIG)/paks/esp-angular/0.9.0/esp-titlecase.js ; \
	cp esp-angular/esp.js ../../$(CONFIG)/paks/esp-angular/0.9.0/esp.js ; \
	cp esp-angular/package.json ../../$(CONFIG)/paks/esp-angular/0.9.0/package.json ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/0.9.0" ; \
	cp esp-angular-mvc/package.json ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/package.json ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates" ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc" ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/appweb.conf ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/appweb.conf ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client" ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/app" ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/app/main.js ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/app/main.js ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/assets" ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/assets/favicon.ico ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/assets/favicon.ico ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/css" ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/css/all.css ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/css/all.css ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/css/all.less ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/css/all.less ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/css/app.less ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/css/app.less ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/css/fix.css ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/css/fix.css ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/css/theme.less ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/css/theme.less ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/index.esp ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/index.esp ; \
	mkdir -p "../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/pages" ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/client/pages/splash.html ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/client/pages/splash.html ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/controller-singleton.c ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/controller-singleton.c ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/controller.c ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/controller.c ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/controller.js ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/controller.js ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/edit.html ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/edit.html ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/list.html ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/list.html ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/model.js ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/model.js ; \
	cp esp-angular-mvc/templates/esp-angular-mvc/start.me ../../$(CONFIG)/paks/esp-angular-mvc/0.9.0/templates/esp-angular-mvc/start.me ; \
	mkdir -p "../../$(CONFIG)/paks/esp-html-mvc/0.9.0" ; \
	cp esp-html-mvc/package.json ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/package.json ; \
	mkdir -p "../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates" ; \
	mkdir -p "../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc" ; \
	cp esp-html-mvc/templates/esp-html-mvc/appweb.conf ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/appweb.conf ; \
	mkdir -p "../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/client" ; \
	mkdir -p "../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/client/assets" ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/assets/favicon.ico ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/client/assets/favicon.ico ; \
	mkdir -p "../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/client/css" ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/css/all.css ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/client/css/all.css ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/css/all.less ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/client/css/all.less ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/css/app.less ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/client/css/app.less ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/css/theme.less ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/client/css/theme.less ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/index.esp ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/client/index.esp ; \
	mkdir -p "../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/client/layouts" ; \
	cp esp-html-mvc/templates/esp-html-mvc/client/layouts/default.esp ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/client/layouts/default.esp ; \
	cp esp-html-mvc/templates/esp-html-mvc/controller-singleton.c ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/controller-singleton.c ; \
	cp esp-html-mvc/templates/esp-html-mvc/controller.c ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/controller.c ; \
	cp esp-html-mvc/templates/esp-html-mvc/edit.esp ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/edit.esp ; \
	cp esp-html-mvc/templates/esp-html-mvc/list.esp ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/list.esp ; \
	cp esp-html-mvc/templates/esp-html-mvc/start.me ../../$(CONFIG)/paks/esp-html-mvc/0.9.0/templates/esp-html-mvc/start.me ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0" ; \
	cp esp-legacy-mvc/package.json ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/package.json ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates" ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc" ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/appweb.conf ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/appweb.conf ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/controller.c ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/controller.c ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/edit.esp ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/edit.esp ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/layouts" ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/layouts/default.esp ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/layouts/default.esp ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/list.esp ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/list.esp ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/migration.c ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/migration.c ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/src" ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/src/app.c ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/src/app.c ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/static" ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/static/css" ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/css/all.css ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/static/css/all.css ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/static/images" ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/images/banner.jpg ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/static/images/banner.jpg ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/images/favicon.ico ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/static/images/favicon.ico ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/images/splash.jpg ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/static/images/splash.jpg ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/index.esp ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/static/index.esp ; \
	mkdir -p "../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/static/js" ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/js/jquery.esp.js ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/static/js/jquery.esp.js ; \
	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/js/jquery.js ../../$(CONFIG)/paks/esp-legacy-mvc/0.9.0/templates/esp-legacy-mvc/static/js/jquery.js ; \
	mkdir -p "../../$(CONFIG)/paks/esp-server/0.9.0" ; \
	cp esp-server/package.json ../../$(CONFIG)/paks/esp-server/0.9.0/package.json ; \
	mkdir -p "../../$(CONFIG)/paks/esp-server/0.9.0/templates" ; \
	mkdir -p "../../$(CONFIG)/paks/esp-server/0.9.0/templates/esp-server" ; \
	cp esp-server/templates/esp-server/appweb.conf ../../$(CONFIG)/paks/esp-server/0.9.0/templates/esp-server/appweb.conf ; \
	cp esp-server/templates/esp-server/controller.c ../../$(CONFIG)/paks/esp-server/0.9.0/templates/esp-server/controller.c ; \
	cp esp-server/templates/esp-server/migration.c ../../$(CONFIG)/paks/esp-server/0.9.0/templates/esp-server/migration.c ; \
	mkdir -p "../../$(CONFIG)/paks/esp-server/0.9.0/templates/esp-server/src" ; \
	cp esp-server/templates/esp-server/src/app.c ../../$(CONFIG)/paks/esp-server/0.9.0/templates/esp-server/src/app.c ; \
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
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/estLib.o -arch $(CC_ARCH) $(IFLAGS) src/paks/est/estLib.c

ifeq ($(ME_EXT_EST),1)
#
#   libest
#
DEPS_31 += $(CONFIG)/inc/est.h
DEPS_31 += $(CONFIG)/inc/me.h
DEPS_31 += $(CONFIG)/inc/osdep.h
DEPS_31 += $(CONFIG)/obj/estLib.o

$(CONFIG)/bin/libest.dylib: $(DEPS_31)
	@echo '      [Link] $(CONFIG)/bin/libest.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libest.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libest.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/estLib.o" $(LIBS) 
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
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/http.o -arch $(CC_ARCH) $(IFLAGS) src/paks/http/http.c

#
#   httpcmd
#
DEPS_34 += $(CONFIG)/inc/mpr.h
DEPS_34 += $(CONFIG)/inc/me.h
DEPS_34 += $(CONFIG)/inc/osdep.h
DEPS_34 += $(CONFIG)/obj/mprLib.o
DEPS_34 += $(CONFIG)/bin/libmpr.dylib
DEPS_34 += $(CONFIG)/inc/pcre.h
DEPS_34 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_34 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_34 += $(CONFIG)/inc/http.h
DEPS_34 += $(CONFIG)/obj/httpLib.o
DEPS_34 += $(CONFIG)/bin/libhttp.dylib
DEPS_34 += $(CONFIG)/obj/http.o

LIBS_34 += -lhttp
LIBS_34 += -lmpr
ifeq ($(ME_EXT_PCRE),1)
    LIBS_34 += -lpcre
endif

$(CONFIG)/bin/http: $(DEPS_34)
	@echo '      [Link] $(CONFIG)/bin/http'
	$(CC) -o $(CONFIG)/bin/http -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/http.o" $(LIBPATHS_34) $(LIBS_34) $(LIBS_34) $(LIBS) -lpam 

#
#   mprSsl.o
#
DEPS_35 += $(CONFIG)/inc/me.h
DEPS_35 += $(CONFIG)/inc/mpr.h
DEPS_35 += $(CONFIG)/inc/est.h

$(CONFIG)/obj/mprSsl.o: \
    src/paks/mpr/mprSsl.c $(DEPS_35)
	@echo '   [Compile] $(CONFIG)/obj/mprSsl.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/mprSsl.o -arch $(CC_ARCH) $(IFLAGS) src/paks/mpr/mprSsl.c

#
#   libmprssl
#
DEPS_36 += $(CONFIG)/inc/mpr.h
DEPS_36 += $(CONFIG)/inc/me.h
DEPS_36 += $(CONFIG)/inc/osdep.h
DEPS_36 += $(CONFIG)/obj/mprLib.o
DEPS_36 += $(CONFIG)/bin/libmpr.dylib
DEPS_36 += $(CONFIG)/inc/est.h
DEPS_36 += $(CONFIG)/obj/estLib.o
ifeq ($(ME_EXT_EST),1)
    DEPS_36 += $(CONFIG)/bin/libest.dylib
endif
DEPS_36 += $(CONFIG)/obj/mprSsl.o

LIBS_36 += -lmpr
ifeq ($(ME_EXT_EST),1)
    LIBS_36 += -lest
endif

$(CONFIG)/bin/libmprssl.dylib: $(DEPS_36)
	@echo '      [Link] $(CONFIG)/bin/libmprssl.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmprssl.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libmprssl.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/mprSsl.o" $(LIBPATHS_36) $(LIBS_36) $(LIBS_36) $(LIBS) 

#
#   manager.o
#
DEPS_37 += $(CONFIG)/inc/me.h
DEPS_37 += $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/manager.o: \
    src/paks/mpr/manager.c $(DEPS_37)
	@echo '   [Compile] $(CONFIG)/obj/manager.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/manager.o -arch $(CC_ARCH) $(IFLAGS) src/paks/mpr/manager.c

#
#   manager
#
DEPS_38 += $(CONFIG)/inc/mpr.h
DEPS_38 += $(CONFIG)/inc/me.h
DEPS_38 += $(CONFIG)/inc/osdep.h
DEPS_38 += $(CONFIG)/obj/mprLib.o
DEPS_38 += $(CONFIG)/bin/libmpr.dylib
DEPS_38 += $(CONFIG)/obj/manager.o

LIBS_38 += -lmpr

$(CONFIG)/bin/appman: $(DEPS_38)
	@echo '      [Link] $(CONFIG)/bin/appman'
	$(CC) -o $(CONFIG)/bin/appman -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/manager.o" $(LIBPATHS_38) $(LIBS_38) $(LIBS_38) $(LIBS) 

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
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/zlib.o -arch $(CC_ARCH) $(IFLAGS) src/paks/zlib/zlib.c

ifeq ($(ME_EXT_ZLIB),1)
#
#   libzlib
#
DEPS_41 += $(CONFIG)/inc/zlib.h
DEPS_41 += $(CONFIG)/inc/me.h
DEPS_41 += $(CONFIG)/obj/zlib.o

$(CONFIG)/bin/libzlib.dylib: $(DEPS_41)
	@echo '      [Link] $(CONFIG)/bin/libzlib.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libzlib.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libzlib.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/zlib.o" $(LIBS) 
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
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/slink.o -arch $(CC_ARCH) $(IFLAGS) src/slink.c

#
#   libslink
#
DEPS_44 += src/slink.c
DEPS_44 += $(CONFIG)/inc/me.h
DEPS_44 += $(CONFIG)/inc/esp.h
DEPS_44 += $(CONFIG)/obj/slink.o

$(CONFIG)/bin/libslink.dylib: $(DEPS_44)
	@echo '      [Link] $(CONFIG)/bin/libslink.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libslink.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libslink.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/slink.o" $(LIBS) 

#
#   sslModule.o
#
DEPS_45 += $(CONFIG)/inc/me.h
DEPS_45 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/sslModule.o: \
    src/modules/sslModule.c $(DEPS_45)
	@echo '   [Compile] $(CONFIG)/obj/sslModule.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/sslModule.o -arch $(CC_ARCH) $(IFLAGS) src/modules/sslModule.c

ifeq ($(ME_EXT_SSL),1)
#
#   libmod_ssl
#
DEPS_46 += $(CONFIG)/inc/mpr.h
DEPS_46 += $(CONFIG)/inc/me.h
DEPS_46 += $(CONFIG)/inc/osdep.h
DEPS_46 += $(CONFIG)/obj/mprLib.o
DEPS_46 += $(CONFIG)/bin/libmpr.dylib
DEPS_46 += $(CONFIG)/inc/pcre.h
DEPS_46 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_46 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_46 += $(CONFIG)/inc/http.h
DEPS_46 += $(CONFIG)/obj/httpLib.o
DEPS_46 += $(CONFIG)/bin/libhttp.dylib
DEPS_46 += $(CONFIG)/inc/appweb.h
DEPS_46 += $(CONFIG)/inc/customize.h
DEPS_46 += $(CONFIG)/obj/config.o
DEPS_46 += $(CONFIG)/obj/convenience.o
DEPS_46 += $(CONFIG)/obj/dirHandler.o
DEPS_46 += $(CONFIG)/obj/fileHandler.o
DEPS_46 += $(CONFIG)/obj/log.o
DEPS_46 += $(CONFIG)/obj/server.o
DEPS_46 += $(CONFIG)/bin/libappweb.dylib
DEPS_46 += $(CONFIG)/inc/est.h
DEPS_46 += $(CONFIG)/obj/estLib.o
ifeq ($(ME_EXT_EST),1)
    DEPS_46 += $(CONFIG)/bin/libest.dylib
endif
DEPS_46 += $(CONFIG)/obj/mprSsl.o
DEPS_46 += $(CONFIG)/bin/libmprssl.dylib
DEPS_46 += $(CONFIG)/obj/sslModule.o

LIBS_46 += -lappweb
LIBS_46 += -lhttp
LIBS_46 += -lmpr
ifeq ($(ME_EXT_PCRE),1)
    LIBS_46 += -lpcre
endif
LIBS_46 += -lmprssl
ifeq ($(ME_EXT_EST),1)
    LIBS_46 += -lest
endif

$(CONFIG)/bin/libmod_ssl.dylib: $(DEPS_46)
	@echo '      [Link] $(CONFIG)/bin/libmod_ssl.dylib'
	$(CC) -dynamiclib -o $(CONFIG)/bin/libmod_ssl.dylib -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) -install_name @rpath/libmod_ssl.dylib -compatibility_version 5.0.0 -current_version 5.0.0 "$(CONFIG)/obj/sslModule.o" $(LIBPATHS_46) $(LIBS_46) $(LIBS_46) $(LIBS) -lpam 
endif

#
#   authpass.o
#
DEPS_47 += $(CONFIG)/inc/me.h
DEPS_47 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/authpass.o: \
    src/utils/authpass.c $(DEPS_47)
	@echo '   [Compile] $(CONFIG)/obj/authpass.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/authpass.o -arch $(CC_ARCH) $(IFLAGS) src/utils/authpass.c

#
#   authpass
#
DEPS_48 += $(CONFIG)/inc/mpr.h
DEPS_48 += $(CONFIG)/inc/me.h
DEPS_48 += $(CONFIG)/inc/osdep.h
DEPS_48 += $(CONFIG)/obj/mprLib.o
DEPS_48 += $(CONFIG)/bin/libmpr.dylib
DEPS_48 += $(CONFIG)/inc/pcre.h
DEPS_48 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_48 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_48 += $(CONFIG)/inc/http.h
DEPS_48 += $(CONFIG)/obj/httpLib.o
DEPS_48 += $(CONFIG)/bin/libhttp.dylib
DEPS_48 += $(CONFIG)/inc/appweb.h
DEPS_48 += $(CONFIG)/inc/customize.h
DEPS_48 += $(CONFIG)/obj/config.o
DEPS_48 += $(CONFIG)/obj/convenience.o
DEPS_48 += $(CONFIG)/obj/dirHandler.o
DEPS_48 += $(CONFIG)/obj/fileHandler.o
DEPS_48 += $(CONFIG)/obj/log.o
DEPS_48 += $(CONFIG)/obj/server.o
DEPS_48 += $(CONFIG)/bin/libappweb.dylib
DEPS_48 += $(CONFIG)/obj/authpass.o

LIBS_48 += -lappweb
LIBS_48 += -lhttp
LIBS_48 += -lmpr
ifeq ($(ME_EXT_PCRE),1)
    LIBS_48 += -lpcre
endif

$(CONFIG)/bin/authpass: $(DEPS_48)
	@echo '      [Link] $(CONFIG)/bin/authpass'
	$(CC) -o $(CONFIG)/bin/authpass -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/authpass.o" $(LIBPATHS_48) $(LIBS_48) $(LIBS_48) $(LIBS) -lpam 

#
#   appweb.o
#
DEPS_49 += $(CONFIG)/inc/me.h
DEPS_49 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/appweb.o: \
    src/server/appweb.c $(DEPS_49)
	@echo '   [Compile] $(CONFIG)/obj/appweb.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/appweb.o -arch $(CC_ARCH) $(IFLAGS) src/server/appweb.c

#
#   appweb
#
DEPS_50 += $(CONFIG)/inc/mpr.h
DEPS_50 += $(CONFIG)/inc/me.h
DEPS_50 += $(CONFIG)/inc/osdep.h
DEPS_50 += $(CONFIG)/obj/mprLib.o
DEPS_50 += $(CONFIG)/bin/libmpr.dylib
DEPS_50 += $(CONFIG)/inc/pcre.h
DEPS_50 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_50 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_50 += $(CONFIG)/inc/http.h
DEPS_50 += $(CONFIG)/obj/httpLib.o
DEPS_50 += $(CONFIG)/bin/libhttp.dylib
DEPS_50 += $(CONFIG)/inc/appweb.h
DEPS_50 += $(CONFIG)/inc/customize.h
DEPS_50 += $(CONFIG)/obj/config.o
DEPS_50 += $(CONFIG)/obj/convenience.o
DEPS_50 += $(CONFIG)/obj/dirHandler.o
DEPS_50 += $(CONFIG)/obj/fileHandler.o
DEPS_50 += $(CONFIG)/obj/log.o
DEPS_50 += $(CONFIG)/obj/server.o
DEPS_50 += $(CONFIG)/bin/libappweb.dylib
DEPS_50 += src/slink.c
DEPS_50 += $(CONFIG)/inc/esp.h
DEPS_50 += $(CONFIG)/obj/slink.o
DEPS_50 += $(CONFIG)/bin/libslink.dylib
DEPS_50 += $(CONFIG)/obj/appweb.o

LIBS_50 += -lappweb
LIBS_50 += -lhttp
LIBS_50 += -lmpr
ifeq ($(ME_EXT_PCRE),1)
    LIBS_50 += -lpcre
endif
LIBS_50 += -lslink

$(CONFIG)/bin/appweb: $(DEPS_50)
	@echo '      [Link] $(CONFIG)/bin/appweb'
	$(CC) -o $(CONFIG)/bin/appweb -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/appweb.o" $(LIBPATHS_50) $(LIBS_50) $(LIBS_50) $(LIBS) -lpam 

#
#   server-cache
#
src/server/cache: $(DEPS_51)
	( \
	cd src/server; \
	mkdir -p cache ; \
	)

#
#   testAppweb.h
#
$(CONFIG)/inc/testAppweb.h: $(DEPS_52)
	@echo '      [Copy] $(CONFIG)/inc/testAppweb.h'
	mkdir -p "$(CONFIG)/inc"
	cp test/src/testAppweb.h $(CONFIG)/inc/testAppweb.h

#
#   testAppweb.o
#
DEPS_53 += $(CONFIG)/inc/me.h
DEPS_53 += $(CONFIG)/inc/testAppweb.h
DEPS_53 += $(CONFIG)/inc/mpr.h
DEPS_53 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/testAppweb.o: \
    test/src/testAppweb.c $(DEPS_53)
	@echo '   [Compile] $(CONFIG)/obj/testAppweb.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/testAppweb.o -arch $(CC_ARCH) $(IFLAGS) test/src/testAppweb.c

#
#   testHttp.o
#
DEPS_54 += $(CONFIG)/inc/me.h
DEPS_54 += $(CONFIG)/inc/testAppweb.h

$(CONFIG)/obj/testHttp.o: \
    test/src/testHttp.c $(DEPS_54)
	@echo '   [Compile] $(CONFIG)/obj/testHttp.o'
	$(CC) -c $(CFLAGS) $(DFLAGS) -o $(CONFIG)/obj/testHttp.o -arch $(CC_ARCH) $(IFLAGS) test/src/testHttp.c

#
#   testAppweb
#
DEPS_55 += $(CONFIG)/inc/mpr.h
DEPS_55 += $(CONFIG)/inc/me.h
DEPS_55 += $(CONFIG)/inc/osdep.h
DEPS_55 += $(CONFIG)/obj/mprLib.o
DEPS_55 += $(CONFIG)/bin/libmpr.dylib
DEPS_55 += $(CONFIG)/inc/pcre.h
DEPS_55 += $(CONFIG)/obj/pcre.o
ifeq ($(ME_EXT_PCRE),1)
    DEPS_55 += $(CONFIG)/bin/libpcre.dylib
endif
DEPS_55 += $(CONFIG)/inc/http.h
DEPS_55 += $(CONFIG)/obj/httpLib.o
DEPS_55 += $(CONFIG)/bin/libhttp.dylib
DEPS_55 += $(CONFIG)/inc/appweb.h
DEPS_55 += $(CONFIG)/inc/customize.h
DEPS_55 += $(CONFIG)/obj/config.o
DEPS_55 += $(CONFIG)/obj/convenience.o
DEPS_55 += $(CONFIG)/obj/dirHandler.o
DEPS_55 += $(CONFIG)/obj/fileHandler.o
DEPS_55 += $(CONFIG)/obj/log.o
DEPS_55 += $(CONFIG)/obj/server.o
DEPS_55 += $(CONFIG)/bin/libappweb.dylib
DEPS_55 += $(CONFIG)/inc/testAppweb.h
DEPS_55 += $(CONFIG)/obj/testAppweb.o
DEPS_55 += $(CONFIG)/obj/testHttp.o

LIBS_55 += -lappweb
LIBS_55 += -lhttp
LIBS_55 += -lmpr
ifeq ($(ME_EXT_PCRE),1)
    LIBS_55 += -lpcre
endif

$(CONFIG)/bin/testAppweb: $(DEPS_55)
	@echo '      [Link] $(CONFIG)/bin/testAppweb'
	$(CC) -o $(CONFIG)/bin/testAppweb -arch $(CC_ARCH) $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/testAppweb.o" "$(CONFIG)/obj/testHttp.o" $(LIBPATHS_55) $(LIBS_55) $(LIBS_55) $(LIBS) -lpam 


#
#   stop
#
DEPS_56 += compile

stop: $(DEPS_56)
	( \
	cd .; \
	@./$(CONFIG)/bin/appman stop disable uninstall >/dev/null 2>&1 ; true ; \
	)

#
#   installBinary
#
installBinary: $(DEPS_57)
	( \
	cd .; \
	mkdir -p "$(ME_APP_PREFIX)" ; \
	rm -f "$(ME_APP_PREFIX)/latest" ; \
	ln -s "5.0.0-rc0" "$(ME_APP_PREFIX)/latest" ; \
	mkdir -p "$(ME_LOG_PREFIX)" ; \
	chmod 755 "$(ME_LOG_PREFIX)" ; \
	[ `id -u` = 0 ] && chown $(WEB_USER):$(WEB_GROUP) "$(ME_LOG_PREFIX)"; true ; \
	mkdir -p "$(ME_CACHE_PREFIX)" ; \
	chmod 755 "$(ME_CACHE_PREFIX)" ; \
	[ `id -u` = 0 ] && chown $(WEB_USER):$(WEB_GROUP) "$(ME_CACHE_PREFIX)"; true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin" ; \
	cp $(CONFIG)/bin/appweb $(ME_VAPP_PREFIX)/bin/appweb ; \
	mkdir -p "$(ME_BIN_PREFIX)" ; \
	rm -f "$(ME_BIN_PREFIX)/appweb" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/appweb" "$(ME_BIN_PREFIX)/appweb" ; \
	cp $(CONFIG)/bin/appman $(ME_VAPP_PREFIX)/bin/appman ; \
	rm -f "$(ME_BIN_PREFIX)/appman" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/appman" "$(ME_BIN_PREFIX)/appman" ; \
	cp $(CONFIG)/bin/http $(ME_VAPP_PREFIX)/bin/http ; \
	rm -f "$(ME_BIN_PREFIX)/http" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/http" "$(ME_BIN_PREFIX)/http" ; \
	if [ "$(ME_EXT_ESP)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/esp $(ME_VAPP_PREFIX)/bin/esp ; \
	rm -f "$(ME_BIN_PREFIX)/esp" ; \
	ln -s "$(ME_VAPP_PREFIX)/bin/esp" "$(ME_BIN_PREFIX)/esp" ; \
	fi ; \
	cp $(CONFIG)/bin/libappweb.dylib $(ME_VAPP_PREFIX)/bin/libappweb.dylib ; \
	cp $(CONFIG)/bin/libhttp.dylib $(ME_VAPP_PREFIX)/bin/libhttp.dylib ; \
	cp $(CONFIG)/bin/libmpr.dylib $(ME_VAPP_PREFIX)/bin/libmpr.dylib ; \
	cp $(CONFIG)/bin/libpcre.dylib $(ME_VAPP_PREFIX)/bin/libpcre.dylib ; \
	cp $(CONFIG)/bin/libslink.dylib $(ME_VAPP_PREFIX)/bin/libslink.dylib ; \
	if [ "$(ME_EXT_SSL)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/libmprssl.dylib $(ME_VAPP_PREFIX)/bin/libmprssl.dylib ; \
	cp $(CONFIG)/bin/libmod_ssl.dylib $(ME_VAPP_PREFIX)/bin/libmod_ssl.dylib ; \
	fi ; \
	if [ "$(ME_EXT_SSL)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/ca.crt $(ME_VAPP_PREFIX)/bin/ca.crt ; \
	fi ; \
	if [ "$(ME_EXT_OPENSSL)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/libssl*.dylib* $(ME_VAPP_PREFIX)/bin/libssl*.dylib* ; \
	cp $(CONFIG)/bin/libcrypto*.dylib* $(ME_VAPP_PREFIX)/bin/libcrypto*.dylib* ; \
	fi ; \
	if [ "$(ME_EXT_EST)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/libest.dylib $(ME_VAPP_PREFIX)/bin/libest.dylib ; \
	fi ; \
	if [ "$(ME_EXT_SQLITE)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/libsql.dylib $(ME_VAPP_PREFIX)/bin/libsql.dylib ; \
	fi ; \
	if [ "$(ME_EXT_ESP)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/libmod_esp.dylib $(ME_VAPP_PREFIX)/bin/libmod_esp.dylib ; \
	fi ; \
	if [ "$(ME_EXT_CGI)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/libmod_cgi.dylib $(ME_VAPP_PREFIX)/bin/libmod_cgi.dylib ; \
	fi ; \
	if [ "$(ME_EXT_EJS)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/libejs.dylib $(ME_VAPP_PREFIX)/bin/libejs.dylib ; \
	cp $(CONFIG)/bin/libmod_ejs.dylib $(ME_VAPP_PREFIX)/bin/libmod_ejs.dylib ; \
	fi ; \
	if [ "$(ME_EXT_PHP)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/libmod_php.dylib $(ME_VAPP_PREFIX)/bin/libmod_php.dylib ; \
	fi ; \
	if [ "$(ME_EXT_PHP)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/libphp5.dylib $(ME_VAPP_PREFIX)/bin/libphp5.dylib ; \
	fi ; \
	if [ "$(ME_EXT_ESP)" = 1 ]; then true ; \
	mkdir -p "$(ME_VAPP_PREFIX)/bin/.." ; \
	cp $(CONFIG)/paks $(ME_VAPP_PREFIX)/bin/../esp ; \
	fi ; \
	if [ "$(ME_EXT_ESP)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/esp.conf $(ME_VAPP_PREFIX)/bin/esp.conf ; \
	fi ; \
	mkdir -p "$(ME_WEB_PREFIX)/bench" ; \
	cp src/server/web/bench/1b.html $(ME_WEB_PREFIX)/bench/1b.html ; \
	cp src/server/web/bench/4k.html $(ME_WEB_PREFIX)/bench/4k.html ; \
	cp src/server/web/bench/64k.html $(ME_WEB_PREFIX)/bench/64k.html ; \
	mkdir -p "$(ME_WEB_PREFIX)" ; \
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
	mkdir -p "$(ME_ETC_PREFIX)" ; \
	cp src/server/mime.types $(ME_ETC_PREFIX)/mime.types ; \
	cp src/server/self.crt $(ME_ETC_PREFIX)/self.crt ; \
	cp src/server/self.key $(ME_ETC_PREFIX)/self.key ; \
	if [ "$(ME_EXT_PHP)" = 1 ]; then true ; \
	cp src/server/php.ini $(ME_ETC_PREFIX)/php.ini ; \
	fi ; \
	cp src/server/appweb.conf $(ME_ETC_PREFIX)/appweb.conf ; \
	cp src/server/sample.conf $(ME_ETC_PREFIX)/sample.conf ; \
	cp src/server/self.crt $(ME_ETC_PREFIX)/self.crt ; \
	cp src/server/self.key $(ME_ETC_PREFIX)/self.key ; \
	echo 'set LOG_DIR "$(ME_LOG_PREFIX)"\nset CACHE_DIR "$(ME_CACHE_PREFIX)"\nDocuments "$(ME_WEB_PREFIX)\nListen 80\n<if SSL_MODULE>\nListenSecure 443\n</if>\n' >$(ME_ETC_PREFIX)/install.conf ; \
	mkdir -p "$(ME_VAPP_PREFIX)/inc" ; \
	cp $(CONFIG)/inc/me.h $(ME_VAPP_PREFIX)/inc/me.h ; \
	mkdir -p "$(ME_INC_PREFIX)/appweb" ; \
	rm -f "$(ME_INC_PREFIX)/appweb/me.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/me.h" "$(ME_INC_PREFIX)/appweb/me.h" ; \
	cp src/paks/osdep/osdep.h $(ME_VAPP_PREFIX)/inc/osdep.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/osdep.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/osdep.h" "$(ME_INC_PREFIX)/appweb/osdep.h" ; \
	cp src/appweb.h $(ME_VAPP_PREFIX)/inc/appweb.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/appweb.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/appweb.h" "$(ME_INC_PREFIX)/appweb/appweb.h" ; \
	cp src/customize.h $(ME_VAPP_PREFIX)/inc/customize.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/customize.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/customize.h" "$(ME_INC_PREFIX)/appweb/customize.h" ; \
	cp src/paks/est/est.h $(ME_VAPP_PREFIX)/inc/est.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/est.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/est.h" "$(ME_INC_PREFIX)/appweb/est.h" ; \
	cp src/paks/http/http.h $(ME_VAPP_PREFIX)/inc/http.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/http.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/http.h" "$(ME_INC_PREFIX)/appweb/http.h" ; \
	cp src/paks/mpr/mpr.h $(ME_VAPP_PREFIX)/inc/mpr.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/mpr.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/mpr.h" "$(ME_INC_PREFIX)/appweb/mpr.h" ; \
	cp src/paks/pcre/pcre.h $(ME_VAPP_PREFIX)/inc/pcre.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/pcre.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/pcre.h" "$(ME_INC_PREFIX)/appweb/pcre.h" ; \
	cp src/paks/sqlite/sqlite3.h $(ME_VAPP_PREFIX)/inc/sqlite3.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/sqlite3.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/sqlite3.h" "$(ME_INC_PREFIX)/appweb/sqlite3.h" ; \
	if [ "$(ME_EXT_ESP)" = 1 ]; then true ; \
	cp src/paks/esp/esp.h $(ME_VAPP_PREFIX)/inc/esp.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/esp.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/esp.h" "$(ME_INC_PREFIX)/appweb/esp.h" ; \
	fi ; \
	if [ "$(ME_EXT_EJS)" = 1 ]; then true ; \
	cp src/paks/ejs/ejs.h $(ME_VAPP_PREFIX)/inc/ejs.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/ejs.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/ejs.h" "$(ME_INC_PREFIX)/appweb/ejs.h" ; \
	cp src/paks/ejs/ejs.slots.h $(ME_VAPP_PREFIX)/inc/ejs.slots.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/ejs.slots.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/ejs.slots.h" "$(ME_INC_PREFIX)/appweb/ejs.slots.h" ; \
	cp src/paks/ejs/ejsByteGoto.h $(ME_VAPP_PREFIX)/inc/ejsByteGoto.h ; \
	rm -f "$(ME_INC_PREFIX)/appweb/ejsByteGoto.h" ; \
	ln -s "$(ME_VAPP_PREFIX)/inc/ejsByteGoto.h" "$(ME_INC_PREFIX)/appweb/ejsByteGoto.h" ; \
	fi ; \
	if [ "$(ME_EXT_EJS)" = 1 ]; then true ; \
	cp $(CONFIG)/bin/ejs.mod $(ME_VAPP_PREFIX)/bin/ejs.mod ; \
	fi ; \
	mkdir -p "$(ME_VAPP_PREFIX)/doc/man1" ; \
	cp doc/man/appman.1 $(ME_VAPP_PREFIX)/doc/man1/appman.1 ; \
	mkdir -p "$(ME_MAN_PREFIX)/man1" ; \
	rm -f "$(ME_MAN_PREFIX)/man1/appman.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/appman.1" "$(ME_MAN_PREFIX)/man1/appman.1" ; \
	cp doc/man/appweb.1 $(ME_VAPP_PREFIX)/doc/man1/appweb.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/appweb.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/appweb.1" "$(ME_MAN_PREFIX)/man1/appweb.1" ; \
	cp doc/man/appwebMonitor.1 $(ME_VAPP_PREFIX)/doc/man1/appwebMonitor.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/appwebMonitor.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/appwebMonitor.1" "$(ME_MAN_PREFIX)/man1/appwebMonitor.1" ; \
	cp doc/man/authpass.1 $(ME_VAPP_PREFIX)/doc/man1/authpass.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/authpass.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/authpass.1" "$(ME_MAN_PREFIX)/man1/authpass.1" ; \
	cp doc/man/esp.1 $(ME_VAPP_PREFIX)/doc/man1/esp.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/esp.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/esp.1" "$(ME_MAN_PREFIX)/man1/esp.1" ; \
	cp doc/man/http.1 $(ME_VAPP_PREFIX)/doc/man1/http.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/http.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/http.1" "$(ME_MAN_PREFIX)/man1/http.1" ; \
	cp doc/man/makerom.1 $(ME_VAPP_PREFIX)/doc/man1/makerom.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/makerom.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/makerom.1" "$(ME_MAN_PREFIX)/man1/makerom.1" ; \
	cp doc/man/manager.1 $(ME_VAPP_PREFIX)/doc/man1/manager.1 ; \
	rm -f "$(ME_MAN_PREFIX)/man1/manager.1" ; \
	ln -s "$(ME_VAPP_PREFIX)/doc/man1/manager.1" "$(ME_MAN_PREFIX)/man1/manager.1" ; \
	mkdir -p "$(ME_ROOT_PREFIX)/Library/LaunchDaemons" ; \
	cp package/macosx/com.embedthis.appweb.plist $(ME_ROOT_PREFIX)/Library/LaunchDaemons/com.embedthis.appweb.plist ; \
	[ `id -u` = 0 ] && chown root:wheel "$(ME_ROOT_PREFIX)/Library/LaunchDaemons/com.embedthis.appweb.plist"; true ; \
	chmod 644 "$(ME_ROOT_PREFIX)/Library/LaunchDaemons/com.embedthis.appweb.plist" ; \
	)

#
#   start
#
DEPS_58 += compile
DEPS_58 += stop

start: $(DEPS_58)
	( \
	cd .; \
	./$(CONFIG)/bin/appman install enable start ; \
	)

#
#   install
#
DEPS_59 += compile
DEPS_59 += stop
DEPS_59 += installBinary
DEPS_59 += start

install: $(DEPS_59)


#
#   uninstall
#
DEPS_60 += build
DEPS_60 += compile
DEPS_60 += stop

uninstall: $(DEPS_60)
	( \
	cd package; \
	rm -f "$(ME_ETC_PREFIX)/appweb.conf" ; \
	rm -f "$(ME_ETC_PREFIX)/esp.conf" ; \
	rm -f "$(ME_ETC_PREFIX)/mine.types" ; \
	rm -f "$(ME_ETC_PREFIX)/install.conf" ; \
	rm -fr "$(ME_INC_PREFIX)/appweb" ; \
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
	)

#
#   genslink
#
genslink: $(DEPS_61)
	( \
	cd src; \
	esp --static --genlink slink.c compile ; \
	)

#
#   run
#
DEPS_62 += compile

run: $(DEPS_62)
	( \
	cd src/server; \
	sudo ../../$(CONFIG)/bin/appweb -v ; \
	)

#
#   test-run
#
DEPS_63 += compile

test-run: $(DEPS_63)
	( \
	cd test; \
	../$(CONFIG)/bin/appweb -v ; \
	)

