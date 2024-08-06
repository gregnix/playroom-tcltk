package require Tk

# tklib .0.8
package require dgw::tvmixins

#https://core.tcl-lang.org/tklib/file?name=modules/treeview/tvmixins.html
#https://chiselapp.com/user/dgroth/repository/tclcode/doc/tip/dgw/tvmixins.html

# demo: tvedit
proc editDone {args} {
      puts "done: $args"
}
pack [dgw::tvedit [ttk::treeview .tv -columns {bool int list} -show {headings} \
   -selectmode extended -yscrollcommand {.sb set}] \
   -edittypes [list bool bool int [list int 0 100]] \
   -editdefault "" -editendcmd editDone] -fill both -expand true -side left

pack [ttk::scrollbar .sb -orient v -command ".tv yview"] -fill y -side left
.tv insert {} end -values {true 15 {Letter B}}
.tv insert {} end -values {true 35 {Letter D}}
for {set i 0} {$i<20} {incr i} {
     .tv insert {} end -values [list true $i {Letter B}]
}
dgw::mixin .tv dgw::tvband