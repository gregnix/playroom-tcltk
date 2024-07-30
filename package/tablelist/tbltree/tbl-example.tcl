#!/usr/bin/env tclsh

package require Tk
package require tablelist_tile
set dirname [file dirname [info script]]
#source [file join $dirname tbltreedict.tcl]

# Create the Tablelist widget with tree configuration
proc createTbl {w} {
   set frt [ttk::frame $w.frt]
   set tbl [tablelist::tablelist $frt.tbl -columns {0 "Key" 0 "Value" 0 "Detail"} -height 20 -width 0 \
    -stretch all ]
   $tbl columnconfigure 0 -name key
   $tbl columnconfigure 1 -name value
   set vsb [scrollbar $frt.vsb -orient vertical -command [list $tbl yview]]
   set hsb [scrollbar $frt.hsb -orient horizontal -command [list $tbl xview]]
   $tbl configure -yscroll [list $vsb set] -xscroll [list $hsb set]
    
   #tbl::init_moveMBind $tbl
   #tbl::init_moveKBind $tbl
   pack $vsb -side right -fill y
   pack $hsb -side bottom -fill x
   pack $tbl -expand yes -fill both

   pack $frt -expand yes -fill both
   return $tbl
}



proc main {} {
  set data {}
  for {set i 0} {$i < 20} {incr i} {
    lappend data [list "Test $i" $i]
  }
  # create two Tablelist and a text widget
ttk::frame .fr
pack .fr -side top -expand 1 -fill both
  
  set tbl [createTbl  .fr]
  $tbl insertlist end $data
#  tbl::init_moveKBind $tbl
#  tbl::init_moveMBind $tbl

}
main
