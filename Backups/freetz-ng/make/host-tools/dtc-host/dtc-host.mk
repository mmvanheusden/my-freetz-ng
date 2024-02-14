$(call TOOLS_INIT, 1.7.0)
$(PKG)_SOURCE:=dtc-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH:=29edce3d302a15563d8663198bbc398c5a0554765c83830d0d4c0409d21a16c4
$(PKG)_SITE:=@KERNEL/software/utils/dtc

$(PKG)_INSTALL_DIR := $(TOOLS_DIR)/fit

$(PKG)_BINARIES            := dtc fdtdump fdtget fdtput fitdump
$(PKG)_BINARIES_BUILD_DIR  := $($(PKG)_BINARIES:%=$($(PKG)_DIR)/%)
$(PKG)_BINARIES_TARGET_DIR := $($(PKG)_BINARIES:%=$($(PKG)_INSTALL_DIR)/%)


# dtc-host and dtc using the same source
$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)
$(TOOLS_CONFIGURED_NOP)

$($(PKG)_BINARIES_BUILD_DIR): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBMAKE) -C $(DTC_HOST_DIR) $(DTC_HOST_BINARIES)

$($(PKG)_BINARIES_TARGET_DIR): $($(PKG)_INSTALL_DIR)/%: $($(PKG)_DIR)/%
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_BINARIES_TARGET_DIR)


$(pkg)-clean:
	-$(MAKE) -C $(DTC_HOST_DIR) clean

$(pkg)-dirclean:
	$(RM) -r $(DTC_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) \
		$(DTC_HOST_INSTALL_DIR)/dtc \
		$(DTC_HOST_INSTALL_DIR)/fdtget \
		$(DTC_HOST_INSTALL_DIR)/fdtdump \
		$(DTC_HOST_INSTALL_DIR)/fdtput \
		$(DTC_HOST_INSTALL_DIR)/mkimage \
		$(DTC_HOST_INSTALL_DIR)/fitdump

$(TOOLS_FINISH)
