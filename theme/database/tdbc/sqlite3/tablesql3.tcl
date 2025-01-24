#! /usr/bin/env tclsh

# 20250124
# table with notbooks an db table and views

package require Tk
package require tablelist_tile

package require tdbc::sqlite3

set dirname [file dirname [info script]]

#set db [tdbc::sqlite3::connection create db chinook.db]
#source [file join $dirname lib sql-infodb-proc-0.1.tcl]

package require Tk
package require tablelist_tile
package require tdbc::sqlite3

# Datenbankverbindung herstellen
set dirname [file dirname [info script]]
set db [tdbc::sqlite3::connection create db [file join $dirname "my-database.sqlite3"]]

#20250124
proc infoDB {db} {
  set tableStruct [dict create]

  # Fetch the list of databases attached to the current SQLite connection
  set dbListStmt [$db prepare "PRAGMA database_list"]
  $dbListStmt execute
  set dbList {}
  $dbListStmt foreach dbRow {
    # Append each database name to the list
    lappend dbList [dict get $dbRow name]
  }
  $dbListStmt close
  dict set tableStruct databases $dbList
  
  # Fetch the names of all tables in the main database
  set stmt [$db prepare "SELECT name FROM sqlite_master WHERE type='table'"]
  $stmt execute
  set tableList {}
  $stmt foreach row {
    # Append each table name to the list
    lappend tableList [dict get $row name]
  }
  $stmt close
  # Set the table list in the resulting dictionary
  
  # Fetch the structure and indexes for each table
  foreach tableName $tableList {
    set columnList [list]
    set columnStmt [$db prepare "PRAGMA table_info($tableName)"]
    $columnStmt execute
    $columnStmt foreach column {
      # Create a dictionary containing column attributes
      set colInfo [dict create]
      dict set colInfo [dict get $column name] type [dict get $column type]
      dict set colInfo [dict get $column name] notnull [dict get $column notnull]
      dict set colInfo [dict get $column name] pk [dict get $column pk]
      # Append column information to the column list
      lappend columnList {*}$colInfo
    }
    # Add the column list to the table structure
    dict set tableStruct tablelist $tableName $columnList
    $columnStmt close
    
    # Fetch index information for the table
    set indexList [list]
    set indexStmt [$db prepare "PRAGMA index_list($tableName)"]
    $indexStmt execute
    $indexStmt foreach index {
      # Create a dictionary containing index attributes
      set indexInfo [dict create]
      dict set indexInfo [dict get $index name] name [dict get $index name]
      dict set indexInfo [dict get $index name] unique [dict get $index unique]
      dict set indexInfo [dict get $index name] origin [dict get $index origin]
      # Append index information to the index list
      lappend indexList {*}$indexInfo
    }
    # Add the index list to the table structure
    dict set tableStruct indexlist $tableName $indexList
    $indexStmt close
  }

  # Fetch the names of all views in the main database
  set stmt [$db prepare "SELECT name FROM sqlite_master WHERE type='view'"]
  $stmt execute
  set viewList {}
  $stmt foreach row {
    # Append each view name to the list
    lappend viewList [dict get $row name]
  }
  $stmt close

  # Fetch the structure and indexes for each view
  foreach viewName $viewList {
    set columnList [list]
    set columnStmt [$db prepare "PRAGMA table_info($viewName)"]
    $columnStmt execute
    $columnStmt foreach column {
      # Create a dictionary containing column attributes
      set colInfo [dict create]
      dict set colInfo [dict get $column name] type [dict get $column type]
      dict set colInfo [dict get $column name] notnull [dict get $column notnull]
      dict set colInfo [dict get $column name] pk [dict get $column pk]
      # Append column information to the column list
      lappend columnList {*}$colInfo
    }
    # Add the column list to the view structure
    dict set tableStruct viewlist $viewName $columnList
    $columnStmt close
    
    # Fetch index information for the view (no indices are expected for views)
    set indexList [list]
    set indexStmt [$db prepare "PRAGMA index_list($tableName)"]
    $indexStmt execute
    $indexStmt foreach index {
      # Create a dictionary containing index attributes
      set indexInfo [dict create]
      dict set indexInfo [dict get $index name] name [dict get $index name]
      dict set indexInfo [dict get $index name] unique [dict get $index unique]
      dict set indexInfo [dict get $index name] origin [dict get $index origin]
      # Append index information to the index list
      lappend indexList {*}$indexInfo
    }
    # Add the index list to the view structure
    dict set tableStruct indexlist $viewName $indexList
    $indexStmt close
  }

  # Return the complete structure of the database
  return $tableStruct
}

