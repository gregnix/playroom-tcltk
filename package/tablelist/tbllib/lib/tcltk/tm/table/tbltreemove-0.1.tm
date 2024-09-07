#! /usr/bin/env tclsh

#tbltreedict.tcl
#20240729
# tablelist as tree

namespace eval tbl {
    variable state

    # mouse selection for move
    #  todo: after, array state for multi selection,
    # Function to set the source index shift and  mouse click
    proc setSourceIndex {W x y} {
        variable state
        set tbl [tablelist::getTablelistPath $W]
        foreach {tbl x y} [tablelist::convEventFields $W $x $y] {}
        if {[dict get $state $tbl mouse sourceIndex] ne "-1" } {
          $tbl rowconfigure [dict get $state $tbl mouse sourceIndex] -bg [dict get $state $tbl mouse before bg]
        } 
        dict set state $tbl mouse sourceIndex [$tbl index @$x,$y]
        dict set state $tbl mouse before bg [$tbl rowcget [dict get $state $tbl mouse sourceIndex] -bg]
        $tbl rowconfigure [dict get $state $tbl mouse sourceIndex] -bg LightSAlmon4
        $tbl selection clear 0 end
        $tbl selection set [dict get $state $tbl mouse sourceIndex]
    }

    # Function to move the element when releasing the mouse button
    proc moveElement {W x y} {
        variable state
        # after 0 before, after 1 after
        set after 0
        set tbl [tablelist::getTablelistPath $W]
        foreach {tbl x y} [tablelist::convEventFields $W $x $y] {}
        if {[dict get $state $tbl mouse sourceIndex] != -1} {
            set newIndex [$tbl index @$x,$y]
            if {$newIndex != [dict get $state $tbl mouse sourceIndex]} {
                $tbl rowconfigure [dict get $state $tbl mouse sourceIndex] -bg [dict get $state $tbl mouse before bg]
                set sidx [dict get $state $tbl mouse sourceIndex]
                set pidx [$tbl parentkey $newIndex]
                set cidx  [expr {$after + [$tbl childindex $newIndex]}]
                $tbl move $sidx $pidx $cidx
                $tbl rowconfigure [expr {$newIndex -1}] -bg [dict get $state $tbl mouse before bg]
                $tbl selection clear 0 end
                $tbl selection set $newIndex
                $tbl activate $newIndex
                dict set state $tbl mouse sourceIndex -1
            }
        }
        catch {$tbl rowconfigure [dict get $state $tbl mouse sourceIndex] -bg [dict get $state $tbl mouse before bg]}
        dict set state $tbl mouse sourceIndex -1
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
        variable state
        #for move
        dict set state $tbl mouse sourceIndex -1
        bind [$tbl bodytag] <Shift-ButtonPress-1>  [namespace code {
            setSourceIndex %W %x %y
        }]
        bind [$tbl bodytag] <ButtonRelease-1> [namespace code {
            moveElement %W %x %y

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