#!/usr/bin/tclsh

#020240908
# Generates various test data
# as lists of lists
# Also tree data

namespace eval tbllib::testdata {
    # Helper procedure to remove leading zeros from a string
    proc removeLeadingZeros {str} {
        if {$str eq "0"} {
            return "0"
        }
        set result [string trimleft $str 0]
        if {$result == "" } {
            set result 0
        }
        return $result
    }

    # Procedure to generate a list of alphabetic sequences
    proc generateAlphabeticSequence {n {class upper}} {
        set resultList {}
        for {set i 0} {$i < $n} {incr i} {
            set result [numberToAlphabeticString $i $class]
            lappend resultList $result
        }
        return $resultList
    }

    # Helper procedure to convert a number to an alphabetic string
    proc numberToAlphabeticString {num {class upper}} {
        set upper "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        set lower "abcdefghijklmnopqrstuvwxyz"
        set alpha "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        set alnum "0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"
        set number "0123456789"
        set uxnumber "0123456789ABCDEF"
        set lxnumber "0123456789abcdef"
        set bnumber "01"

        # Use the appropriate character class
        upvar 0 $class alphabet

        set base [string length $alphabet]
        set result ""

        while {$num >= 0} {
            set remainder [expr {$num % $base}]
            set result [string index $alphabet $remainder]$result
            set num [expr {$num / $base - 1}]
            if {$num < 0} {break}  ;# To handle the final iteration correctly
        }
        return $result
    }

    # Generates alphanumeric test data with words of minimum and maximum length
    # class: alnum, alpha, upper, lower, number, zeronumber
    # 48-123 all char
    # 48-57: 0-9, 65-90: A-Z, 97-122: a-z
    # list alnum: all characters that should not be used between 48 and 123, if selected alnum
    # list alpha: all characters that should not be used when selecting alnum and no numbers
    # list upper: all characters that should not be used when selecting alnum, no numbers and no lowercase letters
    # list lower: all characters that should not be used when selecting alnum, no numbers and no uppercase letters
    # list number: all characters that should not be used when selecting alnum, no uppercase letters and no lowercase letters
    # list zeronumber: all characters that should not be used when selecting alnum, no uppercase letters, no lowercase letters, and no numbers with leading 0, except for 0
    proc testDataalnum {count {*class alnum} {min 3} {max 10}} {
        # List of non-alphanumeric ASCII codes
        set alnum [list 58 59 60 61 62 63 64 91 92 93 94 95 96]

        # Initialize the character class lists
        set alpha $alnum
        for {set i 48} {$i < 59} {incr i} {
            lappend alpha $i
        }
        set upper $alpha
        for {set i 91} {$i < 123} {incr i} {
            lappend upper $i
        }
        set lower $alpha
        for {set i 65} {$i < 91} {incr i} {
            lappend lower $i
        }
        set number $alnum
        for {set i 60} {$i < 123} {incr i} {
            lappend number $i
        }
        set zeronumber $number

        # Use the appropriate character class
        upvar 0 ${*class} noList

        # Generate the test data
        set resultList {}
        for {set i 0} {$i < $count} {incr i} {
            set string ""
            set length [expr {int(rand() * ($max - $min + 1)) + $min}]
            for {set j 0} {$j < $length} {incr j} {
                set val [expr {int(rand() * 75) + 48}]
                if {$val in $noList} {
                    incr j -1
                    continue
                }
                append string [format %c $val]
            }
            if {${*class} == "number"} {
                lappend resultList [removeLeadingZeros $string]
            } else {
                lappend resultList $string
            }
        }
        return $resultList
    }

    # Generates floating-point, integer, and alphanumeric data
    # date format:
    # {%G-W%V-%u} - ISO week date format
    # {%Y-%m-%d %H:%M:%S} - Standard date-time format
    # {%Y-%m-%dT%T} - ISO 8601 date-time format
    # timepoint: now, 2021-04-02, 2001-02-28T12:15:00
    # timeadd: seconds, minutes, hours, days, weeks, months, or years
    proc testDataOne {count {intmax 100} {timepoint now} {timeadd seconds} {format {%Y-%m-%dT%T}} } {
        set data {}
        set time [clock scan $timepoint]
        for {set i 0} {$i < $count} {incr i} {
            set temp [list]
            lappend temp $i ;# id integer
            lappend temp [numberToAlphabeticString $i upper] ;# id string
            lappend temp [numberToAlphabeticString $i number] ;# id string
            lappend temp [numberToAlphabeticString $i uxnumber] ;# id string
            lappend temp [numberToAlphabeticString $i bnumber] ;# id string
            lappend temp [clock format [expr {$time + $i}] -format $format] ;# id time
            lappend temp [clock format [clock add $time $i $timeadd] -format $format] ;# id time
            lappend temp [clock format [clock add $time [incr j [expr {$i + int(rand() * $intmax)}]] $timeadd] -format $format] ;# random time intervals
            lappend temp [expr {rand()}]
            lappend temp [expr {int(rand() * $intmax)}]
            lappend temp [testDataalnum 1 alnum 3 10]
            lappend temp [testDataalnum 3 alnum 3 5]
            lappend temp [testDataalnum 1 alpha 3 10]
            lappend temp [testDataalnum 1 upper 3 10]
            lappend temp [testDataalnum 1 lower 3 10]
            lappend temp [testDataalnum 1 number 1 3]
            lappend temp [testDataalnum 1 zeronumber 1 3]
            lappend temp [clock format [expr {int(rand() * $time)}] -format $format]
            lappend data $temp
        }
        return $data
    }

