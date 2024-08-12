#! /usr/bin/env tclsh

# 20240812
#treeview-lib.tcl

package require struct::list
#::struct::list flatten use in proc showVisibleItems
package require dicttool
# dict is_dict use in procs dict2tvtree collectKeys collectKeysPoint

# a. import export dict and tree
# b. band stripe
# c. treeview extra procs
# d. extra key
# e. example datas
# f. search and open node

################################
# a. import export dict and tree
################################
namespace eval tvlib {
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

  # special with key == ":" then list
  proc dict2tvtree {widget parent dict} {
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
          $widget insert $parent end -text $key -values [list $newList]
          continue
        }

        if {[dict is_dict $keyValue] && [llength $keyValue] != "2"} {
          set newParent [$widget insert $parent end -text $key -values ""]
          dict2tvtree $widget $newParent $keyValue
        } elseif {[llength $keyValue] == "2" && [dict is_dict [lindex $value 1]] } {
          set newParent [$widget insert $parent end -text $key -values ""]
          dict2tvtree $widget $newParent $keyValue
        } else {
          if {[lindex $keyValue 0] eq ":" } {
            $widget insert $parent end -text $key -values [list [lrange $keyValue 1 end]]
          } elseif {[lindex $keyValue 1 0 0] eq ":" } {
            set nparent [$widget insert $parent end -text $key ]
            set newkeyValue [list]
            foreach val {*}[lrange $keyValue 1 end]  {
              lappend newkeyValue [lindex $val 1]
            }
            $widget insert $nparent end -text [lindex $keyValue 0 ] -values [list $newkeyValue]
          } else {
            if {[string match {\{: *} $value]} {
              puts $keyValue
              $widget insert $parent end -text $key -values [string range $$keyValue 2 end-1]
            } else {
              $widget insert $parent end -text $key -values [list $keyValue]
            }



          }
        }
      }
    }
  }

  # Function to recursively convert a tree into a dictionary
  # own interpretation with the same keys
  proc tvtree2dict {tree node} {
    set result {}
    # for equal keys
    set checkFEE 0
    set checkkey ""
    # Get the children of the current node
    set children [$tree children $node]
    foreach child $children {
      set key [$tree item $child -text]
      if {($checkFEE eq "1") && ($key ne $checkkey)} {
        puts "  ch if:  $checkkey k $key :: $checkFEE "
        set checkFEE 0
        set checkkey $key
        set result [expandList $result]
      }
      set value [lindex [$tree item $child -values] 0]
      # Check if the child itself has children
      if {[$tree children $child] > 0} {
        set childDict [tvtree2dict $tree $child]
        dict set result $key $childDict
      } else {
        if {[dict exists $result $key]} {
          set tmplist [dict get $result $key]
          lappend tmplist $value
          dict set result $key $tmplist
          if {!$checkFEE} {
            set checkFEE 1
            set checkkey $key
          }
        }  else {
          dict set result $key $value
        }
      }
    }
    if {($checkFEE eq "1")} {
      set checkFEE 0
      set checkkey $key
      set result [expandList $result]
    }
    return $result
  }
}

################
# b. band stripe
################
# tvlib::bandInit $tree
# tvlib::band $tree
## use event:
# tvlib::band_event $tree
#
# for band striped see at:
# https://wiki.tcl-lang.org/page/dgw%3A%3Atvmixins
# https://chiselapp.com/user/dgroth/repository/tclcode/index
# https://wiki.tcl-lang.org/page/Tile+Table
# https://www.tcl.tk/man/tcl9.0/TkCmd/ttk_treeview.html#M100
namespace eval tvlib {
  proc band {tree {parent {}} {i 0} } {
    foreach item [$tree children $parent] {
      set t [expr {$i % 2}]
      $tree tag remove band0 $item
      $tree tag remove band1 $item
      $tree tag add band$t $item
      incr i
      set i [band $tree $item $i]
    }
    return $i
  }

