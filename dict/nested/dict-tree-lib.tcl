#! /usr/bin/env tclsh

#20240621.0700
#todo
# Sort
#  Traversierungsmethode
#  error handling
#  exists
# #
#proc
#example
#output

proc is-dict {value} {
    return [expr {[string is list $value] && ([llength $value] % 2) == 0}]
}

proc addToTree {utree path value {attr {}}} {
    upvar 1 $utree tree
    set key [lindex $path 0]
    if {[llength $path] == 1} {
        dict set tree key $key val $value
        dict set tree key $key attr $attr
    } else {
        set restPath [lrange $path 1 end]
        if {![dict exists $tree key $key]} {
            dict set tree key $key [dict create]
        } else {
            set subDict [dict get $tree key $key]
            if {![is-dict $subDict]} {
                set subDict [dict create]
                dict set tree key $key $subDict
            }
        }
        set subDict [dict get $tree key $key]
        addToTree subDict $restPath $value $attr
        dict set tree key $key $subDict
    }
}

proc deleteNode {utree path} {
    upvar 1 $utree tree
    set key [lindex $path 0]
    if {[llength $path] == 0} {
        set tree [dict create]
    } elseif {[llength $path] == 1} {
        dict unset tree key $key
    } else {
        set restPath [lrange $path 1 end]
        if {[dict exists $tree key $key]} {
            set subDict [dict get $tree key $key]
            deleteNode subDict $restPath
            dict set tree key $key $subDict
        }
    }
return
}

proc moveNode {utree fromPath toPath} {
    upvar 1 $utree tree
    set value [getNodeFromTree tree $fromPath]
    set attrib [getAttrFromTree tree $fromPath]
    deleteNode tree $fromPath
    addToTree tree $toPath $value $attrib
return
}

proc replaceNode {utree path value attrib} {
    upvar 1 $utree tree
    deleteNode tree $path
    addToTree tree $path $value $attrib
}

proc clearTree {utree} {
    upvar 1 $utree tree
    set tree [dict create]
}

proc getChildren {utree path} {
    upvar 1 $utree tree
    set keyPath [lmap ipath $path {list key $ipath}]
    set keyPath [concat {*}$keyPath]
    set subDict [dict get $tree {*}$keyPath]
    set result {}
    foreach child [dict keys [dict get $subDict key]] {
        lappend result [concat $path $child]
    }
    return $result
}

# tree not use
proc getParent {tree path} {
    if {[llength $path] <= 1} {
        return ""
    }
    return [lrange $path 0 end-1]
}

