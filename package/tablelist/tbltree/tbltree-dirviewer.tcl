#!/usr/bin/env tclsh

package require Tk
package require tablelist_tile
package require dicttool
package require fileutil
set dirname [file dirname [info script]]
source [file join $dirname tbltreedict.tcl]
source [file join $dirname tbltreemove.tcl]

namespace eval tbl {
    # Funktion, um Informationen über eine Datei zu sammeln
    # Funktion, um Informationen über eine Datei oder ein Verzeichnis zu sammeln
    proc get_file_info {path} {
        set info [dict create]
        dict set info size [file size $path]
        dict set info atime [file atime $path]
        dict set info mtime [file mtime $path]
        dict set info type [file type $path]
        dict set info readable [file readable $path]
        dict set info writable [file writable $path]
        dict set info executable [file executable $path]
        dict set info path $path
        #dict set info normalize [file normalize $path]
        #dict set info attrib [file attributes $path]
        #file stat $path stat
        #dict set info stat [array get stat]
        #if {[dict get $info type] eq "file" } {
        #set md5 [md5::md5 -hex -file  $path]
        #dict set info md5 $md5
        #}
        return $info
    }

    # Rekursive Funktion, um die Verzeichnisstruktur zu durchlaufen
    proc scan_directory {dir} {
        set result [dict create]

        # Füge Informationen über das aktuelle Verzeichnis hinzu
        #dict set result __info__ [get_file_info $dir]

        # Durchlaufe alle Dateien und Verzeichnisse im aktuellen Verzeichnis
        foreach item [glob -nocomplain -tails -directory $dir *] {
            set item_path [file join $dir $item]
            if {[file isdirectory $item_path]} {
                # Wenn es ein Verzeichnis ist, rufe die Funktion rekursiv auf
                dict set result $item [scan_directory $item_path]
            } elseif {[file isfile $item_path]} {
                # Wenn es eine Datei ist, sammle die Informationen darüber
        #        dict set result $item __info__ [get_file_info $item_path]
            }
        }
        return $result
    }
}

# Create the Tablelist widget with tree configuration
proc createTbl {w} {
    set frt [ttk::frame $w.frt]
    set tbl [tablelist::tablelist $frt.tbl -columns {0 "Key" 0 "Value" 0 "Detail"} -height 20 -width 0 \
    -stretch all -treecolumn 0 -selectmode single]
    $tbl columnconfigure 0 -name key
    $tbl columnconfigure 1 -name value
    set vsb [scrollbar $frt.vsb -orient vertical -command [list $tbl yview]]
    set hsb [scrollbar $frt.hsb -orient horizontal -command [list $tbl xview]]
    $tbl configure -yscroll [list $vsb set] -xscroll [list $hsb set]

    tbl::init_moveMBind $tbl
    tbl::init_moveKBind $tbl
    pack $vsb -side right -fill y
    pack $hsb -side bottom -fill x
    pack $tbl -expand yes -fill both

    pack $frt -expand yes -fill both
    return $tbl
}

proc main {} {
    dict set data  dir_info [tbl::scan_directory [file normalize ../../]]
    ttk::frame .fr
    pack .fr -side top -expand 1 -fill both

    set tbl [createTbl  .fr]
    tbl::dict2tbltree $tbl root $data
#    tbl::init_moveKBind $tbl
#    tbl::init_moveMBind $tbl
    #puts [tbl::tbltree2dict $tbl root]

}
main


