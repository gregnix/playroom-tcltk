#!/usr/bin/env tclsh

package require Tk
package require tablelist_tile
package require fileutil
set dirname [file dirname [info script]]
source [file join $dirname tbltreedict.tcl]
source [file join $dirname tbltreemove.tcl]


# not working properly, can't find my error
proc acceptChildCmd {tbl targetParentNodeIdx sourceRow} {
   # tbl targetParentNodeIdx sourceRow
   # Debugging output
   #puts "acceptChildCmd called with: $tbl, targetParentNodeIdx: $targetParentNodeIdx, sourceRow: $sourceRow"
   return 1  ;# For simplicity, allow all moves
}

proc acceptDropCmd {tbl targetRow sourceRow} {
   # tbl targetRow sourceRow
   # Check if the operation stays within the same parent node
   # return [expr {$sourceRow != $rowCount - 1 && $targetRow < $rowCount}]
   return 1
}

proc parents {tbl row} {

   while {$row != "root"} {
#   set value [$tbl rowcget $row -text]
   lappend pk $row
   set row [$tbl parentkey $row]
   }
 
for  {set i [expr {[llength $pk] -1}]} { $i > -1 } {incr i -1} {
   set value [$tbl rowcget [lindex $pk $i] -text]
   puts $value
   lappend res $value
}
set file  [file join {*}$res]
return $file  
}

proc cbtree {input W x y args} {
   
   set tbl [tablelist::getTablelistPath $W]
   set treecolumn [$tbl cget -treecolumn]
   switch $input {
      m {
         foreach {tbl x y} [tablelist::convEventFields $W $x $y] {}
         set row [$tbl containing  $y]
         set cell [$tbl cellcget $row,$treecolumn -text]
         puts "$tbl $row $cell :: [$tbl rowcget $row -text] ::  [parents $tbl $row]"
      }
   }
}
# Create the Tablelist widget with tree configuration
proc createTbl {w} {
   set frt [ttk::frame $w.frt]
   set tbl [tablelist::tablelist $frt.tbl -columns {0 "Key" } -height 20 -width 0 \
    -stretch all -treecolumn 0 \
     -movablerows true -acceptchildcommand "acceptChildCmd" -acceptdropcommand "acceptDropCmd" -selectmode single]
   $tbl columnconfigure 0 -name key
#   $tbl columnconfigure 1 -name value
   set vsb [scrollbar $frt.vsb -orient vertical -command [list $tbl yview]]
   set hsb [scrollbar $frt.hsb -orient horizontal -command [list $tbl xview]]
   $tbl configure -yscroll [list $vsb set] -xscroll [list $hsb set]

   bind [$tbl bodytag] <Double-1> [list cbtree m  %W %x %y ]
   
   tbl::init_moveMBind $tbl
   tbl::init_moveKBind $tbl
   pack $vsb -side right -fill y
   pack $hsb -side bottom -fill x
   pack $tbl -expand yes -fill both

   pack $frt -expand yes -fill both
   return $tbl
}

proc main {data} {
   
   ttk::frame .fr
   pack .fr -side top -expand 1 -fill both

   set tbl [createTbl  .fr]
   tbl::dict2tbltree $tbl root $data
   #    tbl::init_moveKBind $tbl
   #    tbl::init_moveMBind $tbl
   #puts [tbl::tbltree2dict $tbl root]

}
set dir [tk_chooseDirectory \
        -initialdir [file join [pwd] ../] -title "Choose a directory"]

dict set data  $dir [tbl::lsD-R $dir]
main $data

