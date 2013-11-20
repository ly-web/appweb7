#
#   appweb-vxworks-default.mk -- Makefile to build Embedthis Appweb for vxworks
#

PRODUCT            := appweb
VERSION            := 4.5.0
BUILD_NUMBER       := rc.0
PROFILE            := default
ARCH               := $(shell echo $(WIND_HOST_TYPE) | sed 's/-.*//')
CPU                := $(subst X86,PENTIUM,$(shell echo $(ARCH) | tr a-z A-Z))
OS                 := vxworks
CC                 := cc$(subst x86,pentium,$(ARCH))
LD                 := link
CONFIG             := $(OS)-$(ARCH)-$(PROFILE)
LBIN               := $(CONFIG)/bin

BIT_PACK_CGI       := 1
BIT_PACK_EJSCRIPT  := 0
BIT_PACK_ESP       := 1
BIT_PACK_EST       := 0
BIT_PACK_MATRIXSSL := 0
BIT_PACK_MDB       := 1
BIT_PACK_NANOSSL   := 0
BIT_PACK_OPENSSL   := 0
BIT_PACK_PCRE      := 1
BIT_PACK_PHP       := 0
BIT_PACK_SDB       := 0
BIT_PACK_SQLITE    := 0
BIT_PACK_SSL       := 0

ifeq ($(BIT_PACK_EST),1)
    BIT_PACK_SSL := 1
endif
ifeq ($(BIT_PACK_LIB),1)
    BIT_PACK_COMPILER := 1
endif
ifeq ($(BIT_PACK_MATRIXSSL),1)
    BIT_PACK_SSL := 1
endif
ifeq ($(BIT_PACK_MDB),1)
    BIT_PACK_ESP := 1
endif
ifeq ($(BIT_PACK_NANOSSL),1)
    BIT_PACK_SSL := 1
endif
ifeq ($(BIT_PACK_OPENSSL),1)
    BIT_PACK_SSL := 1
endif
ifeq ($(BIT_PACK_SDB),1)
    BIT_PACK_ESP := 1
    BIT_PACK_SQLITE := 1
endif

BIT_PACK_CGI_PATH         := cgi
BIT_PACK_COMPILER_PATH    := cc$(subst x86,pentium,$(ARCH))
BIT_PACK_DIR_PATH         := dir
BIT_PACK_DOXYGEN_PATH     := doxygen
BIT_PACK_DSI_PATH         := dsi
BIT_PACK_EJSCRIPT_PATH    := ejscript
BIT_PACK_ESP_PATH         := esp
BIT_PACK_EST_PATH         := est
BIT_PACK_LIB_PATH         := ar
BIT_PACK_LINK_PATH        := link
BIT_PACK_MAN_PATH         := man
BIT_PACK_MAN2HTML_PATH    := man2html
BIT_PACK_MATRIXSSL_PATH   := /usr/src/matrixssl
BIT_PACK_MDB_PATH         := mdb
BIT_PACK_NANOSSL_PATH     := /usr/src/nanossl
BIT_PACK_OPENSSL_PATH     := /usr/src/openssl
BIT_PACK_PCRE_PATH        := pcre
BIT_PACK_PHP_PATH         := /usr/src/php
BIT_PACK_PMAKER_PATH      := pmaker
BIT_PACK_SDB_PATH         := sdb
BIT_PACK_SQLITE_PATH      := sqlite
BIT_PACK_SSL_PATH         := ssl
BIT_PACK_UTEST_PATH       := utest
BIT_PACK_VXWORKS_PATH     := $(WIND_BASE)
BIT_PACK_ZIP_PATH         := zip

export WIND_HOME          := $(WIND_BASE)/..
export PATH               := $(WIND_GNU_PATH)/$(WIND_HOST_TYPE)/bin:$(PATH)

CFLAGS             += -fno-builtin -fno-defer-pop -fvolatile -w
DFLAGS             += -DVXWORKS -DRW_MULTI_THREAD -D_GNU_TOOL -DCPU=PENTIUM $(patsubst %,-D%,$(filter BIT_%,$(MAKEFLAGS))) -DBIT_PACK_CGI=$(BIT_PACK_CGI) -DBIT_PACK_EJSCRIPT=$(BIT_PACK_EJSCRIPT) -DBIT_PACK_ESP=$(BIT_PACK_ESP) -DBIT_PACK_EST=$(BIT_PACK_EST) -DBIT_PACK_MATRIXSSL=$(BIT_PACK_MATRIXSSL) -DBIT_PACK_MDB=$(BIT_PACK_MDB) -DBIT_PACK_NANOSSL=$(BIT_PACK_NANOSSL) -DBIT_PACK_OPENSSL=$(BIT_PACK_OPENSSL) -DBIT_PACK_PCRE=$(BIT_PACK_PCRE) -DBIT_PACK_PHP=$(BIT_PACK_PHP) -DBIT_PACK_SDB=$(BIT_PACK_SDB) -DBIT_PACK_SQLITE=$(BIT_PACK_SQLITE) -DBIT_PACK_SSL=$(BIT_PACK_SSL) 
IFLAGS             += "-I$(CONFIG)/inc -I$(WIND_BASE)/target/h -I$(WIND_BASE)/target/h/wrn/coreip"
LDFLAGS            += '-Wl,-r'
LIBPATHS           += -L$(CONFIG)/bin
LIBS               += -lgcc

DEBUG              := debug
CFLAGS-debug       := -g
DFLAGS-debug       := -DBIT_DEBUG
LDFLAGS-debug      := -g
DFLAGS-release     := 
CFLAGS-release     := -O2
LDFLAGS-release    := 
CFLAGS             += $(CFLAGS-$(DEBUG))
DFLAGS             += $(DFLAGS-$(DEBUG))
LDFLAGS            += $(LDFLAGS-$(DEBUG))

BIT_ROOT_PREFIX    := deploy
BIT_BASE_PREFIX    := $(BIT_ROOT_PREFIX)
BIT_DATA_PREFIX    := $(BIT_VAPP_PREFIX)
BIT_STATE_PREFIX   := $(BIT_VAPP_PREFIX)
BIT_BIN_PREFIX     := $(BIT_VAPP_PREFIX)
BIT_INC_PREFIX     := $(BIT_VAPP_PREFIX)/inc
BIT_LIB_PREFIX     := $(BIT_VAPP_PREFIX)
BIT_MAN_PREFIX     := $(BIT_VAPP_PREFIX)
BIT_SBIN_PREFIX    := $(BIT_VAPP_PREFIX)
BIT_ETC_PREFIX     := $(BIT_VAPP_PREFIX)
BIT_WEB_PREFIX     := $(BIT_VAPP_PREFIX)/web
BIT_LOG_PREFIX     := $(BIT_VAPP_PREFIX)
BIT_SPOOL_PREFIX   := $(BIT_VAPP_PREFIX)
BIT_CACHE_PREFIX   := $(BIT_VAPP_PREFIX)
BIT_APP_PREFIX     := $(BIT_BASE_PREFIX)
BIT_VAPP_PREFIX    := $(BIT_APP_PREFIX)
BIT_SRC_PREFIX     := $(BIT_ROOT_PREFIX)/usr/src/$(PRODUCT)-$(VERSION)


TARGETS            += $(CONFIG)/bin/libmpr.out
TARGETS            += $(CONFIG)/bin/libmprssl.out
TARGETS            += $(CONFIG)/bin/appman.out
TARGETS            += $(CONFIG)/bin/makerom.out
TARGETS            += $(CONFIG)/bin/ca.crt
ifeq ($(BIT_PACK_PCRE),1)
TARGETS            += $(CONFIG)/bin/libpcre.out
endif
TARGETS            += $(CONFIG)/bin/libhttp.out
TARGETS            += $(CONFIG)/bin/http.out
ifeq ($(BIT_PACK_SQLITE),1)
TARGETS            += $(CONFIG)/bin/libsql.out
endif
ifeq ($(BIT_PACK_SQLITE),1)
TARGETS            += $(CONFIG)/bin/sqlite.out
endif
TARGETS            += $(CONFIG)/bin/libappweb.out
ifeq ($(BIT_PACK_ESP),1)
TARGETS            += $(CONFIG)/bin/libmod_esp.out
endif
ifeq ($(BIT_PACK_ESP),1)
TARGETS            += $(CONFIG)/bin/esp.out
endif
ifeq ($(BIT_PACK_ESP),1)
TARGETS            += $(CONFIG)/bin/esp.conf
endif
ifeq ($(BIT_PACK_ESP),1)
TARGETS            += src/server/esp.conf
endif
ifeq ($(BIT_PACK_ESP),1)
TARGETS            += $(CONFIG)/esp
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
TARGETS            += $(CONFIG)/bin/libejs.out
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
TARGETS            += $(CONFIG)/bin/ejs.out
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
TARGETS            += $(CONFIG)/bin/ejsc.out
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
TARGETS            += $(CONFIG)/bin/ejs.mod
endif
ifeq ($(BIT_PACK_CGI),1)
TARGETS            += $(CONFIG)/bin/libmod_cgi.out
endif
ifeq ($(BIT_PACK_EJSCRIPT),1)
TARGETS            += $(CONFIG)/bin/libmod_ejs.out
endif
ifeq ($(BIT_PACK_PHP),1)
TARGETS            += $(CONFIG)/bin/libmod_php.out
endif
ifeq ($(BIT_PACK_SSL),1)
TARGETS            += $(CONFIG)/bin/libmod_ssl.out
endif
TARGETS            += $(CONFIG)/bin/authpass.out
ifeq ($(BIT_PACK_CGI),1)
TARGETS            += $(CONFIG)/bin/cgiProgram.out
endif
TARGETS            += src/server/slink.c
TARGETS            += $(CONFIG)/bin/libslink.out
TARGETS            += $(CONFIG)/bin/appweb.out
TARGETS            += src/server/cache
TARGETS            += $(CONFIG)/bin/testAppweb.out
ifeq ($(BIT_PACK_CGI),1)
TARGETS            += test/cgi-bin/testScript
endif
ifeq ($(BIT_PACK_CGI),1)
TARGETS            += test/web/caching/cache.cgi
endif
ifeq ($(BIT_PACK_CGI),1)
TARGETS            += test/web/auth/basic/basic.cgi
endif
ifeq ($(BIT_PACK_CGI),1)
TARGETS            += test/cgi-bin/cgiProgram.out
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
	@if [ "$(BIT_APP_PREFIX)" = "" ] ; then echo WARNING: BIT_APP_PREFIX not set ; exit 255 ; fi
	@if [ "$(WIND_BASE)" = "" ] ; then echo WARNING: WIND_BASE not set. Run wrenv.sh. ; exit 255 ; fi
	@if [ "$(WIND_HOST_TYPE)" = "" ] ; then echo WARNING: WIND_HOST_TYPE not set. Run wrenv.sh. ; exit 255 ; fi
	@if [ "$(WIND_GNU_PATH)" = "" ] ; then echo WARNING: WIND_GNU_PATH not set. Run wrenv.sh. ; exit 255 ; fi
	@[ ! -x $(CONFIG)/bin ] && mkdir -p $(CONFIG)/bin; true
	@[ ! -x $(CONFIG)/inc ] && mkdir -p $(CONFIG)/inc; true
	@[ ! -x $(CONFIG)/obj ] && mkdir -p $(CONFIG)/obj; true
	@[ ! -f $(CONFIG)/inc/bitos.h ] && cp src/bitos.h $(CONFIG)/inc/bitos.h ; true
	@if ! diff $(CONFIG)/inc/bitos.h src/bitos.h >/dev/null ; then\
		cp src/bitos.h $(CONFIG)/inc/bitos.h  ; \
	fi; true
	@[ ! -f $(CONFIG)/inc/bit.h ] && cp projects/appweb-vxworks-default-bit.h $(CONFIG)/inc/bit.h ; true
	@if ! diff $(CONFIG)/inc/bit.h projects/appweb-vxworks-default-bit.h >/dev/null ; then\
		cp projects/appweb-vxworks-default-bit.h $(CONFIG)/inc/bit.h  ; \
	fi; true
	@if [ -f "$(CONFIG)/.makeflags" ] ; then \
		if [ "$(MAKEFLAGS)" != " ` cat $(CONFIG)/.makeflags`" ] ; then \
			echo "   [Warning] Make flags have changed since the last build: "`cat $(CONFIG)/.makeflags`"" ; \
		fi ; \
	fi
	@echo $(MAKEFLAGS) >$(CONFIG)/.makeflags

