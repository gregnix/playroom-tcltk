#! /usr/bin/env tclsh

#20240407
#typedList.tcl
#inspired and partly adopted by
#https://wiki.tcl-lang.org/page/typedlist
#https://wiki.tcl-lang.org/page/Tcl%5FObj+proposals
#todo:
# proc del
# type with default values

namespace eval type {
    variable Usertype
    proc set {*var type} {
        variable Usertype
        upvar ${*var} var
        if {[info exist var]} {
            dict set Usertype ${*var} $type
        }
    }
    proc get {*var} {
        variable Usertype
        upvar ${*var} var
        if {[info exist var]} {
            dict get $Usertype ${*var}
        }
    }
    namespace export *
    namespace ensemble create
}

#Example
if {[info script] eq $argv0 && 1 } {
set A [list 100 100 200 200]
type set A rectangle
set B [list 100 100 200 200]
type set B oval

puts [type get A]
puts [type get B]
puts $A
}

#Output
if {0} {
rectangle
oval
100 100 200 200
}
