package require tablelist_tile
package require dicttool

set dirname [file dirname [info script]]
set libdirname [file join [file dirname [info script]] ]
source [file join $libdirname tloglib.tcl]
catch {source [file join $tablelist::library demos option_tile.tcl]}

proc expand_all {tbl} {
    $tbl expandall -fully
}

proc collapse_all {tbl} {
    $tbl collapseall -fully
}

proc cbtree {input type W args} {
    tlog "$input $type W: $W llength args: [llength $args] :: args:  $args" 0
    set tbl [tablelist::getTablelistPath $W]
    switch $input {
        m {
            if {$type eq "row" } {
                set  y [lindex $args 1 ]
                tlog   [$tbl containing  $y] 0
            } else {
                tlog  "cbtree: type_: $type" 0
            }
        }
    }
}

proc cbdump {tbl} {
    puts "dump"
}

# Function to recursively display a dictionary in the tree
proc insert_dict_into_tree {widget parent dict} {
    foreach {key value} $dict {
        if {[dict exists $dict $key]} {
            set keyValue [dict get $dict $key]
            if {[dict is_dict $keyValue]} {
                # Insert a new node with the key as the label
                set newParent [$widget insertchild $parent end [list $key ""]]
                insert_dict_into_tree $widget $newParent $keyValue
            } else {
                # Insert a leaf with key and value
                $widget insertchild $parent end [list $key $value]
            }
        }
    }
}

# Function to recursively convert a tree into a dictionary
proc tree_to_dict {tbl node} {
    # Create an empty dictionary
    set result {}

    # Get the children of the current node
    set children [$tbl childkeys $node]

    # Iterate over each child
    foreach child $children {
        # Get the text (key and value) of the current child
        set item [$tbl rowcget $child -text]
        set key [lindex $item 0]
        set value [lindex $item 1]

        # Check if the child itself has children
        if {[$tbl childcount $child] > 0} {
            # If so, recursively process the children
            set childDict [tree_to_dict $tbl $child]
            dict set result $key $childDict
        } else {
            # If not, just add the key-value pair
            dict set result $key $value
        }
    }

    return $result
}

# Create the Tablelist widget with tree configuration
proc createTree {w} {
    set frt [ttk::frame $w.frt]
    set tbl [tablelist::tablelist $frt.tbl -columns {0 "Key" 0 "Value"} -height 0 -width 0 \
    -stretch all \
    -treecolumn 0 -treestyle classic \
    -collapsecommand [list cbtree m coll ] \
    -expandcommand [list cbtree m expa ]]
    # Scrollbars
    set vsb [scrollbar $frt.vsb -orient vertical -command [list $tbl yview]]
    set hsb [scrollbar $frt.hsb -orient horizontal -command [list $tbl xview]]
    $tbl configure -yscroll [list $vsb set] -xscroll [list $hsb set]

    pack $vsb -side right -fill y
    pack $hsb -side bottom -fill x
    pack $tbl -expand yes -fill both

    # Add frames
    set frb [frame $w.frb]
    pack $frb -fill x -side bottom -expand 0

    # Add buttons
    set btnone [button $frb.one -text "Button One" -command [list cbdump $tbl ]]
    set btntwo [button $frb.two -text "Button Two" -command [list cbtree  b row  $tbl ]]

    pack $btnone $btntwo -side left

    bind [$tbl bodytag] <Button-1> {cbtree m row %W %x %y}
    bind [$tbl bodytag] <KeyRelease> {cbtree k row %W  %K }
    pack $frt -expand yes -fill both
    return $tbl
}

# Example data
set data {
    person {
        name "John Doe"
        age 30
        address {
            street "123 Main St"
            city "Anytown"
        }
    }
    job {
        title "Developer"
        company "Works"
    }
}

ttk::frame .fr1
ttk::frame .fr2
pack .fr1 .fr2 -side top -expand 1 -fill both
set tbl1 [createTree .fr1]
set tbl2 [createTree .fr2]

# Insert the data into the Tablelist widget, starting at the root node
insert_dict_into_tree $tbl1 root $data
expand_all $tbl1

# Convert the tree back to a dictionary
set convertedData [tree_to_dict $tbl1 root]

# Insert the converted data into another Tablelist widget
insert_dict_into_tree $tbl2 root $convertedData

tlog " " 0
tlog "puts \$data" 0
tlog $data 0
tlog "Converted Dictionary:" 0
tlog $convertedData 0


# Output tlog
if {0} {
person {name {John Doe} age 30 address {street {123 Main St} city Anytown}} job {title Developer company Works}
Converted Dictionary:

    person {
        name "John Doe"
        age 30
        address {
            street "123 Main St"
            city "Anytown"
        }
    }
    job {
        title "Developer"
        company "Works"
    }

puts $data
 
cbtree: type_: expa
m expa W: .fr1.frt.tbl llength args: 1 :: args:  1
cbtree: type_: expa
m expa W: .fr1.frt.tbl llength args: 1 :: args:  4
cbtree: type_: expa
m expa W: .fr1.frt.tbl llength args: 1 :: args:  0
cbtree: type_: expa
m expa W: .fr1.frt.tbl llength args: 1 :: args:  7    
}

