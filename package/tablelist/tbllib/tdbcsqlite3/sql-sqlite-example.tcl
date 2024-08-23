#!/usr/bin/env tclsh

package require Tk
package require tablelist_tile
package require dicttool
set dirname [file dirname [info script]]
source [file join $dirname tbltreedict.tcl]
source [file join $dirname tbltreemove.tcl]

# Datei 1 und Datei 2 einbinden
package require Tk
package require dicttool
source report-lib.0.2.tcl
source sql-all-proc-0.2.tcl

namespace eval tbl {
  # Checks if the first elements of all sublists are equal
  proc checkFirstElementsEqual {listOfLists} {
    if {[llength $listOfLists] < "2"} {
      return 0
    }
    set firstElement ""
    foreach sublist $listOfLists {
      if {[string is list $sublist]} {
        lassign $sublist first _
      } else {
        set first $sublist
      }
      if {$firstElement eq ""} {
        set firstElement $first
      } elseif {$firstElement ne $first} {
        return 0
      }
    }
    return 1
  }
  # Converts a dictionary into a tree structure
  # Special case: if the key is ":", the value is treated as a list
  proc dict2tbltree {widget parent dict} {
    foreach {key value} [dict get $dict] {

      if {[dict exists $dict $key]} {
        set keyValue [dict get $dict $key]
        if { [checkFirstElementsEqual $keyValue] } {
          set stdList [list]
          set newList [list]
          foreach sublist $keyValue {
            if {[lindex $sublist 0] eq ":"} {
              lappend newList [lindex $sublist 1]
            } else {
              lappend stdList [lindex $sublist 1]
            }
          }
          if {$stdList ne {}} {
            set newList $stdList
          }
          #puts "k $key ::: newList: $newList ::: std: $stdList"

          #$widget insertchild $parent end [list $key  $newList]
          set nparent [$widget insertchild $parent end [list $key ]]
          foreach newItem $newList {
            $widget insertchild $nparent end  [list $newItem ]
          }
          continue
        }

        if {[dict is_dict $keyValue] && [llength $keyValue] != "2"} {
          puts "if P: $parent :: k: $key ::: v: $value"
          #set newParent [$widget insert $parent end -text $key -values ""]
          set newParent [$widget insertchild $parent end [list $key]]
          foreach newItem $value {
            set nparent [$widget insertchild $newParent end  [list $newItem ]]
            $widget insertchild $nparent end  [list $newItem ]

          }
          dict2tbltree $widget $newParent $value
        } elseif {[llength $keyValue] == "2" && [dict is_dict [lindex $value 1]] } {
          puts we
          #set newParent [$widget insert $parent end -text $key -values ""]
          set nparent [$widget insertchild $parent end [list $key $value]]
          dict2tbltree $widget $nparent $keyValue
        } else {
          puts er
          if {[lindex $keyValue 0] eq ":" } {
            puts "er if p: $parent k: $key keyValue: $keyValue"
            #$widget insert $parent end -text $key -values [list [lrange $keyValue 1 end]]
            $widget insertchild $parent end [list $key [list [lrange $keyValue 1 end]]]
          } elseif {[lindex $keyValue 1 0 0] eq ":" } {
            puts "elseif p: $parent k: $key keyValue: $keyValue"
            set nparent [$widget insert $parent end -text $key ]
            set newkeyValue [list]
            foreach val {*}[lrange $keyValue 1 end]  {
              lappend newkeyValue [lindex $val 1]
            }
            puts "ifno p: $parent k: $key keyValue: $keyValue"
            $widget insertchild $nparent end [list $key $value]
            #$widget insert $nparent end -text [lindex $keyValue 0 ] -values [list $newkeyValue]
          } else {
            if {[string match {\{: *} $value]} {
              puts ok
              $widget insert $parent end -text $key -values [string range $keyValue 2 end-1]
            } else {
              puts "else p: $parent ::: k: $key ::: keyValue: $keyValue"
              $widget insertchild $parent end [list $key $value]
              #$widget insertchild $parent end -text $key -values [list $keyValue]
            }
          }
        }
      } else {
        put frasge
      }
    }
  }

  # Recursively converts a tree structure into a dictionary
  # Uses custom interpretation with the same keys
  proc tvtree2dict {tree node} {
    set result {}
    # To handle equal keys
    set checkFEE 0
    set checkkey ""
    # Get the children of the current node
    set children [$tree children $node]
    foreach child $children {
      set key [$tree item $child -text]
      if {($checkFEE eq "1") && ($key ne $checkkey)} {
        puts "  ch if:  $checkkey k $key :: $checkFEE "
        set checkFEE 0
        set checkkey $key
        set result [expandList $result]
      }

      #set value [lindex [$tree item $child -values] 0]
      set value [concat {*}[$tree item $child -values]]
      # Check if the child itself has children
      if {[$tree children $child] > 0} {
        set childDict [tvtree2dict $tree $child]
        dict set result $key $childDict
        if {$value ne ""} {
          dict lappend result $key $value
        }
      } else {
        if {[dict exists $result $key]} {
          set tmplist [dict get $result $key]
          lappend tmplist $value
          dict set result $key $tmplist
          if {!$checkFEE} {
            set checkFEE 1
            set checkkey $key
          }
        } else {
          dict set result $key $value
        }
      }
    }
    if {($checkFEE eq "1")} {
      set checkFEE 0
      set checkkey $key
      set result [expandList $result]
    }
    return $result
  }

  proc dict2tbltree {widget parent dict} {
    puts "parent: $parent"
    if {[dict is_dict $dict]} {
      set keys [dict keys $dict]
      puts "keys: $keys"
      foreach key $keys {
        puts "key: $key"
        set childp [$widget insertchild $parent end $key]
        #        set node [$widget insertchild $childp end [list $key ]]
        dict2tbltree $widget $childp [dict get $dict $key]
      }
    } elseif {[string is list $dict] && ([llength $dict] eq 1) } {
      puts "elseif parent: $parent :::  $dict"
      $widget insertchild $parent end $dict
       
    } elseif {([llength $dict] % 2)} {
      puts " 2 elseif parent: $parent :::  $dict"
      set i 0
      foreach item $dict {
        incr i
        set child $parent

      foreach {k v} $item {
        puts "k: $k v: $v ::: $parent"
        if { $i eq -1 } {
          set newchild [$widget insertchild $child end [list $v  $v]]
          incr i
        } else {
        set newchild [$widget insertchild $child end [list $k $v]]
      }
        set child $newchild
      }
    }
      #dict2tbltree $widget $childp  $dict
    } else {
      puts "else parent: $parent :::  $dict"
    }
    
  }

}

# Create the Tablelist widget with tree configuration
proc createTbl {w} {
  set frt [ttk::frame $w.frt]
  set tbl [tablelist::tablelist $frt.tbl -columns {0 "Key" 0 "Value" 0 "Detail" 0 Weitere"} -height 20 -width 0 \
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



# GUI-Fenster aufbauen
proc buildGUI {dbconn w tbl} {

  set frt [ttk::frame $w.main]
  pack $frt -expand yes -fill both

  # Label für die Combobox
  ttk::label $frt.lbl -text "Enter SQL Command:"
  pack $frt.lbl -side top -padx 10 -pady 5

  # Combobox für SQL-Eingabe
  set cbsqlEntry [ttk::combobox $frt.sqlEntry -width 40 -state "readonly"]
  $cbsqlEntry configure -values {
    "SELECT * FROM users"
    "SELECT name FROM sqlite_master WHERE type='table'"
    "PRAGMA table_info(users)"
    "PRAGMA table_info(sqlite_master)"
    "PRAGMA table_list"
  }
  $frt.sqlEntry set "SELECT * FROM users"  ;# Standardwert setzen

  pack $frt.sqlEntry -side top -fill x -padx 10 -pady 5

  # Text Widget für die Ausgabe
  text $frt.output -height 15 -width 80
  pack $frt.output -side top -fill both -expand yes -padx 10 -pady 5

  # Ausführungsknopf
  ttk::button $frt.execute -text "Execute" -command [list executeSQL $dbconn $frt.sqlEntry $frt.output]
  ttk::button $frt.tableStructure -text "Tablestructur" -command [list displayTableStructure  $dbconn $frt.output $tbl]
  pack $frt.execute $frt.tableStructure -side left -padx 10 -pady 5 -expand 1 -fill both
}


#####################################
#main
# Datenbank initialisieren
initDatabase $dbconnS

ttk::frame .frtbl
pack .frtbl -side left -expand 1 -fill both

set tbl [createTbl  .frtbl]
$tbl configure -width 60
# Starten des GUI
ttk::frame .fr
buildGUI $dbconnS .fr $tbl
pack .fr -expand yes -fill both

# Hauptevent-Schleife
wm title . "SQL Command Interface"
wm geometry . "1200x400+10+12"

