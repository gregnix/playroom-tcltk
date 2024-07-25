package require tablelist_tile
package require dicttool

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
tablelist::tablelist .tbl -columns {0 "Key" 1 "Value"} -height 15 -width 50 \
    -treecolumn 0 -treestyle classic

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
        company "OpenAI"
    }
}

# Insert the data into the Tablelist widget, starting at the root node
insert_dict_into_tree .tbl root $data

# Display the Tablelist widget
pack .tbl -expand yes -fill both