proc getAllNodes {utree path} {
    upvar 1 $utree tree
    set result {}
    set keyPath [lmap ipath $path {list key $ipath}]
    set keyPath [concat {*}$keyPath]

    if {![dict exists $tree {*}$keyPath]} {
        return $result
    }

    set subDict [dict get $tree {*}$keyPath]
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

proc getNodeFromTree {utree path} {
    upvar 1 $utree tree
    set key [lindex $path 0]
    if {[llength $path] == 1} {
        set node [dict get $tree key $key]
        if {[dict exists $node val]} {
            return [dict get $node val]
        } else {
            return {}
        }
    } else {
        set restPath [lrange $path 1 end]
        set subDict [dict get $tree key $key]
        return [getNodeFromTree subDict $restPath]
    }
}

proc getNodeValue {utree path} {
    upvar 1 $utree tree
    set key [lindex $path end]
    set parentPath [lrange $path 0 end-1]
    set keyPath [lmap ipath $parentPath {list key $ipath}]
    set keyPath [concat {*}$keyPath]
    set parentDict [dict get $tree {*}$keyPath]
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

# node exists, then?
proc setNodeValue {utree path newValue} {
    upvar 1 $utree tree
    set key [lindex $path end]
    set parentPath [lrange $path 0 end-1]

    if {[llength $parentPath] == 0} {
        # Handle root element
        set parentDict $tree
    } else {
        set keyPath [lmap ipath $parentPath {list key $ipath}]
        set keyPath [concat {*}$keyPath]
        set parentDict [dict get $tree {*}$keyPath]
        if {![dict exists $parentDict key $key]} {
            error "Key \"$key\" not found in dictionary"
        }
    }

    set node [dict get $parentDict key $key]
    dict set node val $newValue
    dict set parentDict key $key $node

    if {[llength $parentPath] == 0} {
        # Handle root element
        set tee $parentDict
    } else {
        dict set tree {*}$keyPath $parentDict
    }
}

## attrib
proc getAttrFromTree {utree path} {
    upvar 1 $utree tree
    set key [lindex $path 0]
    if {[llength $path] == 1} {
        set node [dict get $tree key $key]
        if {[dict exists $node attr]} {
            return [dict get $node attr]
        } else {
            return {}
        }
    } else {
        set restPath [lrange $path 1 end]
        set subDict [dict get $tree key $key]
        return [getAttrFromTree subDict $restPath]
    }
}

proc getAttrValue {utree path args} {
    upvar 1 $utree tree
    set key [lindex $path end]
    set parentPath [lrange $path 0 end-1]
    set keyPath [lmap ipath $parentPath {list key $ipath}]
    set keyPath [concat {*}$keyPath]
    set parentDict [dict get $tree {*}$keyPath]
    if {![dict exists $parentDict key $key]} {
        error "Key \"$key\" not found in dictionary"
    }
    set node [dict get $parentDict key $key]

    if {[dict exists $node attr]} {
        if {[llength $args] ne 0 } {
            return [dict get $node attr $args]
        } else {
            return [dict get $node attr]
        }


    } else {
        return {}
    }
}

#
proc setAttrValue {utree path newAttribut} {
    upvar 1 $utree tree
    set key [lindex $path end]
    set parentPath [lrange $path 0 end-1]

    if {[llength $parentPath] == 0} {
        # Handle root element
        set parentDict $tree
    } else {
        set keyPath [lmap ipath $parentPath {list key $ipath}]
        set keyPath [concat {*}$keyPath]
        set parentDict [dict get $tree {*}$keyPath]
        if {![dict exists $parentDict key $key]} {
            error "Key \"$key\" not found in dictionary"
        }
    }
    set node [dict get $parentDict key $key]
    dict set node attr $newAttribut
    dict set parentDict key $key $node

    if {[llength $parentPath] == 0} {
        # Handle root element
        set tree $parentDict
    } else {
        dict set tree {*}$keyPath $parentDict
    }
    return
}

proc printTree {utree {indent ""}} {
    upvar 1 $utree tree
    dict for {key value} $tree {
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
        } elseif  {$key eq "attr"} {
            if {[llength $value] ne 0} {
                puts "$indent$value"
            }
        }
    }
}

#cmds for walkTree action
proc cmdPrintNode {path value {attr {}}} {
    set formattedAttr ""
    foreach {key val} $attr {
        append formattedAttr "$key=$val "
    }
    puts "Path: [format %-30s $path] Value: [format %-20s $value] Attr: $formattedAttr"
}

proc cmdListNode {path value {attr {}}} {
    list $path $value $attr
}

proc cmdListAttr {path value {attr {}}} {
    list $path  $attr
}

# info procs
proc size {utree} {
    upvar 1 $utree tree
    set count 0
    dict for {key value} $tree {
        incr count
        if {[is-dict $value]} {
            incr count [size value]
        }
    }
    return $count
}

proc depth {utree} {
    upvar 1 $utree tree
    if {[dict exists $tree val]} {
        return 0
    }
    set maxDepth 0
    if {[dict exists $tree key]} {
        dict for {key value} [dict get $tree key] {
            if {[is-dict $value]} {
                set subDepth [depth value]
                if {$subDepth > $maxDepth} {
                    set maxDepth $subDepth
                }
            }
        }
    }
    return [expr {$maxDepth + 1}]
}



# walktree, action < cmds
proc walkTree {utree path action {recursiv 0} args} {
    upvar 1 $utree tree
    if {$recursiv} {
        set path {}
        set opath {*}$args
    } else {
        set opath $path
    }
    set result [list]
    set keyPath [lmap ipath $path {list key $ipath}]
    set keyPath [concat {*}$keyPath]
    set keysubDict [dict get $tree {*}$keyPath]
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
                    lappend result [$action $currentPath $subvalue [dict get $keysubDict attr]]
                }
            }
        } elseif {$key eq "val"} {
            if {[llength $kpath]} {
                set opath [lrange $opath 0 end-1]
            }
            set values $value
        } elseif {$key eq "attr"} {
            lappend result [$action $opath $values $value]
        }
    }
    return $result
}

proc existsNode {utree path} {
    upvar 1 $utree tree
    set key [lindex $path end]
    set parentPath [lrange $path 0 end-1]
    set keyPath [lmap ipath $parentPath {list key $ipath}]
    set keyPath [concat {*}$keyPath]

    if {[dict exists $tree {*}$keyPath key $key]} {
        return 1
    } else {
        return 0
    }
}

proc isLeafNode {utree path} {
    upvar 1 $utree tree
    set key [lindex $path end]
    set parentPath [lrange $path 0 end-1]
    set keyPath [lmap ipath $parentPath {list key $ipath}]
    set keyPath [concat {*}$keyPath]

    if {[dict exists $tree {*}$keyPath key $key]} {
        set node [dict get $tree {*}$keyPath key $key]
        if {[dict exists $node key]} {
            return 0
        } else {
            return 1
        }
    } else {
        return 0
    }
}

