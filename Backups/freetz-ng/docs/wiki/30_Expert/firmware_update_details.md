# Ablauf eines Firmware-Updates

Bei einem Firmware-Update über das AVM-Web-Interface passiert in etwa
Folgendes (kein Anspruch auf Vollständigkeit):

-   Die Steuerung des gesamten Vorgangs übernimmt das Binary
    `/usr/www/cgi-bin/firmwarecfg`. Es wird vom Webserver aufgerufen.
-   `firmwarecfg` ruft zunächst das Shell-Skript
    `/bin/prepare_fwupgrade` auf, um diverse Dienste zu stoppen und
    somit Platz im RAM für das Firmware-Archiv zu schaffen. Auch Spuren
    von evtl. früheren Updates in der RAM-Disk (`/var`) werden gelöscht.
    `prepare_fwupgrade` wird entweder mit dem Parameter *start* oder mit
    *start_from_internet* aufgerufen, je nachdem, ob ein Update von
    der AVM-Seite geladen werden soll oder von Festplatte. Der
    Unterschied besteht v.a. darin, daß der DSL-Daemon `dsld` im zweiten
    Fall zunächst nicht gestoppt wird.
-   Nachdem nun ein Großteil der Aktivitäten der FritzBox stillgelegt
    ist, wird das Firmware-Image in die RAM-Disk übertragen und dort
    mittels tar entpackt. Dabei wird die digitale Signatur des Pakets
    geprüft. Falls sie nicht korrekt verifiziert werden kann oder fehlt,
    wird später die bekannte Meldung über eine nicht freigegebene
    Firmware im Web-Interface angezeigt. Zunächst wird der Benutzer des
    Web-Interfaces via Rückmeldung von `firmwarecfg` aber einfach nur
    gefragt, ob er trotzdem die Firmware installieren möchte. Nehmen wir
    an, er bejaht das.
-   Die wichtigsten Dateien des entpackten Firmware-Archivs liegen nun
    unter
    -   `/var/install`
    -   `/var/tmp/kernel.image`
    -   `/var/tmp/filesystem.image`
-   Die letzten beiden Dateien liegen nur vor, wenn es sich um ein
    "echtes" Update und nicht um ein Pseudo-Update, z.B. zum
    Aktivieren von Telnet oder zur Installation einer Software wie dem
    *LCR Updater* handelt. `filesystem.image` hat in vielen Fällen die
    Länge null, weil in `kernel.image` alle benötigten Daten fürs
    Flashen enthalten sind.
-   Ein zweites Mal wird `/bin/prepare_fwupgrade` aufgerufen, dieses Mal
    mit dem Parameter *end*. Jetzt werden endgültig die verbleibenden
    Dienste gestoppt, die noch während des Updates stören könnten, indem
    sie z.B. auf den Flash-Speicher zugreifen.
-   Jetzt wird das mit dem Firmware-Image entpackte Shell-Skript
    `/var/install` aufgerufen. Darin passiert eine ganze Menge, z.B.:
