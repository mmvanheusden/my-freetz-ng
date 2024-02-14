$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_RRDTOOL_VERSION_ABANDON),1.2.30,1.8.0))
$(PKG)_LIB_VERSION:=$(if $(FREETZ_PACKAGE_RRDTOOL_VERSION_ABANDON),2.0.15,8.3.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH_ABANDON:=3190efea410a6dd035799717948b2df09910f608d72d23ee81adad4cd0184ae9
$(PKG)_HASH_CURRENT:=bd37614137d7a8dc523359648eb2a81631a34fd91a82ed5581916a52c08433f4
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_RRDTOOL_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=https://github.com/oetiker/rrdtool-1.x/releases/download/v$($(PKG)_VERSION),https://oss.oetiker.ch/rrdtool/pub/archive
### WEBSITE:=https://www.rrdtool.org
### MANPAGE:=https://oss.oetiker.ch/rrdtool/doc
### CHANGES:=https://github.com/oetiker/rrdtool-1.x/blob/master/CHANGES
### CVSREPO:=https://github.com/oetiker/rrdtool-1.x

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_RRDTOOL_VERSION_ABANDON),abandon,current)

$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/rrdtool
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/rrdtool-freetz

$(PKG)_LIBS_SELECTED:=librrd.so.$($(PKG)_LIB_VERSION)
ifeq ($(strip $(FREETZ_LIB_librrd_th)),y)
$(PKG)_LIBS_SELECTED+=librrd_th.so.2.0.13
endif
$(PKG)_LIBS_BUILD_DIR:=$($(PKG)_LIBS_SELECTED:%=$($(PKG)_DIR)/src/.libs/%)
$(PKG)_LIBS_STAGING_DIR:=$($(PKG)_LIBS_SELECTED:%=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%)
$(PKG)_LIBS_TARGET_DIR:=$($(PKG)_LIBS_SELECTED:%=$($(PKG)_TARGET_LIBDIR)/%)

ifeq ($(FREETZ_PACKAGE_RRDTOOL_VERSION_ABANDON),y)
$(PKG)_DEPENDS_ON += libpng freetype libart_lgpl zlib

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_PREVENT_RPATH_HARDCODING,./configure)

$(PKG)_CONFIGURE_ENV += ac_cv_func_setpgrp_void=yes
$(PKG)_CONFIGURE_ENV += rd_cv_ieee_works=yes

$(PKG)_CONFIGURE_OPTIONS += --without-x

$(PKG)_EXTRA_CPPFLAGS += "-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/libart-2.0"
$(PKG)_EXTRA_CPPFLAGS += "-I$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/freetype2"

else
$(PKG)_DEPENDS_ON += glib2 gettext libpng libxml2 harfbuzz cairo pango

$(PKG)_CONFIGURE_OPTIONS += --disable-nls
$(PKG)_CONFIGURE_OPTIONS += --disable-docs
$(PKG)_CONFIGURE_OPTIONS += --disable-examples
$(PKG)_CONFIGURE_OPTIONS += --disable-libdbi
$(PKG)_CONFIGURE_OPTIONS += --disable-librados
$(PKG)_CONFIGURE_OPTIONS += --disable-libwrap
$(PKG)_CONFIGURE_OPTIONS += --disable-lua
$(PKG)_CONFIGURE_OPTIONS += --disable-rrdcached
$(PKG)_CONFIGURE_OPTIONS += --enable-rrd_graph
$(PKG)_CONFIGURE_OPTIONS += --enable-rrd_restore

$(PKG)_EXTRA_CPPFLAGS += "-I$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/glib-2.0/include"
$(PKG)_EXTRA_CPPFLAGS += "-I$(TARGET_TOOLCHAIN_STAGING_DIR)/include/glib-2.0"
$(PKG)_EXTRA_CPPFLAGS += "-I$(TARGET_TOOLCHAIN_STAGING_DIR)/include/harfbuzz"
$(PKG)_EXTRA_CPPFLAGS += "-I$(TARGET_TOOLCHAIN_STAGING_DIR)/include/cairo"
$(PKG)_EXTRA_CPPFLAGS += "-I$(TARGET_TOOLCHAIN_STAGING_DIR)/include/pango-1.0"

$(PKG)_EXCLUDED += usr/share/rrdtool/fonts/DejaVuSansMono-Roman.ttf
endif

$(PKG)_EXCLUDED += $(if $(FREETZ_AVM_HAS_RRDTOOL),usr/bin/rrdtool)

$(PKG)_CONFIGURE_OPTIONS += --sysconfdir=/mod/etc
$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --enable-rrdcgi
$(PKG)_CONFIGURE_OPTIONS += --disable-mmap
$(PKG)_CONFIGURE_OPTIONS += --disable-python
$(PKG)_CONFIGURE_OPTIONS += --disable-perl
$(PKG)_CONFIGURE_OPTIONS += --disable-tcl
$(PKG)_CONFIGURE_OPTIONS += --disable-ruby


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY) $($(PKG)_LIBS_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(RRDTOOL_DIR) all \
		LDFLAGS="$(TARGET_LDFLAGS) $(RRDTOOL_EXTRA_LDFLAGS)" \
		CPPFLAGS="$(TARGET_CPPFLAGS) $(RRDTOOL_EXTRA_CPPFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIBS_STAGING_DIR): $($(PKG)_LIBS_BUILD_DIR)
	$(SUBMAKE) -C $(RRDTOOL_DIR)/src \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install-includeHEADERS \
		install-libLTLIBRARIES
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/librrd*.la

$($(PKG)_LIBS_TARGET_DIR): $($(PKG)_TARGET_LIBDIR)/%: $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/%
	$(INSTALL_LIBRARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIBS_TARGET_DIR)


$(pkg)-clean:
	-$(SUBMAKE) -C $(RRDTOOL_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/librrd* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/rrd.h

$(pkg)-uninstall:
	$(RM) $(RRDTOOL_TARGET_BINARY)
	$(RM) $(RRDTOOL_TARGET_LIBDIR)/librrd*.so*

$(PKG_FINISH)

