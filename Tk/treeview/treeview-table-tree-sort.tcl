#!/usr/bin/env tclsh

package require Tk

# 20240819
# treeview-table-tree-sort.tcl

# procs with namespace tvlib
source treeview-lib.tcl


# example for -command
proc compare {a b} {
  set a0 [lindex $a 0]
  set b0 [lindex $b 0]
  if {$a0 < $b0} {
    return -1
  } elseif {$a0 > $b0} {
    return 1
  }
  return [string compare [lindex $a 1] [lindex $b 1]]
}

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
set tree2 [tvlib::newTree  .fr2 [list Keys Values Rowidx]]
tvlib::bandInit $tree2
tvlib::band $tree2
#tvlib::bandEvent $tree

foreach txt {first second third} {
  set id [$tree2 insert {} end -text "$txt item" -open 1]
  $tree2 item $id -values [list $id]
  for {set i  1} {$i < 5} {incr i} {
    set child [$tree2 insert $id end -text "child $i"]
    $tree2 item $child -values [list $child]
    if {$i eq "2"} {
      continue
    }
    for {set j 1} {$j < 3} {incr j } {
      set grandchild [$tree2 insert $child end -text "grandchild $i"]
      $tree2 item $grandchild -values [list $grandchild]
    }
  }
}
set r -1
foreach item  [tvlib::collectKeys [tvlib::tv2list $tree2]] {
  $tree2 item $item -values [list [$tree2 item $item -values] [incr r]]
}
tvlib::bandEvent $tree2

tvlib::expandAll $tree2 {}

$tree2 configure -height 20
$tree2 heading #0 -command [list tvlib::sortColumn $tree2 #0 0]
$tree2 heading Values -command [list tvlib::sortColumn $tree2 Values 0 "-command compare"]
$tree2 heading Rowidx -command [list tvlib::sortColumn $tree2 Rowidx 0 -integer]

