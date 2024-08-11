package require Tk

# Hauptfenster erstellen
set app .
wm title $app "Treeview - bind"

# Treeview-Widget erstellen
ttk::treeview .tree -columns {} -show tree
grid .tree -sticky news

# Callback-Funktion definieren
proc cb {args} {
    puts "$args selection: [.tree selection] focus: [.tree focus]"
}

# Elemente in die Treeview einfügen und Tags setzen
.tree insert {} end -text "Item 1" -tags "cb"
set id [.tree insert {} end -text "Item 2" -tags "cb"]
.tree insert $id end -text "Sub-Item 1" -tags "cb"
.tree insert $id end -text "Sub-Item 2" -tags "cb"

# Tag-Bindungen setzen
.tree tag bind cb <1> cb
.tree tag bind cb <<TreeviewSelect>> cb
.tree tag bind cb <<TreeviewOpen>> cb
.tree tag bind cb <<TreeviewClose>> cb

# Fenster und Gitterlayout konfigurieren
grid columnconfigure $app 0 -weight 1
grid rowconfigure $app 0 -weight 1


