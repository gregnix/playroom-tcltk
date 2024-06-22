#! /usr/bin/env tclsh

#20240622 1500

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
      set part [lindex $item $i 0]
      set value [lrange [lindex $item $i] 1 end]
      #puts "$part :: $value :: $item"
      lappend plist $part
      if {[existsNodeAttr tree $plist]} {
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
      upsertNode tree $plist $value "part $part pid $pid counter $pcounter ppid $ppid"
    }
  }
  return $tree
}
proc treeAttrToTblLoad {tree colslist} {
  set repeat [expr {[llength $colslist] - 2}]
  set valmaxlength [expr {[llength $colslist] - 3}]
  set sortlist "0 increasing\n"
  set nodelist [lsort -command sortPid  [walkTree tree {}]]
  set datalist [list [list root 0 {*}[lrepeat $repeat {}]]]
  set parentlist {-1}

  foreach item $nodelist {
    set value [dict create]
    set val [lindex $item 1]
    set vallength [expr min($valmaxlength, [llength $val])]
    dict set value part [dict get [lindex $item 2] part]
    dict set value pid [dict get [lindex $item 2] pid]
    dict set value counter [dict get [lindex $item 2] counter]
    dict set value ppid [dict get [lindex $item 2] ppid]
    set itemlist [list [dict get $value part] [dict get $value pid] {*}[lrepeat $repeat {}]]

    # Loop to insert values into columns
    for {set i 0; set j 2} {$i < $vallength && $j < $repeat + 2} {incr i; incr j} {
      lset itemlist $j [lindex $val $i]
    }

    # If there are remaining values, concatenate them into the last column
    if {$vallength < [llength $val]} {
      set remaining [lrange $val $vallength end]
      lset itemlist end [join $remaining " "]
    }
    lappend datalist $itemlist
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
    {{a Helmut Werner Hans Gerd} 001 012}
    {a {002 Birgit Jutta Jessica} 011}
    {b 101 112}
    {b 102 111}
  }


  puts \n
  #tablelist loadString
  set colslist [list id row one two three]
  set tree [dataToTblTreeAttr $data]
  puts \n
  set sortedResults [lsort -command sortPid  [walkTree tree {} ]]
  processSortedResults $sortedResults cmdPrintNode
  puts \n


  #loadstring for import treedata in tablelist
  set loadstring [treeAttrToTblLoad $tree $colslist]
  puts $loadstring

}

#Output:
if {0} {





Path: a                              Value: Helmut Werner Hans Gerd Attr: part=a pid=1 counter=1 ppid=0 
Path: a 001                          Value:                      Attr: part=001 pid=2 counter=2 ppid=1 
Path: a 001 012                      Value:                      Attr: part=012 pid=3 counter=3 ppid=2 
Path: a 002                          Value: Birgit Jutta Jessica Attr: part=002 pid=4 counter=5 ppid=1 
Path: a 002 011                      Value:                      Attr: part=011 pid=5 counter=6 ppid=4 
Path: b                              Value:                      Attr: part=b pid=6 counter=7 ppid=0 
Path: b 101                          Value:                      Attr: part=101 pid=7 counter=8 ppid=6 
Path: b 101 112                      Value:                      Attr: part=112 pid=8 counter=9 ppid=7 
Path: b 102                          Value:                      Attr: part=102 pid=9 counter=11 ppid=6 
Path: b 102 111                      Value:                      Attr: part=111 pid=10 counter=12 ppid=9 


id row one two three
0 increasing

-1 0 1 2 1 4 0 6 7 6 9
{root 0 {} {} {}} {a 1 Helmut Werner {Hans Gerd}} {001 2 {} {} {}} {012 3 {} {} {}} {002 4 Birgit Jutta Jessica} {011 5 {} {} {}} {b 6 {} {} {}} {101 7 {} {} {}} {112 8 {} {} {}} {102 9 {} {} {}} {111 10 {} {} {}}


}







