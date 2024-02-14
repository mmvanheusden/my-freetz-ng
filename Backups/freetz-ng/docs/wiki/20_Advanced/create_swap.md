# Swap-File anlegen

### Was ist ein Swap-File, und wofür brauche ich es?

Das Wort *Swap* kommt aus dem Englischen und bedeutet so viel wie
"austauschen" oder "auslagern" - und genau um letzteres geht es
dabei: Wird der Arbeitsspeicher (RAM) knapp, wird es für die Programme
eng. Damit es trotzdem munter weitergehen kann, kann das System gerade
nicht benötigte Bereiche aus dem Arbeitsspeicher auslagern. Das sind
z.B. Programme, die vielleicht gerade gelangweilt im Hintergrund hängen
und nix zu tun haben. Wird der Speicher später wieder benötigt, holt das
System ihn zurück.

Wer's genauer wissen möchte, schaut z.B. in der
[Wikipedia](http://de.wikipedia.org/wiki/Swapping)
nach.

### Wie lege ich es an?

Jetzt kommt der interessantere Teil :) Im
Entwickler-Repository (`trunk`) gibt es dafür bereits im WebIF eine
einfache Möglichkeit. Wer lieber auf "Nummer sicher" geht, und daher
die Release (`freetz-1.0`) oder `stable` Branch verwendet, dem hilft ein
anderer Linux-PC weiter, auf dem man die benötigte Swap-Datei erstellt,
um sie dann auf die Box zu kopieren. Das sieht z.B. so aus:

```
	dd if=/dev/zero of=swapfile bs=1k count=64000
	mkswap swapfile
	scp swapfile root@fritz.box:/var/media/ftp/uStor01/
```

Dann im Freetz-WebIF unter *Einstellungen ⇒ Swap* noch den Pfad
eintragen, wo das System es finden kann (also
`/var/media/ftp/uStor01/swapfile`), und den Starttyp sinnvollerweise auf
"Automatisch" umstellen. Will man es sofort (ohne Reboot) aktivieren,
geht man im gleichen WebIF noch ins *Dienste* Menü, und startet den
Swap-Dienst manuell - er findet sich gleich im ersten Block bei den
*Basis-Paketen*.


