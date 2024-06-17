#! /usr/bin/env tclsh

#dict - nested
source [file join [file dirname [info script]] dict-tree-lib.tcl]

proc dataToTblTree {data} {
    set tree [dict create]
    set counter 0
    set pos 1
    set pid 0
    set pcounter 0
    set part root
    set subDict [dict create]
    foreach item $data {
        set length [llength $item]
        incr counter
        if {$length} {
            incr counter -1
        }
        set plist [list]
        set ppid $pid
        for {set i 0} {$i < $length } {incr i} {
            incr counter
            set part [lindex $item $i]
            lappend plist $part
            if {![catch {getNodeValue tree $plist}]} {
                set pid [dict get [dict get [lrange [getNodeValue tree $plist] 0 7]] pid]
                set pcounter [dict get [dict get [lrange [getNodeValue tree $plist] 0 7]] counter]
                set ppid [dict get [dict get [lrange [getNodeValue tree $plist] 0 7]] ppid]
            } else {

                if {!$i} {
                    set ppid 0
                } else {
                    set ppid $pid
                }
                set pid $pos
                incr pos
                set pcounter $counter
            }
            addToTree tree $plist "part $part pid $pid counter $pcounter ppid $ppid"
        }
    }
    return $tree
}

proc treeToTblLoad {tree colslist } {
    set repeat [expr {[llength $colslist] -2}]
    set sortlist "0 increasing\n"
    set liste [walkTreeList tree {}]

    set datalist [list [list root 0 {*}[lrepeat $repeat {}]]]
    set parentlist {-1}

    foreach {k value}  $liste {
        lappend datalist [list [lindex $value 1] [lindex $value 3] {*}[lrepeat $repeat {}]]
        lappend parentlist [lindex $value 7]
    }

    append loadString $colslist\n
    append loadString $sortlist\n
    append loadString $parentlist\n
    append loadString $datalist
return $loadString
}


# Example
if {[info script] eq $argv0} {

set data {
    {a 001 012}
    {a 002 011}
    {b 101 112}
    {b 102 111}
}


puts \n
#tablelist loadString
set colslist [list id row one two]
set tree [dataToTblTree $data]
set loadstring [treeToTblLoad $tree $colslist]
puts $loadstring
#end

puts \n
puts "walkTree tree {} printNode"
walkTree tree {} printNode

}







