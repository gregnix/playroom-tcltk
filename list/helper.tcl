#!/usr/bin/env tclsh
 
# helper procs
 
#https://wiki.tcl-lang.org/page/Extending+TclOO+with+metaclasses
proc iota {a {b ""}} {
    if {$b eq ""} {
        set b $a
        set a 0
    }
    for {set r {}} {$a<$b} {incr a} {
        lappend r $a
    }
    return $r
}

# this is generally useful.
# with multiple arguments it is equivalent to:
#   [concat {*}[lmap ...]]
# which under some circumstances can be thought of as:
#   [join [lmap ...] " "]
# the pattern comes up a lot.
# Alternative names:  [lconcat] [ljoin] [lmap*]
#
proc lconcat args {
    concat {*}[uplevel 1 lmap $args]
}

# normal map, but does multiple arguments:
#  % map {expr} {1 2 3} {+ - *} {2 4 5}
#  {3 -2 15}
#
proc map {cmdPrefix args} {
    set names [iota [llength $args]]
    set forArgs [lconcat n $names a $args {list $n $a}]
    set cmdArgs [lconcat name $names {string cat \$ $name}]
    set body "$cmdPrefix $cmdArgs"
    set body "uplevel 1 \[list $body\]"
    lmap {*}$forArgs $body
}

#https://wiki.tcl-lang.org/page/request+new+command+lstride
proc lmapflat {varnames list script} {
    concat {*}[uplevel 1 [list lmap $varnames $list $script]]
}

#https://wiki.tcl-lang.org/page/Striding+a+list
proc lstride {list n} {
  set res {}
  for {set i 0; set j [expr {$n-1}]} {$i < [llength $list]} {incr i $n; incr j $n} {
     lappend res [lrange $list $i $j]
  }
  return $res
}




##############################
if {[info script] eq $argv0} {

#######
# iota
puts [iota 10]

##########
# lmapflat
set numbers [list 1 2 3 4 5]
set result [lmapflat {x} $numbers {expr {$x * 2}}]
puts $result

# Beispiel: Umwandeln jeder Zeichenkette in Großbuchstaben
set strings [list "apple" "banana" "cherry"]
set result [lmapflat {x} $strings {string toupper $x}]

# Ausgabe des Ergebnisses
puts $result
    
#########    
# lconcat 

# Liste von Zahlen
set numbers [list 1 2 3 4 5]
# Verwenden von lconcat, um jede Zahl mit 2 zu multiplizieren
set result [lconcat {x} $numbers {expr {$x * 2}}]
# Ausgabe des Ergebnisses
puts $result

# Liste von Zeichenketten
set strings [list "apple" "banana" "cherry"]
# Verwenden von lconcat, um jede Zeichenkette in Großbuchstaben umzuwandeln
set result [lconcat {x} $strings {string toupper $x}]
# Ausgabe des Ergebnisses
puts $result
   
# Liste von Listen
set listOfLists [list [list 1 2] [list 3 4] [list 5 6]]
# Verwenden von lconcat, um das erste Element jeder Unterliste zu extrahieren
set result [lconcat {x} $listOfLists {lindex $x 0}]
# Ausgabe des Ergebnisses
puts $result
   

# map
# Beispielaufruf der map-Prozedur
set list1 {1 2 3}
set list2 {+ - *}
set list3 {2 4 5}
# Berechnen der Summe der Elemente
set result [map {expr} $list1 $list2 $list3]
# Ausgabe des Ergebnisses
puts $result

# lstride
puts [lstride  {a b c d e f g} 2]



if {0} {
Output:

0 1 2 3 4 5 6 7 8 9
2 4 6 8 10
APPLE BANANA CHERRY
2 4 6 8 10
APPLE BANANA CHERRY
1 3 5
3 -2 15
{a b} {c d} {e f} g


    
}

    
    
}
