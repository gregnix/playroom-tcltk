replace array with dict in oowidgets.tcl

``` 
arrays replace:

variable parentOptions
variable widgetOptions

method install
nopts

method configure
opts

dict structur
parentOption $opt [list opt $opt dbname $dbname dbclass $dbclass stdvalue $stdvalue value $value]
widgetOption $opt [list opt $opt dbname $dbname dbclass $dbclass stdvalue $stdvalue value $value]

dict set widgetOptions $opt opt [string tolower $opt]
dict set widgetOptions $opt dbname [string range $opt 1 end]
dict set widgetOptions $opt dbclass [string toupper [string range $opt 1 end] 0 ]
dict set widgetOptions $opt stdvalue {}
dict set widgetOptions $opt value [dict get $nopts $opt]
```

+ https://wiki.tcl-lang.org/page/TclOO+Properties
+ 
