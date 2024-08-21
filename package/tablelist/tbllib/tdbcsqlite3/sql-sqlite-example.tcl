# Hauptprogramm, das die GUI startet und die Funktionen nutzt

# Datei 1 und Datei 2 einbinden
source sql-sqlite-connect.0.2.tcl
source sql-std-proc-0.2.tcl

package require Tk

# GUI-Fenster aufbauen
proc buildGUI {dbconn} {
    ttk::frame .main
    pack .main -expand yes -fill both

    # Text Widget für SQL-Eingabe
    ttk::label .main.lbl -text "Enter SQL Command:"
    ttk::entry .main.sqlEntry -width 40
    text .main.output -height 15 -width 50
    ttk::button .main.execute -text "Execute" -command [list executeSQL $dbconn .main.sqlEntry .main.output]

    pack .main.lbl -side top -padx 10 -pady 5
    pack .main.sqlEntry -side top -fill x -padx 10 -pady 5
    pack .main.output -side top -fill both -expand yes -padx 10 -pady 5
    pack .main.execute -side top -padx 10 -pady 5
}

# Funktion zur Ausführung von SQL-Befehlen
proc executeSQL {dbconn entryWidget outputWidget} {
    set sql [sqltrim [$entryWidget get]]
    if {[string match {*select*} $sql]} {
        set result [sqlcmdDQL $dbconn $sql]
        set outputText "Columns: [dict get $result columns]\nRows:\n"
        foreach row [dict get $result rows] {
            append outputText "$row\n"
        }
    } else {
        set result [sqlcmdDML $dbconn $sql]
        set outputText "Status: [dict get $result status]\nAffected Rows: [dict get $result affected_rows]\n"
    }
    $outputWidget configure -state normal
    $outputWidget delete 1.0 end
    $outputWidget insert end $outputText
    $outputWidget configure -state disabled
}

# Starten des GUI
buildGUI $dbconnS

# Hauptevent-Schleife
wm title . "SQL Command Interface"
wm geometry . "600x400"

