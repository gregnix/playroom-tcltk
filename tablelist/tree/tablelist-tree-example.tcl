#! /usr/bin/env tclsh

#20240612
package require Tk
package require tablelist_tile
package require struct::set
package require struct::list

# dict - nested
source [file join [file dirname [info script]] lib  dict-tree-tablelist-load.tcl]

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
        0 "row" right
        0 "getkey" right
        0 "index" right
        0 "parent" right
        0 "depth" right
        0 "noderow" right
        0 "descendantcount" right
        0 "childcount" right
        0 "childkeys" right
        0 "childindex" right
        0 "elven" right
    } -stretch all -width 120 -height 30 -treecolumn 0]

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
    {generateSimpleLists {a b} {1} 0} \
    {generateSimpleLists {a b} {1 2} 0} \
    {generateSimpleLists {a b} {1 2} 1} \
    {generateSimpleLists {a b} {1 2 3} 1} \
    {generateSimpleLists {a b} {1 2 3 4} 1} \
    {generateLists {a b} {1 2} {1 2} {} {} 1 1}\
    {generateLists {a b} {1 2} {1 2} {1 2} {1 2 3} 1 1}\
    {generateLists {a b} {1 2 3} {1 2 3} {1 2 3} {1 2 3 4} 1 1}\
    {generateLists {a b} {1 2 3} {1 2 3} {1 2 3} {1 2 3 4 5} 1 1}\
    ] -width 50]
    $cbGenerator current 1
    set frb [ttk::frame $w.frb]
    set btnOutput  [ttk::button $frb.btnOutput -text Output -command [list callbOutput $tbl]]
    set btnPopulate  [ttk::button $frb.btnPopulate -text "Populate" -command [list populateTree $tbl $cbGenerator ]]
    set btnOpen  [ttk::button $frb.btnOpen -text "Open File" -command [list openFile $tbl]]
    set btnSave  [ttk::button $frb.btnSave -text "Save as File" -command [list saveFile $tbl]]
    set btnTblFill  [ttk::button $frb.btnTblFill -text "Tbl fill" -command [list fillTblColumns $tbl]]
    pack $btnOutput $cbGenerator $btnPopulate $btnOpen $btnSave $btnTblFill -side left
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
    $tbl cellconfigure $row,2 -text "[$tbl getkey $row]"
    $tbl cellconfigure $row,3 -text "[$tbl index $row]"
    $tbl cellconfigure $row,4 -text "[$tbl parentkey $row]"
    $tbl cellconfigure $row,5 -text "[$tbl depth $row]"
    $tbl cellconfigure $row,6 -text "[$tbl noderow [$tbl parentkey $row] [$tbl getkey $row]]"
    $tbl cellconfigure $row,7 -text "[$tbl descendantcount $row]"
    $tbl cellconfigure $row,8 -text "[$tbl childcount $row]"
    $tbl cellconfigure $row,9 -text "[$tbl childkeys $row]"
    $tbl cellconfigure $row,10 -text "[$tbl childindex $row]"
}

proc fillTblColumns {tbl} {
    set liststart [$tbl expandedkeys]
    $tbl expandall
    set end [$tbl descendantcount 0]
    for {set i 0}  {$i <= $end} { incr i } {
        fillColumns $tbl $i
    }
    $tbl collapseall
    $tbl expand $liststart
    set listend [$tbl expandedkeys]
    $tbl collapse [::struct::set difference $listend $liststart]

}

# Function  Init
proc populateTree {tbl cbGenerator} {
    $tbl setbusycursor
    puts "time: [time {
    variable data
    $tbl delete 0 end
    if {[lindex [$cbGenerator get] 0] ni {generateLists generateSimpleLists} } {return}
    set data [{*}[$cbGenerator get]]

    set root root
    set root [$tbl insertchild $root end [list $root]]

    insertNode $tbl $data $root
    # Sort based on the columns
    #$tbl collapseall
    #$tbl expandall
    $tbl sortbycolumn 0 -increasing
    fillTblColumns $tbl
    callbOutput $tbl
    }]"
    $tbl  restorecursor
}


