#!/usr/bin/env tclsh

package require twapi
# Version 24.03.2024 2200
# only Windows
# both Brother bPAC SDK 32 Bit und 64 Bit install
# P-Touch Editor from Brother
# Make a label with the P-Touch Editor from Brother,
# create a text field there and save it under ../lbx/name.lbx
# ../log  and ../export for bmp file
# Brother QL-550 print only bPAC 32 bit

namespace eval Bpac {
  variable bpoVariable
  variable result

  set bpoVariable [dict create]
  dict set bpoVariable PrintOptionConstants {
    bpoDefault {value 0x0 desc {The current drive settings are adopted}}
    bpoAutoCut {value 0x1 desc {Autocut is applied.}}
    bpoCutPause {value 0x1 desc {Pause to cut is applied. Valid only with models not supporting the auto cut function}}
    bpoCutMark {value 0x2 desc {Cut mark is inserted. Valid only with models not supporting the auto cut function.}}
    bpoHalfCut {value 0x200 desc {Executes half cut.}}
    bpoChainPrint {value 0x400 desc {Continuous printing is performed.
    The final label is not cut, but when the next labels are output, the preceding blank is cut in line with the cut option setting.}}
    bpoTailCut {value 0x800  desc {Whenever a label is output, the trailing end of the form is forcibly cut to leave a leading blank for the next label output.}}
    bpoSpecialTape {value 0x00080000 desc {No cutting is performed when printing on special tape. Valid only with PT-2430PC.}}
    bpoCutAtEnd {value 0x04000000 desc {"Cut at end" is performed.}}
    bpoNoCut {value 0x10000000 desc {No cutting is performed. Valid only with models supporting cut functions.}}
    bpoMirroring {value 0x4 desc {Executes mirror printing.}}
    bpoQuality {value 0x0010000 desc {Fine-quality printing is performed.}}
    bpoHighSpeed {value 0x01000000 desc {High-speed printing is performed.}}
    bpoHighResolution {value 0x10000000 desc {High-resolution printing is performed}}
    bpoColor {value 0x8 desc color} {value  desc {Color printing is performed.}}
    bpoMono {value 0x10000000 desc {Monochrome printing is performed. Valid only with models supporting the color printing function.}}
    bpoContinue 0x40000000 {value  desc {Combines with printing for the following DoPrint( ) so that it is a single print job. As a result, when the next DoPrints are called up, the front margins are not output.}}
  }
  dict set bpoVariable "Brother QL-550" {
    bpoAutoCut {value &H1 desc {}}
    bpoNoCut {value &H10000000 desc {}}
  }
  dict set bpoVariable "Brother QL-560" {
    bpoAutoCut {value &H1 desc {}}
    bpoNoCut {value &H10000000 desc {}}
    bpoCutAtEnd {value &H4000000 desc {}}
  }
  dict set bpoVariable "ExportType" {
    bexOpened  {value 0x0 desc {}}
    bexLbx {value 0x2  desc {}}
    bexLbl {value 0x2 desc {}}
    bexBmp {value 0x4 desc {}}
    bexPAF {value 0x5 desc {}}
  }
  dict set bpoVariable "FontEffect" {
    bfeNoEffects {value 0x0 desc {No effects}}
    bfeShadowLight {value 0x1 desc {Shadow effect 1}}
    bfeShadów {value 0x2 desc {Shadow effect 2}}
    bfeHorizontal {value 0x3 desc {Striping}}
    bfeOutline {value 0x4 desc {Outline}}
    bfeSurround {value 0x5 desc {Border}}
    bfeFrameOut {value 0x6 desc {Framing}}
    bfeInvertTextColors {value 0x7 desc {Invert text colors}}
  }
  dict set bpoVariable "ObjectAttribute" {
    boaTextOption {value 0x0 desc {Text option}}
    boaFontBold {value 0x1 desc {Font bold}}
    boaFonrEffect {value 0x2 desc {Font effect}}
    boaFontItalics {value 0x3 desc {Font italic}}
    boaFontMaxPoint {value 0x4 desc {Maximum point count}}
    boaFontName {value 0x5 desc {Font name}}
    boaFontStrikeout {value 0x6 desc {Strikeout}}
    boaFontUnderline {value 0x7 desc {Font underline}}
    boaDateTimeAddSubstrat {value 0x8 desc {Addition-substaction of date and time}}
    boaClibArtGallery {value 0x9 desc {Clib art category + No}}
    boaBarcodeProtocol {value 0xa desc {Barcode protocol}}
  }
  dict set bpoVariable "ObjectType" {
    bobText {value 0x0 desc {Text}}
    bobBarcode {value 0x1 desc {Barcode}}
    bobImage {value 0x2 desc {Image}}
    bobDateTime {value 0x3 desc {Date and time}}
    bobClipArt {value 0x4 desc {Clipart}}
  }
  dict set bpoVariable "PrintEvent" {
    bpePrinted {value 0x0 desc {Print end}}
    bpeOffline {value 0x1 desc {Printer offline}}
    bpePaused {value 0x2 desc {Pause}}
    bpeDeleted {value 0x3 desc {Cancel job}}
    bpeError {value 0x4 desc {Error}}
    bpeNotFound {value 0x5 desc {Printer not found}}
  }
}

