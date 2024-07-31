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



namespace eval tbl {

package require tdom
package require json
#https://wiki.tcl-lang.org/page/xml2dict
## Convert set XML formatted data to a Tcl dict
# use tdom to convert XML to JSON
# use json to convert JSON to dict
# @param[in] xml        the xml text to convert
# returns data in xml as an enumberated dict
proc xml2dict { xml } {
        set root [[dom parse $xml] documentElement]
        set i -1
        foreach node [$root childNodes] { lappend res [incr i] [::json::json2dict [$node asJSON] ] }
        return $res
}
}