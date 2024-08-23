package require Tk
package require tablelist_tile


# Create the Tablelist widget with tree configuration
proc createTbl {w columns} {
  set frt [ttk::frame $w.frt]
  set frbtn [ttk::frame $w.frbtn]
  set tbl [tablelist::tablelist $frt.tbl -columns $columns -height 20 -width 0 \
    -stretch all -treecolumn 0 -selectmode single]
  $tbl columnconfigure 0 -name key
  $tbl columnconfigure 1 -name value
  set vsb [scrollbar $frt.vsb -orient vertical -command [list $tbl yview]]
  set hsb [scrollbar $frt.hsb -orient horizontal -command [list $tbl xview]]
  $tbl configure -yscroll [list $vsb set] -xscroll [list $hsb set]

  set btnSave [ttk::button $frbtn.btnSave -text "Speichern" -command [list saveData $tbl]]

  #  tbl::init_moveMBind $tbl
  #  tbl::init_moveKBind $tbl
  pack $vsb -side right -fill y
  pack $hsb -side bottom -fill x
  pack $tbl -expand yes -fill both

  pack $btnSave -side left -expand 0


  pack $frt -expand yes -fill both -side top
  pack $frbtn -side bottom -expand 0 -fill x
  return $tbl
}


# Speicherfunktion
proc saveData {tbl} {
  # Alle Zeilen durchgehen
  set rowCount [$tbl size]
  for {set i 0} {$i < $rowCount} {incr i} {
    set row [$tbl get $i]
    puts "Speichern der Zeile $i: $row"
    # Logik zum Speichern der Zeile in der Datenbank
  }
}


# Hauptfenster konfigurieren
wm title . "Tablelist Konfigurationsmanager"
pack [ttk::frame .frame -padding "10 10 10 10"] -expand 1 -fill both

set columns {0 Tabellenname 0 Spalten 0 Typen 0 Primärschlüssel 0 Fremdschlüssel 0 Anzeigeoptionen}
set tbl [createTbl .frame  $columns]

# Beispiel Daten in die Tablelist einfügen
$tbl insert end {users "ID Name Email" "INTEGER TEXT TEXT" "ID" "" "Full row select"}
$tbl insert end {products "ID Name Price" "INTEGER TEXT REAL" "ID" "" "Editable cells"}





