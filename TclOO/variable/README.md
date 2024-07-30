In TclOO, there are two uses of "variable":

## Inside a method:
- variable varname
- variable varname1 value1 varname2 value2 ...
- my variable varname1 varname2 ..

variable makes varname available within the method and can also initialize it:
### variable
- variable varname value
### my variable
- my variable varname
- set varname value

## In the class definition:
- variable varname1 varname2 ...

this is *comparable*? to `global` in the Tcl core.

## Links
+ https://www.tcl.tk/man/tcl/TclCmd/my.htm
+ https://www.tcl.tk/man/tcl/TclCmd/define.htm#M30
+ https://www.tcl.tk/man/tcl/TclCmd/object.htm#M13
+ https://www.tcl.tk/man/tcl/TclCmd/object.htm#M14
+ https://www.tcl-lang.org/man/tcl/TclCmd/variable.htm
+ https://www.tcl-lang.org/man/tcl/TclCmd/upvar.htm
+ https://www.tcl-lang.org/man/tcl/TclCmd/global.htm
+ https://www.tcl-lang.org/man/tcl/TclCmd/namespace.htm
