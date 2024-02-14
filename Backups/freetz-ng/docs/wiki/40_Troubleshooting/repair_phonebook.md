# Kaputtes Telefonbuch reparieren

### Symptom

Es können keine neuen Einträge hinzugefügt werden. Beim Versuch dessen
kommt die Fehlermeldung:

> FEHLER: Telefonbucheintrag fehlerhaft

### Ursache

Die Datei `/var/flash/phonebook` hat es "zerlegt" - wie und warum auch
immer.

### Lösung

Wie der Pfad unter *Überschrift* schon andeutet, ist eine Datei im Flash
kaputt - die also "nur" durch eine heile ersetzt werden muss. Wohl
dem, der noch ein Freetz Backup hat - für alle anderen hilft es nur, das
Telefonbuch komplett zu leeren:

```
    touch /tmp/leeredatei
    cat /tmp/leeredatei > /var/flash/phonebook
    rm /tmp/leeredatei
```

Anschließend die Box neu starten (am besten, indem man sie kurz vom Netz
trennt - bei einem normalen "Reboot" könnte sie sonst auf den Gedanken
kommen, vor dem Herunterfahren wieder die kaputte Version aus dem RAM in
den Flash zu speichern.

Wer nun noch ein Freetz Backup von einem Zeitpunkt hat, wo das
Telefonbuch noch in Ordnung war, kann aus dieser Archivdatei einfach das
Telefonbuch entpacken, auf den USB-Stick bzw. ins RAM der Box kopieren,
und selbige anstatt der leeren Datei zum Überschreiben des Telefonbuches
im Flash benutzen:

```
    # Auf dem PC
    tar czf freetz-backup.tar.gz flash/phonebook
    scp flash/phonebook root@fritz.box:/tmp/newphonebook
    rm flash/phonebook
    rmdir flash
    # Auf der Box
    cat /tmp/newphonebook > /var/flash/phonebook
    rm /tmp/newphonebook
```

Und dann wieder den Stromstecker ziehen, wie oben beschrieben.

> *Quelle: [IPPF
> Thread](http://www.ip-phone-forum.de/showthread.php?t=176144)*


