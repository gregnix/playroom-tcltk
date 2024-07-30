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