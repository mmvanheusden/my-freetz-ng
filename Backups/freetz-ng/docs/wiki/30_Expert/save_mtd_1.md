# Flash-Partitionen im laufenden Betrieb sichern

Dieser Artikel baut auf dem Artikel
Flash-Partitionierung auf. Ihn vorher zu lesen,
schadet also nicht.

Die überarbeitete Version des Artikels füllt einige Lücken bzgl. der
Frage nach der Numerierung von Devices. Dafür gebührt unser Dank
[Oliver
(olistudent)](http://www.ip-phone-forum.de/member.php?u=58639).

Wie man Partitionen direkt über den Urlader/Bootloader sichert, findet
sich weiter unten.

### Motivation

Ich habe noch nie mit dem ADAM2-Bootloader via FTP
gearbeitet und werde das auch vermutlich erst dann tun, wenn es
notwendig ist oder höchstens mal, um vorher zu üben. Um aber für den
Notfall gerüstet zu sein, wollte ich in der Lage sein, nicht nur Backups
von Kernel und Dateisystem zu ziehen, sondern auch eine Sicherungskopie
vom Bootloader selbst machen können - alles idealerweise, ohne ADAM2
selbst zu benutzen, also einfach im laufenden Betrieb über
Shell-Skripten. Dieser Artikel beschreibt, wie das geht.

### Voraussetzungen

Ich habe eine FritzBox Fon WLAN 7170, darf mich also zu den gut
ausgestatteten AVM-Kunden zählen, weil die 7170 momentan das Modell mit
dem größten Flash-Speicher und den umfangreichsten
Anschlussmöglichkeiten ist. Ich schreibe das nicht, um Werbung zu
machen, sondern um klar zu machen, dass das Folgende nicht 1:1 für alle
anderen Boxen gelten muss und dies vermutlich auch nicht tut.
Insbesondere Zahlenwerte sind auf die Verhältnisse der anderen Boxen
anzupassen.

Die Box hat folgende Merkmale:

```
    {
      echo Kernel: $(uname -a)
      echo Firmware: $CONFIG_VERSION_MAJOR.$CONFIG_VERSION $CONFIG_SUBVERSION
      echo Flash-Partitionierung:
      cat /proc/sys/urlader/environment | grep mtd
    }

    # Kernel: Linux fritz.box 2.6.13.1-ohio #1 Sat Jan 27 12:00:36 CET 2007 mips unknown
    # Firmware: 29.04.29 ds-0.2.9     -->  _26-13
    # Flash-Partitionierung:
    # mtd0    0x90000000,0x90000000   -->  Hidden Root, 0 KB
    # mtd1    0x90010000,0x90780000   -->  Kernel + Filesystem, 7.616 KB
    # mtd2    0x90000000,0x90010000   -->  ADAM2 Bootloader, 64 KB
    # mtd3    0x90780000,0x907C0000   -->  TFFS für Konfig-Daten, 256 KB
    # mtd4    0x907C0000,0x90800000   -->  Kopie TFFS (Double Buffering), 256 KB
```

Die Anmerkungen hinter den Pfeilen wurden manuell eingefügt.

### Lösungsweg

Wenn wir uns das Pseudo-Dateisystem `/dev/` anschauen, erkennen wir
schnell, dass es folgende Geräte (Devices) gibt, die offenbar mit
unserer Aufgabe im Zusammenhang stehen:

-   `/dev/mtd0/` bis `/dev/mtd10`
-   `/dev/mtdblock0` bis `/dev/mtdblock10`

Worin besteht nun der Unterschied zwischen diesen Geräten? Es scheint,
als seien sie alle doppelt vorhanden unter verschiedenen Namen. In
gewissem Sinne stimmt das auch, und weshalb das so ist, sehen wir hier:

```
    ls -l /dev/mtd*

    # crw-r-----    1 root     root      90,   0 Jan  1  2000 /dev/mtd0
    # crw-r-----    1 root     root      90,   1 Jan  1  2000 /dev/mtd1
    # ...
    # brw-r-----    1 root     root      31,   0 Jan  1  2000 /dev/mtdblock0
    # brw-r-----    1 root     root      31,   1 Jan  1  2000 /dev/mtdblock1
    # ...
```

Die jeweils ersten Buchstaben des File Mode bringen es an den Tag: Die
`mtd*` sind zeichenorientierte Geräte (Character Devices, Kürzel "c"),
`mtdblock*` sind blockorientierte Geräte (Block Devices, Kürzel "b").
Man könnte also sagen, es gibt zwei unterschiedliche Sichten auf den
Flash-Speicher: Zum einen kann man ihn als kontinuierlichen Zeichenstrom
sehen, zum anderen als Gerät mit blockweisem Direktzugriff (wie eine
Festplatte). Genaueres gibt es in der
[Wikipedia](http://de.wikipedia.org/wiki/Ger%C3%A4tedatei).

Für den Zweck unserer Sicherheitskopie ist es im Grunde herzlich egal,
wie diese zustande kommt (Zeichen für Zeichen oder blockweise), solange
sich am Ende nur eine komplette Datei pro Flash-Partition auf unserer
Festplatte befindet. Ich habe beide Varianten ausprobiert und bin bei
beiden auf noch ungeklärte Phänomene gestoßen, aber mit den Block
Devices funktionieren die Datensicherungen besser, wie wir sehen werden.

Für die weiteren Erklärungen gehe ich davon aus, daß ein Mount Point
`/var/fritz` existiert, der einen größeren Datenspeicher darstellt. Bei
mir ist das eine über *smbmount* angebundene Windows-Freigabe, es
könnten aber auch USB-Sticks oder -Festplatten in Frage kommen. Genügend
freien RAM-Speicher auf der Box vorausgesetzt, kann man die Kopien auch
irgendwo unterhalb von `/var` zwischenspeichern und via FTP oder SCP
abtransportieren.

### Kopien von Block Devices (mtdblock\*)

Ich hatte erwartet, mit folgendem Befehl den ADAM2-Bootloader, welcher
sich nach Konfiguration laut Urlader (s.o.) ja in Partition `mtd2`
befinden soll, sichern zu können:

```
    cat /dev/mtdblock2 > /var/fritz/adam2
```

Doch weit gefehlt, was finde ich auf meiner Festplatte? Eine Datei der
Größe 7.798.784 Bytes, das sind genau 7.616 KB und somit exakt die Größe
der eigentlich unter `mtd1` beheimateten Kombination aus Kernel und
direkt daran anschließendem Dateisystem. Das Ganze scheint mit der
Zählweise zusammenzuhängen, denn es ergibt sich folgendes Bild:

```
	  ------------ ----------- ---------- ----------------------------------------------------------
	  Blockgerät   Partition   Größe      Beschreibung
	  mtdblock0    ----        ----       *Endlosschleife beim Auslesen*
	  mtdblock1    mtd0        6.966 KB   SquashFS-Filesystem ohne Kernel (hinterer Teil von mtd1)
	  mtdblock2    mtd1        7.616 KB   Kernel + SquashFS-Filesystem
	  mtdblock3    mtd2        64 KB      ADAM2 Bootloader ("Urlader")
	  mtdblock4    mtd3        256 KB     TFFS für Konfig-Daten
	  mtdblock5    mtd4        256 KB     Kopie TFFS (Double Buffering)
	  mtdblock6    (mtd5)      1.664 KB   (Vorbereitet für) JFFS2
	  mtdblock7    (mtd6)      5.952 KB   (Vorbereitet für) Kernel ohne JFFS2
	  ------------ ----------- ---------- ----------------------------------------------------------
```

Die weiteren drei `mtdblock`-Geräte ergeben Ausgaben der Länge null.

Zusammenfassend kann man sagen: Will man eine Kopie der **Partition
`mtd[n]`** haben, muß man offenbar das **Blockgerät `mtdblock[n+1]`**
benutzen.

Anmerkung von
[maceis](http://www.ip-phone-forum.de/member.php?u=95502)
(29.12.2011):

> *Diese Verschiebung kann ich bei meiner neuen 7270_v3 nicht
> feststellen. `cat /dev/mtdblock1` ergibt bei mir eine Datei, die aufs
> kB genau so groß ist, wie der Kernel. `cat /dev/mtdblock2` ist 128 kB
> groß. Das deckt sich mit den Ausgaben von `cat /proc/mtd` und
> `cat /proc/partitions`. Der Platz für den Urlader ist also
> offensichtlich größer geworden. (Warum?)*

Antwort von [Alexander Kriegisch
(kriegaex)](http://www.ip-phone-forum.de/member.php?u=117253)
(06.01.2012):

> *Ich sehe die Verschiebung aktuell auch nicht mehr auf meinen beiden
> Boxen. Das hängt wohl mit Firmware- bzw. Urladerversionen zusammen,
> kann also nicht pauschal für alle Geräte gesagt werden. Der Artikel
> ist ja auch schon ziemlich alt, und damals war es eben so. Zur Größe
> des Urladers: Tja, auch hier ändern sich offenbar die Zeiten. Während
> z.B. die 7170 und die 7270_v1 sowie alle älteren Modelle 64 kB
> Urladergröße hatten, sind es bei der [7270_v2/3 128
> kB](http://www.wehavemorefun.de/fritzbox/index.php/7270#Environment).
> Bei ganz neuen Boxen schließe ich auch 256 kB nicht aus, da müßte ich
> mal nachforschen, ich habe nur die älteren Geräte.*

### Kopien von Character Devices (mtd\*)

Jetzt wird es richtig verwirrend, denn bei den Zeichengeräten taucht
jede Partition zweimal hintereinander auf, allerdings nicht bis ganz zu
Ende, da es ja bei der laufenden Nummer 10 aufhört:

```
	  -------------- ----------- ---------- ----------------------------------------------------------
	  Zeichengerät   Partition   Größe      Beschreibung
	  mtd0/1         ----        ----       *Endlosschleife beim Auslesen*
	  mtd2/3         mtd0        6.966 KB   SquashFS-Filesystem ohne Kernel (hinterer Teil von mtd1)
	  mtd4/5         mtd1        7.616 KB   Kernel + SquashFS-Filesystem
	  mtd6/7         mtd2        64 KB      ADAM2 Bootloader ("Urlader")
	  mtd8/9         mtd3        256 KB     TFFS für Konfig-Daten
	  mtd10(/11)     mtd4        256 KB     Kopie TFFS (Double Buffering)
	  (mtd12/13)     (mtd5)      1.664 KB   (Vorbereitet für) JFFS2
	  (mtd14/15)     (mtd6)      5.952 KB   (Vorbereitet für) Kernel ohne JFFS2
	  -------------- ----------- ---------- ----------------------------------------------------------
```

Die eingeklammerten Zeichengeräte in der ersten Spalte würde es geben,
wenn `/sbin/makedevs` sie beim Hochfahren anlegen würde. In
`/etc/device.table` müßte dazu Folgendes geändert werden, um die Devices
bis `mtd15` zu erhalten:

```
	# Aktuelle Einstellung bei AVM und in Freetz
	/dev/mtd        c       640     0       0       90      0       0       1       11

	# Geänderte Einstellung (siehe letzte Spalte)
	/dev/mtd        c       640     0       0       90      0       0       1       16
```

> *Zitat [Oliver
> (olistudent)](http://www.ip-phone-forum.de/member.php?u=58639):
> "In der original Firmware hört das auch bei 10 auf. Da hab ich das
> halt so übernommen."*

Verständlich, würde ich sagen. Es kann ja jeder für sich ändern, falls
er glaubt, die Geräte zu brauchen.

Der Grund für die Doppelung ist übrigens, daß die Geräte mit den geraden
Nummern Lese-Schreib-Zugriff bieten, die mit den ungeraden
Nur-Lese-Zugriff.

Hier lautet die Formel: Will man eine Kopie der **Partition `mtd(n)`**
haben, benutzt man das **Zeichengerät `mtd(2n+2)`** - oder wahlweise
`mtd(2n+3)`.

### Ein (gefährlicher?) Tip, ohne Gewähr

Im
[OpenWRT-Forum](http://forum.openwrt.org/viewtopic.php?pid=18281#p18281)
ist nachzulesen, daß man auf diese Weise den Bootloader im laufenden
Betrieb überschreiben könne *(Konjunktiv beachten, ich kenne keinen hier
im Forum, der es getestet hat):*

```
    # Annahme 1: neuer Bootloader liegt schon unter /var/adam2_new
    # Annahme 2: /dev/mtdblock3 entspricht Bootloader-Partition mtd2

    # So nicht: cp /var/adam2_new /dev/mtdblock3/
    cat /var/adam2_new > /dev/mtdblock3

    reboot
```

**Update (`cat` statt `cp`, s.o.):** Wie unter 'ADAM2
überschreiben' nachzulesen, klappt das, wie mehrfach
bestätigt wurde und wie AVM auch vormacht in FW-Updates.

Wer will es versuchen? Falls es schief geht und man den Bootloader
löscht statt überschreibt oder das neue Image Mist ist, darf man das
Paket an AVM schon fertig machen :-/, sofern man nicht glücklicher
Besitzer eines
[JTAG-Kabels](http://feadispace.fe.funpic.de/FBF7050/)
(siehe auch
[OpenWrt.org](http://wiki.openwrt.org/OpenWrtDocs/Customizing/Hardware/JTAG_Cable))
mit passender Software ist. Falls man versehentlich "nur" eine andere
Partition überschreibt, sollte ein Recover reichen.

### Wege, sich schnell einen Überblick zu verschaffen

Was ich schon lange beschreiben wollte, da ich es zum Zeitpunkt der
Urfassung dieses Artikels noch nicht wusste, aber später durch
voneinander unabhängige Hinweise von [Sedat
(dileks)](http://www.ip-phone-forum.de/member.php?u=95274)
und [Enrik
(enrik)](http://www.ip-phone-forum.de/member.php?u=58906)
gelernt habe, ist, daß es sehr viel einfacher gewesen wäre, obige
Tabellen bzgl. Partitionen und Block Devices zu erstellen, hätte ich
folgende Befehle gekannt, die jeder auf seinem Boxtyp ausführen sollte,
um sich einen Überblick zu verschaffen, denn die Partitionen sind nicht
überall gleich groß und haben nicht überall die gleiche Nummerierung.
Beispielsweise ist der Urlader unter Kernel 2.4 unter `/dev/mtdblock/2`
zu finden und befindet sich unter Kernel 2.6 unter `/dev/mtdblock3`
(andere Nummer, eine Verzeichnisebene höher). Das ist wichtig zu wissen,
wenn man z.B. ein Downgrade auf eine ältere Firmwareversion vorhat, die
auch auf einen älteren Kernel und Bootloader aufsetzt. Es bringt ja
nichts, Letzteren in die falsche Partition zu schreiben.

### /proc/partitions

```
        $ cat /proc/partitions
    
        major minor  #blocks  name
    
          31     0       8192 mtdblock0
          31     1       6966 mtdblock1
          31     2       7616 mtdblock2
          31     3         64 mtdblock3
          31     4        256 mtdblock4
          31     5        256 mtdblock5
          31     6       1600 mtdblock6
          31     7       6016 mtdblock7
           8     0      64000 sda
           8     1      63984 sda1
```

Hier sieht man sehr schön die Größen der einzelnen Partitionen samt
Device Major/Minor (wer's braucht) und passenden Block-Device-Namen.

Auf einer 7270 sieht das etwas anders aus:

```
	$ cat /proc/partitions

	major minor  #blocks  name

	  31     0       6732 mtdblock0
	  31     1        883 mtdblock1
	  31     2         64 mtdblock2
	  31     3        256 mtdblock3
	  31     4        256 mtdblock4
	  31     5       8192 mtdblock5
```

Hier scheint mtdblock2 wirklich der Bootloader zu sein.

### /proc/mtd

```
	$ cat /proc/mtd

	dev:    size   erasesize  name
	mtd0: 00800000 00010000 "phys_mapped_flash"
	mtd1: 006cdb00 00010000 "filesystem"
	mtd2: 00770000 00010000 "kernel"
	mtd3: 00010000 00010000 "bootloader"
	mtd4: 00040000 00010000 "tffs (1)"
	mtd5: 00040000 00010000 "tffs (2)"
	mtd6: 00190000 00010000 "jffs2"
	mtd7: 005e0000 00010000 "Kernel without jffs2"
```

In dieser alternativen Darstellung mit in Hexadezimal-Schreibweise
angegebener Partitionsgröße sieht man noch als Kommentar eine
Beschreibung, die Auskunft darüber gibt, wofür die einzelnen Partitionen
tatsächlich vorgesehen sind. Sehr einfach, sehr praktisch.

Und auch hier wieder die 7270:

```
	$ cat /proc/mtd

	dev:    size   erasesize  name
	mtd0: 00693200 00010000 "rootfs"
	mtd1: 000dce00 00010000 "kernel"
	mtd2: 00010000 00010000 "urlader"
	mtd3: 00040000 00010000 "tffs (1)"
	mtd4: 00040000 00010000 "tffs (2)"
	mtd5: 00800000 00010000 "reserved"
```

#### Backup von Urlader, Kernel und Dateisystem

Wie man bei einer Kernel-2.6-Firmware konkret und effizient
`urlader.image` und `kernel.image` übers Netzwerk wegsichert, beschreibe
ich im
[Forum](http://www.ip-phone-forum.de/showthread.php?p=954170#post954170).

### Anmerkungen zur 7270v3 mit 2.6er Kernel (mit Version 74.04.88 getestet)

Das in den letzten Absätzen angegebene Layout für die 7270 mit obiger
Firmware kann ich noch um folgende Informationen zur letzten „Partition"
ergänzen. Die in „/proc/mtd" als "reserved" angegebene „mtd5" enthält
den gesamten Bereich von „mtd0" bis „mtd4" hintereinander. Darauf
gebracht hat mich die Größe von 16 MiB (0x800000). Hat man in Freetz das
Programm „dd" mit den Funktionen „if" und „of" (beides ist auszuwählen
im Menuconfig; getestet mit Freetz 1.2) integriert, läßt sich auf
einfache Weise eine vollständige Sicherheitskopie ziehen und
zurückspielen:

```
	$ dd if=/dev/mtdblock5 of=/var/media/ftp/uStor00/mtd5.bak
```

Wiederherstellen geht dann umgekehrt:

```
	$ dd of=/dev/mtdblock5 if=/var/media/ftp/uStor00/mtd5.bak
```

Das Programm „cat" ist zum Sichern ebenso geeignet, hier muß dann die
Ausgabe in die Zieldatei umgeleitet werden. Der erste eingesteckte
USB-Speicher ist für gewöhnlich als „/var/media/ftp/uStor00" eingehängt,
das kann natürlich im Einzelfall anders heißen. Mit „bzip2" kann man es
bei Bedarf noch geringfügig komprimieren. Für die Kopien habe ich ein
Skript auf dem USB-Speicher liegen, daß regelmäßig eine solche Kopie per
Cron anfertigt.

Getestet habe ich das auch: als der Router in einer Reboot-Schleife
hing, habe ich durch das Zurückspielen einer solchen Kopie erfolgreich
einen früheren Zustand wiederhergestellt.

Beachte, daß AVM das Layout in künftigen Versionen ohne weiteres wieder
ändern kann, tippe also niemals ohne eigene Prüfung einfach die
Befehlszeilen oben ab. [Christoph
Franzen](http://www.ip-phone-forum.de/member.php?u=121255)

### Zusammenfassung

Wer Kopien seiner Flash-Partitionen haben möchte, macht das im laufenden
Betrieb am besten, indem er das passende Block Device auswählt (Vorsicht
bei der verschobenen Numerierung!) und mittels `cat` die Daten auf ein
externes Medium wegsichert. *ADAM2* benötigt man hierfür jedenfalls
nicht zwingend, es geht auch so. Am besten kontrolliert man anhand der
sich ergebenden Dateigrößen, ob man die richtigen Partitionen erwischt
hat. Der Bootloader hat immer 64 KB, das TFFS 256 KB, der Rest hängt von
der Box und der Firmware-Version ab.

[Alexander Kriegisch
(kriegaex)](http://www.ip-phone-forum.de/member.php?u=117253)


