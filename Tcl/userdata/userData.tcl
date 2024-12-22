#!/usr/bin/env tclsh

#20241222

proc createuserData {{dir tcltk}} {
  # Detect the operating system
  set userData [dict create]
  set os $::tcl_platform(os)
  dict set userData os $os

  # Define directories based on the operating system
  if {$os eq "Windows NT"} {
    # Windows-specific directories
    if {[info exists ::env(LOCALAPPDATA)]} {
      set usercache [file join $::env(LOCALAPPDATA) $dir]
    } else {
      error "Environment variable LOCALAPPDATA is not set."
    }

    if {[info exists ::env(APPDATA)]} {
      set userconfig [file join $::env(LOCALAPPDATA) $dir]
    } else {
      error "Environment variable LOCALAPPDATA is not set."
    }

    if {[info exists ::env(LOCALAPPDATA)]} {
      set userlib [file join $::env(LOCALAPPDATA) $dir "lib" "lib"]
      set usertm [file join $::env(LOCALAPPDATA) $dir "lib" "tm"]
    } else {
      error "Environment variable LOCALAPPDATA is not set."
    }

  } elseif {$os eq "Linux"} {
    # Linux-specific directories
    if {[info exists ::env(XDG_CACHE_HOME)]} {
      set usercache [file join $::env(XDG_CACHE_HOME) $dir]
    } else {
      set usercache [file join $::env(HOME) ".cache" $dir]
    }

    if {[info exists ::env(XDG_CONFIG_HOME)]} {
      set userconfig [file join $::env(XDG_CONFIG_HOME) $dir]
    } else {
      set userconfig [file join $::env(HOME) ".config" $dir]
    }

    if {[info exists ::env(HOME)]} {
      set userlib [file join $::env(HOME) "lib" $dir "lib"]
      set usertm [file join $::env(HOME) "lib" $dir "tm"]
    } else {
      error "Environment variable HOME is not set."
    }

  } else {
    error "Unsupported operating system: $os"
  }

  dict set userData userlib $userlib
  dict set userData usertm $usertm
  dict set userData usercache $usercache
  dict set userData userconfig $userconfig
  return $userData
}

proc makediruserData {userData {make 0}} {
  # Ensure the directories exist
  set userlib [dict get $userData userlib]
  set usertm [dict get $userData usertm]
  set usercache [dict get $userData usercache]
  set userconfig [dict get $userData userconfig]
  foreach dir {userlib usertm usercache userconfig} {
    set path [set $dir]
    if {![file exists $path]} {
      if {$make} {
        lappend res  "file mkdir $path"
        lappend res "Created directory: $path"
      } else {
        lappend res "Not created directory: $path"
      }
      
    } else {
      lappend res "Directory already exists: $path"
    }
  }
  return $res
}


# Example
if {[info script] eq $argv0} {

set userData [createuserData]
set userlib [dict get $userData userlib]
set usertm [dict get $userData usertm]
set usercache [dict get $userData usercache]
set userconfig [dict get $userData userconfig]
set os [dict get $userData os]

# Add the library directory to the Tcl library search path
set auto_path [linsert $auto_path 0 [file normalize $userlib]]
tcl::tm::path add $usertm
# Output debug information
puts "Operating System: $os"
puts "User-specific library directory: $userlib"
puts "User-specific library directory: $usertm"
puts "User-specific cache directory: $usercache"
puts "User-specific config directory: $userconfig"
puts "Current auto_path: $auto_path"
puts \n
puts [join [makediruserData $userData 0] \n]

}
