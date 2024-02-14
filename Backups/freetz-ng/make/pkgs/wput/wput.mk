$(call PKG_INIT_BIN, 0.6.2)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tgz
$(PKG)_HASH:=229d8bb7d045ca1f54d68de23f1bc8016690dc0027a16586712594fbc7fad8c7
$(PKG)_SITE:=@SF/wput
### WEBSITE:=https://wput.sourceforge.net/
### MANPAGE:=https://linux.die.net/man/1/wput
### CHANGES:=https://sourceforge.net/projects/wput/files/wput/
### CVSREPO:=https://sourceforge.net/p/wput/code/ci/master/tree/

$(PKG)_BINARY:=$($(PKG)_DIR)/wput
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/wput

$(PKG)_CONFIGURE_OPTIONS += --without-ssl

$(PKG)_CFLAGS := $(TARGET_CFLAGS)
$(PKG)_CFLAGS += -fcommon


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(WPUT_DIR) \
		CFLAGS="$(WPUT_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(WPUT_DIR) clean

$(pkg)-uninstall:
	$(RM) $(WPUT_TARGET_BINARY)

$(PKG_FINISH)
