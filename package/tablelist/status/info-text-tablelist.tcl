#! /usr/bin/env tclsh

#20240519
#info-text-tabelist.tcl
#Info tbl
proc infoTbl {tbl args} {
    set LU Other
    if {[llength $args] == 4 } {
        set W [lindex $args 0]
        set ox [lindex $args 1]
        set oy [lindex $args 2]
        set LU [lindex $args 3]
    } elseif {[llength [lindex $args 0]] == 4 } {
        set W [lindex $args 0 0]
        set ox [lindex $args 0 1]
        set oy [lindex $args 0 2]
        set LU [lindex $args 0 3]
    } else {
        set W -1
        set ox -1
        set oy -1
    }

    # U  X Y, L x y, 
    if {$LU == "U"} {
        #infoTbl $tbl %W %X %Y
        # corr X Y => x y
        set x [expr {$ox - [winfo rootx $tbl]}]
        set y [expr {$oy - [winfo rooty $tbl]}]
    } elseif  {$LU == "L"} {
        #infoTbl $tbl %W %x %y
        lassign [tablelist::convEventFields $W $ox $oy] convW x y
    } else {
        set x $ox
        set y $oy
    }
    # mouse click or button
    set doubleclick  [winfo exists $W]

    if {[winfo exists $W]} {
        set path [tablelist::getTablelistPath $W]
    } else {
        set path $tbl
    }

    set ci [$tbl cellindex @$x,$y]
    set gia [$tbl getcell @$x,$y]
    set col [$tbl columnindex @$x,$y]
    set cola [$tbl columnindex active]
    set rows [$tbl curselection]
    set anchor [$tbl getkeys anchor]
    set active [$tbl getkeys active]
    set row [$tbl getkeys active]
    set top [$tbl getkeys top]
    set bottom  [$tbl getkeys bottom]
    set end [$tbl getkeys end]
    set last [$tbl getkeys last]
    set topIndex [$tbl index top]
    set bottomIndex  [$tbl index bottom]
    set selectmode  [$tbl configure -selectmode]

    append result "\$tbl : $tbl :: path : $path \n"
    append result "test [$tbl bodytag] \n"
    append result "\$tbl cget -selectmode : [$tbl cget -selectmode]\n"
    append result "doubleclick $doubleclick :: args : $args :: llength \$args : [llength $args]\n"
    append result "W : $W ox: $ox oy: $oy \n"
    append result "W : $W x: $x y: $y\n"
    append result "set col \[\$tbl columnindex \@\$x,\$y] :: \$col : $col :: \$cola : $cola \n"
    append result "set rows \[$tbl curselection\] : $rows  ::  set row \[\$tbl getkeys active\] : $row \n"
    append result "\$tbl rowcget \$row -text : [$tbl rowcget $row -text] :: \$tbl rowcget  \$row -name : [$tbl rowcget $row -name] \n"
    append result "\$tbl get \$row : [$tbl get $row] \n"
    append result "\$tbl getkeys  active : [$tbl getkeys  active] \n"
    append result "active : $active :: anchor : $anchor :: top: $top :: bottom : $bottom :: end : $end :: last: $last\n"
    append result "\$tbl index anchor [$tbl index anchor] \n"
    append result "active : [$tbl index active] :: anchor : [$tbl index anchor] :: top: [$tbl index top] :: bottom : [$tbl index bottom] :: end : [$tbl index end] :: last: [$tbl index last]\n"
    append result "\$tbl size : [$tbl size] :: \$tbl viewablerowcount : [$tbl viewablerowcount]\n"
    append result "\$tbl toplevelkey \$row : [$tbl toplevelkey $row]\n"
    append result "\$tbl cellindex @\$x,\$y: $ci :: \$tbl getcell \$ci :  [$tbl getcell $ci] :: \$tbl getcell @\$x,\$y : $gia\n"
    append result "\$tbl curcellselection : [$tbl curcellselection]\n"
    append result "\$tbl getfullkeys 0 end : [$tbl getfullkeys 0 end ] :: \$tbl getfullkeys {0 2 3} : [$tbl getfullkeys {0 2 3} ]\n"
    append result "\$tbl get k\[\$tbl getkeys end\] : [$tbl get k[$tbl getkeys end]] \n"
    append result "\$tbl sortorder : [$tbl sortorder]  :: \$tbl sortcolumn : [$tbl sortcolumn] :: tbl sortorderlist: [$tbl sortorderlist]\n"
    append result "\$tbl sortorderlist: [$tbl sortorderlist] :: \$tbl sortcolumnlist: [$tbl sortcolumnlist]\n"
    append result "\n"
    append result "\$tbl cellconfigure  \$col :\n[join [$tbl cellconfigure  $ci] \n] \n"
    append result "\n"
    append result "\$tbl columnconfigure  \$col :\n[join [$tbl columnconfigure  $col] \n] \n"
    append result "\n"
    append result "\$tbl rowconfigure  \$row :\n[join [$tbl rowconfigure  $row] \n] \n"
    append result "\n"
    append result "\$tbl configure :\n [join [$tbl configure] \n] \n"

    return $result
}
