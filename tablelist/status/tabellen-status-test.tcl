#! /usr/bin/env tclsh

# Example table creation
# 20240525
# tablellen-status-test.tcl

package require Tk
package require tablelist

source [file join [file dirname [info script]] tloglib.tcl]
source [file join [file dirname [info script]] info-text-tablelist.tcl]
source [file join [file dirname [info script]] tablelist-statuslib.tcl]
# Central dictionary for saving the status
variable tblDict
set tblDict [dict create]


#not used
proc sortKnumber {tbl} {
    set KeyList [$tbl getfullkeys 0 end]
    set OrigKeyList [lsort -dictionary $KeyList]
    set OrigItemList [$tbl get $OrigKeyList]
    $tbl delete 0 end
    $tbl insertlist end $OrigItemList
}

proc tblInsertList {tbl list} {
    variable tblDict
    set tblStatus [save_tablelist_status  $tbl 1]
    dict set tblDict tblStatus $tblStatus
    $tbl delete 0 end
    $tbl insertlist end $list
    foreach k [$tbl getfullkeys 0 end] {
      $tbl cellconfigure $k,end -text $k
    }
}

proc tblInsertSingle {tbl} {
    if {[lindex $::list [$tbl index end]] == ""} {
        return
    }
    $tbl selection clear 0 end
    $tbl activate [expr {[$tbl index active] + 1}]
    tlog "active [$tbl index active]  last:  [$tbl index last] end: [$tbl index end] size :  [$tbl size] list : \
    [lindex $::list [$tbl index end]] :: k: [$tbl getfullkeys 0 end]" 5 insert 1
    if {[$tbl index active] == [$tbl index last]} {
        set ipos [$tbl index end]
        $tbl insert $ipos [lindex $::list [incr ::countList]]
        $tbl cellconfigure $ipos,end -text [$tbl getfullkeys $ipos $ipos]
        $tbl activate [expr {[$tbl index active] + 1}]
    } else {
        set ipos [$tbl index active]
        $tbl insert $ipos [lindex $::list [incr ::countList]]
        $tbl cellconfigure $ipos,end -text [$tbl getfullkeys $ipos $ipos]
        $tbl activate [expr {[$tbl index active] - 1}]
    }
    $tbl selection clear 0 end
    #$tbl selection set [$tbl index active] [$tbl index active]
    tlog "active [$tbl index active]  last:  [$tbl index last] end: [$tbl index end] size :  [$tbl size] list : \
    [lindex $::list [$tbl index end]] :: k: [$tbl getfullkeys 0 end]" 3 insert 2
}

proc tblDeleteSingle {tbl args} {
    if {[lindex $::list [$tbl index end]] == ""} {
        return
    }
    set res [$tbl delete active]
    return $res
}

# Sort column with knumber
# In column $col all values are unique, except that you have a 1:1 to knumber
# $tbl columnconfigure $col -sortmode command -sortcommand [list createSortCommand $tbl $col]
#
# Assumption: knumber is the last value in the list
# Possibly critical access to list with knumber with info frame
# Speed problem with larger lists and may not work in later versions
proc createSortCommand {tbl col a b} {
    #puts "tbl: $tbl col: $col a: $a b: $b   [lindex [info frame -1] 5 6 ]"
    set ak [searchKpos $a [lindex [info frame -1] 5 6] $col]
    set bk [searchKpos $b [lindex [info frame -1] 5 6] $col]
    return [sortCmd $ak $bk]
}

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

proc OnComboSelected {w tbl type} {
    variable tblDict
    switch $type {
        selectmode {
            $tbl configure -selectmode [$w get]
        }
        sortID {
            dict set tblDict tbloptions sortID [$w get]
            foreach v [$w cget -values] {
                $tbl header cellconfigure 0,$v -background ""
            }
            $tbl header cellconfigure 0,[$w get] -background red
        }
        sortModus {
            dict set tblDict tbloptions sortModus [$w get]
        }
    }
}

proc printClickedCell {w x y} {
    foreach {tbl x y} [tablelist::convEventFields $w $x $y] {}
    puts "clicked on cell [$tbl containingcell $x $y] active [$tbl index active] header [$tbl header get 0 end] "
}

