 proc newTable {w cols {default 1}} {
    if {$default}  {
      set myOptionsDefault [dict create anchor w minwidth 10 stretch 1 width 0]
    } else {
      set myOptionsDefault [dict create anchor {} minwidth {} stretch {} width {}]
    }
    foreach col $cols {
      set myOptions $myOptionsDefault
      puts "myOptions: $myOptions"
      dict with myOptions {
        lassign $col colname anchor minwidth stretch width
        puts "col: $col :::: $colname $anchor $minwidth $stretch $width"
      }
      puts $myOptions
       dict set colsOptions $colname $myOptions
      lappend colnames $colname
    }
    puts "colOPtions:  $colsOptions \n"
    set frt [ttk::frame $w.frt]
    # Create the treeview with headings only, and define column names
    set tree [ttk::treeview $frt.tree -show headings -columns $colnames\
    -yscrollcommand [list $frt.vsb set] -selectmode browse]
    set vsb [::ttk::scrollbar $frt.vsb -orient vertical -command [list $tree yview]]

    # Set the text display for column headers
    foreach colname $colnames {
      set myOptions [dict get $colsOptions $colname]
      dict with myOptions {
        $tree heading $colname -text $colname
        if {$anchor ne {} } {
          $tree column $colname -anchor $anchor
        }
        if {$minwidth ne {} } {
          $tree column $colname -minwidth $minwidth
        }
        if {$stretch ne {} } {
          $tree column $colname -stretch $stretch
        }
        if {$width ne {} } {
          $tree column $colname -width $width
        }

      }
    }
    pack $frt -expand 1 -fill both

    pack $vsb -expand 0 -fill y -side right
    pack $tree -expand 1 -fill both
    return $tree
  }