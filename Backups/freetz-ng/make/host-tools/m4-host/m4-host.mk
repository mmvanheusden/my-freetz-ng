$(call TOOLS_INIT, 1.4.19)
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=63aede5c6d33b6d9b13511cd0be2cac046f2e70fd0a07aa9573a04a82783af96
$(PKG)_SITE:=@GNU/$(pkg_short)
### WEBSITE:=https://www.gnu.org/software/m4/
### MANPAGE:=https://www.gnu.org/software/m4/manual/index.html
### CHANGES:=http://ftp.gnu.org/gnu/m4/
### CVSREPO:=http://git.savannah.gnu.org/gitweb/?p=m4.git

$(PKG)_DEPENDS_ON+=pkgconf-host

$(PKG)_BINARY:=$($(PKG)_DIR)/src/m4
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/build/bin/m4


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(M4_HOST_DIR) all
	touch -c $@

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(MAKE) -C $(M4_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(M4_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(M4_HOST_TARGET_BINARY)

$(TOOLS_FINISH)
