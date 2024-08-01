#!/usr/bin/env tclsh

package require Tk
package require tablelist_tile
set dirname [file dirname [info script]]

# Create the Tablelist widget with tree configuration
proc createTbl {w} {
   set frt [ttk::frame $w.frt]
   set tbl [tablelist::tablelist $frt.tbl -columns {0 "Key" 0 "Value" 0 "Detail"} -height 20 -width 0 \
   -selectmode single \
    -stretch all -movablerows true -acceptchildcommand "acceptChildCmd" -acceptdropcommand "acceptDropCmd"]
   $tbl columnconfigure 0 -name key
   $tbl columnconfigure 1 -name value
   set vsb [scrollbar $frt.vsb -orient vertical -command [list $tbl yview]]
   set hsb [scrollbar $frt.hsb -orient horizontal -command [list $tbl xview]]
   $tbl configure -yscroll [list $vsb set] -xscroll [list $hsb set]

   pack $vsb -side right -fill y
   pack $hsb -side bottom -fill x
   pack $tbl -expand yes -fill both

   pack $frt -expand yes -fill both
   return $tbl
}

# Example functions to validate moving rows
proc acceptChildCmd {tbl targetParentNodeIdx sourceRow} {
   # Debugging output
   #puts "acceptChildCmd called with: $tbl, targetParentNodeIdx: $targetParentNodeIdx, sourceRow: $sourceRow"
   return 1  ;# For simplicity, allow all moves
}

proc acceptDropCmd {tbl targetRow sourceRow} {
   # Debugging output
   #puts "acceptDropCmd called with: $tbl, targetRow: $targetRow, sourceRow: $sourceRow"
   return 1  ;# For simplicity, allow all drops
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
   return $tbl
}
set tbl [main]

#Output:
if {0} {

}
