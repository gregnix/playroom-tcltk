#!/usr/bin/env tclsh

package require Tk
package require tablelist_tile
package require fileutil
set dirname [file dirname [info script]]
source [file join $dirname tbltreedict.tcl]
source [file join $dirname tbltreemove.tcl]

# Create the Tablelist widget with tree configuration
proc createTbl {w} {
   set frt [ttk::frame $w.frt]
   set tbl [tablelist::tablelist $frt.tbl -columns {0 "Key" 0 "Value" 0 "Detail"} -height 20 -width 0 \
    -stretch all -treecolumn 0 -selectmode single]
   $tbl columnconfigure 0 -name key
   $tbl columnconfigure 1 -name value
   set vsb [scrollbar $frt.vsb -orient vertical -command [list $tbl yview]]
   set hsb [scrollbar $frt.hsb -orient horizontal -command [list $tbl xview]]
   $tbl configure -yscroll [list $vsb set] -xscroll [list $hsb set]

   tbl::init_moveMBind $tbl
   tbl::init_moveKBind $tbl
   pack $vsb -side right -fill y
   pack $hsb -side bottom -fill x
   pack $tbl -expand yes -fill both

   pack $frt -expand yes -fill both
   return $tbl
}



proc ls {path} {
   # catch permissions errors
   if {[catch {glob -nocomplain -tails -directory $path *} result]} {
      set result {}
   }
   return $result
}

# recursively builds a nested dict of all files/directories under $path
proc ls-R {path} {
   set result {}
   foreach item [ls $path] {
      if {[file isdirectory [file join $path $item]]} {
         dict set result $item [ls-R [file join $path $item] ]

      } else {
         #dict lappend result $item {}
      }
   }
   return $result
}

proc main {} {
   set data {a1 {b11 {a11 {b1111 c1 b1112 c1}} b12 {a12 {b1211 c1 b1212 c1}}} a2 {b21 {a21 {b2111 c1 b2112 c1}} b22 {a22 {b2211 c1 b2212 c1}}}}
   set data [ls-R ../../..]
   ttk::frame .fr
   pack .fr -side top -expand 1 -fill both

   set tbl [createTbl  .fr]
   tbl::dict2tbltree $tbl root $data
   tbl::init_moveKBind $tbl
   tbl::init_moveMBind $tbl
   #puts [tbl::tbltree2dict $tbl root]

}
main
set dir [pwd]

if {$dir eq ""} {
   foreach volume [file volumes] {
      dict set itemList root [list [file nativename $volume] -1 D $volume]
   }
} else {
   foreach entry [glob -nocomplain -types {d f} -directory $dir *] {
      if {[catch {file mtime $entry} modTime] != 0} {
         continue
      }

      if {[file isdirectory $entry]} {
         dict lappend itemList root [list [file tail $entry] -1 \
		    [clock format $modTime -format "%Y-%m-%d %H:%M"] $entry]
      } else {
         dict lappend itemList root [list [file tail $entry] [file size $entry] \
		    [clock format $modTime -format "%Y-%m-%d %H:%M"] ""]
      }
   }
}

puts [tbl::printDictAdjusted $itemList]

puts $itemList