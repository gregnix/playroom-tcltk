#! /usr/bin/env tclsh

#20240518

set myList {a b c}
puts $myList

# Attempt to use argument expansion to print elements of 'myList' as separate arguments
set result [catch {puts {*}$myList} error]
puts "result: $result"
puts "error: $error"

# Define a procedure 'cmd' that takes any number of arguments and prints each one on a new line
proc cmd {args} {
    foreach arg $args {
        puts $arg
    }
}
puts \n
# Example of how 'cmd' is called with a string representation that won't be evaluated
puts {cmd a {*}{b [c]} d {*}{$e f {g h}}}
# Call 'cmd' with expanded arguments, showing how the list expansion works in real time
cmd a {*}{b [c]} d {*}{$e f {g h}}
puts \n
# Another example of how 'cmd' would be called with a string representation
puts {cmd a b {[c]} d {$e} f {g h}}
# Actual call to 'cmd' with the arguments manually specified without expansion
cmd a b {[c]} d {$e} f {g h}



if {0} {
  Output:
a b c
result: 1
error: wrong # args: should be "puts ?-nonewline? ?channelId? string"


cmd a {*}{b [c]} d {*}{$e f {g h}}
a
b
[c]
d
$e
f
g h


cmd a b {[c]} d {$e} f {g h}
a
b
[c]
d
$e
f
g h

}
