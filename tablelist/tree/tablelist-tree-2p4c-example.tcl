#! /usr/bin/env tclsh

#20240609

# 
package require Tk
package require tablelist_tile

package require struct::list
# help procs
# This function generates flat hierarchical test data
proc generateTreeData1 {{dataList {1 2 3}} {parentList {a b c}} {shuffle 1} } {
    set length [llength $dataList]
    set dataList [::struct::list permutations $dataList]

    foreach  parent  $parentList {
        foreach data $dataList {
            set item ""
            for {set i 1} {$i <= $length } {incr i} {
                lappend item [lsearch $parentList $parent]${i}[lindex $data $i-1]
            }
            lappend resultList [list $parent {*}$item]

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
    set btnOutput  [ttk::button $frt.btnOutput -text Output -command [list callbOutput $tbl]]
    set btnPopulate  [ttk::button $frt.btnPopulate -text "Populate" -command [list populateTree $tbl]]
    pack $btnOutput $btnPopulate -side left
    pack $frb -expand no -fill x

    set bodyTag [$tbl bodytag]
    bind $bodyTag <Double-1>  [list callbOutput $tbl]
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
proc populateTree {tbl} {
    variable data
    $tbl delete 0 end
    set data [generateTreeData1 {1 2 3} {a b c} 1]
    set idliste [list]
    foreach item $data {
        set id [lindex $item 0]
        set one [lindex $item 1]
        set two [lindex $item 2]
        set three [lindex $item 3]
        if {$id ni $idliste} {
            lappend idliste $id
            set idliste [lsort -unique $idliste]
            set rootid [$tbl insertchild root end [list $id]]
        } else {
            foreach idrow [$tbl childkeys root] {
                if {[lindex [$tbl rowcget $idrow -text] 0]  eq $id } {
                    set rootid $idrow
                    foreach onerow [$tbl childkeys $idrow] {
                        if {[lindex [$tbl rowcget $onerow -text] 1]  eq $one } {
                            set rootid $onerow
                        }
                    }
                }
            }
        }
        $tbl insertchild $rootid end [list $id $one $two $three]
    }
    $tbl refreshsorting 0
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
wm title . "Tablelist Tree example with flate test data"
set mainFrame [ttk::frame .main]
pack $mainFrame -expand yes -fill both

set tbl [treetblcreate $mainFrame]
populateTree $tbl

#########################
if {0} {
Output:

 set row 0
row: k0 :: rows :  :: noderow: 0 :: 0
parentsRoot: root {k0 k2 k4} ::  parentkey: root ::  descendantcount: 6
childcountpk : 3 :: childindexpk: 0 :: childkeyspk: k0 k2 k4 :: depthpk : 0
childcount : 3 :: childindex: 0 :: childkeys: k1 k6 k10 :: depth : 1
active rowa: 0 :: $tbl getkey $rowa: 0:: k0
active parentkey: root ::  descendantcount: 6
active childcount : 3 :: childindex: 0 :: childkeys: k1 k6 k10 :: depth : 1

 $tbl get 0 end
a {} {} {}
a 013 022 031
a 013 021 032
a 012 021 033
a 012 023 031
a 011 023 032
a 011 022 033
b {} {} {}
b 111 122 133
b 111 123 132
b 112 123 131
b 112 121 133
b 113 121 132
b 113 122 131
c {} {} {}
c 211 223 232
c 211 222 233
c 213 221 232
c 213 222 231
c 212 223 231
c 212 221 233

  dumptostringid one two three
{} {}

-1 0 1 0 3 0 5 -1 7 8 7 10 7 12 -1 14 15 14 17 14 19
{a {} {} {}} {a 013 022 031} {a 013 021 032} {a 012 021 033} {a 012 023 031} {a 011 023 032} {a 011 022 033} {b {} {} {}} {b 111 122 133} {b 111 123 132} {b 112 123 131} {b 112 121 133} {b 113 121 132} {b 113 122 131} {c {} {} {}} {c 211 223 232} {c 211 222 233} {c 213 221 232} {c 213 222 231} {c 212 223 231} {c 212 221 233}

  data  length 18
a 013 022 031
b 111 122 133
c 211 223 232
a 012 021 033
b 112 123 131
c 211 222 233
b 112 121 133
a 011 023 032
c 213 221 232
c 212 223 231
a 011 022 033
c 212 221 233
c 213 222 231
a 012 023 031
b 113 121 132
b 113 122 131
a 013 021 032
b 111 123 132
}