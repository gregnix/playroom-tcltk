# Functions to save and restore the status
proc save_tablelist_status {tbl} {
    set statusDict [dict create]

    # Save sorting information
    if {[string length [$tbl sortorder]] > 0} {
        dict set statusDict -sortOrder [$tbl sortorder]
        dict set statusDict -sortColumn [$tbl sortcolumn]
    }
    dict set statusDict -sortgetkeys [$tbl getfullkeys 0 end]

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
