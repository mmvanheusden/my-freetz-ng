# WLAN von LAN trennen mit iptables

Diese Anleitung erklärt, wie man den Zugriff vom WLAN der FRZITZBox
beschränken kann, um z. B. das WLAN für jeden zugänglich zu machen, ohne
das interne LAN oder die FRITZBox selbst zu gefährden.

### FRITZBox Einstellung

Zuerst muss im FRITZBox-Webinterface unter *System →
Netzwerkeinstellungen → IP-Adressen* die Option *"Alle Computer
befinden sich im selben IP-Netzwerk"* deaktiviert sein (siehe auch
[Screenshot](/screenshots/48 "Einstellungen für separate Netzwerke (Fritz!Box 7050)")).
Dabei werden nicht nur die Netze getrennt, es entsteht auch ein neues
Interface *wlan*.

### iptables

Jetzt können die Regeln für iptables gesetzt werden. Dies sind einfache
Befehle, die auf der Kommandozeile per *telnet* oder *ssh* ausgeführt
werden. Sollen sie dauerhaft bestehen bleiben, kann man sie z.B. einfach
in die `/var/flash/debug.cfg` schreiben.

### Netzwerk sichern

```
    iptables -A FORWARD -i wlan -o dsl -j ACCEPT
    iptables -A FORWARD -i wlan -j DROP
```

Damit wird das interne Netz geschützt, die Box selbst jedoch nicht.

```
    iptables -A INPUT -i wlan -p tcp -j DROP
    iptables -A INPUT -i wlan -p udp -j DROP
```

Jetzt ist auch der Zugriff per TCP/UDP auf die Box blockiert, sie
antwortet dennoch auf Pings.

### Zugriffe erlauben

Allerdings ist jetzt auch der DNS-Server nicht mehr erreichbar und die
Computer im WLAN können keine Domainnamen (z. B. *www.wikipedia.org*
anstatt 145.97.39.155) mehr aufrufen.

Die Regeln werden von iptables der Reihe nach abgearbeitet. Die Option
**-A** in den vorigen Befehlen steht für *append*, d. h. die Regeln
wurden am *Ende der Liste* eingefügt.

Mit **-I** (für *insert*) kann man nun Regeln an den *Beginn der Liste*
setzen, um Ausnahmen für bestimmte Dienste einzurichten, z. B. für den
DNS-Server via TCP und UDP.

```
    iptables -I INPUT -i wlan -p tcp --dport 53 -j ACCEPT
    iptables -I INPUT -i wlan -p udp --dport 53 -j ACCEPT
```

Danach können Computer im WLAN wie gewohnt die Internetverbindung
benutzen ohne Zugriff auf das Webinterface der Box oder Computer im LAN
zu haben.

Der Zugriff auf die Box lässt sich beliebig nach dem Schema

```
    iptables -I INPUT -i wlan -p <Protokoll> --dport <Port> -j ACCEPT
```

erweitern.

### Beispiele

```
    # ssh
    iptables -I INPUT -i wlan -p tcp --dport 22 -j ACCEPT
    # OpenVPN
    iptables -I INPUT -i wlan -p udp --dport 1194 -j ACCEPT
```


