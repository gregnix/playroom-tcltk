#! /usr/bin/env tclsh

#20240501
# Procedure to modify dictionaries based on key paths and operations
proc modifyDictionary {dictRef keys {operation {{dictRef key} {return {}}}}} {
  if {[llength $keys] == 1} {
    # If at the last key in the path, perform the operation
    set key [lindex $keys 0]
    set value [apply $operation $dictRef $key]
    dict set dictRef $key $value
  } else {
    # Navigate deeper into the dictionary
    set nextKey [lindex $keys 0]
    if {[dict exists $dictRef $nextKey]} {
      set subDict [dict get $dictRef $nextKey]
    } else {
      # Create a new sub-dictionary if the next key doesn't exist
      set subDict {}
    }
    set subDict [modifyDictionary $subDict [lrange $keys 1 end] $operation]
    dict set dictRef $nextKey $subDict
  }
  return $dictRef
}

# man operation
if {0} {
  # Example operation
  #1
  set operation {{dictRef key} {
      return {New Value}
  }}
  set operation {{dictRef key} {
      if {[catch  {dict get $dictRef $key} currentValue]} {
        set currentValue 0
      }
      return [expr {$currentValue + 10}]
  }}
  #3 replace a value with list
  set operation {{dictRef key} {
      return {1 2 3 4 5}
  }}
  #4 deleting a key by returning null
  set operation {{dictRef key} {
      return {}
  }}
  #5 replace a value with a dictionary
  set operation {{dictRef key} {
      # Returns a new dictionary to replace the current value at the specified key
      return {subKey1 value1 subKey2 value2}
  }}
}


# Main block to test the procedure
if {[info script] eq $argv0} {
  set myDict {
    a {x 1 y 2 z 3} b {x 6 y 5 z 4}
  }
  puts "Original Dictionary:"
  puts $myDict

  #2
  set operation {{dictRef key} {
      if {[catch  {dict get $dictRef $key} currentValue]} {
        set currentValue 0
      }
      return [expr {$currentValue + 10}]
  }}
  #Modify the dictionary based on the specified key path and operation
  set newDict [modifyDictionary $myDict {a z} $operation]
  puts "2.Updated Dictionary:"
  puts $newDict

  #2a
  set operation {{dictRef key} {
      if {[catch  {dict get $dictRef $key} currentValue]} {
        set currentValue 0
      }
      return [expr {$currentValue + 10}]
  }}
  #Modify the dictionary based on the specified key path and operation
  set newDict [modifyDictionary $myDict {c z} $operation]
  puts "2a.Updated Dictionary:"
  puts $newDict
  
  
  #3 replace a value with list and variable
  set [namespace current]::wert 12
  set operation {{dictRef key} {
      return [list 1 2 3 4 [set [namespace current]::wert]]
  }}
  #Modify the dictionary based on the specified key path and operation
  set newDict [modifyDictionary $myDict {c z} $operation]
  puts "3.Updated Dictionary:"
  puts $newDict

  #5 replace a value with a dictionary
  set operation {{dictRef key} {
      # Returns a new dictionary to replace the current value at the specified key
      return {subKey1 value1 subKey2 value2}
  }}
  #Modify the dictionary based on the specified key path and operation
  set newDict [modifyDictionary $myDict {a z} $operation]
  puts "5.Updated Dictionary:"
  puts $newDict
}


if {0} {
  output
Original Dictionary:

    a {x 1 y 2 z 3} b {x 6 y 5 z 4}
  
2.Updated Dictionary:
a {x 1 y 2 z 13} b {x 6 y 5 z 4}
2a.Updated Dictionary:
a {x 1 y 2 z 3} b {x 6 y 5 z 4} c {z 10}
3.Updated Dictionary:
a {x 1 y 2 z 3} b {x 6 y 5 z 4} c {z {1 2 3 4 12}}
5.Updated Dictionary:
a {x 1 y 2 z {subKey1 value1 subKey2 value2}} b {x 6 y 5 z 4}

}
