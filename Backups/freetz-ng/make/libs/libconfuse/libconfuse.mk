$(call PKG_INIT_LIB, 3.3)
$(PKG)_LIB_VERSION:=2.1.0
$(PKG)_SOURCE:=confuse-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=1dd50a0320e135a55025b23fcdbb3f0a81913b6d0b0a9df8cc2fdf3b3dc67010
$(PKG)_SITE:=https://github.com/libconfuse/libconfuse/releases/download/v$($(PKG)_VERSION)
### WEBSITE:=https://www.nongnu.org/confuse/
### MANPAGE:=https://www.nongnu.org/confuse/manual/
### CHANGES:=https://github.com/libconfuse/libconfuse/releases
### CVSREPO:=https://github.com/libconfuse/libconfuse

$(PKG)_FILE=$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_BINARY:=$($(PKG)_DIR)/src/.libs/$($(PKG)_FILE)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_FILE)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$($(PKG)_FILE)

$(PKG)_CONFIGURE_OPTIONS += --enable-shared
$(PKG)_CONFIGURE_OPTIONS += --enable-static
$(PKG)_CONFIGURE_OPTIONS += --prefix=/
$(PKG)_CONFIGURE_OPTIONS += --disable-rpath
$(PKG)_CONFIGURE_OPTIONS += --disable-examples
$(PKG)_CONFIGURE_OPTIONS += --without-libiconv-prefix
$(PKG)_CONFIGURE_OPTIONS += --without-libintl-prefix


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBCONFUSE_DIR) \
		all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBCONFUSE_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libconfuse.la \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/libconfuse.pc

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBCONFUSE_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/share/doc/confuse/ \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libconfuse.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/libconfuse.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/confuse.h

$(pkg)-uninstall:
	$(RM) $(LIBCONFUSE_TARGET_DIR)/libconfuse.so*

$(PKG_FINISH)
