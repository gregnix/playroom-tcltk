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