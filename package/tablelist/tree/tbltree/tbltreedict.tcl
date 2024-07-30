#! /usr/bin/env tclsh

#tbltreedict.tcl
#20240729
# tablelist as tree

namespace eval tbl {
    variable state

    proc isDictAdjusted value {
        if {![catch {dict size $value}]} {
            # Check if the dictionary contains at least one nested dictionary
            foreach {key val} $value {
                if {[isDictAdjusted $val] && [llength $key] <= 1 } {
                    return 1
                } elseif {[llength $key] > 1 }  {
                    return 0
                }
            }
            # If no nested dictionaries are found, check the length condition
            if {[llength $value] > 2 } {
                return 1
            }
        }
        return 0
    }

    # Function to recursively convert a tree into a dictionary
    proc tbltree2dict {tbl node} {
        set result {}
        # Get the children of the current node
        set children [$tbl childkeys $node]
        foreach child $children {
            # Get the text (key and value) of the current child
            set item [$tbl rowcget $child -text]
            set key [lindex $item 0]
            set value [lindex $item 1]
            # Check if the child itself has children
            if {[$tbl childcount $child] > 0} {
                set childDict [tbltree2dict $tbl $child]
                dict set result $key $childDict
            } else {
                dict set result $key $value
            }
        }
        return $result
    }

    # Function to recursively display a dictionary in the tree
    proc dict2tbltree {widget parent dict} {
        foreach {key value} $dict {
            if {[dict exists $dict $key]} {
                set keyValue [dict get $dict $key]
                if {[isDictAdjusted $keyValue]} {
                    set newParent [$widget insertchild $parent end [list $key ""]]
                    dict2tbltree $widget $newParent $keyValue
                } else {
                    $widget insertchild $parent end [list $key $value]
                }
            }
        }
    }

    # mouse selection for move
    #  todo: after, array state for multi selection,
    # Function to set the source index on mouse click
    proc setSourceIndex {W x y} {
        set tbl [tablelist::getTablelistPath $W]
        foreach {tbl x y} [tablelist::convEventFields $W $x $y] {}
        set sourceIndex [$tbl index @$x,$y]
        $tbl selection clear 0 end
        $tbl selection set $sourceIndex
        return $sourceIndex
    }

    # Function to move the element when releasing the mouse button
    proc moveElement {W x y sourceIndex} {
        # after 0 before, after 1 after
        set after 0
        set tbl [tablelist::getTablelistPath $W]
        foreach {tbl x y} [tablelist::convEventFields $W $x $y] {}
        if {$sourceIndex != -1} {
            set newIndex [$tbl index @$x,$y]
            if {$newIndex != $sourceIndex} {
                set sidx $sourceIndex
                set pidx [$tbl parentkey $newIndex]
                set cidx  [expr {$after + [$tbl childindex $newIndex]}]
                $tbl move $sidx $pidx $cidx
                $tbl selection clear 0 end
                $tbl selection set $newIndex
                $tbl activate $newIndex
            }
        }
    }

    # Function to update the selection when dragging
    proc updateSelection {W x y} {
        set tbl [tablelist::getTablelistPath $W]
        foreach {tbl x y} [tablelist::convEventFields $W $x $y] {}
        set newIndex [$tbl index @$x,$y]
        $tbl selection clear 0 end
        $tbl selection set $newIndex
        $tbl activate $newIndex
    }
    # binds
    proc init_moveMBind {tbl} {
        #variable state ;# use as local var
        #for move
        dict set state mouse sourceIndex -1
        bind [$tbl bodytag] <ButtonPress-1>  [namespace code {
            dict set state mouse sourceIndex [setSourceIndex %W %x %y]
        }]
        bind [$tbl bodytag] <ButtonRelease-1> [namespace code {
            moveElement %W %x %y [dict get $state mouse sourceIndex]
            dict set state mouse sourceIndex -1
        }]
        bind [$tbl bodytag] <B1-Motion> [namespace code {
            updateSelection %W %x %y
        }]
    }

    # keyboard binds
    # Function to enable shift mode
    proc activateMoveMode {tbl} {
        variable state
        dict set state $tbl keyboard sourceIndex [$tbl index active]
        $tbl selection clear 0 end
        $tbl selection set [dict get $state $tbl keyboard sourceIndex]
        if {[dict get $state $tbl keyboard sourceIndex] ne ""} {
            dict set state $tbl keyboard isMoving 1
        }
    }

    # Function to move the element
    proc confirmMove {tbl} {
        variable state
        set after 0
        if {[dict get $state $tbl keyboard isMoving]} {
            set newIndex [$tbl index active]
            if {$newIndex != [dict get $state $tbl keyboard sourceIndex]} {
                set sidx [dict get $state $tbl keyboard sourceIndex]
                set pidx [$tbl parentkey $newIndex]
                set cidx  [expr {$after + [$tbl childindex $newIndex]}]
                $tbl move $sidx $pidx $cidx
                $tbl selection clear 0 end
                $tbl selection set $newIndex
                $tbl activate $newIndex
            }
            dict set state $tbl keyboard sourceIndex -1
            dict set state $tbl keyboard isMoving 0
        }
    }

    # Function to cancel the move mode
    proc cancelMove {tbl} {
        variable state
        dict set state $tbl keyboard sourceIndex -1
        dict set state $tbl keyboard isMoving 0
    }

    # keyboard binds
    proc init_moveKBind {tbl} {
        variable state
        dict set state $tbl keyboard sourceIndex -1
        dict set state $tbl keyboard isMoving 0
       
        bind [$tbl bodytag] <Return>  [list [namespace current]::cbKbind %W %K ]
        bind [$tbl bodytag] <Escape> [list [namespace current]::cancelMove $tbl]

        # Arrow key bindings for move mode
        bind [$tbl bodytag] <KeyRelease-Up>  [list
        if {[dict get $state $tbl keyboard isMoving]} {
            set curIndex [$tbl index active]
            if {$curIndex >= 0} {
                set newIndex [expr {$curIndex - 0}]
                $tbl activate $newIndex
                $tbl selection clear 0 end
                $tbl selection set $newIndex
            }
        }
        ]
        bind [$tbl bodytag] <KeyRelease-Down>  [list
        if {[dict get $state $tbl keyboard isMoving]} {
            set curIndex [$tbl index active]
            set itemCount [$tbl size]
            puts ok
            if {$curIndex < [expr {$itemCount - 0}]} {
                set newIndex [expr {$curIndex + 0}]
                $tbl activate $newIndex
                $tbl selection clear 0 end
                $tbl selection set $newIndex
            }
        }
        ]
    }
    proc cbKbind {W K args} {
        variable state
        set tbl [tablelist::getTablelistPath $W]
        switch $K {
            Return {
                if {![dict get $state $tbl keyboard isMoving]} {
                    activateMoveMode $tbl
                } else {
                    confirmMove $tbl
                }
            }
        }

    }

}