#
#   appweb-macosx-debug.sh -- Build It Shell Script to build Embedthis Appweb
#

PRODUCT="appweb"
VERSION="4.5.0-rc.1"
BUILD_NUMBER="0"
PROFILE="debug"
ARCH="x64"
ARCH="`uname -m | sed 's/i.86/x86/;s/x86_64/x64/;s/arm.*/arm/;s/mips.*/mips/'`"
OS="macosx"
CONFIG="${OS}-${ARCH}-${PROFILE}"
CC="/usr/bin/clang"
LD="/usr/bin/ld"
CFLAGS="-w"
DFLAGS="-DBIT_DEBUG"
IFLAGS="-I${CONFIG}/inc"
LDFLAGS="-g -Wl,-rpath,@executable_path/ -Wl,-rpath,@loader_path/"
LIBPATHS="-L${CONFIG}/bin"
LIBS="-ldl -lpthread -lm"

[ ! -x ${CONFIG}/inc ] && mkdir -p ${CONFIG}/inc

[ ! -x ${CONFIG}/bin ] && mkdir -p ${CONFIG}/bin

[ ! -x ${CONFIG}/obj ] && mkdir -p ${CONFIG}/obj

[ ! -f ${CONFIG}/inc/bitos.h ] && cp ${SRC}/src/bitos.h ${CONFIG}/inc/bitos.h
[ ! -f ${CONFIG}/inc/bit.h ] && cp projects/appweb-${OS}-${PROFILE}-bit.h ${CONFIG}/inc/bit.h
if ! diff ${CONFIG}/inc/bit.h projects/appweb-${OS}-${PROFILE}-bit.h >/dev/null ; then
	cp projects/appweb-${OS}-${PROFILE}-bit.h ${CONFIG}/inc/bit.h
fi


	echo 4.5.0-rc.1-0

	@echo '      [Copy] ${CONFIG}/inc/mpr.h'
	mkdir -p "${CONFIG}/inc"
	cp src/paks/mpr/mpr.h ${CONFIG}/inc/mpr.h

	@echo '      [Copy] ${CONFIG}/inc/bit.h'

	@echo '      [Copy] ${CONFIG}/inc/bitos.h'
	mkdir -p "${CONFIG}/inc"
	cp src/bitos.h ${CONFIG}/inc/bitos.h

${CC} -c -o ${CONFIG}/obj/mprLib.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/paks/mpr/mprLib.c

${CC} -dynamiclib -o ${CONFIG}/bin/libmpr.dylib -arch x86_64 ${LDFLAGS} ${LIBPATHS} -install_name @rpath/libmpr.dylib -compatibility_version 4.5.0 -current_version 4.5.0 "${CONFIG}/obj/mprLib.o" ${LIBS}

	@echo '      [Copy] ${CONFIG}/inc/est.h'
	mkdir -p "${CONFIG}/inc"
	cp src/paks/est/est.h ${CONFIG}/inc/est.h

${CC} -c -o ${CONFIG}/obj/estLib.o -arch $(CC_ARCH) ${DFLAGS} "${IFLAGS}" src/paks/est/estLib.c

ifeq ($(BIT_PACK_EST),1)
${CC} -dynamiclib -o ${CONFIG}/bin/libest.dylib -arch x86_64 ${LDFLAGS} ${LIBPATHS} -install_name @rpath/libest.dylib -compatibility_version 4.5.0 -current_version 4.5.0 "${CONFIG}/obj/estLib.o" ${LIBS}
endif

${CC} -c -o ${CONFIG}/obj/mprSsl.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/paks/mpr/mprSsl.c

${CC} -dynamiclib -o ${CONFIG}/bin/libmprssl.dylib -arch x86_64 ${LDFLAGS} ${LIBPATHS} -install_name @rpath/libmprssl.dylib -compatibility_version 4.5.0 -current_version 4.5.0 "${CONFIG}/obj/mprSsl.o" ${LIBS} -lmpr -lest

${CC} -c -o ${CONFIG}/obj/manager.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/paks/mpr/manager.c

${CC} -o ${CONFIG}/bin/appman -arch $(CC_ARCH) ${LDFLAGS} ${LIBPATHS} "${CONFIG}/obj/manager.o" ${LIBS} -lmpr

${CC} -c -o ${CONFIG}/obj/makerom.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/paks/mpr/makerom.c

${CC} -o ${CONFIG}/bin/makerom -arch $(CC_ARCH) ${LDFLAGS} ${LIBPATHS} "${CONFIG}/obj/makerom.o" ${LIBS} -lmpr

	@echo '      [Copy] ${CONFIG}/bin/ca.crt'
	mkdir -p "${CONFIG}/bin"
	cp src/paks/est/ca.crt ${CONFIG}/bin/ca.crt

	@echo '      [Copy] ${CONFIG}/inc/pcre.h'
	mkdir -p "${CONFIG}/inc"
	cp src/paks/pcre/pcre.h ${CONFIG}/inc/pcre.h

${CC} -c -o ${CONFIG}/obj/pcre.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/paks/pcre/pcre.c

ifeq ($(BIT_PACK_PCRE),1)
${CC} -dynamiclib -o ${CONFIG}/bin/libpcre.dylib -arch x86_64 ${LDFLAGS} -compatibility_version 4.5.0 -current_version 4.5.0 ${LIBPATHS} -install_name @rpath/libpcre.dylib -compatibility_version 4.5.0 -current_version 4.5.0 "${CONFIG}/obj/pcre.o" ${LIBS}
endif

	@echo '      [Copy] ${CONFIG}/inc/http.h'
	mkdir -p "${CONFIG}/inc"
	cp src/paks/http/http.h ${CONFIG}/inc/http.h

${CC} -c -o ${CONFIG}/obj/httpLib.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/paks/http/httpLib.c

${CC} -dynamiclib -o ${CONFIG}/bin/libhttp.dylib -arch x86_64 ${LDFLAGS} ${LIBPATHS} -install_name @rpath/libhttp.dylib -compatibility_version 4.5.0 -current_version 4.5.0 "${CONFIG}/obj/httpLib.o" ${LIBS} -lpam -lmpr -lpcre

${CC} -c -o ${CONFIG}/obj/http.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/paks/http/http.c

${CC} -o ${CONFIG}/bin/http -arch $(CC_ARCH) ${LDFLAGS} ${LIBPATHS} "${CONFIG}/obj/http.o" ${LIBS} -lhttp -lpam -lmpr -lpcre

	@echo '      [Copy] ${CONFIG}/inc/appweb.h'
	mkdir -p "${CONFIG}/inc"
	cp src/appweb.h ${CONFIG}/inc/appweb.h

	@echo '      [Copy] ${CONFIG}/inc/customize.h'
	mkdir -p "${CONFIG}/inc"
	cp src/customize.h ${CONFIG}/inc/customize.h

${CC} -c -o ${CONFIG}/obj/config.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/config.c

${CC} -c -o ${CONFIG}/obj/convenience.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/convenience.c

${CC} -c -o ${CONFIG}/obj/dirHandler.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/dirHandler.c

${CC} -c -o ${CONFIG}/obj/fileHandler.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/fileHandler.c

${CC} -c -o ${CONFIG}/obj/log.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/log.c

${CC} -c -o ${CONFIG}/obj/server.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/server.c

${CC} -dynamiclib -o ${CONFIG}/bin/libappweb.dylib -arch x86_64 ${LDFLAGS} ${LIBPATHS} -install_name @rpath/libappweb.dylib -compatibility_version 4.5.0 -current_version 4.5.0 "${CONFIG}/obj/config.o" "${CONFIG}/obj/convenience.o" "${CONFIG}/obj/dirHandler.o" "${CONFIG}/obj/fileHandler.o" "${CONFIG}/obj/log.o" "${CONFIG}/obj/server.o" ${LIBS} -lhttp -lpam -lmpr -lpcre

	@echo '      [Copy] ${CONFIG}/inc/edi.h'
	mkdir -p "${CONFIG}/inc"
	cp src/esp/edi.h ${CONFIG}/inc/edi.h

	@echo '      [Copy] ${CONFIG}/inc/esp.h'
	mkdir -p "${CONFIG}/inc"
	cp src/esp/esp.h ${CONFIG}/inc/esp.h

	@echo '      [Copy] ${CONFIG}/inc/mdb.h'
	mkdir -p "${CONFIG}/inc"
	cp src/esp/mdb.h ${CONFIG}/inc/mdb.h

${CC} -c -o ${CONFIG}/obj/edi.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/esp/edi.c

