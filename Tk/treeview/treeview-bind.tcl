package require Tk

#https://wiki.tcl-lang.org/page/ttk%3A%3Atreeview+%2D+Different+bindings

#   
proc band {tree {parent {}} {i 0}} {
  foreach item [$tree children $parent] {
    set t [expr {$i % 2}]
    $tree tag remove band0 $item
    $tree tag remove band1 $item
    $tree tag add band$t $item
    incr i
    set i [band $tree $item $i] 
  }
  return $i
}

proc band_init {tree {color0 #FFFFFF} {color1 #F0F0F0}} {
  $tree tag configure band0 -background $color0
  $tree tag configure band1 -background $color1
  bind $tree <<TVItemsChanges>> [list band $tree]
}

proc band_event {tree} {
  event generate $tree <<TVItemsChanges>> -data [$tree selection]
}


proc show {args} {
  .text insert end "args $args TreeviewSelect fired Current selection is '[ .t selection ]'\n"
}

text .text -width 200 
#Bindungen und Selektion
ttk::treeview .t

for {set i 1} {$i < 6} {incr i} {
  .t insert {} end -text "Item # $i"
}
bind .t <<TreeviewSelect>> {show %W %X %Y %# %a %b %c %d  %f %h %i %k %m %o %p %s %t %w %x %y %A %B %D %E %K %M %N %P %R %S %T}

#band 
band_init .t
band .t

button .b1 -text "Clear Selection" -command {.t selection set ""}
button .b2 -text "Delete Selected" -command {.t delete [.t selection]; band_event .t}
button .b3 -text "Remove Selection" -command {.t selection remove [.t selection]; event generate .t <<TVItemsChanges>> -data [.t selection]}
button .b4 -text "Add item" -command {.t insert {} end -text "Item  # [incr i]"; event generate .t <<TVItemsChanges>> -data [.t selection]}
button .b5 -text "Set Focus 1" -command {.t focus I001}
button .b6 -text "Get Focus" -command {.text insert end [.t focus]\n}
button .b7 -text "Select add 4 and 5" -command { .t selection add {I004 I005}}
button .b8 -text "Select toggle 4" -command { .t selection toggle I004 }
button .b9 -text "Select 2" -command { .t selection set I002 }

pack .text -side right
pack .t .b1 .b2 .b3 .b4 .b5 .b6 .b7 .b8 .b9 -side top

set output "[array get ttk::treeview::State]\n"
.text insert end $output