    # Similar test data generator with some variations
    proc testDataTwo {count {intmax 100} {timepoint now} {timeadd seconds} {format {%Y-%m-%dT%T}} } {
        set data {}
        set time [clock scan $timepoint]
        for {set i 0} {$i < $count} {incr i} {
            set temp [list]
            lappend temp $i ;# id integer
            lappend temp [numberToAlphabeticString $i upper] ;# id string
            lappend temp [clock format [expr {$time + $i}] -format $format] ;# id time
            lappend temp [expr {[format "%.2f" [expr {rand() * $intmax}]]}] ;# rounded float
            lappend temp [expr {int(rand() * $intmax)}]
            lappend temp [testDataalnum 1 alnum 3 10]
            lappend temp [testDataalnum 1 number 1 3]
            lappend temp [testDataalnum 1 zeronumber 1 3]
            lappend data $temp
        }
        return $data
    }
}


namespace eval tbllib::testdata {
    # Generate example data for the table with a specified number of entries and columns
    proc generateLargeList {numEntries numColumns} {
        set largeList {}
        for {set i 1} {$i <= $numEntries} {incr i} {
            set entry [list]
            for {set j 1} {$j <= $numColumns} {incr j} {
                lappend entry "Item_${i}_${j}"
            }
            lappend largeList $entry
        }
        return $largeList
    }

    # Generate numeric data for the table
    proc generateNumberList {numEntries numColumns} {
        set largeList {}
        for {set i 1} {$i <= $numEntries} {incr i} {
            set entry [list]
            for {set j 1} {$j <= $numColumns} {incr j} {
                lappend entry [expr {$i + $j}]
            }
            lappend largeList $entry
        }
        return $largeList
    }

    # Generate mixed content list
    proc generateMixedContentList {numEntries numColumns} {
        set largeList {}
        set alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        set columnTypes [list]

        # Determine the data type for each column
        for {set j 1} {$j <= $numColumns} {incr j} {
            lappend columnTypes [expr {int(rand() * 3)}]
        }

        # Generate data based on the selected column types
        for {set i 1} {$i <= $numEntries} {incr i} {
            set entry [list]
            for {set j 1} {$j <= $numColumns} {incr j} {
                set randomType [lindex $columnTypes [expr {$j - 1}]]
                switch $randomType {
                    0 {lappend entry [expr {int(rand() * 100)}]}   ;# number
                    1 {
                        set index [expr {int(rand() * [string length $alphabet])}]
                        lappend entry [string index $alphabet $index]
                    }
                    2 {
                        set date [clock add [clock scan "2022-01-01"] [expr {int(rand() * 30)}] days]
                        lappend entry [clock format $date -format "%Y-%m-%d"]
                    }
                }
            }
            lappend largeList $entry
        }
        return $largeList
    }

    # Generate a list of random numbers
    proc generateRandomNumberList {numEntries numColumns} {
        set largeList {}
        for {set i 1} {$i <= $numEntries} {incr i} {
            set entry [list]
            for {set j 1} {$j <= $numColumns} {incr j} {
                lappend entry [expr {int(rand() * 100)}]  ;# Random number between 0 and 100
            }
            lappend largeList $entry
        }
        return $largeList
    }

    # Generate sequential data
    proc generateSequentialList {numEntries numColumns} {
        set largeList {}
        set count 0
        for {set i 1} {$i <= $numEntries} {incr i} {
            set entry [list]
            for {set j 1} {$j <= $numColumns} {incr j} {
                incr count
                lappend entry $count
            }
            lappend largeList $entry
        }
        return $largeList
    }

    # Generate alphanumeric data
    proc generateAlphaNumericList {numEntries numColumns} {
        set largeList {}
        set alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
        for {set i 1} {$i <= $numEntries} {incr i} {
            set entry [list]
            for {set j 1} {$j <= $numColumns} {incr j} {
                set letter [string index $alphabet [expr {rand() * [string length $alphabet]}]]
                set number [expr {int(rand() * 100)}]
                lappend entry "${letter}${number}"
            }
            lappend largeList $entry
        }
        return $largeList
    }

    # Generate date data
    proc generateDateList {numEntries numColumns} {
        set largeList {}
        set baseDate "2022-01-01"
        for {set i 0} {$i < $numEntries} {incr i} {
            set entry [list]
            for {set j 1} {$j <= $numColumns} {incr j} {
                set date [clock add [clock scan $baseDate] [expr {int(rand() * 30)}] days]
                lappend entry [clock format $date -format "%Y-%m-%d"]
            }
            lappend largeList $entry
        }
        return $largeList
    }

