#!/usr/bin/env tclsh


#202406250600
#todo
#error handling
#multiple argument as new arg

# Option Parsing Function
proc optparse {optionList} {
  # Retrieve arguments of the current command
  set cmdArgs [lrange [dict get [info frame -2] cmd] 1 end]
  set origArgs $cmdArgs
  array set options $optionList
  array set providedOptions {}
  array set unknownOptions {}
  set removeIndices {}
  set warnings {}

  set positionsArgs [transformList $cmdArgs]

  # Identify options and their arguments
  foreach arg $cmdArgs {
    if {[string match "-*" $arg]} {
      # Count the usage of each option
      incr providedOptions($arg)
      # Warning for multiple usage
      if {$providedOptions($arg) > 1} {
        lappend warnings "Warning: Option '$arg' was used multiple times."
        set unknownOptions($arg) {}
      }
      # Warning for unknown option
      if {![info exists options($arg)]} {
        lappend warnings "Warning: Unknown option '$arg' found."
        set unknownOptions($arg) {}
      }
    }
  }

  # Process known options
  foreach option [array names options] {
    if {![info exists providedOptions($option)]} {
      continue
    }
    set pos [lsearch -exact $cmdArgs $option]
    if {$pos >= 0} {
      lappend removeIndices $pos
      if {$pos < [expr {[llength $cmdArgs] - 1}] && ![string match "-*" [lindex $cmdArgs $pos+1]]} {
        set options($option) [lindex $cmdArgs $pos+1]
        lappend removeIndices [expr {$pos + 1}]
      }
    }
  }

  # Remove identified indices from cmdArgs
  foreach idx [lsort -decreasing $removeIndices] {
    set cmdArgs [lreplace $cmdArgs $idx $idx]
  }

  # Count the frequency of each option in providedOptions
  set maxCount 0
  foreach count [array get providedOptions] {
    if {$count > $maxCount} {
      set maxCount $count
    }
  }
  
  for {set optionCount 1} {$optionCount < $maxCount} {incr optionCount} {
    # Process unknown options
    foreach option [array names unknownOptions] {
      if {![info exists providedOptions($option)]} {
        continue
      }
      set pos [lsearch -exact $cmdArgs $option]
      if {$pos >= 0} {
        if {$pos < [expr {[llength $cmdArgs] - 1}] && ![string match "-*" [lindex $cmdArgs $pos+1]]} {
          lappend unknownOptions($option) [lindex $cmdArgs $pos+1]
          set cmdArgs [lreplace $cmdArgs $pos+1 $pos+1]
        }
        set cmdArgs [lreplace $cmdArgs $pos $pos]
        if {$pos != 0 && [string match "-*" [lindex $cmdArgs $pos-1]]} {
          set cmdArgs [linsert $cmdArgs $pos ""]
        }
      }
    }
  }

  # Set the remaining arguments
  set options(positionsArgs) $positionsArgs
  set options(args) $cmdArgs
  set options(providedOptions) [array get providedOptions]
  set options(unknownOptions) [array get unknownOptions]
  set options(warnings) $warnings
  return [array get options]
}

# Helper function to transform the list
proc transformList {originalList} {
  set newList {}
  set index 0
  set position 0

  while {$index < [llength $originalList]} {
    set element [lindex $originalList $index]

    # Check if the element is an option (starts with '-')
    if {[string match "-*" $element]} {
      # Check if the next element exists and does not have '-' (is a value)
      if {[expr {$index + 1 < [llength $originalList]}] && ![string match "-*" [lindex $originalList [expr {$index + 1}]]]} {
        # Option with value
        lappend newList [list $element [lindex $originalList [expr {$index + 1}]]] $position $index
        incr index
      } else {
        # Option without value
        lappend newList [list $element {}] $position $index
      }
    } else {
      # Only value
      lappend newList $element $position $index
    }
    incr index
    incr position
  }

  return $newList
}

# Testing the functions
if {[info script] eq $argv0} {
  proc opttest {args} {
    set optionsArray [optparse {-o 1 -d {} -a {} -variable {}}]
    array set options $optionsArray
    puts "\nargs: $args"
    parray options
    return
  }

  # Test calls
  opttest 1 5 3 4 -o 5 2 8 -n -o 45  17
  opttest -o -n
  opttest 1 2 3 {} 4 5 -o 5
  opttest -d {name mustermann city "New York City"} -oo 7 -o 4 -n - -- -o 9 -o 2 -o {2 7}
  opttest
  opttest -a 1 -o 3 - -- -n -o 1
  opttest -a 2 -o 3 -- - -n -o 1

  # Testing the function with the example
  puts \n
  foreach exampleList {{1 -o 9 -n 7 -u 8 9 7 -u -u 2 2} {-n} {7 8 9} {-o -o -o 8 9 -o}} {
    set transformedList [transformList $exampleList]
    puts $exampleList
    puts $transformedList
  }
}

