
has_swap() {
	[ -e /proc/swaps ] && sed '1d' /proc/swaps | grep -q ''
}

decim="$(lang de:"," en:".")"
format_value() {
	[ $1 -ge 10 ] && local val=$1 || local val="0$1"
	echo $val | sed -r "s/(.*)(.)$/\1$decim\2/"
}

read_meminfo() {
	eval "$(sed -rne "/^((Mem|Swap)(Total|Free)|(|Swap)Cached):/ s/^([^:]*):[[:space:]]*([0-9]*).*$/mem_\1=\2/p" /proc/meminfo)"
}
read_meminfo


# RAM
sec_begin "$(lang de:"Arbeitsspeicher" en:"Main memory") (RAM)"
total=$(($mem_MemTotal*10/1024))
free=$(($mem_MemFree*10/1024))
cached=$(($mem_Cached*10/1024))
let usedwc="total-cached-free"
let percent="100*usedwc/total"
let perc_buff="100*cached/total"
total="$(format_value $total)"
free="$(format_value $free)"
cached="$(format_value $cached)"
usedwc="$(format_value $usedwc)"
echo "<div>$usedwc MB (+ $cached MB $(lang de:"Cache" en:"cache")) $(lang de:"von" en:"of") $total MB $(lang de:"belegt" en:"used"), $free MB $(lang de:"frei" en:"free")</div>"
stat_bar br $percent $perc_buff
sec_end

# SWAP
if has_swap; then
	sec_begin "$(lang de:"Swap-Speicher" en:"Swap space") (RAM)"
	total=$(($mem_SwapTotal*10/1024))
	free=$(($mem_SwapFree*10/1024))
	cached=$(($mem_SwapCached*10/1024))
	let usedwc="total-cached-free"
	let percent="100*usedwc/total"
	let perc_buff="100*cached/total"
	total="$(format_value $total)"
	free="$(format_value $free)"
	cached="$(format_value $cached)"
	usedwc="$(format_value $usedwc)"
	echo "<div>$usedwc MB (+ $cached MB $(lang de:"Cache" en:"cache")) $(lang de:"von" en:"of") $total MB $(lang de:"belegt" en:"used"), $free MB $(lang de:"frei" en:"free")</div>"
	stat_bar br $percent $perc_buff
	sec_end
fi

# TFFS
if [ "$MOD_MOUNTED_TFFS" == "yes" ]; then
	sec_begin "$(lang de:"Flash-Speicher" en:"Flash memory") (TFFS)"
	echo info > /proc/tffs
	percent=$(grep '^fill=' /proc/tffs)
	percent=${percent#fill=}
	let tffs_size="0x$(awk '/tffs/ { print $2; exit }' /proc/mtd)/1024"
	if [ -z "$tffs_size" ]; then  # Puma7
		mmcp="$(sed -rn 's!.*block2mtd: /dev/!!p' /proc/mtd)"
		[ -n "$mmcp" ] && tffs_size="$(grep "${mmcp//\"/}$" /proc/partitions | awk '{ print $3; exit }')"
	fi
	let tffs_used="tffs_size*percent/100"
	let tffs_free="tffs_size - tffs_used"
	echo "<div>$tffs_used kB $(lang de:"von" en:"of") $tffs_size kB $(lang de:"belegt" en:"used"), $tffs_free kB $(lang de:"frei" en:"free")</div>"
	stat_bar $percent
	sec_end
fi

# NVRAM
if [ -d "/nvram" ] && [ "$MOD_MOUNTED_NVRAM" == "yes" ]; then
	sec_begin "$(lang de:"Config-Speicher" en:"Config memory") (NVRAM)"
	nvram_df="$(df /nvram 2>/dev/null | tail -n1)"
	nvram_size="$(echo "$nvram_df" | awk '{ print $2; exit }')"
	nvram_used="$(echo "$nvram_df" | awk '{ print $3; exit }')"
	nvram_free="$(echo "$nvram_df" | awk '{ print $4; exit }')"
	nvram_perc="$(echo "$nvram_df" | awk '{ print $5; exit }')"
	echo "<div>$nvram_used kB $(lang de:"von" en:"of") $nvram_size kB $(lang de:"belegt" en:"used"), $nvram_free kB $(lang de:"frei" en:"free")</div>"
	stat_bar ${nvram_perc/%}
	sec_end
fi

