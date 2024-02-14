[ "$FREETZ_PATCH_MODFS_BOOT_MANAGER" == "y" ] || return 0
echo1 "adding yf-bootmanager"

[ "$FREETZ_VERBOSITY_LEVEL" -lt "2" ] 2>/dev/null && exec >/dev/null
TEMPDIR=$(mktemp -d)
for oem in $(supported_brandings) all; do
	www_oem="${FILESYSTEM_MOD_DIR}/usr/www/${oem}"
	[ -d "${www_oem}" -a ! -L "${www_oem}" ] || continue

	echo2 "processing branding: ${oem}"
	pushd "${TOOLS_DIR}/yf/bootmanager" >/dev/null
	TMP="$TEMPDIR" \
	  TARGET_SYSTEM_VERSION="${AVM_FW_MAJOR}.${AVM_FW_VERSION}" \
	  TARGET_DIR="../../../${FILESYSTEM_MOD_DIR}" \
	  TARGET_BRANDING="${oem}" \
	  sh "add_to_system_reboot.sh" 2>&1 | sed 's/^/      /g'
	popd >/dev/null
done
rmdir "$TEMPDIR"
[ "$FREETZ_VERBOSITY_LEVEL" -lt "2" ] 2>/dev/null && exec >$(tty)

