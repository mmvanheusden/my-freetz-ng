# Einstellungen speichern im Urlader-Environment

### Vorwort und Motivation

Es kann von Vorteil sein, während des Boot-Prozesses oder evtl. auch
danach noch gewisse Schalter (engl. flags) abfragen zu können, ohne
deswegen gleich auf `/var/flash/debug.cfg` zugreifen zu müssen. Dafür
gibt es folgende Gründe:

-   Die Character Devices unter `/var/flash` sind erst nach Ablauf von
    `/etc/init.d/rc.S` verfügbar, weil sie in diesem Skript erst mittels
    `mknod` erzeugt werden - speziell `debug.cfg` übrigens erst separat
    am Ende des Skripts.
-   Gewisse Funktionalitäten würden wir gerne aufrufen, ***bevor***
    *`rc.S`* läuft. Bestes Beispiel sind Root-Mounts, z.B. das
    Freetz-Paket mini_fo,
    dessen Init-Skript sich in `/etc/inittab` vor `rc.S` einträgt.
    Würden wir jetzt gerne einen Schalter haben, der das Laden von
    `mini_fo` verhindern kann, hätten wir ein Problem.

### Lösungsmöglichkeiten

Kein Problem ohne Lösung. Wir könnten innerhalb von `rc.mini_fo` selbst
`mknod` verwenden, um `debug.cfg` temporär zugreifbar zu machen und nach
Abfragen der gewünschten Information wieder aufräumen mit `rm`, damit
später `rc.S` nicht irritiert wird beim erneuten Erzeugen des Nodes. Es
gibt tatsächlich ein Paket
(NFS-Root), welches diese Technik
verwendet, um auf AVM-Konfigurationsdaten aus dem TFFS zuzugreifen,
zusätzlich aber auch noch Informationen von woanders einholt, und zwar
aus dem sog. Bootloader Environment (Urlader-Umgebungsvariablen). Schon
seit 15.0 greifen auch zwei (noch) undokumentierte Logging-Werkzeuge des
DS-Mod, Inotify-Tools und
*Dmesg-Recording*, auf diese Umgebungsvariablen zu, die beiden Letzteren
sogar über ein kleines, funktional auf bestimmte Anwendungsfälle
eingegrenztes Shell-API, das ich mir habe einfallen lassen. Dazu später
mehr.

### Bootloader Environment

Der Urlader (engl. bootloader), je nach Version auch bekannt unter
ADAM2 oder EVA, besitzt ein sog. Environment, also
einen kleinen Speicherbereich für globale Einstellungen, welche absolut
erforderlich sind, damit die Box überhaupt funktioniert. Das ist ja
bekannt, aber zur Auffrischung nochmals die (mit "\#" anonymisierte)
Ausgabe, generiert auf meiner 7170 mit Kernel 2.6:

```
	$ cat /proc/sys/urlader/environment
	HWRevision      94.1.1.0
	ProductID       Fritz_Box_7170
	SerialNumber    0000000000000000
	annex   B
	autoload        yes
	bootloaderVersion       1.153
	bootserport     tty0
	bluetooth       ##:##:##:##:##:##
	cpufrequency    211968000
	firstfreeaddress        0x946AE530
	firmware_version        1und1
	firmware_info   29.04.29
	flashsize       0x00800000
	maca    ##:##:##:##:##:##
	macb    ##:##:##:##:##:##
	macwlan ##:##:##:##:##:##
	macdsl  ##:##:##:##:##:##
	memsize 0x02000000
	modetty0        38400,n,8,1,hw
	modetty1        38400,n,8,1,hw
	mtd0    0x90000000,0x90000000
	mtd1    0x90010000,0x90780000
	mtd2    0x90000000,0x90010000
	mtd3    0x90780000,0x907C0000
	mtd4    0x907C0000,0x90800000
	my_ipaddress    192.168.178.1
	prompt  AVM_Ar7
	ptest
	reserved        ##:##:##:##:##:##
	req_fullrate_freq       125000000
	sysfrequency    125000000
	urlader-version 1153
	usb_board_mac   ##:##:##:##:##:##
	usb_rndis_mac   ##:##:##:##:##:##
	usb_device_id   0x3D00
	usb_revision_id 0x0200
	usb_device_name USB DSL Device
	usb_manufacturer_name   AVM
	wlan_key        ################
	wlan_cal        ####,####,####,####,####,####,####,####,####
```

