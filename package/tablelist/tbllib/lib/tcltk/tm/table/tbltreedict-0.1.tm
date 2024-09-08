#! /usr/bin/env tclsh

#tbltreedict.tcl
# 20240825

# tablelist as tree
# tbl::dict2tbltree $tbl root $data
# set data [tbl::tbltree2dict $tbl root]

# needs dict isdict from dicttool

namespace eval tbllib {
   # Function to check whether the first elements of the lists are equal
   # use in proc dict2tbltree
   proc checkFirstElementsEqual {listOfLists} {
      if {[llength $listOfLists] < "2"} {
         return 0
      }
      set firstElement ""
      foreach sublist $listOfLists {
         if {[string is list $sublist]} {
            lassign $sublist first _
         } else {
            set first $sublist
         }
         if {$firstElement eq ""} {
            set firstElement $first
         } elseif {$firstElement ne $first} {
            return 0
         }
      }
      return 1
   }

   # Function to recursively convert a tree into a dictionary
   # dict with same keys
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
            if {[dict is_dict $result]} {
               # a dict with same keys
               if {[dict exists $result $key]} {
                  set dicttmp [list [list $key [dict get $result $key]]]
                  lappend dicttmp  [list $key $value]
                  set result $dicttmp
               } elseif {[checkFirstElementsEqual  $result]} {
                  lappend result [list $key $value]
               } else {
                  dict set result $key $value
               }
            }
         }
      }
      return $result
   }


 
   proc dict2tbltree {widget parent dict} {
      if {[dict is_dict $dict]} {
         set keys [dict keys $dict]
         foreach key $keys  {
            set child [$widget insertchild $parent end $key]
            set childdict [dict get $dict $key]
            if {[llength $childdict] eq "1"} {
               dict2tbltree $widget $child $childdict
            } elseif {[checkFirstElementsEqual $childdict]}  {
               foreach {k v } [concat {*}$childdict] {
                  $widget insertchild $child end [list $k $v]
               }
            } elseif {[llength $childdict] eq "2" && ![dict is_dict [lindex $childdict 1]]} {
               $widget cellconfigure $child,value -text $childdict
            } else {
               dict2tbltree $widget $child $childdict
            }
         }
      } else {
         $widget cellconfigure $parent,value -text $dict
      }
   }
}

