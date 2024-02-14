[ "$FREETZ_ENABLE_GPON_SERIAL" == "y" ] || return 0
echo1 "re-adding GPON serial textbox"

replace_lua_function \
  $HTML_LANG_MOD_DIR/support.lua \
  "gpon_serial.show" \
  "config.GPON"

