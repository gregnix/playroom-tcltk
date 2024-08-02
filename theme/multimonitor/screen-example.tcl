#! /usr/bin/env tclsh
package require Tk

# Beispiel einer Funktion, die ein Toplevel-Fenster erstellt
proc create_window {} {
    # Überprüfen, ob das Fenster bereits existiert
    if {[winfo exists .myWindow]} {
        puts "Fenster existiert bereits."
        return
    }
    
    # Toplevel-Fenster erstellen
    set root [toplevel .myWindow]
    wm title $root "Mein Fenster"
    
    # Label hinzufügen
    label $root.lbl -text "Hallo, Tcl/Tk!"
    pack $root.lbl
    
    # Button zum Schließen des Fensters
    button $root.btn -text "Schließen" -command "destroy .myWindow"
    pack $root.btn
}

# Hauptfenster
set mainWin ".mainWin"
if {[winfo exists $mainWin]} {
    destroy $mainWin
}
toplevel $mainWin
wm title $mainWin "Hauptfenster"

# Button zum Erstellen eines neuen Fensters
button $mainWin.newWinBtn -text "Neues Fenster" -command "create_window"
pack $mainWin.newWinBtn

# Bildschirmabmessungen und primäre Bildschirmabmessungen ermitteln
set screen_width [winfo screenwidth .]
set screen_height [winfo screenheight .]
set primary_screen_width 1920
set primary_screen_height $screen_height

set window_width 300
set window_height 200

# Berechne Positionen relativ zum primären Bildschirm
set x_pos [expr {($primary_screen_width - $window_width) / 2}]
set y_pos [expr {($primary_screen_height - $window_height) / 2}]
wm geometry $mainWin [format "%dx%d+%d+%d" $window_width $window_height $x_pos $y_pos]

# Informationen ausgeben
puts "screen_width: $screen_width :: screen_height: $screen_height :: wm maxsize .: [wm maxsize .]"
puts "geo .: [wm geometry .] :: winfo screen: [winfo screen .]"
puts "geo \$mainWin: [wm geometry $mainWin] :: winfo screen: [winfo screen $mainWin]"

# habe zwei monitore
if {0} {
  output:
screen_width: 3840 :: screen_height: 1080 :: wm maxsize .: 3825 1050
geo .: 1x1+0+0 :: winfo screen: :0.0
geo $mainWin: 1x1+810+440 :: winfo screen: :0.0
}
