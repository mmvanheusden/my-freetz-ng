$(call TOOLS_INIT, a524bf3f6bacd1b4ad85d719eed2737d8562f27a)
$(PKG)_SOURCE:=ninja-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=b96b1f70a89cfa6d7bc47bf11d5bb894956a4ea3a3163da830c6869c0b85c014
$(PKG)_SITE:=git@https://github.com/ninja-build/ninja.git
### VERSION:=1.11.1
### WEBSITE:=https://ninja-build.org/
### MANPAGE:=https://github.com/ninja-build/ninja/wiki
### CHANGES:=https://github.com/ninja-build/ninja/releases
### CVSREPO:=https://github.com/ninja-build/ninja

$(PKG)_BUILD_DIR:=$($(PKG)_DIR)/builddir
$(PKG)_BINARY:=$($(PKG)_BUILD_DIR)/ninja
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/ninja


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	$(TOOLS_SUBCMAKE) \
		-B $(NINJA_HOST_BUILD_DIR) \
		-S $(NINJA_HOST_DIR)
	@touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBCMAKE) \
		--build $(NINJA_HOST_BUILD_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(CMAKE) \
		--build $(NINJA_HOST_BUILD_DIR) \
		--target clean
	$(RM) $(NINJA_HOST_DIR)/.configured

$(pkg)-dirclean:
	$(RM) -r $(NINJA_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(NINJA_HOST_TARGET_BINARY)

$(TOOLS_FINISH)
