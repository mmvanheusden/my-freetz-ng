$(call TOOLS_INIT, 2.71)
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=f14c83cfebcc9427f2c3cea7258bd90df972d92eb26752da4ddad81c87a0faa4
$(PKG)_SITE:=@GNU/$(pkg_short)
### WEBSITE:=https://www.gnu.org/software/autoconf/
### MANPAGE:=https://www.gnu.org/savannah-checkouts/gnu/autoconf/manual/
### CHANGES:=https://ftp.gnu.org/gnu/autoconf/
### CVSREPO:=https://git.savannah.gnu.org/gitweb/?p=autoconf.git

$(PKG)_DEPENDS_ON+=m4-host

$(PKG)_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_BUILD_DIR)

$(PKG)_BINARIES            := autoconf autoheader autom4te autoreconf autoscan autoupdate ifnames
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DESTDIR)/bin/%)
$(PKG)_SHARE_TARGET_DIR    := $($(PKG)_DESTDIR)/share/autoconf

$(PKG)_CONFIGURE_OPTIONS += --prefix=$(AUTOCONF_HOST_DESTDIR)

$(PKG)_MAKE_VARS += M4="m4"
$(PKG)_MAKE_VARS += EMACS="no"


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(AUTOCONF_HOST_DIR) \
		$(AUTOCONF_HOST_MAKE_VARS) \
		all
	@touch $@

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.compiled
	$(TOOLS_SUBMAKE) -C $(AUTOCONF_HOST_DIR) \
		$(AUTOCONF_HOST_MAKE_VARS) \
		install
	@touch $@

$(pkg)-fixhardcoded:
	-@$(SED) -i "s!$(TOOLS_HARDCODED_DIR)!$(AUTOCONF_HOST_DESTDIR)!g" \
		$(AUTOCONF_HOST_BINARIES_TARGET_DIR) \
		$(AUTOCONF_HOST_SHARE_TARGET_DIR)/autom4te.cfg

$(pkg)-precompiled: $($(PKG)_DIR)/.installed


$(pkg)-clean:
	-$(MAKE) -C $(AUTOCONF_HOST_DIR) uninstall
	-$(RM) $(AUTOCONF_HOST_DIR)/.{configured,compiled,installed}

$(pkg)-dirclean:
	$(RM) -r $(AUTOCONF_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r \
		$(AUTOCONF_HOST_BINARIES_TARGET_DIR) \
		$(AUTOCONF_HOST_SHARE_TARGET_DIR)/

$(TOOLS_FINISH)
