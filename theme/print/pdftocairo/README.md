poppler
+ https://poppler.freedesktop.org/
+ https://www.mankier.com/package/poppler-utils
+ https://manpages.ubuntu.com/manpages/trusty/man1/pdftocairo.1.html 
```
Poppler is a PDF rendering library based on the xpdf-3.0 code base.
```

 'source': Choose the paper source. 
 
 The value is one of: 'upper', 'onlyone', 'lower', 'middle', 'manual', 'envelope', 'envmanual', 'auto', 'tractor', 'smallfmt', 'largefmt', 'largecapacity', 'formsource' or an integer constant for printer specific sources.
+ "upper" (DMBIN_UPPER): Bezieht sich in der Regel auf die oberste Papierzuführung oder das oberste Papierfach eines Druckers. Wenn ein Drucker über mehrere Papierfächer verfügt, ist dies das am höchsten gelegene.
+ "lower" (DMBIN_LOWER): Bezeichnet die untere Papierzuführung oder das untere Papierfach. In einem System mit mehreren Papierfächern wäre dies das unterste Fach.
+ "middle" (DMBIN_MIDDLE): Für Drucker, die über drei oder mehr Papierfächer verfügen, bezieht sich dies auf das oder die in der Mitte befindlichen Fächer.
* "manual" (DMBIN_MANUAL): Manuelle Papierzuführung, oft verwendet für spezielle Medien oder Einzelblatteinzug.
* "envelope" (DMBIN_ENVELOPE): Spezielles Fach oder Zuführung für Umschläge.
* "envmanual" (DMBIN_ENVMANUAL): Manuelle Zuführung speziell für Umschläge.
+ "auto" (DMBIN_AUTO): Automatische Auswahl der Papierquelle durch den Drucker oder das Treibersystem.

* 'duplex': Set the duplex mode. One of: 'simplex', 'horizontal', 'vertical'.

```
pdftocairo output.pdf -print -printer "laserdrucker" -printopt "source"="upper"
pdftocairo output.pdf -print -printer "laserdrucker" -printopt "source"="lower"
pdftocairo output.pdf -print -printer "laserdrucker" -printopt "source"="middle"
pdftocairo output.pdf -print -printer "laserdrucker" -printopt "source"="manual
```


```
set pdfPrint [file join $libdir bin pdftocairo.exe]
exec $::pdfPrint $pdffile -q -noshrink -print -printer $printer
```
