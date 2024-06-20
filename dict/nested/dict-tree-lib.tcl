#! /usr/bin/env tclsh

#20240619.0600
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

proc addToTree {tree path value {attr {}}} {
    upvar 1 $tree dictTree
    set key [lindex $path 0]
    if {[llength $path] == 1} {
        dict set dictTree key $key val $value
        dict set dictTree key $key attr $attr
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
        addToTree subDict $restPath $value $attr
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
    set value [getNodeFromTree dictTree $fromPath]
    set attrib [getAttrFromTree dictTree $fromPath]
    deleteNode dictTree $fromPath
    addToTree dictTree $toPath $value $attrib
}

proc replaceNode {tree path value attrib} {
    upvar 1 $tree dictTree
    deleteNode dictTree $path
    addToTree dictTree $path $value $attrib
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

proc getNodeFromTree {tree path} {
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
        return [getNodeFromTree subDict $restPath]
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

# node exists, then?
proc setNodeValue {tree path newValue} {
    upvar 1 $tree dictTree
    set key [lindex $path end]
    set parentPath [lrange $path 0 end-1]

    if {[llength $parentPath] == 0} {
        # Handle root element
        set parentDict $dictTree
    } else {
        set keyPath [lmap ipath $parentPath {list key $ipath}]
        set keyPath [concat {*}$keyPath]
        set parentDict [dict get $dictTree {*}$keyPath]
        if {![dict exists $parentDict key $key]} {
            error "Key \"$key\" not found in dictionary"
        }
    }

    set node [dict get $parentDict key $key]
    dict set node val $newValue
    dict set parentDict key $key $node

    if {[llength $parentPath] == 0} {
        # Handle root element
        set dictTree $parentDict
    } else {
        dict set dictTree {*}$keyPath $parentDict
    }
}

## attrib
proc getAttrFromTree {tree path} {
    upvar 1 $tree dictTree
    set key [lindex $path 0]
    if {[llength $path] == 1} {
        set node [dict get $dictTree key $key]
        if {[dict exists $node attr]} {
            return [dict get $node attr]
        } else {
            return {}
        }
    } else {
        set restPath [lrange $path 1 end]
        set subDict [dict get $dictTree key $key]
        return [getAttrFromTree subDict $restPath]
    }
}

proc getAttrValue {tree path args} {
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
proc setAttrValue {tree path newAttribut} {
    upvar 1 $tree dictTree
    set key [lindex $path end]
    set parentPath [lrange $path 0 end-1]

    if {[llength $parentPath] == 0} {
        # Handle root element
        set parentDict $dictTree
    } else {
        set keyPath [lmap ipath $parentPath {list key $ipath}]
        set keyPath [concat {*}$keyPath]
        set parentDict [dict get $dictTree {*}$keyPath]
        if {![dict exists $parentDict key $key]} {
            error "Key \"$key\" not found in dictionary"
        }
    }
    set node [dict get $parentDict key $key]
    dict set node attr $newAttribut
    dict set parentDict key $key $node

    if {[llength $parentPath] == 0} {
        # Handle root element
        set dictTree $parentDict
    } else {
        dict set dictTree {*}$keyPath $parentDict
    }
    return
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
    if {[dict exists $dictTree val]} {
        return 0
    }
    set maxDepth 0
    if {[dict exists $dictTree key]} {
        dict for {key value} [dict get $dictTree key] {
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

proc nodeExists {tree path} {
    upvar 1 $tree dictTree
    set key [lindex $path end]
    set parentPath [lrange $path 0 end-1]
    set keyPath [lmap ipath $parentPath {list key $ipath}]
    set keyPath [concat {*}$keyPath]

    if {[dict exists $dictTree {*}$keyPath key $key]} {
        return 1
    } else {
        return 0
    }
}

proc isLeafNode {tree path} {
    upvar 1 $tree dictTree
    set key [lindex $path end]
    set parentPath [lrange $path 0 end-1]
    set keyPath [lmap ipath $parentPath {list key $ipath}]
    set keyPath [concat {*}$keyPath]

    if {[dict exists $dictTree {*}$keyPath key $key]} {
        set node [dict get $dictTree {*}$keyPath key $key]
        if {[dict exists $node key]} {
            return 0
        } else {
            return 1
        }
    } else {
        return 0
    }
}

proc getSubTree {tree path} {
    upvar 1 $tree dictTree
    set keyPath [lmap ipath $path {list key $ipath}]
    set keyPath [concat {*}$keyPath]

    if {[dict exists $dictTree {*}$keyPath]} {
        return [dict get $dictTree {*}$keyPath]
    } else {
        error "Path \"$path\" not found in tree"
    }
}


###################################################################
# Example
if {[info script] eq $argv0} {

    proc putd {command} {
        puts [info frame -1]
        set cmd [dict get [info frame -1] cmd]
        set cmd "[string trimright [string trimleft $cmd  "putd \["] "\]"]"
        puts "#cmd: ${cmd}"
        puts $command
        puts "\n"
    }

    proc putd {command} {
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

    set tree3 [getSubTree tree {b}]
    printTree tree3

    puts [isLeafNode tree {a 002}]
    #puts [isLeafNode tree {a 002 011}]
    putd [nodeExists tree {a 002 011}]
    putd [nodeExists tree {a 002 012}]
}

#Output
if {0} {

    # printTree:
    a:
    testxy
    pid 0 pppid -1
    001:
    012:
    value012
    013:
    value013
    test1
    002:
    011:
    value011
    b:
    101:
    valueb101
    pid 0
    112:
    Nodevalue 112
    121:
    value121
    002:
    value002
    103:
    111:
    value111
    114:
    value114
    Nodevalue b103

    # puts $tree:
    key {a {val testxy attr {pid 0 pppid -1} key {001 {key {012 {val value012 attr {}} 013 {val value013 attr {}}} val test1} 002 {key {011 {val value011 attr {}}}}}} b {key {101 {val valueb101 attr {pid 0} key {112 {val {Nodevalue 112} attr {} key {121 {val value121 attr {}}}}}} 002 {val value002 attr {}} 103 {key {111 {val value111 attr {}} 114 {val value114 attr {}}} val {Nodevalue b103}}}}}

    # walkTree examples:

    # walkTree tree {} cmdPrintNode:
    Path: a                              Value: testxy               Attr: pid=0 pppid=-1
    Path: a 001 012                      Value: value012             Attr:
    Path: a 001 013                      Value: value013             Attr:
    Path: a 002 011                      Value: value011             Attr:
    Path: b 101                          Value: valueb101            Attr: pid=0
    Path: b 101 112                      Value: Nodevalue 112        Attr:
    Path: b 101 112 121                  Value: value121             Attr:
    Path: b 002                          Value: value002             Attr:
    Path: b 103 111                      Value: value111             Attr:
    Path: b 103 114                      Value: value114             Attr:

    # walkTree tree {b} cmdPrintNode:
    Path: b 101                          Value: valueb101            Attr: pid=0
    Path: b 101 112                      Value: Nodevalue 112        Attr:
    Path: b 101 112 121                  Value: value121             Attr:
    Path: b 002                          Value: value002             Attr:
    Path: b 103 111                      Value: value111             Attr:
    Path: b 103 114                      Value: value114             Attr:

    # walkTree tree {b} cmdListNode:
    {{b 101} valueb101 {pid 0}} {{b 101 112} {Nodevalue 112} {}} {{b 101 112 121} value121 {}} {{b 002} value002 {}} {{b 103 111} value111 {}} {{b 103 114} value114 {}}

    # getNode...:
    valueb101
    valueb101

    # getAttr...:
    pid 0
    pid 0

    # getAttrValue tree {b 101}:
    pid 0

    # setAttrValue tree {b 101} {pid 101}:

    # getAttrValue tree {b 101}:
    pid 101



}
