$(call PKG_INIT_BIN, 2.37)
$(PKG)_SOURCE:=$(pkg)-$($(PKG)_VERSION).tar.bz2
$(PKG)_HASH:=fa9ca4d13871dd122f61258a80d01751d603b4d3ee14095d65453b4e846e17d7
$(PKG)_SITE:=@SF/dejavu,https://github.com/dejavu-fonts/dejavu-fonts/releases/download/version_$(subst .,_,$($(PKG)_VERSION))
### WEBSITE:=https://dejavu-fonts.github.io/
### MANPAGE:=https://dejavu-fonts.org/
### CHANGES:=https://dejavu-fonts.github.io/Download.html
### CVSREPO:=https://github.com/dejavu-fonts/dejavu-fonts

$(PKG)_FONTS_ALL += DejaVuMathTeXGyre
$(PKG)_FONTS_ALL += DejaVuSans-BoldOblique
$(PKG)_FONTS_ALL += DejaVuSans-Bold
$(PKG)_FONTS_ALL += DejaVuSansCondensed-BoldOblique
$(PKG)_FONTS_ALL += DejaVuSansCondensed-Bold
$(PKG)_FONTS_ALL += DejaVuSansCondensed-Oblique
$(PKG)_FONTS_ALL += DejaVuSansCondensed
$(PKG)_FONTS_ALL += DejaVuSans-ExtraLight
$(PKG)_FONTS_ALL += DejaVuSansMono-BoldOblique
$(PKG)_FONTS_ALL += DejaVuSansMono-Bold
$(PKG)_FONTS_ALL += DejaVuSansMono-Oblique
$(PKG)_FONTS_ALL += DejaVuSansMono
$(PKG)_FONTS_ALL += DejaVuSans-Oblique
$(PKG)_FONTS_ALL += DejaVuSans
$(PKG)_FONTS_ALL += DejaVuSerif-BoldItalic
$(PKG)_FONTS_ALL += DejaVuSerif-Bold
$(PKG)_FONTS_ALL += DejaVuSerifCondensed-BoldItalic
$(PKG)_FONTS_ALL += DejaVuSerifCondensed-Bold
$(PKG)_FONTS_ALL += DejaVuSerifCondensed-Italic
$(PKG)_FONTS_ALL += DejaVuSerifCondensed
$(PKG)_FONTS_ALL += DejaVuSerif-Italic
$(PKG)_FONTS_ALL += DejaVuSerif
$(PKG)_FONTS_SELECTED:=$(call PKG_SELECTED_SUBOPTIONS,$($(PKG)_FONTS_ALL))

$(PKG)_FONTS:=$($(PKG)_FONTS_SELECTED:%=%.ttf)
$(PKG)_FONTS_DIR:=$($(PKG)_DEST_DIR)/usr/share/fonts/dejavu-sans-fonts

$(PKG)_FONTS_BUILD_DIR:=$($(PKG)_FONTS:%=$($(PKG)_DIR)/ttf/%)
$(PKG)_FONTS_TARGET_DIR:=$($(PKG)_FONTS:%=$($(PKG)_FONTS_DIR)/%)


$(PKG_SOURCE_DOWNLOAD)
$(PKG_UNPACKED)
$(PKG_CONFIGURED_NOP)

$($(PKG)_FONTS_BUILD_DIR): $($(PKG)_DIR)/.configured

$($(PKG)_FONTS_TARGET_DIR): $($(PKG)_FONTS_DIR)/%: $($(PKG)_DIR)/ttf/%
	$(INSTALL_FILE)

$(pkg):

$(pkg)-precompiled: $($(PKG)_FONTS_TARGET_DIR)


$(pkg)-clean:

$(pkg)-uninstall:
	$(RM) -r $(DEJAVU_FONTS_TTF_FONTS_DIR)

$(PKG_FINISH)
