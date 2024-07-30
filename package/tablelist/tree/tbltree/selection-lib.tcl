#!/usr/bin/env tclsh

package require Tk

# Funktion zum Festlegen des Quellindex beim Mausklick
proc setSourceIndex {W x y} {
   set w [tablelist::getTablelistPath $W]
    foreach {w x y} [tablelist::convEventFields $W $x $y] {}
    set sourceIndex [$w index @$x,$y]
    $w selection clear 0 end
    $w selection set $sourceIndex
    return $sourceIndex
}

# Funktion zum Verschieben des Elements beim Loslassen der Maustaste
proc moveElement {W x y sourceIndex} {
    # after 0 before, after 1 after
    set after 0
    set w [tablelist::getTablelistPath $W]
    foreach {w x y} [tablelist::convEventFields $W $x $y] {}
    if {$sourceIndex != -1} {
        set newIndex [$w index @$x,$y]
        if {$newIndex != $sourceIndex} {
            
            set sidx $sourceIndex
            set pidx [$w parentkey $newIndex]
            set cidx  [expr {$after + [$w childindex $newIndex]}]
            $w move $sidx $pidx $cidx
            $w selection clear 0 end
            $w selection set $newIndex
            $w activate $newIndex
        }
    }
}

# Funktion zum Aktualisieren der Auswahl beim Ziehen
proc updateSelection {W x y} {
    set w [tablelist::getTablelistPath $W]
    foreach {w x y} [tablelist::convEventFields $W $x $y] {}
    set newIndex [$w index @$x,$y]
    $w selection clear 0 end
    $w selection set $newIndex
    $w activate $newIndex
}



