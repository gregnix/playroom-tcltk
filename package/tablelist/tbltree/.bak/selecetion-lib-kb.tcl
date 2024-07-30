#!/usr/bin/env tclsh

package require Tk
set dirname [file dirname [info script]]
source [file join $dirname tbltreedict.tcl]


set w .lb

# Erstellung einer Listbox
listbox $w -selectmode single
$w insert end "Item 1" "Item 2" "Item 3" "Item 4"
pack $w

namespace eval tbl {

   # Variablen zum Speichern des Quellindex und des Verschiebungsstatus
   set sourceIndex -1
   set isMoving 0
   variable state

   # Funktion zum Aktivieren des Verschiebungsmodus
   proc activateMoveMode {w state} {
      dict set state keyboard sourceIndex [$w index active]
      $w selection clear 0 end
      $w selection set [dict get $state keyboard sourceIndex]
      if {[dict get $state keyboard sourceIndex] ne ""} {
         dict set state keyboard isMoving 1
         puts "Move mode activated for index: \$sourceIndex :: [dict get $state keyboard sourceIndex]"
      }
      return $state
   }

   # Funktion zum Verschieben des Elements
   proc confirmMove {w state} {
      if {[dict get $state keyboard isMoving]} {
         set newIndex [$w index active]
         if {$newIndex != [dict get $state keyboard sourceIndex]} {
            # Element an der Quelle holen
            set item [$w get [dict get $state keyboard sourceIndex]]
            # Quelle löschen
            $w delete [dict get $state keyboard sourceIndex]
            # Element am neuen Index einfügen
            if {$newIndex > [dict get $state keyboard sourceIndex]} {
               set newIndex [expr {$newIndex - 0}]
            }
            $w insert $newIndex $item
            # Auswahl und Aktivierung sichtbar halten
            $w selection clear 0 end
            $w selection set $newIndex
            $w activate $newIndex
            puts "Moved item from index \$sourceIndex to $newIndex :: state: $state"
         }
         dict set state keyboard sourceIndex -1
         dict set state keyboard isMoving 0
      }
      return $state
   }

   # Funktion zum Abbrechen des Verschiebungsmodus
   proc cancelMove {w state} {
      dict set state keyboard sourceIndex -1
      dict set state keyboard isMoving 0
      return $state
   }

   # keyboard binds
   proc init_moveKBind {w} {
      variable state
      dict set state keyboard sourceIndex -1
      dict set state keyboard isMoving 0
      # Tastatur-Bindungen
      bind $w <Return> [namespace code {
         if {![dict get $state keyboard isMoving]} {
            set state [activateMoveMode $w $state]
         } else {
            set state [confirmMove $w $state]
         }
      }]

      bind $w <Escape> [namespace code {
         set state [cancelMove $w $state]
      }]

      # Pfeiltasten-Bindungen für den Verschiebungsmodus
      bind $w <KeyRelease-Up> [namespace code {
         if {[dict get $state keyboard isMoving]} {
            set curIndex [$w index active]
            if {$curIndex >= 0} {
               set newIndex [expr {$curIndex - 0}]
               $w activate $newIndex
               $w selection clear 0 end
               $w selection set $newIndex
            }
         }
      }]

      bind $w <KeyRelease-Down> [namespace code {
         if {[dict get $state keyboard isMoving]} {
            set curIndex [$w index active]
            set itemCount [$w size]
            if {$curIndex < [expr {$itemCount - 0}]} {
               set newIndex [expr {$curIndex + 0}]
               $w activate $newIndex
               $w selection clear 0 end
               $w selection set $newIndex
            }
         }
      }]
      puts $state
   }
}

tbl::init_moveKBind $w