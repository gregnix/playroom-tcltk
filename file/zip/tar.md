tar

+ https://wiki.tcl-lang.org/page/tar
+ https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/modules/tar/tar.md
+ https://wiki.tcl-lang.org/page/zlib
+ https://www.tcl-lang.org/man/tcl/TclCmd/zlib.htm

```
package require tar

set dirname [file dirname [info script]]
set sourcedir [file join $dirname source]
set targetdir [file join $dirname target]

set ftgz [open [file join $targetdir tgzfile.tar.gz] wb]
zlib push gzip $ftgz -level 9
tar::create $ftgz $sourcedir -chan
close $ftgz
```
