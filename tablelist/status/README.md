Status tablelist

## Example: tablelist-status-test.tcl

### Libs:
+ info-text-tablelist.tcl
+ tloglib.tcl

## Difference x y and X Y
+ tablelist-cellindex-lowerxy.tcl
+ tablelist-cellindex-upperxy.tcl

### Difference between %x %y and %X %Y
#### %x %y: 
These are the local coordinates relative to the widget that triggered the event (%W). For example, if the event occurs in a cell of a tablelist widget, %x %y specifies the coordinates within that cell.

#### %X %Y: 
In contrast, %X %Y represents the coordinates relative to the entire application window or the main window. These coordinates are useful when you need to know the location of an event in relation to the entire application layout, not just within the triggering widget. 
