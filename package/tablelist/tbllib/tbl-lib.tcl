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