-   Es werden diverse Prüfungen durchgeführt, die bestimmen, auf welchem
    Stand die Box momentan ist, wie der Flash-Bereich partitioniert ist
    und was zu tun ist in Vorbereitung aufs Update. Je nachdem, was das
    Skript herausfindet über die Situation, gibt es am Ende einen der
    folgenden Werte zurück:
    -   *INSTALL_SUCCESS_NO_REBOOT (0)* - alles okay, Neustart der
        Box nicht erforderlich. Dieser Wert sollte nur zurückgegeben
        werden, wenn an Dateisystem und Kernel im Flash nichts geändert
        wird.
    -   *INSTALL_SUCCESS_REBOOT = 1* - der Standardwert bei
        "richtigen" Firmware-Updates. Alles okay, Box neu starten.
    -   *INSTALL_WRONG_HARDWARE = 2* - Installation zurückweisen, weil
        etwas an der Hardware nicht zum Firmware-Image paßt (Problem mit
        dem Annex, falscher OEM).
    -   *INSTALL_KERNEL_CHECKSUM = 3* - fehlerhafte Kernel-Checksumme.
        Falls die beiden Image-Dateien (Kernel und Filesystem)
        existieren, werden ihre CRC-Checksummen durch Aufruf des
        ebenfalls in AVM-Paketen enthaltenen `/var/chksum` geprüft. Sind
        die Checksummen - nicht Verwechseln mit der o.g. Signatur -
        nicht in Ordnung, findet kein Update statt.
    -   *INSTALL_FILESYSTEM_CHECKSUM = 4* - siehe voriger Punkt.
    -   *INSTALL_URLADER_CHECKSUM = 5* - würde bedeuten, dass der zu
        installierende neue Urlader eine falsche Checksumme hat.
        Meistens enthalten Firmware-Updates jedoch keinen neuen Urlader.
    -   *INSTALL_OTHER_ERROR = 6* - sonstiger Fehler.
    -   *INSTALL_FIRMWARE_VERSION = 7* - Problem mit der aktuellen
        Firmware-Version. Entweder kann die aktuelle Version aus
        irgendeinem Grund nicht festgestellt werden oder der
        Versionssprung ist zu groß, weil noch jemand eine Uralt-Version
        installiert hat und zunächst ein Zwischen-Update auf eine andere
        Version ebötigt, um anschließend die neue einspielen zu können.
    -   *INSTALL_DOWNGRADE_NEEDED = 8* - es wird versucht, eine
        Firmware mit niedrigerer Versionsnummer zu installieren.
        Normalerweise blockieren aktuelle Firmwares das, weswegen man
        den Umweg über ein Recover bzw. einen manuellen Downgrade machen
        muss, um diese Hürde zu nehmen. (Man könnte auch einfach die
        Prüfung in diesem Skript auskommentieren.)
-   Das Skript hat auch einen Schalter *-f*, welcher es dazu veranlaßt,
    eine beliebige Firmware-Versionsnummer zu akzeptieren und somit ggf.
    auch einen Downgrade durchzuführen. Allerdings lässt sich der
    Schalter übers Web-Interface meines Wissens nicht setzen. Vermutlich
    wird er von den AVM-Recovery-Tools benutzt. Verbunden mit dem Setzen
    dieses Schalters ist, dass das gerade besprochene Install-Skript
    auch die Einstellungen im Flash löscht und somit die Box auf die
    Werkseinstellungen zurücksetzt. Grundsätzlich könnte man Letzteres
    durch Auskommentieren im Skript verhindern, aber es macht oft genug
    Sinn, es so zu lassen. Ein Downgrade bedeutet nun einmal, dass evtl.
    vorhandene Einstellungen für Features einer neuen Firmware-Version
    von einer älteren nicht richtig interpretiert werden könnten und
    somit schlimmstenfalls die Box schon beim Starten hängen bleiben und
    endgültig zum Recover-Fall werden würde.
-   Zum Schluß werden ggf. noch einige Spezialitäten abgehandelt, z.B.
    Entfernen veralteter Einstellungen oder Konvertierung alter
    Wahlregeln.
-   Das Skript schreibt während des Ablaufs parallel auch noch ein
    weiteres Skript nach `/var/post_install`, welches anschließend über
    `init reboot` indirekt vom führenden Prozeß `firmwarecfg` aufgerufen
    wird, sofern nicht einer der Fehler-Rückgabewerte dies verhindert.
    `post_install` wiederum setzt für den Flash-Vorgang notwendige
    Umgebungsvariablen und lädt das im Firmware-Image enthaltene Modul
    `/var/flash_update.o` (Kernel 2.4) bzw. `/var/flash_update.ko`
    (Kernel 2.6).
-   Übrigens gibt es auch standardmäßig ein `/var/post_install`, das
    beim Systemstart aus `/var.tar` extrahiert wird und vor jedem Reboot
    aufgerufen wird. Der Aufruf-Mechanismus über `/etc/inittab` ist der
    gleiche, der Inhalt des Skripts jedoch völlig anders als in der
    Spezialversion vor dem Flashen.
-   Jetzt erfolgt der eigentliche Flash-Vorgang (falls notwendig).

Nach dem eventuellen Reboot hat man ggf. eine nagelneue Firmware auf der
Box, andernfalls die gewünschte nachinstallierte Funktionalität. Was
`/var/install` macht und welchen Return-Wert es liefert, ist
grundsätzlich für jeden Firmware-Bastler frei entscheidbar. Die anderen
Rahmenbedingungen sind so, wie ich es eben beschrieben habe.

[Alexander Kriegisch
(kriegaex)](http://www.ip-phone-forum.de/member.php?u=117253)