clean:
	rm -f "$(CONFIG)/bin/libmpr.out"
	rm -f "$(CONFIG)/bin/libmprssl.out"
	rm -f "$(CONFIG)/bin/appman.out"
	rm -f "$(CONFIG)/bin/makerom.out"
	rm -f "$(CONFIG)/bin/libest.out"
	rm -f "$(CONFIG)/bin/ca.crt"
	rm -f "$(CONFIG)/bin/libpcre.out"
	rm -f "$(CONFIG)/bin/libhttp.out"
	rm -f "$(CONFIG)/bin/http.out"
	rm -f "$(CONFIG)/bin/libsql.out"
	rm -f "$(CONFIG)/bin/sqlite.out"
	rm -f "$(CONFIG)/bin/libappweb.out"
	rm -f "$(CONFIG)/bin/libmod_esp.out"
	rm -f "$(CONFIG)/bin/esp.out"
	rm -f "$(CONFIG)/bin/esp.conf"
	rm -f "src/server/esp.conf"
	rm -fr "$(CONFIG)/esp"
	rm -f "$(CONFIG)/bin/libejs.out"
	rm -f "$(CONFIG)/bin/ejs.out"
	rm -f "$(CONFIG)/bin/ejsc.out"
	rm -f "$(CONFIG)/bin/libmod_cgi.out"
	rm -f "$(CONFIG)/bin/libmod_ejs.out"
	rm -f "$(CONFIG)/bin/libmod_php.out"
	rm -f "$(CONFIG)/bin/libmod_ssl.out"
	rm -f "$(CONFIG)/bin/authpass.out"
	rm -f "$(CONFIG)/bin/cgiProgram.out"
	rm -f "$(CONFIG)/bin/libslink.out"
	rm -f "$(CONFIG)/bin/appweb.out"
	rm -f "$(CONFIG)/bin/testAppweb.out"
	rm -f "$(CONFIG)/obj/mprLib.o"
	rm -f "$(CONFIG)/obj/mprSsl.o"
	rm -f "$(CONFIG)/obj/manager.o"
	rm -f "$(CONFIG)/obj/makerom.o"
	rm -f "$(CONFIG)/obj/estLib.o"
	rm -f "$(CONFIG)/obj/pcre.o"
	rm -f "$(CONFIG)/obj/httpLib.o"
	rm -f "$(CONFIG)/obj/http.o"
	rm -f "$(CONFIG)/obj/sqlite3.o"
	rm -f "$(CONFIG)/obj/sqlite.o"
	rm -f "$(CONFIG)/obj/config.o"
	rm -f "$(CONFIG)/obj/convenience.o"
	rm -f "$(CONFIG)/obj/dirHandler.o"
	rm -f "$(CONFIG)/obj/fileHandler.o"
	rm -f "$(CONFIG)/obj/log.o"
	rm -f "$(CONFIG)/obj/server.o"
	rm -f "$(CONFIG)/obj/edi.o"
	rm -f "$(CONFIG)/obj/espAbbrev.o"
	rm -f "$(CONFIG)/obj/espDeprecated.o"
	rm -f "$(CONFIG)/obj/espFramework.o"
	rm -f "$(CONFIG)/obj/espHandler.o"
	rm -f "$(CONFIG)/obj/espHtml.o"
	rm -f "$(CONFIG)/obj/espTemplate.o"
	rm -f "$(CONFIG)/obj/mdb.o"
	rm -f "$(CONFIG)/obj/sdb.o"
	rm -f "$(CONFIG)/obj/esp.o"
	rm -f "$(CONFIG)/obj/ejsLib.o"
	rm -f "$(CONFIG)/obj/ejs.o"
	rm -f "$(CONFIG)/obj/ejsc.o"
	rm -f "$(CONFIG)/obj/cgiHandler.o"
	rm -f "$(CONFIG)/obj/ejsHandler.o"
	rm -f "$(CONFIG)/obj/phpHandler.o"
	rm -f "$(CONFIG)/obj/sslModule.o"
	rm -f "$(CONFIG)/obj/authpass.o"
	rm -f "$(CONFIG)/obj/cgiProgram.o"
	rm -f "$(CONFIG)/obj/slink.o"
	rm -f "$(CONFIG)/obj/appweb.o"
	rm -f "$(CONFIG)/obj/testAppweb.o"
	rm -f "$(CONFIG)/obj/testHttp.o"

clobber: clean
	rm -fr ./$(CONFIG)



#
#   version
#
version: $(DEPS_1)
	@echo 4.5.0-rc.0

#
#   mpr.h
#
$(CONFIG)/inc/mpr.h: $(DEPS_2)
	@echo '      [Copy] $(CONFIG)/inc/mpr.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/deps/mpr/mpr.h $(CONFIG)/inc/mpr.h

#
#   bit.h
#
$(CONFIG)/inc/bit.h: $(DEPS_3)
	@echo '      [Copy] $(CONFIG)/inc/bit.h'

#
#   bitos.h
#
DEPS_4 += $(CONFIG)/inc/bit.h

$(CONFIG)/inc/bitos.h: $(DEPS_4)
	@echo '      [Copy] $(CONFIG)/inc/bitos.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/bitos.h $(CONFIG)/inc/bitos.h

#
#   mprLib.o
#
DEPS_5 += $(CONFIG)/inc/bit.h
DEPS_5 += $(CONFIG)/inc/mpr.h
DEPS_5 += $(CONFIG)/inc/bitos.h

$(CONFIG)/obj/mprLib.o: \
    src/deps/mpr/mprLib.c $(DEPS_5)
	@echo '   [Compile] $(CONFIG)/obj/mprLib.o'
	$(CC) -c -o $(CONFIG)/obj/mprLib.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/deps/mpr/mprLib.c

#
#   libmpr
#
DEPS_6 += $(CONFIG)/inc/mpr.h
DEPS_6 += $(CONFIG)/inc/bit.h
DEPS_6 += $(CONFIG)/inc/bitos.h
DEPS_6 += $(CONFIG)/obj/mprLib.o

$(CONFIG)/bin/libmpr.out: $(DEPS_6)
	@echo '      [Link] $(CONFIG)/bin/libmpr.out'
	$(CC) -r -o $(CONFIG)/bin/libmpr.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/mprLib.o" $(LIBS) 

#
#   est.h
#
$(CONFIG)/inc/est.h: $(DEPS_7)
	@echo '      [Copy] $(CONFIG)/inc/est.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/deps/est/est.h $(CONFIG)/inc/est.h

#
#   estLib.o
#
DEPS_8 += $(CONFIG)/inc/bit.h
DEPS_8 += $(CONFIG)/inc/est.h
DEPS_8 += $(CONFIG)/inc/bitos.h

$(CONFIG)/obj/estLib.o: \
    src/deps/est/estLib.c $(DEPS_8)
	@echo '   [Compile] $(CONFIG)/obj/estLib.o'
	$(CC) -c -o $(CONFIG)/obj/estLib.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/deps/est/estLib.c

ifeq ($(BIT_PACK_EST),1)
#
#   libest
#
DEPS_9 += $(CONFIG)/inc/est.h
DEPS_9 += $(CONFIG)/inc/bit.h
DEPS_9 += $(CONFIG)/inc/bitos.h
DEPS_9 += $(CONFIG)/obj/estLib.o

$(CONFIG)/bin/libest.out: $(DEPS_9)
	@echo '      [Link] $(CONFIG)/bin/libest.out'
	$(CC) -r -o $(CONFIG)/bin/libest.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/estLib.o" $(LIBS) 
endif

#
#   mprSsl.o
#
DEPS_10 += $(CONFIG)/inc/bit.h
DEPS_10 += $(CONFIG)/inc/mpr.h
DEPS_10 += $(CONFIG)/inc/est.h

$(CONFIG)/obj/mprSsl.o: \
    src/deps/mpr/mprSsl.c $(DEPS_10)
	@echo '   [Compile] $(CONFIG)/obj/mprSsl.o'
	$(CC) -c -o $(CONFIG)/obj/mprSsl.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(BIT_PACK_MATRIXSSL_PATH)" "-I$(BIT_PACK_MATRIXSSL_PATH)/matrixssl" "-I$(BIT_PACK_NANOSSL_PATH)/src" "-I$(BIT_PACK_OPENSSL_PATH)/include" src/deps/mpr/mprSsl.c

#
#   libmprssl
#
DEPS_11 += $(CONFIG)/inc/mpr.h
DEPS_11 += $(CONFIG)/inc/bit.h
DEPS_11 += $(CONFIG)/inc/bitos.h
DEPS_11 += $(CONFIG)/obj/mprLib.o
DEPS_11 += $(CONFIG)/bin/libmpr.out
DEPS_11 += $(CONFIG)/inc/est.h
DEPS_11 += $(CONFIG)/obj/estLib.o
ifeq ($(BIT_PACK_EST),1)
    DEPS_11 += $(CONFIG)/bin/libest.out
endif
DEPS_11 += $(CONFIG)/obj/mprSsl.o

ifeq ($(BIT_PACK_MATRIXSSL),1)
    LIBS_11 += -lmatrixssl
    LIBPATHS_11 += -L$(BIT_PACK_MATRIXSSL_PATH)
endif
ifeq ($(BIT_PACK_NANOSSL),1)
    LIBS_11 += -lssls
    LIBPATHS_11 += -L$(BIT_PACK_NANOSSL_PATH)/bin
endif
ifeq ($(BIT_PACK_OPENSSL),1)
    LIBS_11 += -lssl
    LIBPATHS_11 += -L$(BIT_PACK_OPENSSL_PATH)
endif
ifeq ($(BIT_PACK_OPENSSL),1)
    LIBS_11 += -lcrypto
    LIBPATHS_11 += -L$(BIT_PACK_OPENSSL_PATH)
endif

$(CONFIG)/bin/libmprssl.out: $(DEPS_11)
	@echo '      [Link] $(CONFIG)/bin/libmprssl.out'
	$(CC) -r -o $(CONFIG)/bin/libmprssl.out $(LDFLAGS) $(LIBPATHS)    "$(CONFIG)/obj/mprSsl.o" $(LIBPATHS_11) $(LIBS_11) $(LIBS_11) $(LIBS) 

#
#   manager.o
#
DEPS_12 += $(CONFIG)/inc/bit.h
DEPS_12 += $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/manager.o: \
    src/deps/mpr/manager.c $(DEPS_12)
	@echo '   [Compile] $(CONFIG)/obj/manager.o'
	$(CC) -c -o $(CONFIG)/obj/manager.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/deps/mpr/manager.c

#
#   manager
#
DEPS_13 += $(CONFIG)/inc/mpr.h
DEPS_13 += $(CONFIG)/inc/bit.h
DEPS_13 += $(CONFIG)/inc/bitos.h
DEPS_13 += $(CONFIG)/obj/mprLib.o
DEPS_13 += $(CONFIG)/bin/libmpr.out
DEPS_13 += $(CONFIG)/obj/manager.o

$(CONFIG)/bin/appman.out: $(DEPS_13)
	@echo '      [Link] $(CONFIG)/bin/appman.out'
	$(CC) -o $(CONFIG)/bin/appman.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/manager.o" $(LIBS) -Wl,-r 

#
#   makerom.o
#
DEPS_14 += $(CONFIG)/inc/bit.h
DEPS_14 += $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/makerom.o: \
    src/deps/mpr/makerom.c $(DEPS_14)
	@echo '   [Compile] $(CONFIG)/obj/makerom.o'
	$(CC) -c -o $(CONFIG)/obj/makerom.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/deps/mpr/makerom.c

#
#   makerom
#
DEPS_15 += $(CONFIG)/inc/mpr.h
DEPS_15 += $(CONFIG)/inc/bit.h
DEPS_15 += $(CONFIG)/inc/bitos.h
DEPS_15 += $(CONFIG)/obj/mprLib.o
DEPS_15 += $(CONFIG)/bin/libmpr.out
DEPS_15 += $(CONFIG)/obj/makerom.o

$(CONFIG)/bin/makerom.out: $(DEPS_15)
	@echo '      [Link] $(CONFIG)/bin/makerom.out'
	$(CC) -o $(CONFIG)/bin/makerom.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/makerom.o" $(LIBS) -Wl,-r 

#
#   ca-crt
#
DEPS_16 += src/deps/est/ca.crt

$(CONFIG)/bin/ca.crt: $(DEPS_16)
	@echo '      [Copy] $(CONFIG)/bin/ca.crt'
	mkdir -p "$(CONFIG)/bin"
	cp src/deps/est/ca.crt $(CONFIG)/bin/ca.crt

#
#   pcre.h
#
$(CONFIG)/inc/pcre.h: $(DEPS_17)
	@echo '      [Copy] $(CONFIG)/inc/pcre.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/deps/pcre/pcre.h $(CONFIG)/inc/pcre.h

#
#   pcre.o
#
DEPS_18 += $(CONFIG)/inc/bit.h
DEPS_18 += $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/pcre.o: \
    src/deps/pcre/pcre.c $(DEPS_18)
	@echo '   [Compile] $(CONFIG)/obj/pcre.o'
	$(CC) -c -o $(CONFIG)/obj/pcre.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/deps/pcre/pcre.c

ifeq ($(BIT_PACK_PCRE),1)
#
#   libpcre
#
DEPS_19 += $(CONFIG)/inc/pcre.h
DEPS_19 += $(CONFIG)/inc/bit.h
DEPS_19 += $(CONFIG)/obj/pcre.o

$(CONFIG)/bin/libpcre.out: $(DEPS_19)
	@echo '      [Link] $(CONFIG)/bin/libpcre.out'
	$(CC) -r -o $(CONFIG)/bin/libpcre.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/pcre.o" $(LIBS) 
endif

#
#   http.h
#
$(CONFIG)/inc/http.h: $(DEPS_20)
	@echo '      [Copy] $(CONFIG)/inc/http.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/deps/http/http.h $(CONFIG)/inc/http.h

#
#   httpLib.o
#
DEPS_21 += $(CONFIG)/inc/bit.h
DEPS_21 += $(CONFIG)/inc/http.h
DEPS_21 += $(CONFIG)/inc/mpr.h

$(CONFIG)/obj/httpLib.o: \
    src/deps/http/httpLib.c $(DEPS_21)
	@echo '   [Compile] $(CONFIG)/obj/httpLib.o'
	$(CC) -c -o $(CONFIG)/obj/httpLib.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/deps/http/httpLib.c

#
#   libhttp
#
DEPS_22 += $(CONFIG)/inc/mpr.h
DEPS_22 += $(CONFIG)/inc/bit.h
DEPS_22 += $(CONFIG)/inc/bitos.h
DEPS_22 += $(CONFIG)/obj/mprLib.o
DEPS_22 += $(CONFIG)/bin/libmpr.out
DEPS_22 += $(CONFIG)/inc/pcre.h
DEPS_22 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_22 += $(CONFIG)/bin/libpcre.out
endif
DEPS_22 += $(CONFIG)/inc/http.h
DEPS_22 += $(CONFIG)/obj/httpLib.o

$(CONFIG)/bin/libhttp.out: $(DEPS_22)
	@echo '      [Link] $(CONFIG)/bin/libhttp.out'
	$(CC) -r -o $(CONFIG)/bin/libhttp.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/httpLib.o" $(LIBS) 

#
#   http.o
#
DEPS_23 += $(CONFIG)/inc/bit.h
DEPS_23 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/http.o: \
    src/deps/http/http.c $(DEPS_23)
	@echo '   [Compile] $(CONFIG)/obj/http.o'
	$(CC) -c -o $(CONFIG)/obj/http.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/deps/http/http.c

#
#   http
#
DEPS_24 += $(CONFIG)/inc/mpr.h
DEPS_24 += $(CONFIG)/inc/bit.h
DEPS_24 += $(CONFIG)/inc/bitos.h
DEPS_24 += $(CONFIG)/obj/mprLib.o
DEPS_24 += $(CONFIG)/bin/libmpr.out
DEPS_24 += $(CONFIG)/inc/pcre.h
DEPS_24 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_24 += $(CONFIG)/bin/libpcre.out
endif
DEPS_24 += $(CONFIG)/inc/http.h
DEPS_24 += $(CONFIG)/obj/httpLib.o
DEPS_24 += $(CONFIG)/bin/libhttp.out
DEPS_24 += $(CONFIG)/obj/http.o

$(CONFIG)/bin/http.out: $(DEPS_24)
	@echo '      [Link] $(CONFIG)/bin/http.out'
	$(CC) -o $(CONFIG)/bin/http.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/http.o" $(LIBS) -Wl,-r 

