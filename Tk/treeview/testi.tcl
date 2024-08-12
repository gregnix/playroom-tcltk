#!/usr/bin/env tclsh

# Prozedur, die rekursiv alle Namespaces auflistet und dabei die Prozeduren jedes Namespaces als Wert speichert
proc listns {{parentns ::}} {
    set result [dict create]
    
    # Füge die Prozeduren des aktuellen Namespaces hinzu
    dict set result procs [listnsprocs $parentns]

    # Rekursive Suche nach Child-Namespaces
    foreach ns [namespace children $parentns] {
        dict set result $ns [listns $ns]
    }

    return $result
}

# Prozedur, die alle Prozeduren eines Namespaces auflistet
proc listnsprocs {ns} {
    return [info procs ${ns}::*]
}

# Beispielhafte Ausgabe des Dictionarys
puts [dict get [listns] procs]  ;# Gibt die Prozeduren im globalen Namespace aus
puts [listns]
