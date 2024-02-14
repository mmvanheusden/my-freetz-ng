$(call TOOLS_INIT, 0.17)
$(PKG)_SOURCE:=netkit-ftp_$($(PKG)_VERSION).orig.tar.gz
$(PKG)_HASH:=61c913299b81a4671ff089aac821329f7db9bc111aa812993dd585798b700349
$(PKG)_SITE:=https://deb.debian.org/debian/pool/main/n/netkit-ftp
### VERSION:=0.17-35
### WEBSITE:=https://packages.debian.org/source/bullseye/netkit-ftp
### MANPAGE:=https://manpages.debian.org/bullseye/ftp/netkit-ftp.1.en.html
### TRACKER:=https://tracker.debian.org/pkg/netkit-ftp
### CHANGES:=https://launchpad.net/debian/+source/netkit-ftp/+changelog

$(PKG)_DEPENDS_ON+=cmake-host

$(PKG)_BUILD_DIR:=$($(PKG)_DIR)/builddir
$(PKG)_BINARY:=$($(PKG)_BUILD_DIR)/ftp/netkit-ftp
$(PKG)_TARGET_BINARY:=$(TOOLS_DIR)/ftp


$(TOOLS_SOURCE_DOWNLOAD)
$(TOOLS_UNPACKED)

$($(PKG)_DIR)/.configured: $($(PKG)_DIR)/.unpacked
	$(TOOLS_SUBCMAKE) \
		-B $(NETKIT_FTP_HOST_BUILD_DIR) \
		-S $(NETKIT_FTP_HOST_DIR)
	@touch $@

$($(PKG)_BINARY): $($(PKG)_DIR)/.configured
	$(TOOLS_SUBCMAKE) \
		--build $(NETKIT_FTP_HOST_BUILD_DIR)

$($(PKG)_TARGET_BINARY): $($(PKG)_BINARY)
	$(INSTALL_FILE)

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	-$(CMAKE) \
		--build $(NETKIT_FTP_HOST_BUILD_DIR) \
		--target clean
	$(RM) $(NETKIT_FTP_HOST_DIR)/.configured

$(pkg)-dirclean:
	$(RM) -r $(NETKIT_FTP_HOST_DIR)

$(pkg)-distclean: $(pkg)-dirclean
	$(RM) $(NETKIT_FTP_HOST_TARGET_BINARY)

$(TOOLS_FINISH)