#
#   sqlite3.h
#
$(CONFIG)/inc/sqlite3.h: $(DEPS_25)
	@echo '      [Copy] $(CONFIG)/inc/sqlite3.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/deps/sqlite/sqlite3.h $(CONFIG)/inc/sqlite3.h

#
#   sqlite3.o
#
DEPS_26 += $(CONFIG)/inc/bit.h
DEPS_26 += $(CONFIG)/inc/sqlite3.h

$(CONFIG)/obj/sqlite3.o: \
    src/deps/sqlite/sqlite3.c $(DEPS_26)
	@echo '   [Compile] $(CONFIG)/obj/sqlite3.o'
	$(CC) -c -o $(CONFIG)/obj/sqlite3.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/deps/sqlite/sqlite3.c

ifeq ($(BIT_PACK_SQLITE),1)
#
#   libsql
#
DEPS_27 += $(CONFIG)/inc/sqlite3.h
DEPS_27 += $(CONFIG)/inc/bit.h
DEPS_27 += $(CONFIG)/obj/sqlite3.o

$(CONFIG)/bin/libsql.out: $(DEPS_27)
	@echo '      [Link] $(CONFIG)/bin/libsql.out'
	$(CC) -r -o $(CONFIG)/bin/libsql.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/sqlite3.o" $(LIBS) 
endif

#
#   sqlite.o
#
DEPS_28 += $(CONFIG)/inc/bit.h
DEPS_28 += $(CONFIG)/inc/sqlite3.h

$(CONFIG)/obj/sqlite.o: \
    src/deps/sqlite/sqlite.c $(DEPS_28)
	@echo '   [Compile] $(CONFIG)/obj/sqlite.o'
	$(CC) -c -o $(CONFIG)/obj/sqlite.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/deps/sqlite/sqlite.c

ifeq ($(BIT_PACK_SQLITE),1)
#
#   sqliteshell
#
DEPS_29 += $(CONFIG)/inc/sqlite3.h
DEPS_29 += $(CONFIG)/inc/bit.h
DEPS_29 += $(CONFIG)/obj/sqlite3.o
DEPS_29 += $(CONFIG)/bin/libsql.out
DEPS_29 += $(CONFIG)/obj/sqlite.o

$(CONFIG)/bin/sqlite.out: $(DEPS_29)
	@echo '      [Link] $(CONFIG)/bin/sqlite.out'
	$(CC) -o $(CONFIG)/bin/sqlite.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/sqlite.o" $(LIBS) -Wl,-r 
endif

#
#   appweb.h
#
$(CONFIG)/inc/appweb.h: $(DEPS_30)
	@echo '      [Copy] $(CONFIG)/inc/appweb.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/appweb.h $(CONFIG)/inc/appweb.h

#
#   customize.h
#
$(CONFIG)/inc/customize.h: $(DEPS_31)
	@echo '      [Copy] $(CONFIG)/inc/customize.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/customize.h $(CONFIG)/inc/customize.h

#
#   config.o
#
DEPS_32 += $(CONFIG)/inc/bit.h
DEPS_32 += $(CONFIG)/inc/appweb.h
DEPS_32 += $(CONFIG)/inc/pcre.h
DEPS_32 += $(CONFIG)/inc/mpr.h
DEPS_32 += $(CONFIG)/inc/http.h
DEPS_32 += $(CONFIG)/inc/customize.h

$(CONFIG)/obj/config.o: \
    src/config.c $(DEPS_32)
	@echo '   [Compile] $(CONFIG)/obj/config.o'
	$(CC) -c -o $(CONFIG)/obj/config.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/config.c

#
#   convenience.o
#
DEPS_33 += $(CONFIG)/inc/bit.h
DEPS_33 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/convenience.o: \
    src/convenience.c $(DEPS_33)
	@echo '   [Compile] $(CONFIG)/obj/convenience.o'
	$(CC) -c -o $(CONFIG)/obj/convenience.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/convenience.c

#
#   dirHandler.o
#
DEPS_34 += $(CONFIG)/inc/bit.h
DEPS_34 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/dirHandler.o: \
    src/dirHandler.c $(DEPS_34)
	@echo '   [Compile] $(CONFIG)/obj/dirHandler.o'
	$(CC) -c -o $(CONFIG)/obj/dirHandler.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/dirHandler.c

#
#   fileHandler.o
#
DEPS_35 += $(CONFIG)/inc/bit.h
DEPS_35 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/fileHandler.o: \
    src/fileHandler.c $(DEPS_35)
	@echo '   [Compile] $(CONFIG)/obj/fileHandler.o'
	$(CC) -c -o $(CONFIG)/obj/fileHandler.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/fileHandler.c

#
#   log.o
#
DEPS_36 += $(CONFIG)/inc/bit.h
DEPS_36 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/log.o: \
    src/log.c $(DEPS_36)
	@echo '   [Compile] $(CONFIG)/obj/log.o'
	$(CC) -c -o $(CONFIG)/obj/log.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/log.c

#
#   server.o
#
DEPS_37 += $(CONFIG)/inc/bit.h
DEPS_37 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/server.o: \
    src/server.c $(DEPS_37)
	@echo '   [Compile] $(CONFIG)/obj/server.o'
	$(CC) -c -o $(CONFIG)/obj/server.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/server.c

#
#   libappweb
#
DEPS_38 += $(CONFIG)/inc/mpr.h
DEPS_38 += $(CONFIG)/inc/bit.h
DEPS_38 += $(CONFIG)/inc/bitos.h
DEPS_38 += $(CONFIG)/obj/mprLib.o
DEPS_38 += $(CONFIG)/bin/libmpr.out
DEPS_38 += $(CONFIG)/inc/pcre.h
DEPS_38 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_38 += $(CONFIG)/bin/libpcre.out
endif
DEPS_38 += $(CONFIG)/inc/http.h
DEPS_38 += $(CONFIG)/obj/httpLib.o
DEPS_38 += $(CONFIG)/bin/libhttp.out
DEPS_38 += $(CONFIG)/inc/appweb.h
DEPS_38 += $(CONFIG)/inc/customize.h
DEPS_38 += $(CONFIG)/obj/config.o
DEPS_38 += $(CONFIG)/obj/convenience.o
DEPS_38 += $(CONFIG)/obj/dirHandler.o
DEPS_38 += $(CONFIG)/obj/fileHandler.o
DEPS_38 += $(CONFIG)/obj/log.o
DEPS_38 += $(CONFIG)/obj/server.o

$(CONFIG)/bin/libappweb.out: $(DEPS_38)
	@echo '      [Link] $(CONFIG)/bin/libappweb.out'
	$(CC) -r -o $(CONFIG)/bin/libappweb.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/config.o" "$(CONFIG)/obj/convenience.o" "$(CONFIG)/obj/dirHandler.o" "$(CONFIG)/obj/fileHandler.o" "$(CONFIG)/obj/log.o" "$(CONFIG)/obj/server.o" $(LIBS) 

#
#   edi.h
#
$(CONFIG)/inc/edi.h: $(DEPS_39)
	@echo '      [Copy] $(CONFIG)/inc/edi.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/esp/edi.h $(CONFIG)/inc/edi.h

#
#   esp.h
#
$(CONFIG)/inc/esp.h: $(DEPS_40)
	@echo '      [Copy] $(CONFIG)/inc/esp.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/esp/esp.h $(CONFIG)/inc/esp.h

#
#   mdb.h
#
$(CONFIG)/inc/mdb.h: $(DEPS_41)
	@echo '      [Copy] $(CONFIG)/inc/mdb.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/esp/mdb.h $(CONFIG)/inc/mdb.h

#
#   edi.o
#
DEPS_42 += $(CONFIG)/inc/bit.h
DEPS_42 += $(CONFIG)/inc/edi.h
DEPS_42 += $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/edi.o: \
    src/esp/edi.c $(DEPS_42)
	@echo '   [Compile] $(CONFIG)/obj/edi.o'
	$(CC) -c -o $(CONFIG)/obj/edi.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/esp/edi.c

#
#   espAbbrev.o
#
DEPS_43 += $(CONFIG)/inc/bit.h
DEPS_43 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espAbbrev.o: \
    src/esp/espAbbrev.c $(DEPS_43)
	@echo '   [Compile] $(CONFIG)/obj/espAbbrev.o'
	$(CC) -c -o $(CONFIG)/obj/espAbbrev.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/esp/espAbbrev.c

#
#   espDeprecated.o
#
DEPS_44 += $(CONFIG)/inc/bit.h
DEPS_44 += $(CONFIG)/inc/esp.h
DEPS_44 += $(CONFIG)/inc/edi.h

$(CONFIG)/obj/espDeprecated.o: \
    src/esp/espDeprecated.c $(DEPS_44)
	@echo '   [Compile] $(CONFIG)/obj/espDeprecated.o'
	$(CC) -c -o $(CONFIG)/obj/espDeprecated.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/esp/espDeprecated.c

#
#   espFramework.o
#
DEPS_45 += $(CONFIG)/inc/bit.h
DEPS_45 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espFramework.o: \
    src/esp/espFramework.c $(DEPS_45)
	@echo '   [Compile] $(CONFIG)/obj/espFramework.o'
	$(CC) -c -o $(CONFIG)/obj/espFramework.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/esp/espFramework.c

#
#   espHandler.o
#
DEPS_46 += $(CONFIG)/inc/bit.h
DEPS_46 += $(CONFIG)/inc/appweb.h
DEPS_46 += $(CONFIG)/inc/esp.h
DEPS_46 += $(CONFIG)/inc/edi.h

$(CONFIG)/obj/espHandler.o: \
    src/esp/espHandler.c $(DEPS_46)
	@echo '   [Compile] $(CONFIG)/obj/espHandler.o'
	$(CC) -c -o $(CONFIG)/obj/espHandler.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/esp/espHandler.c

#
#   espHtml.o
#
DEPS_47 += $(CONFIG)/inc/bit.h
DEPS_47 += $(CONFIG)/inc/esp.h
DEPS_47 += $(CONFIG)/inc/edi.h

$(CONFIG)/obj/espHtml.o: \
    src/esp/espHtml.c $(DEPS_47)
	@echo '   [Compile] $(CONFIG)/obj/espHtml.o'
	$(CC) -c -o $(CONFIG)/obj/espHtml.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/esp/espHtml.c

#
#   espTemplate.o
#
DEPS_48 += $(CONFIG)/inc/bit.h
DEPS_48 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/espTemplate.o: \
    src/esp/espTemplate.c $(DEPS_48)
	@echo '   [Compile] $(CONFIG)/obj/espTemplate.o'
	$(CC) -c -o $(CONFIG)/obj/espTemplate.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/esp/espTemplate.c

#
#   mdb.o
#
DEPS_49 += $(CONFIG)/inc/bit.h
DEPS_49 += $(CONFIG)/inc/appweb.h
DEPS_49 += $(CONFIG)/inc/edi.h
DEPS_49 += $(CONFIG)/inc/mdb.h
DEPS_49 += $(CONFIG)/inc/pcre.h

$(CONFIG)/obj/mdb.o: \
    src/esp/mdb.c $(DEPS_49)
	@echo '   [Compile] $(CONFIG)/obj/mdb.o'
	$(CC) -c -o $(CONFIG)/obj/mdb.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/esp/mdb.c

#
#   sdb.o
#
DEPS_50 += $(CONFIG)/inc/bit.h
DEPS_50 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/sdb.o: \
    src/esp/sdb.c $(DEPS_50)
	@echo '   [Compile] $(CONFIG)/obj/sdb.o'
	$(CC) -c -o $(CONFIG)/obj/sdb.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/esp/sdb.c

ifeq ($(BIT_PACK_ESP),1)
#
#   libmod_esp
#
DEPS_51 += $(CONFIG)/inc/mpr.h
DEPS_51 += $(CONFIG)/inc/bit.h
DEPS_51 += $(CONFIG)/inc/bitos.h
DEPS_51 += $(CONFIG)/obj/mprLib.o
DEPS_51 += $(CONFIG)/bin/libmpr.out
DEPS_51 += $(CONFIG)/inc/pcre.h
DEPS_51 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_51 += $(CONFIG)/bin/libpcre.out
endif
DEPS_51 += $(CONFIG)/inc/http.h
DEPS_51 += $(CONFIG)/obj/httpLib.o
DEPS_51 += $(CONFIG)/bin/libhttp.out
DEPS_51 += $(CONFIG)/inc/appweb.h
DEPS_51 += $(CONFIG)/inc/customize.h
DEPS_51 += $(CONFIG)/obj/config.o
DEPS_51 += $(CONFIG)/obj/convenience.o
DEPS_51 += $(CONFIG)/obj/dirHandler.o
DEPS_51 += $(CONFIG)/obj/fileHandler.o
DEPS_51 += $(CONFIG)/obj/log.o
DEPS_51 += $(CONFIG)/obj/server.o
DEPS_51 += $(CONFIG)/bin/libappweb.out
DEPS_51 += $(CONFIG)/inc/edi.h
DEPS_51 += $(CONFIG)/inc/esp.h
DEPS_51 += $(CONFIG)/inc/mdb.h
DEPS_51 += $(CONFIG)/obj/edi.o
DEPS_51 += $(CONFIG)/obj/espAbbrev.o
DEPS_51 += $(CONFIG)/obj/espDeprecated.o
DEPS_51 += $(CONFIG)/obj/espFramework.o
DEPS_51 += $(CONFIG)/obj/espHandler.o
DEPS_51 += $(CONFIG)/obj/espHtml.o
DEPS_51 += $(CONFIG)/obj/espTemplate.o
DEPS_51 += $(CONFIG)/obj/mdb.o
DEPS_51 += $(CONFIG)/obj/sdb.o

$(CONFIG)/bin/libmod_esp.out: $(DEPS_51)
	@echo '      [Link] $(CONFIG)/bin/libmod_esp.out'
	$(CC) -r -o $(CONFIG)/bin/libmod_esp.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/edi.o" "$(CONFIG)/obj/espAbbrev.o" "$(CONFIG)/obj/espDeprecated.o" "$(CONFIG)/obj/espFramework.o" "$(CONFIG)/obj/espHandler.o" "$(CONFIG)/obj/espHtml.o" "$(CONFIG)/obj/espTemplate.o" "$(CONFIG)/obj/mdb.o" "$(CONFIG)/obj/sdb.o" $(LIBS) 
endif

