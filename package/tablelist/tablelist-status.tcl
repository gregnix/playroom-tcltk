# Example table creation
package require Tk
package require tablelist

# Central dictionary for saving the status
variable datenDict
set datenDict [dict create]

# Help Proc
proc tlog {{message null} args} {
    set timestamp "[clock format [clock seconds]  -format "%T"]"
    set top .toptlog
    set f $top.ft
    set t $f.t
    if {![winfo exists $top]} {
        toplevel $top
        frame $f
        pack $f -side top -fill both -expand true
        set t [text $f.t -setgrid true -wrap none \
    -yscrollcommand "$f.vset set" -xscrollcommand "$f.hset set"]
        scrollbar $f.vset -orient vert -command "$f.t yview"
        scrollbar $f.hset -orient hori -command "$f.t xview"
        pack $f.hset -side bottom -fill x
        pack $f.vset -side right -fill y
        pack $f.t -side left -fill both -expand true

        set popupE [menu $t.popupE]
        $popupE add command -label "Ctrl-c" -command [list tk_textCopy $t]
        $popupE add command -label "Ctrl-x" -command [list tk_textCut $t]
        $popupE add command -label "Ctrl-v" -command [list tk_textPaste $t]
        bind $t <3> [list tk_popup $popupE %X %Y]

        #wm withdraw .
        $t insert end "Start tlog\n"
    }
    $t insert 1.0 \n \n
    $t insert 1.0 "      Start $timestamp\n"
    $t insert 2.0 "$message\n"
    
    return $t
}

proc teststatustbl {tbl args} {
  set rows [$tbl curselection]
  set row [lindex $rows 0]
  set curcellselection [$tbl curcellselection]
  set topIndex [$tbl index top]
  set bottomIndex  [$tbl index bottom]
  set toplevelkey [$tbl toplevelkey $row]

  append result $tbl \n
  append result "row $row :: rows $rows :: rowcget  $row -text [$tbl rowcget $row -text] :: rowcget  $row -name [$tbl rowcget $row -name] ::\n"
  append result "tbl getkeys  active [$tbl getkeys  active] \n"  
  append result "curcellselection $curcellselection \n"
  append result "toplevelkey $toplevelkey\n"
  append result "view [$tbl viewablerowcount]  top $topIndex  bottom  $bottomIndex\n"
  append result "getkeys end k[$tbl getkeys end] :: tbl index end [$tbl index end]  \n"
  append result "tbl get k[$tbl getkeys end] : [$tbl get k[$tbl getkeys end]] :: tbl get [$tbl index end] : [$tbl get [$tbl index end]] \n"
  append result " tbl sortorder [$tbl sortorder]  :: tbl sortcolumn  [$tbl sortcolumn] :: tbl sortorderlist: [$tbl sortorderlist] :: tbl sortcolumnlist: [$tbl sortcolumnlist]\n"
  tlog $result 
}

# Functions to save and restore the status
proc save_tablelist_status {tbl} {
  set statusDict [dict create]

  # Save sorting information
  if {[string length [$tbl sortorder]] > 0} {
    dict set statusDict -sortOrder [$tbl sortorder]
    dict set statusDict -sortColumn [$tbl sortcolumn]
  }

  # Save selections
  set selectedIDs [list]
  foreach row [$tbl curselection] {
    lappend selectedIDs k[$tbl getkeys $row]
  }
  dict set statusDict -selectedRows $selectedIDs

  # Save scroll position
  lassign [$tbl xview] x1 x2
  lassign [$tbl yview] y1 y2
  dict set statusDict -xview $x1
  dict set statusDict -yview $y1

  # Save visible rows and columns
  set firstVisibleRow [$tbl index @0,0]
  set lastVisibleRow [$tbl index @0,[winfo height $tbl]]
  dict set statusDict -visibleRows "$firstVisibleRow $lastVisibleRow"

  set firstVisibleColumn [$tbl columnindex @0,0]
  set lastVisibleColumn [$tbl columnindex @0,[winfo width $tbl]]
  dict set statusDict -visibleColumns "$firstVisibleColumn $lastVisibleColumn"

  # Save column widths
  set columnWidths [list]
  set columnCount [$tbl columncount]
  for {set i 0} {$i < $columnCount} {incr i} {
    lappend columnWidths [$tbl columnwidth $i -requested]
  }
  dict set statusDict -columnWidths $columnWidths
  puts "save: $statusDict"
  return $statusDict
}