${CC} -c -o ${CONFIG}/obj/espAbbrev.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/esp/espAbbrev.c

${CC} -c -o ${CONFIG}/obj/espDeprecated.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/esp/espDeprecated.c

${CC} -c -o ${CONFIG}/obj/espFramework.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/esp/espFramework.c

${CC} -c -o ${CONFIG}/obj/espHandler.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/esp/espHandler.c

${CC} -c -o ${CONFIG}/obj/espHtml.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/esp/espHtml.c

${CC} -c -o ${CONFIG}/obj/espTemplate.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/esp/espTemplate.c

${CC} -c -o ${CONFIG}/obj/mdb.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/esp/mdb.c

${CC} -c -o ${CONFIG}/obj/sdb.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/esp/sdb.c

ifeq ($(BIT_PACK_ESP),1)
${CC} -dynamiclib -o ${CONFIG}/bin/libmod_esp.dylib -arch x86_64 ${LDFLAGS} ${LIBPATHS} -install_name @rpath/libmod_esp.dylib -compatibility_version 4.5.0 -current_version 4.5.0 "${CONFIG}/obj/edi.o" "${CONFIG}/obj/espAbbrev.o" "${CONFIG}/obj/espDeprecated.o" "${CONFIG}/obj/espFramework.o" "${CONFIG}/obj/espHandler.o" "${CONFIG}/obj/espHtml.o" "${CONFIG}/obj/espTemplate.o" "${CONFIG}/obj/mdb.o" "${CONFIG}/obj/sdb.o" ${LIBS} -lappweb -lhttp -lpam -lmpr -lpcre
endif

${CC} -c -o ${CONFIG}/obj/esp.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/esp/esp.c

ifeq ($(BIT_PACK_ESP),1)
${CC} -o ${CONFIG}/bin/esp -arch $(CC_ARCH) ${LDFLAGS} ${LIBPATHS} "${CONFIG}/obj/edi.o" "${CONFIG}/obj/esp.o" "${CONFIG}/obj/espAbbrev.o" "${CONFIG}/obj/espDeprecated.o" "${CONFIG}/obj/espFramework.o" "${CONFIG}/obj/espHandler.o" "${CONFIG}/obj/espHtml.o" "${CONFIG}/obj/espTemplate.o" "${CONFIG}/obj/mdb.o" "${CONFIG}/obj/sdb.o" ${LIBS} -lappweb -lhttp -lpam -lmpr -lpcre -lmod_esp
endif

ifeq ($(BIT_PACK_ESP),1)
	@echo '      [Copy] ${CONFIG}/bin/esp.conf'
	mkdir -p "${CONFIG}/bin"
	cp src/esp/esp.conf ${CONFIG}/bin/esp.conf
endif

ifeq ($(BIT_PACK_ESP),1)
	@echo '      [Copy] src/server/esp.conf'
	mkdir -p "src/server"
	cp src/esp/esp.conf src/server/esp.conf
endif

