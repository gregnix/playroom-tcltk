package require oowidgets
package require dicttool
namespace eval ::comp { }
oowidgets::widget ::comp::LabEntry {
    variable ent
    variable lab
    constructor {path args} {
        # the main widget is the frame
        # add an additional label
        my install ttk::frame $path
  
        lassign [my widget $args] args largs eargs
        set lab [ttk::label $path.lab {*}$largs]
        set ent [ttk::entry $path.ent {*}$eargs]
        pack $lab -side left -padx 5 -pady 5
        pack $ent -side left -padx 5 -pady 5
        my configure {*}$args
    }
    # expose the internal widgets using subcommands
    method widget {argstmp} {
        set args ""
        if {[dict exists $argstmp frame]} {
            set args [dict get $argstmp frame]
        } else {
            set args ""
        }
        if {[dict exists $argstmp label]} {
            set largs [dict get $argstmp label]
        } else {
            set largs ""
        }
        if {[dict exists $argstmp entry]} {
            set eargs [dict get $argstmp entry]
        } else {
            set eargs ""
        }
        
        return [list $args $largs $eargs]
    }
    method label {args} {
        if {[llength $args] == 0} {
            return $lab
        }
        $lab {*}$args
    }
    method entry {args} {
        if {[llength $args] == 0} {
            return $ent
        }
        $ent {*}$args
    }
    # you could as well delegate all methods to the entry widget
    # making it your default widget
    method unknown {args} {
        $ent {*}$args
    }
}

puts [info commands ::comp::*]

set lent [::comp::labentry  .lentry frame {-relief sunken} label {-text "Label:"} entry 2{-background yellow -justify right}]
pack $lent -side top -padx 10 -pady 20
$lent label configure -background red 
$lent entry insert 0 "Some text"
$lent entry configure -background red
puts [$lent entry]
bind [$lent entry] <Destroy> { puts "destroyed entry" }
bind $lent <Destroy> { puts "destroyed labentry" }
puts [$lent configure]
puts \n
puts [$lent label configure]
puts \n
puts [$lent entry configure]