# Tablelist-Widget erstellen
proc tblCreate {w cols suffix} {
  set frt  $w.frt_$suffix
  frame $frt
  # Create table
  set tbl [tablelist::tablelist $frt.tbl -columns $cols -width 100 \
   -xscroll [list $frt.h set] -yscroll [list $frt.v set] -labelcommand tablelist::sortByColumn \
    -stripebackground #f0f0f0 -selectmode multiple -exportselection false]

  $tbl columnconfigure 0 -sortmode dictionary

  # add scrollbar
  set vsb [scrollbar $frt.v -orient vertical -command [list $tbl yview]]
  set hsb [scrollbar $frt.h -orient horizontal -command [list $tbl xview]]

  # Add  frames
  set frb [frame $w.frb_$suffix]
  pack $frb -fill x -side bottom -expand 0
  pack $frt -fill both -side top -expand true

  pack $vsb -side right -fill y -expand 0
  pack $hsb -side bottom -fill x -expand 0
  pack $tbl -fill both -expand true

  # add buttons
  set btnone [button $frb.one -text "Button One" -command [list tk_messageBox -message "Tbl: $tbl" -type ok]]
  set btntwo [button $frb.two -text "Button Two" -command [list tblcallback $tbl ]]

  pack $btnone $btntwo -side left

  # bind
  bind [$tbl bodytag] <Double-1> [list tk_messageBox -message "Tbl: $tbl\nW %W" -type ok]
  bind [$tbl bodytag] <Key-a> [list tk_messageBox -message \
    "Tbl: $tbl\nW %W\nx: %x y:%y\nX:%X Y:%Y\n [join "%k %i %s %A %K %M %N %R %S %T" \n]" -type ok]
  bind [$tbl bodytag] <Key-F4> [list $btntwo invoke]

  return $tbl
}

proc tblcallback {tbl args} {
  puts "$tbl $args"
  puts [info frame 1]
  puts [info frame -1]
  puts [info frame -2]
}

proc tblInsert {tbl rows} {
  $tbl insertlist end $rows
}

proc sqlselectdb {dbconn sqlstmt query_values} {
  set stmt [$dbconn prepare $sqlstmt]
  set rows {}
  try {
    set res [$stmt execute $query_values]
    try {
      while {[$res nextlist row]} {
        lappend rows $row
      }
    } finally {
      $res close
    }
  } finally {
    $stmt close
  }
  return $rows
}

proc generateCols {tableInfo} {
  set cols {}
  set liste [list INTEGER]
  foreach {colName colAttrs} $tableInfo {
    if {[dict get $colAttrs type] in $liste} {
      set dir right
    } else {
      set dir left
    }
    lappend cols 0 $colName $dir
  }
  return $cols
}

#create ttbl
# cols: width name dir

proc datatable {tblname db {w toplevel}} {
  set cols [generateCols [dict get  [infoDB db] tablelist $tblname]]
  if {$w eq "toplevel"} {
    set top [toplevel .top${tblname}]
  } else {
    set top [ttk::frame $w.f${tblname}]
    $w  add $top -text $tblname
  }

  set tbl [tblCreate $top $cols $tblname]

  # insert data
  set sqlstmt [subst -nocommands {SELECT * FROM $tblname}]
  #set query_values [dict create tblname $tblname]
  set query_values {}
  set rows [sqlselectdb db $sqlstmt $query_values]
  tblInsert $tbl $rows
}
proc dataview {tblname db {w toplevel}} {
  set cols [generateCols [dict get  [infoDB db] viewlist $tblname]]
  if {$w eq "toplevel"} {
    set top [toplevel .top${tblname}]
  } else {
    set top [ttk::frame $w.f${tblname}]
    $w  add $top -text $tblname
  }

  set tbl [tblCreate $top $cols $tblname]

  # insert data
  set sqlstmt [subst -nocommands {SELECT * FROM $tblname}]
  #set query_values [dict create tblname $tblname]
  set query_values {}
  set rows [sqlselectdb db $sqlstmt $query_values]
  tblInsert $tbl $rows
}
proc tabChanged {w args} {
  puts $args
  puts [$w index current]
  puts [$w tab current -text]
  puts [$w select]
}


pack [ttk::notebook .nb] -side top -expand 1 -fill both
pack [text .text -height 10] -side top -expand 1 -fill both
foreach tblname [dict keys [dict get  [infoDB db] tablelist]] {
  datatable $tblname  db .nb
}
# Add views to the notebook
#puts  [dict get [infoDB db] viewlist ]

foreach viewname [dict keys [dict get [infoDB db] viewlist]] {
puts $viewname 
dataview $viewname db .nb
}

ttk::notebook::enableTraversal .nb

bind .nb <<NotebookTabChanged>> [list tabChanged %W]
#puts infoDb
#puts [dict keys [infoDB db]]
#puts [dict keys [dict get  [infoDB db] tablelist]]
#puts [dict keys [dict get  [infoDB db] tablelist artikel]]
#puts [dict get  [infoDB db] tablelist artikel]




