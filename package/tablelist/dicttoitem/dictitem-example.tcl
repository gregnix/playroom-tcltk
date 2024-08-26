package require Tcl 8.6
package require tablelist_tile
package require ctext

# text window for information
proc createText {w} {
 set frt [ttk::frame $w.frtext]
 set t [ctext $frt.t -setgrid true -wrap word -width 120 \
    -yscrollcommand "$frt.vsb set" -xscrollcommand "$frt.hsb set"]
 set vsb [scrollbar $frt.vsb -orient vertical -command "$t yview"]
 set hsb [scrollbar $frt.hsb -orient horizontal -command "$t xview"]
 pack $hsb -side bottom -fill x
 pack $vsb -side right -fill y
 pack $t -side left -fill both -expand true
 pack $frt -expand yes -fill both
 return $t
}

proc textwins {w text} {
    $w insert end "${text}\n"
}

proc createTbl {w} {
    set frt [ttk::labelframe $w.frtbl ]
    # Create the Tablelist widget
    set tbl [tablelist::tablelist $frt.tbl -columns {
        0 "First Name" left
        0 "Last Name" left
        0 "Age" center
    } -height 15 -width 50 -stripebackground #f0f0f0 ]

    # scrollbar
    set vsb [scrollbar $frt.vsb -orient vertical -command [list $tbl yview]]
    set hsb [scrollbar $frt.hsb -orient horizontal -command [list $tbl xview]]
    $tbl configure -yscroll [list $vsb set] -xscroll [list $hsb set]
    
    $tbl configure -stretch all
    # sort tbl
    $tbl configure -labelcommand tablelist::sortByColumn

    # Configure column names for dictionary mapping
    $tbl columnconfigure 0 -name forename
    $tbl columnconfigure 1 -name surname
    $tbl columnconfigure 2 -name age
    

    # Display the Tablelist widget
    pack $vsb -side right -fill y
    pack $hsb -side bottom -fill x
    pack $tbl -expand yes -fill both
    pack $frt -side top -expand 1 -fill both
    return $tbl

}

ttk::frame .frm
set tbl [createTbl .frm]
set text [createText .frm]
pack .frm -expand 1 -fill both
# Example data as a dictionary
set data {
    0 {forename "John" surname "Doe" age "30"}
    1 {forename "Jane" surname "Smith" age "25"}
    2 {forename "Alice" surname "Johnson" age "40"}
}

textwins $text " data:"
textwins $text $data



# Insert data into the Tablelist
foreach {key personData} $data {
    set item [$tbl dicttoitem $personData]
    $tbl insert end $item
}



# Get full keys (k0, k1, ...) and IDs (0, 1, ...) of the rows
set KeyList [$tbl getfullkeys 0 end]
set IdList  [$tbl getkeys 0 end]

textwins $text "  \$tbl getkeys 0 : [$tbl getkeys 0]"
textwins $text "  \$tbl getfullkeys 0 : [$tbl getfullkeys 0]"
# Sort the table by the third column ("Age") in increasing order
$tbl sortbycolumn 2 -increasing

textwins $text "  #Output the first key after sorting"
textwins $text "  \$tbl getkeys 0 : [$tbl getkeys 0]"
textwins $text "  \$tbl getfullkeys 0 : [$tbl getfullkeys 0]"

textwins $text " foreach rowcget k"
# Iterate over the keys using rowcget
foreach key $KeyList {
    set item [$tbl rowcget $key -text]
    set value [$tbl itemtodict $item]
    textwins $text $value
    dict set data1 [string map {k ""} $key] $value
}
textwins $text $data1

unset data1
textwins $text " foreach rowcget"
# Iterate over the IDs using rowcget
foreach key $IdList {
    set item [$tbl rowcget $key -text]
    set value [$tbl itemtodict $item]
    textwins $text $value
    dict set data1 $key $value
}
textwins $text $data1

unset data1
textwins $text " foreach get k"
# Iterate over the keys using get
foreach key $KeyList {
    set item [$tbl get $key]
    set value [$tbl itemtodict $item]
    textwins $text $value
    dict set data1 [string map {k ""} $key] $value
}
textwins $text $data1

unset data1
textwins $text " foreach get getkeys k"
# Iterate over the keys using get
foreach key $KeyList {
    set item [$tbl get [$tbl getkeys $key]]
    set value [$tbl itemtodict $item]
    textwins $text $value
    dict set data1 [string map {k ""} $key] $value
}
puts $data1

unset data1
textwins $text " foreach get"
# Iterate over the IDs using get
foreach key $IdList {
    set item [$tbl get $key ]
    set value [$tbl itemtodict $item]
    textwins $text $value
    dict set data1 $key $value
}
textwins $text $data1

unset data1

textwins $text "  for "
# Loop through the rows using a for loop
set rowCount [$tbl size]
for {set i 0} {$i < $rowCount} {incr i} {
    set itemData [$tbl get $i]
    set itemDict [$tbl itemtodict $itemData]
    textwins $text $itemDict"
    dict set data1 $i $itemDict
}
textwins $text $data1

unset data1

