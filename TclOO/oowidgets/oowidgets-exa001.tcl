package require Tk
package require oowidgets

namespace eval ::comp {}
oowidgets::widget ::comp::Button {
    constructor {path args} {
          my install ttk::button $path -comptext text
          my configure {*}$args
    }
}

puts [info commands ::comp::*]
set fb1 [comp::button .fb1 -comptext test -width 20 \
    -text "Button1" ]
pack $fb1 -side top -padx 10 -pady 10 -ipady 20 -ipadx 20
puts "1: [$fb1 configure] \n"


oo::define ::comp::Button {
    method configure { args } {
          my variable widget
          my variable widgetOptions
          my variable parentOptions
          if {[llength $args] == 0}  {
              return  [concat [array get parentOptions] [array get widgetOptions]]
              } elseif {[llength $args] == 1}  {
              # return configuration value for this option
              set opt $args
              if { [info exists widgetOptions($opt) ] } {
                  return $widgetOptions($opt)
              } elseif {[info exists parentOptions($opt)]} {
                  return $parentOptions($opt)
              } else {
                  return -code error "# unkown option"
              }
          }
          
          # error checking
          if {[expr {[llength $args]%2}] == 1}  {
              return -code error "value for \"[lindex $args end]\" missing"
          }
          
          # process the new configuration options...
          array set opts $args
          set nargs [list]
          foreach opt [lsort [array names opts]] {
              set val $opts($opt)
              # overwrite with new value
              if { [info exists widgetOptions($opt)] } {
                  set widgetOptions($opt) $val
              } elseif {[info exists parentOptions($opt)]} {
                  lappend nargs $opt
                  lappend nargs $val
                  set parentOptions($opt) $val
              } else {
                  return -code error "unknown configuration option: \"$opt\" specified"
                  
              }
          }
          return [$widget configure {*}$nargs]
      } 
}


set fb2 [comp::button .fb2 -comptext test -width 20 \
    -text "Button2" ]
pack $fb2 -side top -padx 10 -pady 10 -ipady 20 -ipadx 20
puts "2: [$fb2 configure] \n"


if {0} {
    ::comp::Button ::comp::button
1: -comptext {-textvariable {} -text Button1 -class {} -underline -1 -command {} -padding {} -style {} -state normal -image {} -default normal -takefocus ttk::takefocus -compound {} -cursor {} -width 20} test 

2: -textvariable {} -text Button2 -class {} -underline -1 -command {} -padding {} -style {} -state normal -image {} -default normal -takefocus ttk::takefocus -compound {} -cursor {} -width 20 -comptext test 
}
