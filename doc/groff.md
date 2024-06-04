groff

../src/tcktk/tcltk8.6.14/tcl8.6.14/doc/man.macros

man.maros copy to dir
```
groff -Thtml -man vfs.n > vfs.html 

groff -Tpdf -man vfs.n > vfs.pdf 

groff -Tps -man vfs.n > vfs.ps 
ps2pdf vfs.ps vfs.pdf
```
