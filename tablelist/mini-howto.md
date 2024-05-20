mini howtos
### col, row, cell
```
set row [$tbl getkeys active]
set col [$tbl columnindex @$x,$y] 
set ci [$tbl cellindex @$x,$y]
```
### index
```
set anchor [$tbl index anchor]
set active [$tbl index active]
set row [$tbl index active]
set top [$tbl index top]
set bottom  [$tbl index bottom]
set end [$tbl index end]
set last [$tbl index last]

```
### getkeys
```
set anchor [$tbl getkeys anchor]
set active [$tbl getkeys active]
set row [$tbl getkeys active]
set top [$tbl getkeys top]
set bottom  [$tbl getkeys bottom]
set end [$tbl getkeys end]
set last [$tbl getkeys last]

```
### x y or X Y
```
lassign [tablelist::convEventFields $W $x $y] tbl x y
```
```
set x [expr {$X - [winfo rootx $tbl]}]
set y [expr {$Y - [winfo rooty $tbl]}] 
```


