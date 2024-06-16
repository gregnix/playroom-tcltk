#! /usr/bin/env tclsh

#20240616
#todo
# val: not a dict?
# val: lappend, exists
# error handling

#proc
#example
#output

proc is-dict {value} {
    return [expr {[string is list $value] && ([llength $value] % 2) == 0}]
}

proc addToTree {tree path value} {
    upvar 1 $tree dictTree
    set key [lindex $path 0]
    if {[llength $path] == 1} {
        dict set dictTree key $key val $value
    } else {
        set restPath [lrange $path 1 end]
        if {![dict exists $dictTree key $key]} {
            dict set dictTree key $key [dict create]
        } else {
            set subDict [dict get $dictTree key $key]
            if {![is-dict $subDict]} {
                set subDict [dict create]
                dict set dictTree key $key $subDict
            }
        }
        set subDict [dict get $dictTree key $key]
        addToTree subDict $restPath $value
        dict set dictTree key $key $subDict
    }
}

proc getFromTree {tree path} {
    upvar 1 $tree dictTree
    set key [lindex $path 0]
    if {[llength $path] == 1} {
        set node [dict get $dictTree key $key]
        if {[dict exists $node val]} {
            return [dict get $node val]
        } else {
            return {}
        }
    } else {
        set restPath [lrange $path 1 end]
        set subDict [dict get $dictTree key $key]
        return [getFromTree subDict $restPath]
    }
}

proc printTree {tree {indent ""}} {
    upvar 1 $tree dictTree
    dict for {key value} $dictTree {
        if {[is-dict $value]} {
            puts "$indent$key:"
            printTree value "$indent  "
        } else {
            puts "$indent$key: $value"
        }
    }
}

proc walkTree {tree path action} {
    upvar 1 $tree dictTree
    dict for {key value} $dictTree {
        set currentPath [concat $path $key]
        if {[is-dict $value]} {
            walkTree value $currentPath $action
        } else {
            uplevel 1 [list $action $currentPath $value]
        }
    }
}

proc printNode {path value} {
    puts "Path: $path, Value: $value"
}

proc deleteNode {tree path} {
    upvar 1 $tree dictTree
    set key [lindex $path 0]
    if {[llength $path] == 1} {
        dict unset dictTree key $key
    } else {
        set restPath [lrange $path 1 end]
        if {[dict exists $dictTree key $key]} {
            set subDict [dict get $dictTree key $key]
            deleteNode subDict $restPath
            dict set dictTree key $key $subDict
        }
    }
}

proc clearTree {tree} {
    upvar 1 $tree dictTree
    set dictTree [dict create]
}

proc replaceNode {tree path value} {
    upvar 1 $tree dictTree
    deleteNode dictTree $path
    addToTree dictTree $path $value
}

proc getChildren {tree path} {
    upvar 1 $tree dictTree
    set path [lmap ipath $path {list key $ipath}]
    set path [concat {*}$path]
    set subDict [dict get $dictTree {*}$path]
    return [dict keys [dict get $subDict key]]
}

proc getParent {tree path} {
    if {[llength $path] <= 1} {
        return ""
    }
    return [lrange $path 0 end-1]
}

proc getAllNodes {tree path} {
    upvar 1 $tree dictTree
    set result {}
    set keyPath [lmap ipath $path {list key $ipath}]
    set keyPath [concat {*}$keyPath]

    if {![dict exists $dictTree {*}$keyPath]} {
        return $result
    }

    set subDict [dict get $dictTree {*}$keyPath]
    if {[dict exists $subDict key]} {
        set keysubDict [dict get $subDict key]
    } else {
        return $result
    }
    dict for {key value} $keysubDict {
        lappend result [list $key]
        if {[is-dict $value]} {
            set subResult [getAllNodes subDict $key]
            foreach item $subResult {
                lappend result [concat $key $item]
            }
        }
    }
    return $result
}

proc getNodeValue {tree path} {
    upvar 1 $tree dictTree
    set key [lindex $path end]
    set parentPath [lrange $path 0 end-1]
    set parentPath [lmap ipath $parentPath {list key $ipath}]
    set parentPath [concat {*}$parentPath]
    set parentDict [dict get $dictTree {*}$parentPath]
    if {![dict exists $parentDict key $key]} {
        error "Key \"$key\" not found in dictionary"
    }
    set node [dict get $parentDict key $key]

    if {[dict exists $node val]} {
        return [dict get $node val]
    } else {
        return {}
    }
}

proc setNodeValue {tree path newValue} {
    upvar 1 $tree dictTree
    set key [lindex $path end]
    set parentPath [lrange $path 0 end-1]

    set parentPath [lmap ipath $parentPath {list key $ipath}]
    set parentPath [concat {*}$parentPath]

    set parentDict [dict get $dictTree {*}$parentPath]
    if {![dict exists $parentDict key $key]} {
        puts fehler
        error "Key \"$key\" not found in dictionary"
    }
    set node [dict get $parentDict key $key]
    dict set node val $newValue
    dict set parentDict key $key $node
    dict set dictTree {*}$parentPath $parentDict
}

