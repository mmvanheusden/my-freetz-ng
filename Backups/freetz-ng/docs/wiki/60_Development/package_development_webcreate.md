# Erstellen einer GUI für Pakete in Freetz

### Motivation

Ein großer Faktor für den Erfolg von Freetz ist die Tatsache, dass die
Pakete dort über eine GUI zu konfigurieren sind. Über den Aufbau und die
Vorgehensweise zur Erstellen einer solchen GUI soll es in diesem Beitrag
gehen. Als Grundlage nehmen wir ein virtuelles Paket mit Namen "hugo"
an, um einen Bezug zu haben

### Grundlagen

Bevor man sich Gedanken über die GUI machen kann, sind ein paar
grundlegende Dinge über die Art und Weise zu sagen, wie in Freetz Pakete
funktionieren. Als grundlegende Information sei auf die [Doku
von
Daniel](http://www.ip-phone-forum.de/showthread.php?t=90425)
verwiesen, hier soll das ganze nur kurz wiedergegeben werden (ich hoffe
das "fast wortwörtliche direkte Kopieren" aus dem Thread von Daniel
ist mir hier erlaubt):

### Eigene Pakete

An ein Paket stellen sich folgende Anforderungen:

-   rc Skript:
    `etc/init.d/rc.<paketname> [start|stop|load|unload|restart|status]`

Wenn konfigurierbar:

-   Default Konfiguration: `etc/default.<paketname>/<paketname>.cfg`
-   Optional: cgi Skript für die Weboberfläche:
    `usr/lib/cgi-bin/<paketname>.cgi`
-   Optional: Extra cgi Skripte in `usr/lib/cgi-bin/<paketname>/`

Sonstige Default Dateien sollten auch ins Verzeichnis
etc/default.\<paketname\>/ gepackt werden.

-   `/mod/etc/init.d/rc.<paketname>`
-   `/mod/etc/default.<paketname>/*`
-   `/mod/usr/lib/cgi-bin/<paketname>.cgi`
-   `/mod/usr/lib/cgi-bin/<paketname>/*`

sind immer gültig (sofern im Paket enthalten) und werden bei statischen
Paketen über Symlinks realisiert. Binaries sollten nach `bin`, `sbin`,
`usr/bin` oder `usr/sbin`, damit sie sowohl in statischen als auch
dynamischen Paketen aufrufbar sind (die PATH Variable enthält auch
`/mod/bin`, `/mod/sbin`, `/mod/usr/bin` und `/mod/usr/sbin`). Libraries
funktionieren mit statischen wie auch dynamischen Paketen in lib
(`LD_LIBRARY_PATH=/mod/lib` ⇒ Library wird in `/lib` und `/mod/lib`
gesucht)

Benötigt ein Daemon eines Paketes eine Konfigurationsdatei (z.B.
`hugo.conf`), die für diesen Daemon spezifisch ist, so wird sie in der
Regel im rc Skript vor dem Starten des Daemons erzeugt. Ich habe dafür
folgende Konvention gewählt (ist aber kein muss), welche am Beispiel der
`bftpd.conf` erläutert ist:

1.  Suche nach Skript `/tmp/flash/hugo_conf`, welches die `hugo.conf`
    als Ausgabe hat; existiert? → goto 3.
2.  Führe Skript `/etc/default.hugo/hugo_conf` aus, die Ausgabe ergibt
    wie bei 1. die `hugo.conf` (meistens ist dies der Fall)
3.  Existiert `/tmp/flash/hugo.conf.extra`? → füge sie an die in 1.
    oder 2. generierte `hugo.conf` an

Das sollte alle Möglichkeiten des "Feintunings" offen lassen. 3. macht
nicht immer Sinn, darum ist es optional. Wäre schön, wenn jeder, der ein
Paket erstellt, die Konventionen einhält. Das Skript `hugo_conf` muss
stets mit exportierten Variablen aus `/mod/etc/conf/hugo.cfg` aufgerufen
werden. So wird die `hugo.conf` je nach Paket-Konfiguration individuell
erstellt.

### Konfiguration

Jedes Paket besitzt ein Konfigurationsdatei
`/mod/etc/conf/<paketname>.cfg`, welche wie folgt aufgebaut ist:

```
  export <PAKETNAME>_OPTION1='bla'
  export <PAKETNAME>_OPTION2='blub'
  ...
```

Sie enthält alle Optionen, die auch übers Webinterface eingestellt
werden können und ist in Shell Syntax. Damit kann die aktuelle
Konfiguration mit

```
  . /mod/etc/conf/<paketname>.cfg
```

eingelesen werden. In der Datei
`/mod/etc/default.<paketname>/<paketname>.cfg` sind die default
Einstellungen gespeichert. Beim Speichern werden nur die sich von den
Defaults unterscheidenden Variablen in die `/tmp/flash/<paketname>.diff`
transferiert und mit dem ganzen Verzeichnis `/tmp/flash/` ins tffs
abgelegt. Die Basis-Konfiguration hat den Paketnamen 'mod'. Die
Befehle dazu sind:

```
      modconf load <paketname>
      # -> erzeugt die Datei /mod/etc/conf/<paketname>.cfg aus den Defaults und der <paketname>.diff


      modconf save <paketname>
      # -> erzeugt die Datei <paketname>.diff aus den Defaults und der /mod/etc/conf/<paketname>.cfg

      modsave
      # -> ruft unter anderem für alle Pakete 'modconf save' auf und speichert das Verzeichnis /tmp/flash ins tffs

      modsave flash
      # -> speichert nur das Verzeichnis /tmp/flash ins tffs
```

Das dauerhafte Abschalten des Webinterfaces geht damit so (Variable
MOD_HTTPD in der Basis-Konfiguration 'mod'):

```
  vi /mod/etc/conf/mod.cfg  # -> MOD_HTTPD='yes' durch MOD_HTTPD='no' ersetzen
  modconf save mod  # nun ist mod.diff up-to-date
  modsave flash  # damit ist mod.diff im tffs

  # oder

  vi /mod/etc/conf/mod.cfg  # -> MOD_HTTPD='yes' durch MOD_HTTPD='no' ersetzen
  modsave  # erzeugt alle diff Dateien neu und speichert ins tffs
```

Soviel zur Veranschaulichung. Komfortabler ist folgendes:

```
  modconf set mod MOD_HTTPD=no
  modconf save mod
  modsave flash

  # bzw.

  modconf set mod MOD_HTTPD=no
  modsave
```

### Wie funktioniert das mit der GUI?

Im vorigen Abschnitt wurde beschrieben, welche Dateien es gibt und wie
ich die Werte von Variablen direkt von der Shell aus ändern kann. Die
Freetz GUI's basieren auf dem Konzept des
[Proccgi](http://www.fpx.de/fp/Software/ProcCGI.html)
von Frank Pilhofer. Hierzu bedienen sie sich Umgebungsvariablen, die wie
oben beschrieben dem Muster `<Paketname>_<Variablenname>` folgen. In den
HTML-Seiten der GUI werden Input-Felder mit dem Tag
`name="<Variablenname>"` versehen. Diese Felder korrespondieren dann mit
den Variablen. Alle GUI-Seiten sind in einen Rahmen-Formular von Freetz
untergebracht, das über den Button "Übernehmen" diese Variablen
ausliest und der Umgebungsvariable zuweist.

### Ein Beispiel

Ich hoffe, ein kleines Beispiel macht das deutlicher, unser "Paket"
heisst wie schon gesagt "hugo". Als erstes legen wir das "default"
Verzeichnis und die hugo.cfg Datei an.

```
    mkdir /mod/etc/default.hugo
    touch /mod/etc/default.hugo/hugo.cfg
```

Im "default" Verzeichnis des Paketes `/etc/default.hugo/hugo.cfg`
werden die benutzten Variablen über einen export definiert und zugleich
auch mit einem "default-Wert" belegt. Wenn man später also im
Webinterface auf "Standard" klickt, werden die dort festgelegten Werte
aus der GUI übernommen. So eine Datei sähe dann in etwa so aus:

```
    export HUGO_ACTION='ACCEPT'
    export HUGO_CHAIN='INPUT'
    export HUGO_DESTINATION='anywhere'
    export HUGO_ENABLED='no'
```

Damit sind die Variablen `ACTION`, `CHAIN`, `DESTINATION`, `ENABLED`,
etc. definiert. Diese Variablennamen werden in der GUI, einem
"cgi-File" belegt (per Eingabe oder auch per javascript).

Der entsprechende Abschnitt dazu im Code

```
    <p>DESTINATION: <input type="text" name="destination" value="$(html "$HUGO_DESTINATION")"></p>
```

man sieht hier auch, dass dieses "cgi"-File Shellauswertung nutzt, um
im HTML-Code den Wert von "DESTINATION" als Vorbelegung nutzt.

Beim "Übernehmen" werden diese Variablen mit den "default-Variablen"
verglichen und beim Abweichen direkt resetfest im Flash abgespeichert.

Gibt man hier nun in das Feld "Blabla" ein, erzeugt das "Übernehmen"
die Datei `/var/tmp/flash/hugo.diff` mit diesem Inhalt:

```
    export HUGO_DESTINATION='Blabla'
```

die mit `modsave` auch gleich gesichert wird. Auch wird aus der
Zusammenführung der default-Werte und der geänderten Werte im
*diff*-file die aktuelle Datei `/mod/etc/conf/hugo.cfg` erstellt, die
für jede Variable den aktuellen Wert zuweist (das alles macht übrigens
das cgi `/usr/mww/cgi-bin/save.cgi`, der beim Abschicken des Formulars
aufgerufen wird).

hat man also die `hugo.cfg` Datei im "default" Verzeichnis fertig
gestellt, so kopiert man diese nach `/mod/etc/conf`

```
    modconf load hugo
```

Jetzt kommt die GUI Programmierung dran. Die Datei `hugo.cgi` wird im
Verzeichnis `/mod/usr/lib/cgi-bin/` angelegt und sollte ungefähr so
aussehen.

```
    #!/bin/sh

    PATH=/bin:/usr/bin:/sbin:/usr/sbin
    . /usr/lib/libmodcgi.sh

    # setzt auto_chk oder man_chk auf ' checked', je nach Wert von HUGO_ENABLED
    check "$HUGO_ENABLED" yes:auto "*":man

    sec_begin 'Activation'
    cat << EOF
    <div style="float: right;"><font size="1">Version 1.0.3</font></div>
    <p>
    <input id="e1" type="radio" name="enabled" value="yes" $auto_chk><label for="e1"> Active</label>
    <input id="e2" type="radio" name="enabled" value="no" $man_chk><label for="e2"> Inactive</label>
    </p>
    EOF
    sec_end

    sec_begin 'hugo Überschrift'
    cat << EOF
    ...
    <p>DESTINATION: <input type="text" name="destination" value="$(html "$HUGO_DESTINATION")"></p>
    ...
    EOF
    sec_end
```

Wollen wir eine zusätzliche Datei fest ins Flash speichern, so müssen
wir diese mit `modreg file` registrieren und eine Datei namens
`hugo_file.def` im Verzeichnis `/mod/etc/default.hugo` anlegen. Inhalt
muss so aussehen:

```
    CAPTION='Überschrift'
    DESCRIPTION='Beschreibung dieser Datei. Bla bla bla...'
    CONFIG_FILE='/tmp/flash/hugo_file'
    CONFIG_SAVE='modsave flash;'
    CONFIG_TYPE='text'
```

(Falls die zu bearbeitende Datei zunächst generiert werden muss, kann
die nötige Anweisung in `CONFIG_PREPARE` angegeben werden.)

Der Daemon, der unsere Arbeiten ausführt, heisst `rc.hugo` und wird
unter `/mod/etc/init.d` angelegt. Die ersten Zeilen müssen so aussehen:

```
    #!/bin/sh

    DAEMON=hugo

    # Liest Paketkonfiguration ein und definiert einige Hilsfunktionen
    . /etc/init.d/modlibrc

    start() {
             # HIER KOMMEN DIE VERARBEITUNGEN REIN
             echo "Starting hugo..."
    }

    stop() {
             # HIER KOMMEN DIE VERARBEITUNGEN REIN
             echo "Stopping hugo..."
    }

    case "$1" in
            start)
                    start
                    ;;
            stop)
                    stop
                    ;;
            restart)
                    stop
                    start
                    ;;
            status)
                    if [ -z "$(pidof "$DAEMON")" ]; then
                            echo 'stopped'
                    else
                            echo 'running'
                    fi
                    ;;
         ""|load)
                    # CGI registrieren
                    modreg cgi $DAEMON Bezeichnung
                    # File registrieren (wird resetfest ins flash gespeichert)
                    # modreg file <pkg> <id> <title> <sec-level>  <desc-file (ohne Pfad und .def-Endung)>
                    modreg file 'hugo' 'config' 'HUGO: File' 0 "hugo_file"

                    if [ "$HUGO_ENABLED" != "yes" ]; then
                            echo "$DAEMON is disabled" 1>&2
                            exit 1
                    else
                            start
                    fi
                    ;;

                    ;;
            unload)
                    stop
                    modunreg file 'hugo'
                    modunreg cgi 'hugo'
                    ;;
            *)
                    echo "Usage: $0 [start|stop|restart|status]" 1>&2
                    exit 1
                    ;;
    esac

    exit 0
```

Jetzt löschen den cache und bauen wir den Menüpunkt "hugo" in das
Webmenü ein.

```
    rm /var/mod/var/cache/menu/packages
    modreg cgi hugo hugo
```

**TIPP:** Wenn man ein CGI entwickelt, sollte man seine Arbeiten auf
einen angeschlossenen USB-Stick ablegen und die entsprechenden Dateien
ins RAM von Freetz kopieren bzw. Softlinks setzen. Hier ein Beispiel für
ein kleines Script, welches die Dateien temporär ins RAM kopiert.

```
    #!/bin/sh
    mkdir /mod/etc/default.hugo
    cp hugo.cfg /mod/etc/default.hugo
    modconf load hugo
    cd /mod/usr/lib/cgi-bin
    ln -s /var/media/ftp/uStor01/hugo.cgi hugo.cgi
    cd /mod/etc/init.d
    ln -s /var/media/ftp/uStor01/rc.hugo rc.hugo
    modreg cgi hugo hugo
    cd -
```


