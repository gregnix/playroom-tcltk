package require Tk

# tklib .0.8
package require dgw::tvmixins

#https://core.tcl-lang.org/tklib/file?name=modules/treeview/tvmixins.html
#https://chiselapp.com/user/dgroth/repository/tclcode/doc/tip/dgw/tvmixins.html

# wrapper function 
proc fbrowse {path args} {
     set fb [dgw::tvtooltip [dgw::tvsortable [dgw::tvksearch \
        [dgw::tvfilebrowser [dgw::tvband \
        [ttk::treeview $path]] {*}$args]] \
         -sorttypes [list Name directory Size real Modified dictionary]]]
     return $fb
}
set pw [ttk::panedwindow .pw -orient horizontal]
set f0 [ttk::frame $pw.f]
set f1 [ttk::frame $f0.f]
set fb [fbrowse $f1.fb]
pack $fb -side left -fill both -expand yes
pack [ttk::scrollbar $f1.yscroll -command [list $fb yview]] \
      -side left -fill y -expand false
$fb configure -yscrollcommand [list $f1.yscroll set]
pack $f1 -side top -fill both -expand true
# demo tvtooltip
pack [::ttk::label $f0.msg -font "Times 12 bold" -textvariable ::msg -width 20 \
     -background salmon -borderwidth 2 -relief ridge] \
     -side top -fill x -expand false -ipadx 5 -ipady 4
bind $fb <<RowEnter>> { set ::msg "  Entering row %d"}
bind $fb <<RowLeave>> { set ::msg "  Leaving row %d"}

$pw add $f0
set tree [dgw::tvtree [ttk::treeview $pw.tree -height 15 -show tree -selectmode browse] -icon folder]
foreach txt {first second third} {
   set id [$tree insert {} end -text " $txt item" -open 1]
   for {set i [expr {1+int(rand()*5)}]} {$i > 0} {incr i -1} {
       set child [$tree insert $id 0 -text " child $i"]
       for {set j [expr {int(rand()*3)}]} {$j > 0} {incr j -1} {
          $tree insert $child 0 -text " grandchild $i"
       }
   }
}
$pw add $tree
# another example using mixin syntax
set tv [ttk::treeview $pw.tv -columns "A B C" -show headings]
dgw::mixin $tv dgw::tvsortable

$tv heading A -text A
$tv heading B -text B
$tv heading C -text C
$pw add $tv
for {set i 0} {$i < 20} {incr i} { 
    $tv insert {} end -values [list [expr {rand()*4}] \
        [expr {rand()*10}] [expr {rand()*20}]] 
}
dgw::mixin $tv dgw::tvband
$tv configure  -bandcolors [list white ivory]
pack $pw -side top -fill both -expand true