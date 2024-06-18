#! /usr/bin/env tclsh

#20240618
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

#Output
if {0} {


}
