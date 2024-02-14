# Wie die FritzBox Manipulationen erkennt

Wer kennt sie nicht, diese schöne Meldung auf der Startseite des
Web-Interface?

> ***In Ihrer FRITZBox wurden vom Hersteller nicht unterstützte
> Änderungen durchgeführt.***

### Ursachen

Was haben wir Böses gemacht, um diese Meldung zu verdienen? Da kommen
i.a. zwei Dinge in Frage:

-   **Telnet-Login:** Sobald der Benutzer sich auch nur ein einziges Mal
    via Telnet angemeldet hat, merkt sich die Box diesen Umstand - wie
    nachtragend - bis zum nächsten Recover, also normalerweise für alle
    Zeiten. Wer macht schon deswegen einen Recover?
-   **Nicht autorisiertes Firmware-Update:** Des Modding-Freaks Freude
    ist offenbar der FritzBox Leid. Auch das Einspielen eines
    Firmware-Updates, egal ob echter (Freetz-)Mod oder Pseudo-Update
    ohne Firmware-Änderung (LCR-Updater, Telnet-Aktivierung usw.), wird
    mit einem Eintrag ins Klassenbuch geahndet und führt zur eingangs
    erwähnten Meldung.

### Diagnose

Für beide Arten der Manipulation schreibt die Box Flags persistent in
den Flash-Speicher, allerdings nicht in eine der unter `/var/flash`
sicht- und änderbaren Konfigurationsdateien.

### eventsdump

Es gibt allerdings ein Werkzeug, um sich die gesetzten Flags anzeigen zu
lassen, wenn man auf der Box via Telnet oder SSH angemeldet ist:
`/sbin/eventsdump`.

```
	eventsdump -d | head -n 1
```

*Eventsdump* gibt eigentlich eine Ereignisliste auf die Konsole aus, wie
man sie auch über das Web-Interface zu sehen bekommmt. Der Parameter
*-d* führt dazu, dass eventuell gesetzte Manipulations-Flags mit
ausgegeben werden, und zwar direkt in der ersten Zeile. Die filtern wir
mit `head` heraus. Mögliche Ausgaben sind

-   *DEBUGCFG*,
-   *TELNET*,
-   *NOT_SIGNED*,
-   *IMPORT*,
-   *NOT_SIGNED,IMPORT,TELNET* (oder andere
    Zusammenstellung/Reihenfolge, ohne Leerzeichen)
-   oder etwas anderes, also die erste Zeile des regulären
    Ereignis-Logs.

So sehen wir also, was wir alles Böses getan haben.

### strace