proc tblCreate {w} {
    variable tblDict
    set frt [frame .frt]
    set sortIDList [list 0 1 2 3]
    # Create table
    set tbl [tablelist::tablelist $frt.tbl -columns {0 "ID" right 0 "Name" left 0 "Class" center 0 kNr right}  \
    -stretch all -xscroll [list $frt.h set] -yscroll [list $frt.v set] -labelcommand tablelist::sortByColumn \
    -selectmode multiple -exportselection false]

    # Configure header cells
    $tbl header insert 0 [list]
    foreach v $sortIDList {
        $tbl header cellconfigure 0,$v -text "sortID"
    }
    $tbl header rowconfigure 0 -foreground blue

    $tbl columnconfigure 0 -sortmode command -sortcommand [list createSortCommand $tbl 0]
    $tbl columnconfigure 0 -sortmode dictionary
    $tbl columnconfigure 1 -sortmode dictionary
    $tbl columnconfigure 2 -sortmode dictionary
    $tbl columnconfigure 3 -sortmode dictionary
    #$tbl columnconfigure 1 -sortmode command -sortcommand sortcmdTest
    #$tbl columnconfigure 2 -sortmode command -sortcommand [list createSortCommand $tbl 2]

    set vsb [scrollbar $frt.v -orient vertical -command [list $tbl yview]]
    set hsb [scrollbar $frt.h -orient horizontal -command [list $tbl xview]]

    # Add frame
    set frb [frame .frb]
    set frcb [frame .frcb]
    pack $frcb $frb -fill x -side bottom -expand 0
    pack $frt -fill both -side top -expand true
    pack $vsb -side right -fill y -expand 0
    pack $hsb -side bottom -fill x -expand 0
    pack $tbl -fill both -expand true

    # combobox
    set cbselection [ttk::combobox $frcb.cbselection -values [list single browse multiple extended] -exportselection 0 -width 8]
    $cbselection current 1
    bind $cbselection <<ComboboxSelected>> [namespace code [list OnComboSelected %W $tbl selectmode]]
    pack $cbselection -side left

    set cbsortID [ttk::combobox $frcb.cbsortID -values $sortIDList -exportselection 0 -width 4]
    $cbsortID current 1
    bind $cbsortID <<ComboboxSelected>> [namespace code [list OnComboSelected %W $tbl sortID]]
    event generate $cbsortID <<ComboboxSelected>>
    pack $cbsortID -side left
    
    dict set tblDict tbloptions  sortModus 1
    set cbsortModus [ttk::combobox $frcb.cbsortModus -values [list 0 1] -exportselection 0 -width 4]
    $cbsortModus current 1
    bind $cbsortModus <<ComboboxSelected>> [namespace code [list OnComboSelected %W $tbl sortModus]]
    event generate $cbsortModus <<ComboboxSelected>>
    pack $cbsortModus -side left

    # button
    dict set tblDict tbloptions sortID [$cbsortID get]
    set btnsave [button $frb.save -text "Save Status" -command {
        variable tblDict
        dict set tblDict tblStatus [save_tablelist_status  .frt.tbl [dict get $tblDict tbloptions sortModus] [dict get $tblDict tbloptions sortID]]
        puts "tblStatus saved:\n[dict get $tblDict tblStatus]\n"
    }]
    pack $btnsave -side left

    set btnrestore [button $frb.restore -text "Restore Status" -command {
        variable tblDict
        set sortModus 1
        restore_tablelist_status .frt.tbl [dict get $tblDict tblStatus]
        puts "tblStatus restored:\n[dict get $tblDict tblStatus]\n"
    }]
    pack $btnrestore -side left

    set btninsert [button $frb.insert -text "Insert Data" -command [list tblInsertSingle $tbl]]
    pack $btninsert -side left

    set btndelete [button $frb.delete -text "Delete Data" -command [list tblDeleteSingle $tbl %W %x %y]]
    pack $btndelete -side left

    set btntest [button $frb.test -text "TStatus" -command [list tlogwcallback infoTbl $tbl %s]]
    pack $btntest -side left

    # bind
    bind [$tbl bodytag] <Double-1> [list tlogwcallback infoTbl $tbl %W %X %Y U %s %T]

    bind [$tbl bodytag] <Button-1> {printClickedCell %W %x %y}

    dict set tblDict tbl $tbl
    return $tbl
}

# Data list
set list {{a Herbert 3a} {d Anna 7c} {c Anna 7d} {b "" 9t} {e Birgit 10b} \
{f Werner 10w} {g Tom 10t} {h Suzi 10s} {i Monika 11m} {j "" 12I} \
{k Holger 13H} {l Thomas 67LT} {d Tim 9t}}
set ::countList 4

# Create GUI
wm title . "Tablelist Status Example"
set tbl [tblCreate .]

puts "tblInsertList  [tblInsertList $tbl [lrange $list 0 $::countList]]"
puts $tblDict
puts "\n"