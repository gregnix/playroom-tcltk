# tm libs
set dirname [file h
tcl::tm::path add [file join [file dirname [info script]] lib tm]

set addtmlib ~/lib/tcltk/tm
tcl::tm::path add $addtmlib
package require database::sqlstdproc
package require report::reportlib
package require table::tbllib
package require table::tbltreedict
package require table::tbltreehelpers
package require table::tbltreemove
package require tbl::