#! /usr/bin/env tclsh

#20240813

# treeview-lib-example.tcl

package require Tk
package require ctext
package require scrollutil_tile
package require tooltip

# procs with namespace tvlib:: and example datas
source treeview-lib.tcl

namespace eval tvlib {
  variable rowsparentidx
  
  proc findRowFromDict {tree item} {
    variable rowsparentidx
    puts $rowsparentidx
    puts \n\n
    puts [dict keys [dict get $rowsparentidx 1]]
    puts [lindex [dict keys [dict get $rowsparentidx 1]]1 0]
    puts [dict get $rowsparentidx 1 [lindex [dict keys [dict get $rowsparentidx 1]]1 0]]
    puts \n\n
    if  {[$tree children $item] eq ""} {
      set result [$tree index $item]
    } else {
      set result $item
    }
    set index 0
    set currentItem $item

    # Schleife, um von `item` zu seinem Parent hochzuwandern
    while { $currentItem ne "" } {
      set parent [$tree parent $currentItem]
      #   set index [searchItemInDict $rowsparentidx $currentItem $parent 0 $index]
      lappend result $parent
      set currentItem $parent
    }
    set result [lrange $result 0 end-1]
    set currentItem [lindex $result end]
    # schleife vorgänger in gleicher tiefe 1
    while { $currentItem ne "" } {
      set prev [$tree prev $currentItem]
      #   set index [searchItemInDict $rowsparentidx $currentItem $parent 0 $index]
      lappend prevroot $prev
      set currentItem $prev
    }
    
    set sum [sumCount [lrange $prevroot 0 end-1] 1]
    puts "item: $item"
    puts "prevroot: $prevroot :: $sum "
    puts "result $result\n"
    puts [dict get $rowsparentidx 1 [lindex $result end]]\n
    #puts [dict get $rowsparentidx 1 [lindex $result end] child 2 [lindex $result end-1]]\n
    puts \n\n
    set dvar $rowsparentidx
    set d1 0
    set key 1
    while {[dict exists $dvar $key]} {
      set d2 0
      set d3 0
      dict for {key value} $rowsparentidx {
        incr d1; incr d2; incr d3
        puts "dfor1 ::: k: $key ::: i: $item :::[dict keys [dict get $value]] ::::"
        if {$key eq $item} {
          #puts "if 2fertig:: k: $key ::: i: $item :::[dict keys [dict get $value]]"
          #set key -1
        } else {
          #puts "el 2fertig:: k: $key ::: i: $item ::: [dict keys [dict get $value]]"
          #set key -1
        }
        #puts "item: $item\n"
        #puts "Key: $key - Value: $value"

        #set dvar [dict get $dvar $key]
        incr key 
      }
      
    }
    puts "d1: $d1 d2: $d2 d3: $d3 key: $key"
    return $result
  }
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
  button $cf.b29 -text "getRow sel" -command [list cbbtnbar $tree {$textw insert end [tvlib::getGlobalIndex $tree [$tree selection]]\n}]
  button $cf.b30 -text "BuildChildCountDict" -command [list cbbtnbar $tree {$textw insert end [tvlib::buildChildCountDict $tree]\n}]
  button $cf.b31 -text "keys" -command [list cbbtnbar $tree {$textw insert end [tvlib::keysrowsidx]\n}]
  button $cf.b32 -text "Find Index" -command [list cbbtnbar $tree {$textw insert end [tvlib::findRowFromDict $tree [$tree selection]]\n}]
  button $cf.b33 -text "index sel" -command [list cbbtnbar $tree {$textw insert end [$tree index [$tree selection]]\n}]
  button $cf.b34 -text "ctext clean" -command [list cbbtnbar $tree {$textw delete 4.0 end}]

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
      # d.1 data dict for example datas
      tvlib::dict2tvtree $tree {} [dict get $tvlib::exampleDatas abc12]
    }
    person {
      # d.1 data dict for example datas
      tvlib::dict2tvtree $tree {} [dict get $tvlib::exampleDatas person]
    }
    treegreat {
      # d.2 test data creator
      tvlib::testCreateTreeStruct $tree 7
    }
    treemedium {
      # d.2 test data creator
      tvlib::testCreateTreeStruct $tree 6
    }
    info  {
      # d.2 test data creator
      tvlib::dict2tvtree $tree {} [tvlib::infotcltk]
    }
  }
}
# for info in ctext widget
proc show {args} {
  variable textw
  variable tvbox

  lassign $args W X Y Raute d  x y T rest
  set tree $W

  set values [list]
  set values [struct::list flatten -full -- [$tree item [$tree focus] -values]]
  $tvbox delete [$tvbox children {}]
  tvlib::addCells $tvbox 0 $values 0
  tvlib::bandInit $tvbox
  tvlib::band $tvbox

  $textw insert end "\n$args :: $rest\n"
  $textw insert end "W: $W X: $X Y: $Y #: $Raute d: $d x: $x y: $y T: $T\n "
  $textw insert end "TreeviewSelect  Current selection is '\[\$tree selection\]' [$tree selection ] :: focus:  [$tree focus]\n"
  $textw see end
}

# main gui
proc mainGui {} {
  # ctext widget for info display
  variable textw
  variable tvbox

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
  $textw insert end  "%W %X %Y %#  %d  %x %y  %T\n\n"
}

###################################
#main
###################################
mainGui

