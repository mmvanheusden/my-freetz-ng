# Flash-Partitionen von außen mit FTP sichern

Dieser Artikel baut auf dem Artikel
Flash-Partitionierung auf. Ihn vorher zu lesen,
schadet also nicht. Mein herzlicher Dank für einige der Informationen zu
diesem Artikel gebührt Enrik Berkhan, der sich hier immer vornehm
zurückhält, aber sooo viel weiß.
:-)

### Motivation

Im verwandten Artikel 'Flash-Partitionen im laufenden Betrieb
sichern' habe ich erklärt, wie man direkt von
der Konsole (SSH, Telnet, Rudi-Shell) auf der FritzBox aus über
entsprechende Linux-Block- bzw. -Character-Devices Datensicherungen
vornehmen kann. Das gleiche geht auch "von außen", also ohne
Shell-Zugriff von der Box, indem man per FTP den Urlader - neudeutsch
Bootloader - kontaktiert. Früher hieß der Urlader
ADAM2, heute EVA bei den aktuellen
Kernel-2.6-Firmwares (obwohl die Login-Daten immer noch wie früher sind,
wie wir gleich sehen werden).

Diese Methode ist auch dann anwendbar, wenn die Box nicht mehr sauber
hochfährt oder man kein Telnet auf der Box mit Original-Firmware hat
bzw. man es nicht schafft, es zu aktivieren.

### Voraussetzungen

Wir brauchen eine FritzBox mit Kernel 2.6 und EVA-Urlader, denn seit
älteren Versionen könnten die FTP-Befehle sich mehr oder weniger stark
verändert haben. Das weiß ich aber nicht genau. Es geht auch ein
entsprechendes OEM-Gerät, also z.B. Speedport W501V, W701V, W900V.

