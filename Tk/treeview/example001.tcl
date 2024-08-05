package require Tk

::ttk::label .msg -font "Times 24 bold" -textvariable ::msg -width 20 \
    -background yellow -borderwidth 2 -relief ridge

::ttk::treeview .tree -height 15 -show tree \
    -yscroll ".vsb set" -xscroll ".hsb set" -selectmode browse
::ttk::scrollbar .vsb -orient vertical -command ".tree yview"
::ttk::scrollbar .hsb -orient horizontal -command ".tree xview"

grid .msg - -sticky ew
grid .tree .vsb -sticky nsew
grid .hsb       -sticky nsew
grid column . 0 -weight 1
grid row    . 1 -weight 1

foreach txt {first second third} {
    set id [.tree insert {} end -text "$txt item" -open 1]
    for {set i [expr {1+int(rand()*5)}]} {$i > 0} {incr i -1} {
        set child [.tree insert $id 0 -text "child $i"]
        for {set j [expr {int(rand()*3)}]} {$j > 0} {incr j -1} {
            .tree insert $child 0 -text "grandchild $i"
        }
    }
}