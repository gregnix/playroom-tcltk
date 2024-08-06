package require Tk

# tklib .0.8
package require dgw::tvmixins

#https://core.tcl-lang.org/tklib/file?name=modules/treeview/tvmixins.html
#https://chiselapp.com/user/dgroth/repository/tclcode/doc/tip/dgw/tvmixins.html

# demo: tvband
dgw::tvband [ttk::treeview .fb -columns [list A B C] -show headings]
foreach col [list A B C] { .fb heading $col -text $col }
for {set i 0} {$i < 20} {incr i 1} {
   .fb insert {} end -values [list  [expr {int(rand()*100)}] \
                  [expr {int(rand()*1000)}] [expr {int(rand()*1000)}]]
}
pack .fb -side top -fill both -expand yes