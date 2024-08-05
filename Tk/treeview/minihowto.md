
    To get the values for an item in the tree you would use the item subcommand of the tree

    set selection [.tree selection]
    set text [.tree item $selection -text]
    
