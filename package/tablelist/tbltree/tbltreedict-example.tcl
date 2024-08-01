#! /usr/bin/env tclsh

#tbltreedict-example.tcl
#20240729

# delete and insert with popup
# https://www.nemethi.de/tablelist/tablelistWidget.html#local_drag_and_drop
#
package require tablelist_tile
package require ctext
package require dicttool
catch {source [file join $tablelist::library demos option_tile.tcl]}

set dirname [file dirname [info script]]
source [file join $dirname tbltreedict.tcl]
source [file join $dirname tbltreemove.tcl]
source [file join $dirname tbltreexml.tcl]

# callback for tbl, Double 1 or space
proc cbtree {input t W x y args} {
   set tbl [tablelist::getTablelistPath $W]
   set treecolumn [$tbl cget -treecolumn]
   switch $input {
      m {
         foreach {tbl x y} [tablelist::convEventFields $W $x $y] {}
         set row [$tbl containing  $y]
         set cell [$tbl cellcget $row,$treecolumn -text]
         set data [tbl::tbltree2dict $tbl $row]
         $t insert end "\n#############################################n"
         $t insert end "\ncbtree $input :\n"
         $t insert end "$W $x $y :: $tbl $row \n"
         $t insert end "value: [$tbl cellcget $row,value -text] \n"
         $t insert end "dict data row $row $cell\n"
         $t insert end "[dict print $data]\n"
         $t insert end "[infoRow $tbl $row $t]\n"
         $t see end
      }
      k {
         set k $x
         set K $y
         if { $K eq "space" } {
            set row [$tbl curselection]
            set cell [$tbl cellcget $row,$treecolumn -text]
            set data [tbl::tbltree2dict $tbl $row]
            $t insert end "\n#############################################n"
            $t insert end "\ncbtree $input:\n"
            $t insert end "$W $x $y :: $tbl $row\n"
            $t insert end "value: [$tbl cellcget $row,value -text] \n"
            $t insert end "dict data row $row $cell\n"
            $t insert end "[dict print $data]\n"
            $t insert end "[infoRow $tbl $row $t]\n"
            $t see end
         }
      }
   }
}

# manages extra infos for text window
proc infoRow {tbl row t} {
   lappend  parentsRoot root [$tbl childkeys root]
   set parentkey [$tbl parentkey $row]
   set childcount [$tbl childcount $row]
   set childindex [$tbl childindex $row]
   set descendantcount [$tbl  descendantcount $row]
   set childkeys  [$tbl childkeys $row]
   set depth [$tbl depth $row]
   set childcountpk [$tbl childcount $parentkey]
   if {$parentkey eq "root"} {
      set childindexpk [$tbl childindex k0]
   } else {
      set childindexpk [$tbl childindex $parentkey]
   }
   set childkeyspk  [$tbl childkeys $parentkey]
   set depthpk [$tbl depth $parentkey]
   set noderow [$tbl noderow $parentkey $childindex]
   set childKindex [lindex $childkeys $childindex]
   set toplevelkey [$tbl toplevelkey $row]
   $t insert end "\ninfoRrow $tbl row: $row:"
   $t insert end "\npR: $parentsRoot :: pk: $parentkey :: cc: $childcount :: ci: $childindex :: da: $descendantcount \
    :: cks: $childkeys :: d: $depth" 
   $t insert end "\nccpk: $childcountpk :: cipk: $childindexpk :: ckpk: $childkeyspk :: \
    dpk: $depthpk :: noderow: $noderow :: cki: $childKindex :: tlk: $toplevelkey"
   $t see end
}

