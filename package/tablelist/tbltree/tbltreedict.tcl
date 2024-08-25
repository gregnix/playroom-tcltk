#! /usr/bin/env tclsh

#tbltreedict.tcl
# 20240803

# tablelist as tree
# tbl::dict2tbltree $tbl root $data
# set data [tbl::tbltree2dict $tbl root]

# needs dict isdict from dicttool

namespace eval tbl {
   # Function to check whether the first elements of the lists are equal
   # use in proc dict2tbltree
   proc checkFirstElementsEqual {listOfLists} {
      if {[llength $listOfLists] < "2"} {
         return 0
      }
      set firstElement ""
      foreach sublist $listOfLists {
         lassign $sublist first _
         if {$firstElement eq ""} {
            set firstElement $first
         } elseif {$firstElement ne $first} {
            return 0
         }
      }
      return 1
   }

   # Function to recursively convert a tree into a dictionary
   proc tbltree2dict {tbl node} {
      set result {}
      puts okre2
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

            puts "okre3 [dict is_dict $childDict]"
            dict set result $key $childDict
         } else {
            puts "okre4 [dict is_dict $result]"
            if {[dict is_dict $result] } {
               if {[dict exists $result $key]} {
                  set dicttmp [list $key [dict get $result $key]]
                  lappend dicttmp  $key $value

                  puts "$dicttmp :: $result"
                  lappend result $dicttmp
                  puts okd
               } else {
                  dict set result $key $value
               }
            } else {
            puts "dd $result   "
            }
            puts okre1
         }
      }
      puts okre
      return $result
   }



   # Function to recursively display a dictionary in the tree
   proc dict2tbltree {widget parent dict} {
      foreach {key value} [dict get $dict] {
         if {[dict exists $dict $key]} {
            set keyValue [dict get $dict $key]
            if { [checkFirstElementsEqual $keyValue] } {
               $widget insertchild $parent end [list $key $keyValue]
               continue
            }
            if {[dict is_dict $keyValue] && [llength $keyValue] != "2"} {
               set newParent [$widget insertchild $parent end [list $key ""]]
               dict2tbltree $widget $newParent $keyValue
            } elseif {[llength $keyValue] == "2" && [dict is_dict [lindex $value 1]] } {
               set newParent [$widget insertchild $parent end [list $key ""]]
               dict2tbltree $widget $newParent $keyValue
            } else {
               $widget insertchild $parent end [list $key $value]
            }
         }
      }
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
               puts "else $childdict  ::: [llength $childdict]"

            } else {
               dict2tbltree $widget $child $childdict
            }
         }
      } else {
         $widget cellconfigure $parent,value -text $dict
         set ll [llength [concat {*}$dict]]
         if {$ll eq "1"} {
            puts "einzel if: $dict"
         } else {
            puts "einzel else: $dict"
         }
      }
   }
}

