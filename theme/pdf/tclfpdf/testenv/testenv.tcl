#! /usr/bin/env tclsh

#v202502122201
# helper.tcl
set dirname [file join [file dirname [info script]]]
source -encoding utf-8 [file join $dirname helper.tcl]
#source -encoding utf-8 [file join $dirname lib helper.tcl]

# test environment
testPackage [file dirname [info script]]
infoPkg tclfpdf 1

# two errors
if {0} {
  tree -d
  .
  └── lib
  ├── pkg
  │   └── tclfpdf-master
  │       ├── addons
  │       ├── examples
  │       ├── font
  │       ├── makefont
  │       ├── manual
  │       └── misc
  └── tm


  ./addons/multicell_table.tcl
  # 1
  error in row 52:
  variable MCT_widths MCT_aligns
  variable MCT_widths ; variable MCT_aligns
  # 2
  error in row 68, no effect?
  set a [lindex MCT_aligns $i ]
  set a [lindex $MCT_aligns $i ]
}

# Export of random missing
namespace eval tclfpdf {
  namespace export random
}

set allex  {multi_line_cells.tcl multicell.pdf utf8.tcl utf8.pdf \
dash.tcl dash.pdf ellipse.tcl ellipse.pdf rotation.tcl rotation.pdf \
link.tcl link.pdf links_and_flowing_text.tcl flow.pdf}

set exampledir [file join $dirname lib pkg tclfpdf-master examples]
set pwd [pwd]
cd $exampledir
puts "Tcl system encoding: [encoding system]"
foreach {exat exap}  $allex {

  # example
  set example $exat
  set examplePdf $exap
  #source -encoding utf-8 [file join $exampledir $example]
  source -encoding [encoding system] [file join $exampledir $example]
  #
  file copy -force $examplePdf $::tcl_platform(platform)_${examplePdf}
  pdfViewer $::tcl_platform(platform)_${examplePdf}
}
cd $pwd
