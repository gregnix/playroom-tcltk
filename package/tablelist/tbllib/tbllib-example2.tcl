package require tablelist_tile


# procs with namespace tvlib:: and example datas
#source tbl-lib.tcl
source db-lib.tcl
#source report-lib.tcl

# tm libs
set addtmlib ~/lib/tcltk/tm
tcl::tm::path add $addtmlib
package require database::sqlstdproc
package require report::reportlib  


proc cbtblbtn {db table type args} {
    switch $type {
        btnget {
            listToreport  [fetchAndFormatData $db $table] [lindex $args 0]
        }
    }
}

# GUI erstellen und Tablelist konfigurieren
proc setupGUI {w db otextw itextw} {
    set frt [ttk::frame $w.frame]
    set frbtn [ttk::frame $w.frbtn]
    set tbl [tablelist::tablelist $frt.tbl -columns {0 "ID" right 0 "Name" left 0 "Value" left} \
        -stretch all -xscroll [list $frt.h set] -yscroll [list $frt.v set] \
        -labelcommand tablelist::sortByColumn -selectmode multiple -exportselection false]
    # add scrollbar
    set vsb [scrollbar $frt.v -orient vertical -command [list $tbl yview]]
    set hsb [scrollbar $frt.h -orient horizontal -command [list $tbl xview]]
    $tbl columnconfigure 0 -editable true
    $tbl columnconfigure 1 -editable true
    $tbl columnconfigure 2 -editable true

    pack $vsb -side right -fill y -expand 0
    pack $hsb -side bottom -fill x -expand 0


    pack $tbl -expand yes -fill both
    pack $frt -expand yes -fill both -side top
    pack $frbtn -expand 0 -fill x

    ttk::button $frbtn.btnins -text "Daten einfügen" -command [list \
        insertDataFromTablelist $db $tbl "users" ]
    ttk::button $frbtn.btnget -text "Daten holen" -command [list cbtblbtn $db "users" btnget $otextw ]
    ttk::button $frbtn.btnExecute -text "Execute" -command [list executeSQL $itextw $otextw $db]

    pack {*}[winfo children $frbtn] -side left


    # Tabelle basierend auf der Tablelist-Struktur erstellen
    createTableFromTablelist $db $tbl "users"
    return $tbl
}




###############################################################################
#main

# Datenbankverbindung erstellen
set dbnew [tdbc::sqlite3::connection create db11 :memory:]
wm protocol . WM_DELETE_WINDOW {
    $dbnew close  ;# Datenbankverbindung schließen
    destroy .   ;# GUI schließen
}

# text output
set outWindow [ttk::frame .frouttext]
set outtextWidget [text $outWindow.text -width 80 -height 20]
pack $outtextWidget -expand 1 -fill both
pack $outWindow -expand 1 -fill both -side top

# text input
set inWindow [ttk::frame .frintext]
set intextWidget [text $inWindow.text -width 80 -height 20]
pack $intextWidget -expand 1 -fill both
pack $inWindow -expand 1 -fill both -side top

# table edit bar
ttk::frame .fr
set tbl [setupGUI .fr $dbnew $outtextWidget $intextWidget]
pack .fr -expand 1 -fill both -side top
$tbl insertlist end {{1 Kreis 4} {2 Quadrat 78} {3 Rechteck 12}}





