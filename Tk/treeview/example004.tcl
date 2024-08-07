#!/usr/bin/env tclsh
package require Tk
package require Ttk
package require dicttool
source treeview-lib.tcl


# Daten-Setup
#dict set data Example1 {person {name "John Doe" age 30 address {street "123 Main St" city "Anytown"}} job {title "Developer" company "Works"}}
#dict set data Example2 {person {name "Jane Doe" age 25 address {street "456 Elm St" city "Othertown"}} job {title "Designer" company "Creates"}}


#dict set data Example5 {a1 {b11 {a11 {b1111 c1 b1112 c1}} b12 {a12 {b1211 c1 b1212 c1}}} a2 {b21 {a21 {b2111 c1 b2112 c1}} b22 {a22 {b2211 c1 b2212 c1}}}}

dict set data Example4 {person  {name "John Doe" age 30.8 address {street "123 Main St" city "Anytown"}  employees {  {name "Alice Smith" } {name "Bob Smith"} {name "John Good"} {name "Jane Good"}} } job {title "Developer" company "Works"}}

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
tvlib::dict2tbltree .tree {} $data

#tvlib::insertDict .tree {} $data
tvlib::band .tree
tvlib::bandInit .tree


# Fenster anpassen
grid columnconfigure . 0 -weight 1
grid rowconfigure . 0 -weight 1

# Haupt-Event-Loop starten
# (dies wird automatisch vom Tcl-Interpreter verwaltet)

puts "size: [tvlib::treesize .tree]"
puts [.tree item {}]
puts [.tree children {}]
proc testit {tree {p {}}} {
  foreach c [$tree children $p] {
    puts "w: $p c: $c"
    puts "next: [$tree  next $c]"
    puts "prev: [$tree  prev $c]"
    puts "parent: [$tree  parent $c]"
    puts "idepth: [tvlib::itemdepth $tree $c]"
    puts "c: [$tree children $c]\n"
    testit $tree $c
  }
  return datadict
}
testit .tree

puts [tvlib::treedepth .tree {} 0]


puts [tvlib::collectKeys [tvlib::tv2dict .tree ]]
puts [tvlib::collectKeysPoint [tvlib::tv2dict .tree ]]

set keysList [tvlib::collectKeys $data]
puts "Gesammelte Schlüssel: $keysList"

set keysList [tvlib::collectKeysPoint $data]
puts "Gesammelte Schlüssel: $keysList"

puts "nur die tails: [tvlib::extractTails $keysList]"
