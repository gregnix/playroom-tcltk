#! /usr/bin/env tclsh

#tbltreedict.tcl
# 20240821

# tablelist as tree
# tbl::dict2tbltree $tbl root $data
# set data [tbl::tbltree2dict $tbl root]

# needs dict isdict from dicttool

namespace eval tbl {
   # Function to check whether the first elements of the lists are equal
   # use in proc dict2tbltree
   proc checkFirstElementsEqualOLD {listOfLists} {
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
   proc dict2tbltree.old {widget parent dict} {
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
   
   proc dict2tbltreeold {widget parent dict} {
    foreach {key value} [dict get $dict] {
      if {[dict exists $dict $key]} {
        set keyValue [dict get $dict $key]
        if { [checkFirstElementsEqual $keyValue] } {
          set stdList [list]
          set newList [list]
          foreach sublist $keyValue {
            if {[lindex $sublist 0] eq ":"} {
              lappend newList [lindex $sublist 1]
            } else {
              lappend stdList [lindex $sublist 1]
            }
          }
          if {$stdList ne {}} {
            puts $newList
            set newList $stdList
          }
          $widget insertchild $parent end [list $key $keyValue]
          #$widget insert $parent end -text $key -values [list $newList]
          continue
        }

        if {[dict is_dict $keyValue] && [llength $keyValue] != "2"} {
          set newParent [$widget insertchild $parent end [list $key ""]]
          #set newParent [$widget insert $parent end -text $key -values ""]
          dict2tbltree $widget $newParent $keyValue
        } elseif {[llength $keyValue] == "2" && [dict is_dict [lindex $value 1]] } {
          set newParent [$widget insertchild $parent end [list $key ""]]
          #set newParent [$widget insert $parent end -text $key -values ""]
          dict2tvtree $widget $newParent $keyValue
        } else {
          if {[lindex $keyValue 0] eq ":" } {
            $widget insertchild $parent end [list $key $value]
            #$widget insert $parent end -text $key -values [list [lrange $keyValue 1 end]]
          } elseif {[lindex $keyValue 1 0 0] eq ":" } {
            #set nparent [$widget insert $parent end -text $key ]
            set newParent [$widget insertchild $parent end [list $key ""]]
            set newkeyValue [list]
            foreach val {*}[lrange $keyValue 1 end]  {
              lappend newkeyValue [lindex $val 1]
            }
            $widget insertchild $nparent end [list $key $value]
            #$widget insert $nparent end -text [lindex $keyValue 0 ] -values [list $newkeyValue]
          } else {
            if {[string match {\{: *} $value]} {
              $widget insertchild $parent end [list $key $value]
              #$widget insert $parent end -text $key -values [string range $keyValue 2 end-1]
            } else {
              $widget insertchild $parent end [list $keyValue] 
              puts "key $key "
              
              #$widget insert $parent end -text $key -values [list $keyValue]
            }
          }
        }
      }
    }
  }
   
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
   
}

