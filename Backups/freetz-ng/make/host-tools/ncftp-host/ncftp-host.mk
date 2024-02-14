$(call TOOLS_INIT, 3.2.7)
$(PKG)_SOURCE:=ncftp-$($(PKG)_VERSION)-src.tar.xz
$(PKG)_HASH:=d41c5c4d6614a8eae2ed4e4d7ada6b6d3afcc9fb65a4ed9b8711344bef24f7e8
$(PKG)_SITE:=https://www.ncftp.com/downloads/ncftp,https://www.ncftp.com/public_ftp/ncftp/older_versions,https://www.ncftp.com/public_ftp/ncftp
### WEBSITE:=https://www.ncftp.com/ncftp/
### MANPAGE:=https://www.ncftp.com/ncftp/doc/faq.html
### CHANGES:=https://www.ncftp.com/ncftp/doc/changelog.html

$(PKG)_BINARIES_ALL := ncftp ncftpput  ncftpget ncftpls  ncftpbatch
$(PKG)_BINARIES := ncftp ncftpput  ncftpget ncftpls
$(PKG)_BINARIES_BUILD_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/bin/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$(TOOLS_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR_ALL := $($(PKG)_BINARIES_ALL:%=$(TOOLS_DIR)/%)

$(PKG)_CONFIGURE_OPTIONS += --disable-ccdv
$(PKG)_CONFIGURE_OPTIONS += --without-curses
$(PKG)_CONFIGURE_OPTIONS += --without-ncurses

$(PKG)_CFLAGS := $(TOOLS_CFLAGS)
$(PKG)_CFLAGS += -fcommon
$(PKG)_LDFLAGS := $(TOOLS_LDFLAGS)


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(NCFTP_HOST_DIR) \
		CC="$(TOOLS_CC)" \
		CFLAGS="$(NCFTP_HOST_CFLAGS)"

$($(PKG)_BINARIES_TARGET_DIR): $(TOOLS_DIR)/%: $($(PKG)_DIR)/bin/%
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)


$(pkg)-clean:
	-$(MAKE) -C $(NCFTP_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(NCFTP_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(NCFTP_HOST_BINARIES_TARGET_DIR_ALL)

$(TOOLS_FINISH)