#
#   esp.o
#
DEPS_52 += $(CONFIG)/inc/bit.h
DEPS_52 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/esp.o: \
    src/esp/esp.c $(DEPS_52)
	@echo '   [Compile] $(CONFIG)/obj/esp.o'
	$(CC) -c -o $(CONFIG)/obj/esp.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/esp/esp.c

ifeq ($(BIT_PACK_ESP),1)
#
#   espcmd
#
DEPS_53 += $(CONFIG)/inc/mpr.h
DEPS_53 += $(CONFIG)/inc/bit.h
DEPS_53 += $(CONFIG)/inc/bitos.h
DEPS_53 += $(CONFIG)/obj/mprLib.o
DEPS_53 += $(CONFIG)/bin/libmpr.out
DEPS_53 += $(CONFIG)/inc/pcre.h
DEPS_53 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_53 += $(CONFIG)/bin/libpcre.out
endif
DEPS_53 += $(CONFIG)/inc/http.h
DEPS_53 += $(CONFIG)/obj/httpLib.o
DEPS_53 += $(CONFIG)/bin/libhttp.out
DEPS_53 += $(CONFIG)/inc/appweb.h
DEPS_53 += $(CONFIG)/inc/customize.h
DEPS_53 += $(CONFIG)/obj/config.o
DEPS_53 += $(CONFIG)/obj/convenience.o
DEPS_53 += $(CONFIG)/obj/dirHandler.o
DEPS_53 += $(CONFIG)/obj/fileHandler.o
DEPS_53 += $(CONFIG)/obj/log.o
DEPS_53 += $(CONFIG)/obj/server.o
DEPS_53 += $(CONFIG)/bin/libappweb.out
DEPS_53 += $(CONFIG)/inc/edi.h
DEPS_53 += $(CONFIG)/inc/esp.h
DEPS_53 += $(CONFIG)/inc/mdb.h
DEPS_53 += $(CONFIG)/obj/edi.o
DEPS_53 += $(CONFIG)/obj/espAbbrev.o
DEPS_53 += $(CONFIG)/obj/espDeprecated.o
DEPS_53 += $(CONFIG)/obj/espFramework.o
DEPS_53 += $(CONFIG)/obj/espHandler.o
DEPS_53 += $(CONFIG)/obj/espHtml.o
DEPS_53 += $(CONFIG)/obj/espTemplate.o
DEPS_53 += $(CONFIG)/obj/mdb.o
DEPS_53 += $(CONFIG)/obj/sdb.o
DEPS_53 += $(CONFIG)/bin/libmod_esp.out
DEPS_53 += $(CONFIG)/obj/esp.o

$(CONFIG)/bin/esp.out: $(DEPS_53)
	@echo '      [Link] $(CONFIG)/bin/esp.out'
	$(CC) -o $(CONFIG)/bin/esp.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/edi.o" "$(CONFIG)/obj/esp.o" "$(CONFIG)/obj/espAbbrev.o" "$(CONFIG)/obj/espDeprecated.o" "$(CONFIG)/obj/espFramework.o" "$(CONFIG)/obj/espHandler.o" "$(CONFIG)/obj/espHtml.o" "$(CONFIG)/obj/espTemplate.o" "$(CONFIG)/obj/mdb.o" "$(CONFIG)/obj/sdb.o" $(LIBS) -Wl,-r 
endif

ifeq ($(BIT_PACK_ESP),1)
#
#   esp.conf
#
DEPS_54 += src/esp/esp.conf

$(CONFIG)/bin/esp.conf: $(DEPS_54)
	@echo '      [Copy] $(CONFIG)/bin/esp.conf'
	mkdir -p "$(CONFIG)/bin"
	cp src/esp/esp.conf $(CONFIG)/bin/esp.conf
endif

ifeq ($(BIT_PACK_ESP),1)
#
#   esp.conf.server
#
DEPS_55 += src/esp/esp.conf

src/server/esp.conf: $(DEPS_55)
	@echo '      [Copy] src/server/esp.conf'
	mkdir -p "src/server"
	cp src/esp/esp.conf src/server/esp.conf
endif

ifeq ($(BIT_PACK_ESP),1)
#
#   proto
#
DEPS_56 += src/esp/proto

