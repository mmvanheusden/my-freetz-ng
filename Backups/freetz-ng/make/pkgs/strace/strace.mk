$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_STRACE_VERSION_4),4.9,$(if $(FREETZ_PACKAGE_STRACE_VERSION_5),5.0,6.7)))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH_4:=095bfea5c540b91d297ccac73b21b92fd54a24599fd70395db87ff9eb7fd6f65
$(PKG)_HASH_5:=3b7ad77eb2b81dc6078046a9cc56eed5242b67b63748e7fc28f7c2daf4e647da
$(PKG)_HASH_6:=2090201e1a3ff32846f4fe421c1163b15f440bb38e31355d09f82d3949922af7
$(PKG)_HASH:=$($(PKG)_HASH_$(call GET_MAJOR_VERSION,$($(PKG)_VERSION),1))
$(PKG)_SITE:=https://www.strace.io/files/$($(PKG)_VERSION),https://github.com/strace/strace/releases/download/v$($(PKG)_VERSION)
### WEBSITE:=https://www.strace.io/
### MANPAGE:=https://man7.org/linux/man-pages/man1/strace.1.html
### CHANGES:=https://github.com/strace/strace/releases
### CVSREPO:=https://github.com/strace/strace

$(PKG)_CONDITIONAL_PATCHES+=$(call GET_MAJOR_VERSION,$($(PKG)_VERSION),1)

# MIPS definitions for SO_PROTOCOL / SO_DOMAIN in AVM kernel sources for 7390.06.5x-8x
# differ from that of vanilla sources because of incorrect backport.
# s. https://github.com/Freetz/freetz/issues/208 for more details
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_STRACE_VERSION_4
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_STRACE_VERSION_5
$(PKG)_REBUILD_SUBOPTS += FREETZ_PACKAGE_STRACE_VERSION_6

$(PKG)_CONFIGURE_PRE_CMDS += $(call PKG_ADD_EXTRA_FLAGS,(C|CPP)FLAGS)
$(PKG)_EXTRA_CPPFLAGS += $(if $(and $(FREETZ_SYSTEM_TYPE_IKS),$(FREETZ_AVM_VERSION_06_5X_MIN)),-D_AVM_WRONG_SOCKET_OPTIONS_CODES=1)

$(PKG)_BINARY:=$($(PKG)_DIR)$(if $(FREETZ_PACKAGE_STRACE_VERSION_6),/src/,/)strace
$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/usr/sbin/strace
$(PKG)_CATEGORY:=Debug helpers

$(PKG)_CONFIGURE_ENV += ac_cv_header_linux_netlink_h=yes


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_CONFIGURE)

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(SUBMAKE) -C $(STRACE_DIR) \
		EXTRA_CPPFLAGS="$(STRACE_EXTRA_CPPFLAGS)"

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_BINARY_STRIP)

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(SUBMAKE) -C $(STRACE_DIR) clean

$(pkg)-uninstall:
	$(RM) $(STRACE_TARGET_BINARY)

$(PKG_FINISH)
