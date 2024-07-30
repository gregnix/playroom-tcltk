#!/usr/bin/env tclsh

package require Tk
package require tablelist_tile
set dirname [file dirname [info script]]
source [file join $dirname tbltreedict.tcl]

# Example functions to validate moving rows


# funktioniert leider nicht, kann den Fehler nicht finden   
proc acceptChildCmd {tbl targetParentNodeIdx sourceRow} {
   # Debugging output
   #puts "acceptChildCmd called with: $tbl, targetParentNodeIdx: $targetParentNodeIdx, sourceRow: $sourceRow"
   return 1  ;# For simplicity, allow all moves
}

proc acceptDropCmd {tbl targetRow sourceRow} {
   # Beispiel: Prüfen, ob die Operation innerhalb desselben Elternknotens bleibt

    return [expr {$sourceRow != $rowCount - 1 && $targetRow < $rowCount}]
   return 1
}

# Create the Tablelist widget with tree configuration
proc createTbl {w} {
   set frt [ttk::frame $w.frt]
   set tbl [tablelist::tablelist $frt.tbl -columns {0 "Key" 0 "Value" 0 "Detail"} -height 20 -width 0 \
    -stretch all -movablerows true -acceptchildcommand "acceptChildCmd" -acceptdropcommand "acceptDropCmd" -treecolumn 0 -selectmode single]
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
set data {a1 {b11 {a11 {b1111 c1 b1112 c1}} b12 {a12 {b1211 c1 b1212 c1}}} a2 {b21 {a21 {b2111 c1 b2112 c1}} b22 {a22 {b2211 c1 b2212 c1}}}}
 
   ttk::frame .fr
   pack .fr -side top -expand 1 -fill both

   set tbl [createTbl  .fr]
   tbl::dict2tbltree $tbl root $data
   #tbl::init_moveKBind $tbl
   #tbl::init_moveMBind $tbl
   puts [tbl::tbltree2dict $tbl root]

}
main