$(CONFIG)/esp: $(DEPS_56)
	@echo '      [Copy] $(CONFIG)/esp'
	mkdir -p "$(CONFIG)/esp/angular/client/lib/angular"
	cp src/esp/proto/angular/client/lib/angular/angular-animate.js $(CONFIG)/esp/angular/client/lib/angular/angular-animate.js
	cp src/esp/proto/angular/client/lib/angular/angular-bootstrap-prettify.js $(CONFIG)/esp/angular/client/lib/angular/angular-bootstrap-prettify.js
	cp src/esp/proto/angular/client/lib/angular/angular-bootstrap.js $(CONFIG)/esp/angular/client/lib/angular/angular-bootstrap.js
	cp src/esp/proto/angular/client/lib/angular/angular-cookies.js $(CONFIG)/esp/angular/client/lib/angular/angular-cookies.js
	cp src/esp/proto/angular/client/lib/angular/angular-loader.js $(CONFIG)/esp/angular/client/lib/angular/angular-loader.js
	cp src/esp/proto/angular/client/lib/angular/angular-mocks.js $(CONFIG)/esp/angular/client/lib/angular/angular-mocks.js
	cp src/esp/proto/angular/client/lib/angular/angular-resource.js $(CONFIG)/esp/angular/client/lib/angular/angular-resource.js
	cp src/esp/proto/angular/client/lib/angular/angular-route.js $(CONFIG)/esp/angular/client/lib/angular/angular-route.js
	cp src/esp/proto/angular/client/lib/angular/angular-sanitize.js $(CONFIG)/esp/angular/client/lib/angular/angular-sanitize.js
	cp src/esp/proto/angular/client/lib/angular/angular-scenario.js $(CONFIG)/esp/angular/client/lib/angular/angular-scenario.js
	cp src/esp/proto/angular/client/lib/angular/angular-touch.js $(CONFIG)/esp/angular/client/lib/angular/angular-touch.js
	cp src/esp/proto/angular/client/lib/angular/angular.js $(CONFIG)/esp/angular/client/lib/angular/angular.js
	cp src/esp/proto/angular/client/lib/angular/errors.json $(CONFIG)/esp/angular/client/lib/angular/errors.json
	cp src/esp/proto/angular/client/lib/angular/version.json $(CONFIG)/esp/angular/client/lib/angular/version.json
	cp src/esp/proto/angular/client/lib/angular/version.txt $(CONFIG)/esp/angular/client/lib/angular/version.txt
	mkdir -p "$(CONFIG)/esp/angular"
	cp src/esp/proto/angular/esp.json $(CONFIG)/esp/angular/esp.json
	mkdir -p "$(CONFIG)/esp/angular-esp/client/lib/angular-esp"
	cp src/esp/proto/angular-esp/client/lib/angular-esp/esp-click.js $(CONFIG)/esp/angular-esp/client/lib/angular-esp/esp-click.js
	cp src/esp/proto/angular-esp/client/lib/angular-esp/esp-confirm.js $(CONFIG)/esp/angular-esp/client/lib/angular-esp/esp-confirm.js
	cp src/esp/proto/angular-esp/client/lib/angular-esp/esp-field-errors.js $(CONFIG)/esp/angular-esp/client/lib/angular-esp/esp-field-errors.js
	cp src/esp/proto/angular-esp/client/lib/angular-esp/esp-format.js $(CONFIG)/esp/angular-esp/client/lib/angular-esp/esp-format.js
	cp src/esp/proto/angular-esp/client/lib/angular-esp/esp-gauge.js $(CONFIG)/esp/angular-esp/client/lib/angular-esp/esp-gauge.js
	cp src/esp/proto/angular-esp/client/lib/angular-esp/esp-input-group.js $(CONFIG)/esp/angular-esp/client/lib/angular-esp/esp-input-group.js
	cp src/esp/proto/angular-esp/client/lib/angular-esp/esp-input.js $(CONFIG)/esp/angular-esp/client/lib/angular-esp/esp-input.js
	cp src/esp/proto/angular-esp/client/lib/angular-esp/esp-local.es $(CONFIG)/esp/angular-esp/client/lib/angular-esp/esp-local.es
	cp src/esp/proto/angular-esp/client/lib/angular-esp/esp-local.js $(CONFIG)/esp/angular-esp/client/lib/angular-esp/esp-local.js
	cp src/esp/proto/angular-esp/client/lib/angular-esp/esp-modal.js $(CONFIG)/esp/angular-esp/client/lib/angular-esp/esp-modal.js
	cp src/esp/proto/angular-esp/client/lib/angular-esp/esp-resource.es $(CONFIG)/esp/angular-esp/client/lib/angular-esp/esp-resource.es
	cp src/esp/proto/angular-esp/client/lib/angular-esp/esp-resource.js $(CONFIG)/esp/angular-esp/client/lib/angular-esp/esp-resource.js
	cp src/esp/proto/angular-esp/client/lib/angular-esp/esp-session.es $(CONFIG)/esp/angular-esp/client/lib/angular-esp/esp-session.es
	cp src/esp/proto/angular-esp/client/lib/angular-esp/esp-session.js $(CONFIG)/esp/angular-esp/client/lib/angular-esp/esp-session.js
	cp src/esp/proto/angular-esp/client/lib/angular-esp/esp-titlecase.js $(CONFIG)/esp/angular-esp/client/lib/angular-esp/esp-titlecase.js
	cp src/esp/proto/angular-esp/client/lib/angular-esp/esp.es $(CONFIG)/esp/angular-esp/client/lib/angular-esp/esp.es
	cp src/esp/proto/angular-esp/client/lib/angular-esp/esp.js $(CONFIG)/esp/angular-esp/client/lib/angular-esp/esp.js
	mkdir -p "$(CONFIG)/esp/angular-esp"
	cp src/esp/proto/angular-esp/esp.json $(CONFIG)/esp/angular-esp/esp.json
	mkdir -p "$(CONFIG)/esp/angular-esp-extras/client/lib/angular-esp-extras"
	cp src/esp/proto/angular-esp-extras/client/lib/angular-esp-extras/esp-svg-gauge.js $(CONFIG)/esp/angular-esp-extras/client/lib/angular-esp-extras/esp-svg-gauge.js
	mkdir -p "$(CONFIG)/esp/angular-esp-extras"
	cp src/esp/proto/angular-esp-extras/esp.json $(CONFIG)/esp/angular-esp-extras/esp.json
	mkdir -p "$(CONFIG)/esp/angular-mvc"
	cp src/esp/proto/angular-mvc/appweb.conf $(CONFIG)/esp/angular-mvc/appweb.conf
	mkdir -p "$(CONFIG)/esp/angular-mvc/client/app"
	cp src/esp/proto/angular-mvc/client/app/main.js $(CONFIG)/esp/angular-mvc/client/app/main.js
	mkdir -p "$(CONFIG)/esp/angular-mvc/client/assets"
	cp src/esp/proto/angular-mvc/client/assets/favicon.ico $(CONFIG)/esp/angular-mvc/client/assets/favicon.ico
	mkdir -p "$(CONFIG)/esp/angular-mvc/client/css"
	cp src/esp/proto/angular-mvc/client/css/all.less $(CONFIG)/esp/angular-mvc/client/css/all.less
	cp src/esp/proto/angular-mvc/client/css/app.less $(CONFIG)/esp/angular-mvc/client/css/app.less
	cp src/esp/proto/angular-mvc/client/css/fix.less $(CONFIG)/esp/angular-mvc/client/css/fix.less
	cp src/esp/proto/angular-mvc/client/css/theme.less $(CONFIG)/esp/angular-mvc/client/css/theme.less
	mkdir -p "$(CONFIG)/esp/angular-mvc/client"
	cp src/esp/proto/angular-mvc/client/index.esp $(CONFIG)/esp/angular-mvc/client/index.esp
	mkdir -p "$(CONFIG)/esp/angular-mvc/client/pages"
	cp src/esp/proto/angular-mvc/client/pages/splash.html $(CONFIG)/esp/angular-mvc/client/pages/splash.html
	cp src/esp/proto/angular-mvc/esp.json $(CONFIG)/esp/angular-mvc/esp.json
	cp src/esp/proto/angular-mvc/hosted.conf $(CONFIG)/esp/angular-mvc/hosted.conf
	cp src/esp/proto/angular-mvc/start.bit $(CONFIG)/esp/angular-mvc/start.bit
	mkdir -p "$(CONFIG)/esp/angular-mvc/templates"
	cp src/esp/proto/angular-mvc/templates/controller-singleton.c $(CONFIG)/esp/angular-mvc/templates/controller-singleton.c
	cp src/esp/proto/angular-mvc/templates/controller.c $(CONFIG)/esp/angular-mvc/templates/controller.c
	cp src/esp/proto/angular-mvc/templates/controller.js $(CONFIG)/esp/angular-mvc/templates/controller.js
	cp src/esp/proto/angular-mvc/templates/edit.html $(CONFIG)/esp/angular-mvc/templates/edit.html
	cp src/esp/proto/angular-mvc/templates/list.html $(CONFIG)/esp/angular-mvc/templates/list.html
	cp src/esp/proto/angular-mvc/templates/model.js $(CONFIG)/esp/angular-mvc/templates/model.js
	mkdir -p "$(CONFIG)/esp/angular-ui-bootstrap/client/lib/angular-ui-bootstrap"
	cp src/esp/proto/angular-ui-bootstrap/client/lib/angular-ui-bootstrap/ui-bootstrap-tpls.js $(CONFIG)/esp/angular-ui-bootstrap/client/lib/angular-ui-bootstrap/ui-bootstrap-tpls.js
	mkdir -p "$(CONFIG)/esp/angular-ui-bootstrap"
	cp src/esp/proto/angular-ui-bootstrap/esp.json $(CONFIG)/esp/angular-ui-bootstrap/esp.json
	mkdir -p "$(CONFIG)/esp/animate/client/css"
	cp src/esp/proto/animate/client/css/animate.css $(CONFIG)/esp/animate/client/css/animate.css
	mkdir -p "$(CONFIG)/esp/animate"
	cp src/esp/proto/animate/esp.json $(CONFIG)/esp/animate/esp.json
	mkdir -p "$(CONFIG)/esp/bootstrap/client/lib/bootstrap/css"
	cp src/esp/proto/bootstrap/client/lib/bootstrap/css/bootstrap-theme.css $(CONFIG)/esp/bootstrap/client/lib/bootstrap/css/bootstrap-theme.css
	cp src/esp/proto/bootstrap/client/lib/bootstrap/css/bootstrap-theme.min.css $(CONFIG)/esp/bootstrap/client/lib/bootstrap/css/bootstrap-theme.min.css
	cp src/esp/proto/bootstrap/client/lib/bootstrap/css/bootstrap.css $(CONFIG)/esp/bootstrap/client/lib/bootstrap/css/bootstrap.css
	cp src/esp/proto/bootstrap/client/lib/bootstrap/css/bootstrap.min.css $(CONFIG)/esp/bootstrap/client/lib/bootstrap/css/bootstrap.min.css
	mkdir -p "$(CONFIG)/esp/bootstrap/client/lib/bootstrap/fonts"
	cp src/esp/proto/bootstrap/client/lib/bootstrap/fonts/glyphicons-halflings-regular.eot $(CONFIG)/esp/bootstrap/client/lib/bootstrap/fonts/glyphicons-halflings-regular.eot
	cp src/esp/proto/bootstrap/client/lib/bootstrap/fonts/glyphicons-halflings-regular.svg $(CONFIG)/esp/bootstrap/client/lib/bootstrap/fonts/glyphicons-halflings-regular.svg
	cp src/esp/proto/bootstrap/client/lib/bootstrap/fonts/glyphicons-halflings-regular.ttf $(CONFIG)/esp/bootstrap/client/lib/bootstrap/fonts/glyphicons-halflings-regular.ttf
	cp src/esp/proto/bootstrap/client/lib/bootstrap/fonts/glyphicons-halflings-regular.woff $(CONFIG)/esp/bootstrap/client/lib/bootstrap/fonts/glyphicons-halflings-regular.woff
	mkdir -p "$(CONFIG)/esp/bootstrap/client/lib/bootstrap/js"
	cp src/esp/proto/bootstrap/client/lib/bootstrap/js/bootstrap.js $(CONFIG)/esp/bootstrap/client/lib/bootstrap/js/bootstrap.js
	mkdir -p "$(CONFIG)/esp/bootstrap/client/lib/bootstrap/less"
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/alerts.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/alerts.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/badges.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/badges.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/bootstrap.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/bootstrap.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/breadcrumbs.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/breadcrumbs.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/button-groups.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/button-groups.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/buttons.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/buttons.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/carousel.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/carousel.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/close.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/close.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/code.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/code.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/component-animations.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/component-animations.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/dropdowns.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/dropdowns.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/forms.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/forms.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/glyphicons.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/glyphicons.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/grid.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/grid.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/input-groups.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/input-groups.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/jumbotron.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/jumbotron.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/labels.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/labels.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/list-group.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/list-group.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/media.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/media.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/mixins.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/mixins.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/modals.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/modals.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/navbar.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/navbar.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/navs.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/navs.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/normalize.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/normalize.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/pager.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/pager.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/pagination.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/pagination.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/panels.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/panels.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/popovers.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/popovers.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/print.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/print.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/progress-bars.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/progress-bars.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/responsive-utilities.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/responsive-utilities.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/scaffolding.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/scaffolding.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/tables.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/tables.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/theme.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/theme.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/thumbnails.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/thumbnails.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/tooltip.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/tooltip.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/type.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/type.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/utilities.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/utilities.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/variables.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/variables.less
	cp src/esp/proto/bootstrap/client/lib/bootstrap/less/wells.less $(CONFIG)/esp/bootstrap/client/lib/bootstrap/less/wells.less
	mkdir -p "$(CONFIG)/esp/bootstrap"
	cp src/esp/proto/bootstrap/esp.json $(CONFIG)/esp/bootstrap/esp.json
	mkdir -p "$(CONFIG)/esp/d3/client/lib/d3"
	cp src/esp/proto/d3/client/lib/d3/d3.v3.js $(CONFIG)/esp/d3/client/lib/d3/d3.v3.js
	mkdir -p "$(CONFIG)/esp/d3"
	cp src/esp/proto/d3/esp.json $(CONFIG)/esp/d3/esp.json
	mkdir -p "$(CONFIG)/esp/flot/client/lib/flot"
	cp src/esp/proto/flot/client/lib/flot/excanvas.js $(CONFIG)/esp/flot/client/lib/flot/excanvas.js
	cp src/esp/proto/flot/client/lib/flot/jquery.colorhelpers.js $(CONFIG)/esp/flot/client/lib/flot/jquery.colorhelpers.js
	cp src/esp/proto/flot/client/lib/flot/jquery.flot.canvas.js $(CONFIG)/esp/flot/client/lib/flot/jquery.flot.canvas.js
	cp src/esp/proto/flot/client/lib/flot/jquery.flot.categories.js $(CONFIG)/esp/flot/client/lib/flot/jquery.flot.categories.js
	cp src/esp/proto/flot/client/lib/flot/jquery.flot.crosshair.js $(CONFIG)/esp/flot/client/lib/flot/jquery.flot.crosshair.js
	cp src/esp/proto/flot/client/lib/flot/jquery.flot.errorbars.js $(CONFIG)/esp/flot/client/lib/flot/jquery.flot.errorbars.js
	cp src/esp/proto/flot/client/lib/flot/jquery.flot.fillbetween.js $(CONFIG)/esp/flot/client/lib/flot/jquery.flot.fillbetween.js
	cp src/esp/proto/flot/client/lib/flot/jquery.flot.image.js $(CONFIG)/esp/flot/client/lib/flot/jquery.flot.image.js
	cp src/esp/proto/flot/client/lib/flot/jquery.flot.js $(CONFIG)/esp/flot/client/lib/flot/jquery.flot.js
	cp src/esp/proto/flot/client/lib/flot/jquery.flot.navigate.js $(CONFIG)/esp/flot/client/lib/flot/jquery.flot.navigate.js
	cp src/esp/proto/flot/client/lib/flot/jquery.flot.pie.js $(CONFIG)/esp/flot/client/lib/flot/jquery.flot.pie.js
	cp src/esp/proto/flot/client/lib/flot/jquery.flot.resize.js $(CONFIG)/esp/flot/client/lib/flot/jquery.flot.resize.js
	cp src/esp/proto/flot/client/lib/flot/jquery.flot.selection.js $(CONFIG)/esp/flot/client/lib/flot/jquery.flot.selection.js
	cp src/esp/proto/flot/client/lib/flot/jquery.flot.stack.js $(CONFIG)/esp/flot/client/lib/flot/jquery.flot.stack.js
	cp src/esp/proto/flot/client/lib/flot/jquery.flot.symbol.js $(CONFIG)/esp/flot/client/lib/flot/jquery.flot.symbol.js
	cp src/esp/proto/flot/client/lib/flot/jquery.flot.threshold.js $(CONFIG)/esp/flot/client/lib/flot/jquery.flot.threshold.js
	cp src/esp/proto/flot/client/lib/flot/jquery.flot.time.js $(CONFIG)/esp/flot/client/lib/flot/jquery.flot.time.js
	cp src/esp/proto/flot/client/lib/flot/jquery.js $(CONFIG)/esp/flot/client/lib/flot/jquery.js
	mkdir -p "$(CONFIG)/esp/flot"
	cp src/esp/proto/flot/esp.json $(CONFIG)/esp/flot/esp.json
	mkdir -p "$(CONFIG)/esp/font-awesome/client/lib/font-awesome/css"
	cp src/esp/proto/font-awesome/client/lib/font-awesome/css/font-awesome-ie7.css $(CONFIG)/esp/font-awesome/client/lib/font-awesome/css/font-awesome-ie7.css
	cp src/esp/proto/font-awesome/client/lib/font-awesome/css/font-awesome-ie7.min.css $(CONFIG)/esp/font-awesome/client/lib/font-awesome/css/font-awesome-ie7.min.css
	cp src/esp/proto/font-awesome/client/lib/font-awesome/css/font-awesome.css $(CONFIG)/esp/font-awesome/client/lib/font-awesome/css/font-awesome.css
	cp src/esp/proto/font-awesome/client/lib/font-awesome/css/font-awesome.min.css $(CONFIG)/esp/font-awesome/client/lib/font-awesome/css/font-awesome.min.css
	mkdir -p "$(CONFIG)/esp/font-awesome/client/lib/font-awesome/font"
	cp src/esp/proto/font-awesome/client/lib/font-awesome/font/fontawesome-webfont.eot $(CONFIG)/esp/font-awesome/client/lib/font-awesome/font/fontawesome-webfont.eot
	cp src/esp/proto/font-awesome/client/lib/font-awesome/font/fontawesome-webfont.svg $(CONFIG)/esp/font-awesome/client/lib/font-awesome/font/fontawesome-webfont.svg
	cp src/esp/proto/font-awesome/client/lib/font-awesome/font/fontawesome-webfont.ttf $(CONFIG)/esp/font-awesome/client/lib/font-awesome/font/fontawesome-webfont.ttf
	cp src/esp/proto/font-awesome/client/lib/font-awesome/font/fontawesome-webfont.woff $(CONFIG)/esp/font-awesome/client/lib/font-awesome/font/fontawesome-webfont.woff
	cp src/esp/proto/font-awesome/client/lib/font-awesome/font/FontAwesome.otf $(CONFIG)/esp/font-awesome/client/lib/font-awesome/font/FontAwesome.otf
	mkdir -p "$(CONFIG)/esp/font-awesome/client/lib/font-awesome/less"
	cp src/esp/proto/font-awesome/client/lib/font-awesome/less/bootstrap.less $(CONFIG)/esp/font-awesome/client/lib/font-awesome/less/bootstrap.less
	cp src/esp/proto/font-awesome/client/lib/font-awesome/less/core.less $(CONFIG)/esp/font-awesome/client/lib/font-awesome/less/core.less
	cp src/esp/proto/font-awesome/client/lib/font-awesome/less/extras.less $(CONFIG)/esp/font-awesome/client/lib/font-awesome/less/extras.less
	cp src/esp/proto/font-awesome/client/lib/font-awesome/less/font-awesome-ie7.less $(CONFIG)/esp/font-awesome/client/lib/font-awesome/less/font-awesome-ie7.less
	cp src/esp/proto/font-awesome/client/lib/font-awesome/less/font-awesome.less $(CONFIG)/esp/font-awesome/client/lib/font-awesome/less/font-awesome.less
	cp src/esp/proto/font-awesome/client/lib/font-awesome/less/icons.less $(CONFIG)/esp/font-awesome/client/lib/font-awesome/less/icons.less
	cp src/esp/proto/font-awesome/client/lib/font-awesome/less/mixins.less $(CONFIG)/esp/font-awesome/client/lib/font-awesome/less/mixins.less
	cp src/esp/proto/font-awesome/client/lib/font-awesome/less/path.less $(CONFIG)/esp/font-awesome/client/lib/font-awesome/less/path.less
	cp src/esp/proto/font-awesome/client/lib/font-awesome/less/variables.less $(CONFIG)/esp/font-awesome/client/lib/font-awesome/less/variables.less
	mkdir -p "$(CONFIG)/esp/font-awesome/client/lib/font-awesome/scss"
	cp src/esp/proto/font-awesome/client/lib/font-awesome/scss/_bootstrap.scss $(CONFIG)/esp/font-awesome/client/lib/font-awesome/scss/_bootstrap.scss
	cp src/esp/proto/font-awesome/client/lib/font-awesome/scss/_core.scss $(CONFIG)/esp/font-awesome/client/lib/font-awesome/scss/_core.scss
	cp src/esp/proto/font-awesome/client/lib/font-awesome/scss/_extras.scss $(CONFIG)/esp/font-awesome/client/lib/font-awesome/scss/_extras.scss
	cp src/esp/proto/font-awesome/client/lib/font-awesome/scss/_icons.scss $(CONFIG)/esp/font-awesome/client/lib/font-awesome/scss/_icons.scss
	cp src/esp/proto/font-awesome/client/lib/font-awesome/scss/_mixins.scss $(CONFIG)/esp/font-awesome/client/lib/font-awesome/scss/_mixins.scss
	cp src/esp/proto/font-awesome/client/lib/font-awesome/scss/_path.scss $(CONFIG)/esp/font-awesome/client/lib/font-awesome/scss/_path.scss
	cp src/esp/proto/font-awesome/client/lib/font-awesome/scss/_variables.scss $(CONFIG)/esp/font-awesome/client/lib/font-awesome/scss/_variables.scss
	cp src/esp/proto/font-awesome/client/lib/font-awesome/scss/font-awesome-ie7.scss $(CONFIG)/esp/font-awesome/client/lib/font-awesome/scss/font-awesome-ie7.scss
	cp src/esp/proto/font-awesome/client/lib/font-awesome/scss/font-awesome.scss $(CONFIG)/esp/font-awesome/client/lib/font-awesome/scss/font-awesome.scss
	mkdir -p "$(CONFIG)/esp/font-awesome"
	cp src/esp/proto/font-awesome/esp.json $(CONFIG)/esp/font-awesome/esp.json
	mkdir -p "$(CONFIG)/esp/html-mvc"
	cp src/esp/proto/html-mvc/appweb.conf $(CONFIG)/esp/html-mvc/appweb.conf
	mkdir -p "$(CONFIG)/esp/html-mvc/client/assets"
	cp src/esp/proto/html-mvc/client/assets/favicon.ico $(CONFIG)/esp/html-mvc/client/assets/favicon.ico
	mkdir -p "$(CONFIG)/esp/html-mvc/client/css"
	cp src/esp/proto/html-mvc/client/css/all.less $(CONFIG)/esp/html-mvc/client/css/all.less
	cp src/esp/proto/html-mvc/client/css/app.less $(CONFIG)/esp/html-mvc/client/css/app.less
	cp src/esp/proto/html-mvc/client/css/fix.less $(CONFIG)/esp/html-mvc/client/css/fix.less
	cp src/esp/proto/html-mvc/client/css/theme.less $(CONFIG)/esp/html-mvc/client/css/theme.less
	mkdir -p "$(CONFIG)/esp/html-mvc/client"
	cp src/esp/proto/html-mvc/client/index.esp $(CONFIG)/esp/html-mvc/client/index.esp
	mkdir -p "$(CONFIG)/esp/html-mvc/client/layouts"
	cp src/esp/proto/html-mvc/client/layouts/default.esp $(CONFIG)/esp/html-mvc/client/layouts/default.esp
	cp src/esp/proto/html-mvc/esp.json $(CONFIG)/esp/html-mvc/esp.json
	cp src/esp/proto/html-mvc/hosted.conf $(CONFIG)/esp/html-mvc/hosted.conf
	cp src/esp/proto/html-mvc/start.bit $(CONFIG)/esp/html-mvc/start.bit
	mkdir -p "$(CONFIG)/esp/html-mvc/templates"
	cp src/esp/proto/html-mvc/templates/controller-singleton.c $(CONFIG)/esp/html-mvc/templates/controller-singleton.c
	cp src/esp/proto/html-mvc/templates/controller.c $(CONFIG)/esp/html-mvc/templates/controller.c
	cp src/esp/proto/html-mvc/templates/edit.esp $(CONFIG)/esp/html-mvc/templates/edit.esp
	cp src/esp/proto/html-mvc/templates/list.esp $(CONFIG)/esp/html-mvc/templates/list.esp
	mkdir -p "$(CONFIG)/esp/html5shiv/client/lib/html5shiv"
	cp src/esp/proto/html5shiv/client/lib/html5shiv/html5shiv.js $(CONFIG)/esp/html5shiv/client/lib/html5shiv/html5shiv.js
	mkdir -p "$(CONFIG)/esp/html5shiv"
	cp src/esp/proto/html5shiv/esp.json $(CONFIG)/esp/html5shiv/esp.json
	mkdir -p "$(CONFIG)/esp/jquery/client/lib/jquery"
	cp src/esp/proto/jquery/client/lib/jquery/jquery.js $(CONFIG)/esp/jquery/client/lib/jquery/jquery.js
	mkdir -p "$(CONFIG)/esp/jquery"
	cp src/esp/proto/jquery/esp.json $(CONFIG)/esp/jquery/esp.json
	mkdir -p "$(CONFIG)/esp/legacy-mvc"
	cp src/esp/proto/legacy-mvc/esp.json $(CONFIG)/esp/legacy-mvc/esp.json
	mkdir -p "$(CONFIG)/esp/legacy-mvc/layouts"
	cp src/esp/proto/legacy-mvc/layouts/default.esp $(CONFIG)/esp/legacy-mvc/layouts/default.esp
	mkdir -p "$(CONFIG)/esp/legacy-mvc/static/css"
	cp src/esp/proto/legacy-mvc/static/css/all.css $(CONFIG)/esp/legacy-mvc/static/css/all.css
	mkdir -p "$(CONFIG)/esp/legacy-mvc/static/images"
	cp src/esp/proto/legacy-mvc/static/images/banner.jpg $(CONFIG)/esp/legacy-mvc/static/images/banner.jpg
	cp src/esp/proto/legacy-mvc/static/images/favicon.ico $(CONFIG)/esp/legacy-mvc/static/images/favicon.ico
	cp src/esp/proto/legacy-mvc/static/images/splash.jpg $(CONFIG)/esp/legacy-mvc/static/images/splash.jpg
	mkdir -p "$(CONFIG)/esp/legacy-mvc/static"
	cp src/esp/proto/legacy-mvc/static/index.esp $(CONFIG)/esp/legacy-mvc/static/index.esp
	mkdir -p "$(CONFIG)/esp/legacy-mvc/static/js"
	cp src/esp/proto/legacy-mvc/static/js/jquery.esp.js $(CONFIG)/esp/legacy-mvc/static/js/jquery.esp.js
	cp src/esp/proto/legacy-mvc/static/js/jquery.js $(CONFIG)/esp/legacy-mvc/static/js/jquery.js
	mkdir -p "$(CONFIG)/esp/legacy-mvc/templates"
	cp src/esp/proto/legacy-mvc/templates/controller.c $(CONFIG)/esp/legacy-mvc/templates/controller.c
	cp src/esp/proto/legacy-mvc/templates/edit.esp $(CONFIG)/esp/legacy-mvc/templates/edit.esp
	cp src/esp/proto/legacy-mvc/templates/list.esp $(CONFIG)/esp/legacy-mvc/templates/list.esp
	mkdir -p "$(CONFIG)/esp/less/client/lib/less"
	cp src/esp/proto/less/client/lib/less/less.js $(CONFIG)/esp/less/client/lib/less/less.js
	mkdir -p "$(CONFIG)/esp/less"
	cp src/esp/proto/less/esp.json $(CONFIG)/esp/less/esp.json
	mkdir -p "$(CONFIG)/esp/more/client/css"
	cp src/esp/proto/more/client/css/more.less $(CONFIG)/esp/more/client/css/more.less
	mkdir -p "$(CONFIG)/esp/more"
	cp src/esp/proto/more/esp.json $(CONFIG)/esp/more/esp.json
	mkdir -p "$(CONFIG)/esp/normalize/client/css"
	cp src/esp/proto/normalize/client/css/normalize.less $(CONFIG)/esp/normalize/client/css/normalize.less
	mkdir -p "$(CONFIG)/esp/normalize"
	cp src/esp/proto/normalize/esp.json $(CONFIG)/esp/normalize/esp.json
	mkdir -p "$(CONFIG)/esp/nvd3/client/lib/nvd3"
	cp src/esp/proto/nvd3/client/lib/nvd3/nv.d3.css $(CONFIG)/esp/nvd3/client/lib/nvd3/nv.d3.css
	cp src/esp/proto/nvd3/client/lib/nvd3/nv.d3.js $(CONFIG)/esp/nvd3/client/lib/nvd3/nv.d3.js
	cp src/esp/proto/nvd3/client/lib/nvd3/nv.d3.min.css $(CONFIG)/esp/nvd3/client/lib/nvd3/nv.d3.min.css
	mkdir -p "$(CONFIG)/esp/nvd3"
	cp src/esp/proto/nvd3/esp.json $(CONFIG)/esp/nvd3/esp.json
	mkdir -p "$(CONFIG)/esp/respond/client/lib/respond"
	cp src/esp/proto/respond/client/lib/respond/respond.js $(CONFIG)/esp/respond/client/lib/respond/respond.js
	mkdir -p "$(CONFIG)/esp/respond"
	cp src/esp/proto/respond/esp.json $(CONFIG)/esp/respond/esp.json
	mkdir -p "$(CONFIG)/esp/server"
	cp src/esp/proto/server/appweb.conf $(CONFIG)/esp/server/appweb.conf
	cp src/esp/proto/server/esp.json $(CONFIG)/esp/server/esp.json
	cp src/esp/proto/server/hosted.conf $(CONFIG)/esp/server/hosted.conf
	mkdir -p "$(CONFIG)/esp/server/templates"
	cp src/esp/proto/server/templates/app.c $(CONFIG)/esp/server/templates/app.c
	cp src/esp/proto/server/templates/controller.c $(CONFIG)/esp/server/templates/controller.c
	cp src/esp/proto/server/templates/migration.c $(CONFIG)/esp/server/templates/migration.c
	mkdir -p "$(CONFIG)/esp/xcharts/client/lib/xcharts"
	cp src/esp/proto/xcharts/client/lib/xcharts/xcharts.css $(CONFIG)/esp/xcharts/client/lib/xcharts/xcharts.css
	cp src/esp/proto/xcharts/client/lib/xcharts/xcharts.js $(CONFIG)/esp/xcharts/client/lib/xcharts/xcharts.js
	cp src/esp/proto/xcharts/client/lib/xcharts/xcharts.min.css $(CONFIG)/esp/xcharts/client/lib/xcharts/xcharts.min.css
	mkdir -p "$(CONFIG)/esp/xcharts"
	cp src/esp/proto/xcharts/esp.json $(CONFIG)/esp/xcharts/esp.json