Das Schöne an diesem Environment ist, dass es nicht nur lesbar, sondern
auch (teilweise) beschreibbar ist. Das wird gern verwendet, um
Anpassungen am Annex oder am Branding vorzunehmen, insbesondere bei
OEM-Boxen, deren Besitzer gern eine vollwertige FritzBox daraus machen
möchten, um die entsprechenden Original-Firmware oder Freetz darauf zu
installieren, bzw. auch, um eine deutsche Box im Ausland lauffähig zu
machen oder umgekehrt.

Es ist bei den allermeisten Werten im Environment absolut nicht ratsam,
sie für andere Zwecke zu missbrauchen, aber es gibt eine oben gar nicht
sichtbare Variable, die dafür geschaffen wurde, dem Linux-Kernel
Parameter für den Boot-Vorgang mitzugeben. Diese Parameter werden später
weitergereicht an die Startskripte, aber auch gleichzeitig persistent
gespeichert und sind somit ideal geeignet, um Werte von dort abzufragen.

### Variable "kernel_args"

Die Variable, von der hier die Rede ist, heißt `kernel_args`, fasst
maximal 64 Zeichen an Informationen und sollte daher mit Bedacht
verwendet werden. Man kann folgendermaßen etwas hinein schreiben:

```
    echo "kernel_args tea=Darjeeling quality=FTGFOP1" > /proc/sys/urlader/environment
```

Damit würden wir ein eigens dafür entworfenes (leider fiktives)
Startskript der FritzBox anweisen, beim Hochfahren der Box Tee zu
kochen, und zwar Darjeeling der Qualitätsstufe FTGFOP1 (Finest Tippy
Golden Flowery Orange Pekoe 1).

Wenn man sich jetzt das Environment nochmals anzeigen lässt, findet man
plötzlich dort die Variable `kernel_args` vor:

```
    $ cat /proc/sys/urlader/environment | grep kernel_args
    kernel_args     tea=Darjeeling quality=FTGFOP1
```

Mit ein bisschen Zeichenketten-Manipulation können wir den Wert von
`kernel_args` isolieren und dann weiter zerlegen in unsere beiden
Schlüssel-Werte-Paare. Darauf will ich an dieser Stelle nicht weiter
eingehen, das sind Grundlagen der Shell-Programmierung.

Jedoch wichtig zu wissen ist, wie man während des Boot-Vorgangs an diese
Variable heran kommt. Die Antwort hängt davon ab, zu welchem Zeitpunkt
man den Zugriff benötigt. Sofern das virtuelle Dateisystem unter `/proc`
bereits zugreifbar, das sog. *procfs* also bereits ins Root-Dateisystem
per `mount` eingehängt wurde, können wir so vorgehen wie oben gezeigt.
Andernfalls müssen wir zunächst mittels

```
    [ -e /proc/mounts ] || mount proc
```

*procfs* selbst einhängen, falls es noch nicht da ist. Nach Benutzung
loswerden können wir es entsprechend über `umount proc`

### Kernel_Args-API

Für einfache, auf Debugging oder Logging ausgerichtete Anwendungsfälle,
die innerhalb von `kernel_args` auskommen mit den Werten

-   aktiv/ja,
-   inaktiv/nein,
-   Countdown-Zähler \> 0,

gibt es das Shell-Skript `kernel_args`, welches man mit
`. /usr/bin/kernel_args` in ein laufendes Skript inkludieren und
daraufhin auf verschiedene vorgefertigte Funktionen zur Manipulation von
innerhalb der Bootloader-Variablen `kernel_args` gespeicherten
Schlüssel-Werte-Paaren zugreifen kann. Das Skript ist in den enthaltenen
Kommentarzeilen gut dokumentiert, daher hier nur eine kurze Auflistung
der aktuell (ds26-15.2) verfügbaren Funktionen:

-   **ka_mountProc:** `/proc` mounten, falls notwendig
-   **ka_getArgs:** `kernel_args` komplett auslesen
-   **ka_getKeyValuePair:** Schlüssel-Wert-Paar zu geg. Schlüssel
    ermitteln
-   **ka_isValidName:** Schlüsselnamen auf Validität prüfen
-   **ka_isValidValue:** Wert auf Validität (y, n, Zahl \> 0) prüfen
-   **ka_getValue:** Wert zu einem Schlüssel ermitteln
-   **ka_setValue:** Wer zu einem Schlüssel setzen
-   **ka_removeVariable:** Schlüssel-Wert-Paar löschen
-   **ka_removeVariableNoUpdate:** wie oben, aber nur neuen Wert von
    `kernel_args` nach angenommener Entfernung eines Paares anzeigen,
    nicht direkt ins Environment schreiben
