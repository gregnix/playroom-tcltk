#! /usr/bin/env tclsh

#tbltreedict.tcl
#20240729
# tablelist as tree

namespace eval tbl {

    proc isDictAdjusted value {
        if {![catch {dict size $value}]} {
            # Check if the dictionary contains at least one nested dictionary
            foreach {key val} $value {
                if {[isDictAdjusted $val] && [llength $key] <= 1 } {
                    return 1
                } elseif {[llength $key] > 1 }  {
                    return 0
                }
            }
            # If no nested dictionaries are found, check the length condition
            if {[llength $value] > 2 } {
                return 1
            }
        }
        return 0
    }

    proc printDictAdjusted {dict {ind 0}} {
        foreach {key value} $dict {
            if { [isDictAdjusted $value]} {
                append print "[string repeat " " $ind]$key:" \n
                append print [printDictAdjusted $value [incr ind]] \n
            } else {
                append print "[string repeat " " $ind]$key: $value" \n
            }
        }
        return  $print
    }
    proc isDict value {
        expr {![catch {dict size $value}]}
    }

    proc printDict {dict} {
        foreach {key value} $dict {
            if { [isDict $value]} {
                puts "$key:"
                printDict $value
            } else {
                puts "$key: $value"
            }
        }
    }

    # Function to recursively convert a tree into a dictionary
    proc tbltree2dict {tbl node} {
        set result {}
        # Get the children of the current node
        set children [$tbl childkeys $node]
        foreach child $children {
            # Get the text (key and value) of the current child
            set item [$tbl rowcget $child -text]
            set key [lindex $item 0]
            set value [lindex $item 1]
            # Check if the child itself has children
            if {[$tbl childcount $child] > 0} {
                set childDict [tbltree2dict $tbl $child]
                dict set result $key $childDict
            } else {
                dict set result $key $value
            }
        }
        return $result
    }

    # Function to recursively display a dictionary in the tree
    proc dict2tbltree {widget parent dict} {
        foreach {key value} $dict {
            if {[dict exists $dict $key]} {
                set keyValue [dict get $dict $key]
                if {[isDictAdjusted $keyValue]} {
                    set newParent [$widget insertchild $parent end [list $key ""]]
                    dict2tbltree $widget $newParent $keyValue
                } else {
                    $widget insertchild $parent end [list $key $value]
                }
            }
        }
    }

}


namespace eval tbl {
    # Funktion, um Informationen über eine Datei zu sammeln
    proc get_file_info {file_path} {
        set info [dict create]
        dict set info size [file size $file_path]
        dict set info atime [file atime $file_path]
        dict set info mtime [file mtime $file_path]
        dict set info type [file type $file_path]
        dict set info readable [file readable $file_path]
        dict set info writable [file writable $file_path]
        dict set info executable [file executable $file_path]
        return $info
    }

    # Rekursive Funktion, um die Verzeichnisstruktur zu durchlaufen
    proc scan_directory {dir} {
        set result [dict create]

        # Durchlaufe alle Dateien und Verzeichnisse im aktuellen Verzeichnis
        foreach item [glob -nocomplain -directory $dir *] {
            set item_path [file join $dir $item]
            if {[file isdirectory $item_path]} {
                # Wenn es ein Verzeichnis ist, rufe die Funktion rekursiv auf
                dict set result $item [scan_directory $item_path]
            } elseif {[file isfile $item_path]} {
                # Wenn es eine Datei ist, sammle die Informationen darüber
                dict set result $item [get_file_info $item_path]
            }
        }

        return $result
    }
}