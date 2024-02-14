#!/bin/sh


PATH=/bin:/usr/bin:/sbin:/usr/sbin
. /usr/lib/libmodcgi.sh

cgi --id=freetz

# (svn log --quiet | sed -rn 's/^r[^|]*.([^|]*).*/\1/p' ; echo -e 'TobjasR\nL3P3\nhermann72pb\njohnbock\nM66B\nmagenbrot\nreiffert\nsf3978') | sed 's/(.*)//g;s/ //g' | sort -u | grep -vE '^(root|administrator|github-actions|dependabot\[bot\]|fda77|oliver|derheimi|sfritz|SvenLuebke)$' 
cgi_begin "$(lang de:"&Uuml;ber" en:"About")"
cat << EOF | sed -r 's/(.+[^>])$/\1<br>/g'
<center>

<p>
<h1>Supporters</h1>
abraXxl
aholler
Alex
asmcc
berndy2001
buehmann
BugReporter-ilKY
cawidtu
ChihabDjaidja
cinereous
cm8
Conan179
cuma
Dirk
e6e7e8
er13
f-666
feedzapper
fesc2000
fidelio-dev
flosch-dev
forenuser
FriederBluemle
Greg57070
GregoryAUZANNEAU
Grische
Hadis
harryboo
HerbertNowak
hermann72pb
Himan2001
hippie2000
horle
id1508
idealist1508
JanpieterSollie
JasperMichalke
JBBgameich
Jens
jer194
johnbock
kriegaex
L3P3
leo22
lherschi
M66B
magenbrot
Marcel
markuschen
MartenRingwelski
martinkoehler
Maurits
MaxMuster
maz
McNetic
MichaelHeimpold
mickey
mike
milahu
MilanHauth
mrtnmtth
Oliver
openfnord
PeterFichtner
PeterMeiser
PeterPawn
Rainer
ralf
ralfhartmann
reiffert
RolfLeggewie
SaMMy-lacht
SebastianErtz
sf3978
sfritz2
smischke
stblassitude
SvenLübke
telsch
thiloms
TobjasR
uwes-ufo
Whoopie
WileC
</p>

</center>
EOF
cgi_end

