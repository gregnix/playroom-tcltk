error msg
```
::tclfpdf::ttf_getCMAP4
debug point ::tclfpdf::ttf_getCMAP4 ekse offset
can't read "offset": no such variable
    while executing
"set $offset [expr ($unichar - $startCount($n)) * 2 + $idRangeOffset($n)]"
    (procedure "::tclfpdf::ttf_getCMAP4" line 41)
    invoked from within
"::tclfpdf::ttf_getCMAP4 $unicode_cmap_offset"
    (procedure "::tclfpdf::ttf_extractInfo" line 242)
    invoked from within
"::tclfpdf::ttf_extractInfo"
    (procedure "ttf_getMetrics" line 27)
    invoked from within
"ttf_getMetrics $ttffile"
    (procedure "AddFont" line 39)
    invoked from within
"AddFont "DejaVu" "" "DejaVuSansCondensed.ttf" 1"
```

after correction of
ttf_font.tcl
proc ::tclfpdf::ttf_getCMAP4

row 1091 and 1092
```
set $offset ...
```
after
```
set offset ...
```
