package require Tk
package require ctext

source treeview-lib.tcl
#https://wiki.tcl-lang.org/page/ttk%3A%3Atreeview+%2D+Different+bindings

variable textw

proc treesize {tree} {
  set size [llength [$tree children {}]]
return $size  
}

proc buttonbar {tree textw} {
  button .b1 -text "Clear Selection" -command {$tree selection set ""}
  button .b2 -text "Delete Selected" -command {$tree delete [$tree selection]; tvlib::band_event $tree}
  button .b3 -text "Remove Selection" -command {$tree selection remove [$tree selection]; tvlib::band_event $tree}
  button .b4 -text "Add item" -command {$tree insert {} end -text "Item  # [expr {[treesize $tree] +1}]"; tvlib::band_event $tree}
  button .b5 -text "Set Focus 1" -command {$tree focus I001}
  button .b6 -text "Get Focus" -command {$textw insert end [$tree focus]\n}
  button .b7 -text "Select add 4 and 5" -command { $tree selection add {I004 I005}}
  button .b8 -text "Select toggle 4" -command { $tree selection toggle I004 }
  button .b9 -text "Select 2" -command { $tree selection set I002 }
  
  bind $tree <<TreeviewSelect>> {show  %W %X %Y %# %a %b %c %d  %f %h %i %k %m %o %p %s %t %w %x %y %A %B %D %E %K %M %N %P %R %S %T}
  #pack {*}[winfo children .] -fill x -pady 2 -padx 2 -side top
  pack  .b1 .b2 .b3 .b4 .b5 .b6 .b7 .b8 .b9 -side top
}

proc dataTotree {tree} {
for {set i 1} {$i < 6} {incr i} {
  $tree insert {} end -text "Item # $i"
}
}

proc show {args} {
  variable textw
  lassign $args W X Y Raute a b c d  f h i k m o p s t w x y A B D E K M N P R S T
  set tree $W
  $textw insert end "$args \n"
  $textw insert end "W: $W X: $X Y: $Y #: $Raute d: $d x: $x y: $y T: $T\n "
  $textw insert end "TreeviewSelect fired Current selection is '\[$tree selection\]' [$tree selection ]\n"
  $textw see end
}



set textw [ctext .text -width 200 ]


#Bindungen und Selektion
set tree [ttk::treeview .t]

dataTotree $tree

#band
tvlib::band_init $tree
tvlib::band $tree
# event generate $tree <<TVItemsChanges>> -data [$tree selection]
# tvlib::band_event $tree}


pack $textw -side right -expand 1 -fill both
buttonbar $tree $textw
pack $tree -side top -expand 1  -fill both
set output "[array get ttk::treeview::State]\n"
$textw insert end $output
$textw insert end  "%W %X %Y %# %a %b %c %d  %f %h %i %k %m %o %p %s %t %w %x %y %A %B %D %E %K %M %N %P %R %S %T\n"

puts [$tree children {}]






