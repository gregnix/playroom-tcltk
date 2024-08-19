#! /usr/bin/env tclsh

#20240819

# treeview-lib-example.tcl

package require Tk
package require ctext
package require scrollutil_tile
package require tooltip


# procs with namespace tvlib:: and example datas
source treeview-lib.tcl


# ctext widget for info display
variable textw
variable allTVWidgets

proc createCTW {w} {
  set frt [ttk::frame $w.frt ]
  set textw [ctext $frt.text -width 100 -yscrollcommand [list $frt.vsb set]]
  set vsb [ttk::scrollbar $frt.vsb -orient vertical -command [list $textw yview]]

  pack $frt -side top -fill both -expand 1
  pack $textw -expand 1 -fill both

  return $textw
}


# combobox  for selection example data and $tree configure -selectmode
proc createButton {w tree} {
  variable allTVWidgets
  set frt [ttk::frame $w.frt]
  # combobox for example datas
  set cbdatas [ttk::combobox $frt.cbdatas -values {table tree treerand treemedium "treemedium with rowidx" treegreat abc12 person info} -exportselection 0 -width 15]
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

  dict set allTVWidgets searchWord [ttk::entry $frt.search]
  set searchWord [dict get $allTVWidgets searchWord]
  tooltip::tooltip $searchWord "Entry for search"
  
  pack $cbdatas $cbselectmode $cbthemen  $searchWord -side left
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
      set tree [tvlib::newTree  $wid [list Keys Values Rowidx]]
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
# llength args 1: cmds
# llength args 2: textw cmds, textw for info display
proc cbbtnbar {tree args }  {
variable allTVWidgets
set buttoncmd [dict get $allTVWidgets buttoncmd]
$buttoncmd delete 1.0 end
$buttoncmd insert end   "[lindex [dict get [info frame 1] cmd] 0]\n"
$buttoncmd insert end   [lindex [dict get [info frame -1] cmd] end]
   switch  [llength $args]  {
    1 {
      set cmds {*}$args
      foreach cmd [split $cmds ";"] {
        eval [string trimleft $cmd]
      }
    }
    2 {
      set textw [lindex $args 0]
      set cmds [lindex $args 1]
      foreach cmd [split $cmds ";"] {
        $textw insert end "[eval [string trimleft $cmd]]\n"
      }
      $textw see end
    }
    3 {
      puts 3
      set textw [lindex $args 0]
      set tvwid [lindex $args 1]
      set cmds [lindex $args 2]
      foreach cmd [split $cmds ";"] {
        $textw insert end "[eval [string trimleft $cmd]]\n"
      }
      $textw see end 
    }
  }
}

proc searchResult {values} {
  variable allTVWidgets
  set searchresultbox [dict get $allTVWidgets searchresultbox]
  set tree [dict get $allTVWidgets tree]
  # tv listboox data
  $searchresultbox delete [$searchresultbox children {}]
  tvlib::addCells $searchresultbox 0 $values 0
  tvlib::addCells $searchresultbox 0 $values 0
  
  foreach item [$searchresultbox children {}] {
      set treeitem [$searchresultbox set $item #1]
      set cellsData [$tree item $treeitem -text]
      $searchresultbox set $item #2 $cellsData
    }
}

proc buttonbar {w tree textw } {
  variable allTVWidgets
 
  set tvbox [dict get $allTVWidgets tvbox]
  set table [dict get $allTVWidgets table]
  set searchWord [dict get $allTVWidgets searchWord]

  set f [ttk::frame $w.f]
  set cf [ttk::frame $f.cf]
      
  # for command:
  # [list cbbtnbar $tree { cmds }]
  # [list cbbtnbar $tree  textw { cmds }]
  ttk::button $cf.b100 -text "Test Button" -command [list cbbtnbar $tree $textw $searchWord {$tvwid get}]
  ttk::button $cf.b101 -text "Info tree" -command [list cbbtnbar $tree $textw $tree {set tmpOutput \$tree;set tvwid; \
  $tvwid configure; $tvwid column #0;$tvwid column #1;$tvwid column #2;$tvwid heading #0;$tvwid heading #1;$tvwid heading #2}]
  ttk::button $cf.b102 -text "Info tvbox" -command [list cbbtnbar $tree $textw $tvbox {set tmpOutput \$tvbox;set tvwid; \
  $tvwid configure; $tvwid column #0;$tvwid column #1;$tvwid heading #0;$tvwid heading #1}]
  ttk::button $cf.b103 -text "Info table" -command [list cbbtnbar $tree $textw $table {set tmpOutput \$table;set tvwid; \
  $tvwid configure; \
  $tvwid column #0;$tvwid column #1;$tvwid column #2;$tvwid column #3;$tvwid column #4;$tvwid column #5;$tvwid column #6;$tvwid column #7; \
  $tvwid heading #0;$tvwid heading #1;$tvwid heading #2;$tvwid heading #3;$tvwid heading #4;$tvwid heading #5;$tvwid heading #6;$tvwid heading #7}]
  ttk::button $cf.b104 -text "ctext clean" -command [list cbbtnbar $tree [list $textw delete 1.0 end]]
  
  ttk::button $cf.b110 -text "Set Focus I001" -command [list cbbtnbar $tree {$tree focus I001}]
  ttk::button $cf.b111 -text "Get Focus" -command  [list cbbtnbar $tree $textw {$tree focus}]
  ttk::button $cf.b112 -text "Get Focus Item \nand info" -command [list cbbtnbar $tree $textw {set ouput "[$tree focus] index: [$tree index [$tree focus]] \
  -tags [$tree item [$tree focus] -tags] -open [$tree item [$tree focus] -open] \
  -text [$tree item [$tree focus] -text] -values [$tree item [$tree focus] -values]"}]
  
  ttk::button $cf.b120 -text "expandAll {}" -command [list cbbtnbar $tree {tvlib::expandAll $tree {}}]
  ttk::button $cf.b121 -text "collapseAll {}" -command [list cbbtnbar $tree {tvlib::collapseAll $tree {}}]
  ttk::button $cf.b122 -text "expandAll sel" -command [list cbbtnbar $tree {tvlib::expandAll $tree [$tree selection]}]
  ttk::button $cf.b123 -text "collapseAll sel" -command [list cbbtnbar $tree {tvlib::collapseAll $tree [$tree selection]}]
  
  ttk::button $cf.b130 -text "Clear Selection" -command [list cbbtnbar $tree {$tree selection set ""}]
  ttk::button $cf.b131 -text "Delete Selected" -command [list cbbtnbar $tree {$tree delete [$tree selection]; tvlib::bandEvent $tree}]
  ttk::button $cf.b132 -text "Remove Selection" -command [list cbbtnbar $tree {$tree selection remove [$tree selection]}]
  ttk::button $cf.b133 -text "Select Item add 'Entry' list \nand see first" -command [list cbbtnbar $tree $textw $searchWord {$tree selection add [$tvwid get];$tree see [lindex [$tvwid get] 0]}]
  ttk::button $cf.b134 -text "Select Item toggle 'Entry'" -command [list cbbtnbar $tree $textw $searchWord { $tree selection toggle [$tvwid get]}]
  ttk::button $cf.b135 -text "Select Item 'Entry' \nand see" -command [list cbbtnbar $tree $textw $searchWord { $tree selection set [$tvwid get];$tree see [$tvwid get]}]
  ttk::button $cf.b140 -text "Add item" -command [list cbbtnbar $tree {$tree insert {} end -text "Item  # [expr {[tvlib::treesize $tree] +1}]";\
  $tree item [lindex [$tree children {}] end] -values [lindex [$tree children {}] end]; tvlib::bandEvent $tree}]
  
  ttk::button $cf.b201 -text "tree depth" -command [list cbbtnbar $tree $textw {tvlib::treedepth $tree}]
  ttk::button $cf.b202 -text "item depth in tree" -command [list cbbtnbar $tree $textw {tvlib::itemdepth $tree [$tree selection]}]
  ttk::button $cf.b203 -text "tree size" -command [list cbbtnbar $tree $textw {tvlib::treesize $tree}]
  ttk::button $cf.b210 -text "tree children {}" -command [list cbbtnbar $tree $textw {$tree children {}}]
  ttk::button $cf.b211 -text "childrens col k {}" -command [list cbbtnbar $tree $textw {tvlib::collectKeys [tvlib::tv2list $tree]}]
  ttk::button $cf.b212 -text "childrens P col k {}" -command [list cbbtnbar $tree $textw {tvlib::collectKeysPoint [tvlib::tv2list $tree]}]
  ttk::button $cf.b213 -text "childrens tails {}" -command [list cbbtnbar $tree $textw {tvlib::extractTails [tvlib::collectKeysPoint [tvlib::tv2list $tree {}]]}]
  ttk::button $cf.b214 -text "childrens heads {}" -command [list cbbtnbar $tree $textw {tvlib::extractHeads [tvlib::collectKeysPoint [tvlib::tv2list $tree {}]]}]
  ttk::button $cf.b220 -text "tree children sel" -command [list cbbtnbar $tree $textw {$tree children [$tree selection]}]
  ttk::button $cf.b221 -text "childrens col k sel" -command [list cbbtnbar $tree $textw {tvlib::collectKeys [tvlib::tv2list $tree [$tree selection]]}]
  ttk::button $cf.b222 -text "childrens P col k sel" -command [list cbbtnbar $tree $textw {tvlib::collectKeysPoint [tvlib::tv2list $tree [$tree selection]]}]
  ttk::button $cf.b223 -text "childrens tails sel" -command [list cbbtnbar $tree $textw {tvlib::extractTails [tvlib::collectKeysPoint [tvlib::tv2list $tree [$tree selection]]]}]
  ttk::button $cf.b224 -text "childrens heads sel" -command [list cbbtnbar $tree $textw {tvlib::extractHeads [tvlib::collectKeysPoint [tvlib::tv2list $tree [$tree selection]]]}]
  ttk::button $cf.b230 -text "tvtree2dict {}" -command [list cbbtnbar $tree $textw {tvlib::tvtree2dict $tree {}}]
  ttk::button $cf.b231 -text "tvtree2dict sel" -command [list cbbtnbar $tree $textw {tvlib::tvtree2dict $tree [$tree selection]}]
  ttk::button $cf.b240 -text "search Keys and \nsel 'Entry'" -command [list cbbtnbar $tree $textw $searchWord {tvlib::showVisibleItems $tree [$tvwid get];\
  $tree selection set "";$tree selection add [tvlib::showVisibleItems $tree [$tvwid get]];\
  searchResult [tvlib::showVisibleItems $tree [$tvwid get]]}]
  ttk::button $cf.b241 -text "search and \nsel grandchild 3" -command [list cbbtnbar $tree $textw {tvlib::showVisibleItems $tree "grandchild 3";\
  $tree selection set "";$tree selection add [tvlib::showVisibleItems $tree "grandchild 3"]}]
  ttk::button $cf.b250 -text "BuildChildCountDict" -command [list cbbtnbar $tree $textw {tvlib::buildChildCountDict $tree}]
  ttk::button $cf.b251 -text "rowsparentidx" -command [list cbbtnbar $tree $textw {tvlib::getDict}]
  ttk::button $cf.b252 -text "Find Index sel" -command [list cbbtnbar $tree $textw {tvlib::findRowFromDict $tree [$tree selection]}]
  ttk::button $cf.b253 -text "index sel" -command [list cbbtnbar $tree $textw {$tree index [$tree selection]}]
   
  set font [::ttk::style lookup [$tree cget -style] -font]
  ttk::style configure AnotherButton.TButton -font "$font 9"

  # Use grid to arrange the ttk::buttons in .. columns
  set row 0
  set col 0
  foreach btn [winfo children $cf] {
    $btn configure -style AnotherButton.TButton
    grid $btn -row $row -column $col -sticky snwe -padx 2 -pady 2
    incr col
    if {$col > 10} {
      set col 0
      incr row
    }
  }
  grid $cf -sticky news

  grid columnconfigure $cf 0 -weight 1
  grid columnconfigure $cf 1 -weight 1
  grid rowconfigure $cf $row -weight 1
  #grid rowconfigure    $cf all -uniform AllRows
  #grid columnconfigure $cf 1   -weight 1

  # Configure the scrollableframe to expand
  grid $f -sticky news
  grid rowconfigure $f 0 -weight 1
  grid columnconfigure $f 0 -weight 1
  buttonbartooltip $cf
}

# mini docu
proc buttonbartooltip {cf} {
  tooltip::tooltip $cf.b100 "Test Button: Executes a test action."
  tooltip::tooltip $cf.b101 "Displays information about the 'tree' widget."
  tooltip::tooltip $cf.b102 "Displays information about the 'tvbox' widget."
  tooltip::tooltip $cf.b103 "Displays information about the 'table' widget."
  tooltip::tooltip $cf.b104 "Clears the entire content of the text widget."
  
  tooltip::tooltip $cf.b110 "Sets focus on the item with ID 'I001'."
  tooltip::tooltip $cf.b111 "Retrieves the ID of the currently focused item and displays it in the text widget."
  tooltip::tooltip $cf.b112 "Gets detailed information about the focused item and displays it."
  
  tooltip::tooltip $cf.b120 "Expands all nodes in the treeview."
  tooltip::tooltip $cf.b121 "Collapses all nodes in the treeview."
  tooltip::tooltip $cf.b122 "Expands all nodes under the selected item."
  tooltip::tooltip $cf.b123 "Collapses all nodes under the selected item."
  
  tooltip::tooltip $cf.b130 "Clears the current selection in the treeview."
  tooltip::tooltip $cf.b131 "Deletes the selected item(s) from the treeview."
  tooltip::tooltip $cf.b132 "Removes the selected item(s) from the selection list."
  tooltip::tooltip $cf.b133 "Adds an item to the selection and scrolls to the first item."
  tooltip::tooltip $cf.b134 "Toggles the selection of an item."
  tooltip::tooltip $cf.b135 "Selects an item and scrolls to it."
  tooltip::tooltip $cf.b140 "Adds a new item to the treeview."
  
  tooltip::tooltip $cf.b201 "Calculates and displays the depth of the treeview."
  tooltip::tooltip $cf.b202 "Calculates and displays the depth of the selected item in the treeview."
  tooltip::tooltip $cf.b203 "Counts and displays the total number of items in the treeview."
  tooltip::tooltip $cf.b210 "Displays the children of the root node ({})."
  tooltip::tooltip $cf.b211 "Lists all keys from the root node ({})."
  tooltip::tooltip $cf.b212 "Lists all keys from the root node ({}), with dot-separated paths."
  tooltip::tooltip $cf.b213 "Extracts and displays the tail keys from the root node ({})."
  tooltip::tooltip $cf.b214 "Extracts and displays the head keys from the root node ({})."
  tooltip::tooltip $cf.b220 "Displays the children of the selected node."
  tooltip::tooltip $cf.b221 "Lists all keys from the selected node."
  tooltip::tooltip $cf.b222 "Lists all keys from the selected node, with dot-separated paths."
  tooltip::tooltip $cf.b223 "Extracts and displays the tail keys from the selected node."
  tooltip::tooltip $cf.b224 "Extracts and displays the head keys from the selected node."
  tooltip::tooltip $cf.b230 "Exports the entire treeview as a dictionary from the root node."
  tooltip::tooltip $cf.b231 "Exports the treeview as a dictionary from the selected node."
  tooltip::tooltip $cf.b240 "Searches for keys and selects the matching entries."
  tooltip::tooltip $cf.b241 "Searches for 'grandchild 3' and selects the matching items."
  tooltip::tooltip $cf.b250 "Builds a child count dictionary for the treeview."
  tooltip::tooltip $cf.b251 "Displays the dictionary with child counts."
  tooltip::tooltip $cf.b252 "Finds and displays the global index of the selected item."
  tooltip::tooltip $cf.b253 "Displays the index of the selected item within its parent."
}


# selection for example datas in tree
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
        $tree item $id -values [list $id]
        for {set i  1} {$i < 5} {incr i} {
          set child [$tree insert $id end -text "child $i"]
          $tree item $child -values [list $child]
          if {$i eq "2"} {
            continue
          }
          for {set j 1} {$j < 4} {incr j } {
            set grandchild [$tree insert $child end -text "grandchild $i"]
            $tree item $grandchild -values [list $grandchild]
          }
        }
      }
      set r -1
      foreach item  [tvlib::collectKeys [tvlib::tv2list $tree]] {
        $tree item $item -values [list [$tree item $item -values] [incr r]]
      }
      tvlib::expandAll $tree {}
      tvlib::buildChildCountDict $tree
    }
    treerand {
      foreach txt {first second third} {
        set id [$tree insert {} end -text "$txt item" -open 1]
        $tree item $id -values [list $id]
        for {set i [expr {1+int(rand()*5)}]} {$i > 0} {incr i -1} {
          set child [$tree insert $id 0 -text "child $i"]
          $tree item $child -values [list $child]
          for {set j [expr {int(rand()*4)}]} {$j > 0} {incr j -1} {
            set grandchild [$tree insert $child 0 -text "grandchild $i"]
            $tree item $grandchild -values [list $grandchild]
          }
        }
      }
      set r -1
      foreach item  [tvlib::collectKeys [tvlib::tv2list $tree]] {
        $tree item $item -values [list [$tree item $item -values] [incr r]]
      }
      tvlib::expandAll $tree {}
      tvlib::buildChildCountDict $tree
    }
    abc12 {
      # d.1 data dict for example datas
      tvlib::dict2tvtree $tree {} [dict get $tvlib::exampleDatas abc12]
      set r -1
      foreach item  [tvlib::collectKeys [tvlib::tv2list $tree]] {
        $tree item $item -values [list [$tree item $item -values] [incr r]]
      }
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
    "treemedium with rowidx" {
      # d.2 test data creator
      tvlib::testCreateTreeStruct $tree 6
      set r -1
      foreach item  [tvlib::collectKeys [tvlib::tv2list $tree]] {
        $tree item $item -values [list [$tree item $item -values] [incr r]]
      }
      tvlib::buildChildCountDict $tree
    }
    info  {
      # d.2 test data creator
      tvlib::dict2tvtree $tree {} [tvlib::infotcltk]
      tvlib::buildChildCountDict $tree
    }
  }
}

proc cbsrb {args} {
  variable allTVWidgets
  set tree [dict get $allTVWidgets tree]
  set searchresultbox [dict get $allTVWidgets searchresultbox]
  set item  [$searchresultbox set [$searchresultbox focus] #1]
  $tree see $item
  $tree focus $item
}


# for info in ctext widget
proc show {args} {
  variable textw
  variable allTVWidgets
    
  set table [dict get $allTVWidgets table]
  set tvbox [dict get $allTVWidgets tvbox]
   
  lassign $args W X Y Raute d  x y T rest
  set tree $W

  set values [list]
  # only column values, 
  set values [lindex [$tree item [$tree focus] -values] 0]

  # tv listboox data
  $tvbox delete [$tvbox children {}]
  tvlib::addCells $tvbox 0 $values 0
  tvlib::bandInit $tvbox
  tvlib::band $tvbox
  tvlib::addRow $table [list  $W  $X $Y  $Raute $d $x $y $T]

  $textw insert end "\nTreeviewSelect  Current selection is '\[\$tree selection\]' [$tree selection ] :: focus:  [$tree focus]\n"
  $textw see end
}

# main gui
proc mainGui {} {
  # ctext widget for info display
  variable textw
  variable allTVWidgets

  
  ### ________________________  _________________________ ###

  set pwv1 [ttk::panedwindow .pwv1 -orient vertical -width 1800]
  set fv11 [ttk::frame $pwv1.fv11]
  set fv12 [ttk::frame $pwv1.fv12]
  $pwv1 add $pwv1.fv11
  $pwv1 add $pwv1.fv12
  pack $pwv1 -expand 1 -fill both -side top


  set pwh [ttk::panedwindow $fv12.pwh -orient horizontal -width 1800 ]
  set fh1 [ttk::frame $pwh.fh1]
  set fh2 [ttk::frame $pwh.fh2]
  set fh3 [ttk::frame $pwh.fh3]
  $pwh add $pwh.fh1
  $pwh add $pwh.fh2
  $pwh add $pwh.fh3
  pack $pwh -expand 1 -fill both -side top

  set pwv2 [ttk::panedwindow $fh1.pwv2 -orient vertical -width 560 ]
  set fv1 [ttk::frame $pwv2.fv1]
  set fv2 [ttk::frame $pwv2.fv2]
  $pwv2 add $pwv2.fv1
  $pwv2 add $pwv2.fv2
  pack $pwv2 -expand 1 -fill both

  # treeview box for value list from treeview
  ttk::frame $fh2.fr2
  dict set allTVWidgets tvbox [tvlib::newTable  $fh2.fr2 [list {Value w 40 1 200}]]

  # ctext as info text
  ttk::frame $fh3.fr3
  set textw [createCTW $fh3.fr3]

  set nb [ttk::notebook $fh3.fr3.frti]
  $nb add [frame $nb.f1] -text "Tree Info"
  $nb add [frame $nb.f2] -text "button cmd"
  $nb add [frame $nb.f3] -text "configure"
  $nb add [frame $nb.f4] -text "column"
  $nb add [frame $nb.f5] -text "table"
  $nb select $nb.f1
  ttk::notebook::enableTraversal $nb
  $nb  hide $nb.f1
  #$nb  hide $nb.f2
  $nb  hide $nb.f3
  $nb  hide $nb.f4
  
  
  dict set allTVWidgets buttoncmd  [createCTW $nb.f2]
  
  
  dict set allTVWidgets table [tvlib::newTable $nb.f5 \
  [list {W w 20 1 300} {X e 20 1 80} {Y e 20 1 80} {Raute center 20 1 80} {x e 20 1 80} {y e 20 1 80} {d e 20 1 80} {T n 20 0 80}] ]
  set table [dict get $allTVWidgets table]
  tvlib::bandInit $table
  tvlib::band $table
  $table configure -height 5
    
  dict set allTVWidgets treeinfo [tvlib::newTree $nb.f1 [list widget achor minwidth stretch width id]]
  dict set allTVWidgets configure [tvlib::newTree $nb.f3 [list widget achor minwidth stretch width id]]
  dict set allTVWidgets column [tvlib::newTable $nb.f4 [list widget achor minwidth stretch width id]]
  
  pack $fh2.fr2  $fh3.fr3 $fh3.fr3.frti -side right -expand 1 -fill both
  # treeview and buttonbar
  set ftr [ttk::frame $fv1.ftr]
  pack $ftr -sid top -expand 1 -fill both

  ttk::frame $ftr.fr1
  dict set allTVWidgets tree [tvlib::newTree  $ftr.fr1 [list Keys Values Rowidx]]
  set tree [dict get $allTVWidgets tree]
  
  # combobox for example data und select -selectmode  tree
  ttk::frame $ftr.frbtn
  createButton $ftr.frbtn $tree
  # search result tv box
  ttk::frame $fv2.frsrb
  dict set allTVWidgets searchresultbox [tvlib::newTable  $fv2.frsrb [list {result w 40 1 100} {keys w 40 300}]]
  set searchresultbox [dict get $allTVWidgets searchresultbox]
  bind $searchresultbox <<TreeviewSelect>> [list cbsrb  %W %X %Y %# %d  %x %y %T]
  
  # button bars for cmds
  ttk::frame $fv11.frbar
  buttonbar $fv11.frbar $tree $textw 

  pack $ftr.frbtn -side top -expand 0 -fill x
  pack $ftr.fr1 $fv11.frbar -side top -expand 1 -fill both
  pack $fv2.frsrb -side left -expand 0 -fill both

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

