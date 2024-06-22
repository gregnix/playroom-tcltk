#! /usr/bin/env tclsh

#20240622

#dict - nested
source [file join [file dirname [info script]] dict-tree-lib.tcl]

proc sortPid {a b} {
  set a0 [dict get [lindex $a 2] pid]
  set b0 [dict get [lindex $b 2] pid]
  if {$a0 < $b0} {
    return -1
  } elseif {$a0 > $b0} {
    return 1
  }
  return 0
}


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
      if {![catch {getNodeAttr tree $plist}]} {
        set pid [getNodeAttr tree $plist pid]
        set pcounter [getNodeAttr tree $plist counter]
        set ppid [getNodeAttr tree $plist ppid]
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
      insertNode tree $plist value "part $part pid $pid counter $pcounter ppid $ppid"
    }
  }
  return $tree
}
proc treeAttrToTblLoad {tree colslist } {
  set repeat [expr {[llength $colslist] -2}]
  set sortlist "0 increasing\n"
  set nodelist [lsort -command sortPid  [walkTree tree {} ]]
  set datalist [list [list root 0 {*}[lrepeat $repeat {}]]]
  set parentlist {-1}

  foreach item $nodelist {
    set value [dict create]
    dict set value part [dict get [lindex $item 2] part]
    dict set value pid [dict get [lindex $item 2] pid]
    dict set value counter [dict get [lindex $item 2] counter]
    dict set value ppid [dict get [lindex $item 2] ppid]
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
    puts \n
  set sortedResults [lsort -command sortPid  [walkTree tree {} ]]
  processSortedResults $sortedResults cmdPrintAttr
  puts \n
  

  #loadstring for import treedata in tablelist
  set loadstring [treeAttrToTblLoad $tree $colslist]
  puts $loadstring

    
}

#Output:
if {0} {

Path: a                               Attr: part=a pid=1 counter=1 ppid=0 
Path: a 001                           Attr: part=001 pid=2 counter=2 ppid=1 
Path: a 001 012                       Attr: part=012 pid=3 counter=3 ppid=2 
Path: a 002                           Attr: part=002 pid=4 counter=5 ppid=1 
Path: a 002 011                       Attr: part=011 pid=5 counter=6 ppid=4 
Path: b                               Attr: part=b pid=6 counter=7 ppid=0 
Path: b 101                           Attr: part=101 pid=7 counter=8 ppid=6 
Path: b 101 112                       Attr: part=112 pid=8 counter=9 ppid=7 
Path: b 102                           Attr: part=102 pid=9 counter=11 ppid=6 
Path: b 102 111                       Attr: part=111 pid=10 counter=12 ppid=9 


id row one two
0 increasing

-1 0 1 2 1 4 0 6 7 6 9
{root 0 {} {}} {a 1 {} {}} {001 2 {} {}} {012 3 {} {}} {002 4 {} {}} {011 5 {} {}} {b 6 {} {}} {101 7 {} {}} {112 8 {} {}} {102 9 {} {}} {111 10 {} {}}



}







