#! /usr/bin/env tclsh

#20240819

# tblib-example.tcl

package require Tk
package require tablelist_tile

tcl::tm::path add [file join [file dirname [info script]] lib tcltk tm] 
package require table::tbllib
package require table::tbltreedict
package require table::tbltreehelpers
package require table::tbltreemove
package require table::tbltestdata
##

namespace eval NewProg {
 ttk::frame .fr

 set cols {0 "Col1" right 0 "Col2" left 0 "Col3" center}
 set tbl [ tbllib::newTable .fr $cols]

 $tbl insertlist end  [tbllib::testdata::generateLargeList 10 3]
 $tbl configure -width 40
 pack .fr -expand 1 -fill both

 puts [$tbl getcolumn 1]
 puts [$tbl configure -columns]

}

$NewProg::tbl configure