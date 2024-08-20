package require tdbc::sqlite3
package require tablelist_tile


# Datenbankverbindung erstellen
#tdbc::sqlite3::connection create db11 :memory:


proc showData {db tblName textWidget} {
    # Spaltennamen dynamisch abfragen
    set sql "PRAGMA table_info($tblName)"
    set stmt [$db prepare $sql]
    set result [$stmt execute]
    set columnNames [list]
    while {[$result nextrow -as dicts row]} {
        lappend columnNames [dict get $row name]
    }
    $result close
    $stmt close

    # Daten abfragen
    set columns [join $columnNames ", "]
    set sql "SELECT $columns FROM $tblName"
    set stmt [$db prepare $sql]
    set result [$stmt execute]
    $textWidget delete 1.0 end  ;# Vorherige Inhalte löschen
    while {[$result nextrow -as lists row]} {
        set line ""
        foreach {value columnName} $row $columnNames {
            append line "$columnName: $value "
        }
        $textWidget insert end "$line\n"
    }
    $result close
    $stmt close
}




proc validateColumnName {name} {
    # Einfache Prüfung, ob der Spaltenname gültig ist
    if {![regexp {^[a-zA-Z_][a-zA-Z0-9_]*$} $name]} {
        error "Invalid column name: $name"
    }
}

proc createTableFromTablelist {db tbl dbName} {
    set rawColumnsInfo [$tbl configure -columns]
    set columnsInfo [lindex $rawColumnsInfo end]

    set sql "CREATE TABLE IF NOT EXISTS $dbName ("
    set isFirst 1
    foreach {width name alignment} $columnsInfo {
        if {$width == "0"} {
            validateColumnName $name  ;# Überprüfen, ob der Spaltenname gültig ist
            if {!$isFirst} {
                append sql ", "
            }
            set isFirst 0
            set colType "TEXT"
            if {$alignment in {right center}} {
                set colType "INTEGER"
            }
            append sql "$name $colType"
        }
    }
    append sql ")"
    set stmt [$db prepare $sql]
    $stmt execute
    $stmt close
}

proc insertDataFromTablelist {db tbl dbName} {
    # Spaltennamen abfragen
    set sql "PRAGMA table_info($dbName)"
    set stmt [$db prepare $sql]
    set result [$stmt execute]
    set columnNames [list]
    while {[$result nextrow -as dicts row]} {
        lappend columnNames [dict get $row name]
    }
    $result close
    $stmt close

    set rows [$tbl size]
    for {set i 0} {$i < $rows} {incr i} {
        set rowData [$tbl get $i]

        # SQL-Befehl dynamisch erstellen
        set columns [join $columnNames ", "]
        set placeholders [join [lmap name $columnNames {string cat ":" $name}] ", "]
        set sql "INSERT INTO $dbName ($columns) VALUES ($placeholders)"
        set stmt [$db prepare $sql]

        # Dictionary für Platzhalter erstellen
        set valuesDict {}
        for {set index 0} {$index < [llength $columnNames]} {incr index} {
            set columnName [lindex $columnNames $index]
            set value [lindex $rowData $index]
            dict set valuesDict $columnName $value
        }

        # Statement ausführen
        $stmt execute $valuesDict
        $stmt close
    }
}


proc fetchAndFormatData {db tableName } {
    # Spaltennamen dynamisch abfragen
    set columnQuery [$db prepare "PRAGMA table_info($tableName)"]
    set columnResult [$columnQuery execute]
    set columnNames [list]
    set columnHeaders [list]
    while {[$columnResult nextrow -as dicts columnInfo]} {
        lappend columnNames [dict get $columnInfo name]
        lappend columnHeaders [dict get $columnInfo name]
    }
    $columnResult close
    $columnQuery close

    # Daten abfragen
    set selectColumns [join $columnNames ", "]
    set sql "SELECT $selectColumns FROM $tableName"
    set stmt [$db prepare $sql]
    set result [$stmt execute]
    set dataList [list $columnHeaders]  

    while {[$result nextrow -as lists row]} {
        lappend dataList $row
    }

    $result close
    $stmt close
    return $dataList
}


proc queryData {db tableName columns} {
    # Spaltennamen in einen SQL-freundlichen String konvertieren
    set sqlColumns [join $columns ", "]

    # SQL-Abfrage vorbereiten
    set sql "SELECT $sqlColumns FROM $tableName"
    set stmt [$db prepare $sql]

    # Statement ausführen
    set result [$stmt execute]

    # Daten durchlaufen
    while {[$result nextrow -as dicts row]} {
        # Dynamisch auf die Werte aus dem Dictionary `row` zugreifen
        foreach column $columns {
            puts "$column: [dict get $row $column]"
        }
        puts ""  # Zeilenumbruch für bessere Lesbarkeit
    }

    # Aufräumen
    $result close
    $stmt close
}

# SQL ausführen und Ergebnisse anzeigen
proc executeSQL {txtQuery txtResult db} {
    set sql [string trim [strip $txtQuery]]
    if {$sql eq ""} {
        return
    }

    $txtResult configure -state normal
    $txtResult delete 1.0 end
    set stmt [$db prepare $sql]

    if {[catch {$stmt execute} result]} {
        $txtResult insert end "Error executing SQL: $result\n"
    } else {
        set resultSet [$stmt execute]
        while {[$resultSet nextrow -as dicts -- row]} {
            set rowData ""
            foreach {columnName value} $row {
                append rowData "$columnName: $value  "
            }
            $txtResult insert end "$rowData\n"
        }
        $resultSet close
    }
    $txtResult configure -state disabled
    $stmt close
}

# Hilfsfunktion, um das Text-Widget zu bereinigen
proc strip {txtWidget} {
    # Ersetzt mehrere Leerzeichen durch ein Leerzeichen und entfernt führende/abschließende Leerzeichen
    regsub -all {\s+} [$txtWidget get 1.0 end] " " stripped
    return $stripped
}


