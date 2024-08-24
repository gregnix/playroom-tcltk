package require Tk
package require tablelist

# Erstellen des Tablelist-Widgets
tablelist::tablelist .mytablelist -columns {
    20 "Kunden-ID"
    20 "Vorname"
    20 "Vatername"
    20 "Nachname"
} -width 40 -height 10 -selectmode single   -stripebackground #f0f0f0 \

pack .mytablelist -expand yes -fill both

# Hinzufügen von Beispiel-Daten
set data {
    {12345678901234567890 "Maximilian Mustermann" "Johannes Mustermann" "Langname Mustermann"}
    {23456789012345678901 "Johnathan Doe" "Jack Doe" "Superlonglastname Doe"}
    {34567890123456789012 "Jane Jane" "Jim Doe" "Dorian"}
}

foreach row $data {
    .mytablelist insert end $row
}

# Konfigurieren des Umbruchs für alle Spalten
set colCount [.mytablelist columncount]
for {set col 0} {$col < $colCount} {incr col} {
    .mytablelist columnconfigure $col -wrap true
}

# Damit das Fenster nicht sofort geschlossen wird
tkwait window .
