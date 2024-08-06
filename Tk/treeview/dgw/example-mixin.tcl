package require Tk

# tklib .0.8
package require dgw::tvmixins

#https://core.tcl-lang.org/tklib/file?name=modules/treeview/tvmixins.html
#https://chiselapp.com/user/dgroth/repository/tclcode/doc/tip/dgw/tvmixins.html

# demo: mixin
# standard treeview widget
set tv [ttk::treeview .tv -columns "A B C" -show headings]
$tv heading A -text A
$tv heading B -text B
$tv heading C -text C
pack $tv -side top -fill both -expand true
# add  sorting after object creation using the mixin command
dgw::mixin $tv dgw::tvsortable
# fill the widget
for {set i 0} {$i < 20} {incr i} { 
    $tv insert {} end -values [list [expr {rand()*4}] \
        [expr {rand()*10}] [expr {rand()*20}]] 
}
# add another widget adaptor
dgw::mixin $tv dgw::tvband
# configure the new options of this adaptor at a later point
$tv configure  -bandcolors [list white ivory]