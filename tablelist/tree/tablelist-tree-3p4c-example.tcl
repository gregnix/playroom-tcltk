#! /usr/bin/env tclsh

#20240610

#
package require Tk
package require tablelist_tile

package require struct::list
# help procs
# This function generates flat hierarchical test data
proc generateSimpleLists {{dataList {1 2 3}} {parentList {a b c}} {shuffle 1} } {
    set length [llength $dataList]
    puts $length
    set dataList [::struct::list permutations $dataList]
    puts $dataList
    foreach  parent  $parentList {
        foreach data $dataList {
            set item ""
            for {set i 0} {$i < $length } {incr i} {
                lappend item [lsearch $parentList $parent]${i}[lindex $data $i]
            }
            lappend resultList [list $parent {*}$item]

        }
    }

    if {$shuffle} {
        set resultList  [struct::list shuffle $resultList]
    }
    return $resultList
}
# # This function generates flat hierarchical test data
proc generateLists {{parents {a b}}  {oneList {1 2 }} {twoList {1 2 }} {threeList {1 2 }} {fourList {1 2 3}} {shuffle 1} {flat 1} {simple 1}} {
    set resultList {}
    set oneList [::struct::list permutations $oneList]
    set twoList [::struct::list permutations $twoList]
    set threeList [::struct::list permutations $threeList]
    set fourList [::struct::list permutations $fourList]
    foreach parent $parents {
        foreach one $oneList {
            if {$flat} {set one [string map {{ } {}} $one]}
            foreach two $twoList {
                if {$flat} {set two [string map {{ } {}} $two]}
                foreach three $threeList {
                    if {$flat} {set three [string map {{ } {}} $three]}
                    foreach four $fourList {
                        if {$flat} {set four [string map {{ } {}} $four]}
                        if {$four ne {} } {
                            lappend resultList [list $parent $one $two $three $four]
                        } elseif {$three ne {} } {
                            lappend resultList [list $parent $one $two $three]
                        } elseif {$two ne {}} {
                            lappend resultList [list $parent $one $two ]
                        } else {
                            lappend resultList [list $parent $one ]
                        }
                    }
                }
            }
        }
    }
    if {$shuffle} {
        set resultList  [struct::list shuffle $resultList]
    }
    return $resultList
}


proc treetblcreate {w} {
    set frt [ttk::frame $w.frt]

    # Tree-Widget
    set tbl [tablelist::tablelist $frt.tbl -columns {
        0 "id" right
        0 "one" right
        0 "two" right
        0 "three" right
        0 "four" right
    } -stretch all -width 40 -height 40 -treecolumn 0]

    # Enable expansion and collapse of nodes, sorting
    $frt.tbl configure -expandcommand "expandNode" -collapsecommand "collapseNode" \
    -labelcommand tablelist::sortByColumn 

    # Scrollbars
    set vsb [scrollbar $frt.vsb -orient vertical -command [list $tbl yview]]
    set hsb [scrollbar $frt.hsb -orient horizontal -command [list $tbl xview]]
    $tbl configure -yscroll [list $vsb set] -xscroll [list $hsb set]

    pack $vsb -side right -fill y
    pack $hsb -side bottom -fill x
    pack $tbl -expand yes -fill both
    pack $frt -expand yes -fill both

    set frb [ttk::frame $w.frb]
    set cbGenerator [ttk::combobox $frb.cbGenerator -values [list generateSimpleLists generateLists]]
    $cbGenerator current 0
    set btnOutput  [ttk::button $frb.btnOutput -text Output -command [list callbOutput $tbl]]
    set btnPopulate  [ttk::button $frb.btnPopulate -text "Populate" -command [list populateTree $tbl $cbGenerator ]]
    pack $btnOutput $cbGenerator  $btnPopulate -side left
    pack $frb -expand no -fill x

    set bodyTag [$tbl bodytag]
    bind $bodyTag <Double-1>  [list callbOutput $tbl]
    populateTree $tbl $cbGenerator
    return $tbl
}


# Event-Handler
proc expandNode {tbl row} {
    # Hier kann Code hinzugefügt werden, um zusätzliche Daten dynamisch zu laden
    puts "Expanding node at $row"
    #contentNode $tbl $row
}

proc collapseNode {tbl row} {
    puts "Collapsing node at $row"
}