ifeq ($(BIT_PACK_ESP),1)
	cd src/esp/paks; mkdir -p "../../../${CONFIG}/paks/angular/1.2.6" ; 	cp angular/angular-animate.js ../../../${CONFIG}/paks/angular/1.2.6/angular-animate.js ; 	cp angular/angular-csp.css ../../../${CONFIG}/paks/angular/1.2.6/angular-csp.css ; 	cp angular/angular-route.js ../../../${CONFIG}/paks/angular/1.2.6/angular-route.js ; 	cp angular/angular.js ../../../${CONFIG}/paks/angular/1.2.6/angular.js ; 	cp angular/package.json ../../../${CONFIG}/paks/angular/1.2.6/package.json ; 	mkdir -p "../../../${CONFIG}/paks/esp-angular/4.5.0-rc.1" ; 	cp esp-angular/esp-click.js ../../../${CONFIG}/paks/esp-angular/4.5.0-rc.1/esp-click.js ; 	cp esp-angular/esp-field-errors.js ../../../${CONFIG}/paks/esp-angular/4.5.0-rc.1/esp-field-errors.js ; 	cp esp-angular/esp-format.js ../../../${CONFIG}/paks/esp-angular/4.5.0-rc.1/esp-format.js ; 	cp esp-angular/esp-input-group.js ../../../${CONFIG}/paks/esp-angular/4.5.0-rc.1/esp-input-group.js ; 	cp esp-angular/esp-input.js ../../../${CONFIG}/paks/esp-angular/4.5.0-rc.1/esp-input.js ; 	cp esp-angular/esp-resource.js ../../../${CONFIG}/paks/esp-angular/4.5.0-rc.1/esp-resource.js ; 	cp esp-angular/esp-session.js ../../../${CONFIG}/paks/esp-angular/4.5.0-rc.1/esp-session.js ; 	cp esp-angular/esp-titlecase.js ../../../${CONFIG}/paks/esp-angular/4.5.0-rc.1/esp-titlecase.js ; 	cp esp-angular/esp.js ../../../${CONFIG}/paks/esp-angular/4.5.0-rc.1/esp.js ; 	cp esp-angular/package.json ../../../${CONFIG}/paks/esp-angular/4.5.0-rc.1/package.json ; 	mkdir -p "../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1" ; 	cp esp-angular-mvc/package.json ../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/package.json ; 	mkdir -p "../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/templates" ; 	mkdir -p "../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/templates/esp-angular-mvc" ; 	cp esp-angular-mvc/templates/esp-angular-mvc/appweb.conf ../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/templates/esp-angular-mvc/appweb.conf ; 	mkdir -p "../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/templates/esp-angular-mvc/client" ; 	mkdir -p "../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/templates/esp-angular-mvc/client/app" ; 	cp esp-angular-mvc/templates/esp-angular-mvc/client/app/main.js ../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/templates/esp-angular-mvc/client/app/main.js ; 	mkdir -p "../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/templates/esp-angular-mvc/client/assets" ; 	cp esp-angular-mvc/templates/esp-angular-mvc/client/assets/favicon.ico ../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/templates/esp-angular-mvc/client/assets/favicon.ico ; 	mkdir -p "../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/templates/esp-angular-mvc/client/css" ; 	cp esp-angular-mvc/templates/esp-angular-mvc/client/css/all.css ../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/templates/esp-angular-mvc/client/css/all.css ; 	cp esp-angular-mvc/templates/esp-angular-mvc/client/css/all.less ../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/templates/esp-angular-mvc/client/css/all.less ; 	cp esp-angular-mvc/templates/esp-angular-mvc/client/css/app.less ../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/templates/esp-angular-mvc/client/css/app.less ; 	cp esp-angular-mvc/templates/esp-angular-mvc/client/css/fix.css ../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/templates/esp-angular-mvc/client/css/fix.css ; 	cp esp-angular-mvc/templates/esp-angular-mvc/client/css/theme.less ../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/templates/esp-angular-mvc/client/css/theme.less ; 	cp esp-angular-mvc/templates/esp-angular-mvc/client/index.esp ../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/templates/esp-angular-mvc/client/index.esp ; 	mkdir -p "../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/templates/esp-angular-mvc/client/pages" ; 	cp esp-angular-mvc/templates/esp-angular-mvc/client/pages/splash.html ../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/templates/esp-angular-mvc/client/pages/splash.html ; 	cp esp-angular-mvc/templates/esp-angular-mvc/controller-singleton.c ../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/templates/esp-angular-mvc/controller-singleton.c ; 	cp esp-angular-mvc/templates/esp-angular-mvc/controller.c ../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/templates/esp-angular-mvc/controller.c ; 	cp esp-angular-mvc/templates/esp-angular-mvc/controller.js ../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/templates/esp-angular-mvc/controller.js ; 	cp esp-angular-mvc/templates/esp-angular-mvc/edit.html ../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/templates/esp-angular-mvc/edit.html ; 	cp esp-angular-mvc/templates/esp-angular-mvc/list.html ../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/templates/esp-angular-mvc/list.html ; 	cp esp-angular-mvc/templates/esp-angular-mvc/model.js ../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/templates/esp-angular-mvc/model.js ; 	cp esp-angular-mvc/templates/esp-angular-mvc/start.bit ../../../${CONFIG}/paks/esp-angular-mvc/4.5.0-rc.1/templates/esp-angular-mvc/start.bit ; 	mkdir -p "../../../${CONFIG}/paks/esp-html-mvc/4.5.0-rc.1" ; 	cp esp-html-mvc/package.json ../../../${CONFIG}/paks/esp-html-mvc/4.5.0-rc.1/package.json ; 	mkdir -p "../../../${CONFIG}/paks/esp-html-mvc/4.5.0-rc.1/templates" ; 	mkdir -p "../../../${CONFIG}/paks/esp-html-mvc/4.5.0-rc.1/templates/esp-html-mvc" ; 	cp esp-html-mvc/templates/esp-html-mvc/appweb.conf ../../../${CONFIG}/paks/esp-html-mvc/4.5.0-rc.1/templates/esp-html-mvc/appweb.conf ; 	mkdir -p "../../../${CONFIG}/paks/esp-html-mvc/4.5.0-rc.1/templates/esp-html-mvc/client" ; 	mkdir -p "../../../${CONFIG}/paks/esp-html-mvc/4.5.0-rc.1/templates/esp-html-mvc/client/assets" ; 	cp esp-html-mvc/templates/esp-html-mvc/client/assets/favicon.ico ../../../${CONFIG}/paks/esp-html-mvc/4.5.0-rc.1/templates/esp-html-mvc/client/assets/favicon.ico ; 	mkdir -p "../../../${CONFIG}/paks/esp-html-mvc/4.5.0-rc.1/templates/esp-html-mvc/client/css" ; 	cp esp-html-mvc/templates/esp-html-mvc/client/css/all.css ../../../${CONFIG}/paks/esp-html-mvc/4.5.0-rc.1/templates/esp-html-mvc/client/css/all.css ; 	cp esp-html-mvc/templates/esp-html-mvc/client/css/all.less ../../../${CONFIG}/paks/esp-html-mvc/4.5.0-rc.1/templates/esp-html-mvc/client/css/all.less ; 	cp esp-html-mvc/templates/esp-html-mvc/client/css/app.less ../../../${CONFIG}/paks/esp-html-mvc/4.5.0-rc.1/templates/esp-html-mvc/client/css/app.less ; 	cp esp-html-mvc/templates/esp-html-mvc/client/css/theme.less ../../../${CONFIG}/paks/esp-html-mvc/4.5.0-rc.1/templates/esp-html-mvc/client/css/theme.less ; 	cp esp-html-mvc/templates/esp-html-mvc/client/index.esp ../../../${CONFIG}/paks/esp-html-mvc/4.5.0-rc.1/templates/esp-html-mvc/client/index.esp ; 	mkdir -p "../../../${CONFIG}/paks/esp-html-mvc/4.5.0-rc.1/templates/esp-html-mvc/client/layouts" ; 	cp esp-html-mvc/templates/esp-html-mvc/client/layouts/default.esp ../../../${CONFIG}/paks/esp-html-mvc/4.5.0-rc.1/templates/esp-html-mvc/client/layouts/default.esp ; 	cp esp-html-mvc/templates/esp-html-mvc/controller-singleton.c ../../../${CONFIG}/paks/esp-html-mvc/4.5.0-rc.1/templates/esp-html-mvc/controller-singleton.c ; 	cp esp-html-mvc/templates/esp-html-mvc/controller.c ../../../${CONFIG}/paks/esp-html-mvc/4.5.0-rc.1/templates/esp-html-mvc/controller.c ; 	cp esp-html-mvc/templates/esp-html-mvc/edit.esp ../../../${CONFIG}/paks/esp-html-mvc/4.5.0-rc.1/templates/esp-html-mvc/edit.esp ; 	cp esp-html-mvc/templates/esp-html-mvc/list.esp ../../../${CONFIG}/paks/esp-html-mvc/4.5.0-rc.1/templates/esp-html-mvc/list.esp ; 	cp esp-html-mvc/templates/esp-html-mvc/start.bit ../../../${CONFIG}/paks/esp-html-mvc/4.5.0-rc.1/templates/esp-html-mvc/start.bit ; 	mkdir -p "../../../${CONFIG}/paks/esp-legacy-mvc/4.5.0-rc.1" ; 	cp esp-legacy-mvc/package.json ../../../${CONFIG}/paks/esp-legacy-mvc/4.5.0-rc.1/package.json ; 	mkdir -p "../../../${CONFIG}/paks/esp-legacy-mvc/4.5.0-rc.1/templates" ; 	mkdir -p "../../../${CONFIG}/paks/esp-legacy-mvc/4.5.0-rc.1/templates/esp-legacy-mvc" ; 	cp esp-legacy-mvc/templates/esp-legacy-mvc/controller.c ../../../${CONFIG}/paks/esp-legacy-mvc/4.5.0-rc.1/templates/esp-legacy-mvc/controller.c ; 	cp esp-legacy-mvc/templates/esp-legacy-mvc/edit.esp ../../../${CONFIG}/paks/esp-legacy-mvc/4.5.0-rc.1/templates/esp-legacy-mvc/edit.esp ; 	mkdir -p "../../../${CONFIG}/paks/esp-legacy-mvc/4.5.0-rc.1/templates/esp-legacy-mvc/layouts" ; 	cp esp-legacy-mvc/templates/esp-legacy-mvc/layouts/default.esp ../../../${CONFIG}/paks/esp-legacy-mvc/4.5.0-rc.1/templates/esp-legacy-mvc/layouts/default.esp ; 	cp esp-legacy-mvc/templates/esp-legacy-mvc/list.esp ../../../${CONFIG}/paks/esp-legacy-mvc/4.5.0-rc.1/templates/esp-legacy-mvc/list.esp ; 	mkdir -p "../../../${CONFIG}/paks/esp-legacy-mvc/4.5.0-rc.1/templates/esp-legacy-mvc/static" ; 	mkdir -p "../../../${CONFIG}/paks/esp-legacy-mvc/4.5.0-rc.1/templates/esp-legacy-mvc/static/css" ; 	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/css/all.css ../../../${CONFIG}/paks/esp-legacy-mvc/4.5.0-rc.1/templates/esp-legacy-mvc/static/css/all.css ; 	mkdir -p "../../../${CONFIG}/paks/esp-legacy-mvc/4.5.0-rc.1/templates/esp-legacy-mvc/static/images" ; 	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/images/banner.jpg ../../../${CONFIG}/paks/esp-legacy-mvc/4.5.0-rc.1/templates/esp-legacy-mvc/static/images/banner.jpg ; 	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/images/favicon.ico ../../../${CONFIG}/paks/esp-legacy-mvc/4.5.0-rc.1/templates/esp-legacy-mvc/static/images/favicon.ico ; 	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/images/splash.jpg ../../../${CONFIG}/paks/esp-legacy-mvc/4.5.0-rc.1/templates/esp-legacy-mvc/static/images/splash.jpg ; 	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/index.esp ../../../${CONFIG}/paks/esp-legacy-mvc/4.5.0-rc.1/templates/esp-legacy-mvc/static/index.esp ; 	mkdir -p "../../../${CONFIG}/paks/esp-legacy-mvc/4.5.0-rc.1/templates/esp-legacy-mvc/static/js" ; 	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/js/jquery.esp.js ../../../${CONFIG}/paks/esp-legacy-mvc/4.5.0-rc.1/templates/esp-legacy-mvc/static/js/jquery.esp.js ; 	cp esp-legacy-mvc/templates/esp-legacy-mvc/static/js/jquery.js ../../../${CONFIG}/paks/esp-legacy-mvc/4.5.0-rc.1/templates/esp-legacy-mvc/static/js/jquery.js ; 	mkdir -p "../../../${CONFIG}/paks/esp-server/4.5.0-rc.1" ; 	cp esp-server/package.json ../../../${CONFIG}/paks/esp-server/4.5.0-rc.1/package.json ; 	mkdir -p "../../../${CONFIG}/paks/esp-server/4.5.0-rc.1/templates" ; 	mkdir -p "../../../${CONFIG}/paks/esp-server/4.5.0-rc.1/templates/esp-server" ; 	cp esp-server/templates/esp-server/appweb.conf ../../../${CONFIG}/paks/esp-server/4.5.0-rc.1/templates/esp-server/appweb.conf ; 	cp esp-server/templates/esp-server/controller.c ../../../${CONFIG}/paks/esp-server/4.5.0-rc.1/templates/esp-server/controller.c ; 	cp esp-server/templates/esp-server/migration.c ../../../${CONFIG}/paks/esp-server/4.5.0-rc.1/templates/esp-server/migration.c ; 	mkdir -p "../../../${CONFIG}/paks/esp-server/4.5.0-rc.1/templates/esp-server/src" ; 	cp esp-server/templates/esp-server/src/app.c ../../../${CONFIG}/paks/esp-server/4.5.0-rc.1/templates/esp-server/src/app.c ; cd ../../..
endif


