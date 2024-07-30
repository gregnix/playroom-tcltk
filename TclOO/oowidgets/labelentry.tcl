package require Tk
package require oowidgets

namespace eval ::comp { }
oowidgets::widget ::comp::LabEntry {
    variable ent
    variable lab
    variable woptions
    constructor {path args} {
        # the main widget is the frame
        # add an additional label
        # a dict with internal widget and option 1 (internal widget) 
        # and option new (widget)
        set woptions {label {-text -labeltext}}
        my install ttk::frame $path -labeltext ""
        set lab [ttk::label $path.lab]
        set ent [ttk::entry $path.ent]
        pack $lab -side left -padx 5 -pady 5
        pack $ent -side left -padx 5 -pady 5
        my label configure -text [my cget -labeltext]
        my configure {*}$args

    }
    # option new (widget) also changes option (internal widget)
    method configure {args} {
        set result [next {*}$args]
        foreach childw [dict keys $woptions] {
            foreach {option value} [dict get $woptions $childw] {
                my $childw configure $option [my cget $value]
            }
        }
        return $result
    }
    # If the option is changed, the associated option is also changed
    method wconfigure {childw args} {
        my variable widgetOptions
        set dvar [dict get $woptions $childw]
        set keys [dict keys $dvar]
        foreach {option value} [lrange {*}$args 1 end] {
            if {$option in $keys } {
                set widgetOptions([dict get $dvar $option]) $value
            }
        }
    }
    # expose the internal widgets using subcommands
    method label {args} {
        if {[llength $args] == 0} {
            return $lab
        }
        set result [$lab {*}$args]
        if {[lindex $args 0] == "configure" && [llength $args] > 2  && [expr {([llength $args] -1)%2}] == 0}  {
            my wconfigure label $args
        }
        return $result
    }
    method entry {args} {
        if {[llength $args] == 0} {
            return $ent
        }
        set result [$ent {*}$args]
        if {[lindex $args 0] == "configure" && [llength $args] > 2  && [expr {([llength $args] -1)%2}] == 0}  {
            my wconfigure entry $args
        }
        return $result
    }
    # you could as well delegate all methods to the entry widget
    # making it your default widget
    method unknown {args} {
        $ent {*}$args
    }
}

puts [info commands ::comp::*]

set lent [::comp::labentry .lentry -labeltext Label0:]
pack $lent -side top -padx 10 -pady 20

puts " \n"
puts "label configure: [$lent label configure -text ]"
puts "widget configure: [$lent  configure -labeltext ]"

$lent label configure -text "Label: "
$lent entry insert 0 "Some text"

puts \n
puts "label configure: [$lent label configure -text ]"
puts "widget configure: [$lent  configure -labeltext ]"


if {0} {
Output;
 
::comp::LabEntry ::comp::labentry
 

label configure: -text text Text {} Label0:
widget configure: Label0:


label configure: -text text Text {} {Label: }
widget configure: Label: 

}
