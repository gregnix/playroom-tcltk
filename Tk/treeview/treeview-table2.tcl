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

set delay 100
set delay2 100

set table [tvlib::newTable . [list col1 col2]]
tvlib::bandInit $table
tvlib::band $table
tvlib::bandEvent $table

tvlib::generateLargeDataset $table 10000 6


