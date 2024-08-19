#!/usr/bin/env tclsh

package require Tk

# 20240813
# treeview-table.tcl

# procs with namespace tvlib
source treeview-lib.tcl

# from https://wiki.tcl-lang.org/page/ttk::treeview
# g. use of ttk::treeview to build a table
# proc newTable
# creates a new treeview configured as a table
# add Row, Rows, Cell, Cells
# update Row, Rows, Cell, Cells
# upsert Row, Rows, Cell, Cells
# delete Row, Rows, Cell, Cells
# -- create a new table

# "pseudo play" the display with
#update
#after delay

set delay 1000
set delay2 2000

set table [tvlib::newTable . [list col1 col2]]
tvlib::bandInit $table
tvlib::band $table
tvlib::bandEvent $table
$table configure -height 50

# -- set values for all columns
tvlib::addRow $table [list 1]
tvlib::addRow $table [list 2]
# -- add an empty row
tvlib::addRow $table
tvlib::addRow $table [list "value one"]
tvlib::addRows $table [list [list 3] [list 4] [list 5]]
tvlib::addCells $table  1 w 1

update
after $delay
tvlib::addCells $table  1 [list 1 2 3] 1
puts [tvlib::updateCell $table 1 m 8]
puts [tvlib::updateCell $table 1 x 9]
tvlib::updateCells $table 0 [list  1 2 3 4 5 6 7 8 9 10 11 12] 1

update
after $delay
tvlib::upsertCells $table 1 [list  1 2 3 4 5 6 7 8 9 10 11 12] 1

update
after $delay
tvlib::upsertCell $table 0 k 15
tvlib::deleteRows $table [list 1 3]
puts [tvlib::updateRow $table [list "new value 1" "new value 2"] 2]
tvlib::upsertRow $table [list "upsert value 1" "upsert value 2"] 5
tvlib::upsertRows $table \
 [list  [list "upsert value 3" "upsert value 4"] [list "upsert value 5" "upsert value 6"] ] 5

update
after $delay
tvlib::updateRows $table \
 [list [list "update value 7" "update value 8"] [list "update value 9" "update value 10"] ] 5


update
after $delay
puts [tvlib::deleteRow $table 13]
puts [tvlib::deleteCell $table 1 8]

set res 1
while {$res} {
  update
  after $delay2
  set res [tvlib::deleteRow $table 0]
}

update
after $delay
tvlib::upsertCells $table 1 [list 0 1 2 3 4 5 6 7 8 9 10 11 12] 0

for {set i 0} { $i <= 12} {incr i} {
  update
  after $delay
  tvlib::upsertCell $table 0 $i $i

  update
  after $delay
  tvlib::deleteCell $table 1  $i
}


for {set i 0} { $i <= 12} {incr i} {
  update
  after $delay
  tvlib::updateCell $table 1 [expr {[tvlib::getCell $table 0  $i] *2}] $i
}

set datas2 [tvlib::getAllRows $table]

update
after $delay2
tvlib::deleteAllRows $table

after $delay2
tvlib::addRows $table $datas2

puts [tvlib::getAllCells $table 1]
puts [tvlib::getCells $table 1 [list 2 4 6] ]

#########################
# tests  with large lists
# use 1

if {0} {
  puts "delete: [time {tvlib::deleteAllRows $table} 1]"
  update
  puts "addRows f: [time {tvlib::addRows $table [tvlib::generateLargeList 1000000 2]} 1]"

  #

  set data3  [tvlib::generateLargeList 1000000 2]
  puts "delete AR: [time {tvlib::deleteAllRows $table} 1]"
  puts "addRows d: [time {tvlib::addRows $table $data3} 1]"

  puts "delete AR: [time {tvlib::deleteAllRows $table} 1]"
  puts "addRows d: [time {tvlib::addRows $table $data3} 1]"

  puts "delete AR: [time {tvlib::deleteAllRows $table} 1]"
  puts "addRows d: [time {tvlib::addRows $table $data3} 1]"

  puts "delete TV: [time {$table delete [$table children {}]} 1]"
  puts "addRows d: [time {tvlib::addRows $table $data3} 1]"

  destroy [winfo parent $table]
  update
  puts "Number two"
  set table [tvlib::newTable . [list col1 col2]]
  tvlib::bandInit $table
  tvlib::band $table
  tvlib::bandEvent $table
  $table configure -height 50

  update
  puts "addRows d: [time {tvlib::addRows $table $data3} 1]"

  puts "delete TV: [time {$table delete [$table children {}]} 1]"
  puts "addRows d: [time {tvlib::addRows $table $data3} 1]"

  puts "delete AR: [time {tvlib::deleteAllRows $table} 1]"
  puts "addRows d: [time {tvlib::addRows $table $data3} 1]"

  update
  puts "Number three"

  puts "delete Wi: [time {
destroy [winfo parent $table]
set table [tvlib::newTable . [list col1 col2]]
tvlib::bandInit $table
tvlib::band $table
tvlib::bandEvent $table
$table configure -height 50
} 1]"
  puts "addRows d: [time {tvlib::addRows $table $data3} 1]"

  puts "delete Wi: [time {
destroy [winfo parent $table]
set table [tvlib::newTable . [list col1 col2]]
tvlib::bandInit $table
tvlib::band $table
tvlib::bandEvent $table
$table configure -height 50
} 1]"
  puts "addRows d: [time {tvlib::addRows $table $data3} 1]"
}