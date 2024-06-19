#! /usr/bin/env tclsh

#20240619

#dict - nested
source [file join [file dirname [info script]] dict-tree-lib.tcl]

proc dataToTblTreeAttr {data} {
    set tree [dict create]
    set pid 0
    set pcounter 0
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
            if {![catch {getAttrValue tree $plist}]} {
                set pid [getAttrValue tree $plist pid]
                set pcounter [getAttrValue tree $plist counter]
                set ppid [getAttrValue tree $plist ppid]
            } else {
                if {!$i} {
                    set ppid 0
                } else {
                    set ppid $pid
                }
                incr pos
                set pid $pos
                set pcounter $counter
            }
            addToTree tree $plist value "part $part pid $pid counter $pcounter ppid $ppid" 
        }
    }
    return $tree
}
proc treeAttrToTblLoad {tree colslist } {
    set repeat [expr {[llength $colslist] -2}]
    set sortlist "0 increasing\n"
    set nodelist [walkTree tree {} cmdListAttr]
    set datalist [list [list root 0 {*}[lrepeat $repeat {}]]]
    set parentlist {-1}
    
    foreach item $nodelist {
        set k [lindex $item 0]
        set value [lindex $item 1]
        lappend datalist [list [dict get $value part] [dict get $value pid] {*}[lrepeat $repeat {}]]
        lappend parentlist [dict get $value ppid]
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
set tree [dataToTblTreeAttr $data]
set loadstring [treeAttrToTblLoad $tree $colslist]
puts $loadstring
#end

puts \n
#puts "walkTree tree {} cmdPrintNode"
#walkTree tree {} cmdPrintNode

set tree [dataToTblTreeAttr $data]
 puts \n
puts "walkTree tree {} cmdPrintNode"
walkTree tree {} cmdPrintNode   
puts [getAttrValue tree {a} ppid   ] 
}