    # Generate boolean data
    proc generateBooleanList {numEntries numColumns} {
        set largeList {}
        for {set i 1} {$i <= $numEntries} {incr i} {
            set entry [list]
            for {set j 1} {$j <= $numColumns} {incr j} {
                lappend entry [expr {rand() > 0.5 ? "True" : "False"}]
            }
            lappend largeList $entry
        }
        return $largeList
    }

    # Generate mixed content with fixed types
    proc generateFixedMixedContentList {numEntries numColumns} {
        set largeList {}
        set alphabet "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

        # Define fixed data types for columns
        set columnTypes {0 1 2}  ;# 0 = number, 1 = letter, 2 = date

        # Generate data based on the specified column types
        for {set i 1} {$i <= $numEntries} {incr i} {
            set entry [list]
            for {set j 1} {$j <= $numColumns} {incr j} {
                set randomType [lindex $columnTypes [expr {($j - 1) % [llength $columnTypes]}]]
                switch $randomType {
                    0 {lappend entry [expr {int(rand() * 100)}]}   ;# number
                    1 {
                        set index [expr {int(rand() * [string length $alphabet])}]
                        lappend entry [string index $alphabet $index]
                    }
                    2 {
                        set date [clock add [clock scan "2022-01-01"] [expr {int(rand() * 30)}] days]
                        lappend entry [clock format $date -format "%Y-%m-%d"]
                    }
                }
            }
            lappend largeList $entry
        }
        return $largeList
    }

    # Generate reference list with predefined values
    proc generateReferenceList {numEntries numColumns} {
        set referenceList {}

        # Predefined reference values for columns
        set referenceData {
            {1 A 2022-01-01 "01.01.2022" 1.5 "2022/01/01 12:00" true 1 5}
            {2 B 2022-01-02 "02.01.2022" 3.14 "2022-01-02 14:30" false 0 10}
            {3 C 2022-01-03 "03.01.2022" 9.81 "2022-01-03 09:15" true 1 12}
            {4 D 2022-01-04 "04.01.2022" 12.56 "2022/01/04 08:45" false 0 8}
            {5 E 2022-01-05 "05.01.2022" -15.99 "2022-01-05 10:00" true 1 20}
            {6 F 2022-01-06 "06.01.2022" 38.76 "2022/01/06 07:25" false 0 50}
            {7 G 2022-01-07 "07.01.2022" 42.0 "2022/01/07 16:45" true 1 1}
            {8 H 2022-01-08 "08.01.2022" 54.32 "2022-01-08 11:30" false 0 25}
            {9 I 2022-01-09 "09.01.2022" 54.75 "2022/01/09 13:15" true 1 30}
            {10 J 2022-01-10 "10.01.2022" 60.01 "2022/01/10 09:00" false 0 2}
        }

        # Fill the list with reference values
        for {set i 0} {$i < $numEntries} {incr i} {
            set entry [list]
            for {set j 0} {$j < $numColumns} {incr j} {
                set value [lindex $referenceData [expr {$i % [llength $referenceData]}] $j]
                lappend entry $value
            }
            lappend referenceList $entry
        }

        return $referenceList
    }
}

# Generate hierarchical tree data
namespace eval tbllib::testdata {
    proc generateTreeData {numEntries depth} {
        set treeData {}

        # Helper procedure to create a specific level
        proc createTreeNode {id depth currentDepth} {
            set nodeData [list "Node_${id}" [list "Data_${id}_${currentDepth}" $id ${currentDepth}]]

            # Create children if the depth is not reached
            if {$currentDepth < $depth} {
                set numChildren [expr {int(rand() * 4) + 1}]  ;# Random number of children
                for {set i 0} {$i < $numChildren} {incr i} {
                    lappend nodeData [createTreeNode [incr id] $depth [expr {$currentDepth + 1}]]
                }
            }

            return $nodeData
        }

        # Generate root nodes and their children
        for {set i 0} {$i < $numEntries} {incr i} {
            lappend treeData [createTreeNode $i $depth 1]
        }

        return $treeData
    }
}

if {[info script] eq $argv0} {

    puts "Generating data: [time {set data [tbllib::testdata::testDataOne 1000 100 2001-02-28T12:01:01 seconds]}]"
    # Output random values
    puts "Data length: [llength $data]"
    puts "Range entries: \n[join [lrange $data 0 5] \n]"
    puts "Range entries: \n[join [lrange $data 9 18] \n]"
    puts "Range entries: \n[join [lrange $data 108 113] \n]"
    puts "Range entries: \n[join [lrange $data end-5 end] \n]"

    set data  [tbllib::testdata::generateLargeList 10 3]
    puts $data

    set data  [tbllib::testdata::generateNumberList 10 3]
    puts $data

    set data  [tbllib::testdata::generateReferenceList 10 5]
    puts $data

    set treeData [tbllib::testdata::generateTreeData 5 3]
    puts "Generated Tree Data:"
    puts $treeData
}