-   **ka_isPositiveInteger:** Hilfsfunktion zum Prüfen numerischer
    Werte
-   **ka_isActiveVariable:** Prüfen, ob Wert \> 0 oder "y" (aktiv)
-   **ka_decreaseValue:** Positiven Ganzzahlwert um 1 vermindern. Falls
    er 0 werden würde, Wert durch "n" (inaktiv) ersetzen

### Countdown-Trick

Gerade die letzten beiden Aufrufe ermöglichen ein hilfreiches Konstrukt
beim Entwickeln von Startskripten: Man kann eine Variable z.B. auf 5
setzen und bei jedem Startvorgang um 1 vermindern, bis sie nach fünf
Durchläufen auf "n" (inaktiv) gesetzt wird. Abhängig davon könnte man
den weiteren Verlauf eines Skripts beeinflussen, es also fortsetzen oder
vorzeitig beenden. Sollte im weiteren Verlauf des Skripts also ein
Fehler auftauchen, der den Startvorgang der Box torpediert, so daß man
nicht mehr an sie heran kommt ohne Recover, wäre dieser Countdown eine
praktische Hilfe, denn spätestens beim sechsten Anlauf würde ja die
fehlerhafte Funktion nicht mehr aktiviert sein und die Box normal weiter
gestartet werden. Wir retten uns hiermit also vor uns selbst und ziehen
uns an den eigenen Haaren aus dem Sumpf! ;-)

### Grenzen des kernel_args-API

Sobald wir andere Arten von Werten in `kernel_args` speichern wollen,
z.B. etwas wie `my_path=/usr/bin/my_script`, versagt das API in der
momentanen Version seinen Dienst, weil es ja nur die Werte "y", "n",
positive Ganzzahl zulässt. Aber oben steht ja, wie man auch damit
umgehen kann durch Direktzugriff. Eines Tages erweitere ich vielleicht
auch das API.

### Mögliche Anwendungsfälle

**Root-Mounts:** Dienste wie `mini_fo` zur virtuellen Überlagerung des
Root-Dateisystems durch eine RAM-Disk oder einen externen Speicher, um
Schreibzugriffe zu ermöglichen oder *NFS-Root*, also der vollständige
Ersatz des Root-Dateisystems durch einen voll beschreibbaren und
größenmäßig quasi unbegrenzten Netzwerk-Mount könnten von Schaltern im
Bootloader Environment profitieren, weil man sie bei Bedarf ein- und
ausschalten könnte. (Anm.: NFS-Root zum \[De-\]Aktivieren tatsächlich
einen Eintrag in kernel_args, allerdings ohne API. Zusätzlich wird der
zu mountende NFS-Pfad in einer anderen Bootloader-Variablen Namens
`nfsroot` abgelegt, die der Linux-Kernel sowieso kennt und die wir quasi
missbrauchen.)

**Debugging/Logging:** Bei Bedarf zuschaltebare Funktionen, um
Dateizugriffe beim Booten zu protokollieren, um z.B. festzustellen,
welchen Binaries beim Starten *nicht* angerührt werden und die man
deshalb via Downloader-CGI auslagern könnte, um Platz für mehr früher
benötigte DS-Mod-Pakete zu schaffen, oder um das Kernel-Log in eine
Datei zu sichern, bevor der Ringpuffer überläuft und der Anfang verloren
geht, sind Beispiele für weitere sinnvolle Anwendungsbereiche von
`kernel_args`, ob nun mit oder ohne API. Der Entwickler braucht keine
Debug-Version seiner FW zu flashen, um etwas zu probieren, sondern er
baut die notwendigen Dinge fest in seine FW ein, macht den Start aber
abhängig von einem oder mehreren Schaltern (Berücksichtigung in den
Init-Skripten). Sehr bequem!

Weitere Schweinereien überlasse ich Eurer geschätzten Phantasie.

Diskussionen zum Thema bitte unter
[http://www.ip-phone-forum.de/showthread.php?t=134976](http://www.ip-phone-forum.de/showthread.php?t=134976),
wo zu Beginn noch die Rede davon ist, die Variable *SerialNumber* zu
verwenden, um Werte dort zu speichern. Allerdings hat sich später
herausgestellt, daß man diese Variable zwar dem Anschein nach ändern
kann, die Änderungen aber einen Neustart der Box nicht überleben. Also
bitte nicht verwirren lassen, "state of the art" ist momentan
`kernel_args`.

[Alexander Kriegisch
(kriegaex)](http://www.ip-phone-forum.de/member.php?u=117253)


