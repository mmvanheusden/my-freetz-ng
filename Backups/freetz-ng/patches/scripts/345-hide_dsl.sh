[ "$FREETZ_REMOVE_MULTI_ANNEX_FIRMWARE_PRIME" == "y" -o \
  "$FREETZ_REMOVE_ANNEX_A_FIRMWARE" == "y" -o \
  "$FREETZ_REMOVE_ANNEX_B_FIRMWARE" == "y" -o \
  "$FREETZ_REMOVE_DSLD" == "y" ] || return 0
[ "$FREETZ_ADD_ANNEX_A_FIRMWARE" == "y" ] && return 0
echo1 "hiding dsl"

rm_files \
  "${HTML_LANG_MOD_DIR}/internet/dsl_*.lua" \
  "${HTML_LANG_MOD_DIR}/internet/vdsl_profile.lua"

if [ -e "${HTML_LANG_MOD_DIR}/home/home.lua" ]; then
	# patcht Hauptseite > Kasten Anschluesse > DSL
	[ "$FREETZ_AVM_VERSION_06_2X_MAX" == "y" ] && homelua_disable_wrapper connect_info_dsl
	[ "$FREETZ_AVM_VERSION_06_5X" == "y" ] && modsed -r 's/^(gDataRd.dsl = ).*/\1nil/' "${HTML_LANG_MOD_DIR}/home/home.lua"
	[ "$FREETZ_AVM_VERSION_06_8X_MIN" == "y" ] && modsed 's/^if (data.dsl/& \&\& false/' "${HTML_LANG_MOD_DIR}/home/home.js"
	# patcht Internet > Online-Monitor > Online-Monitor
	modsed \
	  '/^box.out(connection.create_connection_row("inetmon"))$/d' \
	  "${HTML_LANG_MOD_DIR}/internet/inetstat_monitor.lua"
	# patcht Internet > DSL-Informationen (lua)
	sedfile="${HTML_LANG_MOD_DIR}/menus/menu_show.lua"
	if [ -e "$sedfile" ]; then
		modsed 's!not config.ATA or box.query("box:settings/ata_mode") ~= "1"!false!' "$sedfile"
	else
		modsed 's!\["dslInfo"\]!["dslInfoDISABLED"]!' "$MENU_DATA_LUA"
	fi
fi

# patcht Internet > DSL-Informationen (html)
modsed 's/\(setvariable var:showdslinfo \)./\10/' "${HTML_SPEC_MOD_DIR}/menus/menu2_internet.html"

# patcht Uebersicht > Anschlussinformationen
sedfile="${HTML_SPEC_MOD_DIR}/home/home.js"
if [ -e $sedfile ]; then
	echo1 "patching ${sedfile##*/}"
	modsed '/cbDslStateDisplay[^(]/d' $sedfile
fi

# patcht Uebersicht > Anschluesse
mod_del_area \
  'document.write(DslStateLed(' \
  -1 \
  +3 \
  "${HTML_SPEC_MOD_DIR}/home/home.html"

