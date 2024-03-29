$(call PKG_INIT_BIN, 4.2.1)
$(PKG)_SOURCE:=make-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=d6e262bf3601b42d2b1e4ef8310029e1dcf20083c5446b4b7aa67081fdffc589
$(PKG)_SITE:=@GNU/make

$(PKG)_BINARY:=$($(PKG)_DIR)/make
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/bin/make

$(PKG)_CONFIGURE_ENV += ac_cv_lib_elf_elf_begin=no

$(PKG)_CONFIGURE_ENV += make_cv_sys_gnu_glob=no
$(PKG)_CONFIGURE_ENV += GLOBINC='-Iglob/'
$(PKG)_CONFIGURE_ENV += GLOBLIB=glob/libglob.a

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(GNU_MAKE_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(GNU_MAKE_DIR) clean

$(pkg)-uninstall:
	$(RM) $(GNU_MAKE_TARGET_BINARY)

$(PKG_FINISH)