proc ::Bpac::writeFile {filename data} {
  set f [open $filename "w"]
  puts -nonewline $f $data
  close $f
}

proc ::Bpac::pPrintOptionConstants {printerName bpov} {
  variable bpoVariable
  if {[dict exists $bpoVariable $printerName $bpov value]} {
    set res [dict get $bpoVariable $printerName $bpov value]
  }  else {
    set res [dict get $bpoVariable PrintOptionConstants $bpov value]
  }
  return $res
}

proc ::Bpac::brqlPrint {label fieldNames labelfieldNameID expbmp printtext {count 1} {print 1} } {
  variable bpoVariable
  variable result
  # lappend result construction for log
  set result [list]
  # tcl vars and arrays
  lappend result nameofexecutable [info nameofexecutable]
  lappend result patchlevel [info patchlevel]
  #  lappend result auto_path $::auto_path
  #  lappend result tcl__tm__path [::tcl::tm::path list]
  lappend result tcl_platform(os) $::tcl_platform(os)
  lappend result tcl_platform(osVersion) $::tcl_platform(osVersion)
  lappend result tcl_platform(pointerSize) $::tcl_platform(pointerSize)
  lappend result tcl_platform(machine)  $::tcl_platform(machine)
  # Windows env
  lappend result ::env(PROCESSOR_ARCHITECTURE) $::env(PROCESSOR_ARCHITECTURE)
  lappend result ::env(SESSIONNAME) $::env(SESSIONNAME)
  lappend result ::env(PATH)_Tcl [lsearch -all -inline  [split $::env(PATH) ";"] *Tcl*]
  # label
  lappend result label $label
  lappend result {file exists} [file exists $label]
  lappend result expbmp $expbmp
  # comobjs Document, Printer and Object
  lappend result err_bpacDoc [catch {set bpacDoc [::twapi::comobj bpac.Document]} res] bpacDoc $res
  lappend result err_bpacPrinter [catch {set bpacPrinter [::twapi::comobj bpac.Printer]} res] bpacPrinter $res
  lappend result err_bpacObject [catch {set bpacObject [::twapi::comobj bpac.Object]} res] bpacObject $res
  #Document
  lappend result err_objPrinter [catch {set objPrinter [$bpacDoc printer]} res] objPrinter $res
  lappend result err_printerName [catch {set printerName [$objPrinter name]} res] printerName $res
  lappend result err_objObjects [catch {set objObjects [$bpacDoc objects]} res] objObjects $res

  #objects , problem
  ##lappend result err_objObjectsget [catch {$objObjects -call getindexbyname name 1  } res] objObjectsget $res
  # open label
  lappend result err_bpacopenlabel [catch {$bpacDoc -call open $label} res] bpacopenlabel $res
  # label attributs
  lappend result "labelfieldNameID" $labelfieldNameID
  # getobject
  set i 0
  foreach lfNID $labelfieldNameID lfN $printtext {
    lappend result "__foreach-field-[incr i]" "$lfNID $lfN"
    lappend result err_objGetObjectfNID [catch {set objGetObjectfNID [$bpacDoc -call GetObject $lfNID]} res] objGetObjectfNID $res
    # insert $printtext or text from *.lbx
    lappend result err_objnametext [catch {$objGetObjectfNID -call text $lfN } res] objnametext  $res
  }
  # media
  lappend result err_GetMediaID [catch {set objMediaID [$bpacDoc -call GetMediaID ]} res] objGetMediaID $res
  lappend result err_objGetMediaName [catch {set objMediaName [$bpacDoc -call GetMediaName ]} res] objGetMediaName $res

  # label get text atributtes
  ##set gettextBuffer ""
  ##lappend result err_GetText [catch {set objGetText [$bpacDoc -call GetText 1 $gettextBuffer]} res] objGetText $res
  ### error with GetText:  Parameter error. Offending parameter position 2. Typenkonflikt.
  ### VARIANT_BOOL bpac::IDocument::GetText (LONG index, ref BSTR text)
  ### Acquires the text data of the specified line.
  ### Returns the line number of the text in the document.
  ### Arguments:
  ### index  	Index (0 onwards) of the text line to be acquired
  ### text  	Pointer to the buffer in which text is to be acquired
  ###  Returned value: Success or Failure
  lappend result err_GetTextCount [catch {set objGetTextCount [$bpacDoc -call GetTextCount ]} res] objGetTextCount $res
  set i 0
  foreach LabelfieldName $fieldNames {
    lappend result "__foreach-gettextindex-[incr i]" $LabelfieldName
    lappend result "LabelfieldName" $LabelfieldName
    lappend result err_GetTextIndex [catch {$bpacDoc -call GetTextIndex $LabelfieldName} res] objGetTextIndex $res
  }
  # export label as bmp
  lappend result err_ExportType [catch {set ExportType [dict get $bpoVariable ExportType bexBmp value]} res] Exporttype $res
  lappend result err_expbmp [catch {$bpacDoc -call export $ExportType $expbmp 300 } res] export $res
  # print start, print out, end and close
  lappend result err_bpoAutoCut [catch {set bpoAutoCut [pPrintOptionConstants $printerName bpoAutoCut]} res] bpoAutoCut $res
  lappend result err_startprint [catch {$bpacDoc -call Startprint "" $bpoAutoCut} res] startprint $res
  if {$print} {
    lappend result err_printout [catch {$bpacDoc -call PrintOut 1 0} res] printout $res
  }
  lappend result err_endprint [catch {$bpacDoc -call EndPrint} res] endprint $res
  lappend result err_close [catch {$bpacDoc -call Close} res] close $res

  #pretty result
  set longest 0
  foreach key [dict keys $result] {
    set l [string length $key]
    if {$l > $longest} {set longest $l}
  }
  lmap {k v} $result {append prettyresult [format "%-*s = %s" $longest $k $v ] "\n"}
  return [lappend result prettyresult $prettyresult]
}

