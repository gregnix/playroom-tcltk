#! /usr/bin/env tclsh

#20240512
# Idea from
#https://wiki.tcl-lang.org/page/namespace+ensemble
#proc ::tcl::dict::get?

#without fileutil::stripPath
proc ::tcl::file::concat {args} {
  if {[llength $args] != 2} {
        return -code error "This function expects exactly two arguments"
    }
  try {
    file normalize [file join [lindex $args 0] {*}[lrange [file split [lindex $args 1 ]] 1 end]]
  }
}
namespace ensemble configure file -map \
        [dict merge [namespace ensemble configure file -map] {concat ::tcl::file::concat}]


#Example
if {[info script] eq $argv0} {

puts "   [info patchlevel] $tcl_platform(os)"
puts " absolute"
set ndir [pwd]
puts "ndir: $ndir"
puts "file normalize: [file normalize $ndir]"
puts "file split: [file split [file nativename $ndir]]"
puts "file concat  [file concat /tmp $ndir]"

puts "\n  relative"
set ndir ./greg/tmp
puts "ndir: $ndir"
puts "file normalize: [file normalize $ndir]"
puts "file split: [file split [file nativename $ndir]]"
puts "file concat:  [file concat /tmp $ndir]"

puts "\n unc path in windows"
set ndir {\\myserver\files\projects\tcl\info.txt}
puts "ndir: $ndir"
puts "file normalize: [file normalize $ndir]"
puts "file split: [file split [file nativename $ndir]]"
puts "file concat:  [file concat /tmp $ndir]"

puts "\n unc path in windows"
set ndir //myserver/files/projects/tcl/info.txt
puts "ndir: $ndir"
puts "file normalize: [file normalize $ndir]"
puts "file split: [file split [file nativename $ndir]]"
puts "file concat:  [file concat /tmp $ndir]"

puts "\n unc path in windows"
set ndir //myserver/files/projects/tcl/info.txt
puts "ndir: $ndir"
puts "file normalize: [file normalize $ndir]"
puts "file split: [file split [file nativename $ndir]]"
puts "file concat:  [file concat //tmpserver/tmp $ndir]"


#This Tcl script defines a procedure 
#::tcl::file::concat that concatenates two file paths and normalizes the result.
}


if {0} {
  Windows Output:
   8.6.13 Windows NT
 absolute
ndir: F:/tcltk/project/file
file normalize: F:/tcltk/project/file
file split: F:/ tcltk project file
file concat  F:/tmp/tcltk/project/file

  relative
ndir: ./greg/tmp
file normalize: F:/tcltk/project/file/greg/tmp
file split: . greg tmp
file concat:  F:/tmp/greg/tmp

 unc path in windows
ndir: \\myserver\files\projects\tcl\info.txt
file normalize: //myserver/files/projects/tcl/info.txt
file split: //myserver/files projects tcl info.txt
file concat:  F:/tmp/projects/tcl/info.txt

 unc path in windows
ndir: //myserver/files/projects/tcl/info.txt
file normalize: //myserver/files/projects/tcl/info.txt
file split: //myserver/files projects tcl info.txt
file concat:  F:/tmp/projects/tcl/info.txt

 unc path in windows
ndir: //myserver/files/projects/tcl/info.txt
file normalize: //myserver/files/projects/tcl/info.txt
file split: //myserver/files projects tcl info.txt
file concat:  //tmpserver/tmp/projects/tcl/info.txt

  
  Linux Output:
   8.6.14 Linux
 absolute
ndir: /media/lnet/tcltk/project/file
file normalize: /media/lnet/tcltk/project/file
file split: / media lnet tcltk project file
file concat  /tmp/media/lnet/tcltk/project/file

  relative
ndir: ./greg/tmp
file normalize: /media/lnet/tcltk/project/file/greg/tmp
file split: . greg tmp
file concat:  /tmp/greg/tmp

 unc path in windows
ndir: \\myserver\files\projects\tcl\info.txt
file normalize: /media/lnet/tcltk/project/file/\\myserver\files\projects\tcl\info.txt
file split: {\\myserver\files\projects\tcl\info.txt}
file concat:  /tmp

 unc path in windows
ndir: //myserver/files/projects/tcl/info.txt
file normalize: /myserver/files/projects/tcl/info.txt
file split: / myserver files projects tcl info.txt
file concat:  /tmp/myserver/files/projects/tcl/info.txt

 unc path in windows
ndir: //myserver/files/projects/tcl/info.txt
file normalize: /myserver/files/projects/tcl/info.txt
file split: / myserver files projects tcl info.txt
file concat:  /tmpserver/tmp/myserver/files/projects/tcl/info.txt

}
