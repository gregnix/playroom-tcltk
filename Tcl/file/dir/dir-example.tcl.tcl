#!/usr/bin/env tclsh
package require Tcl 8.6
package require dicttool

#!/usr/bin/env tclsh


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
            dict set result $item [get_file_info $item_path]
        }
    }
    
    return $result
}


#example
if {[info script] eq $argv0} {
source printdict.tcl

# Beispielverzeichnis zum Scannen
set dir [file normalize ../../]

# Scanne das Verzeichnis und speichere die Informationen in einem Dictionary
set dir_info [scan_directory $dir]



# Ausgabe des Ergebnisses
print_dict $dir_info

}