$(call TOOLS_INIT, 3.28.3)
$(PKG)_MAJOR_VERSION:=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION))
$(PKG)_SOURCE:=$(pkg_short)-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=72b7570e5c8593de6ac4ab433b73eab18c5fb328880460c86ce32608141ad5c1
$(PKG)_SITE:=https://github.com/Kitware/CMake/releases/download/v$($(PKG)_VERSION)
### WEBSITE:=https://cmake.org/
### MANPAGE:=https://cmake.org/cmake/help/latest/
### CHANGES:=https://github.com/Kitware/CMake/releases
### CVSREPO:=https://gitlab.kitware.com/cmake/cmake

$(PKG)_DEPENDS_ON+=ninja-host

$(PKG)_DESTDIR:=$(FREETZ_BASE_DIR)/$(TOOLS_DIR)/build

$(PKG)_BINARIES            := ccmake cmake cpack ctest
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_DESTDIR)/bin/%)
$(PKG)_SHARE_TARGET_DIR    := $($(PKG)_DESTDIR)/share/$(pkg_short)-$($(PKG)_MAJOR_VERSION)
$(PKG)_DOC_TARGET_DIR      := $($(PKG)_DESTDIR)/doc/$(pkg_short)-$($(PKG)_MAJOR_VERSION)


$(PKG)_CONFIGURE_OPTIONS += --prefix=$(CMAKE_HOST_DESTDIR)
$(PKG)_CONFIGURE_OPTIONS += --generator=Ninja
$(PKG)_CONFIGURE_OPTIONS += --enable-ccache
$(PKG)_CONFIGURE_OPTIONS += --no-qt-gui
$(PKG)_CONFIGURE_OPTIONS += --no-system-libs
$(PKG)_CONFIGURE_OPTIONS += --
$(PKG)_CONFIGURE_OPTIONS += -DCMAKE_USE_OPENSSL=OFF
#$(PKG)_CONFIGURE_OPTIONS += -DOPENSSL_USE_STATIC_LIBS=TRUE


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_CONFIGURE)

$($(PKG)_DIR)/.compiled: $($(PKG)_DIR)/.configured
	$(TOOLS_SUBNINJA) -C $(CMAKE_HOST_DIR) all
	@touch $@

$($(PKG)_DIR)/.installed: $($(PKG)_DIR)/.compiled
	$(TOOLS_SUBNINJA) -C $(CMAKE_HOST_DIR) install
	@$(RM) -r "$(CMAKE_HOST_DOC_TARGET_DIR)"
	@rmdir "$(dir $(CMAKE_HOST_DOC_TARGET_DIR))" || true
	@touch $@

$(pkg)-precompiled: $($(PKG)_DIR)/.installed


$(pkg)-clean:
	-$(NINJA) -C $(CMAKE_HOST_DIR) uninstall
	-$(RM) $(CMAKE_HOST_DIR)/.{configured,compiled,installed}

$(pkg)-dirclean:
	$(RM) -r $(CMAKE_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) -r \
		$(CMAKE_HOST_BINARIES_TARGET_DIR) \
		$(CMAKE_HOST_SHARE_TARGET_DIR)

$(TOOLS_FINISH)
