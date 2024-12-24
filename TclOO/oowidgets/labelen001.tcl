#! /usr/bin/env tclsh

#20241224
#
#https://htmlpreview.github.io/?https://raw.githubusercontent.com/mittelmark/oowidgets/master/tutorial.html
#example Composition

package require oowidgets

namespace eval ::comp { }
oowidgets::widget ::comp::LabEntry {
    variable ent
    variable lab
    constructor {path args} {
        # the main widget is the frame
        # add an additional label
        my install ttk::frame $path
        set lab [ttk::label $path.lab]
        set ent [ttk::entry $path.ent]
        pack $lab -side left -padx 5 -pady 5
        pack $ent -side left -padx 5 -pady 5
        my configure {*}$args
    }
    # expose the internal widgets using subcommands
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

