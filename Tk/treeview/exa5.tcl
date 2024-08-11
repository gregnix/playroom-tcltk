package require Tk

# Hauptfenster erstellen
set app .
wm title $app "Treeview"

# Treeview-Widget erstellen
ttk::treeview .tree -columns {type value} -show [list tree headings]
grid .tree -sticky news

# Spalten konfigurieren
.tree column type -width 100
.tree heading type -text "Type"
.tree heading value -text "Value"

# Einträge im Treeview hinzufügen
foreach item [lsort [info commands]] {
    set x  $item
    set t command
    puts "$t $x"
    .tree insert {} end -text $item -values [list $t $x]
}

# Fenster und Gitterlayout konfigurieren
grid columnconfigure $app 0 -weight 1
grid rowconfigure $app 0 -weight 1

# Ein weiteres Treeview-Widget für die aktuelle Umgebung erstellen
ttk::treeview .tree2 -columns {} -show [list tree headings]
grid .tree2 -row 0 -column 1 -sticky news

foreach item [lsort [info vars]] {
    .tree2 insert {} end -text $item
}

# Layout-Anpassungen
grid columnconfigure $app 1 -weight 1
grid rowconfigure $app 0 -weight 1


