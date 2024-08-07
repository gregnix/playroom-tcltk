package require Tk
package require ctext

source treeview-lib.tcl
#https://wiki.tcl-lang.org/page/ttk%3A%3Atreeview+%2D+Different+bindings

variable textw

proc createTV {w} {
  set frt [ttk::frame $w.frt ]
  set tree [::ttk::treeview $frt.tree -height 15 -show tree \
    -yscroll [list $frt.vsb set] -xscroll [list $frt.hsb set] -selectmode browse]
  set vsb [::ttk::scrollbar $frt.vsb -orient vertical -command [list $tree yview]]
  set hsb [::ttk::scrollbar $frt.hsb -orient horizontal -command [list $tree xview]]

  grid $frt -row 0 -column 0 -sticky nsew

  grid $vsb -row 0 -column 1 -sticky ns
  grid $hsb -row 1 -column 0 -sticky ew
  grid $tree -row 0 -column 0 -sticky nsew

  grid columnconfigure $frt 0 -weight 1
  grid rowconfigure $frt 0  -weight 1
  grid columnconfigure $w 0 -weight 1
  grid rowconfigure $w 0  -weight 1

  return $tree
}


proc buttonbar {tree textw} {
  set f [ttk::frame .f]
  button $f.b1 -text "Clear Selection" -command {$tree selection set ""}
  button $f.b2 -text "Delete Selected" -command {$tree delete [$tree selection]; tvlib::bandEvent $tree}
  button $f.b3 -text "Remove Selection" -command {$tree selection remove [$tree selection]; tvlib::bandEvent $tree}
  button $f.b4 -text "Add item" -command {$tree insert {} end -text "Item  # [expr {[tvlib::treesize $tree] +1}]"; tvlib::bandEvent $tree}
  button $f.b5 -text "Set Focus I001" -command {$tree focus I001}
  button $f.b6 -text "Get Focus" -command {$textw insert end [$tree focus]\n}
  button $f.b7 -text "Select add I004 and I005" -command { $tree selection add {I004 I005}}
  button $f.b8 -text "Select toggle I004" -command { $tree selection toggle I004 }
  button $f.b9 -text "Select I002" -command { $tree selection set I002 }
  button $f.b10 -text "tree depth" -command {$textw insert end [tvlib::treedepth $tree]\n}
  button $f.b11 -text "item depth in tree" -command {$textw insert end [tvlib::itemdepth $tree  [$tree selection]]\n}
  button $f.b12 -text "tree size" -command {$textw insert end [tvlib::treesize $tree]\n}
  button $f.b13 -text "tree children {}" -command {$textw insert end [$tree children {}]\n}
  button $f.b14 -text "tree children sel" -command {$textw insert end [$tree children [$tree selection]]\n}

  bind $tree <<TreeviewSelect>> [list show  %W %X %Y %# %a %b %c %d  %f %h %i %k %m %o %p %s %t %w %x %y %A %B %D %E %K %M %N %P %R %S %T]
  #pack {*}[winfo children .] -fill x -pady 2 -padx 2 -side top
  pack $f  -side top -fill both -expand 0
  pack {*}[winfo children $f]  -fill x -pady 2 -padx 2 -side top
}

proc dataTotree {tree select} {
  switch $select {
    0 {
      for {set i 1} {$i < 6} {incr i} {
        $tree insert {} end -text "Item # $i"
      }
    }
    1 {
      foreach txt {first second third} {
        set id [$tree insert {} end -text "$txt item" -open 1]
        for {set i [expr {1+int(rand()*5)}]} {$i > 0} {incr i -1} {
          set child [$tree insert $id 0 -text "child $i"]
          for {set j [expr {int(rand()*4)}]} {$j > 0} {incr j -1} {
            $tree insert $child 0 -text "grandchild $i"
          }
        }
      }
    }
 
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
#set tree [ttk::treeview .t]

ttk::frame .fr1
set tree [createTV .fr1]

#select 0 or 1 for exeample data
dataTotree $tree 0

#band
tvlib::bandInit $tree
tvlib::band $tree
# event generate $tree <<TVItemsChanges>> -data [$tree selection]
# tvlib::band_event $tree}


pack $textw -side right -expand 1 -fill both
buttonbar $tree $textw
pack .fr1  -side top -expand 1 -fill both
#pack $tree -side top -expand 1  -fill both
set output "[array get ttk::treeview::State]\n"
$textw insert end $output
$textw insert end  "%W %X %Y %# %a %b %c %d  %f %h %i %k %m %o %p %s %t %w %x %y %A %B %D %E %K %M %N %P %R %S %T\n"





