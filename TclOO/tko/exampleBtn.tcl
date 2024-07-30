package require Tk
package require tko


namespace eval greg {}
tko::widget greg::Btn ::ttk::button -*

::oo::define greg::Btn {
   ::tko_option -comptext {} {} {} {
      if {$tko(-comptext) ne {}} {
         puts "w configure , call option -comptext"
      }
   }

   method info {} {
      my variable tko
      my variable infotko
      puts "method info:"
      puts "info patchlevel: [info patchlevel]"
      puts "configure, cget, invoke, instate, state, identify"
      puts "self: [self] :: self method: [self method] :: self call: [self call]"
      puts "self namespace: [self namespace] :: self next: [self next] :: self class: [self class]"
      puts "\nparray tko:\n"
      puts [parray tko]
   }
}


greg::Btn .btn -text hello -comptext test
pack .btn
puts \n
puts ".btn configure: [.btn configure]\n"
puts [.btn configure -comptext Welt -command [list .btn info]]


if {0} {
w configure , call option -comptext


.btn configure: {-class {} {} {} {}} {-command command Command {} {}} {-compound compound Compound {} {}} {-comptext {} {} {} test} {-cursor cursor Cursor {} {}} {-default default Default normal normal} {-image image Image {} {}} {-padding padding Pad {} {}} {-state state State normal normal} {-style style Style {} {}} {-takefocus takeFocus TakeFocus ttk::takefocus ttk::takefocus} {-text text Text {} hello} {-textvariable textVariable Variable {} {}} {-underline underline Underline -1 -1} {-width width Width {} {}}

w configure , call option -comptext

method info:
info patchlevel: 8.6.14
configure, cget, invoke, instate, state, identify
self: ::.btn :: self method: info :: self call: {{method info ::greg::Btn method}} 0
self namespace: ::oo::Obj41 :: self next:  :: self class: ::greg::Btn

parray tko:

tko(-class)        = 
tko(-command)      = .btn info
tko(-compound)     = 
tko(-comptext)     = Welt
tko(-cursor)       = 
tko(-default)      = normal
tko(-image)        = 
tko(-padding)      = 
tko(-state)        = normal
tko(-style)        = 
tko(-takefocus)    = ttk::takefocus
tko(-text)         = hello
tko(-textvariable) = 
tko(-underline)    = -1
tko(-width)        = 
tko(.)             = .btn
tko(..)            = .btn__tko__
tko(Tko)           = ::oo::Obj40::Tko



}

