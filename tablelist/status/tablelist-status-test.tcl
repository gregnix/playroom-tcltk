#! /usr/bin/env tclsh

# Example table creation
# 20240519
# 
package require Tk
package require tablelist

source [file join [file dirname [info script]] tloglib.tcl]
source [file join [file dirname [info script]] info-text-tablelist.tcl]

# Central dictionary for saving the status
variable datenDict
set datenDict [dict create]


#not use
proc sortKnumber {tbl} {
    set KeyList [$tbl getfullkeys 0 end]
    set OrigKeyList [lsort -dictionary $KeyList]
    set OrigItemList [$tbl get $OrigKeyList]
    $tbl delete 0 end
    $tbl insertlist end $OrigItemList
}

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
    set res [$tbl insert end [lindex $::liste  [$tbl index end]]]
    return $res
}
# sort column with knumber
# In column $col all values are unique, except that you have a 1:1 to knumber 
# $tbl columnconfigure $col -sortmode command -sortcommand [list createSortCommand $tbl $col]
# 
# Assumption: knumber is the last value in the list
# possibly critical access to list with knumber with info frame
# Speed problem with larger lists and may not work in later versions
proc createSortCommand {tbl col a b} {
    #puts "tbl: $tbl col: $col a: $a b: $b   [lindex [info frame -1] 5 6 ]"
    set ak [searchKpos $a  [lindex [info frame -1] 5 6 ] $col]
    set bk [searchKpos $b  [lindex [info frame -1] 5 6 ] $col]
    return [sortCmd $ak $bk]
}

proc searchKpos {val liste col} {
    foreach item $liste {
        set currentValue [lindex $item $col]
        if {$currentValue eq $val} {
            set kvalue [lindex $item end]
            return $kvalue
        }
    }
    return "error"
}

proc sortCmd {a b} {
    if {$a < $b} {
        return -1
    } elseif {$a > $b} {
        return 1
    } else {
        return 0
    }
    return 0
}


proc tblCreate {w} {
    variable datenDict
    set frt [frame .frt]

    # Create table
    set tbl [tablelist::tablelist $frt.tbl -columns {0 "ID" right 1 "Name" left 2 "Class" center} \
    -stretch all  -xscroll [list $frt.h set] -yscroll [list $frt.v set] -labelcommand tablelist::sortByColumn \
    -selectmode multiple -exportselection false]

    $tbl columnconfigure 0 -sortmode command -sortcommand [list createSortCommand $tbl 0]
    #$tbl columnconfigure 1 -sortmode command -sortcommand sortcmdTest
    $tbl columnconfigure 2 -sortmode command -sortcommand [list createSortCommand $tbl 2]

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

    set btntest [button $frb.test -text "Test" -command [list tlogtblcallback  infoTbl $tbl]]
    pack $btntest -side right
    bind [$tbl bodytag] <Double-1>  [list tlogtblcallback infoTbl $tbl %W %X %Y U]
    return $tbl
}

# Data list
set liste {{1 Herbert 3a} {4 Anna 7d} {3 Anna 7c} {2 Tim 9t} {5 Birgit 10b} \
{6 Werner 10w} {7 Tom 10t} {8 Suzi 10s} {9 Monika 11m} {10 Ilse 12I} \
{11 Holger 13H} {12 Thomas 67LT} {4 Tim 9t}}

# Create GUI
wm title . "Tablelist Status Example"
set tbl [tblCreate .]

puts "tblInsert  [tblInsert $tbl [lrange $liste 0 5]]"


if {0} {
  tlog:
      Start 04:11:39
infoTbl .frt.tbl .frt.tbl.body 939 513

Start tlog

  
  Output:
/usr/bin/tclsh /home/greg/Project/2024/tcl/example/tklib/tablelist/status/tabellen-testen-02.tcl 


save: -sortgetkeys {} -selectedRows {} -xview 0.0 -yview 0 -visibleRows {-1 -1} -visibleColumns {0 0} -columnWidths {15 8 16}
tblInsert  k0 k1 k2 k3 k4 k5




}

