#!/usr/bin/env tclsh

package require Tk

namespace eval tvlib {
  # use of ttk::treeview to build a table
  # proc newTable
  # creates a new treeview configured as a table
  # new Row, Rows, Cell, Cells
  # update Row, Rows, Cell, Cells
  # upsert Row, Rows, Cell, Cells
  # delete Rows, Cells

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

  proc newRow {t {values ""}} {
    set item [$t insert {} end]
    foreach col [$t cget -columns] val $values {
      $t set $item $col $val
    }
  }

  proc newRows {t {valList ""}} {
    foreach values $valList {
      newRow $t $values
    }
  }
  proc newCell {t col value {pos end}} {
    set item [$t insert {} $pos]
    $t set $item $col $val
  }
  proc newCells {t col values {pos end}} {
    foreach val $values {
      set item [$t insert {} $pos]
      $t set $item $col $val
      incr pos
    }
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
  }

  proc upsertRows {t  values index} {
    foreach val $values {
      upsertRow $t $val $index
      incr index
    }
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
  }

  proc upsertCells {t col values index} {
    foreach val $values {
      upsertCell $t $col $val $index
      incr index
    }
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


}

# example
# -- create a new table
set table [tvlib::newTable . [list col1 col2]]
# -- set values for all columns
tvlib::newRow $table [list 1]
tvlib::newRow $table [list 2]
# -- add an empty row
tvlib::newRow $table
tvlib::newRow $table [list "value one"]
tvlib::newRows $table [list [list 3] [list 4] [list 5]]
tvlib::newCells $table  1 w 1
update
after 5000
tvlib::newCells $table  1 [list 1 2 3] 1
puts [tvlib::updateCell $table 1 m 8]
puts [tvlib::updateCell $table 1 x 9]
tvlib::updateCells $table 0 [list 0 1 2 3 4 5 6 7 8] 2
tvlib::upsertCells $table 1 [list 0 1 2 3 4 5 6 7 8] 2
tvlib::upsertCell $table 0 k 15
tvlib::deleteRows $table [list 1 3]
puts [tvlib::updateRow $table [list "new value 1" "new value 2"] 2]
tvlib::upsertRow $table [list "upsert value 1" "upsert value 2"] 5
tvlib::upsertRows $table [list  [list "upsert value 3" "upsert value 4"] [list "upsert value 5" "upsert value 6"] ] 5
update
after 5000
tvlib::updateRows $table [list  [list "update value 7" "update value 8"] [list "update value 9" "update value 10"] ] 5