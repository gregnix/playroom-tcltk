#! /usr/bin/env tclsh

#20240819

# treeview-lib-example.tcl

package require Tk
package require tablelist_tile
package require ctext
package require scrollutil_tile
package require tooltip


# procs with namespace tvlib:: and example datas
source tbl-lib.tcl
source db-lib.tcl


ttk::frame .fr

set cols {0 "Col1" right 0 "Col2" left 0 "Col3" center}
set tbl [ tbllib::newTable .fr $cols]

$tbl insertlist end  [tbllib::generateLargeList 10 3]
$tbl configure -width 40
pack .fr -expand 1 -fill both

createTableFromTablelist db11 $tbl "generate"