proc restore_tablelist_status {tbl statusDict} {
  # Restore sorting information
  if {[dict exists $statusDict -sortColumn] && [dict get $statusDict -sortColumn] != -1} {
    $tbl sortbycolumn [dict get $statusDict -sortColumn] -[dict get $statusDict -sortOrder]
  }

  # Restore selections
  if {[dict exists $statusDict -selectedRows]} {
    foreach row [dict get $statusDict -selectedRows] {
      $tbl selection set $row
    }
  }

  # Restore scroll position
  if {[dict exists $statusDict -xview] && [dict exists $statusDict -yview]} {
    $tbl xview moveto [dict get $statusDict -xview]
    $tbl yview moveto [dict get $statusDict -yview]
  }

  # Restore visible rows and columns
  if {[dict exists $statusDict -visibleRows]} {
    set firstVisibleRow [lindex [dict get $statusDict -visibleRows] 0]
    set lastVisibleRow [lindex [dict get $statusDict -visibleRows] 1]
    $tbl see $firstVisibleRow
    $tbl see $lastVisibleRow
  }

  if {[dict exists $statusDict -visibleColumns]} {
    set firstVisibleColumn [lindex [dict get $statusDict -visibleColumns] 0]
    set lastVisibleColumn [lindex [dict get $statusDict -visibleColumns] 1]
    $tbl seecolumn $firstVisibleColumn
    $tbl seecolumn $lastVisibleColumn
  }

  # Restore column widths
  if {[dict exists $statusDict -columnWidths]} {
    set columnWidths [dict get $statusDict -columnWidths]
    set columnCount [$tbl columncount]
    for {set i 0} {$i < $columnCount} {incr i} {
      $tbl columnconfigure $i -width -[lindex $columnWidths $i]
    }
  }
}

proc tblInsert {tbl list} {
  variable datenDict
  set tblStatus [save_tablelist_status $tbl]
  dict set datenDict tblStatus $tblStatus
  $tbl delete 0 end
  $tbl insertlist end $list
}

proc tblInsertSingle {tbl} {
  if {[lindex $::liste  [$tbl index end]] == ""} {
    return
  }
  $tbl insert end [lindex $::liste  [$tbl index end]]
}

proc tblCreate {w} {
  variable datenDict
  set frt [frame .frt]

  # Create table
  set tbl [tablelist::tablelist $frt.tbl -columns {0 "ID" right 1 "Name" left 2 "Class" center} \
    -stretch all  -xscroll [list $frt.h set] -yscroll [list $frt.v set] -labelcommand tablelist::sortByColumn \
    -selectmode multiple -exportselection false]
  set vsb [scrollbar $frt.v -orient vertical -command [list $tbl yview]]
  set hsb [scrollbar $frt.h -orient horizontal -command [list $tbl xview]]

   # Add buttons
  set frb [frame .frb]
  pack $frb -fill x -side bottom -expand 0
  
  pack $frt -fill both -side top -expand true
  pack $vsb -side right -fill y -expand 0
  pack $hsb -side bottom -fill x -expand 0
  pack $tbl -fill both -expand true
 
  set btnsave [button $frb.save -text "Save Status" -command {
    variable datenDict
    dict set datenDict tblStatus [save_tablelist_status .frt.tbl]
    puts "tblStatus saved:\n[dict get $datenDict tblStatus]\n"
  }]
  pack $btnsave -side left

  set btnrestore [button $frb.restore -text "Restore Status" -command {
    variable datenDict
    restore_tablelist_status .frt.tbl [dict get $datenDict tblStatus]
    puts "tblStatus restored:\n[dict get $datenDict tblStatus]\n"
  }]
  pack $btnrestore -side right

  set btninsert [button $frb.insert -text "Insert Data" -command [list tblInsertSingle $tbl]]
  pack $btninsert -side right
  
  set btntest [button $frb.test -text "Test" -command [list teststatustbl $tbl ]]
  pack $btntest -side right
  
  return $tbl
}

# Data list
set liste {{1 Herbert 3a} {2 Anna 7d} {3 Anna 7c} {4 Tim 9t} {5 Birgit 10b} \
{6 Werner 10w} {7 Tom 10t} {8 Suzi 10s} {9 Monika 11m} {10 Ilse 12I} \
{11 Holger 13H} {12 Thomas 67LT}}

# Create GUI
wm title . "Tablelist Status Example"
set tbl [tblCreate .]

tblInsert $tbl [lrange $liste 0 5]