Wenn wir jetzt wissen wollen, woher `eventsdump` seine Informationen
nimmt, müssen wir mit einem Werkzeug wie
[strace](http://sourceforge.net/projects/strace)
nachverfolgen, welche Systemaufrufe `eventsdump` macht. Hier ist ein
Ausschnitt aus einem `strace`-Log:

```
	01  mkdir("/var", 0777) = -1 EEXIST (File exists)
	02  mkdir("/var/flash", 0777) = -1 EEXIST (File exists)
	03  unlink("/var/flash/fw_attrib") = -1 ENOENT (No such file or directory)
	04  mknod("/var/flash/fw_attrib", S_IFCHR|0666, makedev(240, 87)) = 0
	05  open("/var/flash/fw_attrib", O_RDONLY) = 3
	06  ioctl(3, TIOCNXCL, 0x7fc22230) = -1 EOPNOTSUPP (Operation not supported)
	07  read(3, "NOT_SIGNED,TELNET", 4096) = 17
	08  write(1, "NOT_SIGNED,TELNET\n", 3) = 18
	09  close(3) = 0
	10  unlink("/var/flash/fw_attrib") = 0
```

Den Ausschnitt habe ich leicht umformatiert. Links steht statt der
Zeilennummern normalerweise jeweils die PID des beobachteten Prozesses.
Rechts nach dem Gleichheitszeichen steht übrigens immer der Rückgabewert
des Aufrufs.

Was passiert hier im Einzelnen?

1.  Verzeichnis `/var` wird angelegt, falls es noch nicht existiert.
2.  Verzeichnis `/var/flash` wird angelegt, falls es noch nicht
    existiert.
3.  Datei `/var/flash/fw_attrib` wird gelöscht, falls vorhanden.
4.  `/var/flash/fw_attrib` wird als Character Device mit den
    Major/Minor-Nummern 240/87 neu angelegt. Mehr dazu später.
5.  `/var/flash/fw_attrib` wird zum Lesen geöffnet. Der aufmerksame
    Leser fragt sich: zum Lesen?! Der Node wurde doch gerade erst
    angelegt.
6.  Die Systemfunktion *ioctl* wird aufgerufen, vermutlich um das
    "magische Verhalten" von `fw_attrib` zu initialisieren. Worin
    dieses besteht, werden wir gleich sehen. Hintergründe zu *ioctl*
    finden sich z.B. in [Linux-Gerätetreiber, 2. Auflage
    (OpenBook von
    O'Reilly)](http://www.oreilly.de/german/freebooks/linuxdrive2ger/book1.html)
    oder in der [englischen
    Wikipedia](http://en.wikipedia.org/wiki/Ioctl).
7.  Es wird aus `fw_attrib` gelesen. 17 Zeichen werden gefunden, sie
    enthalten den Text *NOT_SIGNED,TELNET*. Bingo!
8.  Genau dieser Text plus Zeilenvorschub wird auf die Standardausgabe
    des Prozesses geschrieben. (Das ist, was wir zu sehen bekommen, wenn
    wir `eventsdump -d` aufrufen.
9.  `fw_attrib` wird wieder geschlossen.
10. `fw_attrib` wird gelöscht, genauer gesagt der Node entfernt. Die
    Daten im Flash-Speicher überleben das, denn sie sind immer noch da,
    wenn wir genau das gleiche Character Device mit der selben
    Major/Minor-Kombination erneut öffnen.

### Character Device Nodes

Wie versprochen, mehr zu Ziffer 4. Das Erzeugen des Character Device
Nodes kann man auch selbst nachvollziehen, indem man den Shell-Befehl
`mknod` verwendet. Die Schritte 4 bis 8 sehen auf der Shell wie folgt
aus:

```
    mknod /var/flash/fw_attrib c 240 87
    cat /var/flash/fw_attrib
```

Ausgabe (ohne Zeilenvorschub):

```
	NOT_SIGNED,TELNET
```

Vorsichtshalber sollte man aber die auf diesem Character Device
arbeitende Befehlssequenz mit vor- und nachherigem Löschen des Nodes
umschließen, wie im Trace zu sehen. Also einfach
`rm -f /var/flash/fw_attrib`.

#### Major Number

Offenbar ist nicht bei jeder Box bzw. jedem Firmware-Stand die Major
Number dieselbe. Statt 240 kann also auch 250 oder etwas anderes als
Major festgelegt sein. Darum wollen wir die Major Number allgemein
feststellen können. Wie man in */etc/init.d/rc.S* sehr schön sehen kann,
wird beim Systemstart die Major fürs *tffs* so bestimmt:

```
	major=$(grep tffs /proc/devices)
	tffs_major=${major%%tffs}
```

Das können wir in unserem Code weiter verwenden, um ihn allgemeiner zu
machen.

*Anmerkung: Ob die Minor Number auch geräte- oder firmwareabhängig ist,
ist momentan nicht bekannt. Im ersten Fall einer unterschiedlichen Major
war die Minor gleich.*

#### Wann wird fw_attrib automatisch gelöscht?

Interessantes Detail: Auch ohne manuelles Löschen der Datei wird diese
vom System alle paar Sekunden automatisch gelöscht, sofern das
Web-Interface im Browser geöffnet ist. Das liegt daran, daß sich die
Seite regelmäßig automatisch neu lädt, und dabei wird wegen des Aufrufs
von `eventsdump -d` abgeräumt - security by obscurity. AVM möchte wohl
nicht, daß die Benutzer die Datei sehen und manipulieren. Deshalb müssen
wir den Node jedesmal wieder neu erzeugen. Aber das stört ja nicht, wenn
man es erst einmal weiß.

Um das Löschen zu verhindern, kann man der Datei auch einfach einen
anderen Namen geben, z.B. `/var/tmp/fw_attrib`. Wichtig sind die Major
und Minor Number.

### Lösungen

### In Handarbeit

Wenn wir aus `fw_attrib` lesen können, wieso dann nicht auch hinein
schreiben? Andere Prozesse tun es ja auch, wenn sie
"Klassenbucheinträge" vornehmen. Das geht so:

```
    major=$(grep tffs /proc/devices)
    tffs_major=${major%%tffs}
    rm -f /var/flash/fw_attrib
    mknod /var/flash/fw_attrib c $tffs_major 87
    echo -n "" > /var/flash/fw_attrib
    rm -f /var/flash/fw_attrib
```

Beachten Sie, daß `echo -n` nichts, also auch keinen Zeilenvorschub in
die Datei schreibt. Das kommt einem Löschen des Inhalts gleich. Ein
Kontroll-Aufruf von `eventsdump -d | head -n 1` bestätigt das, und wenn
man jetzt [http://fritz.box](http://fritz.box)
aufruft, ist auf der Übersichtsseite die Meldung verschwunden - das
Führungszeugnis ist sozusagen wieder sauber.
:-)

Aber freuen wir uns nicht zu früh, denn nach dem nächsten
unautorisierten FW-Update bzw. dem folgenden Telnet-Login ist die
Meldung wieder da. Was kann man also noch tun?

### Säuberungsaktion beim Systemstart

Obige Befehlssequenz kann man selbstverständlich auch
`/var/flash/debug.cfg` ausführen lassen. Solange man sich nicht per
Telnet anmeldet, ist die Meldung damit weg, auch wenn man zuvor gerade
ein FW-Update eingespielt hat. Tip: Mit SSH zu arbeiten, stört die
FritzBox nicht, denn damit rechnet sie nicht und kreidet es uns somit
auch nicht als Manipulation an. Wer also ein Freetz mit
Dropbear hat, ist fein heraus.

### Regelmäßiges Aufräumen mit cron

Mit Freetz hat man auch die Möglichkeit, einen *cron*-Job nach dem
Rechten sehen und aufräumen zu lassen. Selbst wenn man also *Telnet*
benutzt, ist, je nach eingestellter Frequenz, nach ein paar Minuten
wieder das Flag gelöscht.

### Telnet ruhig stellen per Hex-Editor

Wenn wir uns ein wenig in den Eingeweiden der Firmware umschauen,
stellen wir fest, daß nicht `telnetd` selbst das entsprechende Flag
setzt. Nein, es ist `/sbin/ar7login`. `telnetd` selbst wird ja wie folgt
aufgerufen, um eine Anmeldung zu ermöglichen:

```
    telnetd -l /sbin/ar7login
```

Wer mit einem Hex-Editor (unter Linux z.B. *hexedit* aus dem
gleichnamigen Paket) `ar7login` öffnet, findet schnell die Zeichenkette
"TELNET" in Großbuchstaben. Genau diese Zeichenkette schreibt das
Programm nach `fw_attrib`. Ersetzt man den ersten Buchstaben durch ein
Null-Byte, entspricht das dem Ersetzen des Wortes durch eine
Zeichenkette der Länge null, Strings in C sind schließlich
null-terminiert. (Ziemlich oft das Wort "null", Entschuldigung.)
Abspeichern, Firmware neu bauen, flashen - fürderhin bleiben wir
verschont von Klassenbucheinträgen für Telnet-Logins.

### Nachgelagertes Aufräumen per Proxy-Skript (Firmware-Variante)

Vielleicht traut sich nicht jeder die Arbeit mit dem Hex-Editor zu. Es
geht auch ohne. Anstatt `ar7login` binär zu manipulieren, wenden wir
einen Proxy-Ansatz an: Wir benennen `/sbin/ar7login` um in z.B.
`/sbin/ar7login-binary` und setzen an seine Stelle ein Shell-Skript
`/sbin/ar7login`:

```
    #!/bin/sh
    /sbin/ar7login-binary $*
    major=$(grep tffs /proc/devices)
    tffs_major=${major%%tffs}
    rm -f /var/flash/fw_attrib
    mknod /var/flash/fw_attrib c $tffs_major 87
    echo -n "" > /var/flash/fw_attrib
```

Wir reichen also einfach alle Parameter durch an `ar7login` und löschen
danach umgehend wieder dessen Spuren im Klassenbuch ;-)
Anschließend gilt analog zu Variante 1: Firmware bauen, flashen,
glücklich sein.

***Achtung: Das Flag wird erst gelöscht, nachdem die Telnet-Sitzung
wieder beendet wird.***

### Nachgelagertes Aufräumen per Proxy-Skript (transiente Variante)

Wem das Firmware-Bauen zu umständlich ist, kann die Proxy-Methode auch
dynamisch zur Laufzeit einsetzen, indem folgende Sequenz in
`/var/flash/debug.cfg` eingebaut wird:

```
    cat << EOF > /var/tmp/ar7login-proxy
    #!/bin/sh
    /var/tmp/ar7login-binary \$*
    major=\$(grep tffs /proc/devices)
    tffs_major=\${major%%tffs}
    rm -f /var/flash/fw_attrib
    mknod /var/flash/fw_attrib c \$tffs_major 87
    echo -n "" > /var/flash/fw_attrib
    EOF

    chmod +x /var/tmp/ar7login-proxy
    cp /sbin/ar7login /var/tmp/ar7login-binary
    mount -o bind /var/tmp/ar7login-proxy /sbin/ar7login
```

Wie man sieht, wird `ar7login` zunächst nach `/var/tmp/ar7login-binary`
kopiert. Das dynamisch erzeugte Skript `/var/tmp/ar7login-proxy` wird
ausführbar gemacht und überlagert durch `mount - o bind` die Datei
`/sbin/ar7login`, nur um als Proxy wiederum auf das kopierte Binary zu
verweisen und nach Ende der Sitzung dann wieder das Telnet-Flag zu
löschen.

### Aufräumen direkt nach dem Login (Firmware-Variante)

Die beiden Proxy-Varianten haben den Nachteil, während der Dauer der
Telnet-Sitzung auf deren Beendigung zu warten und erst anschließend das
Flag zu löschen. Wenn wir stattdessen unseren Aufräum-Code ins globale
Shell-Profil `/etc/profile` einbauen, wird er jeweils direkt nach dem
Login ausgeführt. Es gibt also keine signifikante Latenzzeit, in der die
Flags gesetzt sind, denn das Aufräumen erfolgt ja bereits zu Beginn der
Telnet-Sitzung.

```
    # ... normaler Inhalt von /etc/profile ...

    major=$(grep tffs /proc/devices)
    tffs_major=${major%%tffs}
    rm -f /var/flash/fw_attrib
    mknod /var/flash/fw_attrib c $tffs_major 87
    echo -n "" > /var/flash/fw_attrib
```

### Aufräumen direkt nach dem Login (transiente Variante)

Ebenso wie bei der Proxy-Methode gilt auch hier: Das Profil kann auch
beim Booten aus `/var/flash/debug.cfg` heraus umgeschrieben werden,
indem man es per `mount` der Original-Datei überlagert:

```
    cp /etc/profile /var/tmp/profile

    cat << EOF >> /var/tmp/profile
    major=\$(grep tffs /proc/devices)
    tffs_major=\${major%%tffs}
    rm -f /var/flash/fw_attrib
    mknod /var/flash/fw_attrib c \$tffs_major 87
    echo -n "" > /var/flash/fw_attrib
    EOF

    mount -o bind /var/tmp/profile /etc/profile
```

Man beachte, daß dieses Mal `cat` keine Datei erzeugt, sondern seine
Ausgabe an die zuvor kopierte Originaldatei anhängt. Da wir auch nicht
irgendwelche komplizierten Proxy-Konstrukte haben, brauchen wir uns auch
nicht zu verrenken mit der Namensgebung der Shell-Profile.

### Freetz Patch

Mit einem Patch für
Freetz lässt sich der ganze obige Stress
vermeiden, und die vermaledeite Meldung ist weg. Da unterstreicht das
"Free" in "Freetz" doch gleich, was es heißt
:-)

### einfacheres Löschen

Man kann tffs-Dateien auch über /proc/tffs löschen. In diesem Fall ist
der Befehl:

```
echo clear_id 87 > /proc/tffs
```

### Schlußwort und Ausblick

Wozu die vielen Varianten, wenn es mit dem Patch doch so einfach geht?
Ich dachte mir, ich erkläre mal die unterschiedlichen Ansätze, wie man
beim FritzBox-Modding grundsätzlich vorgehen kann - von minimal-invasiv
aus der `debug.cfg` heraus über die Manipulation von Skripten in der
Firmware bis hin zum Patchen einer Binärdatei. Ich hoffe, meine
Anregungen helfen anderen Mitstreitern beim Entwickeln von Konzepten, um
die gute AVM-Firmware mit neuen Ideen noch ein bißchen besser, bequemer
oder einfach cooler zu machen - kurz: um zu erreichen, was auch AVM uns
nicht übel nehmen dürfte: optimale Ausnutzung der Hard- und Software,
die wir beim Hersteller oder einem seiner Vertriebspartner gekauft
haben.

Was bleibt bzgl. dieses Themas noch offen? Nun, da sind immer noch die
digitalen Signaturen, mit denen die Firmware-Images versehen sind. Sie
sind an sich nichts Schlechtes, im Gegenteil. AVM, T-Com und 1&1 tun gut
daran, ihre jeweiligen Firmware-Versionen eindeutig als solche zu
kennzeichnen und weisen mit Recht bei fehlerhafter Verifikation der
Signaturen darauf hin, daß Support-Ansprüche für modifizierte Firmwares
nicht mehr bestehen. Was ist aber, falls eines Tages der Hersteller oder
einer seiner OEM-Partner beschließen sollten, die Boxen so zu
konfigurieren, daß nicht korrekt signierte Firmware-Versionen nicht mehr
zum Flashen angenommen würden? Das wäre eine Beschneidung der
Benutzerrechte, für die es keinen triftigen Grund gäbe. Deswegen habe
ich mir kürzlich die Signatur-Mechanismen angeschaut und auch hier
Mittel und Wege gefunden, sie zu entschärfen. Mehr dazu gibt es ein
anderes Mal.

Weiterhin happy modding wünscht Euch

[Alexander Kriegisch
(kriegaex)](http://www.ip-phone-forum.de/member.php?u=117253)
### 

Anmerkung: Ich habe eben in meiner neuen FBF 7170 (FW 29.4.32-7153) das
schreiben in `/var/flash/fw_attrib` versucht. Zunächst lies dies die
Meldung im Web-Interface jedoch vollkommen unbeeindruckt. Erst als ich
mit

```
    echo -n "\0\0\0\0\0\0" >/var/flash/fw_attrib
```

mein "TELNET" in dem fw_attrib überschrieben habe, verschwand die
Meldung im Web-Interface! Kann es sein, daß es notwendig ist die
betreffenden Daten zu überschreiben (mit binär 0 = Stringende)?

Harald Becker (ralda)


