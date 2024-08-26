package require Tcl 8.6
package require tablelist_tile


proc createTbl {} {
    set w  ""
    set frt [ttk::labelframe $w.frt ]
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

set tbl [createTbl]

# Example data as a dictionary
set data {
    0 {forename "John" surname "Doe" age "30"}
    1 {forename "Jane" surname "Smith" age "25"}
    2 {forename "Alice" surname "Johnson" age "40"}
}
puts " data:"
puts $data



# Insert data into the Tablelist
foreach {key personData} $data {
    set item [$tbl dicttoitem $personData]
    $tbl insert end $item
}



# Get full keys (k0, k1, ...) and IDs (0, 1, ...) of the rows
set KeyList [$tbl getfullkeys 0 end]
set IdList  [$tbl getkeys 0 end]

puts "  \$tbl getkeys 0 : [$tbl getkeys 0]"
puts "  \$tbl getfullkeys 0 : [$tbl getfullkeys 0]"
# Sort the table by the third column ("Age") in increasing order
$tbl sortbycolumn 2 -increasing

puts "  #Output the first key after sorting"
puts "  \$tbl getkeys 0 : [$tbl getkeys 0]"
puts "  \$tbl getfullkeys 0 : [$tbl getfullkeys 0]"

puts " foreach rowcget k"
# Iterate over the keys using rowcget
foreach key $KeyList {
    set item [$tbl rowcget $key -text]
    set value [$tbl itemtodict $item]
    puts $value
    dict set data1 [string map {k ""} $key] $value
}
puts $data1

unset data1
puts " foreach rowcget"
# Iterate over the IDs using rowcget
foreach key $IdList {
    set item [$tbl rowcget $key -text]
    set value [$tbl itemtodict $item]
    puts $value
    dict set data1 $key $value
}
puts $data1

unset data1
puts " foreach get k"
# Iterate over the keys using get
foreach key $KeyList {
    set item [$tbl get $key]
    set value [$tbl itemtodict $item]
    puts $value
    dict set data1 [string map {k ""} $key] $value
}
puts $data1

unset data1
puts " foreach get getkeys k"
# Iterate over the keys using get
foreach key $KeyList {
    set item [$tbl get [$tbl getkeys $key]]
    set value [$tbl itemtodict $item]
    puts $value
    dict set data1 [string map {k ""} $key] $value
}
puts $data1

unset data1
puts " foreach get"
# Iterate over the IDs using get
foreach key $IdList {
    set item [$tbl get $key ]
    set value [$tbl itemtodict $item]
    puts $value
    dict set data1 $key $value
}
puts $data1

unset data1

puts "  for "
# Loop through the rows using a for loop
set rowCount [$tbl size]
for {set i 0} {$i < $rowCount} {incr i} {
    set itemData [$tbl get $i]
    set itemDict [$tbl itemtodict $itemData]
    puts $itemDict"
    dict set data1 $i $itemDict
}
puts $data1

unset data1


# Output:
if {0} {
 data:

    0 {forename "John" surname "Doe" age "30"}
    1 {forename "Jane" surname "Smith" age "25"}
    2 {forename "Alice" surname "Johnson" age "40"}

  $tbl getkeys 0 : 0
  $tbl getfullkeys 0 : k0
  #Output the first key after sorting
  $tbl getkeys 0 : 1
  $tbl getfullkeys 0 : k1
 foreach rowcget k
forename John surname Doe age 30
forename Jane surname Smith age 25
forename Alice surname Johnson age 40
0 {forename John surname Doe age 30} 1 {forename Jane surname Smith age 25} 2 {forename Alice surname Johnson age 40}
 foreach rowcget
forename Jane surname Smith age 25
forename John surname Doe age 30
forename Alice surname Johnson age 40
0 {forename Jane surname Smith age 25} 1 {forename John surname Doe age 30} 2 {forename Alice surname Johnson age 40}
 foreach get k
forename John surname Doe age 30
forename Jane surname Smith age 25
forename Alice surname Johnson age 40
0 {forename John surname Doe age 30} 1 {forename Jane surname Smith age 25} 2 {forename Alice surname Johnson age 40}
 foreach get getkeys k
forename Jane surname Smith age 25
forename John surname Doe age 30
forename Alice surname Johnson age 40
0 {forename Jane surname Smith age 25} 1 {forename John surname Doe age 30} 2 {forename Alice surname Johnson age 40}
 foreach get
forename Jane surname Smith age 25
forename John surname Doe age 30
forename Alice surname Johnson age 40
0 {forename Jane surname Smith age 25} 1 {forename John surname Doe age 30} 2 {forename Alice surname Johnson age 40}
  for 
forename Jane surname Smith age 25"
    forename John surname Doe age 30"
forename Alice surname Johnson age 40"
    0 {forename Jane surname Smith age 25} 1 {forename John surname Doe age 30} 2 {forename Alice surname Johnson age 40}

}