endif

#
#   ejs.h
#
$(CONFIG)/inc/ejs.h: $(DEPS_57)
	@echo '      [Copy] $(CONFIG)/inc/ejs.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/deps/ejs/ejs.h $(CONFIG)/inc/ejs.h

#
#   ejs.slots.h
#
$(CONFIG)/inc/ejs.slots.h: $(DEPS_58)
	@echo '      [Copy] $(CONFIG)/inc/ejs.slots.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/deps/ejs/ejs.slots.h $(CONFIG)/inc/ejs.slots.h

#
#   ejsByteGoto.h
#
$(CONFIG)/inc/ejsByteGoto.h: $(DEPS_59)
	@echo '      [Copy] $(CONFIG)/inc/ejsByteGoto.h'
	mkdir -p "$(CONFIG)/inc"
	cp src/deps/ejs/ejsByteGoto.h $(CONFIG)/inc/ejsByteGoto.h

#
#   ejsLib.o
#
DEPS_60 += $(CONFIG)/inc/bit.h
DEPS_60 += $(CONFIG)/inc/ejs.h
DEPS_60 += $(CONFIG)/inc/mpr.h
DEPS_60 += $(CONFIG)/inc/pcre.h
DEPS_60 += $(CONFIG)/inc/bitos.h
DEPS_60 += $(CONFIG)/inc/http.h
DEPS_60 += $(CONFIG)/inc/ejs.slots.h

$(CONFIG)/obj/ejsLib.o: \
    src/deps/ejs/ejsLib.c $(DEPS_60)
	@echo '   [Compile] $(CONFIG)/obj/ejsLib.o'
	$(CC) -c -o $(CONFIG)/obj/ejsLib.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/deps/ejs/ejsLib.c

ifeq ($(BIT_PACK_EJSCRIPT),1)
#
#   libejs
#
DEPS_61 += $(CONFIG)/inc/mpr.h
DEPS_61 += $(CONFIG)/inc/bit.h
DEPS_61 += $(CONFIG)/inc/bitos.h
DEPS_61 += $(CONFIG)/obj/mprLib.o
DEPS_61 += $(CONFIG)/bin/libmpr.out
DEPS_61 += $(CONFIG)/inc/pcre.h
DEPS_61 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_61 += $(CONFIG)/bin/libpcre.out
endif
DEPS_61 += $(CONFIG)/inc/http.h
DEPS_61 += $(CONFIG)/obj/httpLib.o
DEPS_61 += $(CONFIG)/bin/libhttp.out
DEPS_61 += $(CONFIG)/inc/ejs.h
DEPS_61 += $(CONFIG)/inc/ejs.slots.h
DEPS_61 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_61 += $(CONFIG)/obj/ejsLib.o

$(CONFIG)/bin/libejs.out: $(DEPS_61)
	@echo '      [Link] $(CONFIG)/bin/libejs.out'
	$(CC) -r -o $(CONFIG)/bin/libejs.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/ejsLib.o" $(LIBS) 
endif

#
#   ejs.o
#
DEPS_62 += $(CONFIG)/inc/bit.h
DEPS_62 += $(CONFIG)/inc/ejs.h

$(CONFIG)/obj/ejs.o: \
    src/deps/ejs/ejs.c $(DEPS_62)
	@echo '   [Compile] $(CONFIG)/obj/ejs.o'
	$(CC) -c -o $(CONFIG)/obj/ejs.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/deps/ejs/ejs.c

ifeq ($(BIT_PACK_EJSCRIPT),1)
#
#   ejs
#
DEPS_63 += $(CONFIG)/inc/mpr.h
DEPS_63 += $(CONFIG)/inc/bit.h
DEPS_63 += $(CONFIG)/inc/bitos.h
DEPS_63 += $(CONFIG)/obj/mprLib.o
DEPS_63 += $(CONFIG)/bin/libmpr.out
DEPS_63 += $(CONFIG)/inc/pcre.h
DEPS_63 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_63 += $(CONFIG)/bin/libpcre.out
endif
DEPS_63 += $(CONFIG)/inc/http.h
DEPS_63 += $(CONFIG)/obj/httpLib.o
DEPS_63 += $(CONFIG)/bin/libhttp.out
DEPS_63 += $(CONFIG)/inc/ejs.h
DEPS_63 += $(CONFIG)/inc/ejs.slots.h
DEPS_63 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_63 += $(CONFIG)/obj/ejsLib.o
DEPS_63 += $(CONFIG)/bin/libejs.out
DEPS_63 += $(CONFIG)/obj/ejs.o

$(CONFIG)/bin/ejs.out: $(DEPS_63)
	@echo '      [Link] $(CONFIG)/bin/ejs.out'
	$(CC) -o $(CONFIG)/bin/ejs.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/ejs.o" $(LIBS) -Wl,-r 
endif

#
#   ejsc.o
#
DEPS_64 += $(CONFIG)/inc/bit.h
DEPS_64 += $(CONFIG)/inc/ejs.h

$(CONFIG)/obj/ejsc.o: \
    src/deps/ejs/ejsc.c $(DEPS_64)
	@echo '   [Compile] $(CONFIG)/obj/ejsc.o'
	$(CC) -c -o $(CONFIG)/obj/ejsc.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/deps/ejs/ejsc.c

ifeq ($(BIT_PACK_EJSCRIPT),1)
#
#   ejsc
#
DEPS_65 += $(CONFIG)/inc/mpr.h
DEPS_65 += $(CONFIG)/inc/bit.h
DEPS_65 += $(CONFIG)/inc/bitos.h
DEPS_65 += $(CONFIG)/obj/mprLib.o
DEPS_65 += $(CONFIG)/bin/libmpr.out
DEPS_65 += $(CONFIG)/inc/pcre.h
DEPS_65 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_65 += $(CONFIG)/bin/libpcre.out
endif
DEPS_65 += $(CONFIG)/inc/http.h
DEPS_65 += $(CONFIG)/obj/httpLib.o
DEPS_65 += $(CONFIG)/bin/libhttp.out
DEPS_65 += $(CONFIG)/inc/ejs.h
DEPS_65 += $(CONFIG)/inc/ejs.slots.h
DEPS_65 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_65 += $(CONFIG)/obj/ejsLib.o
DEPS_65 += $(CONFIG)/bin/libejs.out
DEPS_65 += $(CONFIG)/obj/ejsc.o

$(CONFIG)/bin/ejsc.out: $(DEPS_65)
	@echo '      [Link] $(CONFIG)/bin/ejsc.out'
	$(CC) -o $(CONFIG)/bin/ejsc.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/ejsc.o" $(LIBS) -Wl,-r 
endif

ifeq ($(BIT_PACK_EJSCRIPT),1)
#
#   ejs.mod
#
DEPS_66 += src/deps/ejs/ejs.es
DEPS_66 += $(CONFIG)/inc/mpr.h
DEPS_66 += $(CONFIG)/inc/bit.h
DEPS_66 += $(CONFIG)/inc/bitos.h
DEPS_66 += $(CONFIG)/obj/mprLib.o
DEPS_66 += $(CONFIG)/bin/libmpr.out
DEPS_66 += $(CONFIG)/inc/pcre.h
DEPS_66 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_66 += $(CONFIG)/bin/libpcre.out
endif
DEPS_66 += $(CONFIG)/inc/http.h
DEPS_66 += $(CONFIG)/obj/httpLib.o
DEPS_66 += $(CONFIG)/bin/libhttp.out
DEPS_66 += $(CONFIG)/inc/ejs.h
DEPS_66 += $(CONFIG)/inc/ejs.slots.h
DEPS_66 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_66 += $(CONFIG)/obj/ejsLib.o
DEPS_66 += $(CONFIG)/bin/libejs.out
DEPS_66 += $(CONFIG)/obj/ejsc.o
DEPS_66 += $(CONFIG)/bin/ejsc.out

