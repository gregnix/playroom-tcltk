package require Tk
package require tablelist_tile


# Create the Tablelist widget with tree configuration
proc createTbl {w columns} {
  set frt [ttk::frame $w.frt]
  set frbtn [ttk::frame $w.frbtn]
  set tbl [tablelist::tablelist $frt.tbl -columns $columns -height 20 -width 0 \
    -stripebackground #f0f0f0 \
    -stretch all -treecolumn 0 -selectmode single]
  
  set vsb [scrollbar $frt.vsb -orient vertical -command [list $tbl yview]]
  set hsb [scrollbar $frt.hsb -orient horizontal -command [list $tbl xview]]
  $tbl configure -yscroll [list $vsb set] -xscroll [list $hsb set]

  $tbl columnconfigure 0 -name key
  $tbl columnconfigure 1  -showlinenumbers 1 


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

set columns {0 Key 0 rowid 0 Tabellenname 0 Spalten 0 Typen 0 primarykey 0 foreignkey 0 displayoption}
set tbl [createTbl .frame  $columns]

# Beispiel Daten in die Tablelist einfügen
set root [$tbl insertchildlist root end tree]
#$tbl insertchildlist $root end $childlist1
$tbl insertchild $root end {users "" users "ID Name Email" "INTEGER TEXT TEXT" "ID" "" "Full row select"}
$tbl insertchild $root end {products "" products "ID Name Price" "INTEGER TEXT REAL" "ID" "" "Editable cells"}





