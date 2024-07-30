Tcl 8.6 and Tcl 8.7

https://wiki.tcl-lang.org/page/TclOO+Tricks

+ [Callback](https://wiki.tcl-lang.org/page/TclOO+Tricks#19cfa4dc75b558e7f2372949711e0392d3c8b53fceebf1af216db61a648fa296)
+ mymethod
+ https://github.com/mittelmark/oowidgets
+ https://www.tcl.tk/man/tcl8.7/TclCmd/callback.html
```
proc ::oo::Helpers::callback {method args} {
    list [uplevel 1 {namespace which my}] $method {*}$args
}
proc ::oo::Helpers::mymethod {method args} {
    list [uplevel 1 {namespace which my}] $method {*}$args
}
```

+ classvar
+ https://www.tcl.tk/man/tcl8.7/TclCmd/classvariable.html
```
proc ::oo::Helpers::classvar varName {
  tailcall namespace upvar [info object namespace [uplevel 1 self class]] $varName $varName
}
```
+ tcllib  ooutil
```
proc ::oo::Helpers::classvariable {name args} {
    # Get a reference to the class's namespace
    set ns [info object namespace [uplevel 1 {self class}]]

    # Double up the list of variable names
    set vs [list $name $name]
    foreach v $args {lappend vs $v $v}

    # Lastly, link the caller's local variables to the class's
    # variables
    uplevel 1 [list namespace upvar $ns {*}$vs]
}
```
+ https://www.tcl.tk/man/tcl8.7/TclCmd/my.html
```

```
+ https://github.com/mittelmark/oowidgets
```

proc ::oo::Helpers::myvar {varname} {
    return [uplevel 1 {namespace qualifiers [namespace which my]}]::$varname
}
```
