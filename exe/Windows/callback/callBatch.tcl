#!/usr/bin/env tclsh

set h moin
set w moon
set textoutput ""

#1
set cmd [string map {\\ \\\\} {C:\tmp\program files\testbat.bat}]
set output [exec  $cmd $h $w - hello, world]
puts " [incr i]:"
puts "$output"
append textoutput $i \n $output \n
puts "\n"
unset cmd
unset output

#2
set cmd  {C:\\tmp\\program files\\testbat.bat}
set output [exec  $cmd $h $w - hello, world]
puts " [incr i]:"
puts "$output"
append textoutput $i \n $output \n
puts "\n"
unset cmd
unset output

#3
set cmdpath {C:\\tmp\\program files}
set cmdfile testbat.bat
set cmd [file join $cmdpath $cmdfile]
set output [exec  $cmd $h $w - hello, world]
puts " [incr i]:"
append textoutput $i \n $output \n
puts "$output"
puts "\n"


#4
set cmdpath {C:\\tmp\\program files}
set cmdfile testbat.bat
set cmd [file join $cmdpath $cmdfile]
set output [exec cmd /c  $cmd $h $w - hello, world]
puts " [incr i]:"
append textoutput $i \n $output \n
puts "$output"
puts "\n"


#5
set output [exec  $cmd ]
puts " [incr i]:"
append textoutput $i \n $output \n
puts "$output"
puts "\n"

#
if {[file tail [info nameofexecutable]] eq "wish.exe"} {
text .t
.t insert end $textoutput
pack .t
}