Außerdem benötigen wir ein **Linux**-System (auch eine virtuelle
Maschine, z.B. VMware, geht) mit installiertem
Standard-Kommandozeilen-Client *ftp* (bei mir das Debian-Paket *ftp
0.17-16*) oder aber mit
[NcFTP](http://en.wikipedia.org/wiki/Ncftp) 3.2.0
(bei mir Debian-Paket *ncftp 2:3.2.0-1*).

Alternativ funktioniert die beschriebene Prozedur mit NcFTP 3.2.0 auch
unter **Windows mit Cygwin**. Dort klappt es aber nicht mit dem
Standard-FTP-Client, mit dem Windows-FTP schon gar nicht.

Des weiteren sollte die Boot-IP der Box bekannt sein. Kennt man sie
nicht und kommt man nicht über eine Konsole (SSH, Telnet, Rudi-Shell,
Nano-Shell) an Informationen aus der Box, so kann man sie mittels `ping`
herausfinden, indem man verschiedene IP-Adressen "anpingt" direkt nach
dem Aus- und Einschalten/-stecken der Box. Folgende IPs werden häufig
verwendet:

-   192.168.178.1 (allermeistens)
-   169.254.1.1
-   192.168.2.1
-   192.168.2.254

Die normale und einfache Methode, die Boot-IP herauszufinden, ist diese:

```
	cat /proc/sys/urlader/environment | grep my_ipaddress
```

Man sollte dafür sorgen, dass Personal Firewalls ausgeschaltet sind,
evtl. auch andere Sicherheitspakete, die den Netzwerkverkehr behindern
könnten. Spätestens, wenn es mit aktiven Programmen nicht geht, sollte
man sie ausschalten, auch wenn man sich einbildet, alles sei richtig
eingestellt und daran könne es nicht liegen. Ganz ausschalten, nicht nur
inaktiv setzen!

Außerdem ist es hilfreich, dass der Rechner, von dem aus man die
Ping-Versuche unternimmt und die Verbindung per FTP initiieren möchte,
im gleichen Subnetz (z.B. 192.168.178.0/24 bzw. Netzmaske 255.255.255.0)
ist wie die Box, und zwar bzgl. der Adresse, die man gerade testet. Dass
übrigens der Ping von Windows aus funktioniert, bedeutet noch lange
nicht, dass man dann aus VMware heraus auch Verbindung aufnehmen kann.
Wirklich von dort probieren, wo man später arbeiten möchte.

Verbindungsversuche benötigen evtl. mehrere Anläufe, also wenn ein Ping
oder ein FTP-Connect nach drei, vier Sekunden nach Anschalten der Box
noch nicht geklappt hat, am besten aus- und wieder einschalten, bis der
Ping oder FTP-Connect funktioniert. Unter Windows sollte man ggf. auch
noch das Media Sensing ausschalten, indem man folgendes als Textdatei
`mediasensing-aus.reg` speichert und doppelklickt, um es danach in die
Windows-Registry eintragen zu lassen:

```
	Windows Registry Editor Version 5.00

	[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Tcpip\Parameters]

	"DisableDHCPMediaSense"=dword:00000001
```

Evtl. sollte man nach dem Ausschalten einen Windows-Neustart machen.
AVMs Recover-Werkzeug macht das jedenfalls, aber vielleicht geht es auch
ohne. Man kann das Mediasensing dauerhaft ausgeschaltet lassen, sofern
man den betreffenden Rechner nicht ständig an verschiedenen Netzwerken
ein- und ausstöpselt und das Mediasensing für unterschiedliche
DHCP-Server benötigt (z.B. Notebook abwechselnd im Büro und zu Hause).
Sollte man es doch wieder einschalten wollen, geht das so:

```
	Windows Registry Editor Version 5.00

	[HKEY_LOCAL_MACHINE\SYSTEM\ControlSet001\Services\Tcpip\Parameters]

	"DisableDHCPMediaSense"=dword:00000000
```

### Allgemeine Informationen zur Datensicherung

Das im Folgenden gezeigte Vorgehen ist immer das gleiche, auch wenn
unterschiedliche Kommandozeilen-Clients verwendet werden. Man kann das
Ganze auch manuell im Dialog im FTP-Client durchführen, und außer den
genannten Clients funktionieren vermutlich noch einige andere. Passiven
Datentransfer sollten sie aber beherrschen, und Garantien gebe ich
sowieso nicht. ;-)
Die von mir getesteten Programme sollten ein Gelingen aber wesentlich
wahrscheinlicher machen.

Eine Seltsamkeit gibt es, auf die ich gleich hinweisen möchte: Immer
nach dem Download einer `mtd`-Partition
muß man manuell einmal Strg-C (engl. Ctrl-C) an der Kommandozeile des
FTP-Clients eingeben, damit der Client weiter läuft bzw. terminiert. Aus
irgendeinem Grund wird das Ende eines GET-Downloads nicht erkannt, was
wohl dem Urlader zuzuschreiben ist. Am besten kontrolliert man in einer
zweiten Konsole am Client, ob die Größe der
Download-Datei noch wächst. Nach ein
paar Sekunden sollte das nicht mehr der Fall sein. Die Urlader- und
TFFS-Partitionen sind sowieso fast augenblicklich heruntergeladen, nur
bei `mtd1`, der Partition für Kernel + Dateisystem der Box, dauert es
ein bißchen länger, geht aber auch sehr schnell. Dabei gelten folgende
Dateigrößen:

-   Dateisystem + Kernel (`mtd1`):
    -   7.616 KB = 7.798.784 Bytes bei 8-MB-Boxen
    -   3.520 KB = 3.604.480 Bytes bei 4-MB-Boxen
    -   1.472 KB = 1.507.328 Bytes bei 2-MB-Boxen (theoretisch, diese
        Boxen haben momentan noch alte Urlader)
-   Urlader/Bootloader/EVA (mtd2): immer 64 KB = 65.536 Bytes
-   TFFS1 (mtd3): immer 256 KB = 262.144 Bytes
-   TFFS2 (mtd4): immer 256 KB = 262.144 Bytes

`mtd1-4` summiert ergeben immer genau 8 bzw. 4 bzw. 2 MB, also die
Speichergröße der jeweiligen Box.

