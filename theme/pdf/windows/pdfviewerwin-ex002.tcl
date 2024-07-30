#!/usr/bin/env tclsh

# 2024-03.19
set dirname  [file dirname [info script]]
set filename  ma
set pdffile [join [list $filename pdf] "."]

set assoc [exec cmd /c assoc .pdf]
set ftype [lindex [split $assoc "="] end]
set pdfviewer  [lindex [string map {\\ \\\\} [split [exec cmd /c  ftype $ftype] "="]] 1 0 ]

exec cmd /c  $pdfviewer $pdffile