# Function  Init
proc populateTree {tbl cbGenerator} {
    puts "cbGenerator: $cbGenerator"
    variable data
    $tbl delete 0 end
    #set data [generateSimpleLists {1 2 3 } {a b c} 0]
    #set data [generateLists {a b c} {1 2 3} {1 2 3} {1 2 3 } {} 1 1 1]
    #set data [generateLists ]
    set data [[$cbGenerator get]]
    set idliste [list]
    foreach item $data {
        set id [lindex $item 0]
        set one [lindex $item 1]
        set two [lindex $item 2]
        set three [lindex $item 3]
        set four [lindex $item 4]
        if {$id ni $idliste} {
            lappend idliste $id
            set idliste [lsort -unique $idliste]
            set currentid [$tbl insertchild root end [list $id]]
            set currentid [$tbl insertchild $currentid end [list $id $one]]
            set currentid [$tbl insertchild $currentid end [list $id $one $two]]
        } else {
            foreach idrow [$tbl childkeys root] {
                if {[lindex [$tbl rowcget $idrow -text] 0]  eq $id } {
                    set currentid $idrow
                    foreach onerow [$tbl childkeys $idrow] {
                        if {[lindex [$tbl rowcget $onerow -text] 1]  eq $one } {
                            set currentid $onerow
                            foreach tworow [$tbl childkeys $onerow] {
                                if {[lindex [$tbl rowcget $tworow -text] 2]  eq $two } {
                                    set currentid $tworow
                                }
                            }
                            if {$currentid eq $onerow } {
                                set currentid [$tbl insertchild $currentid end [list $id $one $two]]
                            }
                        }
                    }
                    if {$currentid eq $idrow } {
                        set currentid [$tbl insertchild $currentid end [list $id $one]]
                    }
                }
            }
        }
        $tbl insertchild $currentid end [list $id $one $two $three $four]
    }
    #$tbl sort -increasing
    #$tbl columnconfigure $col -sortmode integer
    $tbl sortbycolumn 4 -increasing
    $tbl sortbycolumn 3 -increasing
    $tbl sortbycolumn 2 -increasing
    $tbl sortbycolumn 1 -increasing
    $tbl sortbycolumn 0 -increasing
    #$tbl refreshsorting root

    callbOutput $tbl
}

# for debug
proc callbOutput {tbl} {
    variable data
    set row [lindex [$tbl childkeys root] 0]
    set rows [$tbl curselection]
    #set curcellselection [$tbl curcellselection]
    lappend  parentsRoot root [$tbl childkeys root]
    set parentkey [$tbl parentkey $row]
    set childcount [$tbl childcount $row]
    set childindex [$tbl childindex $row]
    set descendantcount [$tbl  descendantcount $row]
    set childkeys  [$tbl childkeys $row]
    set depth [$tbl depth $row]
    set noderow [$tbl noderow $parentkey $childindex]
    set childKindex [lindex $childkeys $childindex]
    set toplevelkey [$tbl toplevelkey $row]

    #pk
    set childcountpk [$tbl childcount $parentkey]
    if {$parentkey eq "root"} {
        set childindexpk [$tbl childindex [lindex [$tbl childkeys root] 0]]
    } else {
        set childindexpk [$tbl childindex $parentkey]
    }
    set childkeyspk  [$tbl childkeys $parentkey]
    set depthpk [$tbl depth $parentkey]
    set descendantcountpk [$tbl  descendantcount $parentkey]

    #active rowa
    set rowa [$tbl index active]
    set parentkeya [$tbl parentkey $rowa]
    set childcounta [$tbl childcount $rowa]
    set childindexa [$tbl childindex $rowa]
    set descendantcounta [$tbl  descendantcount $rowa]
    set childkeysa  [$tbl childkeys $rowa]
    set deptha [$tbl depth $rowa]

    # Output widget
    set top .topContent
    set f $top.ft
    set t $f.t
    if {![winfo exists $top]} {
        toplevel $top
        frame $f
        pack $f -side top -fill both -expand true
        set t [text $f.t -setgrid true -wrap none -width 120 \
    -yscrollcommand "$f.vset set" -xscrollcommand "$f.hset set"]
        scrollbar $f.vset -orient vert -command "$f.t yview"
        scrollbar $f.hset -orient hori -command "$f.t xview"
        pack $f.hset -side bottom -fill x
        pack $f.vset -side right -fill y
        pack $f.t -side left -fill both -expand true
        wm geometry $top +0+0
    }
    $t delete 1.0 end
    $t insert end   "row: $row :: rows : $rows :: noderow: $noderow :: [$tbl getkey $row]\n"
    $t insert end   "parentsRoot: $parentsRoot ::  parentkey: $parentkey ::  descendantcount: $descendantcountpk\n"
    $t insert end   "childcount : $childcount :: childindex: $childindex :: childkeys: $childkeyspk :: depth : $depthpk\n"
    $t insert end   "\n"
    $t insert end   "row: $row :: \$tbl getkey \$row: [$tbl getkey $row]:: [$tbl getfullkey $row $row]\n"
    $t insert end   "parentkey: $parentkey ::  descendantcount: $descendantcount\n"
    $t insert end   "childcount : $childcount :: childindex: $childindex :: childkeys: $childkeys :: depth : $depth\n"
    $t insert end   "\n"
    $t insert end   "active rowa: $rowa :: \$tbl getkey \$rowa: [$tbl getkey $rowa]:: [$tbl getfullkey $rowa $rowa]\n"
    $t insert end   "active parentkey: $parentkeya ::  descendantcount: $descendantcounta\n"
    $t insert end   "active childcount : $childcounta :: childindex: $childindexa :: childkeys: $childkeysa :: depth : $deptha\n"
    $t insert end  "\n \$tbl get 0 end\n"
    $t insert end  [join [$tbl get 0 end] \n]
    $t insert end  "\n\n  dumptostring"
    $t insert end [$tbl dumptostring]
    $t insert end  "\n\n  data  length [llength $data]\n"
    $t insert end  [join $data \n]
}



