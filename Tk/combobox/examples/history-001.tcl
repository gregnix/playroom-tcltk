#! /usr/bin/env tclsh

v 20250219
package require Tk
namespace eval historycombobox {
    variable historyDict
    set historyDict [dict create]
}

proc historycombobox::create {parent name maxHistory args} {
    variable historyDict

    array set options {
        -width 20
        -values {}
        -var ""
    }
    array set options $args

    # If no -textvariable is provided, generate an anonymous variable
    if {$options(-var) eq ""} {
        set options(-var) "[namespace current]::historyCombobox_${name}"
        set ${options(-var)} ""  ;# Create the variable in the namespace
    } 

    set widget "$parent.$name"

    # Create the combobox
    ttk::combobox $widget -width $options(-width) -textvariable $options(-var) \
        -values $options(-values) -postcommand [list historycombobox::update $widget]

    # If no history exists for this widget, initialize it
    if {![dict exists $historyDict $widget]} {
        dict set historyDict $widget $options(-values)
    }

    # Bind events to save history on selection and return key press
    bind $widget <<ComboboxSelected>> [list historycombobox::save $widget $options(-var) $maxHistory]
    bind $widget <Return> [list historycombobox::save $widget $options(-var) $maxHistory]

    return $widget
}

proc historycombobox::save {widget varName maxHistory} {
    variable historyDict

    # Retrieve value without using upvar
    set value [uplevel #0 "set $varName"]

    if {$value eq ""} return

    # Use dict get only if the entry exists
    if {[catch {dict get $historyDict $widget} currentValues]} {
        set currentValues {}
    }

    set currentValues [historycombobox::listremove $currentValues $value]
    set currentValues [linsert $currentValues 0 $value]

    while {[llength $currentValues] > $maxHistory} {
        set currentValues [lreplace $currentValues end end]
    }

    dict set historyDict $widget $currentValues
    $widget configure -values $currentValues
}

proc historycombobox::update {widget} {
    variable historyDict
    if {[dict exists $historyDict $widget]} {
        $widget configure -values [dict get $historyDict $widget]
    }
}

proc historycombobox::listremove {list value} {
    set newlist {}
    foreach item $list {
        if {$item ne $value} {
            lappend newlist $item
        }
    }
    return $newlist
}

# Example
if {[info exists argv0] && [info script] eq $argv0} {
    wm title . "Combobox with History"

    ttk::frame .fr
    pack .fr -expand 1 -fill both

    set cb1 [historycombobox::create .fr mycombo1 5  -width 30 -values {"Option 1" "Option 2" "Option 3"}]
    set textVar1 [$cb1 cget -textvariable]
    pack $cb1 -padx 10 -pady 10
    $cb1 current 0
    puts "Combobox 1 -textvariable: $textVar1 = [set $textVar1]"
    
    set cb2 [historycombobox::create .fr mycombo2 5 -var myvar -width 30 -values {"Option 1" "Option 2" "Option 3"}]
    set textVar2 [$cb2 cget -textvariable]
    pack $cb2 -padx 10 -pady 10
    $cb2 current 1
    puts "Combobox 2 -textvariable: $textVar2 = [set $textVar2]"

    puts "\n **Global Variables:**"
    puts "[info globals]"
  
    puts "\n **Variables in `historycombobox` Namespace:**"
    namespace eval historycombobox {
        puts "[info vars]"
    }
}

if {0} {
-textvariable ::historycombobox::historyCombobox_mycombo1 : Option 1
-textvariable myvar : Option 2
g: tcl_rcFileName tcl_version argv0 argv tcl_interactive tk_library tk_version auto_path errorCode cb1 tk_strictMotif errorInfo cb2 auto_index env tcl_pkgPath tcl_patchLevel textVar1 argc textVar2 tk_patchLevel myvar tcl_library tcl_platform
l: 
v: historyCombobox_mycombo1 historyDict tcl_rcFileName tcl_version argv0 argv tcl_interactive tk_library tk_version auto_path errorCode cb1 tk_strictMotif errorInfo cb2 auto_index env tcl_pkgPath tcl_patchLevel textVar1 argc textVar2 tk_patchLevel myvar tcl_library tcl_platform
}
