package require Tk
package require widget::dialog ;# or widget::all

# Function to show the dialog
proc showDialog {} {
    # Create the dialog widget
    set dlg [widget::dialog .pkgerr -modal local -separator 1 -place right \
        -parent . -type okcancel -title "DialogTitle"]

    # Add a frame as a container for the dialog content
    set frame [frame $dlg.f]
    
    # Add a label and an entry field
    label $frame.lbl -text "Please enter your name:"
    entry $frame.ent -textvariable userName
    grid $frame.lbl $frame.ent -sticky ew
    
    # Set the custom widget for the dialog
    $dlg setwidget $frame

    # Display the dialog and process user interaction
    set response [$dlg display]
    if {$response eq "ok"} {
        puts "User entered: $::userName"
    } else {
        puts "Dialog canceled"
    }

    # Destroy the dialog
    destroy $dlg
}

# Display the main window
pack [button .btn -text "Open Dialog" -command showDialog]

