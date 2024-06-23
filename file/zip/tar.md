tar

+ https://wiki.tcl-lang.org/page/tar
+ https://wiki.tcl-lang.org/page/Tcllib+tar
+ https://core.tcl-lang.org/tcllib/doc/trunk/embedded/md/tcllib/files/modules/tar/tar.md
+ https://wiki.tcl-lang.org/page/zlib
+ https://www.tcl-lang.org/man/tcl/TclCmd/zlib.htm

```
package require tar
package require fileutil

# init
set dirname [file dirname [info script]]
set sourcedir [file join $dirname source]
set targetdir [file join $dirname target]
set targettar [file join $dirname target.tar]

# relative path
set pwd [pwd]
lappend sdir  [lrange [file split $sourcedir] [llength [file split $pwd]] end] 

# tar create
set channel [open $targettar w]
fconfigure $channel -translation binary
::tar::create  $channel $sdir  -dereference -chan
close $channel

# tar contents
set channel [open $targettar r]
fconfigure $channel -translation binary
set files [::tar::contents  $channel  -chan]
close $channel

# tar contents
set channel [open $targettar r]
fconfigure $channel -translation binary
set file [list ]
#set file [list $dir]
set files [::tar::stat  $channel $file -chan]
close $channel

# tar untar
set channel [open $targettar r]
fconfigure $channel -translation binary
::tar::untar  $channel -dir $targetdir  -chan
close $channel

```
