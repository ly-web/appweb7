#
# Makefile for the Windows Appweb server components
#
# Copyright (c) Embedthis Software LLC, 2003-2014. All Rights Reserved.
#

BUILD_CROSS	:= 0

include 	.makedep 

ifeq ($(BUILDING_TARGET),1)
TARGETS		+= $(ME_PRODUCT)Monitor$(ME_EXE)
ifeq	($(ME_OS),WIN)
	SYSLIBS	+= shell32.lib
	MONITOR_RES = --resources appwebMonitor.rc
endif
endif

compileExtra: $(TARGETS) 

#
#	Link the monitor
#
$(ME_PRODUCT)Monitor$(ME_EXE): $(ME_LIB_DIR)/libmpr$(ME_LIB) $(OBJECTS)
	@bld --graphical --exe $(ME_PRODUCT)Monitor$(ME_EXE) --rpath "$(ME_LIB_PREFIX)" --rpath "../bin" \
		--search "$(LIBPATH)" $(MODE) --libs "mpr" $(MONITOR_RES) --syslibs "$(SYSLIBS)" \
		$(ME_OBJ_DIR)/$(ME_PRODUCT)Monitor$(ME_OBJ) 
	cp $(ME_PRODUCT)Monitor$(ME_EXE) $(ME_BIN_DIR)/$(ME_PRODUCT)Monitor$(ME_EXE) 
	cp $(ME_PRODUCT)Monitor.ico $(ME_BIN_DIR)

#
#   Local variables:
#   tab-width: 4
#   c-basic-offset: 4
#   End:
#   vim: sw=4 ts=4 noexpandtab
#
