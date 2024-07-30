#! /usr/bin/env tclsh

# Sort column with knumber
# In column $col all values are unique, except that you have a 1:1 to knumber
# $tbl columnconfigure $col -sortmode command -sortcommand [list createSortCommand $tbl $col]
#
# Assumption: knumber is the last value in the list
# Possibly critical access to list with knumber with info frame
# Speed problem with larger lists and may not work in later versions

# Procedure to create a sort command for a table
proc createSortCommand {tbl col a b} {
    # Search for knumber positions for a and b
    set ak [searchKpos $a [lindex [info frame -1] 5 6] $col]
    set bk [searchKpos $b [lindex [info frame -1] 5 6] $col]
    # Return the sorting command
    return [sortCmd $ak $bk]
}

# Procedure to search for a value in a specified column of a list and return the last element of the matching item
proc searchKpos {val list col} {
    foreach item $list {
        set currentValue [lindex $item $col]
        if {$currentValue eq $val} {
            set kvalue [lindex $item end]
            return $kvalue
        }
    }
    return "error"
}

# Procedure to compare two values for sorting
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

#Example
if {[info script] eq $argv0} {
    package require tablelist

    proc OnComboSelected {w tbl types} {
        set type [lindex $types 0]
        puts $type
        switch $type {
            sortcmd {
                set sortcmd [$w get]
                set col [{*}[lindex $types 1] get]
                set origcol $col
                switch $sortcmd {
                    cmdone {
                        $tbl columnconfigure $col -sortmode command -sortcommand [list createSortCommand $tbl $col]
                    }
                    cmdtwo {
                        $tbl columnconfigure $col -sortmode command -sortcommand sortCmd
                    }
                    ascii -
                    asciinocase -
                    integer -
                    real -
                    dictionary {
                        $tbl columnconfigure $col -sortmode $sortcmd
                    }
                    configure {
                        for {set col 0 } { $col <  [$tbl columncount]}  {incr col} {
                            puts "col: $col :: [$tbl columnconfigure $col -sortmode] :: [$tbl columnconfigure $col -sortcommand]"
                        }
                        for {set col 0 } { $col <  [$tbl columncount]}  {incr col} {
                            puts "col: $col :: [$tbl columncget $col -sortmode] :: [$tbl columncget $col -sortcommand]"
                        }
                    }
                }

                for {set col 0 } { $col <  [$tbl columncount]}  {incr col} {
                    $tbl header cellconfigure 0,$col -text [$tbl columncget $col -sortcommand ]
                    $tbl header cellconfigure 1,$col -text [$tbl columncget $col -sortmode ]
                }
                set col $origcol
                $tbl header cellconfigure 0,$col -text [$tbl columncget $col -sortcommand ]
            }
        }
    }


    # Create table (example)
    set tbl [tablelist::tablelist .tbl -columns {20 "ID" right 0 "Name" left 0 "Class" center} \
    -labelcommand tablelist::sortByColumn -width 60 -stretch all]

    # tbl header, for display sortcommand and sortmode
    $tbl header insert 0 [list]
    $tbl header insert 1 [list]
    foreach v [list 0 1 2] {
        $tbl header cellconfigure 0,$v -text [$tbl columncget $v -sortcommand ]
        $tbl header cellconfigure 1,$v -text [$tbl columncget $v -sortmode ]
    }

    pack $tbl -fill both -expand true

    # Configure the column for sorting
    $tbl columnconfigure 0 -sortmode command -sortcommand [list createSortCommand .tbl 0]
    $tbl columnconfigure 1 -sortmode command -sortcommand sortCmd
    $tbl columnconfigure 2 -sortmode dictionary

    # combobox
    set cbsortcol [ttk::combobox .cbsortcol -values [list 0 1 2] -exportselection 0 ]
    $cbsortcol current 0
    #bind $cbsortcol <<ComboboxSelected>> [namespace code [list OnComboSelected %W $tbl sortcol]]
    #event generate $cbsortcol <<ComboboxSelected>>
    pack $cbsortcol -side left

    set cbsortmode [ttk::combobox .cbsortmode -values [list ascii asciinocase integer real dictionary cmdone cmdtwo configure] -exportselection 0 ]
    $cbsortmode current 7
    bind $cbsortmode <<ComboboxSelected>> [namespace code [list OnComboSelected %W $tbl "sortcmd $cbsortcol"]]
    event generate $cbsortmode <<ComboboxSelected>>
    pack $cbsortmode -side left



    # Example data
    set data {{1 "Herbert" "3a"} {5 "Anna" "7d"} {3 "Tim" "9t"}  {15 "Petra" "12e"}}
    # Insert data into table
    foreach item $data {
        $tbl insert end $item
    }
}