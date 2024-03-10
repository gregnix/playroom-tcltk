#! /usr/bin/env tclsh
#version 20240310-2140
# Recursive function to search for the font file in a directory
proc searchFont {directory pattern} {
    # Search for files matching the pattern
    set files [glob -nocomplain -directory $directory -types {f} *]
    foreach file $files {
        if {[string match $pattern [file tail $file]]} {
            return [file normalize $file]
        }
    }
    # Recursively search in subdirectories
    foreach dir [glob -nocomplain -directory $directory -types {d} *] {
        set result [searchFont $dir $pattern]
        if {$result ne ""} {
            return $result
        }
    }
    return ""
}

# Function to find the font across common directories
proc findFont {fontName} {
    # List of directories to search based on the OS
    set searchDirs [list]
    if {$::tcl_platform(platform) == "windows"} {
        lappend searchDirs "C:/Windows/Fonts"
        # Add more Windows-specific directories if needed
    } elseif {$::tcl_platform(platform) == "unix"} {
        # Try using fc-list first for a faster search
        if {![catch {exec which fc-list}]} {
            set command "fc-list | grep -i $fontName"
            if {![catch {exec sh -c $command} result]} {
                foreach line [split $result "\n"] {
                    if {[string match *$fontName* $line]} {
                        return [string trim [lindex [split $line ":"] 0]]
                    }
                }
            }
        }
        # If fc-list isn't successful, or we're on macOS, use fallback directories
        lappend searchDirs "/usr/share/fonts" "/usr/local/share/fonts" "~/.fonts"
    }

    # Iterate through directories and search for the font
    foreach dir $searchDirs {
        set directory [file normalize $dir]
        if {[file exists $directory]} {
            set fontPath [searchFont $directory $fontName]
            if {$fontPath ne ""} {
                return $fontPath
            }
        }
    }

    # Font not found
    return "not found"
}

# Example usage of the function to search for a specific font
set fontPath [findFont "DejaVuSansCondensed.ttf"]
if {$fontPath ne "not found"} {
    puts "Font found: $fontPath"
} else {
    puts "Font not found."
}



