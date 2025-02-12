#! /usr/bin/env tclsh

# v202502112157

# Function to test and modify package paths
proc testPackage {{dirname ""}} {
  # Modify the package path
  # The package directory is always added to the beginning of auto_path
  if {$dirname eq "" } {
    set dirname [file dirname [info script]]
  }
  set dirlibtm [file join $dirname lib tm]  ;# Path to Tcl Modules (tm)
  set dirlibpkg [file join $dirname lib pkg] ;# Path to package directory
  
  # Always add package directory at the beginning of auto_path
  set ::auto_path [linsert $::auto_path 0 $dirlibpkg]
  
  # Add the tm directory to the Tcl Module search path
  ::tcl::tm::path add $dirlibtm

  # Collect results for debugging
  lappend res auto_path $::auto_path
  lappend res tm [tcl::tm::path list] 
  
  return $res
}

# Function to retrieve information about a package
proc infoPkg {pkg {output 0}} {
  # Set package details
  set infoPackage(package) $pkg
  set infoPackage(dirname) [file dirname [info script]]
  set infoPackage(dirlibtm) [file join [file dirname [info script]] lib tm]
  set infoPackage(dirlibpkg) [file join [file dirname [info script]] lib pkg]

  # Ensure the package directory is prioritized in auto_path
  set ::auto_path [linsert $::auto_path 0 $infoPackage(dirlibpkg)]
  
  # Require the package
  package require $infoPackage(package)

  # Collect package information
  lappend infos "# Package Information:"
  lappend infos "$infoPackage(package): [package provide $infoPackage(package)]"
  lappend infos "[package ifneeded $infoPackage(package) \
[lindex [lsort -dictionary [package versions $infoPackage(package)]] end]]"
  lappend infos "Tcl Version: [info patchlevel]"
  lappend infos "Executable Path: [info nameofexecutable]"
  
  # Store the collected information in an array
  set infoPackage(infos) $infos

  # Print output if requested
  if {$output} {
    puts "\n[join $infos "\n"]\n"
  }

  return [array get infoPackage]
}

# Function to open a PDF file with the default viewer
proc pdfViewer {pdffile} {
  # Detect platform and execute the appropriate command
  switch -- $::tcl_platform(platform) {
    windows {
      set os "windows"
      exec cmd /c "" $pdffile &
    }
    unix {
      set os "unix"
      exec {*}[auto_execok xdg-open] $pdffile &
    }
    macintosh {
      set os "macintosh"
      # macOS-specific command could be added here
    }
    default {
      set os "default"
    }
  }
}
