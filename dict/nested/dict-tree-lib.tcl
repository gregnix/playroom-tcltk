#! /usr/bin/env tclsh

#20240618
#todo

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

proc moveNode {tree fromPath toPath} {
    upvar 1 $tree dictTree
    set value [getFromTree dictTree $fromPath]
    deleteNode dictTree $fromPath
    addToTree dictTree $toPath $value
}

proc replaceNode {tree path value} {
    upvar 1 $tree dictTree
    deleteNode dictTree $path
    addToTree dictTree $path $value
}

proc clearTree {tree} {
    upvar 1 $tree dictTree
    set dictTree [dict create]
}

proc getChildren {tree path} {
    upvar 1 $tree dictTree
    set keyPath [lmap ipath $path {list key $ipath}]
    set keyPath [concat {*}$keyPath]
    set subDict [dict get $dictTree {*}$keyPath]
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

proc getNodeValue {tree path} {
    upvar 1 $tree dictTree
    set key [lindex $path end]
    set parentPath [lrange $path 0 end-1]
    set keyPath [lmap ipath $parentPath {list key $ipath}]
    set keyPath [concat {*}$keyPath]
    set parentDict [dict get $dictTree {*}$keyPath]
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

# node exists
proc setNodeValue {tree path newValue} {
    upvar 1 $tree dictTree
    set key [lindex $path end]
    set parentPath [lrange $path 0 end-1]

    set keyPath [lmap ipath $parentPath {list key $ipath}]
    set keyPath [concat {*}$keyPath]

    set parentDict [dict get $dictTree {*}$keyPath]
    if {![dict exists $parentDict key $key]} {
        error "Key \"$key\" not found in dictionary"
    }
    set node [dict get $parentDict key $key]
    dict set node val $newValue
    dict set parentDict key $key $node
    dict set dictTree {*}$keyPath $parentDict
}

proc printTree {tree {indent ""}} {
    upvar 1 $tree dictTree
    dict for {key value} $dictTree {
        if {$key eq "key"} {
            dict for {subkey subvalue} $value {
                if {[is-dict $subvalue]} {
                    puts "$indent$subkey:"
                    printTree subvalue "$indent  "
                } else {
                    puts "$indent$subkey: $subvalue"
                }
            }
        } elseif {$key eq "val"} {
            puts "$indent$value"
        }
    }
}

proc cmdPrintNode {path value} {
    puts "Path: [format %-30s $path] Value: $value"
}

proc cmdListNode {path value} {
    list $path $value
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
# not worked
proc sortTree {tree} {
    upvar 1 $tree dictTree
    puts "dictTree: \n$dictTree\n"
    set sortedTree [dict create]
    dict for {key value} $dictTree {
        if {$key eq "key"} {
            dict set sortedTree $key [dict create]
            set subDict [dict get $dictTree $key]
            set sortedSubDict [dict create]
            foreach subKey [lsort [dict keys $subDict]] {
                dict set sortedSubDict $subKey [dict get $subDict $subKey]
            }
            dict set sortedTree $key $sortedSubDict
        } elseif {$key eq "val"} {
            dict set sortedTree $key $value
        }
    }
    puts "sortedTree:\n$sortedTree\n"
    set dictTree $sortedTree
    dict for {key value} $dictTree {
        if {[is-dict $value]} {
            set subTree [dict get $dictTree $key]
            sortTree subTree
            dict set dictTree $key $subTree
        }
    }
    
}

proc walkTree {tree path action {recursiv 0} args} {
    upvar 1 $tree dictTree
    if {$recursiv} {
        set path {}
        set opath {*}$args
    } else {
        set opath $path
    }
    set result [list]
    set keyPath [lmap ipath $path {list key $ipath}]
    set keyPath [concat {*}$keyPath]
    set keysubDict [dict get $dictTree {*}$keyPath]
    set kpath {}
    dict for {key value} $keysubDict {
        if {$key eq "key"} {
            set kpath {}
            dict for {subkey subvalue} $value {
                lappend kpath {*}$subkey
                if {[llength $kpath] eq "1"} {
                    lappend opath {*}$kpath
                } else {
                    set opath [lreplace $opath end end [lindex $kpath end]]
                }
                set currentPath [concat $path $subkey]
                if {[is-dict $subvalue]} {
                    lappend result {*}[walkTree subvalue $currentPath $action 1 $opath]
                } else {
                    lappend result [$action $currentPath $subvalue]
                }
            }
        } elseif {$key eq "val"} {
            if {[llength $kpath]} {
                set opath [lrange $opath 0 end-1]
            }
            lappend result [$action $opath $value]
        }
    }
    return $result
}



###################################################################
# Example
if {[info script] eq $argv0} {

    # Initialisieren eines leeren Baumes
    set tree [dict create]

    # Hinzufügen von Daten zum Baum
    addToTree tree {a 001 012} "value012"
    addToTree tree {a 001 013} "value013"
    addToTree tree {a 002 011} "value011"
    addToTree tree {b 101} "valueb101"
    addToTree tree {b 101 112} "value112"
    addToTree tree {b 101 112 121} "value121"
    addToTree tree {b 002} "value002"
    addToTree tree {b 103 111} "value111"
    setNodeValue tree {b 103} "Nodevalue b103"
    setNodeValue tree {b 101 112} "Nodevalue 112"
    addToTree tree {a} "Nodevalue a"
    addToTree tree {b 103 114} "value114"

sortTree tree
puts "after sortTree:\ndictTree:\n$tree"

    #    puts " \nwalkTree tree {} printNode"
    #    walkTree tree {} printNode

    #    puts " \nwalkTree tree {} printNode"
    #    walkTreeT tree {} printNode


#    puts " \nwalkTree tree {} cmdPrintNode:"
 #   walkTree tree {} cmdPrintNode

  #  puts " \nwalkTree tree {b} cmdPrintNode:"
   # walkTree tree {b} cmdPrintNode

    #puts " \nwalkTree tree {b} cmdListNode:"
    #puts [walkTree tree {b} cmdListNode]

}

# walkTreeT funkt

#Output
if {0} {

  

 
 
walkTree tree {} cmdPrintNode:
Path: a 001 012                      Value: value012
Path: a 001 013                      Value: value013
Path: a 002 011                      Value: value011
Path: a                              Value: Nodevalue a
Path: b 101                          Value: valueb101
Path: b 101 112                      Value: Nodevalue 112
Path: b 101 112 121                  Value: value121
Path: b 002                          Value: value002
Path: b 103 111                      Value: value111
Path: b 103 114                      Value: value114
Path: b 103                          Value: Nodevalue b103
 
walkTree tree {b} cmdPrintNode:
Path: b 101                          Value: valueb101
Path: b 101 112                      Value: Nodevalue 112
Path: b 101 112 121                  Value: value121
Path: b 002                          Value: value002
Path: b 103 111                      Value: value111
Path: b 103 114                      Value: value114
Path: b 103                          Value: Nodevalue b103
 
walkTree tree {b} cmdListNode:
{{b 101} valueb101} {{b 101 112} {Nodevalue 112}} {{b 101 112 121} value121} {{b 002} value002} {{b 103 111} value111} {{b 103 114} value114} {{b 103} {Nodevalue b103}}



}
