package require Tk

# Hauptfenster erstellen
set app .
wm title $app "Treeview - tags"

# Treeview-Widget erstellen
ttk::treeview .tree -columns {} -show tree
grid .tree -sticky news

# Elemente in die Treeview einfügen und Tags setzen
.tree insert {} end -text "Item 1" -tags "fg"
.tree insert {} end -text "Item 2" -tags "bg"
.tree insert {} end -text "Item 3"
.tree insert {} end -text "Item 4" -tags {fg bg}

# Tags konfigurieren
.tree tag configure bg -background yellow
.tree tag configure fg -foreground red

# Fenster und Gitterlayout konfigurieren
grid columnconfigure $app 0 -weight 1
grid rowconfigure $app 0 -weight 1