proc moveNode {tree fromPath toPath} {
    upvar 1 $tree dictTree
    set value [getFromTree dictTree $fromPath]
    deleteNode dictTree $fromPath
    addToTree dictTree $toPath $value
}

proc size {tree} {
    upvar 1 $tree dictTree
    set count 0
    dict for {key value} $dictTree {
        incr count
        if {[is-dict $value]} {
            incr count [size value]
        }
    }
    return $count
}

proc depth {tree} {
    upvar 1 $tree dictTree
    set maxDepth 0
    dict for {key value} $dictTree {
        if {[is-dict $value]} {
            set subDepth [depth value]
            if {$subDepth > $maxDepth} {
                set maxDepth $subDepth
            }
        }
    }
    return [expr {$maxDepth + 1}]
}

# Example
if {[info script] eq $argv0} {

    # Initialisieren eines leeren Baumes
    set tree [dict create]

    # Hinzufügen von Daten zum Baum
    addToTree tree {a 001 012} "value012"
    addToTree tree {a 001 013} "value013"
    addToTree tree {a 002 011} "value011"
    addToTree tree {b 101 112} "value112"
    addToTree tree {b 103 111} "value111"
    setNodeValue tree {b 101} "Nodevalue 101 3 "
    setNodeValue tree {b 103} "Nodevalue 103 "
    setNodeValue tree {b 101 112} "Nodevalue 112"
    addToTree tree {b 002} "addto value"

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

    puts "Baumstruktur:"
    printTree tree
    addToTree tree {a 001} "value3a"
    addToTree tree {a 001} "value3aa id"
    puts "Baumstruktur after addToTree tree {a 002 011 023} \"value3a\":"
    printTree tree
    puts children
    puts [getChildren tree {a 001}]
    puts parents
    puts [getParent tree {a 001 012}]
    puts getfromtree
    puts [getFromTree tree {a 001 012}]
    puts [getFromTree tree {a 001}]
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
}

#Output
if {0} {
    /usr/bin/tclsh /home/greg/Project/2024/tcl/example/tcl/dict/tree/dict-tree-lib.tcl


    Tree struct:
    key:
    a:
    key:
    001:
    key:
    012:
    val: value012
    013:
    val: value013
    002:
    key:
    011:
    val: value011
    b:
    key:
    101:
    key:
    112:
    val:
    Nodevalue: 112
    val: Nodevalue 101 3
    103:
    key:
    111:
    val: value111
    val:
    Nodevalue: 103
    002:
    val:
    addto: value
    Wert an {a 001 012}: value012
    Wert an {a 001 013}: value013
    Neuer Wert an {a 001 012}: new_value1
    löschen eines Knoten 012

    Kindknoten von {a 001}:
    012 013
    013

    Baumstruktur nach dem Verschieben von {a 001 012} nach {b 102 012}:

    Größe des Baums:
    34

    Tiefe des Baums:
    8

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
    key {a {key {001 {key {013 {val value013} 012 {val value012nm}}} 002 {key {011 {val value011}}}}} b {key {101 {key {112 {val {Nodevalue 112}}} val {Nodevalue 101 3 }} 103 {key {111 {val value111}} val {Nodevalue 103 }} 002 {val {addto value}} 102 {key {012 {val value012n}}}}}}

    [dict keys [dict get $tree key a key]]
    001 002

    [dict get $tree key a key 001 key 013]
    val value013

    [dict get $tree key a key 001 key 012 val]
    value012nm

    [dict get $tree key a key 002]
    key {011 {val value011}}
    Baumstruktur:
    key:
    a:
    key:
    001:
    key:
    013:
    val: value013
    012:
    val: value012nm
    002:
    key:
    011:
    val: value011
    b:
    key:
    101:
    key:
    112:
    val:
    Nodevalue: 112
    val: Nodevalue 101 3
    103:
    key:
    111:
    val: value111
    val:
    Nodevalue: 103
    002:
    val:
    addto: value
    102:
    key:
    012:
    val: value012n
    Baumstruktur after addToTree tree {a 002 011 023} "value3a":
    key:
    a:
    key:
    001:
    key:
    013:
    val: value013
    012:
    val: value012nm
    val:
    value3aa: id
    002:
    key:
    011:
    val: value011
    b:
    key:
    101:
    key:
    112:
    val:
    Nodevalue: 112
    val: Nodevalue 101 3
    103:
    key:
    111:
    val: value111
    val:
    Nodevalue: 103
    002:
    val:
    addto: value
    102:
    key:
    012:
    val: value012n
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

    Press return to continue


}
