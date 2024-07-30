#! /usr/bin/env tclsh

#20240524
#tloglib.tcl
# Help Proc
proc tlogwcallback {cmd w args } {
    set result [$cmd $w $args]
    tlog $result
}


proc tlog {message {ts 0} args} {
    set timestamp "[clock format [clock seconds]  -format "%T"]"
    set top .toptlog
    set f $top.ft
    set t $f.t
    if {![winfo exists $top]} {
        toplevel $top
        frame $f
        pack $f -side top -fill both -expand true
        set t [text $f.t -setgrid true -wrap none -width 120 \
    -yscrollcommand "$f.vset set" -xscrollcommand "$f.hset set"]
        scrollbar $f.vset -orient vert -command "$f.t yview"
        scrollbar $f.hset -orient hori -command "$f.t xview"
        pack $f.hset -side bottom -fill x
        pack $f.vset -side right -fill y
        pack $f.t -side left -fill both -expand true

        set popupE [menu $t.popupE]
        $popupE add command -label "Ctrl-c" -command [list tk_textCopy $t]
        $popupE add command -label "Ctrl-x" -command [list tk_textCut $t]
        $popupE add command -label "Ctrl-v" -command [list tk_textPaste $t]
        $popupE add command -label "Search Dialog" -command [list searchDialog $t "Die Suche"]
        bind $t <3> [list tk_popup $popupE %X %Y]
        wm geometry $top +0+0
        #wm withdraw .
        #$t insert end "Start tlog\n"

    }

    #    $t insert 1.0 "$message\n"
    switch $ts {

        0 {
            $t mark set insert 1.0
        }
        1 {
            $t insert 1.0 "  i: [$t index insert] c: [$t index current]      $args\n"
            $t mark set insert 1.0
        }
        2 {
            $t insert 1.0 "  i: [$t index insert] c: [$t index current]      Start $timestamp   $args\n"
            $t mark set insert 1.0
        }
        3 {
            $t mark set insert ${ts}.0 
            
            
        }
        4 {
            $t insert 1.0 "  i: [$t index insert] c: [$t index current]      $args\n"
            $t mark set insert 2.0
        }
        5 {
            $t insert 1.0 "  i: [$t index insert] c: [$t index current]      Start $timestamp   $args\n"
            $t mark set insert 2.0
        }
    }
    $t insert insert "$message\n"
    #$t mark set insert [$t index 1.0]
    #return $t
}

proc searchDialog {textw string} {
    set w [toplevel .[clock seconds]]
    wm resizable $w 0 0
    wm title $w "Text search"
    wm transient $w $textw
    wm attribute $w -topmost 1
    label  $w.l -text $string
    entry  $w.e -textvar $w -bg white
    bind $w.e <Return> {set done 1}
    button $w.f     -text Forward    -command [list search_text $textw $w.e forward]
    button $w.b     -text Backwards  -command [list search_text $textw $w.e backwards]
    button $w.close -text Close -command "set $w {}; set done 1"
    grid $w.l  -    -        -sticky news
    grid $w.e  -    -        -sticky news
    grid $w.f $w.b $w.close
    raise $w.e
    focus $w.e
    vwait done
    destroy $w
    set ::$w
}
# Suchfunktion
proc search_text {txtWidget entryWidget direction} {
    set pattern [$entryWidget get]
    if {$pattern eq ""} {
        return
    }
    set length [string length $pattern]
    set pos [$txtWidget index insert]

    if {[string compare $direction "forward"] == 0} {
        set pos [$txtWidget search -forward -nocase -- $pattern $pos end]
        if {$pos != ""} {
            $txtWidget tag remove found 1.0 end
            $txtWidget tag add found $pos "$pos + $length char"
            $txtWidget tag configure found -background yellow
            $txtWidget see $pos
            # Update insert mark to continue search from the end of the found text
            set validNewPos [$txtWidget index "$pos + $length char"]
            $txtWidget mark set insert $validNewPos
        } else {
            # Wenn nichts gefunden, starte von Anfang des Textes
            set pos [$txtWidget search -forward -nocase -- $pattern 1.0 end]
            if {$pos != ""} {
                $txtWidget tag remove found 1.0 end
                $txtWidget tag add found $pos "$pos + $length char"
                $txtWidget tag configure found -background yellow
                $txtWidget see $pos
                set validNewPos [$txtWidget index "$pos + $length char"]
                $txtWidget mark set insert $validNewPos
            }
        }
    } else {
        if {$pos == "1.0"} {
            set pos [$txtWidget search -backwards -nocase -- $pattern end "1.0"]
        } else {
            set pos [$txtWidget search -backwards -nocase -- $pattern $pos "1.0"]
        }
        if {$pos != ""} {
            $txtWidget tag remove found 1.0 end
            $txtWidget tag add found $pos "$pos + $length char"
            $txtWidget tag configure found -background yellow
            $txtWidget see $pos
            # Set insert mark at the beginning of the found text for backward search
            $txtWidget mark set insert $pos
        } else {
            set pos [$txtWidget search -backwards -nocase -- $pattern end "1.0"]
            if {$pos != ""} {
                $txtWidget tag remove found 1.0 end
                $txtWidget tag add found $pos "$pos + $length char"
                $txtWidget tag configure found -background yellow
                $txtWidget see $pos
                # Set insert mark at the beginning of the found text for backward search
                $txtWidget mark set insert $pos
            }
        }
    }
}

