#The script creates a simple GUI log window using Tcl/Tk,
#which displays the output of a shell command. It redirects
#both standard output (stdout) and standard error (stderr)
#of the shell command to the log window. Inputs in the log
#window are sent to the shell, and the shell outputs are displayed in the log window.
#
#https://wiki.tcl-lang.org/page/a+way+to+%27pipe%27+from+an+external+process+into+a+text+widget
#

package require Tk
variable stdio
variable wrerr
variable rderr

# Log function to add text to the log window
proc log {text logwindow {tags {}}} {
  $logwindow.output configure -state normal
  $logwindow.output insert end $text $tags
  $logwindow.output configure -state disabled
  $logwindow.output see end
}

# Function to create the log window
proc logwindow {} {
  set top [toplevel .toplogwindow]
  ttk::combobox $top.input -values {}
  ttk::scrollbar $top.scroll -orient vertical -command [list $top.output yview]
  text $top.output -state disabled -yscrollcommand [list $top.scroll set]
  $top.output tag configure input -background gray
  $top.output tag configure error -background red
  pack $top.input -fill x -side bottom
  pack $top.scroll -fill y -side right
  pack $top.output -fill both -expand 1
  focus $top.input
  # Popup menu for copying text
  set popupE [menu $top.output.popupE  -tearoff 0]
  $popupE add command -label "Copy Ctrl-c" -command [list tk_textCopy $top.output]
  bind $top.output <3> [list tk_popup $popupE %X %Y]
  # Search
  set searchFrame [ttk::frame $top.fr]
  ttk::entry $searchFrame.searchEntry -textvariable searchText -width 30
  ttk::button $searchFrame.searchButton -text "Search" -command [list searchText $top.output $searchFrame.searchEntry]
  pack $searchFrame.searchEntry -side left
  pack $searchFrame.searchButton -side left
  pack $searchFrame -side top -fill x

  # Menu for switching shells
  menu $top.menubar
  $top configure -menu $top.menubar
  menu $top.menubar.shell -tearoff 0
  $top.menubar.shell add command -label "Switch to Tclsh" -command {switch_shell "tclsh" $logwindow}
  $top.menubar.shell add command -label "Switch to Sh" -command {switch_shell "sh" $logwindow}
  $top.menubar.shell add command -label "Switch to Bash" -command {switch_shell "bash" $logwindow}
  $top.menubar.shell add command -label "Switch to Cmd.exe" -command {switch_shell "cmd.exe" $logwindow}
  $top.menubar add cascade -label "Shell" -menu $top.menubar.shell
  menu $top.menubar.edit -tearoff 0
  $top.menubar.edit add command -label "Copy" -command [list tk_textCopy $top.output]
  $top.menubar add cascade -label "Edit" -menu $top.menubar.edit

  return $top
}

proc searchText {textWidget searchEntry} {
  set searchStr [$searchEntry get]
  $textWidget tag remove searchHighlight 1.0 end
  if {$searchStr ne ""} {
    set pos [$textWidget search -count length $searchStr 1.0 end]
    while {$pos ne ""} {
      set endPos [$textWidget index "$pos + $length char"]
      $textWidget tag add searchHighlight $pos $endPos
      set pos [$textWidget search -count length -forward $searchStr $endPos end]
    }
    $textWidget tag configure searchHighlight -background yellow
  }
}

proc switch_shell {shell logwindow} {
  variable stdio
  variable wrerr
  variable rderr
  puts "switch_shell: [chan names]"
  if {[info exists stdio]} {
    foreach chan [chan names] {
      if {[lsearch [list $stdio $rderr $wrerr] $chan] != -1} {
        chan close $chan
      }
    }
  }
  set stdio [init_channels $shell $logwindow]
  init_bind $logwindow $stdio
  wm title $logwindow $shell
}

# Procedure to initialize the channels
proc init_channels {shell logwindow} {
  variable stdio
  variable wrerr
  variable rderr
  puts "init_channels s0: [chan names]"
  lassign [chan pipe] rderr wrerr
  puts "init_channels s1: [chan names]"
  set stdio [open |[concat $shell [list 2>@ $wrerr]] r+]
  puts "init_channels s2: [chan names]"
  foreach {chan tags} [list $stdio "" $rderr error] {
    chan configure $chan -buffering line -blocking 0
    chan event $chan readable [list apply {{chan tags logwindow} {
        if {[chan eof $chan]} {
          log "EOF\n" $logwindow error
          $logwindow.input state disabled
          chan close $chan
        } else {
          log [chan read $chan] $logwindow $tags
        }
    }} $chan $tags $logwindow]
  }
  return $stdio
}


# Procedure to initialize the input binding
proc init_bind {logwindow stdio} {
  bind $logwindow.input <Return> [list apply {{chan logwindow} {
      set input [$logwindow.input get]
      if {$input ne ""} {
        set values [$logwindow.input cget -values]
        if {[lsearch $values $input] == -1} {
          $logwindow.input configure -values [linsert $values 0 $input]
        }
        log "$input\n" $logwindow
        chan puts $chan "$input\n"
        chan flush $chan ;# Ensure the command is sent immediately
        $logwindow.input delete 0 end
      }
  }} $stdio $logwindow]
}

# Platform detection and setting the appropriate shell command
proc osshell {} {
  switch -- $::tcl_platform(platform) {
    windows {
      set shell [list cmd.exe]
    }
    unix {
      set shell [list sh]
    }
    macintosh {
      set shell [list zsh]
    }
    default {
      set shell [list sh]
    }
  }
  return $shell
}

##########################
# main
wm withdraw .
set logwindow [logwindow]
# Initialize channels
set stdio [init_channels [osshell] $logwindow]
init_bind $logwindow $stdio

wm title $logwindow [osshell]


if {0} {
}
