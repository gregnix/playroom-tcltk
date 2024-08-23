
#sql-std-proc-0.2.tcl

#sqlcmdDQL für select
#sqlcmdDML für update,insert, delete und Transactionen
# Spezielle Prozedur für DDL-Operationen (CREATE, ALTER, DROP)
proc sqltrim sqltext {
  return [string trim [string map {"\n" ""} $sqltext]]
}

# Verbesserung der Rückgabestruktur in sqlcmdDQL
proc sqlcmdDQL {dbconn sqlvar {query_values {} }} {
  set data [dict create]
  set stmt [$dbconn prepare $sqlvar]
  try {
    set res [$stmt execute $query_values]
    try {
      set columns [$res columns]
      dict set data columns $columns
      set rows []
      while {[$res nextlist row]} {
        lappend rows $row
      }
      dict set data rows $rows
    } finally {
      $res close
    }
  } finally {
    $stmt close
  }
  return $data
}


# mit Transaction
proc sqlcmdDML {dbconn sqlvar {query_values {}}} {
    set rueckgabe [dict create]
    $dbconn begintransaction
    set stmt [$dbconn prepare $sqlvar]
    try {
        set res [$stmt execute $query_values]
        if {[info exists res] && [info object isa object $res] && [lsearch -exact [info object methods $res] "changes"] != -1} {
            set changes [$res changes]  ;# Anzahl der durch die Transaktion betroffenen Zeilen
            dict set rueckgabe affected_rows $changes
        }
        $dbconn commit
        dict set rueckgabe status "success"
    } on error {msg options} {
        $dbconn rollback
        dict set rueckgabe status "error"
        dict set rueckgabe message $msg
        dict set rueckgabe options $options
    } finally {
        if {[info exists stmt]} {
            $stmt close
        }
    }
    return $rueckgabe
}

# Ohne Transaction, aber mit konsistenter Fehlerbehandlung
# Erweiterte Rückgabestruktur in sqlcmdDML
proc sqlcmdDMLwo {dbconn sqlvar {query_values {}}} {
    set rueckgabe [dict create]
    set stmt [$dbconn prepare $sqlvar]
    try {
        set res [$stmt execute $query_values]
        if {[info exists res] && [info object isa object $res] && [lsearch -exact [info object methods $res] "changes"] != -1} {
            set changes [$res changes]  ;# Anzahl der durch die Transaktion betroffenen Zeilen
            dict set rueckgabe affected_rows $changes
        }
        dict set rueckgabe status "success"
    } on error {msg options} {
        dict set rueckgabe status "error"
        dict set rueckgabe message $msg
        dict set rueckgabe options $options
    } finally {
        if {[info exists stmt]} {
            $stmt close
        }
    }
    return $rueckgabe
}


# Spezielle Prozedur für DDL-Operationen (CREATE, ALTER, DROP)
proc sqlcmdDDL {dbconn sqlvar {query_values {} }} {
    set rueckgabe [dict create]
    set stmt [$dbconn prepare $sqlvar]
    try {
        $stmt execute $query_values
        dict set rueckgabe status "success"
    } on error {msg options} {
        dict set rueckgabe status "error"
        dict set rueckgabe message $msg
        dict set rueckgabe options $options
    } finally {
        $stmt close
    }
    return $rueckgabe
}



proc fetchTableStructure {db} {
    set tableStruct [dict create]

    # Fetch database list
    set dbListStmt [$db prepare "PRAGMA database_list"]
    $dbListStmt execute
    set dbList {}
    $dbListStmt foreach dbRow {
        lappend dbList [dict get $dbRow name]
    }
    $dbListStmt close
    dict set tableStruct databases $dbList

    # Fetch table names
    set stmt [$db prepare "SELECT name FROM sqlite_master WHERE type='table'"]
    $stmt execute
    set tableList {}
    $stmt foreach row {
        lappend tableList [dict get $row name]
    }
    $stmt close

    # Fetch structure and indexes of each table
    foreach tableName $tableList {
        set columnList [list]
        set columnStmt [$db prepare "PRAGMA table_info($tableName)"]
        $columnStmt execute
        $columnStmt foreach column {
            set colInfo [dict create \
                name [dict get $column name] \
                type [dict get $column type] \
                notnull [dict get $column notnull] \
                pk [dict get $column pk]]
            lappend columnList $colInfo
        }
        $columnStmt close

        # Fetch index info
        set indexList [list]
        set indexStmt [$db prepare "PRAGMA index_list($tableName)"]
        $indexStmt execute
        $indexStmt foreach index {
            set indexInfo [dict create \
                name [dict get $index name] \
                unique [dict get $index unique] \
                origin [dict get $index origin]]
            lappend indexList $indexInfo
        }
        $indexStmt close

        dict set tableStruct $tableName [dict create columns $columnList indexes $indexList]
    }

    # Output the complete structure
    #puts $tableStruct
    return $tableStruct
}
proc displayTableStructure {dbconn outputWidget tbl} {
    # Fetch the table structure
    catch {
        set result [fetchTableStructure $dbconn]
    } errMsg

    # Check for errors
    if {[dict exists $errMsg -errorcode]} {
        $outputWidget insert end "Error fetching table structure: $errMsg(-errorinfo)\n"
        return
    }

    # Prepare a formatted string for output
    #set formattedResult [formatTableStructureForDisplay $result]

    # Insert the formatted result into the widget
    #$outputWidget insert end $formattedResult
    tbl::dict2tbltree $tbl root $result
}

proc formatTableStructureForDisplay {tableStruct} {
    set displayText ""
    if {[dict size $tableStruct] == 0} {
        return "No tables found in the database."
    }

    foreach db [dict keys $tableStruct] {
        append displayText "Database: $db\n"
        set dbTables [dict get $tableStruct $db]

        # Check if dbTables is actually a dictionary
        if {![info exists dbTables] || ![dict is_dict $dbTables]} {
            append displayText "  No valid table data found for this database.\n"
            continue
        }

        foreach tableName [dict keys $dbTables] {
            append displayText "  Table: $tableName\n"
            set columns [dict get $dbTables $tableName]

            if {![string is list $columns]} {
                append displayText "    No valid column data available.\n"

                continue
            }

            foreach col $columns {
                if {[dict exists $col name]} {
                    append displayText "    Column: [dict get $col name] - Type: , Not Null: [dict get $col notnull], PK: [dict get $col pk]\n"
                } else {
                    append displayText "    Incomplete column data.\n"
                }
            }

        }
    }
    return $displayText
}
