# Aufbau eines Patches

Ein Patch ist eine Datei im Textformat, die für gewöhnlich die Endung
.patch (manchmal auf .diff) hat und eine Liste von Unterschieden
zwischen zwei Version einer Datei enthält. Patches enthalten nur
Unterschiede in Textdateien. Unterschiede in Binärdateien können nicht
gepatched werden.

Zu Beginn eines Patch kann ein Kommentar stehen, der beschreibt wo der
Patch herkommt, wer daran mitgewirkt hat, welches Problem er löst usw.
Der eigentliche Beginn der Unterschiede wird durch `---` gekennzeichnet.
Für gewöhnlich enthält ein Patch 3 Zeilen Kontext vor und nach jeder
geänderten Zeile. Diese dienen als Referenz, so dass der Patch auch noch
angewendet werden kann falls an der zu patchenden Datei eine Änderung
vorgenommen wurde und die Zeilennummern nicht mehr korrekt sind.

```
Dieser Patch ist ein Beispiel und fügt menuconfig einen neuen Eintrag hinzu.

Index: make/Config.in
===================================================================
--- make/Config.in   (Revision 7307)
+++ make/Config.in   (Arbeitskopie)
@@ -51,6 +51,7 @@
 source make/netcat/Config.in
 source make/nc6/Config.in
 source make/netsnmp/Config.in
+source make/newpackage/Config.in
 source make/nfs-utils/Config.in
 source make/ntfs/Config.in
 source make/openntpd/Config.in
```

In den meisten Fällen lauten die 2 Dateinamen (hier make/Config.in)
gleich, manchmal Unterscheiden sie sich in der Endung (.orig), je
nachdem wie der Patch erstellt wurde. Im Beispiel ist also eine Änderung
an der Datei make/Config.in beschrieben. Konkret wurde hier ein neues
Paket *newpackage* geschrieben und soll jetzt dem menuconfig hinzugefügt
werden. Die fünfte Zeile des Patches enthält Informationen darüber wo
sich der zu patchende Abschnitt (hunk) in der Datei befindet und wie
viele Textzeilen der Patch verändert. Im Beispiel beginnt der Patch ab
Zeile 51 und fügt eine Zeile (7-6=1), gekennzeichnet durch ein `+`,
hinzu. Man könnte also das gleiche Ergebnis erreichen, wenn man die
Datei make/Config.in in einem Texteditor öffnet und die Zeile
`source make/newpackage/Config.in` an der beschriebenen Stelle
hinzufügt.

### Erzeugen eines Patches

Man hat eine Datei (Config.in) geändert und difft sie gegen SVN:

```
 svn diff Config.in > Config.patch
```

Alle Änderungen im Verzeichnis + Unterverzeichnisse:

```
svn diff > all.patch
```

Falls man neue Dateien angelegt hat müssen diese erst dem SVN
hinzugefügt werden:

```
svn add Datei- oder Verzeichnisname
```

### Patch anwenden oder rückgängig machen

Patch anwenden:

```
$ patch -p0 < Config.patch
patching file Config.in
$
```

Patch rückgängig machen:

```
$ patch -Rp0 < Config.patch
patching file Config.in
$
```

Falls ihr so etwas seht:

```
$ patch -p0 < Config.patch
patching file Config.in
Hunk #1 FAILED at 1.
1 out of 1 hunk FAILED -- saving rejects to file Config.in.rej
```

Dann passt der Patch nicht mehr und muss erneuert werden.

