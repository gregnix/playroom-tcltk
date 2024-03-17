#! /usr/bin/env tclsh

# 2024-03-17
# templates for new tcl tk scripts
# Delete what you don't need
if {1} {

# tm libs
set addtmlib ~/lib/tcltk/tm
tcl::tm::path add $addtmlib

# lib
lappend auto_path [file join [file dirname [info script]] lib ]

# libs first position
# relativ
set auto_path [linsert $auto_path 0 [file normalize  "../.."]]
#absolut
set addlib  ~/lib/tcltk/lib
set auto_path [linsert $auto_path 0 [file normalize  $addlib]]

#! /usr/bin/env tclsh
tcl::tm::path add [file join [file dirname [info script]] lib tm]
lappend auto_path [file join [file dirname [info script]] lib ]
    
set dirname [file dirname [info script]]
set libdirname [file join [file dirname [info script]] lib tm]      

# winSys
# from tablelist - demos - config.tcl
variable winSys
if {[catch {tk windowingsystem} winSys] != 0} {
	switch $::tcl_platform(platform) {
    unix	{ set winSys x11 }
    windows	{ set winSys win32 }
    macintosh	{ set winSys classic }
}
}
puts "  winSys: $winSys"
     
# platform 
switch -- $::tcl_platform(platform) {
  windows {
     set os "windows"
    }
    unix {
     set os "unix"
    }
    macintosh {
     set os "macintosh"

    }
    default { 
    set os "default"
    }
} 
puts "  os: $os"

#package
package require Tk
}


#Output
if {0} {
    Output:
    
}


#Example
if {[info script] eq $argv0} {
    puts "  [info script]"
    puts "  auto_pat:\n[join $auto_path "\n"]"
    puts "  tm path:\n[join [tcl::tm::path list] "\n"]"
}
