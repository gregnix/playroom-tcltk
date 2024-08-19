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


proc formatFloat {value precision} {
    return [format "%.*f" $precision $value]
}


# Beispiel für das Einfügen von Daten mit ausgerichteten Dezimalstellen
set cols {{"Column1" e 50 1 100} {"Column2" e 50 1 100}}
set table [tvlib::newTable . $cols]

# Beispielwerte für die Spalten
set data {
    {"Item 1" 1.2345}
    {"Item 2" 12.345}
    {"Item 3" 123.45}
    {"Item 4" 1234.5}
    {"Item 5" 12345.0}
}
tvlib::addRows $table $data
# Einfügen der formatierten Daten in die Tabelle
#foreach row $data {
#    lassign $row item value
#    set formattedValue [formatFloat $value 4]  ; # Formatieren mit 4 Dezimalstellen
#    $tree insert {} end -values [list $item $formattedValue]
#}