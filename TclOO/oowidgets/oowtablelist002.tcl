#! /usr/bin/env tclsh

#20241224
#set addlib  [file join [file dirname [info script]] lib]
#set auto_path [linsert $auto_path 0 [file normalize  $addlib]]
package require oowidgets
package require tablelist_tile

namespace eval ::test { }

# changes
oowidgets::widget ::test::Tablelist {
        constructor {path extras args} {
                set stdoptions [list -exportselection false]
                my install ::tablelist::tablelist $path {*}$stdoptions {*}$extras
                my configure {*}$args
        }

        method unknown {method args} {
                my variable widget
                puts "unknown $method $args"
                if {[catch {$widget $method {*}$args} result]} {
                        return -code error $result
                }
                return $result
        }
        method info {args} {
                my variable widgetpath
                my variable widgettype
                my variable parentOptions
                my variable widgetOptions
                my variable widget
                puts "widgetpath $widgetpath"
                puts "widgettype [catch {set widgettype} msg] $msg"
                puts "widget $widget"
                parray parentOptions
                if {[info exists widgetOptions]} {
                        parray widgetOptions
                } else {
                        puts "widgetOptions not exists"
                }
        }
}


#
set tbl [test::tablelist .t1 {-newselction false }  -stripebackground #f0f0f0 -selectmode multiple -columns {0 row left}]
pack $tbl

for {set i 0} {$i < 10 } {incr i} {
  $tbl insert end $i
}

puts [$tbl info]
