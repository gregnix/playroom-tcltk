#!/usr/bin/env tclsh

#todo
# TODO
# Adjust mouse behavior for the menu in toplevel and non-toplevel widgets


# 20240119

#package require Tk
puts "Tk v[package require Tk]"
package require scrollutil_tile
package require msgcat

namespace eval textwid {
  namespace import ::msgcat::mc
  ::msgcat::mcmset de {
    File Datei
    Edit Bearbeiten
    Open \u00D6ffnen
    Save Speichern
    "Save as" "Speichern als"
    Close "Schlie\u00DFen"
    Exit "Beenden"
    Redo Wiederholen
    Undo "R\u00FCckg\u00E4ngig"
    "Select all" "Alles markieren"
    Cut Ausschneiden
    Copy Kopieren
    Paste Einf\u00FCgen
    Clear L\u00F6schen
  }
  msgcat::mclocale de
  proc textwid {{top .top} args} {

    set dirname [file dirname [info script]]
    set filename  ""
    if {$top eq ".top"} {
      set top [toplevel $top]
      set tfmain [ttk::frame $top.tfmain]
      wm title  $top [file rootname $filename]
      set wtype 1
    } else {
      set wtype 0
      set tfmain [ttk::frame $top.frmain]
    }
    pack $tfmain -expand 1 -fill both -side bottom
    
    set tfmenu [ttk::frame $tfmain.tfmenu]
    pack $tfmenu -expand 0 -fill x -side top
    set tfstatus [ttk::frame $tfmain.tfstatus]
    pack $tfstatus -side bottom -fill x
    set tftext [ttk::frame $tfmain.frtext]
    pack $tftext -expand 1 -fill both -side bottom
   
    # Ein scrollednotebook erstellen
    #set snb [scrollutil::scrollednotebook $tftext.snb -width 300]
    #pack $snb -expand yes -fill both
    #set frame [ttk::frame $snb.one]
    #$snb add $frame -text one
    # Beispielinhalt hinzufügen
    #set tf [ttk::frame $frame.tf ]
    set tf [ttk::frame $tftext.tf ]
    pack $tf -expand 1 -fill both

    set sa [scrollutil::scrollarea $tf.sa]
    # Look up individual namespace for the text widget
    set txt [text $sa.t -wrap none]
    $sa setwidget $sa.t
    pack $sa -expand 1 -fill both
 
    # Namespace for individual text widget
    set ns [widgettoname $txt]
    bind $txt <Destroy> [list namespace delete [namespace current]::${ns}]
    namespace eval $ns {}
    variable ${ns}::status
    set ${ns}::status(Status) "Start"

    ttk::label $tfstatus.lb -textvariable [namespace current]::${ns}::status(Status)
    pack $tfstatus.lb -side left -expand 1 -fill x

    set popupE [menuText $txt $wtype $top $tfmenu $filename]
      
    bindwid 
    puts [winfo children $tf.sa.t]
  
    return $txt
  }
  proc bindwid  {} {
    uplevel {
    bind $txt <3> [list tk_popup $popupE %X %Y]
    bind $txt <Control-o> [list [namespace current]::loadText $txt]  
    bind $txt <Control-o> +[list break]
    bind $txt <Control-s> [list [namespace current]::saveText $txt ""]
   }
  }
  proc menuText {txt wtype top mfr filename} {
    if {$wtype} {
      set mfr $txt.menu
      set m $mfr
      menu $m -tearoff 0
      $mfr add cascade -label [mc File] -menu $mfr.file
      $mfr add cascade -label [mc Edit] -menu $mfr.edit
      $mfr add cascade -label [mc Help] -menu $mfr.help
      $top configure -menu $mfr
      set mfm $mfr.file
      set mem $mfr.edit
      set mhm $mfr.help
    } else {
      #set mfr [ttk::frame  [winfo parent $top ].frm]
      #pack $mfr -expand 1 -fill x -side top
      ttk::menubutton $mfr.file -text [mc File] -menu $mfr.file.m -style Toolbutton
      ttk::menubutton $mfr.edit -text [mc Edit] -menu $mfr.edit.m -style Toolbutton
      ttk::menubutton $mfr.help -text [mc Help] -menu $mfr.help.m -style Toolbutton
      set mfm $mfr.file.m
      set mem $mfr.edit.m
      set mhm $mfr.help.m
      pack $mfr.file $mfr.edit $mfr.help -side left -anchor nw
    }
    menu $mfm -tearoff 0
    $mfm add command -label [mc Open] -command [list [namespace current]::loadText $txt]  -accelerator Ctrl+O
    $mfm add command -label [mc Save] -command [list [namespace current]::saveText $txt $filename]   -accelerator Ctrl+S
    menu $mem -tearoff 0
    $mem add command -label "[mc Select all]" -command [list $txt tag add sel 1.0 end]   -accelerator Ctrl+a
    $mem add separator
    $mem add command -label [mc Cut] -command [list tk_textCut $txt]    -accelerator Ctrl+X
    $mem add command -label [mc Copy] -command [list tk_textCopy $txt]   -accelerator Ctrl+C
    $mem add command -label [mc Paste] -command [list tk_textPaste $txt]  -accelerator Ctrl+V
    menu $mhm -tearoff 0

    set popupE [menu $txt.popupE]
    $popupE add command -label [mc Cut] -command [list tk_textCut $txt]
    $popupE add command -label [mc Copy] -command [list tk_textCopy $txt]
    $popupE add command -label [mc Paste] -command [list tk_textPaste $txt]
    $popupE add separator
    $popupE add command -label [mc Select all] -command [list $txt tag add sel 1.0 end]

    $popupE add separator
    $popupE add command -label [mc Open] -command [list [namespace current]::loadText $txt]
    $popupE add command -label [mc Save] -command [list [namespace current]::saveText $txt $filename]
    return $popupE
  }
  proc widgettoname {w} {
    set wid $w
    # Search text widget in widget tree, .sa.t
    while {[winfo class $wid] ne "Text"} {
      if {[winfo exists [winfo parent $wid].sa]} {
        set wid [winfo parent $wid].sa.t
      } elseif { [winfo parent $wid] eq "."} {
         error "No associated text widget found for $w"
      } else {
        set wid [winfo parent $wid]
      }
    }
    set res [string map {{.} {} } $wid]
    return $res
  }
  proc updateStatus {msg w} {
    set ns [widgettoname $w]
    variable ${ns}::status
    set ${ns}::status(Status)  $msg
    after 3000 [list set [namespace current]::${ns}::status(Status) "Ready"] ;# Reset after 3 seconds
  }

