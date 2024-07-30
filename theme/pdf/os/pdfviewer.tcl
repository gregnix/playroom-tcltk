#!/usr/bin/env tclsh

#20240415
proc pdfViewer {pdffile} {
  # platform
  switch -- $::tcl_platform(platform) {
    windows {
      set os "windows"
      exec cmd /c "" $pdffile
    }
    unix {
      set os "unix"
      exec {*}[auto_execok xdg-open] $pdffile
    }
    macintosh {
      set os "macintosh"

    }
    default {
      set os "default"
    }
  }
}

#Example
if {[info script] eq $argv0} {
  set dirname  [file dirname [info script]]
  set filename  ma
  set pdffile [join [list $filename pdf] "."]
  pdfViewer $pdffile
}
