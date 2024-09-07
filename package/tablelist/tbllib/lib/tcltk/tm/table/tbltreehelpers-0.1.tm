#! /usr/bin/env tclsh

#tbltreedict.tcl
#20240729
# tablelist as tree

namespace eval tbl {

    proc printDict {dict} {
        foreach {key value} $dict {
            if { [isDict $value]} {
                puts "$key:"
                printDict $value
            } else {
                puts "$key: $value"
            }
        }
    }

    proc lsD {path} {
        # catch permissions errors
        if {[catch {glob -nocomplain -tails -type d -directory $path *} result]} {
            set result {}
        }
        return $result
    }

    # recursively builds a nested dict of all directories under $path
    proc lsD-R {path {depth 3}} {
        if {$depth eq "0"} {
            return {}
        }
        set result {}
        incr depth -1
        foreach item [lsD $path] {
            #set itemlength [llength $item]
            set res [lsD-R [file join $path $item] $depth]
            #set reslength  [llength $res]
            dict set result $item $res

        }
        return $result
    }

}


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
        dict set info normalize [file normalize $path]
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
        dict set result __info__ [get_file_info $dir]

        # Durchlaufe alle Dateien und Verzeichnisse im aktuellen Verzeichnis
        foreach item [glob -nocomplain -tails -directory $dir *] {
            set item_path [file join $dir $item]
            if {[file isdirectory $item_path]} {
                # Wenn es ein Verzeichnis ist, rufe die Funktion rekursiv auf
                dict set result $item [scan_directory $item_path]
            } elseif {[file isfile $item_path]} {
                # Wenn es eine Datei ist, sammle die Informationen darüber
                dict set result $item __info__ [get_file_info $item_path]
            }
        }

        return $result
    }
}

namespace eval tbl {
    proc dictdir { dir } {
        set d ""
#        file stat $dir fstat
#        foreach item [lsort [array names fstat]] {
#            dict set d [file normalize .] $item $fstat($item)
#        }
        foreach subdir [lsort [glob -directory $dir  -nocomplain -types d "*"]] {
            dict set d {*}[dictdir $subdir]
        }
#        foreach fname [lsort [glob -directory $dir -nocomplain -types f "*"]] {
#            file stat $fname fstat
            # sorted:
#            foreach item [lsort [array names fstat]] {
#                dict set d [file tail $fname] $item $fstat($item)
#            }
            # faster but unsorted:
            # dict set d [file tail $fname] [array get fstat]
#        }
        return [list [file tail $dir]/ $d]
        #return [list ${dir}/ $d]
    }
}