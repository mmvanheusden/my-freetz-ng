$(call PKG_INIT_LIB, 0.42.2)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=pixman-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=ea1480efada2fd948bc75366f7c349e1c96d3297d09a3fe62626e38e234a625e
$(PKG)_SITE:=https://www.cairographics.org/releases/
### WEBSITE:=http://www.pixman.org/
### CHANGES:=https://www.cairographics.org/releases/
### CVSREPO:=https://cgit.freedesktop.org/pixman/

$(PKG)_LIBNAME_SHORT:=$(pkg)
$(PKG)_LIBNAME_LONG:=$($(PKG)_LIBNAME_SHORT:%=lib%-1.so.$($(PKG)_LIB_VERSION))
$(PKG)_BINARY:=$($(PKG)_DIR)/pixman/.libs/$($(PKG)_LIBNAME_LONG)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_LIBNAME_LONG)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_LIBNAME_LONG)

$(PKG)_CONFIGURE_OPTIONS += --disable-openmp
$(PKG)_CONFIGURE_OPTIONS += --disable-loongson-mmi
$(PKG)_CONFIGURE_OPTIONS += --disable-mmx
$(PKG)_CONFIGURE_OPTIONS += --disable-sse2
$(PKG)_CONFIGURE_OPTIONS += --disable-ssse3
$(PKG)_CONFIGURE_OPTIONS += --disable-vmx
$(PKG)_CONFIGURE_OPTIONS += --disable-arm-simd
$(PKG)_CONFIGURE_OPTIONS += --disable-arm-neon
$(PKG)_CONFIGURE_OPTIONS += --disable-arm-a64-neon
$(PKG)_CONFIGURE_OPTIONS += --disable-arm-iwmmxt
$(PKG)_CONFIGURE_OPTIONS += --disable-arm-iwmmxt2
$(PKG)_CONFIGURE_OPTIONS += --disable-mips-dspr2
$(PKG)_CONFIGURE_OPTIONS += --disable-gcc-inline-asm
$(PKG)_CONFIGURE_OPTIONS += --disable-static-testprogs
$(PKG)_CONFIGURE_OPTIONS += --disable-timers
$(PKG)_CONFIGURE_OPTIONS += --disable-gnuplot
$(PKG)_CONFIGURE_OPTIONS += --disable-gtk
$(PKG)_CONFIGURE_OPTIONS += --disable-libpng


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PIXMAN_DIR) all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(PIXMAN_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/pixman-1.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpixman-1.la

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(PIXMAN_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libpixman-1.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/include/pixman-1/ \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/pixman-1.pc

$(pkg)-uninstall:
	$(RM) $(PIXMAN_TARGET_DIR)/libpixman-1.so*

$(PKG_FINISH)
