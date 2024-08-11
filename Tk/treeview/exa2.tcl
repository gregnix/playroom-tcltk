package require Tk

package require Tk

# Hauptfenster erstellen
set app .
wm title $app "Treeview - multiple columns"

# Treeview-Widget erstellen
ttk::treeview .tree -columns {size modified} -show {tree headings}
grid .tree -sticky news

# Elemente in die Treeview einfügen
.tree insert {} end -id widgets -text "Widgets"
.tree insert {} 0 -id apps -text "Applications"

# Spalten konfigurieren
.tree column size -width 50 -anchor center
.tree heading size -text "Size"
.tree heading modified -text "Modified"

# Werte für die Spalten setzen
.tree set widgets size "12KB"
.tree set widgets modified "Last week"

# Weitere Elemente mit zugehörigen Werten einfügen
.tree insert {} end -text "Canvas" -values {25KB Today}
.tree insert apps end -text "Browser" -values {115KB Yesterday}

# Fenster und Gitterlayout konfigurieren
grid columnconfigure $app 0 -weight 1
grid rowconfigure $app 0 -weight 1



