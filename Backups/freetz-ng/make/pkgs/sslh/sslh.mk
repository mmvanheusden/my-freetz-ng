$(call PKG_INIT_BIN, 2.0.1)
$(PKG)_SOURCE:=$(pkg)-v$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=d88d43ee11cf1324983c196c894b41766c33d957b6af53b62c8479703bbbd26c
$(PKG)_SITE:=https://www.rutschle.net/tech/sslh
### WEBSITE:=https://www.rutschle.net/tech/sslh/README.html
### MANPAGE:=https://www.rutschle.net/tech/sslh/doc/config
### CHANGES:=https://www.rutschle.net/tech/sslh/download.html
### CVSREPO:=https://github.com/yrutschle/sslh

$(PKG)_BINARY:=$($(PKG)_DIR)/sslh-fork
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/sslh

$(PKG)_DEPENDS_ON += libconfig pcre2


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(SSLH_DIR) \
		CC="$(TARGET_CC)" \
		CFLAGS="$(TARGET_CFLAGS)" \
		sslh-fork

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(SSLH_DIR) clean

$(pkg)-uninstall:
	$(RM) $(SSLH_TARGET_BINARY)

$(PKG_FINISH)

