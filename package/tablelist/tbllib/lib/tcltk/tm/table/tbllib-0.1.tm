package require Tk
package require tablelist_tile

namespace eval tbllib {
 proc newTable {w cols} {
  variable tblVarDict
  set frt  $w.frt
  frame $frt -background "gray"

  # Create table
  set tbl [tablelist::tablelist $frt.tbl -columns $cols \
    -stretch all  -xscroll [list $frt.h set] -yscroll [list $frt.v set] -labelcommand tablelist::sortByColumn \
    -selectmode multiple -exportselection false]

  dict set tblVarDict $tbl cols $cols
  dict set tblVarDict $tbl editVars {}
  dict set tblVarDict $tbl colVars {}

  $tbl columnconfigure 0 -sortmode dictionary
  $tbl columnconfigure 1 -editable 1

  # Speichere den Bearbeitbarkeitszustand in editVars
  for {set col 0} {$col < [llength $cols]} {incr col} {
   dict set tblVarDict $tbl editVars $col 1 ; # Spalte bearbeitbar
   dict set tblVarDict $tbl colVars $col 1 ;  # Spalte sichtbar
  }


  #add scrollbar
  set vsb [scrollbar $frt.v -orient vertical -command [list $tbl yview]]
  set hsb [scrollbar $frt.h -orient horizontal -command [list $tbl xview]]

  # Add frames
  set fro [frame $w.fro]
  set frb [frame $w.frb]
  grid $fro -row 0 -column 0 -sticky ew -columnspan 2
  grid $frb -row 2 -column 0 -sticky ew -columnspan 2
  grid $frt -row 1 -column 0 -sticky nsew

  grid $vsb -row 0 -column 1 -sticky ns
  grid $hsb -row 1 -column 0 -sticky ew
  grid $tbl -row 0 -column 0 -sticky nsew

  # combobox
  set cbselection [ttk::combobox $fro.cbselection -values [list single  multiple ] -exportselection 0 -width 8]
  bind $cbselection <<ComboboxSelected>> [namespace code [list [namespace current]::OnComboSelected %W $tbl selectmode]]
  $cbselection current 0
  event generate $cbselection <<ComboboxSelected>>

  # Add buttons
  set btnone [ttk::button $frb.one -text "Button One" -command [list tk_messageBox -message "Tbl: $tbl" -type ok]]
  set btntwo [ttk::button $frb.two -text "Button Two" -command [list [namespace current]::tblcallback $tbl test]]
  set btndelete [ttk::button $frb.delete -text "Delete" -command [list [namespace current]::tblcallback $tbl delete]]
  set btncopy [ttk::button $frb.copy -text "Copy" -command [list [namespace current]::tblcallback $tbl copy]]

  set btnhide [ttk::button $fro.hide -text "HideShow" -command [list [namespace current]::toggleColumns $tbl]]
  set btneditable [ttk::button $fro.edit -text "Editable" -command [list [namespace current]::toggleEditableColumns $tbl]]

  grid $btnone -row 0 -column 0 -sticky w
  grid $btntwo -row 0 -column 1 -sticky e
  grid $btndelete -row 0 -column 2 -sticky e
  grid $btncopy -row 0 -column 3 -sticky e
  grid $btnhide -row 1 -column 1 -sticky e
  grid $btneditable -row 1 -column 2 -sticky e
  grid $cbselection -row 1 -column 0 -sticky ew

  grid columnconfigure $frt 0 -weight 1
  grid rowconfigure $frt 0  -weight 1
  grid columnconfigure $w 0 -weight 1
  grid rowconfigure $w 1  -weight 1

  #add bind
  bind [$tbl bodytag] <Double-1> [list tk_messageBox -message "Tbl: $tbl\nW %W" -type ok]
  bind [$tbl bodytag] <Key-a> [list tk_messageBox -message \
    "Tbl: $tbl\nW %W\nx: %x y:%y\nX:%X Y:%Y\n [join "%k %i %s %A %K %M %N %R %S %T" \n]" -type ok]
  bind [$tbl bodytag] <Key-F4> [list $btntwo invoke]

  return $tbl
 }