$(CONFIG)/bin/ejs.mod: $(DEPS_66)
	$(LBIN)/ejsc --out ./$(CONFIG)/bin/ejs.mod --optimize 9 --bind --require null src/deps/ejs/ejs.es
endif

#
#   cgiHandler.o
#
DEPS_67 += $(CONFIG)/inc/bit.h
DEPS_67 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/cgiHandler.o: \
    src/modules/cgiHandler.c $(DEPS_67)
	@echo '   [Compile] $(CONFIG)/obj/cgiHandler.o'
	$(CC) -c -o $(CONFIG)/obj/cgiHandler.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/modules/cgiHandler.c

ifeq ($(BIT_PACK_CGI),1)
#
#   libmod_cgi
#
DEPS_68 += $(CONFIG)/inc/mpr.h
DEPS_68 += $(CONFIG)/inc/bit.h
DEPS_68 += $(CONFIG)/inc/bitos.h
DEPS_68 += $(CONFIG)/obj/mprLib.o
DEPS_68 += $(CONFIG)/bin/libmpr.out
DEPS_68 += $(CONFIG)/inc/pcre.h
DEPS_68 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_68 += $(CONFIG)/bin/libpcre.out
endif
DEPS_68 += $(CONFIG)/inc/http.h
DEPS_68 += $(CONFIG)/obj/httpLib.o
DEPS_68 += $(CONFIG)/bin/libhttp.out
DEPS_68 += $(CONFIG)/inc/appweb.h
DEPS_68 += $(CONFIG)/inc/customize.h
DEPS_68 += $(CONFIG)/obj/config.o
DEPS_68 += $(CONFIG)/obj/convenience.o
DEPS_68 += $(CONFIG)/obj/dirHandler.o
DEPS_68 += $(CONFIG)/obj/fileHandler.o
DEPS_68 += $(CONFIG)/obj/log.o
DEPS_68 += $(CONFIG)/obj/server.o
DEPS_68 += $(CONFIG)/bin/libappweb.out
DEPS_68 += $(CONFIG)/obj/cgiHandler.o

$(CONFIG)/bin/libmod_cgi.out: $(DEPS_68)
	@echo '      [Link] $(CONFIG)/bin/libmod_cgi.out'
	$(CC) -r -o $(CONFIG)/bin/libmod_cgi.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/cgiHandler.o" $(LIBS) 
endif

#
#   ejsHandler.o
#
DEPS_69 += $(CONFIG)/inc/bit.h
DEPS_69 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/ejsHandler.o: \
    src/modules/ejsHandler.c $(DEPS_69)
	@echo '   [Compile] $(CONFIG)/obj/ejsHandler.o'
	$(CC) -c -o $(CONFIG)/obj/ejsHandler.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/modules/ejsHandler.c

ifeq ($(BIT_PACK_EJSCRIPT),1)
#
#   libmod_ejs
#
DEPS_70 += $(CONFIG)/inc/mpr.h
DEPS_70 += $(CONFIG)/inc/bit.h
DEPS_70 += $(CONFIG)/inc/bitos.h
DEPS_70 += $(CONFIG)/obj/mprLib.o
DEPS_70 += $(CONFIG)/bin/libmpr.out
DEPS_70 += $(CONFIG)/inc/pcre.h
DEPS_70 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_70 += $(CONFIG)/bin/libpcre.out
endif
DEPS_70 += $(CONFIG)/inc/http.h
DEPS_70 += $(CONFIG)/obj/httpLib.o
DEPS_70 += $(CONFIG)/bin/libhttp.out
DEPS_70 += $(CONFIG)/inc/appweb.h
DEPS_70 += $(CONFIG)/inc/customize.h
DEPS_70 += $(CONFIG)/obj/config.o
DEPS_70 += $(CONFIG)/obj/convenience.o
DEPS_70 += $(CONFIG)/obj/dirHandler.o
DEPS_70 += $(CONFIG)/obj/fileHandler.o
DEPS_70 += $(CONFIG)/obj/log.o
DEPS_70 += $(CONFIG)/obj/server.o
DEPS_70 += $(CONFIG)/bin/libappweb.out
DEPS_70 += $(CONFIG)/inc/ejs.h
DEPS_70 += $(CONFIG)/inc/ejs.slots.h
DEPS_70 += $(CONFIG)/inc/ejsByteGoto.h
DEPS_70 += $(CONFIG)/obj/ejsLib.o
DEPS_70 += $(CONFIG)/bin/libejs.out
DEPS_70 += $(CONFIG)/obj/ejsHandler.o

$(CONFIG)/bin/libmod_ejs.out: $(DEPS_70)
	@echo '      [Link] $(CONFIG)/bin/libmod_ejs.out'
	$(CC) -r -o $(CONFIG)/bin/libmod_ejs.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/ejsHandler.o" $(LIBS) 
endif

#
#   phpHandler.o
#
DEPS_71 += $(CONFIG)/inc/bit.h
DEPS_71 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/phpHandler.o: \
    src/modules/phpHandler.c $(DEPS_71)
	@echo '   [Compile] $(CONFIG)/obj/phpHandler.o'
	$(CC) -c -o $(CONFIG)/obj/phpHandler.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(BIT_PACK_PHP_PATH)" "-I$(BIT_PACK_PHP_PATH)/main" "-I$(BIT_PACK_PHP_PATH)/Zend" "-I$(BIT_PACK_PHP_PATH)/TSRM" src/modules/phpHandler.c

ifeq ($(BIT_PACK_PHP),1)
#
#   libmod_php
#
DEPS_72 += $(CONFIG)/inc/mpr.h
DEPS_72 += $(CONFIG)/inc/bit.h
DEPS_72 += $(CONFIG)/inc/bitos.h
DEPS_72 += $(CONFIG)/obj/mprLib.o
DEPS_72 += $(CONFIG)/bin/libmpr.out
DEPS_72 += $(CONFIG)/inc/pcre.h
DEPS_72 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_72 += $(CONFIG)/bin/libpcre.out
endif
DEPS_72 += $(CONFIG)/inc/http.h
DEPS_72 += $(CONFIG)/obj/httpLib.o
DEPS_72 += $(CONFIG)/bin/libhttp.out
DEPS_72 += $(CONFIG)/inc/appweb.h
DEPS_72 += $(CONFIG)/inc/customize.h
DEPS_72 += $(CONFIG)/obj/config.o
DEPS_72 += $(CONFIG)/obj/convenience.o
DEPS_72 += $(CONFIG)/obj/dirHandler.o
DEPS_72 += $(CONFIG)/obj/fileHandler.o
DEPS_72 += $(CONFIG)/obj/log.o
DEPS_72 += $(CONFIG)/obj/server.o
DEPS_72 += $(CONFIG)/bin/libappweb.out
DEPS_72 += $(CONFIG)/obj/phpHandler.o

LIBS_72 += -lphp5
LIBPATHS_72 += -L$(BIT_PACK_PHP_PATH)/libs

$(CONFIG)/bin/libmod_php.out: $(DEPS_72)
	@echo '      [Link] $(CONFIG)/bin/libmod_php.out'
	$(CC) -r -o $(CONFIG)/bin/libmod_php.out $(LDFLAGS) $(LIBPATHS)  "$(CONFIG)/obj/phpHandler.o" $(LIBPATHS_72) $(LIBS_72) $(LIBS_72) $(LIBS) 
endif

#
#   sslModule.o
#
DEPS_73 += $(CONFIG)/inc/bit.h
DEPS_73 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/sslModule.o: \
    src/modules/sslModule.c $(DEPS_73)
	@echo '   [Compile] $(CONFIG)/obj/sslModule.o'
	$(CC) -c -o $(CONFIG)/obj/sslModule.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" "-I$(BIT_PACK_MATRIXSSL_PATH)" "-I$(BIT_PACK_MATRIXSSL_PATH)/matrixssl" "-I$(BIT_PACK_NANOSSL_PATH)/src" "-I$(BIT_PACK_OPENSSL_PATH)/include" src/modules/sslModule.c

ifeq ($(BIT_PACK_SSL),1)
#
#   libmod_ssl
#
DEPS_74 += $(CONFIG)/inc/mpr.h
DEPS_74 += $(CONFIG)/inc/bit.h
DEPS_74 += $(CONFIG)/inc/bitos.h
DEPS_74 += $(CONFIG)/obj/mprLib.o
DEPS_74 += $(CONFIG)/bin/libmpr.out
DEPS_74 += $(CONFIG)/inc/pcre.h
DEPS_74 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_74 += $(CONFIG)/bin/libpcre.out
endif
DEPS_74 += $(CONFIG)/inc/http.h
DEPS_74 += $(CONFIG)/obj/httpLib.o
DEPS_74 += $(CONFIG)/bin/libhttp.out
DEPS_74 += $(CONFIG)/inc/appweb.h
DEPS_74 += $(CONFIG)/inc/customize.h
DEPS_74 += $(CONFIG)/obj/config.o
DEPS_74 += $(CONFIG)/obj/convenience.o
DEPS_74 += $(CONFIG)/obj/dirHandler.o
DEPS_74 += $(CONFIG)/obj/fileHandler.o
DEPS_74 += $(CONFIG)/obj/log.o
DEPS_74 += $(CONFIG)/obj/server.o
DEPS_74 += $(CONFIG)/bin/libappweb.out
DEPS_74 += $(CONFIG)/inc/est.h
DEPS_74 += $(CONFIG)/obj/estLib.o
ifeq ($(BIT_PACK_EST),1)
    DEPS_74 += $(CONFIG)/bin/libest.out
endif
DEPS_74 += $(CONFIG)/obj/mprSsl.o
DEPS_74 += $(CONFIG)/bin/libmprssl.out
DEPS_74 += $(CONFIG)/obj/sslModule.o

ifeq ($(BIT_PACK_MATRIXSSL),1)
    LIBS_74 += -lmatrixssl
    LIBPATHS_74 += -L$(BIT_PACK_MATRIXSSL_PATH)
endif
ifeq ($(BIT_PACK_NANOSSL),1)
    LIBS_74 += -lssls
    LIBPATHS_74 += -L$(BIT_PACK_NANOSSL_PATH)/bin
endif
ifeq ($(BIT_PACK_OPENSSL),1)
    LIBS_74 += -lssl
    LIBPATHS_74 += -L$(BIT_PACK_OPENSSL_PATH)
endif
ifeq ($(BIT_PACK_OPENSSL),1)
    LIBS_74 += -lcrypto
    LIBPATHS_74 += -L$(BIT_PACK_OPENSSL_PATH)
endif

$(CONFIG)/bin/libmod_ssl.out: $(DEPS_74)
	@echo '      [Link] $(CONFIG)/bin/libmod_ssl.out'
	$(CC) -r -o $(CONFIG)/bin/libmod_ssl.out $(LDFLAGS) $(LIBPATHS)    "$(CONFIG)/obj/sslModule.o" $(LIBPATHS_74) $(LIBS_74) $(LIBS_74) $(LIBS) 
endif

#
#   authpass.o
#
DEPS_75 += $(CONFIG)/inc/bit.h
DEPS_75 += $(CONFIG)/inc/appweb.h

$(CONFIG)/obj/authpass.o: \
    src/utils/authpass.c $(DEPS_75)
	@echo '   [Compile] $(CONFIG)/obj/authpass.o'
	$(CC) -c -o $(CONFIG)/obj/authpass.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/utils/authpass.c

#
#   authpass
#
DEPS_76 += $(CONFIG)/inc/mpr.h
DEPS_76 += $(CONFIG)/inc/bit.h
DEPS_76 += $(CONFIG)/inc/bitos.h
DEPS_76 += $(CONFIG)/obj/mprLib.o
DEPS_76 += $(CONFIG)/bin/libmpr.out
DEPS_76 += $(CONFIG)/inc/pcre.h
DEPS_76 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_76 += $(CONFIG)/bin/libpcre.out
endif
DEPS_76 += $(CONFIG)/inc/http.h
DEPS_76 += $(CONFIG)/obj/httpLib.o
DEPS_76 += $(CONFIG)/bin/libhttp.out
DEPS_76 += $(CONFIG)/inc/appweb.h
DEPS_76 += $(CONFIG)/inc/customize.h
DEPS_76 += $(CONFIG)/obj/config.o
DEPS_76 += $(CONFIG)/obj/convenience.o
DEPS_76 += $(CONFIG)/obj/dirHandler.o
DEPS_76 += $(CONFIG)/obj/fileHandler.o
DEPS_76 += $(CONFIG)/obj/log.o
DEPS_76 += $(CONFIG)/obj/server.o
DEPS_76 += $(CONFIG)/bin/libappweb.out
DEPS_76 += $(CONFIG)/obj/authpass.o

$(CONFIG)/bin/authpass.out: $(DEPS_76)
	@echo '      [Link] $(CONFIG)/bin/authpass.out'
	$(CC) -o $(CONFIG)/bin/authpass.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/authpass.o" $(LIBS) -Wl,-r 

#
#   cgiProgram.o
#
DEPS_77 += $(CONFIG)/inc/bit.h

$(CONFIG)/obj/cgiProgram.o: \
    src/utils/cgiProgram.c $(DEPS_77)
	@echo '   [Compile] $(CONFIG)/obj/cgiProgram.o'
	$(CC) -c -o $(CONFIG)/obj/cgiProgram.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/utils/cgiProgram.c

ifeq ($(BIT_PACK_CGI),1)
#
#   cgiProgram
#
DEPS_78 += $(CONFIG)/inc/bit.h
DEPS_78 += $(CONFIG)/obj/cgiProgram.o

$(CONFIG)/bin/cgiProgram.out: $(DEPS_78)
	@echo '      [Link] $(CONFIG)/bin/cgiProgram.out'
	$(CC) -o $(CONFIG)/bin/cgiProgram.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/cgiProgram.o" $(LIBS) -Wl,-r 
endif

#
#   slink.c
#
src/server/slink.c: $(DEPS_79)
	cd src/server; [ ! -f slink.c ] && cp slink.empty slink.c ; true ; cd ../..

