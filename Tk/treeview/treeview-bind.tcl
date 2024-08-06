package require Tk
package require ctext

source treeview-lib.tcl
#https://wiki.tcl-lang.org/page/ttk%3A%3Atreeview+%2D+Different+bindings


proc show {args} {
  lassign $args W X Y Raute a b c d  f h i k m o p s t w x y A B D E K M N P R S T
  .text insert end "$args \n"
  .text insert end "W: $W X: $X Y: $Y #: $Raute d: $d x: $x y: $y T: $T\n "
  .text insert end "TreeviewSelect fired Current selection is '\[.t selection\]' [.t selection ]\n"
  .text see end
}

ctext .text -width 200 
#Bindungen und Selektion
set tree [ttk::treeview .t]

for {set i 1} {$i < 6} {incr i} {
  $tree insert {} end -text "Item # $i"
}
bind $tree <<TreeviewSelect>> {show %W %X %Y %# %a %b %c %d  %f %h %i %k %m %o %p %s %t %w %x %y %A %B %D %E %K %M %N %P %R %S %T}

#band 
tvlib::band_init $tree
tvlib::band $tree
# event generate .t <<TVItemsChanges>> -data [.t selection]
# tvlib::band_event .t}

button .b1 -text "Clear Selection" -command {.t selection set ""}
button .b2 -text "Delete Selected" -command {.t delete [.t selection]; tvlib::band_event .t}
button .b3 -text "Remove Selection" -command {.t selection remove [.t selection]; tvlib::band_event .t}
button .b4 -text "Add item" -command {.t insert {} end -text "Item  # [incr i]"; tvlib::band_event .t}
button .b5 -text "Set Focus 1" -command {.t focus I001}
button .b6 -text "Get Focus" -command {.text insert end [.t focus]\n}
button .b7 -text "Select add 4 and 5" -command { .t selection add {I004 I005}}
button .b8 -text "Select toggle 4" -command { .t selection toggle I004 }
button .b9 -text "Select 2" -command { .t selection set I002 }

pack .text -side right
pack .t .b1 .b2 .b3 .b4 .b5 .b6 .b7 .b8 .b9 -side top

set output "[array get ttk::treeview::State]\n"
.text insert end $output
.text insert end  "%W %X %Y %# %a %b %c %d  %f %h %i %k %m %o %p %s %t %w %x %y %A %B %D %E %K %M %N %P %R %S %T\n"







