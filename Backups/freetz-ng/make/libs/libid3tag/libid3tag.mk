$(call PKG_INIT_LIB, 0.16.3)
$(PKG)_LIB_VERSION:=$($(PKG)_VERSION)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=371eafd9336a4027352187216c6fdb496966362854b5e151c51940f8b25e726f
$(PKG)_SITE:=git@https://codeberg.org/tenacityteam/libid3tag.git
### WEBSITE:=https://tenacityaudio.org/
### CHANGES:=https://codeberg.org/tenacityteam/libid3tag/releases
### CVSREPO:=https://codeberg.org/tenacityteam/libid3tag

$(PKG)_BINARY:=$($(PKG)_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/$(pkg).so.$($(PKG)_LIB_VERSION)

$(PKG)_DEPENDS_ON += cmake-host
$(PKG)_DEPENDS_ON += zlib

$(PKG)_CONFIGURE_OPTIONS += -DCMAKE_INSTALL_PREFIX="/"
$(PKG)_CONFIGURE_OPTIONS += -DCMAKE_SKIP_INSTALL_RPATH=NO
$(PKG)_CONFIGURE_OPTIONS += -DCMAKE_SKIP_RPATH=NO

$(PKG)_CONFIGURE_OPTIONS += -DBUILD_SHARED_LIBS=ON
$(PKG)_CONFIGURE_OPTIONS += -DCMAKE_BUILD_TYPE=Release


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CMAKE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(LIBID3TAG_DIR)
#cmake	cd $(LIBID3TAG_DIR) && cmake -LA .

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) -C $(LIBID3TAG_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/id3tag.pc
#		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libid3tag.la
	@touch -c $@

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBID3TAG_DIR) clean
	$(RM) $(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libid3tag* $(TARGET_TOOLCHAIN_STAGING_DIR)/cmake/id3tag/

$(pkg)-uninstall:
	$(RM) $(LIBID3TAG_TARGET_DIR)/libid3tag*.so*

$(PKG_FINISH)