  proc bandInit {tree {color0 #FFFFFF} {color1 #E0E0E0}} {
    $tree tag configure band0 -background $color0
    $tree tag configure band1 -background $color1
    bind $tree <<TVItemsChanges>> [list [namespace current]::band $tree]
  }

  proc bandEvent {tree} {
    event generate $tree <<TVItemsChanges>> -data [$tree selection]
  }

}

#########################
# c. treeview extra procs
#########################
namespace eval tvlib {
  proc treesize {tree {p {}}} {
    set size 0
    foreach c [$tree children $p] {
      incr size [llength $c]
      incr size [treesize $tree $c]
    }
    return $size
  }

  proc treedepth {tree {parent {}} {depth 0}} {
    set max $depth
    foreach item [$tree children $parent] {
      set currentDepth [treedepth $tree $item [expr {$depth + 1}]]
      if {$currentDepth > $max} {
        set max $currentDepth
      }
    }
    return $max
  }
  proc itemdepth {tree item} {
    set depth 0
    while {$item ne ""} {
      set item [$tree parent $item]
      incr depth
    }
    return $depth
  }
  proc tv2list {tree {parent {}}} {
    set data {}
    foreach c [$tree children $parent] {
      dict set data $c [tv2list $tree $c]
    }
    return $data
  }
}

####################
# d. key extra procs
####################
namespace eval tvlib {
  #
  proc collectKeys {dictVar {keysList {}}} {
    foreach {key value} [dict get $dictVar] {
      if { [checkFirstElementsEqual $value] } {
        lappend keysList ${key}
        continue
      }
      if {[dict is_dict $value] && [llength $value] != "2"} {
        lappend keysList ${key}
        set keysList [collectKeys $value  $keysList]
      } elseif {[llength $value] == "2" && [dict is_dict [lindex $value 1]] } {
        lappend keysList ${key}
        set keysList [collectKeys $value  $keysList]
      } else {
        lappend keysList ${key}
      }
    }
    return $keysList
  }

  # with full path with point
  proc collectKeysPoint {dictVar {prefix ""} {keysList {}}} {
    foreach {key value} [dict get $dictVar] {
      if { [checkFirstElementsEqual $value] } {
        lappend keysList ${prefix}${key}
        continue
      }
      if {[dict is_dict $value] && [llength $value] != "2"} {
        lappend keysList ${prefix}${key}
        set keysList [collectKeysPoint $value "${prefix}${key}." $keysList]
      } elseif {[llength $value] == "2" && [dict is_dict [lindex $value 1]] } {
        lappend keysList ${prefix}${key}
        set keysList [collectKeysPoint $value "${prefix}${key}." $keysList]
      } else {
        lappend keysList ${prefix}${key}
      }
    }
    return $keysList
  }

  proc extractTails {keys} {
    set tails {}
    foreach key $keys {
      set parts [split $key "."]
      lappend tails [lindex $parts end]
    }
    return $tails
  }
  proc extractHeads {keys} {
    set heads {}
    foreach key $keys {
      set parts [split $key "."]
      lappend heads [lindex $parts 0]
    }
    return [uniqueList2 $heads]
  }

  # use in proc extractHeads
  proc uniqueList2 {list} {
    set dict {}
    foreach item $list {
      dict set dict $item ""
    }
    dict keys $dict
  }

  # use in proc tvtree2dict
  proc expandList {inputList} {
    set key [lindex $inputList 0]
    set values [lindex $inputList 1]
    set result {}

    foreach value $values {
      lappend result [list $key $value]
    }
    return $result
  }
}

#####################################
# d. example datas
# tvlib::testCreateTreeStruct $tree 4
#####################################
namespace eval tvlib {
  variable exampleDatas

  # d.1 data dict for example datas
  dict set exampleDatas abc12 {a1 {b11 {a11 {b1111 c1 b1112 c1}} b12 {a12 {b1211 c1 b1212 c1}}} a2 {b21 {a21 {b2111 c1 b2112 c1}} b22 {a22 {b2211 c1 b2212 c1}}}}
  dict set exampleDatas person {person  {name "John Doe" age 30.8 address {street "123 Main St" city "Anytown"}  employees {  {name "Alice Smith" } {name "Bob Smith"} {name "John Good"} {name "Jane Good"}} } job {title "Developer" company "Works"}}


