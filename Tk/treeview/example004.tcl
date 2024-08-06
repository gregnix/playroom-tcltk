#!/usr/bin/env tclsh
package require Tk
package require Ttk
package require dicttool
source treeview-lib.tcl
namespace import tvlib::*

proc checkFirstElementsEqual {listOfLists} {
  if {[llength $listOfLists] < "2"} {
    return 0
  }
  set firstElement ""
  foreach sublist $listOfLists {
    lassign $sublist first _
    if {$firstElement eq ""} {
      set firstElement $first
    } elseif {$firstElement ne $first} {
      return 0
    }
  }
  return 1
}

# Funktion zum Einfügen von Daten in das Treeview
proc insertDict {tree parent data} {
  foreach {key value} [dict get $data] {
    if {[catch {dict get $value}]} {
      $tree insert $parent end -text $key -values $value
    } else {
      set id [$tree insert $parent end -text $key -values ""]
      insertDict $tree $id $value
    }
  }
}
proc dict2tbltree {widget parent dict} {
  foreach {key value} $dict {
    if {[dict exists $dict $key]} {
      set keyValue [dict get $dict $key]
      if { [checkFirstElementsEqual $keyValue] } {
        $widget insert $parent end -text $key -values \{$keyValue\}
        continue
      } 
      if {[dict is_dict $keyValue] && [llength $keyValue] != "2"} {
        set newParent [$widget insert $parent end -text $key -values "D"]
        dict2tbltree $widget $newParent $keyValue
      } elseif {[llength $keyValue] == "2" && [dict is_dict [lindex $value 1]] } {
        set newParent [$widget insert $parent end -text $key -values "l"]
        dict2tbltree $widget $newParent $keyValue
      } else {
        $widget insert $parent end -text $key -values \{$keyValue\}

      }
    }
  }
}




# Daten-Setup
#dict set data Example1 {person {name "John Doe" age 30 address {street "123 Main St" city "Anytown"}} job {title "Developer" company "Works"}}
#dict set data Example2 {person {name "Jane Doe" age 25 address {street "456 Elm St" city "Othertown"}} job {title "Designer" company "Creates"}}

#dict set data Example5 {a1 {b11 {a11 {b1111 c1 b1112 c1}} b12 {a12 {b1211 c1 b1212 c1}}} a2 {b21 {a21 {b2111 c1 b2112 c1}} b22 {a22 {b2211 c1 b2212 c1}}}}

dict set data Example4 {person  {name "John Doe" age 30 address {street "123 Main St" city "Anytown"}  employees {  {name "Alice Smith" } {name "Bob Smith"} {name "John Good"} {name "Jane Good"}} } job {title "Developer" company "Works"}}

# Hauptfenster erstellen
set root [tk::toplevel .top]
wm title $root "Nested Dictionary in Treeview"

# Treeview erstellen
ttk::treeview .tree -columns {Value} -show {tree headings}
grid .tree -sticky news

# Spaltenüberschriften festlegen
#.tree heading Key -text "Key"
.tree heading Value -text "Value"
#.tree column Key -width 150
.tree column Value -width 250


# Daten aus dem Dict in das Treeview einfügen
#dict2tbltree .tree {} $data
insertDict .tree {} $data
tvlib::band .tree
tvlib::band_init .tree


# Fenster anpassen
grid columnconfigure . 0 -weight 1
grid rowconfigure . 0 -weight 1

# Haupt-Event-Loop starten
# (dies wird automatisch vom Tcl-Interpreter verwaltet)
