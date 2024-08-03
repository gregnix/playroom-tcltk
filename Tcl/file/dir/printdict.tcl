package require dicttool
# Funktion, um ein Dictionary formatiert auszugeben
proc print_dict {dict {indent ""}} {
    foreach {key value} [dict get $dict] {
        if {[dict is_dict $value]} {
            if {$key eq "__info__"} {
                puts "$indent$key:"
                print_dict $value "$indent  "
            } else {
                puts "$indent$key/"
                print_dict $value "$indent  "
            }
        } else {
            puts "$indent$key: $value"
        }
    }
}

