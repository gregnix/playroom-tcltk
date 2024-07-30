## bug in code
### ttf_font.tcl
+ proc ::tclfpdf::ttf_getCMAP4
```
set $offset [expr ($unichar - $startCount($n)) * 2 + $idRangeOffset($n)];
set $offset [ expr $idRangeOffset_start + 2 * $n + $offset]; 
```
```
set offset [expr ($unichar - $startCount($n)) * 2 + $idRangeOffset($n)];
set offset [ expr $idRangeOffset_start + 2 * $n + $offset]; 
```

### tclfpdf.1.6.tcl
+ proc ::tclfpdf::_readint

::env(PROCESSOR_ARCHITECTURE) is only available in Ms Windows
```
set arch $::env(PROCESSOR_ARCHITECTURE);
```

## Problems with example
+ ./example/dash.tcl

```
#false
Output "dash.tcl";
#rather
Output "dash.pdf";
```

## Problems under Linux

+ Directory for fonts is not one, but can be several. And then again divided into subdirectories.
+ Library directories are read-only. But here font descriptions, which can be generated dynamically, are saved in ../tclfpdf.1,6/font.
