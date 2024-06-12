#! /usr/bin/env tclsh

#20240612
package require Tk
package require tablelist_tile

package require struct::list
# help procs
# This function generates flat hierarchical test data
proc generateSimpleLists {{parentList {a b }} {dataList {1 2 3 }}  {shuffle 1} } {
    set length [llength $dataList]
    set dataList [::struct::list permutations $dataList]
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
proc generateLists {{parents {a b c d}}  {oneList {1 2 }} {twoList {1 2 3}} {threeList {1 2 3}} {fourList {1 2 3 4}} {shuffle 1} {flat 1}} {
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
        0 "id" left
        0 "one" right
        0 "two" right
        0 "three" right
        0 "four" right
        0 "five" right
        0 "six" right
        0 "seven" right
        0 "eight" right
        0 "nine" right
        0 "ten" right
    } -stretch all -width 100 -height 30 -treecolumn 0]

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

    set frcb [ttk::frame $w.frcb]
    set cbGenerator [ttk::combobox $frcb.cbGenerator -values [list \
    {generateSimpleLists {a b} {1 2} 0} \
    {generateSimpleLists {a b} {1 2} 1} \
    {generateSimpleLists {a b} {1 2 3} 1} \
    {generateSimpleLists {a b} {1 2 3 4} 1} \
    {generateLists {a b} {1 2} {1 2} {} {} 1 1}\
    {generateLists {a b} {1 2} {1 2} {1 2} {1 2 3} 1 1}\
    {generateLists {a b} {1 2 3} {1 2 3} {1 2 3} {1 2 3 4} 1 1}\
    {generateLists {a b} {1 2 3} {1 2 3} {1 2 3} {1 2 3 4 5} 1 1}\
    ] -width 50]
    $cbGenerator current 0
    set frb [ttk::frame $w.frb]
    set btnOutput  [ttk::button $frb.btnOutput -text Output -command [list callbOutput $tbl]]
    set btnPopulate  [ttk::button $frb.btnPopulate -text "Populate" -command [list populateTree $tbl $cbGenerator ]]
    pack $btnOutput $cbGenerator  $btnPopulate -side left
    pack $frb $frcb -expand 0 -fill x
    pack $frt -expand yes -fill both


    set bodyTag [$tbl bodytag]
    bind $bodyTag <Double-1>  [list callbOutput $tbl]
    populateTree $tbl $cbGenerator
    return $tbl
}

# Event-Handler
proc expandNode {tbl row} {
    # Hier kann Code hinzugefügt werden, um zusätzliche Daten dynamisch zu laden
    #puts "Expanding node at $row"
    #contentNode $tbl $row
    fillColumns $tbl $row
}

proc collapseNode {tbl row} {
    #puts "Collapsing node at $row"
    fillColumns $tbl $row

}

proc fillColumns {tbl row} {
    $tbl cellconfigure $row,1 -text "$row"
    $tbl cellconfigure $row,2 -text "[$tbl parentkey $row]"
    $tbl cellconfigure $row,3 -text "[$tbl noderow [$tbl parentkey $row] [$tbl getkey $row]]"
    $tbl cellconfigure $row,4 -text "[$tbl getkey $row]"
    $tbl cellconfigure $row,5 -text "[$tbl index $row]"
    $tbl cellconfigure $row,6 -text "[$tbl depth $row]"
    $tbl cellconfigure $row,7 -text "[$tbl descendantcount $row]"
    $tbl cellconfigure $row,8 -text "[$tbl childkeys $row]"
    $tbl cellconfigure $row,9 -text "[$tbl childindex $row]"
}

proc fillTblColumns {tbl} {
    set end [$tbl index end]
    for {set i 0}  {$i < $end} { incr i } {
        fillColumns $tbl $i
    }
}

# Function  Init
proc populateTree {tbl cbGenerator} {
    variable data
    $tbl delete 0 end
    if {[lindex [$cbGenerator get] 0] ni {generateLists generateSimpleLists} } {return}
    set data [{*}[$cbGenerator get]]

    set root root
    set root [$tbl insertchild $root end [list $root]]

    #problem with insertchildlist , no subs 
    if {0} {
        puts $data
        #set data {{{a \n 1} 001 012} {{a 2} 002 011} {{b 1} 101 112} {{b 2} 102 111}}
        set data {{a 001 012 } {a 002 011} {b 101 112} {b 102 111}}
        puts $data
        $tbl  insertchildlist  $root end $data
    } else {
        insertNode $tbl $data $root
    }
    # Sort based on the columns
    #$tbl collapseall
    #$tbl expandall
    for {set col [expr {[llength [lindex $data 0] ] - 1}]} {$col >= 0} {incr col -1} {
        $tbl sortbycolumn $col -increasing
    }
    fillTblColumns $tbl
    #callbOutput $tbl
}

proc insertNode {tbl data root} {
    foreach item $data {
        set currentid $root
        set length [llength $item]

        for {set i 0} {$i < $length} {incr i} {
            if {![llength [$tbl childkeys $currentid]]} {
                set currentid [$tbl insertchild $currentid end [list [lindex $item $i]]]
                fillColumns $tbl $currentid
            } else {
                set found 0
                foreach ck [$tbl childkeys $currentid] {
                    if {[lindex [$tbl rowcget $ck -text] 0] eq [lindex $item $i] } {
                        set found 1
                        break
                    }
                }
                if {$found} {
                    set currentid $ck
                } else {
                    set currentid [$tbl insertchild $currentid end [list [lindex $item $i]]]
                    #fillColumns $tbl $currentid
                }
            }
        }
    }
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

wm title . "Tree example with flate test data"
set mainFrame [ttk::frame .main]
pack $mainFrame -expand yes -fill both

set tbl [treetblcreate $mainFrame]

#########################
if {0} {
    Output:

}