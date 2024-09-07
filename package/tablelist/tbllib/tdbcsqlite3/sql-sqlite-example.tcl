#!/usr/bin/env tclsh

package require Tk
package require tablelist_tile
package require dicttool
set dirname [file dirname [info script]]
source [file join $dirname tbltreedict.tcl]
source [file join $dirname tbltreemove.tcl]

# Datei 1 und Datei 2 einbinden
package require Tk
package require dicttool


source report-lib.0.2.tcl
source sql-all-proc-0.2.tcl

# tm libs
set addtmlib ~/lib/tcltk/tm
tcl::tm::path add $addtmlib
#package require database::sqlstdproc
#package require report::reportlib


 

# Create the Tablelist widget with tree configuration
proc createTbl {w} {
 set frt [ttk::frame $w.frt]
 set tbl [tablelist::tablelist $frt.tbl -columns {0 "Key" 0 "Value"} -height 20 -width 0 \
    -stretch all -treecolumn 0 -selectmode single -stripebackground #f0f0f0 ]
  $tbl columnconfigure 0 -name key
  $tbl columnconfigure 1 -name value
  $tbl columnconfigure 1 -wrap true
  set vsb [scrollbar $frt.vsb -orient vertical -command [list $tbl yview]]
  set hsb [scrollbar $frt.hsb -orient horizontal -command [list $tbl xview]]
  $tbl configure -yscroll [list $vsb set] -xscroll [list $hsb set]

  #tbl::init_moveMBind $tbl
  #tbl::init_moveKBind $tbl
  pack $vsb -side right -fill y
  pack $hsb -side bottom -fill x
  pack $tbl -expand yes -fill both

  pack $frt -expand yes -fill both
  return $tbl
}



# GUI-Fenster aufbauen
proc buildGUI {dbconn w tbl} {

  set frt [ttk::frame $w.main]
  pack $frt -expand yes -fill both

  # Label für die Combobox
  ttk::label $frt.lbl -text "Enter SQL Command:"
  pack $frt.lbl -side top -padx 10 -pady 5

  # Combobox für SQL-Eingabe
  set cbsqlEntry [ttk::combobox $frt.sqlEntry -width 40 ]
  $cbsqlEntry configure -values {
    "SELECT * FROM users"
    "SELECT name FROM sqlite_master WHERE type='table'"
    "PRAGMA database_list"
    "PRAGMA table_info(users)"
    "PRAGMA table_info(sqlite_master)"
    "PRAGMA table_list"
    "PRAGMA collation_list"
    "PRAGMA encoding"
    "PRAGMA function_list"
    "PRAGMA module_list"
    "PRAGMA pragma_list"
    "PRAGMA stats"
  }

  $frt.sqlEntry set "SELECT name FROM sqlite_master WHERE type='table'"  ;# Standardwert setzen

  pack $frt.sqlEntry -side top -fill x -padx 10 -pady 5

  # Text Widget für die Ausgabe
  set outputw [text $frt.output -height 15 -width 80]
  set vsb [scrollbar $frt.vsb -orient vertical -command [list $outputw yview]]
  #set hsb [scrollbar $frt.hsb -orient horizontal -command [list $outputw xview]]
  $outputw configure -yscroll [list $vsb set] 
  pack $vsb -side right -fill y 
  pack $outputw -side top -fill both -expand yes -padx 10 -pady 5


  # Ausführungsknopf
  ttk::button $frt.execute -text "Execute" -command [list executeSQL $dbconn $frt.sqlEntry $frt.output]
  ttk::button $frt.tableStructure -text "Tablestructur" -command [list displayTableStructure  $dbconn $frt.output $tbl]
  set cbbtnCmd [ttk::combobox $frt.btnCmd -width 40  -state readonly]
  bind $cbbtnCmd <<ComboboxSelected>> [list cbbtnCmd %W  $dbconn $outputw $tbl]
  $cbbtnCmd configure -values {
    "$outputw insert end hello\\n"
    "$outputw delete 1.0 end"
    "displayTableStructure  $dbconn $outputw $tbl"
    "$outputw insert end [infoDB $dbconn]\\n"
  }
  pack $frt.execute $frt.tableStructure  $frt.btnCmd -side left -padx 10 -pady 5 -expand 1 -fill both

  bind . <F5> [list executeSQL $dbconn $frt.sqlEntry $frt.output]
}

proc cbbtnCmd {W dbconn outputw tbl} {
  eval  [$W get]

}




#####################################
#main
# Datenbank initialisieren
#initDatabase $dbconnS

ttk::frame .frtbl
pack .frtbl -side top -expand 1 -fill both

set tbl [createTbl  .frtbl]
$tbl configure -width 60
# Starten des GUI
ttk::frame .fr
buildGUI $dbconnS .fr $tbl
pack .fr -expand yes -fill both

# Hauptevent-Schleife
wm title . "SQL Command Interface"
#wm geometry . "1200x400+10+12"

