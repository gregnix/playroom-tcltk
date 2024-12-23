package require oowidgets
package require tablelist_tile

namespace eval ::test { }
oowidgets::widget ::test::Tablelist {
  constructor {path args} {
    my install ::tablelist::tablelist $path
    my configure {*}$args
  }
}



set tbl [test::tablelist .t  -columns {0 row left}]
pack $tbl

for {set i 0} {$i < 10 } {incr i} {
  $tbl insert end $i
}