# https://core.tcl-lang.org/tips/doc/trunk/tip/342.md
# https://www.tcl.tk/man/tcl9.0/TclCmd/dict.html
# https://wiki.tcl-lang.org/page/namespace+ensemble

proc ::tcl::dict::getdef {D args} {
     if {[dict exists $D {*}[lrange $args 0 end-1]]} then {
         dict get $D {*}[lrange $args 0 end-1]
     } else {
         lindex $args end
     }
}
namespace ensemble configure dict -map \
        [dict merge [namespace ensemble configure dict -map] {getdef ::tcl::dict::getdef}]

