#! /usr/bin/env tclsh

# Example table with grid
# 20240510
#
package require Tk
package require tablelist

proc tblCreate {w} {
    set frt  $w.frt
    frame $frt -background "gray"

    # Create table
    set tbl [tablelist::tablelist $frt.tbl -columns {0 "ID" right 0 "Name" left 0 "Class" center} \
    -stretch all  -xscroll [list $frt.h set] -yscroll [list $frt.v set] -labelcommand tablelist::sortByColumn \
    -stripebackground #f0f0f0 -selectmode multiple -exportselection false]

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

proc tblcallback {tbl args} {
    puts "$tbl $args"
    puts [info frame 1]
    puts [info frame -1]
    puts [info frame -2]
}

# Main
# Data list
set liste {{1 Herbert 3a} {4 Anna 7d} {3 Anna 7c} {2 Tim 9t} {5 Birgit 10b} \
{6 Werner 10w} {7 Tom 10t} {8 Suzi 10s} {9 Monika 11m} {10 Ilse 12I} \
{11 Holger 13H} {12 Thomas 67LT} {4 Tim 9t}}

# Create GUI
wm title . "Tablelist with grid Example"
set f .f
grid [frame $f] -row 0 -column 0 -sticky nsew
set tbl [tblCreate $f]
grid columnconfigure . 0 -weight 1
grid rowconfigure . 0  -weight 1

puts "tblInsert  [$tbl insertlist end  $liste]"
focus $tbl
$tbl activate 0



