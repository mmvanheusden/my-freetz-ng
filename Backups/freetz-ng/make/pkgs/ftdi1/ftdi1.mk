$(call PKG_INIT_BIN, 1.5)
$(PKG)_LIB_VERSION:=2.5.0
$(PKG)_SOURCE:=lib$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=7c7091e9c86196148bd41177b4590dccb1510bfe6cea5bf7407ff194482eb049
$(PKG)_SITE:=https://www.intra2net.com/en/developer/libftdi/download
### WEBSITE:=https://www.intra2net.com/en/developer/libftdi/
### MANPAGE:=https://www.intra2net.com/en/developer/libftdi/documentation/
### CHANGES:=https://www.intra2net.com/en/developer/libftdi/index.php
### CVSREPO:=http://developer.intra2net.com/git/?p=libftdi

$(PKG)_BINARY:=$($(PKG)_DIR)/ftdi_eeprom/ftdi_eeprom
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/ftdi_eeprom

$(PKG)_FILE:=lib$(pkg).so.$($(PKG)_LIB_VERSION)
$(PKG)_LIB_BINARY:=$($(PKG)_DIR)/src/$($(PKG)_FILE)
$(PKG)_LIB_STAGING_BINARY:=$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/$($(PKG)_FILE)
$(PKG)_LIB_TARGET_BINARY:=$($(PKG)_TARGET_LIBDIR)/$($(PKG)_FILE)

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_FTDI1

$(PKG)_DEPENDS_ON += libusb1
$(PKG)_DEPENDS_ON += $(if $(FREETZ_PACKAGE_FTDI1),libconfuse)
$(PKG)_DEPENDS_ON += cmake-host

$(PKG)_CONFIGURE_OPTIONS += -Wno-dev

$(PKG)_CONFIGURE_OPTIONS += -DCMAKE_INSTALL_PREFIX="/"
$(PKG)_CONFIGURE_OPTIONS += -DCMAKE_SKIP_INSTALL_RPATH=NO
$(PKG)_CONFIGURE_OPTIONS += -DCMAKE_SKIP_RPATH=YES
$(PKG)_CONFIGURE_OPTIONS += -DCMAKE_BUILD_TYPE=Release
$(PKG)_CONFIGURE_OPTIONS += -DBUILD_TESTS=OFF
$(PKG)_CONFIGURE_OPTIONS += -DDOCUMENTATION=OFF
$(PKG)_CONFIGURE_OPTIONS += -DEXAMPLES=OFF
$(PKG)_CONFIGURE_OPTIONS += -DLINK_PYTHON_LIBRARY=OFF
$(PKG)_CONFIGURE_OPTIONS += -DSTATICLIBS=ON
$(PKG)_CONFIGURE_OPTIONS += -DFTDIPP=OFF
$(PKG)_CONFIGURE_OPTIONS += -DFTDI_EEPROM=$(if $(FREETZ_PACKAGE_FTDI1),ON,OFF)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CMAKE)

$($(PKG)_BINARY) $($(PKG)_LIB_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(FTDI1_DIR)
#cmake	cd $(GETDNS_DIR) && cmake -LA .

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$($(PKG)_LIB_STAGING_BINARY): $($(PKG)_LIB_BINARY)
	$(SUBMAKE) -C $(FTDI1_DIR) \
		DESTDIR="$(TARGET_TOOLCHAIN_STAGING_DIR)" \
		install
	$(PKG_FIX_LIBTOOL_LA) \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/pkgconfig/{libftdi1,libftdipp1}.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/libftdi1-config
#		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/lib/libftdi1.la
	@touch -c $@

$($(PKG)_LIB_TARGET_BINARY): $($(PKG)_LIB_STAGING_BINARY)
	$(INSTALL_LIBRARY_STRIP)

$(pkg): $($(PKG)_LIB_STAGING_BINARY)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY) $($(PKG)_LIB_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(FTDI1_DIR) clean
	$(RM) -r \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/bin/ftdi_eeprom \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/usr/share/doc/libftdi1/ \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/cmake/libftdi1/ \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/libftdi1.* \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/lib/pkgconfig/{libftdi1,libftdipp1}.pc \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/bin/libftdi1-config \
		$(TARGET_TOOLCHAIN_STAGING_DIR)/include/libftdi1/

$(pkg)-uninstall:
	$(RM) $(FTDI1_TARGET_BINARY) $(FTDI1_TARGET_LIBDIR)/libftdi1.so*

$(call PKG_ADD_LIB,libftdi1)
$(PKG_FINISH)
