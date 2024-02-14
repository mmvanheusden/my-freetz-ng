# Benutzerverwaltung

### Benutzer anlegen

Nehmen wir an, der neue Benutzer soll *picard* heißen. Benutzer *root*
macht dann Folgendes:

### Freetz

```
    # Benutzer hinzufügen
    adduser picard
    # in buffer speichern ???
    # Persistent speichern
    modsave flash
```

### ds-mod

```
    # Benutzer hinzufügen
    echo "picard:*" >> /tmp/flash/shadow.save
    # Persistent speichern
    modsave flash
    # Alle Benutzer neu laden, fehlende Heimverzeichnisse erzeugen
    modpasswd load
    # Paßwort vergeben (wird automatisch persistent gespeichert)
    modpasswd picard
    # Test
    login picard
```

### Benutzer löschen

Jetzt der umgekehrte Weg - Benutzer *picard* soll wieder weg. Benutzer
*root* macht dann Folgendes:

### Freetz

```
    # Benutzer löschen
    deluser picard
    # Persistent speichern
    modsave flash
```

### ds-mod

```
    # Heimverzeichnis löschen
    rm -rf /mod/home/picard
    # Temporäre Datei mit gelöschtem Benutzer erzeugen
    grep -v '^picard:' /tmp/flash/shadow.save > /tmp/deleted-user
    # Benutzerdatei überschreiben
    mv /tmp/deleted-user /tmp/flash/shadow.save
    # Persistent speichern
    modsave flash
    # Alle Benutzer neu laden (jetzt einen weniger)
    modpasswd load
    # Test (schlägt mit "Login incorrect" bei PW-Eingabe fehl)
    login picard
```

### Manuelle Anpassungen

Um z.B. die UID anzupassen geht man nach dem erfolgreichen Anlegen wie
oben beschrieben, wie folgt vor:

-   Datei /tmp/passwd bearbeiten
-   modsave flash
-   modsave

### Besonderheiten

### Dropbear

In Freetz akzeptiert Dropbear standardmäßig nur Logins des Benutzers
`root`. Wer auch Anmeldungen anderer Benutzer ermöglichen will, muss auf
der Freetz-Weboberfläche die Option "Login nur für root erlauben"
deaktivieren. Das Entfernen des Patches
`make/dropbear/patches/100-root-login-only.patch` ist - anders als in
früheren Versionen - nicht mehr nötig.