proc insertNode {tbl data root} {
    foreach item $data {
        set currentid $root
        set length [llength $item]

        for {set i 0} {$i < $length} {incr i} {
            set itemi [lindex $item $i]
            if {![llength [$tbl childkeys $currentid]]} {
                set currentid [$tbl insertchild $currentid end $itemi]
                #fillColumns $tbl $currentid
            } else {
                set found 0
                foreach ck [$tbl childkeys $currentid] {
                    if {[lindex [$tbl rowcget $ck -text] 0] eq $itemi } {
                        set found 1
                        break
                    }
                }
                if {$found} {
                    set currentid $ck
                } else {
                    set currentid [$tbl insertchild $currentid end $itemi]
                    #fillColumns $tbl $currentid
                }
            }
        }
    }
}

proc openFile {tbl} {
    set pwd  [pwd]
    set openfile [file join $pwd test.txt]
    set filename [tk_getOpenFile -initialfile $openfile ]
    set result [$tbl loadfromfile $filename]
    fillTblColumns $tbl
}
proc saveFile {tbl} {
    set pwd [pwd]
    set savefile [file join $pwd test.txt]
    set filename  [tk_getSaveFile -initialfile $savefile]
    set result [$tbl dumptofile $filename]
    puts $result
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
        wm geometry $top 120x50+1920+0
    }
    
    set colslist [$tbl cget -columntitles]
    set tree [dataToTblTree $data]
    set loadstring [treeToTblLoad $tree $colslist]
      walkTree tree {} printNode  
    
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
    $t insert end  "\n\n dumptostring:\n"
    $t insert end [$tbl dumptostring]
    $t insert end  "\n:dumptostring"
    $t insert end  "\n\n extern loadstring:\n"
    $t insert end  $loadstring
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
    row: k0 :: rows : 0 :: noderow: 0 :: 0
    parentsRoot: root k0 ::  parentkey: root ::  descendantcount: 11
    childcount : 2 :: childindex: 0 :: childkeys: k0 :: depth : 0

    row: k0 :: $tbl getkey $row: 0:: k0
    parentkey: root ::  descendantcount: 10
    childcount : 2 :: childindex: 0 :: childkeys: k1 k6 :: depth : 1

    active rowa: 0 :: $tbl getkey $rowa: 0:: k0
    active parentkey: root ::  descendantcount: 10
    active childcount : 2 :: childindex: 0 :: childkeys: k1 k6 :: depth : 1

    $tbl get 0 end
    root 0 root 0 0 0 1 10 {k1 k6} 0 {}
    a 1 k0 6 1 1 2 4 {k2 k4} 0 {}
    001 2 k1 6 2 2 3 1 k3 0 {}
    012 3 k2 4 3 3 4 0 {} 0 {}
    002 4 k1 6 4 4 3 1 k5 1 {}
    011 5 k4 6 5 5 4 0 {} 0 {}
    b 6 k0 11 6 6 2 4 {k7 k9} 1 {}
    101 7 k6 11 7 7 3 1 k8 0 {}
    112 8 k7 9 8 8 4 0 {} 0 {}
    102 9 k6 11 9 9 3 1 k10 1 {}
    111 10 k9 11 10 10 4 0 {} 0 {}

    dumptostringid one two three four five six seven eight nine ten
    0 increasing

    -1 0 1 2 1 4 0 6 7 6 9
    {root 0 root 0 0 0 1 10 {k1 k6} 0 {}} {a 1 k0 6 1 1 2 4 {k2 k4} 0 {}} {001 2 k1 6 2 2 3 1 k3 0 {}} {012 3 k2 4 3 3 4 0 {} 0 {}} {002 4 k1 6 4 4 3 1 k5 1 {}} {011 5 k4 6 5 5 4 0 {} 0 {}} {b 6 k0 11 6 6 2 4 {k7 k9} 1 {}} {101 7 k6 11 7 7 3 1 k8 0 {}} {112 8 k7 9 8 8 4 0 {} 0 {}} {102 9 k6 11 9 9 3 1 k10 1 {}} {111 10 k9 11 10 10 4 0 {} 0 {}}

    data  length 4
    a 001 012
    a 002 011
    b 101 112
    b 102 111
}