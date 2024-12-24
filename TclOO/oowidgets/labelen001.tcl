#! /usr/bin/env tclsh

#20241224
#
#https://htmlpreview.github.io/?https://raw.githubusercontent.com/mittelmark/oowidgets/master/tutorial.html
#example Composition
# with changes with method widgetall for args
# frame
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
        if {[dict is_dict $args]} {
            puts "if $args"
        } else {
            puts "else $args"
        }
        lassign [my widgetall $args] args largs eargs
        set lab [ttk::label $path.lab {*}$largs]
        set ent [ttk::entry $path.ent {*}$eargs]
        pack $lab -side left -padx 5 -pady 5
        pack $ent -side left -padx 5 -pady 5
        my configure {*}$args
    }
    # expose the internal widgets using subcommands
    method widgetall {argstmp} {
        set args ""
        if {[dict exists $argstmp frame]} {
            set args [dict get $argstmp frame]
            set argstmp [dict remove $argstmp frame]
        } else {
            set args $argstmp
        }
        if {[dict exists $argstmp label]} {
            set largs [dict get $argstmp label]
            set argstmp [dict remove $argstmp label]
        } else {
            set largs ""
        }
        if {[dict exists $argstmp entry]} {
            set eargs [dict get $argstmp entry]
            set argstmp [dict remove $argstmp entry]
        } else {
            set eargs ""
        }
        lappend args {*}$argstmp
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

puts original
set lent [::comp::labentry .lentry -relief solid]
pack $lent -side top -padx 10 -pady 20
$lent label configure -text "Label: "
$lent entry insert 0 "Some text"
puts [$lent entry]
bind [$lent entry] <Destroy> { puts "destroyed entry" }
bind $lent <Destroy> { puts "destroyed labentry" }
#destroy $lent

puts "Version 2"
set lent2 [::comp::labentry  .lentry2 frame {-relief sunken} label {-text "Label:"} entry {-justify right}]
pack $lent2 -side top -padx 10 -pady 20
$lent2 label configure -background red
$lent2 entry insert 0 "Some text 2"
puts [$lent2 entry]
bind [$lent2 entry] <Destroy> { puts "destroyed entry" }
bind $lent2 <Destroy> { puts "destroyed labentry" }
puts [$lent2 configure]
puts \n
puts [$lent2 label configure]
puts \n
puts [$lent2 entry configure]