-   TODO (evtl. aus dem
    [ippf-Wiki](http://wiki.ip-phone-forum.de/software:ds-mod:howtos#patches_in_den_ds-mod_einspielen)
    kopieren)

### Wie finde ich die zu patchende Stelle?

Auf diese Frage muss man primär antworten: Es kommt darauf an, worum es
geht. Weil das aber hier im Wiki natürlich nicht so befriedigend ist,
folgen ein paar Tipps von RalfFriedl am konkreten Beispiel von crond
bzw. dem Frotend dazu, nämlich dem crontab-Fenster im Freetz WebGUI.

Da cron nicht ein extra Paket ist, sondern zum Freetz Basis-System
gehört, liegen die Dateien für cron unter dem Verzeichnis
"make/mod/root/files". Wenn es ein eigenes Paket wäre, z.B. inetd,
wären die Dateien unter "make/inetd/files/root".

Im folgenden geht es darum, wie man die Web-Oberfläche von crontab
ändert und dann patcht. Am einfachsten findet man die Datei, wenn man
nach einem Text sucht, der sonst hoffentlich selten vorkommt,
"crontab" scheint hier ein guter Wert zu sein.

```
$ grep -r crontab make 2> /dev/null | fgrep -v /.svn/
make/mod/files/root/etc/init.d/rc.crond:        cat /tmp/flash/mod/crontab /etc/cron.d/* /tmp/cron.d/* 2> /dev/null |
make/mod/files/root/etc/init.d/rc.crond:            crontab -u root -
make/mod/files/root/etc/init.d/rc.crond:                [ -r /tmp/flash/crontab.save ] && mv /tmp/flash/crontab.save /tmp/flash/mod/crontab
make/mod/files/root/etc/init.d/rc.crond:                modreg file mod crontab 'crontab' 0 "crontab"
make/mod/files/root/etc/init.d/rc.crond:                modunreg file mod crontab
make/mod/files/root/etc/default.mod/crontab.def:CAPTION='Freetz: crontab'
make/mod/files/root/etc/default.mod/crontab.def:CONFIG_FILE='/tmp/flash/mod/crontab'
```

Das suchen in "make" ist nur für den Fall, dass man nicht sicher ist,
in welchem Verzeichnis sich die Dateien befinden. Wenn man weiss, daß
cron zum Hauptsystem gehört, kann man direkt in "make/mod/files"
suchen, dann geht es schneller. Die Umleitung "2\> /dev/null"
unterdrückt Fehlermeldungen wegen nicht gefundener Dateien/Links.

Die Ergebnisse in Dateien mit "/.svn/" im Pfad sind hier nicht von
Bedeutung.

Der Text "crontab" kommt also in den Dateien rc.crond und crontab.def
vor. Das sagt uns leider noch nicht, was man machen muss, um eine Hilfe
auf die Seite zu bringen. Also suchen wir einmal nach "Hosts", weil
auf der Hosts-Seite schon eine Hilfe da ist.

```
$ grep -r Hosts make 2> /dev/null | fgrep -v /.svn/
...
make/mod/files/root/etc/default.mod/hosts.def:CAPTION='Freetz: hosts'
root/etc/init.d/rc.mod:         modreg file 'exhosts' 'Hosts' 1 "$deffile"
... und noch viele andere Treffer
```

Die Definitionsdatei, aus der der Text "hosts" kommt, ist also
make/mod/files/root/etc/default.mod/hosts.def. Schauen wir uns also mal
die Datei an:

```
$ cat make/mod/files/root/etc/default.mod/hosts.def
CAPTION='Freetz: hosts'
DESCRIPTION='Syntax: &lt;ip&gt; &lt;mac&gt; &lt;interface&gt; &lt;host&gt; [&lt;aliases|#description&gt;]<br>
($(lang de:"z.B.: 10.0.0.1 * * www.local mfh1 # Mein Server" en:"e.g. 10.0.0.1 * * www.local mfh1 # my server")) *=&quot;$(lang de:"nicht definiert" en:"not defined")&quot;'
... der Rest ist hier nicht von Bedeutung
```

Wir sehen also, dass die Beschreibung aus dem Eintrag DESCRIPTION kommt,
der in der Datei make/mod/files/root/etc/default.mod/crontab.def nicht
vorhanden ist. Man muss also in der Datei
make/mod/files/root/etc/default.mod/crontab.def einen Eintrag
DESCRIPTION anlegen.

Wenn man will, dass mehrere Sprachen mit \$(lang ...) unterstützt
werden, dann muss man auch sicherstellen, dass die Datei in der
passenden Liste hinterlegt ist. Dies ist die datei ".language" im
Verzeichnis make/\<Paket\>/files.

Die Datei sieht so aus:

```
$ cat .language
languages
{ de en }
default
{ en }
files
{
        etc/default.mod/*.def
        etc/init.d/rc.mod
        usr/bin/modreg
        ...
}
```

Wir sehen hier, dass alle Dateien etc/default.mod/\*.def schon
inkludiert werden und kein weiterer Eintrag notwendig ist.

Die geänderte Datei ist in diesem Fall nur
make/mod/files/root/etc/default.mod/crontab.def und es geht weiter wie
unten beschrieben.

Hintergrundinfos finden sich in diesem
[IPPF-Thread](http://www.ip-phone-forum.de/showthread.php?p=1274104#post1274104).

### Links

[Wikipedia Artikel zu diff
(Englisch)](http://en.wikipedia.org/wiki/Diff)
[Wikipedia Artikel zu patch
(Englisch)](http://en.wikipedia.org/wiki/Patch_(Unix))


