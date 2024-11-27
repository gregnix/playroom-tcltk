#! /usr/bin/env tclsh

#20240525
#tablelist-statuslib.tcl
#
# Functions to save and restore the status
# sortModus: use in restore
# sortModus 1: with sortID
# sortModus 0: without sortID, with sortorder and sortcolumn, problem with both == ""
# sortID: sort by column $sortID
#
# todo
# sortID 1: new lines how to sort?
#
proc save_tablelist_status {tbl {sortModus 1} {sortID 0}} {
    set statusDict [dict create]
    dict set statusDict -sortmodus $sortModus
    # Save sorting information
    if {[string length [$tbl sortorder]] > 0} {
        dict set statusDict -sortOrder [$tbl sortorder]
        dict set statusDict -sortColumn [$tbl sortcolumn]
    }
    dict set statusDict -sortgetkeys [$tbl getfullkeys 0 end]

    dict set statusDict -sortID $sortID
    # Save sorted IDs of column $sortID
    set sortedIDs [list]
    set row 0
    while {$row < [$tbl index end]} {
        lappend sortedIDs [lindex [$tbl rowcget $row -text] $sortID]
        incr row
    }
    dict set statusDict -sortedIDs $sortedIDs

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

    return $statusDict
}

proc restore_tablelist_status {tbl statusDict} {

    # sortID
    if {[dict exists $statusDict -sortID]} {
        set sortID [dict get $statusDict -sortID]
    } else {
        set sortID 0
    }
    if {[dict get $statusDict -sortmodus]} {
        # Restore sorting by saved IDs
        # Call when entire table is passed. Might be needed for multiple sortIDs (internal knumber?)
        # set  sortListByIndex [sortListByIndex [$tbl get 0 end] [dict get $statusDict -sortedIDs] $sortID]
        set sortListByIndex [sortListByIndex [$tbl getcolumns $sortID $sortID] [dict get $statusDict -sortedIDs] 0]
        set tmplist [$tbl get 0 end]
        puts "restore  tmplist $tmplist"
        $tbl delete 0 end
        foreach pos $sortListByIndex {
            $tbl insert end [lindex $tmplist $pos]
        }
        puts "smodus 1"
    } else {
        # Restore sorting
        if {[dict exists $statusDict -sortColumn] && [dict get $statusDict -sortColumn] != -1} {
            $tbl sortbycolumn [dict get $statusDict -sortColumn] -[dict get $statusDict -sortOrder]
        } else {
            puts "sortColumn empty"
        }
        puts "smodus 0"
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
    # Restore sorting
    # if {[dict exists $statusDict -sortColumn] && [dict get $statusDict -sortColumn] != -1} {
    # $tbl sortbycolumn [dict get $statusDict -sortColumn] -[dict get $statusDict -sortOrder]
    # }
}

# Helper proc
# Function to replace empty sublists with __null__
proc replaceEmptySublists {lst} {
    set newList [list]
    foreach item $lst {
        if {[llength $item] == 0} {
            lappend newList __null__
        } else {
            lappend newList $item
        }
    }
    return $newList
}

# Procedure to sort a list based on a sort index
proc sortListByIndex {values sortIndex {sortID 0}} {
    # Check if the entire table is passed as value
    set valueCount [llength $values]
    if {[llength $values] == 1} {
        set values [concat {*}$values]
        set valueCount [llength $values]
    }
    set values [replaceEmptySublists $values]
    set sortIndex [replaceEmptySublists $sortIndex]
    # Create a list of pairs (index, value)
    set pairs {}

    # Update sortIndex if there are missing IDs
    set existingIDs [list]
    foreach val $values {
        lappend existingIDs [lindex $val $sortID]
    }
    set existingIDs [concat {*}$existingIDs]
    set tmpsortIndex [list]
    foreach id $sortIndex {
        if {$id in $existingIDs} {
            lappend tmpsortIndex $id
        }
    }
    set tmpnewsortIndex [list]
    array unset valarr
    foreach id $existingIDs {
        if {$id ni $tmpsortIndex} {
            lappend tmpnewsortIndex $id
        } else {
            incr valarr($id)
            if {$valarr($id) > [llength [lsearch -all $tmpsortIndex $id]] } {
               lappend tmpnewsortIndex $id 
            }
        }
    }
    if {[llength $tmpnewsortIndex] > 0} {
        set tmpnewsortIndex [lsort $tmpnewsortIndex]
        lappend tmpsortIndex {*}$tmpnewsortIndex
     }
    set sortIndex $tmpsortIndex
    set indexCount [llength $sortIndex]
    if { $valueCount != $indexCount} {
        puts "Fehler : valueCount : $valueCount : $values :: sortIndex : $indexCount : $sortIndex"
    }
    array unset  valarr
    for {set i 0} {$i < $valueCount} {incr i} {
        set idx [lindex $sortIndex $i]
        set sval [lsearch -index $sortID -all $values $idx]
        if {[llength $sval] == 1} {
            lappend pairs [list $i $sval]
        } else {
            incr valarr($sval)
            set isval [expr {$valarr($sval) - 1}]
            lappend pairs [list $i [lindex $sval $isval]]
        }
    }
    # Sort the pairs based on the index
    set sortedPairs [lsort -index 0 $pairs]
    # Extract the sorted values
    set sortedValues [list]
    foreach pair $sortedPairs {
        lappend sortedValues [lindex $pair 1]
    }
    return $sortedValues
}
