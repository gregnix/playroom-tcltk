#!/usr/bin/env tclsh

package require Tk

# 20240819
# treeview-table.tcl

# procs with namespace tvlib
source treeview-lib.tcl



ttk::frame .fr
pack .fr -side left -expand 1 -fill both

set table [tvlib::newTable .fr [list col1 col2]]
tvlib::bandInit $table
tvlib::band $table
tvlib::bandEvent $table
$table configure -height 20

$table heading col1 -text "Column 1" -command [list tvlib::sortColumn $table col1 0]
$table heading col2 -text "Column 2" -command [list tvlib::sortColumn $table col2 0]


tvlib::addCells $table 0 [list 0 1 2 3 4 5 6 7 8 9 10 11 12] 0
tvlib::upsertCells $table  1 [list 21 000 203 3751 5 4 1 7 2 9 456 32 38] 0
puts [tvlib::updateCell $table 1 m 8]
puts [tvlib::updateCell $table 1 M 5]
puts [tvlib::updateCell $table 1 x 9]



#####################################################################################
ttk::frame .fr2
pack .fr2 -side right -expand 1 -fill both
set tree [tvlib::newTree  .fr2 [list Keys Values Rowidx]]
tvlib::bandInit $tree
tvlib::band $tree
tvlib::bandEvent $tree

foreach txt {first second third} {
      set id [$tree insert {} end -text "$txt item" -open 1]
      $tree item $id -values [list $id]
      for {set i  1} {$i < 5} {incr i} {
            set child [$tree insert $id end -text "child $i"]
            $tree item $child -values [list $child]
            if {$i eq "2"} {
                  continue
            }
            for {set j 1} {$j < 3} {incr j } {
                  set grandchild [$tree insert $child end -text "grandchild $i"]
                  $tree item $grandchild -values [list $grandchild]
            }
      }
}
set r -1
foreach item  [tvlib::collectKeys [tvlib::tv2list $tree]] {
      $tree item $item -values [list [$tree item $item -values] [incr r]]
}
tvlib::bandEvent $tree


tvlib::expandAll $tree {}

$tree configure -height 20
$tree heading #0 -command [list tvlib::sortColumn $tree #0 0]
$tree heading Values -command [list tvlib::sortColumn $tree Values 0]
$tree heading Rowidx -command [list tvlib::sortColumn $tree Rowidx 0]