# common vars
set dirname [file dirname [info script]]
set filename [file tail [info script]]
set filerootname [file rootname [file tail [info script]]]
set liblbx [file join $dirname "lbx"]
set exportdir [file join $dirname "export"]
catch {file mkdir export}
set logdir [file join $dirname "log"]
catch {file mkdir $logdir}

# individual dict to lbx label
# lb62x25f1r.lbx ,field1, textone, fester Rahmen
# lb62x25f2r.lbx , field1 field2, textone texttwo, fester Rahmen
# lb62x25f1fg.lbx ,field1, textone, freie Groesse
set labelVar [dict create]
dict set labelVar lb62x25f2r {
template lb62x25f2r.lbx
fieldNames {textone texttwo}
labelfieldNameID {field1 field2}
printtext {"text example one" "text example 2"}
}

dict set labelVar lb62x25f1r {
template lb62x25f1r.lbx
fieldNames {textone}
labelfieldNameID {field1}
printtext {"text example one"}
}

# common value for dict
foreach value [dict keys $labelVar] {
  dict set labelVar $value label [string map {/ \\} [file join $liblbx [dict get $labelVar $value template]]]
  dict set labelVar $value expbmp [string map {/ \\} [file join $exportdir [file rootname [dict get $labelVar $value template]]-${::tcl_platform(pointerSize)}.bmp]]
  dict set labelVar $value print 1
  dict set labelVar $value count 1
}

# call the print proc
# lb62x25f1r lb62x25f2r
set labelDict [dict get $labelVar lb62x25f2r]
dict with labelDict {
 set print 0
 set result [::Bpac::brqlPrint $label $fieldNames $labelfieldNameID $expbmp $printtext  $count $print]
}
set logtxt [file join $logdir log-[file rootname $template]-${::tcl_platform(pointerSize)}.txt] 

#
set imageview 1
set textview 1
# the bmp file
if {$imageview} {
  exec cmd /c "" $expbmp &
}

# the log file
#Output a file in ./log/log-x.txt
#tcl_platform(pointerSize) 4 -> 32 Bit  8 -> 64 Bit
::Bpac::writeFile $logtxt [dict get $result prettyresult]

if {$textview} {
  exec cmd /c "" $logtxt &
}
# Outputs
#Output conole
puts [dict get $result prettyresult ]
#puts [dict get $result err_objObjectsget]
#puts [dict get $result objObjectsget]

#Output text widget
if {[file tail [info nameofexecutable]] eq "wish.exe"} {
  text .t
  .t insert end [dict get $result prettyresult]
  pack .t -expand 1 -fill both
}