proc getSubTree {utree path} {
    upvar 1 $utree tree
    set keyPath [lmap ipath $path {list key $ipath}]
    set keyPath [concat {*}$keyPath]

    if {[dict exists $tree {*}$keyPath]} {
        return [dict get $tree {*}$keyPath]
    } else {
        error "Path \"$path\" not found in tree"
    }
}

proc getSiblings {utree path} {
    upvar 1 $utree tree
    set parentPath [getParent tree $path]
    if {$parentPath eq ""} {
        return {}
    }
    set children [getChildren tree $parentPath]
    set result {}
    foreach child $children {
        if {$child ne $path } {
            lappend result $child
        }
    }
    return $result
}

proc isDescendant {tree ancestorPath descendantPath} {
    if {[llength $descendantPath] <= [llength $ancestorPath]} {
        return 0
    }
    set ancestorLength [llength $ancestorPath]
    return [string equal [join $ancestorPath " "] [join [lrange $descendantPath 0 [expr {$ancestorLength - 1}]] " "]]
}


###################################################################
# Example
if {[info script] eq $argv0} {

proc putd {command} {
    set cmd [dict get [info frame -1] cmd]
    set cmd [string range $cmd [string first $cmd \[] end-1]
    puts "#cmd: ${cmd}"
    puts $command
    puts "\n"
}

    proc putdr {command} {
        set frameInfo [info frame -1]
        set cmd [dict get $frameInfo cmd]
        set regex {putd\s*\[\s*(.*?)\s*\]}
        if {[regexp $regex $cmd all match]} {
            puts "# $match:"
            puts $command
        } else {
            puts "Fehler: Ungültiger Befehl."
        }
    }

    # Initialisieren eines leeren Baumes
    set tree [dict create]

    # Hinzufügen von Daten zum Baum
    addToTree tree {a} "value00"
    addToTree tree {a 001 012} "value012"
    addToTree tree {a 001 013} "value013"
    addToTree tree {a 002 011} "value011"
    addToTree tree {b 101} "valueb101" "pid 0"
    addToTree tree {b 101 112} "value112"
    addToTree tree {b 101 112 121} "value121"
    addToTree tree {b 002} "value002"
    addToTree tree {b 103 111} "value111"
    setNodeValue tree {b 103} "Nodevalue b103"
    setNodeValue tree {b 101 112} "Nodevalue 112"
    addToTree tree {a} "Nodevalue a"
    addToTree tree {b 103 114} "value114"
    setAttrValue tree {a} {pid 0 pppid -1}
    setNodeValue tree {a 001} {test1}
    setNodeValue tree {a} {testxy}

    puts "\n# printTree:"
    printTree tree

    puts "\n# puts \$tree:"
    puts $tree

    puts "\n# walkTree examples:"
    #    puts " \nwalkTree tree {} printNode"
    #    walkTree tree {} printNode

    #    puts " \nwalkTree tree {} printNode"
    #    walkTreeT tree {} printNode

    puts "\n# walkTree tree {} cmdPrintNode:"
    walkTree tree {} cmdPrintNode

    puts "\n# walkTree tree {b} cmdPrintNode:"
    walkTree tree {b} cmdPrintNode

    puts "\n# walkTree tree {b} cmdListNode:"
    puts [walkTree tree {b} cmdListNode]

    puts "\n# getNode...:"
    puts [getNodeValue tree {b 101}]
    puts [getNodeFromTree tree {b 101}]
    puts "\n# getAttr...:"
    puts [getAttrValue tree {b 101}]
    puts [getAttrFromTree tree {b 101}]

    puts "\n# getAttrValue tree {b 101}:"
    puts [getAttrValue tree {b 101}]
    puts "\n# setAttrValue tree {b 101} {pid 101}:"
    set a [setAttrValue tree {b 101} {pid 101}]
    puts "\n# getAttrValue tree {b 101}:"
    puts [getAttrValue tree {b 101}]
    # Tiefe des Baums
    puts "\nTiefe des Baums:"
    puts [depth tree]

    puts "\n# tree2"
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
    printTree tree2
    # Calculate and print the depth of the tree

    putd "Depth of the tree: [depth tree2] "
    puts "\n# subtree tree b: tree3"
    set tree3 [getSubTree tree {b}]
    printTree tree3

    putd [isLeafNode tree {a 002}]
    putd [isLeafNode tree {a 002 011}]
    putd [existsNode tree {a 002 011}]
    putd [existsNode tree {a 002 012}]

    putd [getParent tree {a 001 012}]
    putd [getChildren tree {a 001} ]
    putd [getSiblings tree {a 001 012}]
    putd [isDescendant tree {a} {a 001 012}]
    putd [isDescendant tree {a 001} {a 001 012}]
    putd [isDescendant tree {a 001} {a 002 011}]
}

#Output
if {0} {



}
