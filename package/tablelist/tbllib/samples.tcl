package require Tk
package require tdbc::sqlite3
package require tablelist

# Datenbankverbindung erstellen
tdbc::sqlite3::connection create db :memory:

# GUI-Aufbau
proc setupGUI {frame db} {
    ttk::label $frame.lblQuery -text "SQL Query:"
    ttk::text $frame.txtQuery -height 5 -width 50
    ttk::button $frame.btnExecute -text "Execute" -command [list executeSQL $frame.txtQuery $frame.txtResult db]

    ttk::label $frame.lblResult -text "Results:"
    ttk::text $frame.txtResult -height 20 -width 50 -state disabled

    pack $frame.lblQuery -side top -fill x
    pack $frame.txtQuery -side top -fill x
    pack $frame.btnExecute -side top -fill x
    pack $frame.lblResult -side top -fill x
    pack $frame.txtResult -side top -fill both -expand true
}

# SQL ausführen und Ergebnisse anzeigen
proc executeSQL {txtQuery txtResult db} {
    set sql [string trim [strip $txtQuery get 1.0 end]]
    if {$sql eq ""} {
        return
    }

    $txtResult configure -state normal
    $txtResult delete 1.0 end
    set stmt [db prepare $sql]

    if {[catch {$stmt execute} result]} {
        $txtResult insert end "Error executing SQL: $result\n"
    } else {
        set resultSet [$stmt execute]
        while {[$resultSet nextrow]} {
            set rowData ""
            foreach {columnName value} [$resultSet get -as dict] {
                append rowData "$columnName: $value  "
            }
            $txtResult insert end "$rowData\n"
        }
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

# Hauptfenster
ttk::frame .fr
setupGUI .fr db
pack .fr -expand 1 -fill both
