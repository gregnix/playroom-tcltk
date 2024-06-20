#! /usr/bin/env tclsh

#20240620
source [file join [file dirname [info script]] dict-tree-lib.tcl]

# Initialisieren eines leeren Baumes
set tree [dict create]

# Hinzufügen von Daten zum Baum
addToTree tree {a} "value00"
addToTree tree {a 001 012} "value012"
addToTree tree {a 001 013} "value013"
addToTree tree {a 002 011} "value011"
addToTree tree {b 101 112} "value112"
addToTree tree {b 103 111} "value111"
setNodeValue tree {b 101} "Nodevalue 101 3"
setNodeValue tree {b 103} "Nodevalue 103 "
setNodeValue tree {b 101 112} "Nodevalue 112"
addToTree tree {b 002} "addto value"
addToTree tree {a} "Nodevalue"
setAttrValue tree {a} {pid 0 pppid -1}
setAttrValue tree {a 001 012} {pid 12}

# Baum durchlaufen und die Aktion auf jeden Knoten anwenden
puts "Tree struct:"
printTree tree

# Abrufen eines Wertes
set value [getNodeValue tree {a 001 012}]
puts "Wert an {a 001 012}: $value"

# Abrufen eines Wertes
set value [getNodeValue tree {a 001 013}]
puts "Wert an {a 001 013}: $value"

# Ändern eines Wertes
setNodeValue tree {a 001 012} "new_value1"
set newValue [getNodeValue tree {a 001 012}]
puts "Neuer Wert an {a 001 012}: $newValue"

# Löschen eines Knotens
puts "löschen eines Knoten 012"
puts "\nKindknoten von {a 001}:"
puts [getChildren tree {a 001}]
deleteNode tree {a 001 012}
puts [getChildren tree {a 001}]
addToTree tree {a 001 012} "value012n"
setAttrValue tree {a 001 012} {pid 12a}
# Verschieben eines Knotens
moveNode tree {a 001 012} {b 102 012}
addToTree tree {a 001 012} "value012nm"
puts "\nBaumstruktur nach dem Verschieben von {a 001 012} nach {b 102 012}:"

# Größe des Baums
puts "\nGröße des Baums:"
puts [size tree]

# Tiefe des Baums
puts "\nTiefe des Baums:"
puts [depth tree]

# Abrufen der Kindknoten eines Pfads
puts "\nKindknoten von {a 001}:"
puts [getChildren tree {a 001}]

# Abrufen der Kindknoten eines Pfads
puts "\nKindknoten von {a}:"
puts [getChildren tree {a}]

# Abrufen des Elternknotens eines Pfads
puts "\nElternknoten von {a 002 011 023}:"
puts [getParent tree {a 002 011 023}]

# Abrufen aller Knoten eines Pfads
puts "\nAlle Knoten von {a}:"
puts [getAllNodes tree {a}]
puts "\nAlle Knoten von {a 001}:"
puts [getAllNodes tree {a 001}]
puts "ende getAllNodes\n"

# proc für proc testen
puts "\ntree raw:"
puts $tree
puts ""
puts {[dict keys [dict get $tree key a key]]}
puts [dict keys [dict get $tree key a key]]
puts ""
puts {[dict get $tree key a key 001 key 013]}
puts [dict get $tree key a key 001 key 013]
puts ""
puts {[dict get $tree key a key 001 key 012 val]}
puts [dict get $tree key a key 001 key 012 val]
puts ""
puts {[dict get $tree key a key 002]}
puts [dict get $tree key a key 002]

puts "tree :"
printTree tree
addToTree tree {a 001} "value3a"
addToTree tree {a 001} "value3aa id"
puts "tree after addToTree tree :"
printTree tree
puts children
puts [getChildren tree {a 001}]
puts parents
puts [getParent tree {a 001 012}]
puts getfromtree
puts [getNodeFromTree tree {a 001 012}]
puts [getNodeFromTree tree {a 001}]
puts getnodetree
puts [getNodeValue  tree {a 002}]
setNodeValue tree {a 002} neu
puts [getNodeValue  tree {a 002}]
setNodeValue tree {a 002} neu2
puts [getNodeValue  tree {a 002}]
lappend neu [getNodeValue  tree {a 002}]
lappend neu neu3
setNodeValue tree {a 002} $neu
puts [getNodeValue  tree {a 002}]
puts [getNodeValue  tree {b 101}]
puts [getNodeValue  tree {b 103}]

