#!/usr/bin/env tclsh
package require Tcl 8.6
package require dicttool

# Funktion, um Informationen über eine Datei zu sammeln
proc get_file_info {file_path} {
    set info [dict create]
    dict set info size [file size $file_path]
    dict set info atime [file atime $file_path]
    dict set info mtime [file mtime $file_path]
    dict set info type [file type $file_path]
    dict set info readable [file readable $file_path]
    dict set info writable [file writable $file_path]
    dict set info executable [file executable $file_path]
    return $info
}

# Rekursive Funktion, um die Verzeichnisstruktur zu durchlaufen
proc scan_directory {dir} {
    set result [dict create]
    
    # Durchlaufe alle Dateien und Verzeichnisse im aktuellen Verzeichnis
    foreach item [glob -nocomplain -directory $dir *] {
        set item_path [file join $dir $item]
        if {[file isdirectory $item_path]} {
            # Wenn es ein Verzeichnis ist, rufe die Funktion rekursiv auf
            dict set result $item [scan_directory $item_path]
        } elseif {[file isfile $item_path]} {
            # Wenn es eine Datei ist, sammle die Informationen darüber
            dict set result $item [get_file_info $item_path]
        }
    }
    
    return $result
}

if {[info script] eq $argv0} {
# Beispielverzeichnis zum Scannen
set dir "/home/greg/Project/github"

# Scanne das Verzeichnis und speichere die Informationen in einem Dictionary
set dir_info [scan_directory $dir]

# Ausgabe des Ergebnisses
puts [dict print $dir_info]
 
}