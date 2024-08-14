#! /usr/bin/env tclsh

# 20240813
#treeview-lib.tcl

#https://core.tcl-lang.org/tk/tktview/2a6c62afd9

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
# g. creates a new treeview configured as a table with new, update ,upsert

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
              $widget insert $parent end -text $key -values [string range $keyValue 2 end-1]
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
    dict set result commands  [listnscommands $parentns]
    dict set result functions  [listnsfunctions $parentns]
    dict set result procs [listnsprocs $parentns]
    dict set result vars [listnsvars $parentns]

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

  proc listnscommands {ns} {
    set result ""
    foreach command [lsort [info commands ${ns}::*]] {
      lappend result [list ":" $command]
    }
    return $result
  }
  proc listnsfunctions {ns} {
    set result ""
    foreach function [lsort [info functions ${ns}::*]] {
      lappend result [list ":" $function]
    }
    return $result
  }

  proc listnsvars {ns} {
    #set result ""
    #set resultvars ""
    #set resultarray ""
    set date ""
    foreach var [lsort [info vars ${ns}::*]] {

      if {[array exists $var]} {
        #lappend resultarray [list ":" $var]
        dict set date array $var [list {*}[array get $var]]
      } {
        #lappend resultvars [list ":" $var]
        if {[catch {set $var} msg]} {
          puts "catch error: proc listnsvar :: $var"
          dict set date variable $var [list catch_error]
        } else {
          dict set date variable $var [list ":" [list [set $var]]]
        }

      }
    }
    #dict set result array $resultarray
    #dict set result variable $resultvars
    dict set data variablen $date
    #return $result
    return $data
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

namespace eval tvlib {
  # g. use of ttk::treeview to build a table
  # proc newTable
  # creates a new treeview configured as a table
  # new Row, Rows, Cell, Cells
  # update Row, Rows, Cell, Cells
  # upsert Row, Rows, Cell, Cells
  # delete Row, Rows, cell, Cells

  proc newTable {w colnames} {
    set frt [ttk::frame $w.frt]
    # create the tree showing headings only, and define column names
    set tree [ttk::treeview $frt.tree -show headings -columns $colnames\
    -yscrollcommand [list $frt.vsb set] -selectmode browse]
    set vsb [::ttk::scrollbar $frt.vsb -orient vertical -command [list $tree yview]]

    # set the text display for columns headers
    foreach colname $colnames {
      $tree heading $colname -text $colname
    }
    pack $frt -expand 1 -fill both

    pack $vsb -expand 0 -fill y -side right
    pack $tree -expand 1 -fill both
    return $tree
  }

  proc addRow {t {values ""}} {
    set item [$t insert {} end]
    foreach col [$t cget -columns] val $values {
      $t set $item $col $val
    }
    event generate $t <<TVItemsChanges>>
  }

  proc addRows {t {valueslist ""}} {
    foreach values $valueslist {
      set item [$t insert {} end]
      foreach col [$t cget -columns] val $values {
        $t set $item $col $val
      }
    }
    event generate $t <<TVItemsChanges>>
  }
  proc addCell {t col value {pos end}} {
    set item [$t insert {} $pos]
    $t set $item $col $val
    event generate $t <<TVItemsChanges>>
  }
  proc addCells {t col values {pos end}} {
    set item [lindex [$t children {}] $pos]
    set index [$t index $item]
    foreach val $values {
      set item [$t insert {} $index]
      $t set $item $col $val
      incr index
    }
    event generate $t <<TVItemsChanges>>
  }
  proc updateRow {t values index} {
    set item [lindex [$t children {}] $index]
    if { $item eq "" } {
      return 0
    }
    foreach col [$t cget -columns] val $values {
      $t set $item $col $val
    }
    return 1
  }

  proc updateRows {t values index} {
    foreach val $values {
      updateRow $t $val $index
      incr index
    }
  }
  proc updateCell {t col value index} {
    set item [lindex [$t children {}] $index]
    if { $item eq "" } {
      return 0
    }
    $t set $item $col $value
    return 1
  }

  proc updateCells {t col values index} {
    foreach val $values {
      updateCell $t $col $val $index
      incr index
    }
  }
  proc upsertRow {t values index} {
    set items [$t children {}]
    if {$index < [llength $items]} {
      set item [lindex $items $index]
      foreach col [$t cget -columns] val $values {
        $t set $item $col $val
      }
    } else {
      while {[llength $items] <= $index} {
        set item [$t insert {} end]
        lappend items $item
      }
      foreach col [$t cget -columns] val $values {
        $t set $item $col $val
      }
    }
    event generate $t <<TVItemsChanges>>
  }

  proc upsertRows {t valueslist index} {
    foreach values $valueslist {
      set items [$t children {}]
      if {$index < [llength $items]} {
        set item [lindex $items $index]
        foreach col [$t cget -columns] val $values {
          $t set $item $col $val
        }
      } else {
        while {[llength $items] <= $index} {
          set item [$t insert {} end]
          lappend items $item
        }
        foreach col [$t cget -columns] val $values {
          $t set $item $col $val
        }
      }
      incr index
    }
    event generate $t <<TVItemsChanges>>
  }

  proc upsertCell {t col value index} {
    set items [$t children {}]
    if {$index < [llength $items]} {
      set item [lindex $items $index]
      $t set $item $col $value
    } else {
      while {[llength $items] <= $index} {
        set item [$t insert {} end]
        lappend items $item
      }
      $t set $item $col $value
    }
    event generate $t <<TVItemsChanges>>
  }

  proc upsertCells {t col values index} {
    foreach value $values {
      set items [$t children {}]
      if {$index < [llength $items]} {
        set item [lindex $items $index]
        $t set $item $col $value
      } else {
        while {[llength $items] <= $index} {
          set item [$t insert {} end]
          lappend items $item
        }
        $t set $item $col $value
      }
      incr index
    }
    event generate $t <<TVItemsChanges>>
  }

  proc deleteAllRows {t} {
    foreach item [$t children {}] {
      $t delete $item
    }
  }

  proc deleteRow {t index} {
    set item [lindex [$t children {}] $index]
    if { $item eq "" } {
      return 0
    }
    $t delete $item
    event generate $t <<TVItemsChanges>>
    return 1
  }

  proc deleteRows {t indices} {
    set items [$t children {}]
    set sortedIndices [lsort -integer -decreasing $indices]
    foreach index $sortedIndices {
      if {$index < [llength $items]} {
        set item [lindex $items $index]
        $t delete $item
      }
    }
    event generate $t <<TVItemsChanges>>
  }

  proc deleteCell {t col  index} {
    return [updateCell $t $col "" $index]
  }

  proc deleteCells {t col indices} {
    set items [$t children {}]
    foreach index $indices {
      if {$index < [llength $items]} {
        set item [lindex $items $index]
        $t set $item $col ""
      }
    }
  }
  proc getRow {t index} {
    set item [lindex [$t children {}] $index]
    if { $item ne "" } {
      set rowData {}
      foreach col [$t cget -columns] {
        lappend rowData  [$t set $item $col]
      }
      return  $rowData
    }
    return
  }
  proc getAllRows {t} {
    set rowsData {}
    foreach item [$t children {}] {
      set rowData {}
      foreach col [$t cget -columns] {
        lappend rowData [$t set $item $col]
      }
      lappend rowsData $rowData
    }
    return $rowsData
  }
  proc getRows {t indices} {
    set rowsData {}
    set items [$t children {}]

    foreach index $indices {
      if {$index < [llength $items]} {
        set item [lindex $items $index]
        set rowData {}
        foreach col [$t cget -columns] {
          lappend rowData [$t set $item $col]
        }
        lappend rowsData $rowData
      }
    }

    return $rowsData
  }

  proc getCell {t col index} {
    set item [lindex [$t children {}] $index]
    if { $item ne "" } {
      return [$t set $item $col]
    }
    return ""
  }
  proc getAllCells {t col} {
    set cellsData {}
    foreach item [$t children {}] {
      lappend cellsData [$t set $item $col]
    }
    return $cellsData
  }
  proc getCells {t col indices} {
    set cellsData {}
    set items [$t children {}]

    foreach index $indices {
      if {$index < [llength $items]} {
        set item [lindex $items $index]
        lappend cellsData [$t set $item $col]
      }
    }

    return $cellsData
  }

  # example data for table
  proc generateLargeList {numEntries numColumns} {
    set largeList {}

    for {set i 1} {$i <= $numEntries} {incr i} {
      set entry [list]
      for {set j 1} {$j <= $numColumns} {incr j} {
        lappend entry "Item_${i}_${j}"
      }
      lappend largeList $entry
    }

    return $largeList
  }
}

#The dictionary is constructed in such a way that each node stores
#the entire "tree extent" of its children.
#This allows the global index to be calculated efficiently.
namespace eval tvlib {
  proc buildChildCountDict {tree} {
    set childCountDict {}
    foreach item [$tree children {}] {
      set count [countChildren $tree $item]
      dict set childCountDict $item $count
    }
    return $childCountDict
  }

  proc countChildren {tree item} {
    set count 1  ;# Zählt sich selbst
    foreach child [$tree children $item] {
      incr count [countChildren $tree $child]
    }
    return $count
  }
  proc getGlobalIndexFromDict {tree targetItem childCountDict} {
    set target [$tree parent $targetItem]
    puts $target
    set index 0
    return [recursiveIndexSearch $tree {} $target $childCountDict $index]
  }

  proc recursiveIndexSearch {tree parent targetItem childCountDict idx} {
    foreach item [$tree children $parent] {
      if {$item eq $targetItem} {
        return $idx
      }
      incr idx
      set result [recursiveIndexSearch $tree $item $targetItem $childCountDict $idx]
      if {$result != -1} {
        return $result
      }
      incr idx [expr {[dict get $childCountDict $item] - 1}]
    }
    return -1 ;# Item nicht gefunden
  }
}