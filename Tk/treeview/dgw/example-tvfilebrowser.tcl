package require Tk

# tklib .0.8
package require dgw::tvmixins

#https://core.tcl-lang.org/tklib/file?name=modules/treeview/tvmixins.html
#https://chiselapp.com/user/dgroth/repository/tclcode/doc/tip/dgw/tvmixins.html

# demo: tvfilebrowser
dgw::tvfilebrowser [dgw::tvsortable [dgw::tvksearch [dgw::tvband \
         [ttk::treeview .fb]]] \
        -sorttypes [list Name directory Size real Modified dictionary]]
pack .fb -side top -fill both -expand yes