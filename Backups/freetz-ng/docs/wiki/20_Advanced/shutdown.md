# Rechner im Netz herunterfahren

Mit den Freetz-Paketen wol und callmonitor existieren einfach zu
konfigurierende Möglichkeiten, einen Rechner im Netz mittels
Mobiltelefon oder Freetz-Webinterface zu starten. Ebenso einfach
bedienbar ist das Herunterfahren eines Rechners hinter einer Fritzbox.
Die Konfiguration ist keine Hexerei, es funktioniert sowohl für Linux-
als auch Windows-Rechner.

### Voraussetzungen

-   Fritzbox mit den Paketen "dropbear" (inklusive ssh-client) und
    "callmonitor"

### Konfiguration der Fritzbox

### Keys erzeugen

-   Auf Fritzbox einloggen, Ordner erstellen und Public Keys erzeugen:
    ```
		mkdir /var/tmp/flash/ssh
		cd /var/tmp/flash/ssh
		dropbearkey -t rsa -f rsakey_box
    ```

-   Public Key extrahieren:
    ```
		dropbearkey -y -f rsakey_box | grep ssh > rsakey_box.pub
    ```

### Konfiguration der Fritzbox für herunterzufahrenden Linux-Rechner

-   Auf Fritzbox Datei (etwa
    /var/tmp/flash/ssh/shutdown_linuxrechner.sh) mit folgendem Inhalt
    erzeugen (Manche Distributionen verhindern in der
    Standardeinstellung, dass der Benutzer "root" sich einloggen kann.
    Ändere dies oder, ersetze "root" am besten durch einen Benutzer,
    der aus Sicherheitsgründen nur die Rechte zum Herunterfahren des
    Rechners hat):

```
		ssh -i /var/tmp/flash/ssh/rsakey_box root@<ip_rechner> "shutdown -h now"
```

-   Füge als abschließende Konfigurationsmaßnahme auf der Fritzbox
    folgende Zeile zu den Listenern des Callmonitors hinzu:

```
		in:request ^<abgangsrufnummer> ^<eingangsrufnummer> HOME=/mod/root && /var/tmp/flash/ssh/shutdown_linuxrechner.sh
```

### Konfiguration der Fritzbox für herunterzufahrenden Windows-Rechner

-   Auf Fritzbox Datei (etwa
    /var/tmp/flash/ssh/shutdown_windowsrechner.sh) mit folgendem Inhalt
    erzeugen, \<benutzername\> durch den Windows-Benutzernamen ersetzen:
    ```
		ssh -i /var/tmp/flash/ssh/rsakey_box <benutzername>@<ip_rechner> "shutdown -s"
    ```

-   Folgende Zeile zu den Listenern des Callmonitors hinzufügen:

    ```
		in:request ^<abgangsrufnummer> ^<eingangsrufnummer> HOME=/mod/root && /var/tmp/flash/ssh/shutdown_windowsrechner.sh
    ```

### Konfiguration des herunterzufahrenden Linux-Rechners

-   Public-Key (ja genau, jenen den wir vorhin extrahiert haben) von
    Fritzbox auf Zielrechner kopieren und authorisieren (evt. root durch
    /home/\<benutzername\> ersetzen, dann auch dafür sorgen, dass dieser
    Benutzer die Rechte hat, den Rechner runterzufahren):
    ```
		cat rsakey_box.pub >> /root/.ssh/authorized_keys
    ```

-   OpenSSH-Server installieren und starten.

### Konfiguration des herunterzufahrenden Windows-Rechners (getestet unter Windows XP)

-   Public-Key von Fritzbox auf Zielrechner kopieren, in
    "authorized_keys" umbenennen und im Ordner c:\\Dokumente und
    Einstellungen\\benutzername\\.ssh\\ ablegen. Auf dem Rechner des
    Autors musste der Ordner (des vorangestellten Punktes wegen) im
    Terminal angelegt werden (mkdir .ssh).

-   [Openssh](http://sshwindows.sourceforge.net/)
    installieren.

-   Konfigurationsdatei c:\\programme\\openssh\\etc\\sshd_config
    anpassen. Folgende Werte korrigieren:

    ```
		StrictModes no
		RSAAuthentication yes
		PubkeyAuthentication yes
		AuthorizedKeysFile  .ssh/authorized_keys
	```

Nun kann der Rechner mittels Anrufen der im Listener des Callmonitors
eingegebenen Rufnummer gestartet werden. Es funktioniert auch über das
Freetz-Webinterface, Extras, Testanruf.

### Bemerkungen

-   Der herunterzufahrende Rechner muss in /mod/root/.ssh/known_hosts
    eingetragen sein. Am einfachsten erreichst du das dadurch, dass du
    dich einmal von der Fritzbox aus mit dem Rechner über ssh
    verbindest.

-   Damit die erstellten Dateien nicht durch einen Neustart der Fritzbox
    verlorengehen, muss noch der Befehl "modsave flash" ausgeführt
    werden.