  proc saveText {w filename} {
    set filename [tk_getSaveFile -title "Save file"]
    if {$filename ne ""} {
      if {[catch {set file [open $filename w]} err]} {
        tk_messageBox -message "Error saving file: $err" -icon error
        return
      }
      set data [$w get 1.0 end]
      puts $file $data
      close $file
    }
  }
  proc loadText {w} {
    set filename [tk_getOpenFile -title "Open file"]
    if {$filename ne ""} {
      if {[catch {set file [open $filename r]} err]} {
        tk_messageBox -message "Error opening file: $err" -icon error
        return
      }
      set data [read $file]
      close $file
      $w delete 1.0 end
      $w insert 1.0 $data
      updateStatus "File loaded" $w
    }
  }
}




################################
#Example
# 
if {[info exists argv0] && [info script] eq $argv0} {
#1 
  if {1} {
  set data [join $auto_path "\n"]
  ttk::frame .fr
  pack .fr -expand 1 -fill both
  set txt  [textwid::textwid .fr ]
  $txt  insert end $txt
  $txt  insert end "\n"
  $txt  insert end $data
  wm geometry [winfo toplevel $txt] +10+100
}
#2  
  if {1} {
  # toplevel
  #wm withdraw .
  set txttop [textwid::textwid]
  $txttop  insert end $txttop
  $txttop  insert end "\n"
  $txttop  insert end $data
  wm geometry [winfo toplevel $txttop] +700+100
}
}
