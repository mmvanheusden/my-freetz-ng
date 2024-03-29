$(call PKG_INIT_LIB, avm-7390.05.50)
$(PKG)_LIB_VERSION:=3.0.4
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=9f8ff665972521755ced8f27591a864e89f35877a8f6e82340fe7c42cd217580
$(PKG)_SITE:=@MIRROR/

$(PKG)_BINARY:=$($(PKG)_DIR)/libcapi20.so.$($(PKG)_LIB_VERSION)
$(PKG)_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libcapi20.so.$($(PKG)_LIB_VERSION)
$(PKG)_TARGET_BINARY:=$($(PKG)_TARGET_DIR)/libcapi20.so.$($(PKG)_LIB_VERSION)

$(PKG)_MAKE_OPTS := -C $(LIBCAPI_DIR)
$(PKG)_MAKE_OPTS += CROSS_COMPILE="$(TARGET_CROSS)"
$(PKG)_MAKE_OPTS += CAPI20OPTS="$(TARGET_CFLAGS) $(FPIC)"
$(PKG)_MAKE_OPTS += DEFAULT_LDFLAGS_LIB="-Wl,-z,defs"
$(PKG)_MAKE_OPTS += FILESYSTEM="$(TARGET_TOOLCHAIN_STAGING_DIR)/usr"

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) $(LIBCAPI_MAKE_OPTS) all

$($(PKG)_STAGING_BINARY): $($(PKG)_BINARY)
	$(SUBMAKE) $(LIBCAPI_MAKE_OPTS) install

$($(PKG)_TARGET_BINARY): $($(PKG)_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(LIBCAPI_DIR) clean
	$(RM) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libcapi20.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/capi20.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/capiutils.h \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/capicmd.h

$(pkg)-uninstall:
	$(RM) $(LIBCAPI_TARGET_DIR)/libcapi*.so*

$(PKG_FINISH)
