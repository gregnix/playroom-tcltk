package require tdbc::sqlite3

# Datenbankverbindung herstellen
proc dbConnect {} {
    tdbc::sqlite3::connection create db mydatabase.db
    return db
}

# Daten aus der SQLite-Datenbank laden
proc loadData {db tbl} {
    set result [$db prepare {SELECT * FROM mytable}]
    $result execute
    while {[$result nextrow]} {
        $tbl insert end [$result get]
    }
    $result close
}

# Änderungen speichern
proc saveChanges {db tbl row col value} {
    set stmt [$db prepare {
        UPDATE mytable SET [lindex [$tbl columnnames] $col] = :newValue WHERE id = :rowId
    }]
    $stmt execute -dict {newValue $value rowId [lindex [$tbl get $row] 0]}
    $stmt close
}

# GUI-Setup
proc setupGUI {db} {
    package require tablelist
    ttk::frame .f
    tablelist::tablelist .f.tbl -columns {0 "ID" 0 "Name" 0 "Age"} -editable true
    pack .f.tbl -expand yes -fill both
    pack .f -expand yes -fill both

    # Daten laden
    loadData $db .f.tbl

    # Änderungen speichern, wenn eine Zelle bearbeitet wird
    bind .f.tbl <<TablelistCellEdited>> {
        %W get %r %c %V
        saveChanges $db %W %r %c %V
    }
}

# Hauptausführung
set db [dbConnect]
setupGUI $db
