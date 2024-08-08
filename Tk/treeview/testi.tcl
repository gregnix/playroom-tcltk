#!/usr/bin/env tclsh

package require Tk
package require Ttk
package require scrollutil

# Hauptfenster erstellen
set root [tk::toplevel .top]
wm title $root "Scrollable Frame Example"

# Scrollarea und Scrollableframe erstellen
set sa [scrollutil::scrollarea $root.sa]
set sf [scrollutil::scrollableframe $sa.sf -width 400 -height 300 -yscrollincrement 20]

# Scrollableframe in Scrollarea setzen
$sa setwidget $sf

# Contentframe aus Scrollableframe bekommen
set cf [$sf contentframe]

# Contentframe mit Widgets füllen
for {set i 1} {$i <= 30} {incr i} {
    ttk::label $cf.lbl$i -text "Label $i"
    grid $cf.lbl$i -row $i -column 0 -padx 10 -pady 5 -sticky w
}

# Automatische Anpassung der Breite des Scrollableframes
$sf autofillx true

# Scrollableframe konfigurieren
$sf configure -height 300 -yscrollincrement 20

# Scrollarea packen
pack $sa -expand yes -fill both

# Haupt-Event-Loop starten (dies wird automatisch vom Tcl-Interpreter verwaltet)
scrollutil::createWheelEventBindings all