for unix and macintosh SYSTEM_TTFONTS as a list
```
set SYSTEM_TTFONTS ""
switch -- $::tcl_platform(platform) {
	windows { set SYSTEM_TTFONTS "[file normalize $::env(SystemRoot)/fonts]" }
	unix { set SYSTEM_TTFONTS [list "/usr/share/fonts" "/usr/local/share/fonts" "~/.fonts"]}
	macintosh {set SYSTEM_TTFONTS [list "/System/Library/Fonts"]}
	default { Error "Missing system path font.\n The platform: $::tc_platform(platform) isn't defined."}
}
```

proc ::tclfpdf::AddFont
```
if  {$uni } {
set ttffilename ""
switch -- $::tcl_platform(platform) {
	windows {
		if {$SYSTEM_TTFONTS!="" && [file exists "$SYSTEM_TTFONTS/$file"]} {
			set ttffilename "$SYSTEM_TTFONTS/$file";
		}  else {
			set ttffilename "$fontpath/$file";
		}
	}
	macintosh -
	unix {
		# $SYSTEM_TTFONTS is a list
		foreach fpath $SYSTEM_TTFONTS {
			if {$fpath!="" && [file exists [file join $fpath "truetype" $family $file]]} {
				set ttffilename [file join $fpath "truetype" $family $file]
			} elseif { $fpath!="" && [file exists [file join $fpath  $file]]} {
				set ttffilename [file join $fpath  $file]
			}
		}
		if {$ttffilename == ""} {
			set ttffilename "$fontpath/$file";
		}
	}
}
```