${CC} -c -o ${CONFIG}/obj/cgiHandler.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/modules/cgiHandler.c

ifeq ($(BIT_PACK_CGI),1)
${CC} -dynamiclib -o ${CONFIG}/bin/libmod_cgi.dylib -arch x86_64 ${LDFLAGS} ${LIBPATHS} -install_name @rpath/libmod_cgi.dylib -compatibility_version 4.5.0 -current_version 4.5.0 "${CONFIG}/obj/cgiHandler.o" ${LIBS} -lappweb -lhttp -lpam -lmpr -lpcre
endif

${CC} -c -o ${CONFIG}/obj/sslModule.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/modules/sslModule.c

ifeq ($(BIT_PACK_SSL),1)
${CC} -dynamiclib -o ${CONFIG}/bin/libmod_ssl.dylib -arch x86_64 ${LDFLAGS} ${LIBPATHS} -install_name @rpath/libmod_ssl.dylib -compatibility_version 4.5.0 -current_version 4.5.0 "${CONFIG}/obj/sslModule.o" ${LIBS} -lappweb -lhttp -lpam -lmpr -lpcre -lmprssl -lest
endif

${CC} -c -o ${CONFIG}/obj/authpass.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/utils/authpass.c

${CC} -o ${CONFIG}/bin/authpass -arch $(CC_ARCH) ${LDFLAGS} ${LIBPATHS} "${CONFIG}/obj/authpass.o" ${LIBS} -lappweb -lhttp -lpam -lmpr -lpcre

${CC} -c -o ${CONFIG}/obj/cgiProgram.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/utils/cgiProgram.c

ifeq ($(BIT_PACK_CGI),1)
${CC} -o ${CONFIG}/bin/cgiProgram -arch $(CC_ARCH) ${LDFLAGS} ${LIBPATHS} "${CONFIG}/obj/cgiProgram.o" ${LIBS}
endif

	cd src/server; [ ! -f slink.c ] && cp slink.empty slink.c ; true ; cd ../..

${CC} -c -o ${CONFIG}/obj/slink.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/server/slink.c

${CC} -dynamiclib -o ${CONFIG}/bin/libslink.dylib -arch x86_64 ${LDFLAGS} ${LIBPATHS} -install_name @rpath/libslink.dylib -compatibility_version 4.5.0 -current_version 4.5.0 "${CONFIG}/obj/slink.o" ${LIBS}

${CC} -c -o ${CONFIG}/obj/appweb.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" src/server/appweb.c

${CC} -o ${CONFIG}/bin/appweb -arch $(CC_ARCH) ${LDFLAGS} ${LIBPATHS} "${CONFIG}/obj/appweb.o" ${LIBS} -lappweb -lhttp -lpam -lmpr -lpcre -lslink

	cd src/server; mkdir -p cache ; cd ../..

	@echo '      [Copy] ${CONFIG}/inc/testAppweb.h'

${CC} -c -o ${CONFIG}/obj/testAppweb.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" test/src/testAppweb.c

${CC} -c -o ${CONFIG}/obj/testHttp.o -arch $(CC_ARCH) ${CFLAGS} ${DFLAGS} "${IFLAGS}" test/src/testHttp.c

${CC} -o ${CONFIG}/bin/testAppweb -arch $(CC_ARCH) ${LDFLAGS} ${LIBPATHS} "${CONFIG}/obj/testAppweb.o" "${CONFIG}/obj/testHttp.o" ${LIBS} -lappweb -lhttp -lpam -lmpr -lpcre

ifeq ($(BIT_PACK_CGI),1)
	cd test; echo '#!../${CONFIG}/bin/cgiProgram' >cgi-bin/testScript ; chmod +x cgi-bin/testScript ; cd ..
endif

ifeq ($(BIT_PACK_CGI),1)
	cd test; echo "#!`type -p ejs`" >web/caching/cache.cgi ;                 echo 'print("HTTP/1.0 200 OK\nContent-Type: text/plain\n\n{number:" + Date().now() + "}\n")' >>web/caching/cache.cgi ;                 chmod +x web/caching/cache.cgi ; cd ..
endif

ifeq ($(BIT_PACK_CGI),1)
	cd test; echo "#!`type -p ejs`" >web/auth/basic/basic.cgi ;                 echo 'print("HTTP/1.0 200 OK\nContent-Type: text/plain\n\n" + serialize(App.env, {pretty: true}) + "\n")' >>web/auth/basic/basic.cgi ;                 chmod +x web/auth/basic/basic.cgi ; cd ..
endif

