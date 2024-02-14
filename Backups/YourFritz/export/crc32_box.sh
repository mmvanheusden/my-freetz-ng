#! /bin/sh
# SPDX-License-Identifier: GPL-2.0-or-later
#
# compute CRC32 check sum for a file with shell commands only
# replace AVM's "testvalue" with another binary/wrapper, if
# not running on a FRITZ!Box
#
tv=/bin/testvalue
test -x $tv || exit 1
td=/var/tmp/crc$(date +%s)
cleanup()
{
	test ${#td} -gt 12 && rm -r $td
}
trap cleanup EXIT HUP TERM KILL
mkdir -p $td
cat - >$td/input
i=0
while [ $i -lt 256 ]; do
	r=$i
	j=0
	while [ $j -lt 8 ]; do
		if [ $(( r&1 )) -eq 1 ]; then
			r=$(( ((r>>1)&0x7FFFFFFF)^0xEDB88320 ))
		else
			r=$(( (r>>1)&0x7FFFFFFF ))
		fi
		let j+=1
	done
	eval crc_$i=$r
	let i+=1
done
crc=-1
fs=$(stat -c %s $td/input)
filesize=$fs
offset=0
while [ $fs -gt 0 ]; do
	if [ $fs -ge 4 ]; then
		size=4
	else
		if [ $fs -ge 2 ]; then
			size=2
		else
			size=1
		fi
	fi
	value=$($tv $td/input $size $offset)
	let offset+=size
	let fs-=size
	k=0
	while [ $k -lt $size ]; do
		byte=$(( (value>>((size-1-k)*8))&255 ))
		i=$(( (crc&255)^byte ))
		eval v=\$crc_$i
		crc=$(( ((crc>>8)&0x00FFFFFF)^v ))
		let k+=1
	done
	if [ ${#1} -gt 0 ]; then
		percent=$(( offset*100/filesize ))
		echo -n -e "\r$offset / $filesize = $percent%" 1>&2
	fi
done
if [ ${#1} -gt 0 ]; then
	echo -n -e "\r\x1B[K" 1>&2
fi
let crc=~crc
if [ $crc -lt 0 ]; then
	crc=$(printf "%X" $crc)
	offset=$(( ${#crc}-8 ))
	crc=${crc:$offset}
	printf "%s\n" $crc
else
	printf "%08X\n" $crc
fi