### Sicherung mit Linux-Standard-FTP (ftp)

Folgenden Code am besten in eine Skript-Datei eintragen und von dort
ausführen wegen der Mehrzeiligkeit. Dabei die passende IP-Adresse
eintragen und nach dem vollständigen
Download jeder Partition jeweils einmal
Strg-C drücken, damit die folgende heruntergeladen wird bzw. am Ende die
FTP-Sitzung beendet wird.

```
    (
    cat <<EOT
    open 192.168.178.1
    user adam2 adam2
    debug
    bin
    quote MEDIA FLSH
    get mtd1
    get mtd2
    get mtd3
    get mtd4
    quit
    EOT
    ) | ftp -n -p
```

Im Anschluß sollten sich im aktuellen Verzeichnis vier Dateien von
`mtd1` bis `mtd4` befinden.

### Sicherung mit Linux-NcFTP (ncftpget)

Auch hier wieder die IP-Adresse ersetzen. Das Skript jeweils einmal für
jede der vier Partitionen von `mtd1` bis `mtd4` aufrufen, alles auf
einmal geht hier nicht. Aber Strg-C am Ende des
Downloads ist auch hier zum Beenden
erforderlich.

```
	ncftpget \
		-d stdout \
		-o doNotGetStartCWD=1,useFEAT=0,useHELP_SITE=0,useCLNT=0,useSIZE=0,useMDTM=0 \
		-W "quote MEDIA FLSH" \
		-u adam2 \
		-p adam2 \
		ftp://192.168.178.1/mtd1
```

### Sicherung mit Cygwin-NcFTP (ncftpget)

Das funktioniert genauso wie unter Linux mit der gleichnamigen
Anwendung, siehe oben.

### Uploads via FTP

Analog hierzu kann man auch mit `ftp` bzw. `ncftpput` Uploads machen,
allerdings sollte man das im Normalfall nur für `mtd1` (Kernel +
Dateisystem) machen, und dafür gibt es in ds26-15.2 bereits ein bequemes
Skript Namens `tools/push_firmware.sh` (ab 15.3 entfällt die Endung
`.sh`), welches unter Linux und Windows + Cygwin läuft und genaus das
tut.

Das doppelt gepufferte TFFS - dort werden die Einstellungen der
Firmware, sowohl vom Hersteller als auch von Freetz, gespeichert -
sollte man nur im Notfall und immer nur auf genau die Box zurück
spielen, von der es stammt, denn es enthält einen Teil der Identität der
Box. Das hat sich seit dem Übergang von ADAM2 auf EVA zwar relativiert,
weil der wichtigste Teil der Angaben direkt in den Bootloader gewandert
ist - siehe [Artikel von Enrik zu
EVA](http://wehavemorefun.de/fritzbox/index.php/EVA) - aber
man sollte trotzdem damit aufpassen.

Was viel brisanter geworden ist, ist ein Überschreiben des Urladers,
denn er enthält seit dem Übergang auf EVA wirklich wichtige
box-individuelle Daten. Außerdem lässt er sich sowieso nicht via FTP
überschreiben, weil er während der FTP-Sitzung ja gerade aktiv ist. Im
Artikel ADAM-Bootloader wird beschrieben, wie man
den Urlader direkt im laufenden Betrieb von der Konsole auf der Box aus
überschreiben kann, aber dort steht nicht, wie man die box-individuellen
Daten dort ins Image bekommt. Sie sollten also tunlichst bereits drin
sein oder man sollte sich die Update-Prozedur aus den Original-Firmwares
(z.B. 06.04.33, darin steckt ein Bootloader samt Update-Programm)
anschauen und sich o.g. Artikel von Enrik durchlesen.

 **Ich
kann nur dringendst davon abraten, den Urlader zu überschreiben, das
sollte auch nie notwendig sein!!!**


[Alexander Kriegisch
(kriegaex)](http://www.ip-phone-forum.de/member.php?u=117253)