#
#   slink.o
#
DEPS_80 += $(CONFIG)/inc/bit.h
DEPS_80 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/slink.o: \
    src/server/slink.c $(DEPS_80)
	@echo '   [Compile] $(CONFIG)/obj/slink.o'
	$(CC) -c -o $(CONFIG)/obj/slink.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/server/slink.c

#
#   libslink
#
DEPS_81 += src/server/slink.c
DEPS_81 += $(CONFIG)/inc/bit.h
DEPS_81 += $(CONFIG)/inc/esp.h
DEPS_81 += $(CONFIG)/obj/slink.o

$(CONFIG)/bin/libslink.out: $(DEPS_81)
	@echo '      [Link] $(CONFIG)/bin/libslink.out'
	$(CC) -r -o $(CONFIG)/bin/libslink.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/slink.o" $(LIBS) 

#
#   appweb.o
#
DEPS_82 += $(CONFIG)/inc/bit.h
DEPS_82 += $(CONFIG)/inc/appweb.h
DEPS_82 += $(CONFIG)/inc/esp.h

$(CONFIG)/obj/appweb.o: \
    src/server/appweb.c $(DEPS_82)
	@echo '   [Compile] $(CONFIG)/obj/appweb.o'
	$(CC) -c -o $(CONFIG)/obj/appweb.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" src/server/appweb.c

#
#   appweb
#
DEPS_83 += $(CONFIG)/inc/mpr.h
DEPS_83 += $(CONFIG)/inc/bit.h
DEPS_83 += $(CONFIG)/inc/bitos.h
DEPS_83 += $(CONFIG)/obj/mprLib.o
DEPS_83 += $(CONFIG)/bin/libmpr.out
DEPS_83 += $(CONFIG)/inc/pcre.h
DEPS_83 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_83 += $(CONFIG)/bin/libpcre.out
endif
DEPS_83 += $(CONFIG)/inc/http.h
DEPS_83 += $(CONFIG)/obj/httpLib.o
DEPS_83 += $(CONFIG)/bin/libhttp.out
DEPS_83 += $(CONFIG)/inc/appweb.h
DEPS_83 += $(CONFIG)/inc/customize.h
DEPS_83 += $(CONFIG)/obj/config.o
DEPS_83 += $(CONFIG)/obj/convenience.o
DEPS_83 += $(CONFIG)/obj/dirHandler.o
DEPS_83 += $(CONFIG)/obj/fileHandler.o
DEPS_83 += $(CONFIG)/obj/log.o
DEPS_83 += $(CONFIG)/obj/server.o
DEPS_83 += $(CONFIG)/bin/libappweb.out
DEPS_83 += src/server/slink.c
DEPS_83 += $(CONFIG)/inc/esp.h
DEPS_83 += $(CONFIG)/obj/slink.o
DEPS_83 += $(CONFIG)/bin/libslink.out
DEPS_83 += $(CONFIG)/obj/appweb.o

$(CONFIG)/bin/appweb.out: $(DEPS_83)
	@echo '      [Link] $(CONFIG)/bin/appweb.out'
	$(CC) -o $(CONFIG)/bin/appweb.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/appweb.o" $(LIBS) -Wl,-r 

#
#   server-cache
#
src/server/cache: $(DEPS_84)
	cd src/server; mkdir -p cache ; cd ../..

#
#   testAppweb.h
#
$(CONFIG)/inc/testAppweb.h: $(DEPS_85)
	@echo '      [Copy] $(CONFIG)/inc/testAppweb.h'
	mkdir -p "$(CONFIG)/inc"
	cp test/src/testAppweb.h $(CONFIG)/inc/testAppweb.h

#
#   testAppweb.o
#
DEPS_86 += $(CONFIG)/inc/bit.h
DEPS_86 += $(CONFIG)/inc/testAppweb.h
DEPS_86 += $(CONFIG)/inc/mpr.h
DEPS_86 += $(CONFIG)/inc/http.h

$(CONFIG)/obj/testAppweb.o: \
    test/src/testAppweb.c $(DEPS_86)
	@echo '   [Compile] $(CONFIG)/obj/testAppweb.o'
	$(CC) -c -o $(CONFIG)/obj/testAppweb.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" test/src/testAppweb.c

#
#   testHttp.o
#
DEPS_87 += $(CONFIG)/inc/bit.h
DEPS_87 += $(CONFIG)/inc/testAppweb.h

$(CONFIG)/obj/testHttp.o: \
    test/src/testHttp.c $(DEPS_87)
	@echo '   [Compile] $(CONFIG)/obj/testHttp.o'
	$(CC) -c -o $(CONFIG)/obj/testHttp.o $(CFLAGS) $(DFLAGS) "-I$(CONFIG)/inc" "-I$(WIND_BASE)/target/h" "-I$(WIND_BASE)/target/h/wrn/coreip" test/src/testHttp.c

#
#   testAppweb
#
DEPS_88 += $(CONFIG)/inc/mpr.h
DEPS_88 += $(CONFIG)/inc/bit.h
DEPS_88 += $(CONFIG)/inc/bitos.h
DEPS_88 += $(CONFIG)/obj/mprLib.o
DEPS_88 += $(CONFIG)/bin/libmpr.out
DEPS_88 += $(CONFIG)/inc/pcre.h
DEPS_88 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_88 += $(CONFIG)/bin/libpcre.out
endif
DEPS_88 += $(CONFIG)/inc/http.h
DEPS_88 += $(CONFIG)/obj/httpLib.o
DEPS_88 += $(CONFIG)/bin/libhttp.out
DEPS_88 += $(CONFIG)/inc/appweb.h
DEPS_88 += $(CONFIG)/inc/customize.h
DEPS_88 += $(CONFIG)/obj/config.o
DEPS_88 += $(CONFIG)/obj/convenience.o
DEPS_88 += $(CONFIG)/obj/dirHandler.o
DEPS_88 += $(CONFIG)/obj/fileHandler.o
DEPS_88 += $(CONFIG)/obj/log.o
DEPS_88 += $(CONFIG)/obj/server.o
DEPS_88 += $(CONFIG)/bin/libappweb.out
DEPS_88 += $(CONFIG)/inc/testAppweb.h
DEPS_88 += $(CONFIG)/obj/testAppweb.o
DEPS_88 += $(CONFIG)/obj/testHttp.o

$(CONFIG)/bin/testAppweb.out: $(DEPS_88)
	@echo '      [Link] $(CONFIG)/bin/testAppweb.out'
	$(CC) -o $(CONFIG)/bin/testAppweb.out $(LDFLAGS) $(LIBPATHS) "$(CONFIG)/obj/testAppweb.o" "$(CONFIG)/obj/testHttp.o" $(LIBS) -Wl,-r 

ifeq ($(BIT_PACK_CGI),1)
#
#   test-testScript
#
DEPS_89 += $(CONFIG)/inc/mpr.h
DEPS_89 += $(CONFIG)/inc/bit.h
DEPS_89 += $(CONFIG)/inc/bitos.h
DEPS_89 += $(CONFIG)/obj/mprLib.o
DEPS_89 += $(CONFIG)/bin/libmpr.out
DEPS_89 += $(CONFIG)/inc/pcre.h
DEPS_89 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_89 += $(CONFIG)/bin/libpcre.out
endif
DEPS_89 += $(CONFIG)/inc/http.h
DEPS_89 += $(CONFIG)/obj/httpLib.o
DEPS_89 += $(CONFIG)/bin/libhttp.out
DEPS_89 += $(CONFIG)/inc/appweb.h
DEPS_89 += $(CONFIG)/inc/customize.h
DEPS_89 += $(CONFIG)/obj/config.o
DEPS_89 += $(CONFIG)/obj/convenience.o
DEPS_89 += $(CONFIG)/obj/dirHandler.o
DEPS_89 += $(CONFIG)/obj/fileHandler.o
DEPS_89 += $(CONFIG)/obj/log.o
DEPS_89 += $(CONFIG)/obj/server.o
DEPS_89 += $(CONFIG)/bin/libappweb.out
DEPS_89 += $(CONFIG)/inc/testAppweb.h
DEPS_89 += $(CONFIG)/obj/testAppweb.o
DEPS_89 += $(CONFIG)/obj/testHttp.o
DEPS_89 += $(CONFIG)/bin/testAppweb.out

test/cgi-bin/testScript: $(DEPS_89)
	cd test; echo '#!../$(CONFIG)/bin/cgiProgram.out' >cgi-bin/testScript ; chmod +x cgi-bin/testScript ; cd ..
endif

ifeq ($(BIT_PACK_CGI),1)
#
#   test-cache.cgi
#
DEPS_90 += $(CONFIG)/inc/mpr.h
DEPS_90 += $(CONFIG)/inc/bit.h
DEPS_90 += $(CONFIG)/inc/bitos.h
DEPS_90 += $(CONFIG)/obj/mprLib.o
DEPS_90 += $(CONFIG)/bin/libmpr.out
DEPS_90 += $(CONFIG)/inc/pcre.h
DEPS_90 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_90 += $(CONFIG)/bin/libpcre.out
endif
DEPS_90 += $(CONFIG)/inc/http.h
DEPS_90 += $(CONFIG)/obj/httpLib.o
DEPS_90 += $(CONFIG)/bin/libhttp.out
DEPS_90 += $(CONFIG)/inc/appweb.h
DEPS_90 += $(CONFIG)/inc/customize.h
DEPS_90 += $(CONFIG)/obj/config.o
DEPS_90 += $(CONFIG)/obj/convenience.o
DEPS_90 += $(CONFIG)/obj/dirHandler.o
DEPS_90 += $(CONFIG)/obj/fileHandler.o
DEPS_90 += $(CONFIG)/obj/log.o
DEPS_90 += $(CONFIG)/obj/server.o
DEPS_90 += $(CONFIG)/bin/libappweb.out
DEPS_90 += $(CONFIG)/inc/testAppweb.h
DEPS_90 += $(CONFIG)/obj/testAppweb.o
DEPS_90 += $(CONFIG)/obj/testHttp.o
DEPS_90 += $(CONFIG)/bin/testAppweb.out

test/web/caching/cache.cgi: $(DEPS_90)
	cd test; echo "#!`type -p ejs`" >web/caching/cache.cgi ; cd ..
	cd test; echo 'print("HTTP/1.0 200 OK\nContent-Type: text/plain\n\n" + Date() + "\n")' >>web/caching/cache.cgi ; cd ..
	cd test; chmod +x web/caching/cache.cgi ; cd ..
endif

ifeq ($(BIT_PACK_CGI),1)
#
#   test-basic.cgi
#
DEPS_91 += $(CONFIG)/inc/mpr.h
DEPS_91 += $(CONFIG)/inc/bit.h
DEPS_91 += $(CONFIG)/inc/bitos.h
DEPS_91 += $(CONFIG)/obj/mprLib.o
DEPS_91 += $(CONFIG)/bin/libmpr.out
DEPS_91 += $(CONFIG)/inc/pcre.h
DEPS_91 += $(CONFIG)/obj/pcre.o
ifeq ($(BIT_PACK_PCRE),1)
    DEPS_91 += $(CONFIG)/bin/libpcre.out
endif
DEPS_91 += $(CONFIG)/inc/http.h
DEPS_91 += $(CONFIG)/obj/httpLib.o
DEPS_91 += $(CONFIG)/bin/libhttp.out
DEPS_91 += $(CONFIG)/inc/appweb.h
DEPS_91 += $(CONFIG)/inc/customize.h
DEPS_91 += $(CONFIG)/obj/config.o
DEPS_91 += $(CONFIG)/obj/convenience.o
DEPS_91 += $(CONFIG)/obj/dirHandler.o
DEPS_91 += $(CONFIG)/obj/fileHandler.o
DEPS_91 += $(CONFIG)/obj/log.o
DEPS_91 += $(CONFIG)/obj/server.o
DEPS_91 += $(CONFIG)/bin/libappweb.out
DEPS_91 += $(CONFIG)/inc/testAppweb.h
DEPS_91 += $(CONFIG)/obj/testAppweb.o
DEPS_91 += $(CONFIG)/obj/testHttp.o
DEPS_91 += $(CONFIG)/bin/testAppweb.out

test/web/auth/basic/basic.cgi: $(DEPS_91)
	cd test; echo "#!`type -p ejs`" >web/auth/basic/basic.cgi ; cd ..
	cd test; echo 'print("HTTP/1.0 200 OK\nContent-Type: text/plain\n\n" + serialize(App.env, {pretty: true}) + "\n")' >>web/auth/basic/basic.cgi ; cd ..
	cd test; chmod +x web/auth/basic/basic.cgi ; cd ..
endif

ifeq ($(BIT_PACK_CGI),1)
#
#   test-cgiProgram
#
DEPS_92 += $(CONFIG)/inc/bit.h
DEPS_92 += $(CONFIG)/obj/cgiProgram.o
DEPS_92 += $(CONFIG)/bin/cgiProgram.out

test/cgi-bin/cgiProgram.out: $(DEPS_92)
	cd test; cp ../$(CONFIG)/bin/cgiProgram.out cgi-bin/cgiProgram.out ; cd ..
	cd test; cp ../$(CONFIG)/bin/cgiProgram.out cgi-bin/nph-cgiProgram.out ; cd ..
	cd test; cp ../$(CONFIG)/bin/cgiProgram.out 'cgi-bin/cgi Program.out' ; cd ..
	cd test; cp ../$(CONFIG)/bin/cgiProgram.out web/cgiProgram.cgi ; cd ..
	cd test; chmod +x cgi-bin/* web/cgiProgram.cgi ; cd ..
endif

#
#   installBinary
#
installBinary: $(DEPS_93)

#
#   install
#
DEPS_94 += compile
DEPS_94 += installBinary

install: $(DEPS_94)
	


#
#   uninstall
#
DEPS_95 += build
DEPS_95 += compile

uninstall: $(DEPS_95)
	rm -f "$(BIT_VAPP_PREFIX)/appweb.conf"
	rm -f "$(BIT_VAPP_PREFIX)/esp.conf"
	rm -f "$(BIT_VAPP_PREFIX)/mine.types"
	rm -f "$(BIT_VAPP_PREFIX)/install.conf"
	rm -fr "$(BIT_VAPP_PREFIX)/inc/appweb"

#
#   genslink
#
genslink: $(DEPS_96)
	cd src/server; esp --static --genlink slink.c --flat compile ; cd ../..


#
#   run
#
DEPS_97 += compile

run: $(DEPS_97)
	cd src/server; sudo ../../$(CONFIG)/bin/appweb -v ; cd ../..

