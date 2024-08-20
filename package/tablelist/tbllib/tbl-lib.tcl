package require Tk
package require tablelist_tile

namespace eval tbllib {
 proc newTable {w cols} {
  set frt  $w.frt
  frame $frt -background "gray"

  # Create table
  set tbl [tablelist::tablelist $frt.tbl -columns $cols \
    -stretch all  -xscroll [list $frt.h set] -yscroll [list $frt.v set] -labelcommand tablelist::sortByColumn \
    -selectmode multiple -exportselection false]

  $tbl columnconfigure 0 -sortmode dictionary

  #add scrollbar
  set vsb [scrollbar $frt.v -orient vertical -command [list $tbl yview]]
  set hsb [scrollbar $frt.h -orient horizontal -command [list $tbl xview]]

  # Add frames
  set frb [frame $w.frb]
  grid $frb -row 1 -column 0 -sticky ew -columnspan 2
  grid $frt -row 0 -column 0 -sticky nsew

  grid $vsb -row 0 -column 1 -sticky ns
  grid $hsb -row 1 -column 0 -sticky ew
  grid $tbl -row 0 -column 0 -sticky nsew

  #add button
  set btnone [button $frb.one -text "Button One" -command [list tk_messageBox -message "Tbl: $tbl" -type ok]]
  set btntwo [button $frb.two -text "Button Two" -command [list tblcallback $tbl ]]

  grid $btnone -row 0 -column 0 -sticky w
  grid $btntwo -row 0 -column 1 -sticky e

  grid columnconfigure $frt 0 -weight 1
  grid rowconfigure $frt 0  -weight 1
  grid columnconfigure $w 0 -weight 1
  grid rowconfigure $w 0  -weight 1

  #add bind
  bind [$tbl bodytag] <Double-1> [list tk_messageBox -message "Tbl: $tbl\nW %W" -type ok]
  bind [$tbl bodytag] <Key-a> [list tk_messageBox -message \
    "Tbl: $tbl\nW %W\nx: %x y:%y\nX:%X Y:%Y\n [join "%k %i %s %A %K %M %N %R %S %T" \n]" -type ok]
  bind [$tbl bodytag] <Key-F4> [list $btntwo invoke]

  return $tbl
 }

}
namespace eval tbllib {
 # Generate example data for the table with a specified number of entries and columns
 proc generateLargeList {numEntries numColumns} {
  set largeList {}
  for {set i 1} {$i <= $numEntries} {incr i} {
   set entry [list]
   for {set j 1} {$j <= $numColumns} {incr j} {
    lappend entry "Item_${i}_${j}"
   }
   lappend largeList $entry
  }
  return $largeList
 }
}


namespace eval tbllib {
 proc newTable {w cols} {
  set frt  $w.frt
  frame $frt -background "gray"

  # Create table
  set tbl [tablelist::tablelist $frt.tbl -columns $cols \
          -stretch all -xscroll [list $frt.h set] -yscroll [list $frt.v set] -labelcommand tablelist::sortByColumn \
          -selectmode multiple -exportselection false]

  # Make the second column editable (basic text editing)
  $tbl columnconfigure 1 -editable true

  # Make the third column editable with a combobox having predefined values
  $tbl columnconfigure 2 -editable true -editwindow  ttk::combobox

  # Configure edit start command to setup combobox values
  $tbl configure -editstartcommand tbllib::editStartCmd


  # Add scrollbars
  set vsb [scrollbar $frt.v -orient vertical -command [list $tbl yview]]
  set hsb [scrollbar $frt.h -orient horizontal -command [list $tbl xview]]

  # Add frames
  set frb [frame $w.frb]
  grid $frb -row 1 -column 0 -sticky ew -columnspan 2
  grid $frt -row 0 -column 0 -sticky nsew

  grid $vsb -row 0 -column 1 -sticky ns
  grid $hsb -row 1 -column 0 -sticky ew
  grid $tbl -row 0 -column 0 -sticky nsew

  # Add buttons
  set btnone [button $frb.one -text "Button One" -command [list tk_messageBox -message "Tbl: $tbl" -type ok]]
  set btntwo [button $frb.two -text "Button Two" -command [list tblcallback $tbl]]

  grid $btnone -row 0 -column 0 -sticky w
  grid $btntwo -row 0 -column 1 -sticky e

  grid columnconfigure $frt 0 -weight 1
  grid rowconfigure $frt 0 -weight 1
  grid columnconfigure $w 0 -weight 1
  grid rowconfigure $w 0 -weight 1

  return $tbl
 }
 # Function to configure widget at edit start
 proc editStartCmd {tbl row col args} {
  puts $args
  set w [$tbl editwinpath]
  if {$col == 2} {  # Assuming column 2 is the combobox
   $w configure -values {"Option1" "Option2" "Option3"}
  }
 }
}


if {[info script] eq $argv0} {

 ttk::frame .fr

 set cols {0 "Col1" right 0 "Col2" left 0 "Col3" center}
 set tbl [ tbllib::newTable .fr $cols]

 $tbl insertlist end  [tbllib::generateLargeList 10 3]
 $tbl configure -width 40
 pack .fr -expand 1 -fill both

 puts [$tbl getcolumn 1]
 puts [$tbl configure -columns]

 if {0} {
  output:
  Item_1_2 Item_2_2 Item_3_2 Item_4_2 Item_5_2 Item_6_2 Item_7_2 Item_8_2 Item_9_2 Item_10_2
  -columns columns Columns {} {0 Col1 right 0 Col2 left 0 Col3 center}
 }

}