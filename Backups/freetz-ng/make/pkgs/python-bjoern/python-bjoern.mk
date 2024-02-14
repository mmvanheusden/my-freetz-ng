$(call PKG_INIT_BIN, 37d28e5645)
$(PKG)_SOURCE:=bjoern-$($(PKG)_VERSION).tar.gz
$(PKG)_HASH:=8a4a25f1357036b6a890c0dc35c34ffffd05b22294e7e205ff01c9af3b88fe65
$(PKG)_SITE:=git@https://github.com/jonashaag/bjoern.git

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/bjoern.so

$(PKG)_DEPENDS_ON += python libev

$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_PYTHON_STATIC

$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.configured
	$(call Build/PyMod/PKG, PYTHON_BJOERN)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)

$(pkg)-clean:
	-$(SUBMAKE) -C $(PYTHON_BJOERN_DIR) clean

$(pkg)-uninstall:
	$(RM) -r \
		$(PYTHON_BJOERN_TARGET_BINARY) \
		$(PYTHON_BJOERN_DEST_DIR)$(PYTHON_SITE_PKG_DIR)/bjoern-*.egg-info

$(PKG_FINISH)
