$(call PKG_INIT_BIN, $(if $(FREETZ_PACKAGE_PYLOAD_VERSION_ABANDON),v0.4.20,78162d757d767f5e1436043fd84bf19ca72e8f53))
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.xz
$(PKG)_HASH_ABANDON:=d017b5ab7ba21db04da6b308a52861255e0bdd3b0809e4a771c1e0ffecabee72
$(PKG)_HASH_CURRENT:=c21a8bf17c87e8a50f54c415ff29c0df94814d1ac31f04b6168b68835957d0ac
$(PKG)_HASH:=$($(PKG)_HASH_$(if $(FREETZ_PACKAGE_PYLOAD_VERSION_ABANDON),ABANDON,CURRENT))
$(PKG)_SITE:=git@https://github.com/pyload/pyload.git
### VERSION:=0.4.20/78162d75
### WEBSITE:=https://www.pyload.net/
### MANPAGE:=https://github.com/pyload/pyload/wiki
### CHANGES:=https://github.com/pyload/pyload/releases
### CVSREPO:=https://github.com/pyload/pyload/commits/

$(PKG)_TARGET_BINARY:=$($(PKG)_DEST_DIR)/opt/pyLoad/pyLoadCore.py

$(PKG)_CONDITIONAL_PATCHES+=$(if $(FREETZ_PACKAGE_PYLOAD_VERSION_ABANDON),abandon,current)

define pyLoad/build/files
.build-prereq-checked
.unpacked
.configured
.exclude
endef

define pyLoad/unnecessary/files
.hgignore
.gitattributes
docs
icons
LICENSE
locale
module/cli
module/gui
module/lib/wsgiserver/LICENSE.txt
module/web/servers
pavement.py
pyLoadCli.py
pyLoadGui.py
README
scripts
setup.cfg
systemCheck.py
testlinks.txt
tests
endef


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_DIR)/.exclude: $($(PKG)_DIR)/.configured
	@$(call write-list-to-file,$(call newline2space,$(pyLoad/build/files)) $(call newline2space,$(pyLoad/unnecessary/files)),$@)

$($(PKG)_TARGET_BINARY): $($(PKG)_DIR)/.exclude
	@mkdir -p $(dir $@); \
	$(call COPY_USING_TAR,$(PYLOAD_DIR),$(dir $@),--exclude-from=$< .) \
	touch -c $@

$(pkg):

$(pkg)-precompiled: $($(PKG)_TARGET_BINARY)


$(pkg)-clean:
	$(RM) $(PYLOAD_DIR)/.exclude

$(pkg)-uninstall:
	$(RM) -r $(dir $(PYLOAD_TARGET_BINARY))

$(PKG_FINISH)
