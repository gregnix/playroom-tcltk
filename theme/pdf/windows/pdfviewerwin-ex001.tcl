#!/usr/bin/env tclsh

# 2024-03.19
set dirname  [file dirname [info script]]
set filename  ma
set pdffile [join [list $filename pdf] "."]

exec cmd /c "" $pdffile
#exec cmd /c start "" $pdffile