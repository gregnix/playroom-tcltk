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

proc sortPid {a b} {
  set a0 [dict get [lindex $a 2] pid]
  set b0 [dict get [lindex $b 2] pid]
  if {$a0 < $b0} {
    return -1
  } elseif {$a0 > $b0} {
    return 1
  }
  return 0
}

proc insertNode {utree path {value {}}  {attr {}}} {
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
        insertNode subDict $restPath $value $attr
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
    insertNode tree $toPath $value $attrib
    return
}

proc replaceNode {utree path value attrib} {
    upvar 1 $utree tree
    deleteNode tree $path
    insertNode tree $path $value $attrib
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

    if {[llength $path] > 0} {
        set keyPath [lmap ipath $path {list key $ipath}]
        set keyPath [concat {*}$keyPath]
        if {![dict exists $tree {*}$keyPath]} {
            return $result
        }
        set subDict [dict get $tree {*}$keyPath]
    } else {
        set subDict $tree
    }

    if {[dict exists $subDict key]} {
        set keysubDict [dict get $subDict key]
    } else {
        return $result
    }

    dict for {key value} $keysubDict {
        set fullPath [concat $path $key]
        lappend result $fullPath
        if {[is-dict $value]} {
            set subResult [getAllNodes tree $fullPath]
            foreach item $subResult {
                lappend result $item
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

# node not exists, then?
proc setNodeValue {utree path newValue} {
    upvar 1 $utree tree
    set key [lindex $path end]
    set parentPath [lrange $path 0 end-1]

    if {[llength $parentPath] == 0} {
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

    set oldValue  [dict get $node val ]
    dict set node val $newValue
    dict set parentDict key $key $node

    if {[llength $parentPath] == 0} {
        # Handle root element
        set tee $parentDict
    } else {
        dict set tree {*}$keyPath $parentDict
    }
    return
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

proc getNodeAttr {utree path args} {
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
proc setNodeAttr {utree path newAttrib} {
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
    set oldAttrib [dict get $node attr]
    dict set node attr $newAttrib
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
proc processSortedResults {sortedResults action} {
    foreach result $sortedResults {
        eval $action $result
    }
}
proc cmdPrintNode {path value attr} {
    set formattedAttr ""
    foreach {key val} $attr {
        append formattedAttr "$key=$val "
    }
    puts "Path: [format %-30s $path] Value: [format %-20s $value] Attr: $formattedAttr"
}

proc cmdPrintAttr {path value attr} {
    set formattedAttr ""
    foreach {key val} $attr {
        append formattedAttr "$key=$val "
    }
    puts "Path: [format %-30s $path]  Attr: $formattedAttr"
}

# info procs
proc size {utree} {
    upvar 1 $utree tree
    set count 0
    dict for {key value} $tree {
        if {[dict exists $value val] || [dict exists $value key]} {
            incr count
        }
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

proc walkTree {utree path} {
    upvar 1 $utree tree
    set stack [list [list $path]]
    set results {}

    while {[llength $stack] > 0} {
        lassign [lindex $stack end] currentPath
        set stack [lrange $stack 0 end-1]

        set keyPath [lmap ipath $currentPath {list key $ipath}]
        set keyPath [concat {*}$keyPath]
        set keysubDict [dict get $tree {*}$keyPath]

        set values ""
        set attr {}

        dict for {key value} $keysubDict {
            if {$key eq "key"} {
                dict for {subkey subvalue} $value {
                    set newPath [concat $currentPath $subkey]
                    lappend stack [list $newPath]
                }
            } elseif {$key eq "val"} {
                set values $value
            } elseif {$key eq "attr"} {
                set attr $value
            }
        }

        if {[llength $values] > 0 || [llength $attr] > 0} {
            lappend results [list $currentPath $values $attr]
        }
    }

    # Sortieren der Ergebnisse
    set sortedResults [lsort -dictionary $results]

    return $sortedResults
}

# walktree, action < cmds
proc walkTreeold {utree path action args} {
    #puts " wT: [incr ::wT] :: level: [info level] :: frame: [info frame] :: cmd: [dict get [info frame -1] cmd]"
    upvar 1 $utree tree
    set opath $path
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
                if {[is-dict $subvalue]} {
                    lappend result {*}[walkTreeChild subvalue $action  $opath]
                } else {
                    error "no dictionary"
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

proc walkTreeChild {utree action args} {
    #puts "  wTC: [incr ::wTC] :: level: [info level] :: frame: [info frame] :: cmd: [dict get [info frame -1] cmd]"
    upvar 1 $utree tree
    set path {}
    set opath {*}$args
    set result [list]
    set keysubDict [dict get $tree]
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

                if {[is-dict $subvalue]} {
                    lappend result {*}[walkTreeChild subvalue  $action  $opath]
                } else {
                    error "no dicitionary"
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

proc existsNodeValue {utree path} {
    upvar 1 $utree tree
    set key [lindex $path end]
    set parentPath [lrange $path 0 end-1]
    set keyPath [lmap ipath $parentPath {list key $ipath}]
    set keyPath [concat {*}$keyPath]

    if {[dict exists $tree {*}$keyPath key $key val]} {
        return 1
    } else {
        return 0
    }
}

proc existsNodeAttr {utree path} {
    upvar 1 $utree tree
    set key [lindex $path end]
    set parentPath [lrange $path 0 end-1]
    set keyPath [lmap ipath $parentPath {list key $ipath}]
    set keyPath [concat {*}$keyPath]

    if {[dict exists $tree {*}$keyPath key $key attr]} {
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
        if {[dict exists $node key] && [llength [dict get $node key]] != 0 } {
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
# tree is not use
proc isDescendant {ancestorPath descendantPath} {
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
        set cmd [string range $cmd [string first \[ $cmd]+1 [string last \] $cmd]-1]
        puts "#cmd: ${cmd}"
        puts $command
        puts "\n"
    }

    # Initialisieren eines leeren Baumes
    set tree [dict create]

    # Hinzufügen von Daten zum Baum
    insertNode tree {a} "value00"
    insertNode tree {a 001 012} "value012"
    insertNode tree {a 001 013 014} "value014"
    insertNode tree {a 002 011} "value011"
    insertNode tree {b 101} "valueb101" "pid 0"
    insertNode tree {b 104 142} "value112"
    insertNode tree {b 101 112}
    setNodeValue tree {b 101 112} "sNV112"
    setNodeAttr tree {b 101 112} "pid 14"
    insertNode tree {b 101 112 121} "value121"
    insertNode tree {b 002} "value002"
    insertNode tree {b 103 111} "valueb111"

    printTree tree
    # Ergebnisse sortiert abrufen
    set sortedResults [walkTree tree {}]
    # Sortierte Ergebnisse verarbeiten
    processSortedResults $sortedResults cmdPrintNode
    processSortedResults $sortedResults cmdPrintAttr
    putd $tree
    putd [size tree]
    putd [depth tree]
    putd [getAllNodes tree {}]]

}

#Output
if {0} {
    a:
    value00
    001:
    012:
    value012
    013:
    014:
    value014
    002:
    011:
    value011
    b:
    101:
    valueb101
    pid 0
    112:
    sNV112
    pid 14
    121:
    value121
    104:
    142:
    value112
    002:
    value002
    103:
    111:
    valueb111
    Path: b 103 111                      Value: valueb111            Attr:
    Path: b 002                          Value: value002             Attr:
    Path: b 104 142                      Value: value112             Attr:
    Path: b 101                          Value: valueb101            Attr: pid=0
    Path: b 101 112                      Value: sNV112               Attr: pid=14
    Path: b 101 112 121                  Value: value121             Attr:
    Path: a                              Value: value00              Attr:
    Path: a 002 011                      Value: value011             Attr:
    Path: a 001 013 014                  Value: value014             Attr:
    Path: a 001 012                      Value: value012             Attr:

    Path: a                              Value: value00              Attr:
    Path: a 001 012                      Value: value012             Attr:
    Path: a 001 013 014                  Value: value014             Attr:
    Path: a 002 011                      Value: value011             Attr:
    Path: b 101                          Value: valueb101            Attr: pid=0
    Path: b 101 112                      Value: sNV112               Attr: pid=14
    Path: b 101 112 121                  Value: value121             Attr:
    Path: b 104 142                      Value: value112             Attr:
    Path: b 002                          Value: value002             Attr:
    Path: b 103 111













    #cmd:
    key {a {val value00 attr {} key {001 {key {012 {val value012 attr {}} 013 {key {014 {val value014 attr {}}}}}} 002 {key {011 {val value011 attr {}}}}}} b {key {101 {val valueb101 attr {pid 0} key {112 {val sNV112 attr {pid 14} key {121 {val value121 attr {}}}}}} 104 {key {142 {val value112 attr {}}}} 002 {val value002 attr {}} 103 {key {111 {val valueb111 attr {}}}}}}}


    #cmd: size tree
    16


    #cmd: depth tree
    3


    #cmd: getAllNodes tree {a}]
    {a 001} {a 001 012} {a 001 013} {a 001 013 014} {a 002} {a 002 011}]



}
