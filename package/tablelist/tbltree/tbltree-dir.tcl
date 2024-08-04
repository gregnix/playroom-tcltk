#!/usr/bin/env tclsh

package require Tk
package require tablelist_tile
package require dicttool
package require fileutil
set dirname [file dirname [info script]]
source [file join $dirname tbltreedict.tcl]
source [file join $dirname tbltreemove.tcl]
source [file join $dirname tbltreehelpers.tcl]

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

proc path {tbl row} {
   if {$row eq "root"} {
      set pk k0
   }
   while {$row != "root"} {
      lappend pk $row
      set row [$tbl parentkey $row]
   }

   for  {set i [expr {[llength $pk] -1}]} { $i > -1 } {incr i -1} {
      set value [$tbl rowcget [lindex $pk $i] -text]
      lappend res $value
   }
   set file  [file join {*}$res]
   return $file
}

proc cbtree {input type W x y args} {
   set tbl [tablelist::getTablelistPath $W]
   if {$tbl eq "" } {
      set tbl $W
   }
   set treecolumn [$tbl cget -treecolumn]
   switch $input {
      m {
         foreach {tbl x y} [tablelist::convEventFields $W $x $y] {}
         set row [$tbl containing  $y]
         set cell [$tbl cellcget $row,$treecolumn -text]
         switch $type {
            info {
               puts "$tbl $row $cell :: [$tbl rowcget $row -text] :: [path $tbl $row]"
            }

         }

      }
      b {
         set row $y
         switch $type {
            parent {
               if {$row eq 0 } {
                  set r [$tbl rowcget $row -text]
                  set dir [file dirname $r]
                  $tbl delete 0 end
                  dict set data  $dir [tbl::lsD-R $dir]
                  tbl::dict2tbltree $tbl root $data
                  $tbl collapseall
                  $tbl expandall -partly
               } else {
                  set r [$tbl rowcget $row -text]
                  set dir [path $tbl [$tbl parentkey $row]]
                  $tbl delete  0 end
                  dict set data  $dir [tbl::lsD-R $dir]
                  tbl::dict2tbltree $tbl root $data
                  $tbl collapseall
                  $tbl expandall -partly

               }
            }
            toroot {
               set r [$tbl rowcget $row -text]
               set dir [path $tbl $row]
               $tbl delete 0 end
               dict set data  $dir [tbl::lsD-R $dir]
               tbl::dict2tbltree $tbl root $data
               $tbl collapseall
               $tbl expandall -partly
            }
         }
      }
   }
}

# button1 selection for popup only if popup already exists
proc cbtk_popupExists {W x y X Y} {
   if {[winfo exists .cbtk_popup]} {
      cbtk_popup  $W  $x $y $X $Y
   }
}

proc cbtk_popup {W x y X Y } {
   if {[winfo exists .cbtk_popup]} {
      set geometry [wm geometry .cbtk_popup]
      destroy .cbtk_popup
   }
   set tbl [tablelist::getTablelistPath $W]
   foreach {tbl x y} [tablelist::convEventFields $W $x $y] {}
   set row [$tbl containing  $y]
   # if outside the table
   if {$row == "-1" } {
      set row last
   }
   set key [$tbl cellcget $row,key -text]
   #set value [$tbl cellcget $row,value -text]
   set top [toplevel .cbtk_popup ]

   if {[info exists geometry]}  {
      wm geometry $top $geometry
   } else {
      wm geometry $top +$X+[expr {$Y+50}]
   }
   wm transient $top $tbl

   $tbl selection clear 0 end
   $tbl selection anchor $row
   $tbl selection set $row
   $tbl activate $row

   set krow [$tbl getfullkey $row]
   set pk [$tbl parentkey $row]
   set cix [$tbl childindex $row]
   set cc [$tbl childcount $row]
   set dc [$tbl  descendantcount $row]
   set nr [$tbl noderow $pk $cix]
   set depth [$tbl depth $row]

   ttk::label $top.labinfo1 -text "row: $row krow: $krow nr: $nr" -background white
   ttk::label $top.labinfo2 -text "pk: $pk cix: $cix cc: $cc dc: $dc d: $depth" -background white
   tk::button $top.btnparent -text "Open parent $row" -command [list cbtree b parent $W 0 $row]
   tk::button $top.btntoroot -text "row to root $row" -command [list cbtree b toroot $W 0 $row]
   ttk::entry $top.entkey
   $top.entkey insert 0 $key

   pack {*}[winfo children $top] -fill x -pady 2 -padx 2
}

proc  expandCmd {tbl row args} {
   set dir [path $tbl $row]
   dict set data  $dir [tbl::lsD-R $dir]
   set datac [dict get $data $dir]
   set cks [$tbl childkeys $row]
   if {[$tbl depth [lindex $cks 0]] eq "4" } {
      puts depth
      #$tbl delete $cks
      #tbl::dict2tbltree $tbl $row $datac
      after 100 [list cbtree b toroot $tbl 0  [$tbl parentkey $row]]
   }
   #after 100 [$tbl collapseall]
   #$tbl expandall -partly
   #puts [$tbl expandedkeys]
}
proc collapseCmd {args} {

}

# Create the Tablelist widget with tree configuration
proc createTbl {w} {
   set frt [ttk::frame $w.frt]
   set tbl [tablelist::tablelist $frt.tbl -columns {0 "Key" } -height 20 -width 0 \
    -stretch all -treecolumn 0 \
    -expandcommand expandCmd -collapsecommand collapseCmd \
    -movablerows true -acceptchildcommand "acceptChildCmd" -acceptdropcommand "acceptDropCmd" -selectmode single]
   $tbl columnconfigure 0 -name key
   #   $tbl columnconfigure 1 -name value
   set vsb [scrollbar $frt.vsb -orient vertical -command [list $tbl yview]]
   set hsb [scrollbar $frt.hsb -orient horizontal -command [list $tbl xview]]
   $tbl configure -yscroll [list $vsb set] -xscroll [list $hsb set]

   bind [$tbl bodytag] <Double-1> [list cbtree m info %W %x %y ]
   #bind [$tbl bodytag] <Button-3> [list cbtree m parent %W %x %y ]
   bind [$tbl bodytag] <<Button3>> +[list cbtk_popup %W  %x %y %X %Y ]
   bind [$tbl bodytag] <Button-1> +[list cbtk_popupExists  %W  %x %y %X %Y]

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
   $tbl collapseall
   return $tbl
}
set dir [tk_chooseDirectory \
        -initialdir [file join [pwd] ../../] -title "Choose a directory"]

dict set data  $dir [tbl::lsD-R $dir]
set tbl [main $data]

