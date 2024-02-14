# Eigene Programme kompilieren

Nachdem die Toolchain heruntergeladen oder gebaut wurde, kann sie
verwendet werden, um eigene Programme, oder solche, die noch nicht als
Paket zur Verfügung stehen, zu übersetzen.

Den MIPS-Compiler zum Pfad hinzufügen:

```
	export PATH=/pfad/zu/freetz/toolchain/target/bin:$PATH
```

Optionen für `./configure`:

```
	./configure --build=i386-linux-gnu --target=mipsel-linux --host=mipsel-linux
```

(i386-linux-gnu ist nicht unbedingt notwendig, nur beschwert sich
`configure`, wenn es nicht angegeben ist. Auf 64-Bit-Plattformen oder
Nicht-Intel-Architekturen muß es natürlich anders heißen.)

Statisches Linken der Binaries, damit sie keine separaten Libraries
benutzen, sondern sie gleich enthalten (funktioniert aber nicht bei
jeder Software):

```
	LDFLAGS=-static ./configure ...
```

Statisch gelinkte Binaries sind einfacher zu installieren, weil sie eben
alles enthalten - aber dadurch sind sie größer, und wenn sie mit anderen
Programmen gemeinsam genutzte Funktionalität haben, verschwenden sie
Speicherplatz. Außerdem müssen sie separat upgedatet werden, wenn z.B.
in einer Library eine Sicherheitslücke gepatcht wurde. Es ist also am
besten, statische Binaries nur zum Testen, oder wenn es anders nicht
geht, zu verwenden.

In manchen Fällen ist es ratsam die CC-Variable explizit zu setzen. Auch
die Angabe der *CFLAGS* kann nicht schaden:

```
	./configure ... CC="mipsel-linux-gcc" CFLAGS="-Os -pipe -march=4kc -Wa,--trap"
```


