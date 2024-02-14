# Platz sparen im Dateisystem der FritzBox

### Vorwort und Motivation

Dass der Speicherplatz im Dateisystem der FritzBox - insbesondere bei
den heute noch verbreiteten "kleinen" Routern wie der 5050 oder der
7050 - begrenzt ist, dürfte jedem Modder klar sein, der schon einmal
entsprechende Fehlermeldungen von `fwmod` während des Zusammenbauens der
Firmware (FW) gesehen hat und daraufhin anfangen mußte zu überlegen,
welche Freetz-Pakete er weglässt. Diskutiert wird über dieses Problem
bspw. im IPPF-Thread [7050 zu eng: DS-Mod-Teile manuell auf
externe Platte
auslagern](http://www.ip-phone-forum.de/showthread.php?t=132936),
aber auch woanders.

Ohne ein hier ein fertiges "Abspeck-Werkzeug" präsentieren zu wollen,
möchte ich an dieser Stelle einfach mal übersichtshalber zusammenfassen,
welche Mittel und Wege mir derzeit einfallen würden, wenn ich Platz
sparen müsste auf meiner Box. Es geht darum, Hilfe zur Selbsthilfe zu
leisten und ein paar Gedanken mit auf den Weg zu geben, um es jedem zu
ermöglichen, die ihm am erfolgversprechendsten erscheinenden Wege weiter
zu verfolgen. Weder erhebt diese kleine Übersicht Anspruch auf
Vollständigkeit noch auf absolute Korrektheit oder Praxiserprobtheit.
Mit meiner 7170 habe ich momentan keine Platzprobleme, da ich auch nicht
der Typ bin, der "alles" auf seiner Box laufen haben möchte - übrigens
schon der erste und mit effektivste Weg zum Sparen: nicht übertriebene,
aber angemessene Bescheidenheit und Konzentration aufs Notwendige.

### Bestandsaufnahme: Wo stecken die Platzfresser?

Bevor wir darüber nachdenken, an welchen Ecken wir sparen können,
sollten wir uns zunächst einen Überblick darüber verschaffen, wo am
meisten Platz verbraucht wird. Im zweiten Schritt unterscheiden wir dann
zwischen notwendigen und überflüssigen Platzfressern, im Folgenden PFs
genannt. Schließlich gehen wir nach dem
[Pareto-Prinzip](http://de.wikipedia.org/wiki/Pareto-Verteilung#Pareto-Prinzip)
vor, um mit überschaubarem Aufwand einen möglichst hohen Effekt zu
erzielen.

### Schritt 1: Untersuchung Original-Firmware

Welche Dateien verbrauchen am meisten Platz in der Original-Firmware?
Dazu schauen wir uns am einfachsten nach einem `make` das Verzeichnis
an, in welchem die entpackten Firmware-Dateien abgelegt sind:
`build/original/filesystem`. Mit folgendem Befehl durchsuchen wir das
Verzeichnis nach Dateien (`find -type f`) und übergeben all diese
Dateien dem `ls`-Befehl, um diesen dazu veranlassen, sie nach ihrer
Größe absteigend zu sortieren. Als Beispiel diene hier die AVM-FW
29.04.29 für die Box vom Typ 7170. (Der Übersicht halber lasse ich
unwichtige Spalten der Ergebnisliste weg.)

```
	$ cd build/original/filesystem
	$ find . -type f | xargs ls -lSR | more

	1291372 lib/libcrypto.so.0.9.8
	 858208 lib/modules/2.6.13.1-ohio/kernel/drivers/isdn/isdn_fon4/zzz/isdn_fbox.ko
	 730844 lib/modules/2.6.13.1-ohio/kernel/drivers/dsld/kdsldmod.ko
	 551944 usr/bin/telefon
	 473772 lib/modules/2.6.13.1-ohio/kernel/drivers/net/wireless/avm_wlan/wlan/tiap.ko
	 425652 lib/libuClibc-0.9.28.so
	 416632 bin/busybox
	 314836 lib/libavmcsock.so.2.0.0
	 303784 lib/modules/microvoip-dsl.bin
	 283853 lib/modules/microvoip_isdn_top.bit1
	 274704 usr/bin/ctlmgr
	 274352 lib/libsiplib.so.2.0.0
	 259052 lib/libssl.so.0.9.8
	 252344 usr/share/ctlmgr/libtr069.so
	 234684 usr/share/ctlmgr/libfon.so
	 212468 lib/modules/microvoip_isdn_top.bit
	 212432 sbin/dsld
	 202684 lib/libmscodex.so.2.0.0
	 167180 sbin/fsck.ext2
	 163360 sbin/multid
	 158332 lib/modules/2.6.13.1-ohio/kernel/drivers/usb/core/usbcore.ko
	 154224 usr/bin/wpa_authenticator
	 142624 lib/modules/2.6.13.1-ohio/kernel/drivers/atm/avm_atm/tiatm.ko
	 142104 lib/libosipparser2.so.4.0.0
	 134308 lib/modules/2.6.13.1-ohio/kernel/drivers/scsi/scsi_mod.ko
	 132296 lib/libar7cfg.so.1.0.0
	 117056 lib/libm-0.9.28.so
	 116804 bin/voipd
	 106192 lib/modules/fw_dcrhp_1150_ap.bin
	 102712 usr/lib/libext2fs.so.2.4
	 102472 sbin/fdisk
```

Jetzt kann man anfangen zu überlegen, was wohl verzichtbar wäre. Eine
Busybox oder den DSL-Daemon wegzulassen, ergibt keinen Sinn - eher
schon, bei der Busybox auf unnötige Applets zu verzichten. Mancher mag
sich überlegen, dass er die WLAN-Bestandteile nicht braucht, stattdessen
vielleicht lieber mehr Platz für OpenVPN schaffen möchte. Das ist nur
ein Beispiel und unabhängig davon, ob die Box ohne die WLAN-Binaries
überhaupt sauber startet (Kommentar: Das WLAN-Modul, tiap.ko, lässt sich
ohne Probleme entfernen). Wenn man die Dateien weglässt, sollte man z.B.
dafür sorgen, daß die entsprechenden Dienste deaktiviert werden oder in
den entsprechenden Startskripten ggf. Dinge zur Sicherheit
auskommentiert werden. Bei anderen Programmen fällt die Entscheidung
wieder leichter: `fdisk` braucht man beispielsweise im Normalfall nicht,
solange man nicht mit `mkfs.ext2` ein Dateisystem anlegen möchte. Ein
bisschen sparen kann man also, indem man es weglässt, vielleicht die
entscheidenden KB, damit eine andere Erweiterung auf die Box passt. Für
andere Kandidaten wie die
libtr069 gibt es bei den
kleinen Boxen sogar schon Schalter in der
Menükonfiguration von
Freetz, um sie wegzulassen. Im Allgemeinen untersucht man die
Startdateien unter `/etc/init.d`, um herauszufinden, ob und wann eine
bestimmte Datei geladen wird. Bei benötigten Bibliotheken ist die
Analyse etwas schwieriger, aber auch möglich.

### Schritt 2: Untersuchung Mod-Firmware

Das Gleiche, was wir gerade für die Original-Firmware gemacht haben, tun
wir nun für die nach unseren Wünschen konfigurierte Mod-Firmware. Selbst
wenn diese evtl. nicht erfolgreich gebaut werden konnte, weil z.B. der
Platz nicht genügte, sehen wir doch das erzeugte Dateisystem unter
`build/modified/filesystem`. Es folgt ein Beispiel von meiner 7170 mit
Mod-Version ds-0.2.9_26-14.2 und, grob gesprochen, folgenden
aktivierten Optionen und Erweiterungen: 1&1-Branding, keine Hilfetexte
und Assistenten, Original-Kernel, Bftp, Callmonitor, Cifsmount, Dropbear
(nur Server), MC, Mini_fo, Samba, Screen, Syslogd-CGI, WoL-CGI, Lua,
Matrixtunnel. Das sieht dann so aus:

```
	$ cd build/modified/filesystem
	$ find . -type f | xargs ls -lSR | more

	1291372 lib/libcrypto.so.0.9.8
	 913456 usr/sbin/smbd
	 858208 lib/modules/2.6.13.1-ohio/kernel/drivers/isdn/isdn_fon4/zzz/isdn_fbox.ko
	 779956 usr/bin/mc.bin
	 730844 lib/modules/2.6.13.1-ohio/kernel/drivers/dsld/kdsldmod.ko
	 599740 bin/busybox
	 551944 usr/bin/telefon
	 473772 lib/modules/2.6.13.1-ohio/kernel/drivers/net/wireless/avm_wlan/wlan/tiap.ko
	 436344 usr/sbin/nmbd
	 413184 lib/libuClibc-0.9.28.so
	 372060 usr/bin/screen.bin
	 323371 lib/modules/2.6.13.1-ohio/kernel/fs/cifs/cifs.ko
	 314836 lib/libavmcsock.so.2.0.0
	 303784 lib/modules/microvoip-dsl.bin
	 283853 lib/modules/microvoip_isdn_top.bit1
	 274704 usr/bin/ctlmgr
	 274352 lib/libsiplib.so.2.0.0
	 273900 usr/lib/libncurses.so.5.5
	 259052 lib/libssl.so.0.9.8
	 252344 usr/share/ctlmgr/libtr069.so
	 234684 usr/share/ctlmgr/libfon.so
	 212468 lib/modules/microvoip_isdn_top.bit
	 212432 sbin/dsld
	 204336 usr/bin/lua
	 202684 lib/libmscodex.so.2.0.0
	 200256 usr/lib/libreadline.so.5.2
	 183224 usr/sbin/dropbearmulti
	 167180 sbin/fsck.ext2
	 163360 sbin/multid
	 155037 lib/modules/2.6.13.1-ohio/kernel/drivers/usb/core/usbcore.ko
	 154224 usr/bin/wpa_authenticator
	 142624 lib/modules/2.6.13.1-ohio/kernel/drivers/atm/avm_atm/tiatm.ko
	 142104 lib/libosipparser2.so.4.0.0
	 132296 lib/libar7cfg.so.1.0.0
	 132124 lib/modules/2.6.13.1-ohio/kernel/drivers/scsi/scsi_mod.ko
	 131614 usr/share/samba/unicode_map.850
	 117746 usr/lib/mc/mc.hlp
	 116804 bin/voipd
	 116148 lib/libm-0.9.28.so
	 106192 lib/modules/fw_dcrhp_1150_ap.bin
	 102712 usr/lib/libext2fs.so.2.4
	 102472 sbin/fdisk
```

Wir erkennen: Samba, MC und Screen scheinen recht groß zu sein, aber so
richtig übersichtlich ist das Ganze nicht, denn die zuvor analysierten
Dateien der Original-Firmware sind ja immer noch in der Liste. Wenn wir
nur die exklusiv im Mod vorkommenden sehen wollen, müssen wir erst ein
bißchen aussieben:

```
	$ cd build
	$ find original/filesystem -type f | sed 's/^original\/filesystem\///' > orig-files
	$ find modified/filesystem -type f | sed 's/^modified\/filesystem\///' > modi-files
	$ diff -u orig-files modi-files | \
		grep '^+' | grep -v '^+++' | sed 's/^+/modified\/filesystem\//' > new-files
	$ cat new-files | xargs ls -lSR | more

	 913456 usr/sbin/smbd
	 779956 usr/bin/mc.bin
	 436344 usr/sbin/nmbd
	 372060 usr/bin/screen.bin
	 323371 lib/modules/2.6.13.1-ohio/kernel/fs/cifs/cifs.ko
	 273900 usr/lib/libncurses.so.5.5
	 204336 usr/bin/lua
	 200256 usr/lib/libreadline.so.5.2
	 183224 usr/sbin/dropbearmulti
	 131614 usr/share/samba/unicode_map.850
	 117746 usr/lib/mc/mc.hlp
	  85680 lib/modules/2.6.13.1-ohio/kernel/fs/mini_fo/mini_fo.ko
	  85072 usr/lib/libmatrixssl.so
	  68816 usr/sbin/bftpd
	  57005 lib/modules/2.6.13.1-ohio/kernel/net/ipv4/netfilter/ip_conntrack.ko
	  34309 usr/lib/mc/syntax/html.syntax
	  31232 lib/modules/2.6.13.1-ohio/kernel/net/ipv4/netfilter/ip_tables.ko
	  26432 usr/lib/libhistory.so.5.2
	  24544 usr/bin/haserl
	  23940 usr/sbin/matrixtunnel
	  21708 usr/sbin/mount.cifs
	  20392 lib/modules/2.6.13.1-ohio/kernel/drivers/block/loop.ko
	  11461 usr/lib/mc/syntax/perl.syntax
	  10684 lib/modules/2.6.13.1-ohio/kernel/net/ipv4/netfilter/ipt_LOG.ko
```

Wir sehen Verschiedenes: *Samba* ist tatsächlich ein Platzfresser, wenn
man *smbd* und *nmbd* zusammenzählt. *MC* mit *ncurses* ist auch nicht
zu verachten - evtl. könnten wir wenigstens die Hilfedatei *mc.hlp*
weglassen. Allerdings muß man bei textlastigen Dateien wie der MC-Hilfe
aufpassen und die Erwartungen nicht zu hoch schrauben: **Unsere
Vergleiche hinken im Grunde alle, denn wir müßten uns die Dateien
LZMA-komprimiert anschauen, um einen Eindruck davon zu erhalten, wieviel
Platz sie in einem SquashFS auf der Box wirklich brauchen würden.
Textdateien z.B. sind extrem stark komprimierbar. Sie also wegzulassen,
bringt oft weniger als erhofft.**

Was noch auffällt, sind diverse *Netfilter*-Bibliotheken, die wohl mit
in die Firmware kopiert wurden, als ich mal testweise *Iptables*
kompiliert habe. Offensichtlich bleibt dabei so Manches übrig, das gar
nicht hinein gehört in die FW, weil es längst abgewählt wurde. Das gilt
übrigens auch für so manche Shared Library und diverse Kernelmodule.
Also hier bitte aufpassen und kontrollieren, evtl. mal die
entsprechenden Verzeichnisse leeren oder, falls man nicht weiß, wo man
hinfassen soll, mal neu aufsetzen und mit korrekt eingestellter
Konfiguration (Datei `.config`) von vorne anfangen.

### Schritt 3: Vorher-Nachher-Vergleich existierender Dateien

Wir haben uns bisher alte und neue Dateien angeschaut, aber nicht
geprüft, ob sich gleichnamige, in beiden FW-Versionen vorhandene Dateien
evtl. signifikant in der Größe geändert haben. Auch das kann uns evtl.
Hinweise darauf geben, wo man noch sparen kann, wenngleich vermutlich in
geringerem Umfang. Aber wer den Heller nicht ehrt, ...

Das folgende Shell-Skript mag etwas verwirrend sein, und optimal
programmiert ist es sicher nicht, aber es dient seinem Zweck. (Ich kann
übrigens nicht mit *Awk* umgehen, sonst wäre das Ganze vermutlich
übersichtlicher geworden.) Was es tut, ist Folgendes:

-   zwei Dateilisten generieren (wie oben schon gesehen)
-   in beiden Listen auftauchende Dateinamen herausfiltern (d.h. übrig
    lassen)
-   ein weiteres Shell-Skript erzeugen und ausführbar machen
-   das Shell-Skript ausführen
-   Das Skript selbst gibt für alle gemeinsamen Dateien die
    Größendifferenz (neu minus alt) in Bytes und den Pfadnamen aus.
-   Die Ergebnisliste wird aufsteigend sortiert und gefiltert (Dateien
    ohne Unterschied in der Größe werden eliminiert).
-   Uns interessieren dann die Dateien mit den größten absoluten
    Unterschieden. Negative Werte bedeuten dabei Platzersparnis
    gegenüber der Original-Firmware, positive zusätzlich beanspruchten
    Speicherplatz.

```
	$ cd build
	$ find original/filesystem -type f | sed 's/^original\/filesystem\///' > orig-files
	$ find modified/filesystem -type f | sed 's/^modified\/filesystem\///' > modi-files
	$ diff -u 99999 orig-files modi-files | grep '^ ' | sed 's/^ //' > before-after-files
	$ echo '#!/bin/bash' > before-after-script
	$ chmod +x before-after-script
	$ cat before-after-files | sed -r \
		's/(.*)/printf "%10d %s\\n" $(( $(stat -c "%s" modified\/filesystem\/\1) - $(stat -c "%s" original\/filesystem\/\1) )) \1/' \
		>> before-after-script
	$ ./before-after-script | grep -v ' 0 ' | sort -g > before-after-diffs

	-12468 lib/libuClibc-0.9.28.so
	 -7508 lib/libgcc_s.so.1
	 -3295 lib/modules/2.6.13.1-ohio/kernel/drivers/usb/core/usbcore.ko
	 -2184 lib/modules/2.6.13.1-ohio/kernel/drivers/scsi/scsi_mod.ko
	 -1088 lib/modules/2.6.13.1-ohio/kernel/fs/fat/fat.ko
	   ... ...
	  9756 lib/libpthread-0.9.28.so
	 10240 var.tar
    183108 bin/busybox
```

Wir erkennen in diesem Fall nichts Aufregendes: Die *uClibc* wurde ca.
12 KB kleiner, die *Busybox* allerdings um ca. 180 KB größer. Das ist
doch nicht zu vernachlässigen. Allerdings kann die *Busybox* damit auch
mehr als das Original.

War das jetzt umsonst? Nein! Denn wenn wir das Gleiche mal bei der
7050-FW machen, sehen wir, daß dort die *libgcc_s*, wenn sie denn in
der Konfiguration ausgewählt und somit ersetzt wurde, von 215 auf knappe
60 KB schrumpft (siehe
[dort](http://www.ip-phone-forum.de/showpost.php?p=840715&postcount=17)).
Das liegt daran, daß in dieser FW-Version das Original - wohl
versehentlich - nicht gestrippt oder gar mit zusätzlicher
Debug-Information freigegeben wurde. Ergo: Wer eine FW modifiziert und
Platz sparen möchte, sollte tunlichst auch auf scheinbare Kleinigkeiten
achten.

### Weitere Spartricks

### Auslagerung von Dateien

Eine Möglichkeit mit viel Potential ist das Auslagern von Dateien,
entweder auf direkt zugreifbare USB-Datenträger (Speicherstift,
Festplatte) oder auf Netzlaufwerke, die mittels NFS, Cifsmount oder
Smbmount beim Hochfahren der Box eingebunden werden, so daß die erst
nach dem Einbinden (Mounten) benötigten Dateien direkt vom externen
Speicher bzw. übers Netz geladen werden können. Damit kann man eine
Firmware in `build/modified` bauen, die eigentlich zu groß ist für ein
Image und abbricht beim Bauen, welche man jedoch hinterher so verändert,
daß große Dateien durch Symlinks auf die zu mountenden Speicher ersetzt
werden. Die entnommenen Dateien werden entsprechend bereitgestellt, das
ausgedünnte `build/modified` im zweiten Durchgang erfolgreich zu einem
Image verbaut. Die Startskripten der FW wurden vorher ebenfalls
entsprechend angepaßt.

*Update 05.10.2007:* Bereits seit ds26-15.1 ist das Paket
[Downloader-CGI](http://www.ip-phone-forum.de/showthread.php?t=134934)
Bestandteil des DS-Mod. Es erleichtert das automatische Herunterladen
von Dateien beim Start der Box.

### Komprimierte Binaries und Nutzdaten

Eine häufig geäußerte Idee im IPPF ist, man könne doch beispielsweise
einen EXE-Packer verwenden, um die Binaries zu verkleinern. Das ist
**ziemlich sinnlos** und kostet nur unnötig Rechenzeit, denn das
SquashFS (Dateisystem der Boxen) ist bereits so extrem gut komprimiert,
daß eine weitere Kompression gar nicht zum Tragen kommen würde (siehe
[dort](http://www.ip-phone-forum.de/showthread.php?p=832868&highlight=lzma#post832868)).
Warum das manchmal dazu führt, daß eine scheinbar große weggelassene
Datenmenge kaum Ersparnisse bei der FW-Größe bringt, sofern es sich um
gut komprimierbare Daten handelt, erkläre ich [in diesem
Beitrag](http://www.ip-phone-forum.de/showthread.php?p=844325&highlight=lzma#post844325).

### Ältere bzw. alternative Software-Versionen

Oft wird im [IPPF](http://www.ip-phone-forum.de/)
gefragt, weshalb beispielsweise der *Midnight Commander (mc-4.5.0)* oder
*Samba 2.0.10* so alte Stände haben. Das hängt teilweise einfach damit
zusammen, daß die alten Versionen vom Leistungsumfang her ausreichen,
dafür aber viel kleiner sind als die neueren Versionen mit mehr
Features. Im Falle des *MC* kommt noch dazu, daß neuere Versionen gegen
Bibliotheken gelinkt sind, welche über das, was die *uClibC* als
*libc*-Ersatz bietet, ein wenig hinaus gehen und das Ersetzen
entsprechender Aufrufe durch eigene Makros einen großen Aufwand bedeuten
würde.

Weitere Sparmöglichkeiten bestehen in der Suche nach Alternativen zu
bekannten Softwarepaketen. Beispiele:

-   *Matrixssl* ist kleiner als *OpenSSL*, genügt aber oft, z.B. um
    einen HTTPS-Tunnel zu bauen. Nur wenn auf SSL-Bibliotheken
    aufsetzende Software wie *OpenVPN* nicht mit *Matrixssl*
    funktionieren, man aber glaubt, diese zu brauchen, bleibt keine
    Wahl.
-   *Deco* ist kleiner als *MC*, dafür aber auch wesentlich weniger
    leistungsfähig.
-   Die *Rudi-Shell* ist phantastisch klein, kann aber sehr viel. Sie
    führt beliebige Shell-Skripten aus, hat eine Befehlshistorie, kann
    Dateien von und zur Box transferieren (sogar komprimiert) und taugt
    sogar zum Remote-Flashen der Box. Mittels *Matrixtunnel* wird sie
    ein funktional (nicht komfortmäßig) vollwertiger Ersatz für *SSH*
    bei weit geringerem Platzbedarf und ohne die Notwendigkeit, einen
    SSH-Zugang zu haben, was hinter manchen Firewalls einfach nicht
    erlaubt ist, weil es nur einen Web-Proxy für HTTP und HTTPS gibt.
    Rudi + Matrixtunnel genügt dies. Einen *vi* kann Rudi zwar nicht
    remote bedienbar machen, aber dafür kann man ja einfach Dateien hin
    und her übertragen. Lokal bequem editieren, zurück auf die Box -
    fertig!
-   *Cifsmount* stellt Verbindungen zu Windows- und Samba-Freigaben her,
    ist aber deutlich kleiner als *Smbmount*.
-   *Mini_fo* kleiner als *UnionFS*, läuft aber sehr stabil (bisher
    keine mir bekannten Fehlermeldungen dazu im Forum). Dafür kann man
    einen *Mini_fo*-Mount nicht über NFS exportieren, aber wer braucht
    das schon? Außerdem gibt es Samba, damit geht es.
-   *Perl* oder *PHP* würden die FritzBox ressourcentechnisch
    überlasten - *Lua* nicht. *Lua* ist eine sehr schlanke und dabei
    einfach zu lernende und leistungsfähige Skriptsprache, nicht nur für
    CGI. *Update 05.10.2007:* Inzwischen habe ich gelernt, daß Apache +
    PHP, die man jetzt auch per Freetz bauen kann, sehr wohl stabil und
    performant auf der FritzBox laufen, aber der Platzverbrauch ist
    enorm. Und ums Platzsparen geht es ja hier.
-   A propos CGI-Handling: *Haserl* ist klein und leistet alles, was ich
    auf der Box brauche. Da brauche ich nicht einmal *Lua*, und manchmal
    verzichte ich sogar auf Haserl, weil es ein Shellskript tut.

### Firmware-Patches aus Menuconfig

Schon seit langer Zeit gibt es Firmware-Patches, die nicht benötigte
Original-Bestandteile aus dem FW-Image entfernen und Platz für
Zusatz-Pakete schaffen. Dabei muß jeder selbst entscheiden, ob er
Hilfetexte und Assistenten für die AVM-Weboberfläche, den
Original-AVM-Webserver selbst (durch BusyBox-httpd ersetzbar), UPnP,
DSL, VoIP, Kindersicherung usw. benötigt.

Wer z.B. seine Box als reinen IP-Client betreibt, der über einen
weiteren vorgeschalteten Router die Internet-Verbindung bekommt und auch
keine PPoE-Anmeldung benötigt, kann viel Platz sparen mit einem
entsprechenden Patch, welcher *dsld* plus Zubehör aus der Firmware
entfernt. Normalanwender benutzen die Box als DSL-Router und können den
Patch dann eben nicht anwenden.

Beispiel Webserver: Auf den AVM-Webserver kann man nach heutigem
Wissensstand problemlos verzichten und stattdessen den kleineren und
ressourcenschonenderen *httpd* verwenden, der für Freetz ohnehin benutzt
wird. Leider wurde der AVM-Server bei neueren Firmwares (Neue
AVM-Weboberflächen seit etwa Mitte-Ende 2007) anders realisiert, sodass
der *httpd*-Ersatz nicht mehr möglich ist.

Beispiel UPnP: Wer nicht mit Client-Programmen (z.B. von AVM) den Status
der Box per Universal Plug'n'Play (UPnP) abfragt - mir persönlich
genügt die Web-Oberfläche vollkommen - oder Client-Programmen erlauben
möchte, dynamisch die Firmware-Einstellungen zu verändern (d.h. Löcher
hinein zu bohren), kann auch die entsprechenden Bestandteile (`igdd`
u.a. Dateien) weglassen. Das spart zum einen Platz im Firmware-Image,
zum anderen läuft ein Prozess weniger. Das Weglassen von UPnP macht
jedoch das Versenden der Faxe mit FritzFax nicht möglich. Wer darauf
verzichten kann, kann UPnP abwählen.

### Schlußwort

Das soll es fürs Erste gewesen sein. Wie eingangs gesagt: Es gibt sicher
noch diverse weitere Sparmöglichkeiten. Anregungen werden gern in diese
Seite von mir eingepflegt. In diesem Sinne:

**Geiz ist nicht geil, sondern dumm - aber *sinnvoll* sparen ist
hilfreich.**

[Alexander Kriegisch
(kriegaex)](http://www.ip-phone-forum.de/member.php?u=117253)


