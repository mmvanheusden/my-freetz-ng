$(call PKG_INIT_BIN, 6.1)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=9721d0614e1a5d0fe6b80c9a8a04ada8efd42cbdfddd239e95a8059ae283aa6f
$(PKG)_SITE:=@SF/bftpd
### WEBSITE:=https://bftpd.sourceforge.net/
### MANPAGE:=https://bftpd.sourceforge.net/documents.html
### CHANGES:=https://bftpd.sourceforge.net/downloads/CHANGELOG
### CVSREPO:=https://sourceforge.net/projects/bftpd/

$(PKG)_BINARY:=$($(PKG)_DIR)/bftpd
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/bftpd

ifeq ($(strip $(FREETZ_PACKAGE_BFTPD_WITH_ZLIB)),y)
$(PKG)_DEPENDS_ON += zlib
endif

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_BFTPD_WITH_ZLIB

$(PKG)_CONFIGURE_OPTIONS += $(if $(FREETZ_PACKAGE_BFTPD_WITH_ZLIB),--enable-libz)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(BFTPD_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(BFTPD_DIR) clean
	rm -f $(BFTPD_FREETZ_CONFIG_FILE)

$(pkg)-uninstall:
	$(RM) $(BFTPD_TARGET_BINARY)

$(PKG_FINISH)
