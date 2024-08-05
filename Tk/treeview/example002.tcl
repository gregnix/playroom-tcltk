#!/usr/bin/env tclsh
package require Tk
package require Ttk

# Daten-Setup
dict set data Example1 {person {name "John Doe" age 30 address {street "123 Main St" city "Anytown"}} job {title "Developer" company "Works"}}
dict set data Example2 {person {name "Jane Doe" age 25 address {street "456 Elm St" city "Othertown"}} job {title "Designer" company "Creates"}}

# Hauptfenster erstellen
set root [tk::toplevel .top]
wm title $root "Nested Dictionary in Treeview"

# Treeview erstellen
ttk::treeview .tree -columns {Key Value} -show {tree headings}
grid .tree -sticky news

# Spaltenüberschriften festlegen
.tree heading Key -text "Key"
.tree heading Value -text "Value"
.tree column Key -width 150
.tree column Value -width 250

# Funktion zum Einfügen von Daten in das Treeview
proc insertDict {tree parent data} {
    foreach {key value} [dict get $data] {
        if {[catch {dict get $value}]} {
            $tree insert $parent end -text $key -values $value
        } else {
            set id [$tree insert $parent end -text $key -values ""]
            insertDict $tree $id $value
        }
    }
}

# Daten aus dem Dict in das Treeview einfügen
insertDict .tree {} $data

# Fenster anpassen
grid columnconfigure . 0 -weight 1
grid rowconfigure . 0 -weight 1

# Haupt-Event-Loop starten
# (dies wird automatisch vom Tcl-Interpreter verwaltet)
