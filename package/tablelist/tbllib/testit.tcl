package require Tk
package require tablelist_tile

# Beispiel-Daten für das Tablelist-Widget
set headers {ID Name Age Country}
set data {
    {1 "Alice" 30 "USA"}
    {2 "Bob" 25 "UK"}
    {3 "Charlie" 35 "Canada"}
}

# Tablelist erstellen
tablelist::tablelist .tbl -columns {0 "ID" left 0 "Name" left 0 "Age" left 0 "Country" left} \
    -selectmode browse \
    -width 50 \
    -height 10

# Daten einfügen
foreach row $data {
    .tbl insert end $row
}

# Scrollbar hinzufügen
pack [scrollbar .yscroll -command ".tbl yview"] -side right -fill y
pack .tbl -side left -fill both -expand true
.tbl configure -yscrollcommand ".yscroll set"

# Kontextmenü für das Verstecken von Spalten
menu .popup -tearoff 0

# Funktion zum Verstecken oder Anzeigen einer Spalte
proc toggle_column_visibility {tbl col} {
    # Abfragen, ob die Spalte aktuell versteckt ist
    set current_hidden [.tbl columncget $col -hide]

    # Spalte ein- oder ausblenden
    if {$current_hidden} {
        .tbl columnconfigure $col -hide 0
    } else {
        .tbl columnconfigure $col -hide 1
    }
}

# Kontextmenü erstellen, um Spalten auszuwählen
foreach {index header} $headers {
    .popup add checkbutton -label $header -variable hidden($index) \
        -command [list toggle_column_visibility .tbl $index]
}

# Kontextmenü anzeigen bei Rechtsklick
bind [.tbl bodytag] <Button-3> {tk_popup .popup %X %Y}

# Fenster öffnen
pack .tbl
