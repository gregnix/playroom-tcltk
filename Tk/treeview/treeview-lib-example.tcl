#! /usr/bin/env tclsh

#20240816

# treeview-lib-example.tcl

package require Tk
package require ctext
package require scrollutil_tile
package require tooltip

# procs with namespace tvlib:: and example datas
source treeview-lib.tcl

namespace eval tvlib {
  variable rowsparentidx

  
}


# ctext widget for info display
variable textw
variable tvbox

proc createCTW {w} {
  set frt [ttk::frame $w.frt ]
  set textw [ctext $frt.text -width 100 -yscrollcommand [list $frt.vsb set]]
  set vsb [ttk::scrollbar $frt.vsb -orient vertical -command [list $textw yview]]

  pack $frt -side top -fill both -expand 1

  pack $vsb -side right -fill y -expand 0
  pack $textw -expand 1 -fill both

  return $textw
}


# treeview widget
proc createTV {w} {
  set frt [ttk::frame $w.frt ]
  set tree [::ttk::treeview $frt.tree -height 15 -show {tree headings} \
    -columns [list value rowidx] -displaycolumns [list value rowidx] \
    -yscrollcommand [list $frt.vsb set] -xscrollcommand [list $frt.hsb set] -selectmode browse]
  set vsb [::ttk::scrollbar $frt.vsb -orient vertical -command [list $tree yview]]
  set hsb [::ttk::scrollbar $frt.hsb -orient horizontal -command [list $tree xview]]

  $tree heading #0 -text Keys
  $tree heading value -text "Values" -anchor center
  $tree heading rowidx -text "Rowidx" -anchor center
  # problem with scrollbar vsb
  $tree column #0 -minwidth 40 -stretch 0
  $tree column value -minwidth 40 -stretch 0
  $tree column rowidx -minwidth 10 -stretch 0 -width 100

  grid $frt -row 0 -column 0 -sticky nsew

  grid $vsb -row 0 -column 1 -sticky ns
  grid $tree -row 0 -column 0 -sticky nsew
  grid $hsb -row 1  -column 0 -sticky ew

  grid columnconfigure $frt 0 -weight 1
  grid rowconfigure $frt 0  -weight 1
  grid columnconfigure $w 0 -weight 1
  grid rowconfigure $w 0  -weight 1
  grid rowconfigure $w 1  -weight 0

  return $tree
}

# combobox  for selection example data and $tree configure -selectmode
proc createButton {w tree} {
  set frt [ttk::frame $w.frt]
  # combobox for example datas
  set cbdatas [ttk::combobox $frt.cbdatas -values {table tree treemedium treegreat abc12 person info} -exportselection 0 -width 15]
  $cbdatas current 1
  bind $cbdatas <<ComboboxSelected>> [namespace code [list cbComboSelected %W $tree data]]
  cbComboSelected $cbdatas $tree data

  #  $tree confgure -selectmode extended, browse, or none.
  set cbselectmode [ttk::combobox $frt.cbselectmode -values {extended browse none} -exportselection 0 -width 15]
  $cbselectmode current 1
  bind $cbselectmode <<ComboboxSelected>> [namespace code [list cbComboSelected %W $tree selectmode]]
  cbComboSelected $cbselectmode $tree selectmode

  #  $tree confgure -selectmode extended, browse, or none.
  set cbthemen [ttk::combobox $frt.cbthemen -values [ttk::style theme names] -exportselection 0 -width 15]
  $cbthemen current 0
  bind $cbthemen <<ComboboxSelected>> [namespace code [list cbComboSelected %W $tree themen]]
  cbComboSelected $cbthemen $tree themen

  pack $cbdatas $cbselectmode $cbthemen -side left
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
      bind $tree <<TreeviewSelect>> [list show  %W %X %Y %# %d  %x %y %T]
    }
    selectmode {
      $tree configure -selectmode [$w get]
    }
    themen {
      ttk::style theme use [$w get]
    }
  }
}

# simple callback for buttonbar
proc cbbtnbar {tree cmds}  {
  variable textw
  foreach cmd [split $cmds ";"] {
    eval [string trimleft $cmd]
  }
  $textw see end
}

