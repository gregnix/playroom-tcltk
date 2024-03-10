#! /usr/bin/env tclsh

#version 20240310-1130
#https://linux.die.net/man/1/fc-list

set command "fc-list :lang=zh | grep -i '\.ttf'"  
if {[catch {exec sh -c $command} result ]} {
   set fonts leer
} else {
  set fonts $result
}

# Processing the output to find a suitable font
puts $fonts
puts \n\n
foreach font [list DejaVuSansCondensed.ttf simhei.ttf DroidSansFallbackFull.ttf] {
set command "fc-list | grep -i $font"
catch {exec sh -c $command} result errorCode
    puts "search: $font"
    puts "result:  $result"
    puts "errorCode $errorCode \n"
}

if {0} {
  Output;
search: DejaVuSansCondensed.ttf
result:  /usr/share/fonts/truetype/dejavu/DejaVuSansCondensed.ttf: DejaVu Sans,DejaVu Sans Condensed:style=Condensed,Book
errorCode -code 0 -level 0 

search: simhei.ttf
result:  child process exited abnormally
errorCode CHILDSTATUS 25380 1 
}
