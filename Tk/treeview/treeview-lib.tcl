#! /usr/bin/env tclsh

# 20240817
# treeview-lib.tcl

# https://core.tcl-lang.org/tk/tktview/2a6c62afd9

package require struct::list
# ::struct::list flatten is used in the proc showVisibleItems
package require dicttool
# dict is_dict is used in the procs dict2tvtree, collectKeys, and collectKeysPoint

# a. Import and export of dict and tree structures
# b. Band (stripe) functionality for treeview rows
# c. Additional treeview utility procs
# d. Additional key management procs
# e. Example data
# f. Searching and opening nodes in treeview
# g. Creating a new treeview configured as a table with options for adding, updating, upserting data etc.
# h. helper procs exppandAll, collapseAll, isLeaf
# i. global indeex

################################
# a. Import and export of dict and tree structures
################################
namespace eval tvlib {
  # Checks if the first elements of all sublists are equal
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

  # Converts a dictionary into a tree structure
  # Special case: if the key is ":", the value is treated as a list
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

  # Recursively converts a tree structure into a dictionary
  # Uses custom interpretation with the same keys
  proc tvtree2dict {tree node} {
    set result {}
    # To handle equal keys
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
        } else {
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
# b. Band (stripe) functionality for treeview rows
################
# tvlib::bandInit $tree
# tvlib::band $tree
## Use event:
# tvlib::band_event $tree
#
# For striped bands, see at:
# https://wiki.tcl-lang.org/page/dgw%3A%3Atvmixins
# https://chiselapp.com/user/dgroth/repository/tclcode/index
# https://wiki.tcl-lang.org/page/Tile+Table
# https://www.tcl.tk/man/tcl9.0/TkCmd/ttk_treeview.html#M100
namespace eval tvlib {

  # Recursively apply alternating background colors to rows
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

  # Initialize banding with specific colors
  proc bandInit {tree {color0 #FFFFFF} {color1 #E0E0E0}} {
    $tree tag configure band0 -background $color0
    $tree tag configure band1 -background $color1
    bind $tree <<TVItemsChanges>> [list [namespace current]::band $tree]
  }

  # Trigger a banding event
  proc bandEvent {tree} {
    event generate $tree <<TVItemsChanges>> -data [$tree selection]
  }
}

#########################
# c. Additional treeview utility procs
#########################
namespace eval tvlib {

  # Recursively calculates the total number of nodes in the tree
  proc treesize {tree {p {}}} {
    set size 0
    foreach c [$tree children $p] {
      incr size [llength $c]
      incr size [treesize $tree $c]
    }
    return $size
  }

  # Recursively calculates the depth of the tree
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

  # Calculates the depth of a specific item in the tree
  proc itemdepth {tree item} {
    set depth 0
    while {$item ne ""} {
      set item [$tree parent $item]
      incr depth
    }
    return $depth
  }

  # Converts the tree structure into a nested dictionary
  proc tv2list {tree {parent {}}} {
    set data {}
    foreach c [$tree children $parent] {
      dict set data $c [tv2list $tree $c]
    }
    return $data
  }
}

####################
# d. Additional key management procs
####################
namespace eval tvlib {

  # Recursively collect all keys from a dictionary
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

  # Recursively collect all keys from a dictionary with full paths using dots
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

  # Extract the last parts (tails) of the keys separated by dots
  proc extractTails {keys} {
    set tails {}
    foreach key $keys {
      set parts [split $key "."]
      lappend tails [lindex $parts end]
    }
    return $tails
  }

  # Extract the first parts (heads) of the keys separated by dots
  proc extractHeads {keys} {
    set heads {}
    foreach key $keys {
      set parts [split $key "."]
      lappend heads [lindex $parts 0]
    }
    return [uniqueList2 $heads]
  }

  # Returns a list of unique elements (used in extractHeads)
  proc uniqueList2 {list} {
    set dict {}
    foreach item $list {
      dict set dict $item ""
    }
    dict keys $dict
  }

  # Expands a list by separating the key-value pairs
  # Used in tvtree2dict
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
# e. Example data
# Usage: tvlib::testCreateTreeStruct $tree 4
#####################################
namespace eval tvlib {
  variable exampleDatas

  # e.1 Example data dictionary
  dict set exampleDatas abc12 {a1 {b11 {a11 {b1111 c1 b1112 c1}} b12 {a12 {b1211 c1 b1212 c1}}} a2 {b21 {a21 {b2111 c1 b2112 c1}} b22 {a22 {b2211 c1 b2212 c1}}}}
  dict set exampleDatas person {person  {name "John Doe" age 30.8 address {street "123 Main St" city "Anytown"}  employees {  {name "Alice Smith" } {name "Bob Smith"} {name "John Good"} {name "Jane Good"}} } job {title "Developer" company "Works"}}

  # e.2 Two procs for generating test data for tree structures
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

  # Collects and returns Tcl/Tk environment information in a dictionary
  proc infotcltk {} {
    lappend infodata hostname [info hostname]
    lappend infodata library [info library]
    lappend infodata nameofexecutable [info nameofexecutable]
    lappend infodata patchlevel [info patchlevel]
    lappend infodata sharedlibextension [info sharedlibextension]
    lappend infodata tclversion [info tclversion]
    dict set data info $infodata

    dict set data tm [tcl::tm::path list]

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

    # Add namespace information to the data dictionary
    dict set data namespace [listns]

    set ns ::
    set pat [set ns]::*

    foreach proc [lsort [info procs $pat]] {
      dict lappend data procs [list : $proc]
    }

    foreach command [lsort [info commands $pat]] {
      dict lappend data commands [list : $command]
    }

    foreach function [lsort [info functions $pat]] {
      dict lappend data functions [list : $function]
    }

    foreach var [info vars $pat] {
      if {[array exists $var]} {
        dict lappend date array $var [list {*}[array get $var]]
      } else {
        dict lappend date variable $var [list [set $var]]
      }
    }
    dict set data vars $date

    return $data
  }

  # Generate example data for the table with a specified number of entries and columns
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



  # Recursively lists namespaces, commands, functions, and variables
  proc listns {{parentns ::}} {
    set result [dict create]
    dict set result commands [listnscommands $parentns]
    dict set result functions [listnsfunctions $parentns]
    dict set result procs [listnsprocs $parentns]
    dict set result vars [listnsvars $parentns]

    foreach ns [namespace children $parentns] {
      dict set result $ns [listns $ns]
    }
    return $result
  }

  # List procedures in the specified namespace
  proc listnsprocs {ns} {
    set result ""
    foreach proc [lsort [info procs ${ns}::*]] {
      lappend result [list ":" $proc]
    }
    return $result
  }

  # List commands in the specified namespace
  proc listnscommands {ns} {
    set result ""
    foreach command [lsort [info commands ${ns}::*]] {
      lappend result [list ":" $command]
    }
    return $result
  }

  # List functions in the specified namespace
  proc listnsfunctions {ns} {
    set result ""
    foreach function [lsort [info functions ${ns}::*]] {
      lappend result [list ":" $function]
    }
    return $result
  }

  # List variables in the specified namespace, including arrays
  proc listnsvars {ns} {
    set date ""
    foreach var [lsort [info vars ${ns}::*]] {
      if {[array exists $var]} {
        dict set date array $var [list {*}[array get $var]]
      } else {
        if {[catch {set $var} msg]} {
          puts "catch error: proc listnsvar :: $var"
          dict set date variable $var [list catch_error]
        } else {
          dict set date variable $var [list ":" [list [set $var]]]
        }
      }
    }
    dict set data variablen $date
    return $data
  }
}

#########################
# f. Searching and opening nodes in treeview
#########################
namespace eval tvlib {

  # Open all parent nodes of the specified item
  proc openParentNodes {tree item} {
    set parent [$tree parent $item]
    if {$parent ne ""} {
      $tree item $parent -open true
      openParentNodes $tree $parent
    }
  }

  # Find and return a list of all visible items matching the search string
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

  # Recursively search for matching visible children
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

#########################
# g. Creating a new treeview configured as a table
#########################
namespace eval tvlib {

  # Create a new treeview widget configured as a table
  # colname anchor minwidth stretch width
  proc newTable {w cols} {
    # colsnames for create treeview widget
    foreach col $cols {
      lassign $col colname anchor minwidth stretch width
      lappend colnames $colname
    }
    set frt [ttk::frame $w.frt]
    # Create the treeview with headings only, and define column names
    set tree [ttk::treeview $frt.tree -show headings -columns $colnames\
    -yscrollcommand [list $frt.vsb set] -selectmode browse]
    set vsb [::ttk::scrollbar $frt.vsb -orient vertical -command [list $tree yview]]

    # Set the text display for column headers and options for columns
    foreach col $cols {
      lassign $col colname anchor minwidth stretch width
      $tree heading $colname -text $colname
      if {$anchor ne {} } {
        $tree column $colname -anchor $anchor
      }
      if {$minwidth ne {} } {
        $tree column $colname -minwidth $minwidth
      }
      if {$stretch ne {} } {
        $tree column $colname -stretch $stretch
      }
      if {$width ne {} } {
        $tree column $colname -width $width
      }
    }

    pack $frt -expand 1 -fill both

    pack $vsb -expand 0 -fill y -side right
    pack $tree -expand 1 -fill both
    return $tree
  }

  # Add a new row to the table
  proc addRow {t {values ""}} {
    set item [$t insert {} end]
    foreach col [$t cget -columns] val $values {
      $t set $item $col $val
    }
    event generate $t <<TVItemsChanges>>
  }

  # Add multiple rows to the table
  proc addRows {t {valueslist ""}} {
    foreach values $valueslist {
      set item [$t insert {} end]
      foreach col [$t cget -columns] val $values {
        $t set $item $col $val
      }
    }
    event generate $t <<TVItemsChanges>>
  }

  # Add a single cell to the table
  proc addCell {t col value {pos end}} {
    set item [$t insert {} $pos]
    $t set $item $col $val
    event generate $t <<TVItemsChanges>>
  }

  # Add multiple cells to the table
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

  # Update a specific row in the table
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

  # Update multiple rows in the table
  proc updateRows {t values index} {
    foreach val $values {
      updateRow $t $val $index
      incr index
    }
  }

  # Update a specific cell in the table
  proc updateCell {t col value index} {
    set item [lindex [$t children {}] $index]
    if { $item eq "" } {
      return 0
    }
    $t set $item $col $value
    return 1
  }

  # Update multiple cells in the table
  proc updateCells {t col values index} {
    foreach val $values {
      updateCell $t $col $val $index
      incr index
    }
  }

  # Insert or update a specific row in the table
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

  # Insert or update multiple rows in the table
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

  # Insert or update a specific cell in the table
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

  # Insert or update multiple cells in the table
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

  # Delete all rows in the table
  proc deleteAllRows {t} {
    foreach item [$t children {}] {
      $t delete $item
    }
  }

  # Delete a specific row in the table
  proc deleteRow {t index} {
    set item [lindex [$t children {}] $index]
    if { $item eq "" } {
      return 0
    }
    $t delete $item
    event generate $t <<TVItemsChanges>>
    return 1
  }

  # Delete multiple rows in the table based on their indices
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

  # Delete a specific cell in the table
  proc deleteCell {t col index} {
    return [updateCell $t $col "" $index]
  }

  # Delete multiple cells in the table based on their indices
  proc deleteCells {t col indices} {
    set items [$t children {}]
    foreach index $indices {
      if {$index < [llength $items]} {
        set item [lindex $items $index]
        $t set $item $col ""
      }
    }
  }

  # Retrieve data from a specific row in the table
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

  # Retrieve data from all rows in the table
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

  # Retrieve data from multiple rows based on their indices
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

  # Retrieve data from a specific cell in the table
  proc getCell {t col index} {
    set item [lindex [$t children {}] $index]
    if { $item ne "" } {
      return [$t set $item $col]
    }
    return ""
  }

  # Retrieve data from all cells in a specific column
  proc getAllCells {t col} {
    set cellsData {}
    foreach item [$t children {}] {
      lappend cellsData [$t set $item $col]
    }
    return $cellsData
  }

  # Retrieve data from multiple cells based on their indices
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

}

# h. helper procs
################################
namespace eval tvlib {

  # Expand all nodes in the tree
  proc expandAll {tree item} {
    # Expand the specified item
    $tree item $item -open true

    # Loop through all children of the item
    foreach child [$tree children $item] {
      # Recursive call to expand all children
      expandAll $tree $child
    }
  }

  # Collapse all nodes in the tree
  proc collapseAll {tree item} {
    # Collapse the specified item
    $tree item $item -open false

    # Loop through all children of the item
    foreach child [$tree children $item] {
      # Recursive call to collapse all children
      collapseAll $tree $child
    }
  }

  # Check if the specified item is a leaf (no children)
  proc isLeaf {tree item} {
    if {[llength [$tree children $item]] == 0} {
      return 1
    } else {
      return 0
    }
  }

  # Find the previous non-leaf item relative to the specified item
  proc findPreviousNonLeaf {tree item} {
    set prevItem [$tree prev $item]
    set abst 1
    while {$prevItem ne ""} {
      incr abst
      if {![isLeaf $tree $prevItem]} {
        return [list $prevItem $abst]
      }
      set prevItem [$tree prev $prevItem]
    }
    if {$prevItem eq "" } {
      set prevItem [$tree parent $item]
    }
    return [list $prevItem $abst]
  }
}

# i. global index
# The dictionary is constructed in such a way that each node stores
# the entire "tree extent" of its children.
# This allows the global index to be calculated efficiently.
namespace eval {tvlib} {
  variable rowsparentidx
  set rowsparentidx {}

  # Build a dictionary that stores the child count for each node
  proc buildChildCountDict {tree {depth 1}} {
    variable rowsparentidx
    set rowsparentidx [addChildrenToDict $tree {} $depth]
    return 1
  }

  proc getDict {} {
    variable rowsparentidx
    return $rowsparentidx
  }

  # Recursively add child nodes and their counts to the dictionary
  proc addChildrenToDict {tree parent {depth 1}} {
    set dictRef {}
    set childDepth [expr {$depth + 1}]
    foreach item [$tree children $parent] {
      set count [countChildren $tree $item]
      dict set dictRef $depth $item  count $count
      dict set dictRef $depth $item  cdepth [addChildrenToDict $tree $item $childDepth]
    }
    return $dictRef
  }

  # Count the number of children for a given item
  proc countChildren {tree item} {
    set count 1  ;# Counts itself
    foreach child [$tree children $item] {
      incr count [countChildren $tree $child]
    }
    return $count
  }

  # Get the keys from the rowsparentidx dictionary at depth 0
  proc keysrowsidx {} {
    variable rowsparentidx
    set keys [dict keys [dict get $rowsparentidx 0]]
    return $keys
  }



  # Calculate the row index based on the items and their depth
  proc rowindexCount {items depth} {
    variable rowsparentidx
    set rowindex 0
    foreach item $items {
      set rowindex [expr {$rowindex + [dict get $rowsparentidx $depth $item count]}]
    }
    return $rowindex
  }

  proc findRowFromDict {tree item {rowindex 0}} {
    variable rowsparentidx
    set rowindex 0

    if {[tvlib::isLeaf $tree $item] } {
      # Find the previous non-leaf item and adjust the item and rowindex
      set previousNonLeafList [tvlib::findPreviousNonLeaf $tree $item]
      set item [lindex $previousNonLeafList 0]
      set rowindex  [expr {$rowindex + [lindex $previousNonLeafList 1]}]
    }

    if {[$tree children $item] eq ""} {
      set result [$tree index $item]
      set  rowindex  [expr {$rowindex +  [$tree index $item]}]
    } else {
      set result $item
    }
    set index 0
    set currentItem $item

    # Traverse upwards to find all parent nodes
    while { $currentItem ne "" } {
      set parent [$tree parent $currentItem]
      lappend result $parent
      set currentItem $parent
    }
    set result [lrange $result 0 end-1]
    set currentItem [lindex $result end]

    # Find previous siblings at the same depth
    set prevroot [list]
    while { $currentItem ne "" } {
      set prev [$tree prev $currentItem]
      lappend prevroot $prev
      set currentItem $prev
    }

    # Calculate the row index based on previous siblings
    set rowindex [expr {$rowindex + [rowindexCount [lrange $prevroot 0 end-1] 1]}]


    # Look up the depth-based dictionary and adjust the row index
    set dvar [dict get $rowsparentidx 1 [lindex $result end] cdepth]
    if {$item in [dict keys [dict get $rowsparentidx 1]]} {
      set key -10

    } else {
      set key 2
    }

    # Traverse the dictionary to accumulate row counts
    while {[dict exists $dvar $key]} {
      dict for {key value} $dvar {
        foreach  k  [dict keys [dict get $value]] {
          if {$k eq $item} {
            set rowindex [expr {$rowindex + 1}]
            set key -10
            break
          } else {
            set rowindex [expr {$rowindex + [dict get $value $k count]}]
            set key -10

          }
        }
        #incr key
      }
    }
    return $rowindex
  }
}