proc buttonbar {w tree textw} {
  set f [ttk::frame $w.f]

  #  scrolled frame for buttonbar
  set sa [scrollutil::scrollarea $f.sa]
  set sf [scrollutil::scrollableframe $sa.sf -width 480]
  $sa setwidget $sf
  set cf [$sf contentframe]

  button $cf.b1 -text "Clear Selection" -command [list cbbtnbar $tree {$tree selection set ""}]
  button $cf.b2 -text "Delete Selected" -command [list cbbtnbar $tree {$tree delete [$tree selection]; tvlib::bandEvent $tree}]
  button $cf.b3 -text "Remove Selection" -command [list cbbtnbar $tree {$tree selection remove [$tree selection]}]
  button $cf.b4 -text "Add item" -command [list cbbtnbar $tree {$tree insert {} end -text "Item  # [expr {[tvlib::treesize $tree] +1}]";\
  $tree item [lindex [$tree children {}] end] -values [lindex [$tree children {}] end]; tvlib::bandEvent $tree}]
  button $cf.b5 -text "Set Focus I001" -command [list cbbtnbar $tree {$tree focus I001}]
  button $cf.b6 -text "Get Focus" -command  [list cbbtnbar $tree {$textw insert end [$tree focus]\n}]
  button $cf.b7 -text "Get Focus Item \nand info" -command [list cbbtnbar $tree {$textw insert end "[$tree focus] index: [$tree index [$tree focus]] \
  -tags [$tree item [$tree focus] -tags] -open [$tree item [$tree focus] -open] \
  -text [$tree item [$tree focus] -text] -values [$tree item [$tree focus] -values]\n"}]
  button $cf.b8 -text "Select add I004  I005 \nand see I004" -command [list cbbtnbar $tree { $tree selection add {I004 I005};$tree see I004}]
  button $cf.b9 -text "Select toggle I004" -command [list cbbtnbar $tree { $tree selection toggle I004}]
  button $cf.b10 -text "Select I005 and see" -command [list cbbtnbar $tree { $tree selection set I005;$tree see I005 }]
  button $cf.b11 -text "tree depth" -command [list cbbtnbar $tree {$textw insert end [tvlib::treedepth $tree]\n}]
  button $cf.b12 -text "item depth in tree" -command [list cbbtnbar $tree {$textw insert end [tvlib::itemdepth $tree  [$tree selection]]\n}]
  button $cf.b13 -text "tree size" -command [list cbbtnbar $tree {$textw insert end [tvlib::treesize $tree]\n}]
  button $cf.b14 -text "tree children {}" -command [list cbbtnbar $tree {$textw insert end [$tree children {}]\n}]
  button $cf.b15 -text "childrens col k {}" -command [list cbbtnbar $tree {$textw insert end [tvlib::collectKeys [tvlib::tv2list $tree ]]\n}]
  button $cf.b16 -text "childrens P col k {}" -command [list cbbtnbar $tree {$textw insert end [tvlib::collectKeysPoint [tvlib::tv2list $tree ]]\n}]
  button $cf.b17 -text "childrens tails {}" -command [list cbbtnbar $tree {$textw insert end [tvlib::extractTails [tvlib::collectKeysPoint [tvlib::tv2list $tree {}]]]\n}]
  button $cf.b18 -text "childrens heads {}" -command [list cbbtnbar $tree {$textw insert end [tvlib::extractHeads [tvlib::collectKeysPoint [tvlib::tv2list $tree {}]]]\n}]
  button $cf.b19 -text "tree children sel" -command [list cbbtnbar $tree {$textw insert end [$tree children [$tree selection]]\n}]
  button $cf.b20 -text "childrens col k sel" -command [list cbbtnbar $tree {$textw insert end [tvlib::collectKeys [tvlib::tv2list $tree [$tree selection]]]\n}]
  button $cf.b21 -text "childrens P col k sel" -command [list cbbtnbar $tree {$textw insert end [tvlib::collectKeysPoint [tvlib::tv2list $tree [$tree selection]]]\n}]
  button $cf.b22 -text "childrens tails sel" -command [list cbbtnbar $tree {$textw insert end [tvlib::extractTails [tvlib::collectKeysPoint [tvlib::tv2list $tree [$tree selection]]]]\n}]
  button $cf.b23 -text "childrens heads sel" -command [list cbbtnbar $tree {$textw insert end [tvlib::extractHeads [tvlib::collectKeysPoint [tvlib::tv2list $tree [$tree selection]]]]\n}]
  button $cf.b24 -text "tvtree2dict {}" -command [list cbbtnbar $tree {$textw insert end [tvlib::tvtree2dict $tree {}]\n}]
  button $cf.b25 -text "tvtree2dict sel" -command [list cbbtnbar $tree {$textw insert end [tvlib::tvtree2dict $tree [$tree selection]]\n}]
  button $cf.b26 -text "search and \nsel child 1" -command [list cbbtnbar $tree {$textw insert end [tvlib::showVisibleItems $tree "child 1"];\
  $tree selection set "";$tree selection add [tvlib::showVisibleItems $tree "child 1"]\n}]

  button $cf.b27 -text "search and \nsel grandchild 3" -command [list cbbtnbar $tree {$textw insert end [tvlib::showVisibleItems $tree "grandchild 3"];\
  $tree selection set "";$tree selection add [tvlib::showVisibleItems $tree "grandchild 3"]\n}]

  button $cf.b28 -text "search and \nsel Node 1 Depth 5" -command [list cbbtnbar $tree {$textw insert end [tvlib::showVisibleItems $tree "Node 1 Depth 5"];\
 $tree selection set "";$tree selection add [tvlib::showVisibleItems $tree "Node 1 Depth 5"]\n}]
  button $cf.b30 -text "BuildChildCountDict" -command [list cbbtnbar $tree {$textw insert end [tvlib::buildChildCountDict $tree]\n}]
  button $cf.b32 -text "Find Index" -command [list cbbtnbar $tree {$textw insert end [tvlib::findRowFromDict $tree [$tree selection]]\n}]
  button $cf.b33 -text "index sel" -command [list cbbtnbar $tree {$textw insert end [$tree index [$tree selection]]\n}]
  button $cf.b34 -text "ctext clean" -command [list cbbtnbar $tree {$textw delete 4.0 end}]
  button $cf.b35 -text "expandAll {}" -command [list cbbtnbar $tree {tvlib::expandAll $tree {}}]
  button $cf.b36 -text "collapseAll {}" -command [list cbbtnbar $tree {tvlib::collapseAll $tree {}}]
  button $cf.b37 -text "expandAll sel" -command [list cbbtnbar $tree {tvlib::expandAll $tree [$tree selection]}]
  button $cf.b38 -text "collapseAll sel" -command [list cbbtnbar $tree {tvlib::collapseAll $tree [$tree selection]}]

  # as info
  bind $tree <<TreeviewSelect>> [list show  %W %X %Y %# %d %x %y  %T]

  scrollutil::createWheelEventBindings all
  $sf autofillx true
  $sf configure -height 500 -yscrollincrement 5

  pack $sa -expand yes -fill both -padx 7p -pady 7p
  #pack $f  -expand yes -fill both
  #pack {*}[winfo children $cf]  -fill x -pady 2 -padx 2 -side top

  grid $f -sticky nwes
  foreach {a b c} [winfo children $cf] {
    if {[catch {grid  $a $b $c -sticky we}]} {
      if {[catch {grid $a $b -sticky we}]} {
        grid $a -sticky we
      }
    }
  }
  #  grid rowconfigure    $f 0 -weight 1
  #  grid columnconfigure $f  0 -weight 1

  buttonbartooltip $cf
}

# mini docu
proc buttonbartooltip {cf} {
    tooltip::tooltip $cf.b1 "Clear the current selection in the treeview"
    tooltip::tooltip $cf.b2 "Delete the selected item(s) from the treeview"
    tooltip::tooltip $cf.b3 "Remove the selected item(s) from the selection list"
    tooltip::tooltip $cf.b4 "Add a new item to the treeview"
    tooltip::tooltip $cf.b5 "Set focus to the item with ID 'I001'"
    tooltip::tooltip $cf.b6 "Get the ID of the currently focused item and display it in the text widget"
    tooltip::tooltip $cf.b7 "Get detailed information about the focused item"
    tooltip::tooltip $cf.b8 "Select items 'I004' and 'I005' and scroll to 'I004'"
    tooltip::tooltip $cf.b9 "Toggle the selection of item 'I004'"
    tooltip::tooltip $cf.b10 "Select item 'I005' and scroll to it"
    tooltip::tooltip $cf.b11 "Calculate and display the depth of the tree"
    tooltip::tooltip $cf.b12 "Calculate and display the depth of the selected item in the tree"
    tooltip::tooltip $cf.b13 "Count and display the total number of items in the tree"
    tooltip::tooltip $cf.b14 "Display the children of the root node (parent {})"
    tooltip::tooltip $cf.b15 "List all keys from the root node (parent {})"
    tooltip::tooltip $cf.b16 "List all keys from the root node (parent {}) with dot-separated paths"
    tooltip::tooltip $cf.b17 "Extract and display the tail keys from the root node (parent {})"
    tooltip::tooltip $cf.b18 "Extract and display the head keys from the root node (parent {})"
    tooltip::tooltip $cf.b19 "Display the children of the selected node"
    tooltip::tooltip $cf.b20 "List all keys from the selected node with dot-separated paths"
    tooltip::tooltip $cf.b21 "List all keys from the selected node with dot-separated paths"
    tooltip::tooltip $cf.b22 "Extract and display the tail keys from the selected node"
    tooltip::tooltip $cf.b23 "Extract and display the head keys from the selected node"
    tooltip::tooltip $cf.b24 "Export the entire tree as a dictionary from the root"
    tooltip::tooltip $cf.b25 "Export the tree as a dictionary from the selected node"
    tooltip::tooltip $cf.b26 "Search for 'child 1' and select the matching items"
    tooltip::tooltip $cf.b27 "Search for 'grandchild 3' and select the matching items"
    tooltip::tooltip $cf.b28 "Search for 'Node 1 Depth 5' and select the matching items"
    tooltip::tooltip $cf.b30 "Build a child count dictionary for the tree"
    tooltip::tooltip $cf.b32 "Find and display the global index of the selected item"
    tooltip::tooltip $cf.b33 "Display the index of the selected item within its parent"
    tooltip::tooltip $cf.b34 "Clear the text widget content from line 4 onwards"
    tooltip::tooltip $cf.b35 "Expand all nodes in the treeview"
    tooltip::tooltip $cf.b36 "Collapse all nodes in the treeview"
    tooltip::tooltip $cf.b37 "Expand all nodes under the selected item"
    tooltip::tooltip $cf.b38 "Collapse all nodes under the selected item"
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
      tvlib::expandAll $tree {}
      tvlib::buildChildCountDict $tree
    }
    abc12 {
      # d.1 data dict for example datas
      tvlib::dict2tvtree $tree {} [dict get $tvlib::exampleDatas abc12]
      tvlib::buildChildCountDict $tree
    }
    person {
      # d.1 data dict for example datas
      tvlib::dict2tvtree $tree {} [dict get $tvlib::exampleDatas person]
      tvlib::buildChildCountDict $tree
    }
    treegreat {
      # d.2 test data creator
      tvlib::testCreateTreeStruct $tree 7
      tvlib::buildChildCountDict $tree
    }
    treemedium {
      # d.2 test data creator
      tvlib::testCreateTreeStruct $tree 6
      tvlib::buildChildCountDict $tree
    }
    info  {
      # d.2 test data creator
      tvlib::dict2tvtree $tree {} [tvlib::infotcltk]
      tvlib::buildChildCountDict $tree
    }
  }
}
# for info in ctext widget
proc show {args} {
  variable textw
  variable tvbox
  variable table

  lassign $args W X Y Raute d  x y T rest
  set tree $W

  set values [list]
  set values [struct::list flatten -full -- [$tree item [$tree focus] -values]]
  $tvbox delete [$tvbox children {}]
  tvlib::addCells $tvbox 0 $values 0
  tvlib::bandInit $tvbox
  tvlib::band $tvbox

  tvlib::addRow $table [list  $W  $X $Y  $Raute $d $x $y $T]
  
  #$textw insert end "\n$args :: $rest\n"
  #$textw insert end "W: $W X: $X Y: $Y #: $Raute d: $d x: $x y: $y T: $T\n "
  $textw insert end "TreeviewSelect  Current selection is '\[\$tree selection\]' [$tree selection ] :: focus:  [$tree focus]\n"
  $textw see end
}

