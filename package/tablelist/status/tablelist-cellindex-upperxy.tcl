

#example script:
package require tablelist
proc cmd {tbl W X Y} {
    #difference  x y or X Y
    set x [expr {$X - [winfo rootx $tbl]}]
    set y [expr {$Y - [winfo rooty $tbl]}] 
    
    set ci [$tbl cellindex @$x,$y]
    set cia [$tbl cellindex active]
    set gia [$tbl getcell @$x,$y]
    set ria [$tbl index active]
    set coli [$tbl columnindex @$x,$y]
    puts "$tbl $W $x $y :: cia: $cia  ria: $ria  :: ci $ci :: gia $gia :: coli $coli"
}

tablelist::tablelist .tbl -columns {0 "ID" right 10 "Name" left 0 "Class" center}
#difference  x y or X Y
bind [.tbl bodytag] <Double-1>  [list cmd .tbl %W %X %Y]
pack .tbl -fill both -expand true

.tbl insert end {0 Herbert 0a}
.tbl insert end {1 Anna 1a}
.tbl insert end {2 Lisa 2l}
.tbl insert end {3 Werner 3w}

#Output:
if {0} {
   Output 
.tbl .tbl.body 151 36 :: cia: 0,0  ria: 0  :: ci 0,2 :: gia 0a :: coli 2
.tbl .tbl.body 151 52 :: cia: 1,0  ria: 1  :: ci 1,2 :: gia 1a :: coli 2
.tbl .tbl.body 151 70 :: cia: 2,0  ria: 2  :: ci 2,2 :: gia 2l :: coli 2
.tbl .tbl.body 73 97 :: cia: 3,0  ria: 3  :: ci 3,1 :: gia Werner :: coli 1

}


