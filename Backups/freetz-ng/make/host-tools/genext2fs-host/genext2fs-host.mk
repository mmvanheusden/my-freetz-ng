$(call TOOLS_INIT, 3b99f4a43f612b9ee74bbf24ca9890606295313f)
$(PKG)_SOURCE:=genext2fs-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=2721c9e131324994ed6c001bfd0d4f176be437592aacf52644e06781a3952598
$(PKG)_SITE:=git@https://github.com/bestouff/genext2fs.git
### VERSION:=1.5.0-3b99f4a4
### WEBSITE:=https://genext2fs.sourceforge.net/
### MANPAGE:=https://sourceforge.net/projects/genext2fs/
### CHANGES:=https://github.com/bestouff/genext2fs/tags
### CVSREPO:=https://github.com/bestouff/genext2fs

$(PKG)_CONFIGURE_PRE_CMDS += ./autogen.sh;
$(PKG)_CONFIGURE_OPTIONS += --program-prefix=""
$(PKG)_CONFIGURE_OPTIONS += --program-suffix=""
$(PKG)_CONFIGURE_OPTIONS += --prefix=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/genext2fs: $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) CC="$(TOOLS_CC)" CXX="$(TOOLS_CXX)" CFLAGS="$(TOOLS_CFLAGS)" LDFLAGS="$(TOOLS_LDFLAGS)" -C $(GENEXT2FS_HOST_DIR) all
	touch -c $@

$(pkg)-test: $($(PKG)_DIR)/.tests-passed
$($(PKG)_DIR)/.tests-passed: $($(PKG)_DIR)/genext2fs
	(cd $(GENEXT2FS_HOST_DIR); ./test.sh)
	touch $@

$(TOOLS_DIR)/genext2fs: $($(PKG)_DIR)/genext2fs
	$(INSTALL_FILE)

$(pkg)-precompiled: $(TOOLS_DIR)/genext2fs


$(pkg)-clean:
	-$(MAKE) -C $(GENEXT2FS_HOST_DIR) clean
	$(RM) $(GENEXT2FS_HOST_DIR)/.configured $(GENEXT2FS_HOST_DIR)/.tests-passed

$(pkg)-dirclean:
	$(RM) -r $(GENEXT2FS_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(TOOLS_DIR)/genext2fs

$(TOOLS_FINISH)
