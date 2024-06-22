#! /usr/bin/env tclsh

#20240621.0700
source [file join [file dirname [info script]] dict-tree-lib.tcl]

# for debug
   proc putd {command} {
        set cmd [dict get [info frame -1] cmd]
        set cmd [string range $cmd [string first \[ $cmd]+1 [string last \] $cmd]-1]
        puts "#cmd: ${cmd}"
        puts $command
        puts "\n"
    }

# Initialisieren eines leeren Baumes
set tree [dict create]

# Define the tree structure as a nested dictionary
insertNode tree {a} "value00"
insertNode tree {a 001 012} "value012"
insertNode tree {a 001 013} "value013"
insertNode tree {a 002 011} "value011"
insertNode tree {b 101 112} "value112"
insertNode tree {b 103 111} "value111"
insertNode tree {b 002} "addto value"
insertNode tree {a} "Nodevalue"
setNodeAttr tree {a} {pid 0 pppid -1}
setNodeAttr tree {a 001 012} {pid 12}

#tree2
# Define the tree structure as a nested dictionary
set tree2 [dict create]
insertNode tree2 {value} 10
insertNode tree2 {left value} 5
insertNode tree2 {left left value} 3
insertNode tree2 {left right value} 7
insertNode tree2 {right value} 15
insertNode tree2 {right left value} 12
insertNode tree2 {right right value} 18

# display tree
puts "Tree struct:"
printTree tree
puts "\n# walkTree tree {} cmdPrintNode:"
walkTree tree {} cmdPrintNode

puts "\n# walkTree tree {a} cmdPrintNode:"
walkTree tree {a} cmdPrintNode

puts "\n# walkTree tree {a} cmdListNode:"
puts [walkTree tree {a} cmdListNode]
# treetmp deleteNode
set treetmp $tree
puts "\n#treetmp struct:"
printTree treetmp
deleteNode treetmp {a}
puts "\n#treetmp struct after deleteNode {a} :"
printTree treetmp
deleteNode treetmp {}
puts "\n#treetmp struct after deleteNode {} :"
printTree treetmp
unset treetmp
puts \n


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

# deletNode
putd [getChildren tree {a 001}] 
putd [deleteNode tree {a 001 012}]
putd [getChildren tree {a 001}]

#
insertNode tree {a 001 012} "value012n"
setNodeAttr tree {a 001 012} {pid 12a}

puts "\nBaumstruktur vor dem Verschieben:"
printTree tree

# move a node  a -> b
putd [moveNode tree {a 001 012} {b 102 012}]
puts "\nBaumstruktur nach dem Verschieben von {a 001 012} nach {b 102 012}:"
printTree tree

# move a node  b -> a
putd [moveNode tree {b 102 012} {a 001 012}]
putd [isLeafNode tree {b 102}]
puts "\nBaumstruktur nach dem Verschieben von {b 102 012} nach {a 001 012}:"
printTree tree 
putd [isLeafNode tree {b 101}]
putd [isLeafNode tree {b 102}]
exit

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
insertNode tree {a 001} "value3a"
insertNode tree {a 001} "value3aa id"
puts "tree after insertNode tree :"
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



# Calculate and print the depth of the tree
puts "Depth of the tree: [depth tree2]"

#Output
if {0} {


}