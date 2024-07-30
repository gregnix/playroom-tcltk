
Because font descriptions are created a writable folder:
Two additional variables

+ TCLFPDF_USER_FONTPATH
+ fontuserpath

instead of [file join /tmp TCLFPDF fontuser] you could specify another writable folder

a variable from a script to pass the font user path
+ ::tclfpdf_arg_fontpath]



```
variable TCLFPDF_FONTPATH "[file join [file dirname [info script]]]/font"
variable TCLFPDF_USER_FONTPATH "[file join /tmp TCLFPDF fontuser]"
```

```
variable fontuserpath
variable TCLFPDF_USER_FONTPATH
```

in proc ::tclfpdf::Init
```
;# Font path
variable fontpath;
variable TCLFPDF_FONTPATH;
set fontpath $TCLFPDF_FONTPATH;
variable fontuserpath;
variable TCLFPDF_USER_FONTPATH;

if {[isset ::tclfpdf_arg_fontpath]} {
   set fontuserpath [file normalize  $::tclfpdf_arg_fontpath]
} else {
  set fontuserpath $TCLFPDF_USER_FONTPATH;
}
file mkdir $fontuserpath
```

in proc ::tclfpdf::AddFont
```
variable fontuserpath
#set unifilename "$fontpath/[string tolower [file rootname $file]]";
set unifilename [file join $fontuserpath [string tolower [file rootname $file]]
```

