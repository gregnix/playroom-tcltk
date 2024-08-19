# treeview widget
proc createTV {w} {
  set frt [ttk::frame $w.frt ]
  set tree [::ttk::treeview $frt.tree -height 15 -show {tree headings} \
    -columns [list value rowidx] -displaycolumns [list value rowidx] \
    -yscrollcommand [list $frt.vsb set] -xscrollcommand [list $frt.hsb set] -selectmode browse]
  set vsb [::ttk::scrollbar $frt.vsb -orient vertical -command [list $tree yview]]
  set hsb [::ttk::scrollbar $frt.hsb -orient horizontal -command [list $tree xview]]

  $tree heading #0 -text Keys
  $tree heading value -text "Values" -anchor center
  $tree heading rowidx -text "Rowidx" -anchor center
  # problem with scrollbar vsb
  $tree column #0 -minwidth 40 -stretch 0
  $tree column value -minwidth 40 -stretch 0
  $tree column rowidx -minwidth 40 -stretch 0

  grid $frt -row 0 -column 0 -sticky nsew

  grid $vsb -row 0 -column 1 -sticky ns
  grid $tree -row 0 -column 0 -sticky nsew
  grid $hsb -row 1  -column 0 -sticky ew

  grid columnconfigure $frt 0 -weight 1
  grid rowconfigure $frt 0  -weight 1
  grid columnconfigure $w 0 -weight 1
  grid rowconfigure $w 0  -weight 1
  grid rowconfigure $w 1  -weight 0

  return $tree
}