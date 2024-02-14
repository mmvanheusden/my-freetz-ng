# Enable custom UDEV rules
Es können eigene Regeln die UDEV auswertet hinterlegt werden.<br>
<br>

Mit diesem Patch werden 2 zusätzliche frei verwendbare rules erstellt und nach /tmp/flash/mod/ verlinkt. Diese können mit dem Webinterface in einem Unterpunkt von "Freetz" bearbeitet werden.

 * first (00-custom.rules): wird vor allen Regeln von AVM ausgeführt
 * final (99-custom.rules): wird nach allen Regeln von AVM ausgeführt 

Damit können USB Geräte fest zugeordnet werden:

```
SUBSYSTEMS=="usb", KERNEL=="ttyUSB*", ATTRS{serial}=="7CF6976", SYMLINK+="reader1"
SUBSYSTEMS=="usb", KERNEL=="ttyUSB*", ATTRS{serial}=="FDF4F0D", SYMLINK+="reader2"
SUBSYSTEMS=="usb", KERNEL=="ttyUSB*", ATTRS{serial}=="40ABBFF", SYMLINK+="lcd1"
```

