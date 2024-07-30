set auto_path [linsert $auto_path 0  [file join [file dirname [info script]] lib ]]
package require Tk
package require oowidgets

proc tlog {{message null} args} {
    set zeitpunkt "[clock format [clock seconds]  -format "%T"]"
    set top .toptlog
    set f $top.ft
    set t $f.t
    if {![winfo exists $top]} {
        toplevel $top
        frame $f
        pack $f -side top -fill both -expand true
        set t [text $f.t -setgrid true -wrap none \
    -yscrollcommand "$f.vset set" -xscrollcommand "$f.hset set"]
        scrollbar $f.vset -orient vert -command "$f.t yview"
        scrollbar $f.hset -orient hori -command "$f.t xview"
        pack $f.hset -side bottom -fill x
        pack $f.vset -side right -fill y
        pack $f.t -side left -fill both -expand true

        set popupE [menu $t.popupE]
        $popupE add command -label "Strg-c" -command [list tk_textCopy $t]
        $popupE add command -label "Strg-x" -command [list tk_textCut $t]
        $popupE add command -label "Strg-v" -command [list tk_textPaste $t]
        bind $t <3> [list tk_popup $popupE %X %Y]

        #wm withdraw .
        $t insert end "Start tlog\n"
    }
    $t insert 1.0 \n \n
    $t insert 1.0 "      Start $zeitpunkt\n"
    $t insert 2.0 "$message\n"
    
    return $t
}


namespace eval ::comp {}
oowidgets::widget ::comp::Button {
    constructor {path args} {
        my install ttk::button $path -comptext text
        my configure {*}$args
    }
}

proc statusbtn {btn} {
    append mesg "  info commands \n[info commands ::comp::*]\n"
    append mesg "  configure  \n[join [$btn configure] \n]\n"
    append mesg "  configure -text  \n[$btn configure -text] \n"
    append mesg "  cget -text \n[$btn cget -text]\n"
    append mesg "  cget -comptext \n[$btn cget -comptext]\n"
    append mesg "  winfo class $btn \n[winfo class $btn]\n"
    append mesg "  winfo class [winfo parent $btn] \n[winfo class [winfo parent $btn]]\n"
    append mesg "  winfo children $btn \n[winfo children $btn]\n"
    append mesg "  info  class call ::comp::Button  \n[info class call ::comp::Button $btn ]\n"
    append mesg "  info body ::comp::button  \n[info body ::comp::button ]\n"
    append mesg "  info frame 3  \n[info frame 3 ]\n"  
    append mesg "  info frame 2  \n[info frame 2 ]\n"    
    append mesg "  info frame 1  \n[info frame 1 ]\n"
    append mesg "  info frame 0  \n[info frame 0 ]\n"
    append mesg "  info frame -1  \n[info frame -1 ]\n"
    append mesg "  info frame -2  \n[info frame -2 ]\n"
    append mesg "  info frame -3  \n[info frame -3 ]\n"  
    
    tlog $mesg
}

tlog
set fb1 [comp::button .fb1 -comptext test -width 20 \
    -text "Button1" -command [list statusbtn .fb1]]
pack $fb1 -side top -padx 10 -pady 10 -ipady 20 -ipadx 20



