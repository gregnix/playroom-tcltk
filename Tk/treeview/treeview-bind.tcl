package require Tk
package require ctext
package require scrollutil_tile
package require tooltip

# procs with namespace tvlib::
# buttons cmd
source treeview-lib.tcl

# ctext widget for info
variable textw

# treeview widget
proc createTV {w} {
  set frt [ttk::frame $w.frt ]
  set tree [::ttk::treeview $frt.tree -height 15 -show {tree headings} \
    -columns [list value] -displaycolumns [list value] \
    -yscroll [list $frt.vsb set] -xscroll [list $frt.hsb set] -selectmode browse]
  set vsb [::ttk::scrollbar $frt.vsb -orient vertical -command [list $tree yview]]
  set hsb [::ttk::scrollbar $frt.hsb -orient horizontal -command [list $tree xview]]

  $tree heading #0 -text Keys
  $tree heading value -text "Values" -anchor center

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

# combobox  for selection example data and $tree configure -selectmode
proc createButton {w tree} {
  set frt [ttk::frame $w.frt]
  # combobox
  set cbdatas [ttk::combobox $frt.cbdatas -values {table tree treemedium treegreat abc12 person} -exportselection 0 -width 15]
  $cbdatas current 1
  bind $cbdatas <<ComboboxSelected>> [namespace code [list cbComboSelected %W $tree data]]
  cbComboSelected $cbdatas $tree data

  #  $tree confgure -selectmode extended, browse, or none. 
  set cbselectmode [ttk::combobox $frt.cbselectmode -values {extended browse none} -exportselection 0 -width 15]
  $cbselectmode current 0
  bind $cbselectmode <<ComboboxSelected>> [namespace code [list cbComboSelected %W $tree selectmode]]
  cbComboSelected $cbselectmode $tree selectmode
  
  pack $cbdatas $cbselectmode -side left
  pack $frt -side top -expand 0 -fill x

  return $cbdatas
}

# callback combobox
proc cbComboSelected {w tree type} {
  switch $type {
    data {
      $tree delete [$tree children {}]
      set wid [winfo parent [winfo parent $tree]]
      destroy  [winfo parent $tree]
      set tree  [createTV $wid]
      dataTotree $tree [$w get]
      tvlib::bandInit $tree
      tvlib::band $tree
      tvlib::bandEvent $tree
      bind $tree <<TreeviewSelect>> [list show  %W %X %Y %# %a %b %c %d  %f %h %i %k %m %o %p %s %t %w %x %y %A %B %D %E %K %M %N %P %R %S %T]
    }
    selectmode {
      $tree configure -selectmode [$w get]
    }
  }
}

proc buttonbar {w tree textw} {
  set f [ttk::frame $w.f]
  
  #  scrolled frame for buttonbar
  set sa [scrollutil::scrollarea $f.sa]
  set sf [scrollutil::scrollableframe $sa.sf]
  $sa setwidget $sf
  set cf [$sf contentframe]
  
  button $cf.b1 -text "Clear Selection" -command {$tree selection set ""}
  button $cf.b2 -text "Delete Selected" -command {$tree delete [$tree selection]; tvlib::bandEvent $tree}
  button $cf.b3 -text "Remove Selection" -command {$tree selection remove [$tree selection]}
  button $cf.b4 -text "Add item" -command {$tree insert {} end -text "Item  # [expr {[tvlib::treesize $tree] +1}]";\
  $tree item [lindex [$tree children {}] end] -values [lindex [$tree children {}] end]; tvlib::bandEvent $tree}
  button $cf.b5 -text "Set Focus I001" -command {$tree focus I001}
  button $cf.b6 -text "Get Focus" -command {$textw insert end [$tree focus]\n}
  button $cf.b7 -text "Get Focus Item and info" -command {$textw insert end "[$tree focus] index: [$tree index [$tree focus]] \
  -tags [$tree item [$tree focus] -tags] -open [$tree item [$tree focus] -open] \
  -text [$tree item [$tree focus] -text] -values [$tree item [$tree focus] -values]\n"}
  button $cf.b8 -text "Select add I004  I005 and see I004" -command { $tree selection add {I004 I005};$tree see I004}
  button $cf.b9 -text "Select toggle I004" -command { $tree selection toggle I004}
  button $cf.b10 -text "Select I005 and see" -command { $tree selection set I005;$tree see I005 }
  button $cf.b11 -text "tree depth" -command {$textw insert end [tvlib::treedepth $tree]\n}
  button $cf.b12 -text "item depth in tree" -command {$textw insert end [tvlib::itemdepth $tree  [$tree selection]]\n}
  button $cf.b13 -text "tree size" -command {$textw insert end [tvlib::treesize $tree]\n}
  button $cf.b14 -text "tree children {}" -command {$textw insert end [$tree children {}]\n}
  button $cf.b15 -text "childrens col k {}" -command {$textw insert end [tvlib::collectKeys [tvlib::tv2dict $tree ]]\n}
  button $cf.b16 -text "childrens P col k {}" -command {$textw insert end [tvlib::collectKeysPoint [tvlib::tv2dict $tree ]]\n}
  button $cf.b17 -text "childrens tails {}" -command {$textw insert end [tvlib::extractTails [tvlib::collectKeysPoint [tvlib::tv2dict $tree {}]]]\n}
  button $cf.b18 -text "childrens heads {}" -command {$textw insert end [tvlib::extractHeads [tvlib::collectKeysPoint [tvlib::tv2dict $tree {}]]]\n}
  button $cf.b19 -text "tree children sel" -command {$textw insert end [$tree children [$tree selection]]\n}
  button $cf.b20 -text "childrens col k sel" -command {$textw insert end [tvlib::collectKeys [tvlib::tv2dict $tree [$tree selection]]]\n}
  button $cf.b21 -text "childrens P col k sel" -command {$textw insert end [tvlib::collectKeysPoint [tvlib::tv2dict $tree [$tree selection]]]\n}
  button $cf.b22 -text "childrens tails sel" -command {$textw insert end [tvlib::extractTails [tvlib::collectKeysPoint [tvlib::tv2dict $tree [$tree selection]]]]\n}
  button $cf.b23 -text "childrens heads sel" -command {$textw insert end [tvlib::extractHeads [tvlib::collectKeysPoint [tvlib::tv2dict $tree [$tree selection]]]]\n}
  button $cf.b24 -text "tvtree2dict {}" -command {$textw insert end [tvlib::tvtree2dict $tree {}]\n}
  button $cf.b25 -text "tvtree2dict sel" -command {$textw insert end [tvlib::tvtree2dict $tree [$tree selection]]\n}
  button $cf.b26 -text "search and sel child 1" -command {$textw insert end [tvlib::showVisibleItems $tree "child 1"];\
  $tree selection set "";$tree selection add [tvlib::showVisibleItems $tree "child 1"]\n}
  button $cf.b27 -text "search and sel grandchild 3" -command {$textw insert end [tvlib::showVisibleItems $tree "grandchild 3"];\
  $tree selection set "";$tree selection add [tvlib::showVisibleItems $tree "grandchild 3"]\n}
  button $cf.b28 -text "ctext delete 3.0 end" -command {$textw delete 4.0 end}
    
  # as info 
  bind $tree <<TreeviewSelect>> [list show  %W %X %Y %# %a %b %c %d  %f %h %i %k %m %o %p %s %t %w %x %y %A %B %D %E %K %M %N %P %R %S %T]

  
  scrollutil::createWheelEventBindings all
  $sf autofillx true
  $sf configure -height 600 -yscrollincrement 5

  pack $sa -expand yes -fill both -padx 7p -pady 7p
  pack $f  -expand yes -fill both
  pack {*}[winfo children $cf]  -fill x -pady 2 -padx 2 -side top
  buttonbartooltip $cf
}

proc buttonbartooltip {cf} {
  tooltip::tooltip $cf.b4 "example table, item"
  tooltip::tooltip $cf.b8 "item"
  tooltip::tooltip $cf.b9 "item"
  tooltip::tooltip $cf.b10 "item"
  tooltip::tooltip $cf.b13 "count items"
  tooltip::tooltip $cf.b15 "all keys from parent {} as list "
  tooltip::tooltip $cf.b16 "all keys from parent {} as a linked list with a dot separator"
  tooltip::tooltip $cf.b17 "all keys from parent {} from  a linked list with a dot separator"
  tooltip::tooltip $cf.b18 "all parent keys from parent {} from  a linked list with a dot separator"
  tooltip::tooltip $cf.b20 "all keys from parent sel as list "
  tooltip::tooltip $cf.b21 "all keys from parent sel as a linked list with a dot separator"
  tooltip::tooltip $cf.b22 "all keys from parent sel from  a linked list with a dot separator"
  tooltip::tooltip $cf.b23 "all parent keys from parent sel from  a linked list with a dot separator"
  tooltip::tooltip $cf.b24 "export tree as dict from {}"
  tooltip::tooltip $cf.b25 "export tree as dict from sel"
  tooltip::tooltip $cf.b26 "example tree search item -text"
  tooltip::tooltip $cf.b27 "example tree search item -text"
}

#
proc dataTotree {tree select} {
  switch $select {
    table {
      for {set i 1} {$i < 6} {incr i} {
        set item [$tree insert {} end -text "Item # $i"]
        $tree item $item -values $item
      }
    }
    tree {
      foreach txt {first second third} {
        set id [$tree insert {} end -text "$txt item" -open 1]
        $tree item $id -values $id
        for {set i [expr {1+int(rand()*5)}]} {$i > 0} {incr i -1} {
          set child [$tree insert $id 0 -text "child $i"]
          $tree item $child -values $child
          for {set j [expr {int(rand()*4)}]} {$j > 0} {incr j -1} {
            set grandchild [$tree insert $child 0 -text "grandchild $i"]
            $tree item $grandchild -values $grandchild
          }
        }
      }
    }
    abc12 {
      dict set data Example5 {a1 {b11 {a11 {b1111 c1 b1112 c1}} b12 {a12 {b1211 c1 b1212 c1}}} a2 {b21 {a21 {b2111 c1 b2112 c1}} b22 {a22 {b2211 c1 b2212 c1}}}}
      tvlib::dict2tvtree $tree {} $data
    }
    person {
      dict set data Example4 {person  {name "John Doe" age 30.8 address {street "123 Main St" city "Anytown"}  employees {  {name "Alice Smith" } {name "Bob Smith"} {name "John Good"} {name "Jane Good"}} } job {title "Developer" company "Works"}}
      tvlib::dict2tvtree $tree {} $data
    }
    treegreat {
      tvlib::testCreateTreeStruct $tree 7
    }
    treemedium {
      tvlib::testCreateTreeStruct $tree 4
    }
  }
}
# for info in ctrxt widget
proc show {args} {
  variable textw
  lassign $args W X Y Raute a b c d  f h i k m o p s t w x y A B D E K M N P R S T rest
  set tree $W
  $textw insert end "$args :: $rest\n"
  $textw insert end "W: $W X: $X Y: $Y #: $Raute d: $d x: $x y: $y T: $T\n "
  $textw insert end "TreeviewSelect  Current selection is '\[$tree selection\]' [$tree selection ] :: focus:  [$tree focus]\n"
  $textw see end
}

###################################
#main
###################################
# ctext as info text
set textw [ctext .text -width 150 ]

ttk::frame .fr1
set tree [createTV .fr1]

#band stripes
tvlib::bandInit $tree
tvlib::band $tree
# event generate $tree <<TVItemsChanges>> -data [$tree selection]
# use:
# tvlib::band_event $tree

pack $textw -side right -expand 1 -fill both

ttk::frame .frbtn
# combobox for example data und select -selectmode  tree
createButton .frbtn $tree
ttk::frame .frbar
# buttons for cmds
buttonbar .frbar $tree $textw

pack .frbar .frbtn .fr1  -side top -expand 1 -fill both
#pack $tree -side top -expand 1  -fill both

set output "[array get ttk::treeview::State]\n"
$textw insert end $output
$textw insert end  "%W %X %Y %# %a %b %c %d  %f %h %i %k %m %o %p %s %t %w %x %y %A %B %D %E %K %M %N %P %R %S %T\n\n"