# Create the Tablelist widget with tree configuration
proc createTree {w t args} {
   set frt [ttk::labelframe $w.frt -text $args]
   set tbl [tablelist::tablelist $frt.tbl -columns {0 "Key" 40 "Value"} -height 20 -width 0 \
    -stretch all -treecolumn 0 -treestyle classic \
    -selectmode single]
   $tbl columnconfigure 0 -name key
   $tbl columnconfigure 1 -name value
   set vsb [scrollbar $frt.vsb -orient vertical -command [list $tbl yview]]
   set hsb [scrollbar $frt.hsb -orient horizontal -command [list $tbl xview]]
   $tbl configure -yscroll [list $vsb set] -xscroll [list $hsb set]

   bind [$tbl bodytag] <Double-1> [list cbtree m $t %W %x %y ]
   bind [$tbl bodytag] <KeyRelease> [list cbtree k $t %W %k %K ]

   bind [$tbl bodytag] <<Button3>> +[list cbtk_popup %W  %x %y %X %Y $t]
   bind [$tbl bodytag] <Button-1> +[list cbtk_popupExists  %W  %x %y %X %Y $t]

   tbl::init_moveMBind $tbl
   tbl::init_moveKBind $tbl
   pack $vsb -side right -fill y
   pack $hsb -side bottom -fill x
   pack $tbl -expand yes -fill both

   pack $frt -expand yes -fill both
   return $tbl
}

# https://www.nemethi.de/tablelist/tablelistWidget.html#local_drag_and_drop
# not working properly, can't find my error  
proc acceptChildCmd {tbl targetParentNodeIdx sourceRow} {
   # tbl targetParentNodeIdx sourceRow
   # Debugging output
   #puts "acceptChildCmd called with: $tbl, targetParentNodeIdx: $targetParentNodeIdx, sourceRow: $sourceRow"
   return 1  ;# For simplicity, allow all moves
}

proc acceptDropCmd {tbl targetRow sourceRow} {
   # tbl targetRow sourceRow
   # Check if the operation stays within the same parent node
   # return [expr {$sourceRow != $rowCount - 1 && $targetRow < $rowCount}]
   return 1
}

# Create the Tablelist widget with tree configuration and local drag_and_drop
proc createTreelDD {w t args} {
   set frt [ttk::labelframe $w.frt -text $args]
   set tbl [tablelist::tablelist $frt.tbl -columns {0 "Key" 40 "Value"} -height 20 -width 0 \
    -stretch all -treecolumn 0 -treestyle classic \
    -movablerows true -acceptchildcommand "acceptChildCmd" -acceptdropcommand "acceptDropCmd" -selectmode single]
   $tbl columnconfigure 0 -name key
   $tbl columnconfigure 1 -name value
   set vsb [scrollbar $frt.vsb -orient vertical -command [list $tbl yview]]
   set hsb [scrollbar $frt.hsb -orient horizontal -command [list $tbl xview]]
   $tbl configure -yscroll [list $vsb set] -xscroll [list $hsb set]

   bind [$tbl bodytag] <Double-1> [list cbtree m $t %W %x %y ]
   bind [$tbl bodytag] <KeyRelease> [list cbtree k $t %W %k %K ]

   bind [$tbl bodytag] <<Button3>> +[list cbtk_popup %W  %x %y %X %Y $t]
   bind [$tbl bodytag] <Button-1> +[list cbtk_popupExists  %W  %x %y %X %Y $t]

   pack $vsb -side right -fill y
   pack $hsb -side bottom -fill x
   pack $tbl -expand yes -fill both

   pack $frt -expand yes -fill both
   return $tbl
}


# button1 selection for popup only if popup already exists
proc cbtk_popupExists {W x y X Y t} {
   if {[winfo exists .cbtk_popup]} {
      cbtk_popup  $W  $x $y $X $Y $t
   }
}

