package require Tk

# Hauptfenster erstellen
set app .
wm title $app "Treeview"

# Treeview-Widget erstellen
ttk::treeview .tree -columns {} -show tree
grid .tree -sticky news

# Wurzelelemente hinzufügen
set id1 [.tree insert {} 0 -text "Item 1"]
set id2 [.tree insert {} end -text "Item 2"]

# Ein weiteres Element hinzufügen und untergeordnete Elemente einfügen
set id3 [.tree insert {} end -text "Item 3"]
.tree insert $id3 0 -text "sub-item 0"
.tree insert $id3 1 -text "sub-item 1"

# Das Fenster starten
grid columnconfigure $app 0 -weight 1
grid rowconfigure $app 0 -weight 1
#pack $app -fill both -expand 1


