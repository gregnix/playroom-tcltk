
#!/usr/bin/env tclsh

# 20240112
#package require Tk
package require platform

namespace eval infop {
  variable cmd
  # platform
  switch -- $::tcl_platform(platform) {
    windows {
      set cmd(os) "windows"
      set cmd(where) [file normalize C:\\Windows\\System32\\where.exe]
      proc start {name} {
        package require twapi
        ::twapi::create_process {} -cmdline "cmd /c start \"\" \"$name\"" -showwindow hidden
      }

    }
    unix {
      set cmd(os) "unix"
      set cmd(where) whereis
    }
    macintosh {
      set cmd(os) "macintosh"

    }
    default {
      set cmd(os) "default"
    }
  }



  proc systemInfo {{output 1}} {
    variable cmd
    set info ""

    lappend info "==== Tcl Information [clock format [clock seconds] -format "%Y.%m.%d_%H-%M" ] ===="
    lappend info "Tcl Version: $::tcl_version"
    lappend info "Tcl Patch Level: $::tcl_patchLevel"
    lappend info "info nameofexecutable: [info nameofexecutable]"
    set cmd(bin) [file tail [info nameofexecutable]]
    lappend info "bin: [file tail [info nameofexecutable]]"
    lappend info "Startup File: $::tcl_rcFileName"
    catch {set msg  $::tcl_precision} msg
    lappend info "FP Precision: $msg"

    lappend info "\n==== Command Line Arguments ===="
    lappend info "argv0: $::argv0"
    lappend info "argc: $::argc"
    lappend info "argv: $::argv"

    if {[info exists ::args]} {
      lappend info "Arguments List:"
      set i 0
      foreach v $::args {
        lappend info "[incr i]: $v"
      }
      lappend info "--- End of Arguments ---"
    } else {
      lappend info "Arguments List: non-existent"
    }

    lappend info "\n==== Platform Details ===="
    foreach {k v} [array get ::tcl_platform] {
      lappend info "$k: $v"
    }
    lappend info "--- End of Platform Details ---"

    lappend info "\n==== Tcl Library Paths ===="
    lappend info "::tcl_library:"
    set i 0
    foreach v $::tcl_library {
      lappend info "[incr i]: $v"
    }
    lappend info "--- End of tcl_library ---"

    lappend info "\n==== tcl_pkgPath ===="
    if {[info exists ::tcl_pkgPath]} {
      set i 0
      foreach v $::tcl_pkgPath {
        lappend info "[incr i]: $v"
      }
    } else {
      lappend info "tcl_pkgPath: non-existent"
    }
    lappend info "--- End of tcl_pkgPath ---"

    lappend info "\n==== auto_path ===="
    set i 0
    foreach v $::auto_path {
      lappend info "[incr i]: $v"
    }
    lappend info "--- End of auto_path ---"

    lappend info "\n==== tcl::tm::path ===="
    set i 0
    foreach v [tcl::tm::path list] {
      lappend info "[incr i]: $v"
    }
    lappend info "--- End of tcl::tm::path ---"

    lappend info "\n==== tcl::pkgconfig ===="
    foreach item [tcl::pkgconfig list] {
      lappend info "$item: [tcl::pkgconfig get $item]"
    }
    lappend info "--- End of tcl::pkgconfig ---"

    lappend info "\n==== Environment Variables ===="
    foreach infoenv {LD_LIBRARY_PATH TCLLIBPATH HOME XDG_CACHE_HOME XDG_CONFIG_HOME APPDATA LOCALAPPDATA} {
      catch {set msg  $::env($infoenv)} msg
      lappend info "$infoenv: $msg"
    }
    lappend info "--- End of Environment Variables ---"

    lappend info "\n==== where bin ===="
    if {$cmd(os) eq "windows"} {

      #set a "cmd /c start \"\" $cmd(where) c:/ /R  $cmd(bin)"
      #set a dir
      #puts $a
      #set a {*}[exec $a]
      #set a [exec cmd.exe /c start  {*}[$cmd(where) c:/tmp /R  $cmd(bin)] ]
      #set a [exec cmd $cmd(where) c:/tmp /R  $cmd(bin) ]
      #set log [start $cmd(where) -a $cmd(bin)]
      #puts "log $log"
      set a [exec  $cmd(where) $cmd(bin)]
      set a [string range $a [string first " " $a] end ]
      set a [string map {"\\" /} $a ]
      puts $a
    } else {
      set a [exec  $cmd(where) $cmd(bin)]
      set a [string range $a [string first " " $a] end ]
      set a [string map {"\\" /} $a ]
      puts $a
    }
    set i 0
    foreach v $a {
      lappend info "[incr i]: [file normalize $v]"
    }

    lappend info "--- End of Environment where bin ---"


    # Tk
    if {[info exists ::tk_library]} {
      lappend info "\n==== Tk Information ===="
      lappend info "Tk Version: $::tk_version"
      lappend info "Tk Patch Level: $::tk_patchLevel"
      lappend info "Tk windowingsystem: [tk windowingsystem]"
      catch {set msg  $::tk::scalingPct} msg
      lappend info "Tk scalingPct: $msg"
      catch {set msg $::tk::svgFmt} msg
      lappend info "Tk svgFmt: $msg"
      lappend info "\n==== Tk Library Paths ===="
      lappend info "tk_library:"
      set i 0
      foreach v $::tk_library {
        lappend info "[incr i]: $v"
      }
      lappend info "--- End of tk_library ---"

      lappend info "\n==== tk::Priv ===="
      foreach {k v} [array get ::tk::Priv] {
        lappend info "$k: $v"
      }
      lappend info "--- End of tk::Priv ---"
    }
    if {$output} {
      puts $info
    }
    return $info
  }