 proc tblcallback {tbl type args} {
  variable tblVarDict
  variable dbconnS
  switch $type {
   aktual {
    set cb  [lindex $args 0]
    $cb configure -values [[namespace current]::sqlauwahl $dbconnS]
   }
   delete {
    set sel [lindex [$tbl curselection] 0]
    foreach row [ lsort -integer -decreasing [$tbl curselection]] {
     $tbl delete $row
    }
    $tbl  selection set $sel
   }
   copy {
    set sel [lindex [$tbl curselection] 0]
    $tbl insert $sel [$tbl get $sel]
   }
   test {
    set columncount [expr {[$tbl columncount] - 1}]
    for {set col 0} {$col <= $columncount} {incr col} {
     dict set  cols $col title [$tbl columncget $col -title]
     dict set  cols $col width [$tbl columncget $col -width]
     dict set  cols $col align [$tbl columncget $col -align]
     dict set  cols $col sortmode [$tbl columncget $col -sortmode]
     dict set  cols $col hide [$tbl columncget $col -hide]
    }
    dict set tblVarDict $tbl cols $cols
    puts $tblVarDict
    puts  [dict get $tblVarDict $tbl cols 0]
    #puts [dict get $tblVarDict $tbl cols]
    #puts [dict get $tblVarDict $tbl]

   }
  }
 }

 proc OnComboSelected {w tbl type} {
  variable dbconnS
  variable tblDict
  switch $type {
   selectmode {
    $tbl configure -selectmode [$w get]
   }
   sortID {
    dict set tblDict tbloptions sortID [$w get]
    foreach v [$w cget -values] {
     $tbl header cellconfigure 0,$v -background ""
    }
    $tbl header cellconfigure 0,[$w get] -background red
   }
   sortModus {
    dict set tblDict tbloptions sortModus [$w get]
   }
  }
 }

 # Prozedur für das Umschalten der Bearbeitbarkeit
 proc toggleEditableColumns {tbl} {
  variable tblVarDict

  # Existierendes Menü löschen, falls vorhanden
  catch {destroy .popupEditable}

  # Kontextmenü erstellen
  set popup [menu .popupEditable -tearoff 0]

  # Hole die Anzahl der Spalten aus dem Dict
  set columncount [expr {[llength [dict get $tblVarDict $tbl cols]] / 3 - 1}]

  for {set col 0} {$col <= $columncount} {incr col} {
   # Bearbeitbarkeitsstatus aus dem Dict holen
   set editable [dict get $tblVarDict $tbl editVars $col]
   set varName "[namespace current]::editVar$col"

   # Checkbutton für jede Spalte erstellen
   .popupEditable add checkbutton -label [$tbl columncget $col -title] \
                -variable $varName -onvalue 1 -offvalue 0 \
                -command [list tbllib::toggleColumnEditable $tbl $col $varName]

   # Aktualisiere den Bearbeitbarkeitsstatus im dict, basierend auf dem aktuellen Status
   dict set tblVarDict $tbl editVars $col $editable
  }

  # Menü anzeigen lassen
  tk_popup .popupEditable [winfo pointerx .] [winfo pointery .]
 }

 # Prozedur zum Umschalten der Bearbeitbarkeit
 proc toggleColumnEditable {tbl col varName} {
  variable tblVarDict

  if {[set $varName] == 1} {
   $tbl columnconfigure $col -editable 1
   dict set tblVarDict $tbl editVars $col 1 ;  # Aktualisiere das dict
  } else {
   $tbl columnconfigure $col -editable 0
   dict set tblVarDict $tbl editVars $col 0 ;  # Aktualisiere das dict
  }
 }

