package require Tk

# Create the main application window
set app ""
wm title . "Display a 2D Table"

# Create a label at the top
ttk::label $app.lblTitle -text "Display a 2D table" -font "Arial 24"
grid $app.lblTitle -row 0 -column 0 -columnspan 2 -sticky news

ttk::label $app.lblSubtitle -text "Click on header to sort"
grid $app.lblSubtitle -row 1 -column 0 -columnspan 2 -sticky news

# Create a combobox
ttk::combobox $app.combo -values {A B C}
grid $app.combo -row 2 -column 0 -columnspan 2 -sticky news

# Create a Treeview widget with columns
ttk::treeview $app.tree -columns {0 1 2 3 4 5 6 7 8} -show headings
grid $app.tree -row 3 -column 0 -columnspan 2 -sticky news

# Define headings
set headings {A B C D E F G H I}

# Configure the columns and headings
set i -1
foreach heading $headings  {
    incr i
    $app.tree column $i -width 50 -anchor e
    $app.tree heading $i -text $heading
}

# Populate the Treeview with random data
for {set i 0} {$i < 40} {incr i} {
    set values ""
    for {set j 0} {$j < 9} {incr j} {
        lappend values [expr {int(rand()*1000)}]
    }
    $app.tree insert {} end -text [lindex $values 0] -values [lrange $values 1 end]
}

# Configure the grid layout
grid columnconfigure . 0 -weight 1
grid rowconfigure . 3 -weight 1


