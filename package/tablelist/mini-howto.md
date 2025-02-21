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
# knumber e.q. k0
set number [$tbl getkeys k0]

```
## knumber
```
set knumber [$tbl getfullkeys $row $row]
set knumber k[$tbl getkeys $row $row]
set knumbers [$tbl getfullkeys 0 end]

proc sortKnumber {tbl} {
  set KeyList [$tbl getfullkeys 0 end]
  set OrigKeyList [lsort -dictionary $KeyList]
  set OrigItemList [$tbl get $OrigKeyList]
  $tbl delete 0 end
  $tbl insertlist end $OrigItemList
}
```
### x y or X Y
```
foreach {tbl x y} [tablelist::convEventFields $w $x $y] {}
lassign [tablelist::convEventFields $W $x $y] tbl x y
```
```
set x [expr {$X - [winfo rootx $tbl]}]
set y [expr {$Y - [winfo rooty $tbl]}] 
```
### containing
```
foreach {tbl x y} [tablelist::convEventFields $w $x $y] {}
set row [$tbl containing  $y]
set cell  [$tbl containingcell $x $y]
```

### Event Handling
+ [listbox Binding](https://www.tcl.tk/man/tcl/TkCmd/listbox.htm#M56)
+ [virtual events](https://www.nemethi.de/tablelist/tablelistWidget.html#virtual_events)
+ [DEFAULT AND INDIVIDUAL BINDINGS FOR THE TABLELIST BODY](https://www.nemethi.de/tablelist/tablelistWidget.html#body_bindings)
+ [DEFAULT AND INDIVIDUAL BINDINGS FOR THE HEADER ITEMS](https://www.nemethi.de/tablelist/tablelistWidget.html#header_bindings)
+ [DEFAULT AND INDIVIDUAL BINDINGS FOR THE HEADER LABELS](https://www.nemethi.de/tablelist/tablelistWidget.html#body_bindings)
+ [DEFAULT BINDINGS FOR INTERACTIVE CELL EDITING]()
```
# m mouse k keyboard b button
bind [$tbl bodytag] <Button-1> [list [namespace current]::cbtree m row %W %x %y]]
bind [$tbl bodytag] <KeyRelease> [list [namespace current]::cbtree k row %W %k %K]]
```

### Navigation and Scrolling
```
$tbl see $row
lassign [$tbl yview] top bottom

```

### Managing Selections
```
set rows [$tbl curselection]

$tbl selection clear $pos1 $pos2
$tbl selection set  $pos1 $pos2
$tbl activate $pos



```

### 
```

```

