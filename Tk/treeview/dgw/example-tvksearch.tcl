package require Tk

# tklib .0.8
package require dgw::tvmixins

#https://core.tcl-lang.org/tklib/file?name=modules/treeview/tvmixins.html
#https://chiselapp.com/user/dgroth/repository/tclcode/doc/tip/dgw/tvmixins.html

# demo: tvksearch
dgw::tvfilebrowser [dgw::tvksearch [ttk::treeview .fb]]
pack .fb -side top -fill both -expand yes