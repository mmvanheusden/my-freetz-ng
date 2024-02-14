# UI-Module und ctlmgr_ctl

Mit dem `ctlmgr_ctl` können interne Variablen von AVM angezeigt und bearbeitet werden die unter `/var/flash/` zumeist in Textdateien gespeichert sind.
Manche dieser Variablen sind nicht, nicht mehr oder nur mit einem anderen Branding im Webinterface zu sehen.
Dies ist keine öffentliche und dokumentierte Schnittstelle und verhält sich teilweise sehr eigenwillig.
Manche Werte sind nicht änderbar oder andere akzeptieren nur gewisse Wertebereiche.
Andere lösen ein Ereignis aus und kehren zu ihrem Wert zurück.
Es kann auch Werte geben die man besser nicht ändern sollte.
Vor dem Experimentieren sollte man unbedingt eine Konfigurationsicherung erstellen.


### Module

Die Module sind Kategorien wie zum Beispiel `wlan`, `env` oder `tr069` die oft einzlene Konfigurationsdateien repräsentieren.
<br>Um alle Module des Gerätes anzuzeigen:
```
$ ctlmgr_ctl u | sed '1,2d'

rights
uimodlogic
boxusers
...
avmcounter
rrd
move
```

### Keys
Die Keys sind die Variablen eines Modules. Diese beginnen mit `settings/` und manche alternativ mit `status/`.
<br>Um alle Keys eines Modules anzuzeigen:
```
$ ctlmgr_ctl u  tr064

tr064:settings/
enabled=0
username=dslf-config
password=***
only_https=0
check_sid=error
doupdate_require_auth=1
```

### Alle Variablen
Listet alle Module mit allen Keys und den gesetzten Werten auf.
Dieser Befehlt braucht gut 1 Minute und speichert die Ausgabe zusätzlich in `uimods.txt`.

```
for x in $(ctlmgr_ctl u | sed '1,2d'); do echo; ctlmgr_ctl u $x; done | tee uimods.txt
```


### Variable lesen

```
$ ctlmgr_ctl r  tr064 settings/username

dslf-config
```

oder 

```
$ ctlmgr_ctl r -v  tr064 settings/username

tr064:settings/username = dslf-config
```

### Variable schreiben

```
$ ctlmgr_ctl w  tr064 settings/username dslf-config

dslf-config
```

oder

```
$ ctlmgr_ctl w -v  tr064 settings/username dslf-config

tr064:settings/username = dslf-config
```

### Mehrere Variablen

Lesen:
```
$ ctlmgr_ctl r  tr064 settings/enabled  tr064 settings/username

0
dslf-config
```
oder
```
$ ctlmgr_ctl r -v  tr064 settings/enabled  tr064 settings/username

tr064:settings/enabled = 0
tr064:settings/username = dslf-config
```
Schreiben:
```
$ctlmgr_ctl w  tr064 settings/enabled 0  tr064 settings/username dslf-config

0
dslf-config
```
oder
```
$ ctlmgr_ctl w -v  tr064 settings/enabled 0  tr064 settings/username dslf-config

tr064:settings/enabled = 0
tr064:settings/username = dslf-config
```

### Listen

Anzahl Elemente einer Liste ausgeben:
```
$ ctlmgr_ctl r boxusers settings/user/count

2
```

Alle Elemente einer Liste anzeigen:
```
$ ctlmgr_ctl l boxusers settings/user/list

  user0
  user1
```

Ausgewählte Variablen aller Elemente lesen:
```
$ ctlmgr_ctl l boxusers "settings/user/list(UID,name,box_admin_rights)"

  user0   boxuser11       fritz   3
  user1   boxuser10       horst   0
```

Eine Variable eines Elementes lesen:
```
$ ctlmgr_ctl r boxusers settings/user0/UID

boxuser11
```

Nächstes freies Element anzeigen:
```
$ ctlmgr_ctl r boxusers settings/user/newid

user2
```

Ein neues Element anlegen:
```
$ ctlmgr_ctl w  boxusers settings/user2/enabled 0  boxusers settings/user2/name horst  boxusers settings/user2/box_admin_rights 3  boxusers settings/user2/password aciouasvdtn

0
horst
3
****
```

Ein Element löschen:
```
$ ctlmgr_ctl del  boxusers boxusers:command/user2


```

### Links
 - [Losing Freetz due to an automatic update](https://github.com/Freetz-NG/freetz-ng/discussions/871#discussioncomment-7372142)

