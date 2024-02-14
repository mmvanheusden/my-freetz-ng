# Remove UPnP (igdd/upnpd)
Entfernt den UPnP-daemon. Achtung! Ohne UPnP-daemon ist keine Einrichtung von FritzFax möglich.<br>
<br>

uPnP steht für "universal Plug'n'Play". Hiermit lassen sich, sofern aktiviert und freigegeben, von Clients auf Verlangen Ports an der Box freischalten.
Dies ist einerseits sicher ganz praktisch, da man dies dann nicht mehr manuell in der Web-Oberfläche erledigen muss - birgt aber auch seine Risiken:
Auch ein Trojaner könnte auf diese Weise seine "Autobahn-nach-Hause" schalten - siehe dazu auch den Artikel ​Router hacken per uPnP.
Bei aktiviertem uPnP auf der Box gibt man quasi die Kontrolle zumindest ein gutes Stück ab.

Einige AVM Software benötigt diese Funktionalität (u.a. FritzFax) - andere Programme u.U. auch. Wer es hingegen nicht braucht, kann es hier entfernen.
Und wer sich dessen nicht ganz sicher ist, kann es ja zunächst in der Web-Oberfläche deaktivieren und schauen, ob irgend ein Programm
schreit - passiert dies bis zum nächsten Firmware-Update nicht, kann man den Kram dann rauswerfen ;)

### Was wird entfernt?

Mit dem Patch wird der uPnP Daemon (igdd) aus dem Image entfernt. Außerdem werden die Init-Skripte angepasst, damit sie nicht über dessen Fehlen stolpern.

### Was ist zu beachten?

Zum einen, wie schon oben erwähnt: Einige Software ist auf den uPnP Server hier angewiesen - diese funktioniert dann mit großer Wahrscheinlichkeit maximal noch eingeschränkt.

Desweiteren sollte man vor Einspielen eines Images mit entferntem uPnP Server sicherstellen, dass alle uPnP Features im aktuellen Image deaktiviert wurden.
Die entsprechenden Optionen finden sich unter "Einstellungen ⇒ System ⇒ Netzwerkeinstellungen ⇒ Statusinformationen über UPnP übertragen (empfohlen)".

### Weiterführende Links

 * [Wikipedia: uPnP](http://de.wikipedia.org/wiki/Universal_Plug_and_Play)
 * [DSL Re-Connect per uPnP](http://blog.jbbr.net/2008/01/03/fritzbox-schneller-reconnect-unter-linux/)
 * [Router hacken per uPnP](http://forum.ubuntuusers.de/topic/router-hacken-mit-hilfe-von-upnp/)