ifeq ($(BIT_PACK_CGI),1)
	cd test; cp ../${CONFIG}/bin/cgiProgram cgi-bin/cgiProgram ;                 cp ../${CONFIG}/bin/cgiProgram cgi-bin/nph-cgiProgram ;                 cp ../${CONFIG}/bin/cgiProgram 'cgi-bin/cgi Program' ;                 cp ../${CONFIG}/bin/cgiProgram web/cgiProgram.cgi ;                 chmod +x cgi-bin/* web/cgiProgram.cgi ; cd ..
endif


	@cd .; ./${CONFIG}/bin/appman stop disable uninstall >/dev/null 2>&1 ; true ; cd .

	cd .; mkdir -p "$(BIT_APP_PREFIX)" ; 	rm -f "$(BIT_APP_PREFIX)/latest" ; 	ln -s "4.5.0-rc.1" "$(BIT_APP_PREFIX)/latest" ; 	mkdir -p "$(BIT_LOG_PREFIX)" ; 	chmod 755 "$(BIT_LOG_PREFIX)" ; 	[ `id -u` = 0 ] && chown $(WEB_USER):$(WEB_GROUP) "$(BIT_LOG_PREFIX)"; true ; 	mkdir -p "$(BIT_CACHE_PREFIX)" ; 	chmod 755 "$(BIT_CACHE_PREFIX)" ; 	[ `id -u` = 0 ] && chown $(WEB_USER):$(WEB_GROUP) "$(BIT_CACHE_PREFIX)"; true ; 	mkdir -p "$(BIT_VAPP_PREFIX)/bin" ; 	cp ${CONFIG}/bin/appweb $(BIT_VAPP_PREFIX)/bin/appweb ; 	mkdir -p "$(BIT_BIN_PREFIX)" ; 	rm -f "$(BIT_BIN_PREFIX)/appweb" ; 	ln -s "$(BIT_VAPP_PREFIX)/bin/appweb" "$(BIT_BIN_PREFIX)/appweb" ; 	cp ${CONFIG}/bin/appman $(BIT_VAPP_PREFIX)/bin/appman ; 	rm -f "$(BIT_BIN_PREFIX)/appman" ; 	ln -s "$(BIT_VAPP_PREFIX)/bin/appman" "$(BIT_BIN_PREFIX)/appman" ; 	cp ${CONFIG}/bin/http $(BIT_VAPP_PREFIX)/bin/http ; 	rm -f "$(BIT_BIN_PREFIX)/http" ; 	ln -s "$(BIT_VAPP_PREFIX)/bin/http" "$(BIT_BIN_PREFIX)/http" ; 	if [ "$(BIT_PACK_ESP)" = 1 ]; then true  ; 	cp ${CONFIG}/bin/esp $(BIT_VAPP_PREFIX)/bin/esp ; 	rm -f "$(BIT_BIN_PREFIX)/esp" ; 	ln -s "$(BIT_VAPP_PREFIX)/bin/esp" "$(BIT_BIN_PREFIX)/esp" ; 	fi ; 	cp ${CONFIG}/bin/libappweb.dylib $(BIT_VAPP_PREFIX)/bin/libappweb.dylib ; 	cp ${CONFIG}/bin/libhttp.dylib $(BIT_VAPP_PREFIX)/bin/libhttp.dylib ; 	cp ${CONFIG}/bin/libmpr.dylib $(BIT_VAPP_PREFIX)/bin/libmpr.dylib ; 	cp ${CONFIG}/bin/libpcre.dylib $(BIT_VAPP_PREFIX)/bin/libpcre.dylib ; 	cp ${CONFIG}/bin/libslink.dylib $(BIT_VAPP_PREFIX)/bin/libslink.dylib ; 	if [ "$(BIT_PACK_SSL)" = 1 ]; then true  ; 	cp ${CONFIG}/bin/libmprssl.dylib $(BIT_VAPP_PREFIX)/bin/libmprssl.dylib ; 	cp ${CONFIG}/bin/libmod_ssl.dylib $(BIT_VAPP_PREFIX)/bin/libmod_ssl.dylib ; 	fi ; 	if [ "$(BIT_PACK_SSL)" = 1 ]; then true  ; 	cp ${CONFIG}/bin/ca.crt $(BIT_VAPP_PREFIX)/bin/ca.crt ; 	fi ; 	if [ "$(BIT_PACK_OPENSSL)" = 1 ]; then true  ; 	cp ${CONFIG}/bin/libssl.0.9.7.dylib $(BIT_VAPP_PREFIX)/bin/libssl.0.9.7.dylib ; 	cp ${CONFIG}/bin/libssl.0.9.8.dylib $(BIT_VAPP_PREFIX)/bin/libssl.0.9.8.dylib ; 	cp ${CONFIG}/bin/libssl.1.0.0.dylib $(BIT_VAPP_PREFIX)/bin/libssl.1.0.0.dylib ; 	cp ${CONFIG}/bin/libssl.dylib $(BIT_VAPP_PREFIX)/bin/libssl.dylib ; 	cp ${CONFIG}/bin/libcrypto.0.9.7.dylib $(BIT_VAPP_PREFIX)/bin/libcrypto.0.9.7.dylib ; 	cp ${CONFIG}/bin/libcrypto.0.9.8.dylib $(BIT_VAPP_PREFIX)/bin/libcrypto.0.9.8.dylib ; 	cp ${CONFIG}/bin/libcrypto.1.0.0.dylib $(BIT_VAPP_PREFIX)/bin/libcrypto.1.0.0.dylib ; 	cp ${CONFIG}/bin/libcrypto.dylib $(BIT_VAPP_PREFIX)/bin/libcrypto.dylib ; 	fi ; 	if [ "$(BIT_PACK_EST)" = 1 ]; then true  ; 	cp ${CONFIG}/bin/libest.dylib $(BIT_VAPP_PREFIX)/bin/libest.dylib ; 	fi ; 	if [ "$(BIT_PACK_SQLITE)" = 1 ]; then true  ; 	cp ${CONFIG}/bin/libsql.dylib $(BIT_VAPP_PREFIX)/bin/libsql.dylib ; 	fi ; 	if [ "$(BIT_PACK_ESP)" = 1 ]; then true  ; 	cp ${CONFIG}/bin/libmod_esp.dylib $(BIT_VAPP_PREFIX)/bin/libmod_esp.dylib ; 	fi ; 	if [ "$(BIT_PACK_CGI)" = 1 ]; then true  ; 	cp ${CONFIG}/bin/libmod_cgi.dylib $(BIT_VAPP_PREFIX)/bin/libmod_cgi.dylib ; 	fi ; 	if [ "$(BIT_PACK_EJSCRIPT)" = 1 ]; then true  ; 	cp ${CONFIG}/bin/libejs.dylib $(BIT_VAPP_PREFIX)/bin/libejs.dylib ; 	cp ${CONFIG}/bin/libmod_ejs.dylib $(BIT_VAPP_PREFIX)/bin/libmod_ejs.dylib ; 	fi ; 	if [ "$(BIT_PACK_PHP)" = 1 ]; then true  ; 	cp ${CONFIG}/bin/libmod_php.dylib $(BIT_VAPP_PREFIX)/bin/libmod_php.dylib ; 	fi ; 	if [ "$(BIT_PACK_PHP)" = 1 ]; then true  ; 	cp ${CONFIG}/bin/libphp5.dylib $(BIT_VAPP_PREFIX)/bin/libphp5.dylib ; 	fi ; 	if [ "$(BIT_PACK_ESP)" = 1 ]; then true  ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/angular" ; 	cp src/esp/paks/angular/angular-animate.js $(BIT_VAPP_PREFIX)/esp/angular/angular-animate.js ; 	cp src/esp/paks/angular/angular-csp.css $(BIT_VAPP_PREFIX)/esp/angular/angular-csp.css ; 	cp src/esp/paks/angular/angular-route.js $(BIT_VAPP_PREFIX)/esp/angular/angular-route.js ; 	cp src/esp/paks/angular/angular.js $(BIT_VAPP_PREFIX)/esp/angular/angular.js ; 	cp src/esp/paks/angular/package.json $(BIT_VAPP_PREFIX)/esp/angular/package.json ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/esp-angular" ; 	cp src/esp/paks/esp-angular/esp-click.js $(BIT_VAPP_PREFIX)/esp/esp-angular/esp-click.js ; 	cp src/esp/paks/esp-angular/esp-field-errors.js $(BIT_VAPP_PREFIX)/esp/esp-angular/esp-field-errors.js ; 	cp src/esp/paks/esp-angular/esp-format.js $(BIT_VAPP_PREFIX)/esp/esp-angular/esp-format.js ; 	cp src/esp/paks/esp-angular/esp-input-group.js $(BIT_VAPP_PREFIX)/esp/esp-angular/esp-input-group.js ; 	cp src/esp/paks/esp-angular/esp-input.js $(BIT_VAPP_PREFIX)/esp/esp-angular/esp-input.js ; 	cp src/esp/paks/esp-angular/esp-resource.js $(BIT_VAPP_PREFIX)/esp/esp-angular/esp-resource.js ; 	cp src/esp/paks/esp-angular/esp-session.js $(BIT_VAPP_PREFIX)/esp/esp-angular/esp-session.js ; 	cp src/esp/paks/esp-angular/esp-titlecase.js $(BIT_VAPP_PREFIX)/esp/esp-angular/esp-titlecase.js ; 	cp src/esp/paks/esp-angular/esp.js $(BIT_VAPP_PREFIX)/esp/esp-angular/esp.js ; 	cp src/esp/paks/esp-angular/package.json $(BIT_VAPP_PREFIX)/esp/esp-angular/package.json ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/esp-angular-mvc" ; 	cp src/esp/paks/esp-angular-mvc/package.json $(BIT_VAPP_PREFIX)/esp/esp-angular-mvc/package.json ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/esp-angular-mvc/templates/esp-angular-mvc" ; 	cp src/esp/paks/esp-angular-mvc/templates/esp-angular-mvc/appweb.conf $(BIT_VAPP_PREFIX)/esp/esp-angular-mvc/templates/esp-angular-mvc/appweb.conf ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/esp-angular-mvc/templates/esp-angular-mvc/client/app" ; 	cp src/esp/paks/esp-angular-mvc/templates/esp-angular-mvc/client/app/main.js $(BIT_VAPP_PREFIX)/esp/esp-angular-mvc/templates/esp-angular-mvc/client/app/main.js ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/esp-angular-mvc/templates/esp-angular-mvc/client/assets" ; 	cp src/esp/paks/esp-angular-mvc/templates/esp-angular-mvc/client/assets/favicon.ico $(BIT_VAPP_PREFIX)/esp/esp-angular-mvc/templates/esp-angular-mvc/client/assets/favicon.ico ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/esp-angular-mvc/templates/esp-angular-mvc/client/css" ; 	cp src/esp/paks/esp-angular-mvc/templates/esp-angular-mvc/client/css/all.css $(BIT_VAPP_PREFIX)/esp/esp-angular-mvc/templates/esp-angular-mvc/client/css/all.css ; 	cp src/esp/paks/esp-angular-mvc/templates/esp-angular-mvc/client/css/all.less $(BIT_VAPP_PREFIX)/esp/esp-angular-mvc/templates/esp-angular-mvc/client/css/all.less ; 	cp src/esp/paks/esp-angular-mvc/templates/esp-angular-mvc/client/css/app.less $(BIT_VAPP_PREFIX)/esp/esp-angular-mvc/templates/esp-angular-mvc/client/css/app.less ; 	cp src/esp/paks/esp-angular-mvc/templates/esp-angular-mvc/client/css/fix.css $(BIT_VAPP_PREFIX)/esp/esp-angular-mvc/templates/esp-angular-mvc/client/css/fix.css ; 	cp src/esp/paks/esp-angular-mvc/templates/esp-angular-mvc/client/css/theme.less $(BIT_VAPP_PREFIX)/esp/esp-angular-mvc/templates/esp-angular-mvc/client/css/theme.less ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/esp-angular-mvc/templates/esp-angular-mvc/client" ; 	cp src/esp/paks/esp-angular-mvc/templates/esp-angular-mvc/client/index.esp $(BIT_VAPP_PREFIX)/esp/esp-angular-mvc/templates/esp-angular-mvc/client/index.esp ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/esp-angular-mvc/templates/esp-angular-mvc/client/pages" ; 	cp src/esp/paks/esp-angular-mvc/templates/esp-angular-mvc/client/pages/splash.html $(BIT_VAPP_PREFIX)/esp/esp-angular-mvc/templates/esp-angular-mvc/client/pages/splash.html ; 	cp src/esp/paks/esp-angular-mvc/templates/esp-angular-mvc/controller-singleton.c $(BIT_VAPP_PREFIX)/esp/esp-angular-mvc/templates/esp-angular-mvc/controller-singleton.c ; 	cp src/esp/paks/esp-angular-mvc/templates/esp-angular-mvc/controller.c $(BIT_VAPP_PREFIX)/esp/esp-angular-mvc/templates/esp-angular-mvc/controller.c ; 	cp src/esp/paks/esp-angular-mvc/templates/esp-angular-mvc/controller.js $(BIT_VAPP_PREFIX)/esp/esp-angular-mvc/templates/esp-angular-mvc/controller.js ; 	cp src/esp/paks/esp-angular-mvc/templates/esp-angular-mvc/edit.html $(BIT_VAPP_PREFIX)/esp/esp-angular-mvc/templates/esp-angular-mvc/edit.html ; 	cp src/esp/paks/esp-angular-mvc/templates/esp-angular-mvc/list.html $(BIT_VAPP_PREFIX)/esp/esp-angular-mvc/templates/esp-angular-mvc/list.html ; 	cp src/esp/paks/esp-angular-mvc/templates/esp-angular-mvc/model.js $(BIT_VAPP_PREFIX)/esp/esp-angular-mvc/templates/esp-angular-mvc/model.js ; 	cp src/esp/paks/esp-angular-mvc/templates/esp-angular-mvc/start.bit $(BIT_VAPP_PREFIX)/esp/esp-angular-mvc/templates/esp-angular-mvc/start.bit ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/esp-html-mvc" ; 	cp src/esp/paks/esp-html-mvc/package.json $(BIT_VAPP_PREFIX)/esp/esp-html-mvc/package.json ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/esp-html-mvc/templates/esp-html-mvc" ; 	cp src/esp/paks/esp-html-mvc/templates/esp-html-mvc/appweb.conf $(BIT_VAPP_PREFIX)/esp/esp-html-mvc/templates/esp-html-mvc/appweb.conf ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/esp-html-mvc/templates/esp-html-mvc/client/assets" ; 	cp src/esp/paks/esp-html-mvc/templates/esp-html-mvc/client/assets/favicon.ico $(BIT_VAPP_PREFIX)/esp/esp-html-mvc/templates/esp-html-mvc/client/assets/favicon.ico ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/esp-html-mvc/templates/esp-html-mvc/client/css" ; 	cp src/esp/paks/esp-html-mvc/templates/esp-html-mvc/client/css/all.css $(BIT_VAPP_PREFIX)/esp/esp-html-mvc/templates/esp-html-mvc/client/css/all.css ; 	cp src/esp/paks/esp-html-mvc/templates/esp-html-mvc/client/css/all.less $(BIT_VAPP_PREFIX)/esp/esp-html-mvc/templates/esp-html-mvc/client/css/all.less ; 	cp src/esp/paks/esp-html-mvc/templates/esp-html-mvc/client/css/app.less $(BIT_VAPP_PREFIX)/esp/esp-html-mvc/templates/esp-html-mvc/client/css/app.less ; 	cp src/esp/paks/esp-html-mvc/templates/esp-html-mvc/client/css/theme.less $(BIT_VAPP_PREFIX)/esp/esp-html-mvc/templates/esp-html-mvc/client/css/theme.less ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/esp-html-mvc/templates/esp-html-mvc/client" ; 	cp src/esp/paks/esp-html-mvc/templates/esp-html-mvc/client/index.esp $(BIT_VAPP_PREFIX)/esp/esp-html-mvc/templates/esp-html-mvc/client/index.esp ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/esp-html-mvc/templates/esp-html-mvc/client/layouts" ; 	cp src/esp/paks/esp-html-mvc/templates/esp-html-mvc/client/layouts/default.esp $(BIT_VAPP_PREFIX)/esp/esp-html-mvc/templates/esp-html-mvc/client/layouts/default.esp ; 	cp src/esp/paks/esp-html-mvc/templates/esp-html-mvc/controller-singleton.c $(BIT_VAPP_PREFIX)/esp/esp-html-mvc/templates/esp-html-mvc/controller-singleton.c ; 	cp src/esp/paks/esp-html-mvc/templates/esp-html-mvc/controller.c $(BIT_VAPP_PREFIX)/esp/esp-html-mvc/templates/esp-html-mvc/controller.c ; 	cp src/esp/paks/esp-html-mvc/templates/esp-html-mvc/edit.esp $(BIT_VAPP_PREFIX)/esp/esp-html-mvc/templates/esp-html-mvc/edit.esp ; 	cp src/esp/paks/esp-html-mvc/templates/esp-html-mvc/list.esp $(BIT_VAPP_PREFIX)/esp/esp-html-mvc/templates/esp-html-mvc/list.esp ; 	cp src/esp/paks/esp-html-mvc/templates/esp-html-mvc/start.bit $(BIT_VAPP_PREFIX)/esp/esp-html-mvc/templates/esp-html-mvc/start.bit ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/esp-legacy-mvc" ; 	cp src/esp/paks/esp-legacy-mvc/package.json $(BIT_VAPP_PREFIX)/esp/esp-legacy-mvc/package.json ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/esp-legacy-mvc/templates/esp-legacy-mvc" ; 	cp src/esp/paks/esp-legacy-mvc/templates/esp-legacy-mvc/controller.c $(BIT_VAPP_PREFIX)/esp/esp-legacy-mvc/templates/esp-legacy-mvc/controller.c ; 	cp src/esp/paks/esp-legacy-mvc/templates/esp-legacy-mvc/edit.esp $(BIT_VAPP_PREFIX)/esp/esp-legacy-mvc/templates/esp-legacy-mvc/edit.esp ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/esp-legacy-mvc/templates/esp-legacy-mvc/layouts" ; 	cp src/esp/paks/esp-legacy-mvc/templates/esp-legacy-mvc/layouts/default.esp $(BIT_VAPP_PREFIX)/esp/esp-legacy-mvc/templates/esp-legacy-mvc/layouts/default.esp ; 	cp src/esp/paks/esp-legacy-mvc/templates/esp-legacy-mvc/list.esp $(BIT_VAPP_PREFIX)/esp/esp-legacy-mvc/templates/esp-legacy-mvc/list.esp ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/esp-legacy-mvc/templates/esp-legacy-mvc/static/css" ; 	cp src/esp/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/css/all.css $(BIT_VAPP_PREFIX)/esp/esp-legacy-mvc/templates/esp-legacy-mvc/static/css/all.css ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/esp-legacy-mvc/templates/esp-legacy-mvc/static/images" ; 	cp src/esp/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/images/banner.jpg $(BIT_VAPP_PREFIX)/esp/esp-legacy-mvc/templates/esp-legacy-mvc/static/images/banner.jpg ; 	cp src/esp/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/images/favicon.ico $(BIT_VAPP_PREFIX)/esp/esp-legacy-mvc/templates/esp-legacy-mvc/static/images/favicon.ico ; 	cp src/esp/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/images/splash.jpg $(BIT_VAPP_PREFIX)/esp/esp-legacy-mvc/templates/esp-legacy-mvc/static/images/splash.jpg ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/esp-legacy-mvc/templates/esp-legacy-mvc/static" ; 	cp src/esp/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/index.esp $(BIT_VAPP_PREFIX)/esp/esp-legacy-mvc/templates/esp-legacy-mvc/static/index.esp ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/esp-legacy-mvc/templates/esp-legacy-mvc/static/js" ; 	cp src/esp/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/js/jquery.esp.js $(BIT_VAPP_PREFIX)/esp/esp-legacy-mvc/templates/esp-legacy-mvc/static/js/jquery.esp.js ; 	cp src/esp/paks/esp-legacy-mvc/templates/esp-legacy-mvc/static/js/jquery.js $(BIT_VAPP_PREFIX)/esp/esp-legacy-mvc/templates/esp-legacy-mvc/static/js/jquery.js ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/esp-server" ; 	cp src/esp/paks/esp-server/package.json $(BIT_VAPP_PREFIX)/esp/esp-server/package.json ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/esp-server/templates/esp-server" ; 	cp src/esp/paks/esp-server/templates/esp-server/appweb.conf $(BIT_VAPP_PREFIX)/esp/esp-server/templates/esp-server/appweb.conf ; 	cp src/esp/paks/esp-server/templates/esp-server/controller.c $(BIT_VAPP_PREFIX)/esp/esp-server/templates/esp-server/controller.c ; 	cp src/esp/paks/esp-server/templates/esp-server/migration.c $(BIT_VAPP_PREFIX)/esp/esp-server/templates/esp-server/migration.c ; 	mkdir -p "$(BIT_VAPP_PREFIX)/esp/esp-server/templates/esp-server/src" ; 	cp src/esp/paks/esp-server/templates/esp-server/src/app.c $(BIT_VAPP_PREFIX)/esp/esp-server/templates/esp-server/src/app.c ; 	fi ; 	if [ "$(BIT_PACK_ESP)" = 1 ]; then true  ; 	cp ${CONFIG}/bin/esp.conf $(BIT_VAPP_PREFIX)/bin/esp.conf ; 	fi ; 	mkdir -p "$(BIT_WEB_PREFIX)/bench" ; 	cp src/server/web/bench/1b.html $(BIT_WEB_PREFIX)/bench/1b.html ; 	cp src/server/web/bench/4k.html $(BIT_WEB_PREFIX)/bench/4k.html ; 	cp src/server/web/bench/64k.html $(BIT_WEB_PREFIX)/bench/64k.html ; 	mkdir -p "$(BIT_WEB_PREFIX)" ; 	cp src/server/web/favicon.ico $(BIT_WEB_PREFIX)/favicon.ico ; 	mkdir -p "$(BIT_WEB_PREFIX)/icons" ; 	cp src/server/web/icons/back.gif $(BIT_WEB_PREFIX)/icons/back.gif ; 	cp src/server/web/icons/blank.gif $(BIT_WEB_PREFIX)/icons/blank.gif ; 	cp src/server/web/icons/compressed.gif $(BIT_WEB_PREFIX)/icons/compressed.gif ; 	cp src/server/web/icons/folder.gif $(BIT_WEB_PREFIX)/icons/folder.gif ; 	cp src/server/web/icons/parent.gif $(BIT_WEB_PREFIX)/icons/parent.gif ; 	cp src/server/web/icons/space.gif $(BIT_WEB_PREFIX)/icons/space.gif ; 	cp src/server/web/icons/text.gif $(BIT_WEB_PREFIX)/icons/text.gif ; 	cp src/server/web/iehacks.css $(BIT_WEB_PREFIX)/iehacks.css ; 	mkdir -p "$(BIT_WEB_PREFIX)/images" ; 	cp src/server/web/images/banner.jpg $(BIT_WEB_PREFIX)/images/banner.jpg ; 	cp src/server/web/images/bottomShadow.jpg $(BIT_WEB_PREFIX)/images/bottomShadow.jpg ; 	cp src/server/web/images/shadow.jpg $(BIT_WEB_PREFIX)/images/shadow.jpg ; 	cp src/server/web/index.html $(BIT_WEB_PREFIX)/index.html ; 	cp src/server/web/min-index.html $(BIT_WEB_PREFIX)/min-index.html ; 	cp src/server/web/print.css $(BIT_WEB_PREFIX)/print.css ; 	cp src/server/web/screen.css $(BIT_WEB_PREFIX)/screen.css ; 	mkdir -p "$(BIT_WEB_PREFIX)/test" ; 	cp src/server/web/test/bench.html $(BIT_WEB_PREFIX)/test/bench.html ; 	cp src/server/web/test/test.cgi $(BIT_WEB_PREFIX)/test/test.cgi ; 	cp src/server/web/test/test.ejs $(BIT_WEB_PREFIX)/test/test.ejs ; 	cp src/server/web/test/test.esp $(BIT_WEB_PREFIX)/test/test.esp ; 	cp src/server/web/test/test.html $(BIT_WEB_PREFIX)/test/test.html ; 	cp src/server/web/test/test.php $(BIT_WEB_PREFIX)/test/test.php ; 	cp src/server/web/test/test.pl $(BIT_WEB_PREFIX)/test/test.pl ; 	cp src/server/web/test/test.py $(BIT_WEB_PREFIX)/test/test.py ; 	mkdir -p "$(BIT_WEB_PREFIX)/test" ; 	cp src/server/web/test/test.cgi $(BIT_WEB_PREFIX)/test/test.cgi ; 	chmod 755 "$(BIT_WEB_PREFIX)/test/test.cgi" ; 	cp src/server/web/test/test.pl $(BIT_WEB_PREFIX)/test/test.pl ; 	chmod 755 "$(BIT_WEB_PREFIX)/test/test.pl" ; 	cp src/server/web/test/test.py $(BIT_WEB_PREFIX)/test/test.py ; 	chmod 755 "$(BIT_WEB_PREFIX)/test/test.py" ; 	mkdir -p "$(BIT_ETC_PREFIX)" ; 	cp src/server/mime.types $(BIT_ETC_PREFIX)/mime.types ; 	cp src/server/self.crt $(BIT_ETC_PREFIX)/self.crt ; 	cp src/server/self.key $(BIT_ETC_PREFIX)/self.key ; 	if [ "$(BIT_PACK_PHP)" = 1 ]; then true  ; 	cp src/server/php.ini $(BIT_ETC_PREFIX)/php.ini ; 	fi ; 	cp src/server/appweb.conf $(BIT_ETC_PREFIX)/appweb.conf ; 	cp src/server/sample.conf $(BIT_ETC_PREFIX)/sample.conf ; 	cp src/server/self.crt $(BIT_ETC_PREFIX)/self.crt ; 	cp src/server/self.key $(BIT_ETC_PREFIX)/self.key ; 	echo 'set LOG_DIR "$(BIT_LOG_PREFIX)"\nset CACHE_DIR "$(BIT_CACHE_PREFIX)"\nDocuments "$(BIT_WEB_PREFIX)\nListen 80\nListenSecure 443\n' >$(BIT_ETC_PREFIX)/install.conf ; 	mkdir -p "$(BIT_VAPP_PREFIX)/inc" ; 	cp ${CONFIG}/inc/bit.h $(BIT_VAPP_PREFIX)/inc/bit.h ; 	mkdir -p "$(BIT_INC_PREFIX)/appweb" ; 	rm -f "$(BIT_INC_PREFIX)/appweb/bit.h" ; 	ln -s "$(BIT_VAPP_PREFIX)/inc/bit.h" "$(BIT_INC_PREFIX)/appweb/bit.h" ; 	cp src/bitos.h $(BIT_VAPP_PREFIX)/inc/bitos.h ; 	rm -f "$(BIT_INC_PREFIX)/appweb/bitos.h" ; 	ln -s "$(BIT_VAPP_PREFIX)/inc/bitos.h" "$(BIT_INC_PREFIX)/appweb/bitos.h" ; 	cp src/appweb.h $(BIT_VAPP_PREFIX)/inc/appweb.h ; 	rm -f "$(BIT_INC_PREFIX)/appweb/appweb.h" ; 	ln -s "$(BIT_VAPP_PREFIX)/inc/appweb.h" "$(BIT_INC_PREFIX)/appweb/appweb.h" ; 	cp src/customize.h $(BIT_VAPP_PREFIX)/inc/customize.h ; 	rm -f "$(BIT_INC_PREFIX)/appweb/customize.h" ; 	ln -s "$(BIT_VAPP_PREFIX)/inc/customize.h" "$(BIT_INC_PREFIX)/appweb/customize.h" ; 	cp src/paks/est/est.h $(BIT_VAPP_PREFIX)/inc/est.h ; 	rm -f "$(BIT_INC_PREFIX)/appweb/est.h" ; 	ln -s "$(BIT_VAPP_PREFIX)/inc/est.h" "$(BIT_INC_PREFIX)/appweb/est.h" ; 	cp src/paks/http/http.h $(BIT_VAPP_PREFIX)/inc/http.h ; 	rm -f "$(BIT_INC_PREFIX)/appweb/http.h" ; 	ln -s "$(BIT_VAPP_PREFIX)/inc/http.h" "$(BIT_INC_PREFIX)/appweb/http.h" ; 	cp src/paks/mpr/mpr.h $(BIT_VAPP_PREFIX)/inc/mpr.h ; 	rm -f "$(BIT_INC_PREFIX)/appweb/mpr.h" ; 	ln -s "$(BIT_VAPP_PREFIX)/inc/mpr.h" "$(BIT_INC_PREFIX)/appweb/mpr.h" ; 	cp src/paks/pcre/pcre.h $(BIT_VAPP_PREFIX)/inc/pcre.h ; 	rm -f "$(BIT_INC_PREFIX)/appweb/pcre.h" ; 	ln -s "$(BIT_VAPP_PREFIX)/inc/pcre.h" "$(BIT_INC_PREFIX)/appweb/pcre.h" ; 	cp src/paks/sqlite/sqlite3.h $(BIT_VAPP_PREFIX)/inc/sqlite3.h ; 	rm -f "$(BIT_INC_PREFIX)/appweb/sqlite3.h" ; 	ln -s "$(BIT_VAPP_PREFIX)/inc/sqlite3.h" "$(BIT_INC_PREFIX)/appweb/sqlite3.h" ; 	if [ "$(BIT_PACK_ESP)" = 1 ]; then true  ; 	cp src/esp/edi.h $(BIT_VAPP_PREFIX)/inc/edi.h ; 	rm -f "$(BIT_INC_PREFIX)/appweb/edi.h" ; 	ln -s "$(BIT_VAPP_PREFIX)/inc/edi.h" "$(BIT_INC_PREFIX)/appweb/edi.h" ; 	cp src/esp/esp.h $(BIT_VAPP_PREFIX)/inc/esp.h ; 	rm -f "$(BIT_INC_PREFIX)/appweb/esp.h" ; 	ln -s "$(BIT_VAPP_PREFIX)/inc/esp.h" "$(BIT_INC_PREFIX)/appweb/esp.h" ; 	cp src/esp/mdb.h $(BIT_VAPP_PREFIX)/inc/mdb.h ; 	rm -f "$(BIT_INC_PREFIX)/appweb/mdb.h" ; 	ln -s "$(BIT_VAPP_PREFIX)/inc/mdb.h" "$(BIT_INC_PREFIX)/appweb/mdb.h" ; 	fi ; 	if [ "$(BIT_PACK_EJSCRIPT)" = 1 ]; then true  ; 	cp src/paks/ejs/ejs.h $(BIT_VAPP_PREFIX)/inc/ejs.h ; 	rm -f "$(BIT_INC_PREFIX)/appweb/ejs.h" ; 	ln -s "$(BIT_VAPP_PREFIX)/inc/ejs.h" "$(BIT_INC_PREFIX)/appweb/ejs.h" ; 	cp src/paks/ejs/ejs.slots.h $(BIT_VAPP_PREFIX)/inc/ejs.slots.h ; 	rm -f "$(BIT_INC_PREFIX)/appweb/ejs.slots.h" ; 	ln -s "$(BIT_VAPP_PREFIX)/inc/ejs.slots.h" "$(BIT_INC_PREFIX)/appweb/ejs.slots.h" ; 	cp src/paks/ejs/ejsByteGoto.h $(BIT_VAPP_PREFIX)/inc/ejsByteGoto.h ; 	rm -f "$(BIT_INC_PREFIX)/appweb/ejsByteGoto.h" ; 	ln -s "$(BIT_VAPP_PREFIX)/inc/ejsByteGoto.h" "$(BIT_INC_PREFIX)/appweb/ejsByteGoto.h" ; 	fi ; 	if [ "$(BIT_PACK_EJSCRIPT)" = 1 ]; then true  ; 	cp ${CONFIG}/bin/ejs.mod $(BIT_VAPP_PREFIX)/bin/ejs.mod ; 	fi ; 	mkdir -p "$(BIT_VAPP_PREFIX)/doc/man1" ; 	cp doc/man/appman.1 $(BIT_VAPP_PREFIX)/doc/man1/appman.1 ; 	mkdir -p "$(BIT_MAN_PREFIX)/man1" ; 	rm -f "$(BIT_MAN_PREFIX)/man1/appman.1" ; 	ln -s "$(BIT_VAPP_PREFIX)/doc/man1/appman.1" "$(BIT_MAN_PREFIX)/man1/appman.1" ; 	cp doc/man/appweb.1 $(BIT_VAPP_PREFIX)/doc/man1/appweb.1 ; 	rm -f "$(BIT_MAN_PREFIX)/man1/appweb.1" ; 	ln -s "$(BIT_VAPP_PREFIX)/doc/man1/appweb.1" "$(BIT_MAN_PREFIX)/man1/appweb.1" ; 	cp doc/man/appwebMonitor.1 $(BIT_VAPP_PREFIX)/doc/man1/appwebMonitor.1 ; 	rm -f "$(BIT_MAN_PREFIX)/man1/appwebMonitor.1" ; 	ln -s "$(BIT_VAPP_PREFIX)/doc/man1/appwebMonitor.1" "$(BIT_MAN_PREFIX)/man1/appwebMonitor.1" ; 	cp doc/man/authpass.1 $(BIT_VAPP_PREFIX)/doc/man1/authpass.1 ; 	rm -f "$(BIT_MAN_PREFIX)/man1/authpass.1" ; 	ln -s "$(BIT_VAPP_PREFIX)/doc/man1/authpass.1" "$(BIT_MAN_PREFIX)/man1/authpass.1" ; 	cp doc/man/esp.1 $(BIT_VAPP_PREFIX)/doc/man1/esp.1 ; 	rm -f "$(BIT_MAN_PREFIX)/man1/esp.1" ; 	ln -s "$(BIT_VAPP_PREFIX)/doc/man1/esp.1" "$(BIT_MAN_PREFIX)/man1/esp.1" ; 	cp doc/man/http.1 $(BIT_VAPP_PREFIX)/doc/man1/http.1 ; 	rm -f "$(BIT_MAN_PREFIX)/man1/http.1" ; 	ln -s "$(BIT_VAPP_PREFIX)/doc/man1/http.1" "$(BIT_MAN_PREFIX)/man1/http.1" ; 	cp doc/man/makerom.1 $(BIT_VAPP_PREFIX)/doc/man1/makerom.1 ; 	rm -f "$(BIT_MAN_PREFIX)/man1/makerom.1" ; 	ln -s "$(BIT_VAPP_PREFIX)/doc/man1/makerom.1" "$(BIT_MAN_PREFIX)/man1/makerom.1" ; 	cp doc/man/manager.1 $(BIT_VAPP_PREFIX)/doc/man1/manager.1 ; 	rm -f "$(BIT_MAN_PREFIX)/man1/manager.1" ; 	ln -s "$(BIT_VAPP_PREFIX)/doc/man1/manager.1" "$(BIT_MAN_PREFIX)/man1/manager.1" ; 	mkdir -p "$(BIT_ROOT_PREFIX)/Library/LaunchDaemons" ; 	cp package/macosx/com.embedthis.appweb.plist $(BIT_ROOT_PREFIX)/Library/LaunchDaemons/com.embedthis.appweb.plist ; 	[ `id -u` = 0 ] && chown root:wheel "$(BIT_ROOT_PREFIX)/Library/LaunchDaemons/com.embedthis.appweb.plist"; true ; 	chmod 644 "$(BIT_ROOT_PREFIX)/Library/LaunchDaemons/com.embedthis.appweb.plist" ; cd .

	cd .; ./${CONFIG}/bin/appman install enable start ; cd .

#  Omit build script install


	cd package; rm -f "$(BIT_ETC_PREFIX)/appweb.conf" ; 	rm -f "$(BIT_ETC_PREFIX)/esp.conf" ; 	rm -f "$(BIT_ETC_PREFIX)/mine.types" ; 	rm -f "$(BIT_ETC_PREFIX)/install.conf" ; 	rm -fr "$(BIT_INC_PREFIX)/appweb" ; 	rm -fr "$(BIT_WEB_PREFIX)" ; 	rm -fr "$(BIT_SPOOL_PREFIX)" ; 	rm -fr "$(BIT_CACHE_PREFIX)" ; 	rm -fr "$(BIT_LOG_PREFIX)" ; 	rm -fr "$(BIT_VAPP_PREFIX)" ; 	rmdir -p "$(BIT_ETC_PREFIX)" 2>/dev/null ; true ; 	rmdir -p "$(BIT_WEB_PREFIX)" 2>/dev/null ; true ; 	rmdir -p "$(BIT_LOG_PREFIX)" 2>/dev/null ; true ; 	rmdir -p "$(BIT_SPOOL_PREFIX)" 2>/dev/null ; true ; 	rmdir -p "$(BIT_CACHE_PREFIX)" 2>/dev/null ; true ; 	rm -f "$(BIT_APP_PREFIX)/latest" ; 	rmdir -p "$(BIT_APP_PREFIX)" 2>/dev/null ; true ; cd ..

	cd src/server; esp --static --genlink slink.c --flat compile ; cd ../..

	cd src/server; sudo ../../${CONFIG}/bin/appweb -v ; cd ../..

	cd test; ../${CONFIG}/bin/appweb -v ; cd ..

