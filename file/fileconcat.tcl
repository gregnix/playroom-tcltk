#! /usr/bin/env tclsh

#20240512
#This Tcl script defines a procedure 
#::tcl::file::concat that concatenates two file paths and normalizes the result.
# Idea from
#https://wiki.tcl-lang.org/page/namespace+ensemble
#proc ::tcl::dict::get?

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
set ndir [pwd]
puts $ndir
puts  [file concat /tmp $ndir]

puts "\n"
set ndir ./greg/tmp
puts $ndir
puts  [file concat /tmp $ndir]

}


if {0} {
  Windows Output:
F:/tcltk/project/file
F:/tmp/tcltk/project/file

./greg/tmp
F:/tmp/greg/tmp
  
  Linux Output:
/media/lnet/tcltk/project/file
/tmp/media/lnet/tcltk/project/file

./greg/tmp
/tmp/greg/tmp
}
