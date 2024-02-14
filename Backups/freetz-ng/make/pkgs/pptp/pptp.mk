$(call PKG_INIT_BIN, 1.10.0)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=82492db8e487ce73b182ee7f444251d20c44f5c26d6e96c553ec7093aefb5af4
$(PKG)_SITE:=@SF/pptpclient
$(PKG)_BINARY:=$($(PKG)_DIR)/pptp
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/pptp
### WEBSITE:=https://sourceforge.net/projects/pptpclient/
### CHANGES:=https://sourceforge.net/projects/pptpclient/files/pptp/
### CVSREPO:=https://sourceforge.net/p/pptpclient/git/ci/master/tree/


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(PPTP_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(PPTP_DIR) clean

$(pkg)-uninstall:
	$(RM) $(PPTP_TARGET_BINARY)

$(PKG_FINISH)
