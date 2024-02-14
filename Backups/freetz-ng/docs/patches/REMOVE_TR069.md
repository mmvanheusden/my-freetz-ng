# Remove tr069
Entfernt tr069 (Remote-Konfiguration durch den Provider). Ohne tr069 ist keine Einrichtung mit 1und1-Startcode möglich.<br>
<br>

"TR69 ist […] ein Protokoll, das die Kommunikation zwischen einem Endgerät und einem Kontrollserver regelt." So beschreibt es ein Blogeintrag (siehe unten).
Verwendet wird dies bei der Fritzbox einerseits um komplexe Einstellungen bei der Einrichtung der Box zu automatisieren, andererseits damit der jeweilige Provider im Supportfall
auf die Konfiguration der Box beim Kunden zugreifen kann. Das geht von der Veränderung einzelner Einstellungen bis hin zum Firmware-Upgrade oder der Feststellung von Modifikationen.

Zu den Nachteilen des aktivierten TR-069 siehe insbesondere die zweite Seite des zweiten Artikels in unten stehender Link-Liste:
Offensichtlich ist TR-069 bei Fritzboxen ab Werk bereits aktiviert, so dass "Big Brother" seinen Schnüffel-Zugang bereits einsatzbereit vorfindet.
Wer einmal das Helferscript /bin/supportdata ansieht braucht sich nicht zu wundern warum Modifikationen sofort vom Provider im Supportfall entdeckt
werden, genauso wie Dienste dritter (z.B. VoIP).

Viele der im FAQ beschriebenen Gefahren beim Ersetzen der SSL libraries stehen auch in direktem Zusammenhang mit dem TR069 Dienst der scheinbar zur HTTPS gesicherten
Verbindung zum ACS Server die "originalen" AVM SSL libraries braucht. Bei früheren Firmware Versionen reichte hier das Deaktivieren von TR069, jedoch tauchen die Probleme
bei neueren Firmwares auch dann auf - vielleicht ein Indiz dafür das sich der Dienst garnicht mehr ganz deaktivieren lässt.

 * Konflikte zwischen Freetz Modifikationen und TR069 tauchen meist erst bei angeschlossenem DSL auf, wodurch sich das Problem leicht eingrenzen lässt. Läuft eine Box stabil bis DSL angeschlossen bzw synchronisiert wird dann hilft dieser Patch. Warnung unten beachten!.

Es ist also in vieler Hinsicht eventuell empfehlenswert, an dieser Stelle von der Möglichkeit der kompletten Entfernung von TR-069 Gebrauch zu machen.
Wer also die Hilfestellung per TR-069 nicht dauerhaft benötigt (oder garnicht wünscht), kann sich den "tr069 stuff" im Image ersparen - und den
freigewordenen Platz für andere Dinge nutzen.

Warnung: Entfernt man TR069 funktioniert weder automatische Einrichtung noch Startcode.
Manche Provider haben komplizierte Multi-PVC Einstellungen für Internet Telefonie die sich über das Webinterface in der Form oft nicht eingeben lassen.
Eine manuelle Eingabe funktioniert oft auch ist aber von der Providerseite leicht zu erkennen und wird oft in den AGBs als nicht unterstützt benannt (Bsp: 1und1).

Auch zieht der Support im Fehlerfall eventuell jegliche Kooperationbereitschaft zurück wenn nicht mit TR069 konfiguriert wurde oder werden kann - bis
hin zu angeblichem Garantieverlust des gelieferten Gerätes. Im gebrandeten Webinterface solcher Provider ist TR069 auch nicht abschaltbar.
Daher empfiehlt sich folgende Vorgehensweise:

 * Vor dem Modifizieren der Firmware einen Werksreset machen (ausser bei Neugeräten).
 * Falls das Gerät bereits modifiziert wurde Freetz Einstellungen sichern und eine Recovery durchführen (vorher auf original Branding einstellen!).
 * Eventuell vorhandenen USB-Speicher entfernen.
 * Die vom Provider empfohlene Einstellungsprozedur durchführen (Bsp: Startcode bei 1und1).
 * Nach erfolgreicher Einrichtung und funktionierender Telefonie vom DSL trennen.
 * Freetz Firmware mit entfernter TR069 Funktionalität aufspielen - ggf. NUR Freetz Einstellungen wiederherstellen.
 * DSL wieder anschliessen - Ruhe ist.
 * Im Service Fall die Prozedur wiederholen (Ab Recovery). 

Tip: Bevor man seine Box modifiziert sollte man sich eine Kopie des Environments machen um später vergleichen zu können.
Das Environment bleibt bei einer Recovery unverändert und enthält eventuell Spuren von Modifikationen.
Es gibt mehrere Methoden dies zu tun:

 * FTP auf ADAM2 und dort PRINTENV
 * Uber telnet/ssh in die Box (hinterlässt Spuren ⇒ Werksreset danach) und cat /proc/sys/urlader/environment 

### Weiterführende Links

 * [Infos zu TR-069](http://www.jodler.ch/bstocker/?p=335)
 * [TR-069: Router-Plug-and-Play mit Risiken](http://www.netzwelt.de/news/78076-tr-069-router-plug-and-play-mit-risiken.html)
 * [Heise: TR-069 im laufenden Betrieb](http://www.heise.de/netze/DSL-fernkonfiguriert--/artikel/99963/3)
 * [IPPF Thread: tr069 verstehen und nutzen](http://www.ip-phone-forum.de/showthread.php?t=146089)

