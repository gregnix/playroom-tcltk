#!/usr/bin/env tclsh

package require Tk
package require tablelist_tile
set dirname [file dirname [info script]]
source [file join $dirname tbltreedict.tcl]

namespace eval tbl {

  # Variablen zum Speichern des Quellindex und des Verschiebungsstatus
#  set sourceIndex -1
#  set isMoving 0
  variable state

  # Funktion zum Aktivieren des Verschiebungsmodus
  proc activateMoveMode {tbl} {
    variable state
    puts "start active tbl $tbl"
    dict set state $tbl keyboard sourceIndex [$tbl index active]
    $tbl selection clear 0 end
    $tbl selection set [dict get $state $tbl keyboard sourceIndex]
    if {[dict get $state $tbl keyboard sourceIndex] ne ""} {
      dict set state $tbl keyboard isMoving 1
      puts "Move mode activated for index: \$sourceIndex :: [dict get $state $tbl keyboard sourceIndex]"
    }
    puts "ende active tbl $tbl state $state"
  }

  # Funktion zum Verschieben des Elements
  proc confirmMove {tbl} {
    variable state
    puts "start confirm tbl $tbl"
    if {[dict get $state $tbl keyboard isMoving]} {
      set newIndex [$tbl index active]
      if {$newIndex != [dict get $state $tbl keyboard sourceIndex]} {
        # Element an der Quelle holen
        set item [$tbl get [dict get $state $tbl keyboard sourceIndex]]
        # Quelle löschen
        $tbl delete [dict get $state $tbl keyboard sourceIndex]
        # Element am neuen Index einfügen
        if {$newIndex > [dict get $state $tbl keyboard sourceIndex]} {
          set newIndex [expr {$newIndex - 0}]
        }
        $tbl insert $newIndex $item
        # Auswahl und Aktivierung sichtbar halten
        $tbl selection clear 0 end
        $tbl selection set $newIndex
        $tbl activate $newIndex
        puts "Moved item from index \$sourceIndex to $newIndex :: state: $state"
      }
      dict set state $tbl keyboard sourceIndex -1
      dict set state $tbl keyboard isMoving 0
    }
  }

  # Funktion zum Abbrechen des Verschiebungsmodus
  proc cancelMove {tbl} {
    variable state
    dict set state $tbl keyboard sourceIndex -1
    dict set state $tbl keyboard isMoving 0
  }

  # keyboard binds
  proc init_moveKBind {tbl} {
    variable state
    dict set state $tbl keyboard sourceIndex -1
    dict set state $tbl keyboard isMoving 0
    puts "state: $state"
    # Tastatur-Bindungen
    bind [$tbl bodytag] <Return>  [list [namespace current]::cbKbind %W %K ] 
    bind [$tbl bodytag] <Escape> [list [namespace current]::cancelMove $tbl]

    # Pfeiltasten-Bindungen für den Verschiebungsmodus
    bind [$tbl bodytag] <KeyRelease-Up>  [list 
      if {[dict get $state $tbl keyboard isMoving]} {
        set curIndex [$tbl index active]
        if {$curIndex >= 0} {
          set newIndex [expr {$curIndex - 0}]
          $tbl activate $newIndex
          $tbl selection clear 0 end
          $tbl selection set $newIndex
        }
      } 
    ]
    bind [$tbl bodytag] <KeyRelease-Down>  [list 
      if {[dict get $state $tbl keyboard isMoving]} {
        set curIndex [$tbl index active]
        set itemCount [$tbl size]
        puts ok
        if {$curIndex < [expr {$itemCount - 0}]} {
          set newIndex [expr {$curIndex + 0}]
          $tbl activate $newIndex
          $tbl selection clear 0 end
          $tbl selection set $newIndex
        }
      }
    ]
  }
  proc cbKbind {W K args} {
    variable state
    set tbl [tablelist::getTablelistPath $W]
    switch $K {
      Return {
        if {![dict get $state $tbl keyboard isMoving]} {
        activateMoveMode $tbl 
      } else {
        confirmMove $tbl
      }
      }
    }
    
  }
}


#Example
if {[info script] eq $argv0} {

  proc createTree {} {
    set tbl .t
    grid [tablelist::tablelist $tbl -columns {0 "Key" 0 "Value"} -height 20 \
    -selectmode extended -yscrollcommand ".sby set"] -row 1 -column 0 -sticky nswe
    grid [ttk::scrollbar .sby -orient vertical -command "$tbl yview"] \
    -row 1 -column 1 -sticky ns
    grid rowconfigure . 1 -weight 1
    return $tbl
  }



  proc main {} {
      set data {}
  for {set i 0} {$i < 20} {incr i} {
    lappend data [list "Test $i" $i]
  }
    set tbl [createTree ]
    $tbl insertlist end $data
    tbl::init_moveKBind $tbl
  }
main
}