#########################
# main
# gui
## tbl init


wm title . "Tablelist Tree example with flate test data"
set mainFrame [ttk::frame .main]
pack $mainFrame -expand yes -fill both

set tbl [treetblcreate $mainFrame]

#########################
if {0} {
Output:
row: k6 :: rows : 11 :: noderow: 0 :: 6
parentsRoot: root {k6 k12 k0} ::  parentkey: root ::  descendantcount: 42
childcount : 3 :: childindex: 0 :: childkeys: k6 k12 k0 :: depth : 0

row: k6 :: $tbl getkey $row: 6:: k6
parentkey: root ::  descendantcount: 13
childcount : 3 :: childindex: 0 :: childkeys: k7 k10 k34 :: depth : 1

active rowa: 11 :: $tbl getkey $rowa: 36:: k36
active parentkey: k34 ::  descendantcount: 1
active childcount : 1 :: childindex: 0 :: childkeys: k37 :: depth : 3

 $tbl get 0 end
a {} {} {} {}
a 001 {} {} {}
a 001 012 {} {}
a 001 012 023 {}
a 001 013 {} {}
a 001 013 022 {}
a 002 {} {} {}
a 002 011 {} {}
a 002 011 023 {}
a 002 013 021 {}
a 003 {} {} {}
a 003 011 {} {}
a 003 011 022 {}
a 003 012 021 {}
b {} {} {} {}
b 101 {} {} {}
b 101 112 {} {}
b 101 112 123 {}
b 101 113 {} {}
b 101 113 122 {}
b 102 {} {} {}
b 102 111 {} {}
b 102 111 123 {}
b 102 113 121 {}
b 103 {} {} {}
b 103 111 {} {}
b 103 111 122 {}
b 103 112 121 {}
c {} {} {} {}
c 201 {} {} {}
c 201 212 223 {}
c 201 213 {} {}
c 201 213 222 {}
c 202 {} {} {}
c 202 211 223 {}
c 202 213 {} {}
c 202 213 221 {}
c 203 {} {} {}
c 203 211 {} {}
c 203 211 222 {}
c 203 212 {} {}
c 203 212 221 {}

  dumptostringid one two three four
0 increasing

-1 0 1 2 1 4 0 6 7 6 0 10 11 10 -1 14 15 16 15 18 14 20 21 20 14 24 25 24 -1 28 29 29 31 28 33 33 35 28 37 38 37 40
{a {} {} {} {}} {a 001 {} {} {}} {a 001 012 {} {}} {a 001 012 023 {}} {a 001 013 {} {}} {a 001 013 022 {}} {a 002 {} {} {}} {a 002 011 {} {}} {a 002 011 023 {}} {a 002 013 021 {}} {a 003 {} {} {}} {a 003 011 {} {}} {a 003 011 022 {}} {a 003 012 021 {}} {b {} {} {} {}} {b 101 {} {} {}} {b 101 112 {} {}} {b 101 112 123 {}} {b 101 113 {} {}} {b 101 113 122 {}} {b 102 {} {} {}} {b 102 111 {} {}} {b 102 111 123 {}} {b 102 113 121 {}} {b 103 {} {} {}} {b 103 111 {} {}} {b 103 111 122 {}} {b 103 112 121 {}} {c {} {} {} {}} {c 201 {} {} {}} {c 201 212 223 {}} {c 201 213 {} {}} {c 201 213 222 {}} {c 202 {} {} {}} {c 202 211 223 {}} {c 202 213 {} {}} {c 202 213 221 {}} {c 203 {} {} {}} {c 203 211 {} {}} {c 203 211 222 {}} {c 203 212 {} {}} {c 203 212 221 {}}

  data  length 18
c 203 211 222
c 203 212 221
a 001 012 023
a 002 013 021
b 101 113 122
b 102 113 121
b 101 112 123
c 202 211 223
c 201 212 223
c 201 213 222
b 102 111 123
c 202 213 221
b 103 112 121
a 001 013 022
a 003 012 021
a 003 011 022
a 002 011 023
b 103 111 122

}