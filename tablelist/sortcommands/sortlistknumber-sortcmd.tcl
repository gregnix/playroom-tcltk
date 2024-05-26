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

    proc OnComboSelected {w tbl type} {
        switch $type {
            selectmode {
                $tbl configure -selectmode [$w get]
            }
            sortcmdzero {
                set sortcmd [$w get]
                switch $sortcmd {
                    command {
                        $tbl columnconfigure 0 -sortmode command -sortcommand [list createSortCommand $tbl 0]
                    }
                    dictionary {
                        $tbl columnconfigure 0 -sortmode dictionary
                    }
                }

                for {set v 0 } { $v <  [$tbl columncount]}  {incr v} {
                    $tbl header cellconfigure 0,$v -text [$tbl columncget $v -sortcommand ]
                    $tbl header cellconfigure 1,$v -text [$tbl columncget $v -sortmode ]
                }
                $tbl header cellconfigure 0,0 -text $sortcmd
            }
        }
    }
 

    # Create table (example)
    set tbl [tablelist::tablelist .tbl -columns {10 "ID" right 0 "Name" left 0 "Class" center} \
    -labelcommand tablelist::sortByColumn -width 50 -stretch all]
    # tbl header
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
    set cbselection [ttk::combobox .cbselection -values [list dictionary command ] -exportselection 0 ]
    $cbselection current 1
    bind $cbselection <<ComboboxSelected>> [namespace code [list OnComboSelected %W $tbl sortcmdzero]]
    pack $cbselection -side left
    event generate $cbselection <<ComboboxSelected>>

    
    # Example data
    set data {{1 "Herbert" "3a"} {5 "Anna" "7d"} {3 "Tim" "9t"}}
    # Insert data into table
    foreach item $data {
        $tbl insert end $item
    }    
    
}
