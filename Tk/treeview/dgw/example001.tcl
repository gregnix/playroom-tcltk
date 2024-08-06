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

set fb [fbrowse .fp2]
pack $fb -side top -fill both -expand yes
pack [::ttk::label .msg -font "Times 12 bold" -textvariable ::msg -width 20 \
     -background salmon -borderwidth 2 -relief ridge] \
     -side top -fill x -expand false -ipadx 5 -ipady 4
bind $fb <<RowEnter>> { set ::msg "  Entering row %d"}
bind $fb <<RowLeave>> { set ::msg "  Leaving row %d"}