# popup for infos
proc cbtk_popup {W x y X Y t} {
   if {[winfo exists .cbtk_popup]} {
      set geometry [wm geometry .cbtk_popup]
      destroy .cbtk_popup
   }
   set tbl [tablelist::getTablelistPath $W]
   foreach {tbl x y} [tablelist::convEventFields $W $x $y] {}
   set row [$tbl containing  $y]
   # if outside the table
   if {$row == "-1" } {
      set row last
   }
   set key [$tbl cellcget $row,key -text]
   set value [$tbl cellcget $row,value -text]
   set top [toplevel .cbtk_popup ]

   if {[info exists geometry]}  {
      wm geometry $top $geometry
   } else {
      wm geometry $top +$X+[expr {$Y+50}]
   }
   wm transient $top $tbl

   $tbl selection clear 0 end
   $tbl selection anchor $row
   $tbl selection set $row
   $tbl activate $row

   set krow [$tbl getfullkey $row]
   set pk [$tbl parentkey $row]
   set cix [$tbl childindex $row]
   set cc [$tbl childcount $row]
   set dc [$tbl  descendantcount $row]
   set nr [$tbl noderow $pk $cix]
   
   ttk::label $top.labinfo1 -text "row: $row krow: $krow nr: $nr" -background white 
   ttk::label $top.labinfo2 -text "pk: $pk cix: $cix cc: $cc dc: $dc" -background white 
   ttk::button $top.btninfo -text "Info row $row"  -command [list infoRow $tbl $row $t]
   ttk::button $top.btndump -text "dumptostring " -command [list cbtkpm $tbl $row dumptostring $top.entkey $top.entvalue $t]
   ttk::button $top.btntree2dict -text tbltree2dict -command [list cbtkpm $tbl $row tbltree2dict $top.entkey $top.entvalue $t]
   ttk::button $top.btndel -text "Delete row $row" -command [list $tbl delete $row]
   ttk::button $top.btnupt -text "Update row $row" -command [list cbtkpm $tbl $row update $top.entkey $top.entvalue $t]
   ttk::button $top.btnins -text "Insert after row $row" -command [list cbtkpm $tbl $row insert $top.entkey $top.entvalue $t]

   ttk::entry $top.entkey
   ttk::entry $top.entvalue

   $top.entkey insert 0 $key
   $top.entvalue insert 0 $value

   pack {*}[winfo children $top] -fill x -pady 2 -padx 2
}

# callbacks for popup
proc cbtkpm {tbl row cmd entkey entval t} {
   set key [$entkey get]
   set value [$entval get]

   switch $cmd {
      update {
         $tbl cellconfigure $row,key -text $key
         $tbl cellconfigure $row,value -text $value
      }
      insert {
         set parentkey [$tbl parentkey $row]
         set childindex [$tbl childindex $row]
         $tbl insertchild $parentkey [incr childindex] [list $key $value]
      }
      dumptostring {
         set data [$tbl dumptostring]
         $t insert end "\n$data"
      }
      tbltree2dict {
         set data [tbl::tbltree2dict $tbl root]
         $t insert end "\n$data"
      }
   }
   $t see end
}

# text window for information
proc createText {w} {
   set frt [ttk::frame $w.frt]
   set t [ctext $frt.t -setgrid true -wrap word -width 120 \
    -yscrollcommand "$frt.vsb set" -xscrollcommand "$frt.hsb set"]
   set vsb [scrollbar $frt.vsb -orient vertical -command "$t yview"]
   set hsb [scrollbar $frt.hsb -orient horizontal -command "$t xview"]
   pack $hsb -side bottom -fill x
   pack $vsb -side right -fill y
   pack $t -side left -fill both -expand true
   pack $frt -expand yes -fill both
   return $t
}