  # d.2 two procs for test data for tree struct
  proc testAddNodes {tree parent depth} {
    if {$depth <= 0} {
      return
    }
    set numChildren [expr {1 + int(rand() * 11)}]
    for {set i 0} {$i < $numChildren} {incr i} {
      set id [$tree insert $parent end -text "Node $i Depth $depth"]
      $tree item $id -values $id
      testAddNodes $tree $id [expr {$depth - 1}]
    }
  }
  proc testCreateTreeStruct {tree {depth 5} } {
    foreach txt {first second third fourth five} {
      set id [$tree insert {} end -text "$txt item" -open 1]
      $tree item $id -values $id
      testAddNodes $tree $id $depth
    }
  }

  #https://wiki.tcl-lang.org/page/info
  # special with key == ":" then list
  proc infotcltk {} {
    lappend infodata hostname [info hostname]
    lappend infodata library [info library]
    lappend infodata nameofexecutable [info nameofexecutable]
    lappend infodata patchlevel [info patchlevel]
    lappend infodata sharedlibextension [info sharedlibextension]
    lappend infodata tclversion [info tclversion]
    dict set data info $infodata

    dict set data tm [tcl::tm::path list]

    #https://wiki.tcl-lang.org/page/Tcl+Package+User+Guide
    foreach i [lsort [package names]] {
      if {[string length [package provide $i]]} {
        lappend loaded  $i [package present $i]
      }
    }
    dict set data package loaded $loaded

    foreach p [lsort [package names]] {
      lappend allp $p [package versions $p]
    }
    dict set data package all $allp

    #namespace
    dict set data namespace [listns]

    set ns ::
    set pat [set ns]::*

    foreach proc [lsort [info procs $pat]] {
      dict lappend data  procs  [list : $proc]
    }

    foreach command [lsort [info commands $pat]] {
      dict lappend data commands  [list : $command]
    }

    foreach function [lsort [info functions $pat]] {
      dict lappend data functions  [list : $function]
    }

    foreach var [info vars $pat] {
      if {[array exists $var]} {
        dict lappend date array $var [list {*}[array get $var]]
      } {
        dict lappend date variable $var [list [set $var]]
      }
    }
    dict set data vars $date

    return $data
  }

  proc listns {{parentns ::}} {
    set result [dict create]
    dict set result procs [listnsprocs $parentns]
    dict set result vars  [listnsvars $parentns]
    foreach ns [namespace children $parentns] {
      dict set result $ns [listns $ns]
    }
    return $result
  }

  proc listnsprocs {ns} {
    set result ""
    foreach proc [lsort [info procs ${ns}::*]] {
      lappend result [list ":" $proc]
    }
    return $result
  }
  proc listnsvars {ns} {
    set result ""
    foreach var [lsort [info vars ${ns}::*]] {
      lappend result [list ":" $var]
    }
    return $result
  }
}

#########################
# e. search and open node
#########################
namespace eval tvlib {

  # e.1 set list [tvlib::showVisibleItems $tree "child 1"]
  # procs: openParentNodes showVisibleItems showVisibleChildren
  proc openParentNodes {tree item} {
    set parent [$tree parent $item]
    if {$parent ne ""} {
      $tree item $parent -open true
      openParentNodes $tree $parent
    }
  }
  proc showVisibleItems {tree searchString} {
    set resultList [list]
    foreach item [$tree children {}] {
      if {[string match $searchString [$tree item $item -text]]} {
        openParentNodes $tree $item
      } else {
        $tree item $item -open false
      }
      lappend resultList [showVisibleChildren $tree $item $searchString]
    }
    return [::struct::list flatten -full $resultList]
  }

  proc showVisibleChildren {tree parent searchString} {
    set resultList [list ]
    foreach item [$tree children $parent] {
      if {[string match $searchString [$tree item $item -text]]} {
        lappend resultList $item
        openParentNodes $tree $item
      } else {
        $tree item $item -open false
      }
      lappend resultList [showVisibleChildren $tree $item $searchString]
    }
    return $resultList
  }

}
