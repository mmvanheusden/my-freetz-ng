$(call TOOLS_INIT, 2.1.1)
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=3a224f2accf091b77a5781316e27b9ee3ba82c083cc2e539e08940b68a44fec5
$(PKG)_SITE:=https://distfiles.ariadne.space/pkgconf
### WEBSITE:=http://pkgconf.org/
### MANPAGE:=http://pkgconf.org/features.html
### CHANGES:=https://github.com/pkgconf/pkgconf/blob/master/NEWS
### CVSREPO:=https://github.com/pkgconf/pkgconf/tags

$(PKG)_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_BUILD_DIR)

$(PKG)_BINARIES            := pkgconf bomtool
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DESTDIR)/bin/%)

$(PKG)_WRAPPER             := pkg-config
$(PKG)_WRAPPER_SOURCE      := $($(PKG)_MAKE_DIR)/src/$($(PKG)_WRAPPER)
$(PKG)_WRAPPER_TARGET      := $($(PKG)_DESTDIR)/bin/$($(PKG)_WRAPPER)

$(PKG)_CONFIGURE_OPTIONS += --prefix=$(PKGCONF_HOST_DESTDIR)


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(PKGCONF_HOST_DIR) \
		LDFLAGS="$(TOOLS_LDFLAGS) -static" \
		all
	@touch $@

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.compiled
	$(TOOLS_SUBMAKE) -C $(PKGCONF_HOST_DIR) install
	@touch $@

$($(PKG)_WRAPPER_TARGET): $($(PKG)_WRAPPER_SOURCE)
	cp $< $@

$(pkg)-precompiled: $($(PKG)_DIR)/.installed $($(PKG)_WRAPPER_TARGET)


$(pkg)-clean:
	-$(MAKE) -C $(PKGCONF_HOST_DIR) uninstall
	-$(RM) $(PKGCONF_HOST_DIR)/.{configured,compiled,installed}

$(pkg)-dirclean:
	$(RM) -r $(PKGCONF_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r \
		$(PKGCONF_HOST_WRAPPER_TARGET) \
		$(PKGCONF_HOST_BINARIES_TARGET_DIR) \
		$(PKGCONF_HOST_DESTDIR)/include/pkgconf/libpkgconf/ \
		$(PKGCONF_HOST_DESTDIR)/lib/libpkgconf.* \
		$(PKGCONF_HOST_DESTDIR)/lib/pkgconfig/libpkgconf.pc \
		$(PKGCONF_HOST_DESTDIR)/share/aclocal/pkg.m4

$(TOOLS_FINISH)