  proc savefile {filename data } {
    set fileid [open $filename w]
    foreach datum [split $data "\n"] {
      puts  $fileid $datum
    }
    close $fileid
  }

  proc openfile_as_list {file} {
    set fp [open $file r]
    fconfigure $fp -encoding utf-8
    set data {}
    while {[gets $fp line] >= 0} {
      lappend data $line
    }
    close $fp
    return $data
  }

  proc parse_key_value_list {file} {
    set raw_list [openfile_as_list $file]
    set parsed_list {}

    foreach line $raw_list {
      # Ignoriere leere Zeilen
      if {[string trim $line] eq ""} {
        lappend parsed_list [list $line ""]tolkien

        continue
      }
      if {[regexp {^\s*(====|---)} $line]} {
        lappend parsed_list [list $line ""]
        continue
      }
      # Prüfe auf das Format "key: value"
      if {[regexp {^(.+?):\s*(.*)$} $line -> key value]} {
        lappend parsed_list [list ${key}: $value]
      } else {
        # Wenn kein ":" vorhanden ist, speichere die gesamte Zeile als Schlüssel ohne Wert
        lappend parsed_list [list $line ""]
      }
    }

    return $parsed_list
  }
  # Tabellarische Ausgabe der Ergebnisse
  proc print_table {data} {
    #set data [systemInfo 0]
    set parsed_list {}
    foreach line $data {
      # Ignoriere leere Zeilen
      if {[string trim $line] eq ""} {
        lappend parsed_list [list $line ""]
        continue
      }
      if {[regexp {^\s*(====|---)} $line]} {
        lappend parsed_list [list $line ""]
        continue
      }
      # Prüfe auf das Format "key: value"
      if {[regexp {^(.+?):\s*(.*)$} $line -> key value]} {
        lappend parsed_list [list ${key}: $value]
      } else {
        # Wenn kein ":" vorhanden ist, speichere die gesamte Zeile als Schlüssel ohne Wert
        lappend parsed_list [list $line ""]
      }
    }
    foreach kv $parsed_list {
      append res "[lindex $kv 0] [lindex $kv 1]" "\n"
    }
    return $res
  }

  proc saveauto {data} {
    foreach k $data {
      append allinfo $k "\n"
    }
    set dirname [file dirname [info script]]
    set filename  [join [lrange [file split [info nameofexecutable] ] 1 end] ""].txt
    if {[package provide Tk] eq ""} {
      package require Tk
    }
    set file [tk_getSaveFile -initialfile $filename -initialdir $dirname -filetypes {{{Text Files}  {.txt}}}]
    if {$file ne ""} {
      savefile $file  $allinfo
    }
    return $file
  }

  namespace export *
  puts "systeminfo [namespace current]"
}



################################
#Example
if {[info exists argv0] && [info script] eq $argv0} {
  namespace import infop::*
  set data [systemInfo 0]
  #  saveauto $data
  set dirname [file dirname [info script]]
  set libfile [file join $dirname lib txtwidlib.tcl]
  if {[file exists $libfile] || [info procs textwid::textwid ] eq "textwid::textwid" } {
    source -encoding utf-8 [file join $dirname lib txtwidlib.tcl]
    set txttop [textwid::textwid]
    $txttop  insert end $txttop
    $txttop  insert end "\n"
    $txttop  insert end [print_table $data]
    wm withdraw .
  } else {
    puts [print_table $data]
  }
  puts [info procs textwid::textwid2 ]
}

