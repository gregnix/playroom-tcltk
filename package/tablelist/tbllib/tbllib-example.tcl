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
 ttk::frame .fr1

 set data [tbllib::testdata::testDataTwo 100 100 2001-02-28T12:01:01 seconds]
 #set data [tbllib::testdata::generateReferenceList 10 8]

 set cols [tbllib::generateColumns $data]
 set tbl [ tbllib::newTable .fr1 $cols]

 $tbl insertlist end  $data

 $tbl configure -width 40
 pack .fr1 -expand 1 -fill both

 puts [$tbl getcolumn 1]
 puts [$tbl configure -columns]

}

$NewProg::tbl configure