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



ttk::frame .fr
pack .fr -side top -expand 1 -fill both

set table [tvlib::newTable .fr [list col1 col2]]
tvlib::bandInit $table
tvlib::band $table
tvlib::bandEvent $table
$table configure -height 50

$table heading col1 -text "Column 1" -command [list tvlib::sortColumn $table col1 0]
$table heading col2 -text "Column 2" -command [list tvlib::sortColumn $table col2 0]


# -- set values for all columns
tvlib::addRow $table [list 1]
tvlib::addRow $table [list 2]
# -- add an empty row
tvlib::addRow $table
tvlib::addRow $table [list "value one"]
tvlib::addRows $table [list [list 3] [list 4] [list 5]]
tvlib::addCells $table  1 w 1

tvlib::addCells $table  1 [list 1 2 3] 1
puts [tvlib::updateCell $table 1 m 8]
puts [tvlib::updateCell $table 1 x 9]
tvlib::updateCells $table 0 [list  1 2 3 4 5 6 7 8 9 10 11 12] 1


#set data3  [tvlib::generateLargeList 10 2]
#puts "delete AR: [time {tvlib::deleteAllRows $table} 1]"
#puts "addRows d: [time {tvlib::addRows $table $data3} 1]"

