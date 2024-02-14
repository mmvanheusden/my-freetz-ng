#!/bin/sh

. /usr/lib/libmodcgi.sh

sec_begin "$(lang de:"Starttyp" en:"Start type")"
cgi_print_radiogroup_service_starttype "enabled" "$PCSC_LITE_ENABLED" "" "" 0
sec_end

sec_begin "$(lang de:"Konfiguration" en:"Configuration")"

cat << EOF
<ul>
<li><a href="$(href file pcsc-lite conf)">$(lang de:"reader.conf bearbeiten" en:"Edit reader.conf")</a></li>
</ul>
EOF

sec_end


sec_begin "$(lang de:"Erweitert" en:"Advanced")"

cat << EOF
<h2>$(lang de:"Zus&auml;tzliche Kommandozeilen-Optionen (f&uuml;r Experten)" en:"Additional command-line options (for experts)"):</h2>
EOF
cgi_print_textline_p "options" "$PCSC_LITE_OPTIONS" 20/255 "$(lang de:"Optionen" en:"Options"): "

sec_end