 # Prozedur für das Umschalten der Spaltensichtbarkeit
 proc toggleColumns {tbl} {
  variable tblVarDict

  # Existierendes Menü löschen, falls vorhanden
  catch {destroy .popupColumns}

  # Kontextmenü erstellen
  set popup [menu .popupColumns -tearoff 0]

  # Hole die Anzahl der Spalten aus dem Dict
  set columncount [expr {[llength [dict get $tblVarDict $tbl cols]] / 3 - 1}]

  for {set col 0} {$col <= $columncount} {incr col} {
   # Sichtbarkeitsstatus aus dem Dict holen
   set visible [dict get $tblVarDict $tbl colVars $col]
   set varName "[namespace current]::colVar$col"

   # Checkbutton für jede Spalte erstellen
   .popupColumns add checkbutton -label [$tbl columncget $col -title] \
                -variable $varName -onvalue 1 -offvalue 0 \
                -command [list tbllib::toggleColumnVisibility $tbl $col $varName]

   # Aktualisiere den Sichtbarkeitsstatus im dict
   dict set tblVarDict $tbl colVars $col $visible
  }

  # Menü anzeigen lassen
  tk_popup .popupColumns [winfo pointerx .] [winfo pointery .]
 }

 # Prozedur zum Umschalten der Sichtbarkeit von Spalten
 proc toggleColumnVisibility {tbl col varName} {
  variable tblVarDict

  if {[set $varName] == 1} {
   $tbl columnconfigure $col -hide 0
   dict set tblVarDict $tbl colVars $col 1 ;  # Aktualisiere das dict
  } else {
   $tbl columnconfigure $col -hide 1
   dict set tblVarDict $tbl colVars $col 0 ;  # Aktualisiere das dict
  }
 }


 # Function to configure widget at edit start
 proc editStartCmd {tbl row col args} {
  puts $args
  set w [$tbl editwinpath]
  if {$col == 2} {  # Assuming column 2 is the combobox
   $w configure -values {"Option1" "Option2" "Option3"}
  }
 }
}



namespace eval tbllib {
 proc getFilteredRows {tbl columnIndex value} {
  set rowCount [$tbl index end]
  set filteredRows {}

  for {set i 0} {$i < $rowCount} {incr i} {
   if {[$tbl cellcget $i,$columnIndex -text] eq $value} {
    lappend filteredRows [$tbl get $i]
   }
  }

  return $filteredRows
 }

 # Funktion zum Überprüfen, ob ein Wert numerisch ist (Integer)
 proc isInteger {value} {
  expr {[string is integer -strict $value]}
 }

 # Funktion zum Erzeugen der Spalten basierend auf den Daten
 proc generateColumns {data} {
  set cols {}

  # Bestimme die Anzahl der Spalten anhand der ersten Zeile der Daten
  set numColumns [llength [lindex $data 0]]

  # Dynamisch Spaltenüberschriften und Ausrichtungen erstellen
  for {set i 0} {$i < $numColumns} {incr i} {
   set title "Col$i"  ;# Dynamischer Titel, z.B. Col0, Col1, ...

   # Bestimme die Ausrichtung basierend auf dem Datentyp der ersten Zeile
   set value [lindex [lindex $data 0] $i]
   if {[string is integer -strict $value]} {
    set align right
   } else {
    set align left
   }

   # Füge die Spalte mit Index, Titel und Ausrichtung hinzu
   lappend cols 0 $title $align
  }

  return $cols
 }


}





if {[info script] eq $argv0} {

 tcl::tm::path add [file join [file dirname [info script]] ./]
 package require tbltestdata


 ttk::frame .fr
 set data [tbllib::testdata::testDataTwo 100 100 2001-02-28T12:01:01 seconds]
 #set data [tbllib::testdata::generateReferenceList 10 8]

 set cols [tbllib::generateColumns $data]
 set tbl [ tbllib::newTable .fr $cols]

 $tbl insertlist end  $data
 $tbl configure -width 80
 pack .fr -expand 1 -fill both

 puts [$tbl getcolumn 1]
 puts [$tbl configure -columns]

 if {0} {
  output:
  Item_1_2 Item_2_2 Item_3_2 Item_4_2 Item_5_2 Item_6_2 Item_7_2 Item_8_2 Item_9_2 Item_10_2
  -columns columns Columns {} {0 Col1 right 0 Col2 left 0 Col3 center}
 }

}