puts "walkTree tree {} printNode"
walkTree tree {} cmdPrintNode

puts \n
set liste [walkTree tree {} cmdListNode]
foreach {k v}  $liste {
    puts "$k $v"
}

#tree2
# Define the tree structure as a nested dictionary
set tree2 [dict create]
addToTree tree2 {value} 10
addToTree tree2 {left value} 5
addToTree tree2 {left left value} 3
addToTree tree2 {left right value} 7
addToTree tree2 {right value} 15
addToTree tree2 {right left value} 12
addToTree tree2 {right right value} 18

# Calculate and print the depth of the tree
puts "Depth of the tree: [depth tree2]"

#Output
if {0} {
Tree struct:
a:
  Nodevalue
  pid 0 pppid -1
  001:
    012:
      value012
      pid 12
    013:
      value013
  002:
    011:
      value011
b:
  101:
    112:
      Nodevalue 112
    Nodevalue 101 3
  103:
    111:
      value111
    Nodevalue 103 
  002:
    addto value
Wert an {a 001 012}: value012
Wert an {a 001 013}: value013
Neuer Wert an {a 001 012}: new_value1
löschen eines Knoten 012

Kindknoten von {a 001}:
012 013
013

Baumstruktur nach dem Verschieben von {a 001 012} nach {b 102 012}:

Größe des Baums:
46

Tiefe des Baums:
3

Kindknoten von {a 001}:
013 012

Kindknoten von {a}:
001 002

Elternknoten von {a 002 011 023}:
a 002 011

Alle Knoten von {a}:
001 {001 013} {001 012} 002 {002 011}

Alle Knoten von {a 001}:
013 012
ende getAllNodes


tree raw:
key {a {val Nodevalue attr {pid 0 pppid -1} key {001 {key {013 {val value013 attr {}} 012 {val value012nm attr {}}}} 002 {key {011 {val value011 attr {}}}}}} b {key {101 {key {112 {val {Nodevalue 112} attr {}}} val {Nodevalue 101 3}} 103 {key {111 {val value111 attr {}}} val {Nodevalue 103 }} 002 {val {addto value} attr {}} 102 {key {012 {val value012n attr {pid 12a}}}}}}}

[dict keys [dict get $tree key a key]]
001 002

[dict get $tree key a key 001 key 013]
val value013 attr {}

[dict get $tree key a key 001 key 012 val]
value012nm

[dict get $tree key a key 002]
key {011 {val value011 attr {}}}
tree :
a:
  Nodevalue
  pid 0 pppid -1
  001:
    013:
      value013
    012:
      value012nm
  002:
    011:
      value011
b:
  101:
    112:
      Nodevalue 112
    Nodevalue 101 3
  103:
    111:
      value111
    Nodevalue 103 
  002:
    addto value
  102:
    012:
      value012n
      pid 12a
tree after addToTree tree :
a:
  Nodevalue
  pid 0 pppid -1
  001:
    013:
      value013
    012:
      value012nm
    value3aa id
  002:
    011:
      value011
b:
  101:
    112:
      Nodevalue 112
    Nodevalue 101 3
  103:
    111:
      value111
    Nodevalue 103 
  002:
    addto value
  102:
    012:
      value012n
      pid 12a
children
013 012
parents
a 001
getfromtree
value012nm
value3aa id
getnodetree

neu
neu2
neu2 neu3
Nodevalue 101 3
Nodevalue 103 
walkTree tree {} printNode
Path: a                              Value: Nodevalue            Attr: pid=0 pppid=-1 
Path: a 001 013                      Value: value013             Attr: 
Path: a 001 012                      Value: value012nm           Attr: 
Path: a 001                          Value: value3aa id          Attr: 
Path: a 002 011                      Value: value011             Attr: 
Path: b 101 112                      Value: Nodevalue 112        Attr: 
Path: b 103 111                      Value: value111             Attr: 
Path: b 002                          Value: addto value          Attr: 
Path: b 102 012                      Value: value012n            Attr: pid=12a 


a Nodevalue {pid 0 pppid -1} {a 001 013} value013 {}
{a 001 012} value012nm {} {a 001} {value3aa id} {}
{a 002 011} value011 {} {b 101 112} {Nodevalue 112} {}
{b 103 111} value111 {} {b 002} {addto value} {}
{b 102 012} value012n {pid 12a} 
Depth of the tree: 3

    
}