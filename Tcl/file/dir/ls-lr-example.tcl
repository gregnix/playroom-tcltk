proc ls {path} {
   # catch permissions errors
   if {[catch {glob -nocomplain -tails -directory $path *} result]} {
      set result {}
   }
   return $result
}

# recursively builds a nested dict of all files/directories under $path
proc ls-R {path} {
   set result {}
   foreach item [ls $path] {
      if {[file isdirectory [file join $path $item]]} {
         dict set result $item [ls-R [file join $path $item] ]

      } else {
         #dict lappend result $item {}
      }
   }
   return $result
}


#Example
if {[info script] eq $argv0} {
source printdict.tcl


# Beispielverzeichnis zum Scannen
set dir [file normalize ../../../]
set dir [file normalize /erweitert/sicher/greg/]


# Scanne das Verzeichnis und speichere die Informationen in einem Dictionary
set dir_info [ls-R $dir]

# Ausgabe des Ergebnisses
print_dict $dir_info

}