#Output:
if {0} {


args: 1 5 3 4 -o 5 2 8 -n -o 45 17
options(-a)              = 
options(-d)              = 
options(-o)              = 5
options(-variable)       = 
options(args)            = 1 5 3 4 2 8 17
options(positionsArgs)   = 1 0 0 5 1 1 3 2 2 4 3 3 {-o 5} 4 4 2 5 6 8 6 7 {-n {}} 7 8 {-o 45} 8 9 17 9 11
options(providedOptions) = -o 2 -n 1
options(unknownOptions)  = -o 45 -n {{}}
options(warnings)        = {Warning: Unknown option '-n' found.} {Warning: Option '-o' was used multiple times.}

args: -o -n
options(-a)              = 
options(-d)              = 
options(-o)              = 1
options(-variable)       = 
options(args)            = -n
options(positionsArgs)   = {-o {}} 0 0 {-n {}} 1 1
options(providedOptions) = -o 1 -n 1
options(unknownOptions)  = -n {}
options(warnings)        = {Warning: Unknown option '-n' found.}

args: 1 2 3 {} 4 5 -o 5
options(-a)              = 
options(-d)              = 
options(-o)              = 5
options(-variable)       = 
options(args)            = 1 2 3 {} 4 5
options(positionsArgs)   = 1 0 0 2 1 1 3 2 2 {} 3 3 4 4 4 5 5 5 {-o 5} 6 6
options(providedOptions) = -o 1
options(unknownOptions)  = 
options(warnings)        = 

args: -d {name mustermann city "New York City"} -oo 7 -o 4 -n - -- -o 9 -o 2 -o {2 7}
options(-a)              = 
options(-d)              = name mustermann city "New York City"
options(-o)              = 4
options(-variable)       = 
options(args)            = 
options(positionsArgs)   = {-d {name mustermann city "New York City"}} 0 0 {-oo 7} 1 2 {-o 4} 2 4 {-n {}} 3 6 {- {}} 4 7 {-- {}} 5 8 {-o 9} 6 9 {-o 2} 7 11 {-o {2 7}} 8 13
options(providedOptions) = -o 4 - 1 -d 1 -- 1 -n 1 -oo 1
options(unknownOptions)  = -o {9 2 {2 7}} - {} -- {{}} -n {{}} -oo 7
options(warnings)        = {Warning: Unknown option '-oo' found.} {Warning: Unknown option '-n' found.} {Warning: Unknown option '-' found.} {Warning: Unknown option '--' found.} {Warning: Option '-o' was used multiple times.} {Warning: Option '-o' was used multiple times.} {Warning: Option '-o' was used multiple times.}

args: 
options(-a)              = 
options(-d)              = 
options(-o)              = 1
options(-variable)       = 
options(args)            = 
options(positionsArgs)   = 
options(providedOptions) = 
options(unknownOptions)  = 
options(warnings)        = 

args: -a 1 -o 3 - -- -n -o 1
options(-a)              = 1
options(-d)              = 
options(-o)              = 3
options(-variable)       = 
options(args)            = 
options(positionsArgs)   = {-a 1} 0 0 {-o 3} 1 2 {- {}} 2 4 {-- {}} 3 5 {-n {}} 4 6 {-o 1} 5 7
options(providedOptions) = -o 2 - 1 -- 1 -a 1 -n 1
options(unknownOptions)  = -o 1 - {} -- {} -n {{}}
options(warnings)        = {Warning: Unknown option '-' found.} {Warning: Unknown option '--' found.} {Warning: Unknown option '-n' found.} {Warning: Option '-o' was used multiple times.}

args: -a 2 -o 3 -- - -n -o 1
options(-a)              = 2
options(-d)              = 
options(-o)              = 3
options(-variable)       = 
options(args)            = 
options(positionsArgs)   = {-a 2} 0 0 {-o 3} 1 2 {-- {}} 2 4 {- {}} 3 5 {-n {}} 4 6 {-o 1} 5 7
options(providedOptions) = -o 2 - 1 -- 1 -a 1 -n 1
options(unknownOptions)  = -o 1 - {} -- {{}} -n {{}}
options(warnings)        = {Warning: Unknown option '--' found.} {Warning: Unknown option '-' found.} {Warning: Unknown option '-n' found.} {Warning: Option '-o' was used multiple times.}


1 -o 9 -n 7 -u 8 9 7 -u -u 2 2
1 0 0 {-o 9} 1 1 {-n 7} 2 3 {-u 8} 3 5 9 4 7 7 5 8 {-u {}} 6 9 {-u 2} 7 10 2 8 12
-n
{-n {}} 0 0
7 8 9
7 0 0 8 1 1 9 2 2
-o -o -o 8 9 -o
{-o {}} 0 0 {-o {}} 1 1 {-o 8} 2 2 9 3 4 {-o {}} 4 5
  
}