# cb for selection example data and info window for tablelist options and commands
proc createButton {w tbl1 tbl2 data t} {
   set dataList [dict keys $data]
   set frt [ttk::frame $w.frt]
   # combobox
   set cbselection [ttk::combobox $frt.cbselection -values $dataList -exportselection 0 -width 8]
   $cbselection current 5

   bind $cbselection <<ComboboxSelected>> [namespace code [list cbComboSelected %W $tbl1 $tbl2 $data $t]]
   cbComboSelected $cbselection $tbl1 $tbl2 $data $t

   set infotext [string map {:: \n} {pR: root [$tbl childkeys root] :: pk: [$tbl parentkey $row] :: cc: [$tbl childcount $row] :: ci: [$tbl childindex $row] :: da: [$tbl  descendantcount $row]  :: cks: [$tbl childkeys $row] :: d: [$tbl depth $row] :: ccpk: [$tbl childcount $parentkey] :: cipk: $childindexpk :: ckpk: [$tbl childkeys $parentkey] :: dpk: [$tbl depth $parentkey] :: noderow:[$tbl noderow $parentkey $childindex] :: cki: [lindex $childkeys $childindex] :: tlk: [$tbl toplevelkey $row]}]

   set infobtn [ttk::button $frt.infobtn -text "infoRow" -command [list tk_messageBox -detail $infotext]]

   pack $cbselection $infobtn -side left
   pack $frt -side top -expand 0 -fill x

   return $cbselection
}

# Insert the data into the Tablelist widget, starting at the root node
proc dataTotbl {tbl data t} {
   tbl::dict2tbltree $tbl root $data
   # output in text widget
   $t insert end "data $tbl:\n"
   $t insert end $data
   $t insert end "\n\n"
   $t insert end "data $tbl:"
   $t insert end [dict print $data]
   $t insert end "\n\n"
}

proc cbComboSelected {w tbl1 tbl2 data t} {
   set data1 [dict get $data [$w get]]
   if {[$w get] eq "all" }  {
      set data1 $data
   }
   set ::spinvar(actuell) {}
   $tbl1 delete 0 end
   $tbl2 delete 0 end
   $t delete 1.0 end
   # data to tbl1
   dataTotbl $tbl1 $data1 $t
   # Convert the tree back to a dictionary
   set data2 [tbl::tbltree2dict $tbl1 root]
   # Insert the  data2 into another Tablelist widget
   dataTotbl $tbl2 $data2 $t
   $t see end
}


###
#Example datas in dict data, 2-4 differences in number of employees
dict set data all {}
dict set data Example1 {person {name "John Doe" age 30 address {street "123 Main St" city "Anytown"}} job {title "Developer" company "Works"}}
dict set data Example2 {person  {name "John Doe" age 30 address {street "123 Main St" city "Anytown"}  employees {  {name "Alice Smith" } {name "Bob Smith"} {name "John Good"} } } job {title "Developer" company "Works"}}
dict set data Example3 {person  {name "John Doe" age 30 address {street "123 Main St" city "Anytown"}  employees {  {name "Alice Smith" } {name "Bob Smith"} } } job {title "Developer" company "Works"}}
dict set data Example4 {person  {name "John Doe" age 30 address {street "123 Main St" city "Anytown"}  employees {  {name "Alice Smith" } {name "Bob Smith"} {name "John Good"} {name "Jane Good"}} } job {title "Developer" company "Works"}}
dict set data Example5 {a1 {b11 {a11 {b1111 c1 b1112 c1}} b12 {a12 {b1211 c1 b1212 c1}}} a2 {b21 {a21 {b2111 c1 b2112 c1}} b22 {a22 {b2211 c1 b2212 c1}}}}
set employeeInfo {
   12345-A {forenames "Joe" surname "Schmoe" street "147 Short Street" city "Springfield" phone "555-1234"}
   98372-J {forenames "Anne" surname "Other" street "32995 Oakdale Way" city "Springfield" phone "555-8765"}
}

dict set data employeeInfo $employeeInfo

###
#main
# create two Tablelist and a text widget
ttk::frame .fr1
ttk::frame .fr2
ttk::frame .frt
ttk::frame .frb

pack .frt -side right -expand 1 -fill both
pack .frb .fr1  .fr2 -side top -expand 1 -fill both

set t    [createText .frt]
set tbl1 [createTree .fr1 $t]
set tbl2 [createTreelDD .fr2 $t "local drag and drop"]
set btn  [createButton .frb $tbl1 $tbl2 $data $t]

puts  [$tbl1 cget -treecolumn]

