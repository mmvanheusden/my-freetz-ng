$(call TOOLS_INIT, 1.16.5)
$(PKG)_MAJOR_VERSION:=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=f01d58cd6d9d77fbdca9eb4bbd5ead1988228fdb73d6f7a201f5f8d6b118b469
$(PKG)_SITE:=@GNU/$(pkg_short)
### WEBSITE:=https://www.gnu.org/software/automake/
### MANPAGE:=https://www.gnu.org/software/automake/manual/automake.html
### CHANGES:=https://ftp.gnu.org/gnu/automake/
### CVSREPO:=https://git.savannah.gnu.org/cgit/automake.git

$(PKG)_DEPENDS_ON+=autoconf-host

$(PKG)_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_BUILD_DIR)

$(PKG)_LINKS                 := aclocal automake
$(PKG)_BINARIES              := $(patsubst %, %-$($(PKG)_MAJOR_VERSION), $($(PKG)_LINKS))
$(PKG)_SHARES_FEW            := $($(PKG)_BINARIES)
$(PKG)_SHARES_ALL            := $($(PKG)_BINARIES) aclocal

$(PKG)_LINKS_TARGET_DIR      := $($(PKG)_LINKS:%=$($(PKG)_DESTDIR)/bin/%)
$(PKG)_BINARIES_TARGET_DIR   := $($(PKG)_BINARIES:%=$($(PKG)_DESTDIR)/bin/%)
$(PKG)_SHARES_TARGET_DIR_FEW := $($(PKG)_SHARES_FEW:%=$($(PKG)_DESTDIR)/share/%/)
$(PKG)_SHARES_TARGET_DIR_ALL := $($(PKG)_SHARES_ALL:%=$($(PKG)_DESTDIR)/share/%/)

$(PKG)_CONFIGURE_OPTIONS += --prefix=$(AUTOCONF_HOST_DESTDIR)


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(AUTOMAKE_HOST_DIR) all
	@touch $@

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.compiled
	$(TOOLS_SUBMAKE) -C $(AUTOMAKE_HOST_DIR) install
	@rm -f $($(PKG)_LINKS_TARGET_DIR)
	@touch $@

$($(PKG)_LINKS_TARGET_DIR) : $($(PKG)_DESTDIR)/bin/% : $($(PKG)_DIR)/.installed
	ln -sf "$(notdir $@)-$(call GET_MAJOR_VERSION,$(AUTOMAKE_HOST_VERSION))" "$@"

$(pkg)-fixhardcoded:
	-@$(SED) -i "s!$(TOOLS_HARDCODED_DIR)!$(AUTOMAKE_HOST_DESTDIR)!g" \
		$(AUTOMAKE_HOST_BINARIES_TARGET_DIR) \
		$(patsubst %,%*/*,$(AUTOMAKE_HOST_SHARES_TARGET_DIR_FEW))

$(pkg)-precompiled: $($(PKG)_LINKS_TARGET_DIR)


$(pkg)-clean:
	-$(MAKE) -C $(AUTOMAKE_HOST_DIR) uninstall
	-$(RM) $(AUTOMAKE_HOST_DIR)/.{configured,compiled,installed}

$(pkg)-dirclean:
	$(RM) -r $(AUTOMAKE_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r \
		$(AUTOMAKE_HOST_LINKS_TARGET_DIR) \
		$(AUTOMAKE_HOST_BINARIES_TARGET_DIR) \
		$(AUTOMAKE_HOST_SHARES_TARGET_DIR_ALL)

$(TOOLS_FINISH)
