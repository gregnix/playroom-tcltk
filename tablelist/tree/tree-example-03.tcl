package require tablelist_tile
package require dicttool

proc expand_all {} {
    .tbl expandall -fully
}

proc collapse_all {} {
    .tbl collapseall -fully
}

proc cbtree {args} {
    puts "llength args: [llength $args] :: args:  $args]"
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

# Create the Tablelist widget with tree configuration
proc createTree {} {
    set tbl [tablelist::tablelist .tbl -columns {0 "Key" 0 "Value"} -height 15 -width 50 \
    -treecolumn 0 -treestyle classic \
    -collapsecommand [list cbtree "Collapsed: %W"] \
    -expandcommand [list cbtree "Expanded: %W"]]
    return $tbl
}

set tbl [createTree]

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

# Insert the data into the Tablelist widget, starting at the root node
insert_dict_into_tree $tbl root $data

# Display the Tablelist widget
pack $tbl -expand yes -fill both

puts "dict keys: [dict keys $data]"
