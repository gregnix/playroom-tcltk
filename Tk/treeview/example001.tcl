package require Tk
source treeview-lib.tcl

proc createTV {w} {
  set frt [ttk::frame $w.frt ]
  set tree [::ttk::treeview $frt.tree -height 15 -show tree \
    -yscroll [list $frt.vsb set] -xscroll [list $frt.hsb set] -selectmode browse]
  set vsb [::ttk::scrollbar $frt.vsb -orient vertical -command [list $tree yview]]
  set hsb [::ttk::scrollbar $frt.hsb -orient horizontal -command [list $tree xview]]

  grid $frt -row 0 -column 0 -sticky nsew

  grid $vsb -row 0 -column 1 -sticky ns
  grid $hsb -row 1 -column 0 -sticky ew
  grid $tree -row 0 -column 0 -sticky nsew


  grid columnconfigure $frt 0 -weight 1
  grid rowconfigure $frt 0  -weight 1
  grid columnconfigure $w 0 -weight 1
  grid rowconfigure $w 0  -weight 1

  return $tree
}


::ttk::label .msg -font "Times 24 bold" -textvariable ::msg -width 20 \
    -background yellow -borderwidth 2 -relief ridge

ttk::frame .fr1
pack .fr1  -side top -expand 1 -fill both
set tree [createTV .fr1]

foreach txt {first second third} {
  set id [$tree insert {} end -text "$txt item" -open 1]
  for {set i [expr {1+int(rand()*5)}]} {$i > 0} {incr i -1} {
    set child [$tree insert $id 0 -text "child $i"]
    for {set j [expr {int(rand()*3)}]} {$j > 0} {incr j -1} {
      $tree insert $child 0 -text "grandchild $i"
    }
  }
}
tvlib::band_init $tree
tvlib::band $tree

