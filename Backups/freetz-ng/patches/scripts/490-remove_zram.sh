[ "$FREETZ_REMOVE_ZRAM" == "y" ] || return 0
echo1 "removing zram files"

rm_files \
  "${FILESYSTEM_MOD_DIR}/etc/init.d/S40-swap" \
  "${FILESYSTEM_MOD_DIR}/etc/boot.d/core/swap" \
  "${FILESYSTEM_MOD_DIR}/etc/modules-load.d/swap.conf" \
  "${MODULES_DIR}/kernel/drivers/staging/zram/zram.ko" \
  "${MODULES_DIR}/kernel/drivers/block/zram/zram.ko" \
  "${MODULES_DIR}/kernel/lib/lzo/lzo_compress.ko"

supervisor_delete_service "swap"

echo1 "patching rc.conf"
modsed "s/CONFIG_SWAP=.*$/CONFIG_SWAP=\"n\"/g" "${FILESYSTEM_MOD_DIR}/etc/init.d/rc.conf"