# main gui
proc mainGui {} {
  # ctext widget for info display
  variable textw
  variable tvbox
  variable table

  set pwh [ttk::panedwindow .pwh -orient horizontal ]
  set fh1 [ttk::frame $pwh.fh1]
  set fh2 [ttk::frame $pwh.fh2]
  set fh3 [ttk::frame $pwh.fh3]
  $pwh add $pwh.fh1
  $pwh add $pwh.fh2
  $pwh add $pwh.fh3
  pack $pwh -expand 1 -fill both

  set pwv [ttk::panedwindow $fh1.pwv -orient vertical ]
  set fv1 [ttk::frame $pwv.fv1]
  set fv2 [ttk::frame $pwv.fv2]
  $pwv add $pwv.fv1
  $pwv add $pwv.fv2
  pack $pwv -expand 1 -fill both

  # treeview box for value list from treeview
  ttk::frame $fh2.fr2
  set tvbox [tvlib::newTable $fh2.fr2 Value]

  # ctext as info text
  ttk::frame $fh3.fr3
  set textw [createCTW $fh3.fr3]
  
  set table [tvlib::newTable $fh3 [list W X Y Raute d x y T ]]

  pack $fh2.fr2 $fh3.fr3 -side right -expand 1 -fill both

  # treeview and buttonbar
  set ftr [ttk::frame $fv1.ftr]
  pack $ftr -sid top -expand 1 -fill both

  ttk::frame $ftr.fr1
  set tree [createTV $ftr.fr1]
  # combobox for example data und select -selectmode  tree
  ttk::frame $ftr.frbtn
  createButton $ftr.frbtn $tree

  # buttons for cmds
  ttk::frame $fv2.frbar
  buttonbar $fv2.frbar $tree $textw

  pack $ftr.frbtn -side top -expand 0 -fill x
  pack $ftr.fr1 $fv2.frbar -side top -expand 1 -fill both

  #band stripes
  tvlib::bandInit $tree
  tvlib::band $tree
  # event generate $tree <<TVItemsChanges>> -data [$tree selection]
  # use:
  # tvlib::bandEvent $tree


  set output "[array get ttk::treeview::State]\n"
  $textw insert end $output
  
}

###################################
#main
###################################
mainGui

