#!/usr/bin/env tclsh

package require Tk
package require tablelist_tile
set dirname [file dirname [info script]]
source [file join $dirname tbltreedict.tcl]



#Example
proc createTree {} {
  set tbl .t
  grid [tablelist::tablelist $tbl -columns {0 "Key" 0 "Value"} -height 20 \
    -selectmode extended -yscrollcommand ".sby set"] -row 1 -column 0 -sticky nswe
  grid [ttk::scrollbar .sby -orient vertical -command "$tbl yview"] \
    -row 1 -column 1 -sticky ns
  grid rowconfigure . 1 -weight 1
  return $tbl
}



proc main {} {
  set data {}
  for {set i 0} {$i < 20} {incr i} {
    lappend data [list "Test $i" $i]
  }
  set tbl [createTree ]
  $tbl insertlist end $data
  tbl::init_moveKBind $tbl
  tbl::init_moveMBind $tbl

}
main
