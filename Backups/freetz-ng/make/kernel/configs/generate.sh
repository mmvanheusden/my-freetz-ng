#! /usr/bin/env bash
MYPWD="$(dirname $(realpath $0))"
cd "$MYPWD"

for i in avm/config-*; do
	[ "$i" != "${i%--not-available}" ] && continue
	i=$(basename $i)
	sed -r -e 's,=n$,=m,' "avm/$i" | diff -du --label "avm/$i" --label "freetz/$i" - freetz/$i > diffs/$i.diff
done

exit 0

