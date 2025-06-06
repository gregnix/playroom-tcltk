if {0} {
colordb – Unified Tcl/Tk Color Name Utility
The colordb module is a Tcl/Tk utility for loading, merging, comparing, and displaying color name data from multiple standard sources, including:
/usr/share/X11/rgb.txt – the traditional X11 color database
colors.tcl – used in the Tk demo directory
colors.n – the Tcl/Tk man page describing symbolic color names

Features
Parses and normalizes color definitions (name, RGB, hex, winfo rgb)
Merges multiple sources into a unified color dictionary
Compares color definitions across systems or formats
Checks whether a color is valid in the current Tk environment

Outputs to:
rgb.txt format (for re-import)
CSV and detailed tables (for analysis)
Interactive GUI using tablelist_tile with live color preview
}

# Initialization of data from all sources
#
# Required files:
# - /usr/share/X11/rgb.txt                    (X11 color list)
# - https://gitlab.freedesktop.org/xorg/app/rgb/raw/master/rgb.txt
# - /usr/local/share/man/mann/colors.n       (Tk manpage color list)
# - ../src/tcktk/tcltk9/tk9.0.0/doc/colors.n (alternative source)
# - $::tk_library/demos/colors.tcl           (Tk demo color list)
# - ../src/tk9.0.0/library/demos/colors.tcl
# 
# 

package provide colordb 0.1
package require Tk
namespace eval colordb {
  variable dRgbTxt {}
  variable dColorsN {}
  variable dmerged {}
  variable lColorsTcl {}
}

# Initialization of data from all sources
 proc colordb::Init {} {
  # /usr/share/X11/rgb.txt
  # https://gitlab.freedesktop.org/xorg/app/rgb/raw/master/rgb.txt
  # /usr/local/share/man/mann/colors.n
  # ../src/tcktk/tcltk9/tk9.0.0/doc/colors.n
  #  $::tk_library demos colors.tcl
  # ../src/tk9.0.0/library/demos/colors.tcl
  variable dRgbTxt
  variable dmerged 
  variable lColorsTcl
  variable dColorsN
  
  set dRgbTxt [[namespace current]::readRgbTxt rgb.txt]
  set dmerged [[namespace current]::readRgbTxt merged.txt]
  set lColorsTcl [[namespace current]::readColorsTcl colors.tcl]
  set dColorsN [[namespace current]::readColorsN colors.n]
}


# Read and parse X11 rgb.txt into a color dict
proc colordb::readRgbTxt {{filePath {}}} {
  if {$filePath eq ""} {
    set filePath /usr/share/X11/rgb.txt
  }
  if {![file exists $filePath]} { return {} }
  set fh [open $filePath r]
  set db {}
  while {[gets $fh line] >= 0} {
    if {[string match {!*} $line]} continue
    set name [lassign $line r g b]
    set hex [format "#%02X%02X%02X" $r $g $b]
    set winfo [expr {[catch {winfo rgb . $name} msg] ? {-1 -1 -1} : $msg}]
    dict set db $name [dict create r $r g $g b $b hex $hex winfo $winfo]
  }
  close $fh
  return $db
}

# Extract color names from colors.tcl demo file
proc colordb::readColorsTcl {{filePath {}}} {
  if {$filePath eq ""} {
    set filePath [file join $::tk_library demos colors.tcl]
  }
  if {![file exists $filePath]} { return {} }
  set fh [open $filePath r]
  set block ""
  set collecting 0
  while {[gets $fh line] >= 0} {
    if {[string match "\$w.frame.list insert*" $line]} {
      set collecting 1
    }
    if {$collecting} {
      append block $line\n
    }
  }
  close $fh
  set block [string map {\\ ""} $block]
  return [lrange $block 3 end]
}

# Parse colors.n man page content into a color dict
proc colordb::readColorsN {{filePath {}}} {
  if {$filePath eq ""} {
    set filePath [file join  /usr/local/share/man/mann/ colors.n]
  }
  if {![file exists $filePath]} { return {} }
  set fh [open $filePath r]

  set collecting 0
  while {[gets $fh line] >= 0} {
    if {[string match "*fBName*" $line]} {
      set collecting 1
      continue
    }
    if {[string match ".DE*" $line]} {
      set collecting 0
    }
    if {$collecting} {
      lassign [lrange $line end-2 end] r g b
      set name [lrange $line 0 end-3]
      set hex [format "#%02X%02X%02X" $r $g $b]
      set winfo [expr {[catch {winfo rgb . $name} msg] ? {-1 -1 -1} : $msg}]
      dict set db $name [dict create r $r g $g b $b hex $hex winfo $winfo]
    }
  }
  close $fh
  return $db
}

# Get color data by name from a dict
proc colordb::getColor {name dvar} {
  if {[dict exists $dvar $name]} {
    return [dict get $dvar $name]
  } else {
    return -code error "unknown color name: $name"
  }
}

# Get hex code from a color name
proc colordb::hex {name} {
  return [dict get [colordb::getColor $name] hex]
}

# Return all valid Tk color names in dict (winfo success)
proc colordb::validNames {dvar} {
  set valid {}
  dict for {name values} $dvar {
    if {[dict get $values winfo] ne "-1 -1 -1"} {
      lappend valid $name
    }
  }
  return $valid
}

# Return all keys in a color dict
proc colordb::allNames {dvar} {
  return [dict keys $dvar]
}

# Check if a color name is valid in Tk
proc colordb::colorExists {color} {
  return [expr {![catch {winfo rgb . $color}]}]
}

# Print formatted color table to terminal
proc colordb::printTableColors {colorName} {
  puts [format "%-20s %-10s %-13s %-15s" "Name" "Hex" "RGB(8bit)" "winfo rgb"]
  puts [string repeat "-" 65]
  foreach name [lsort [dict keys $colorName]] {
    set data [dict get $colorName $name]
    set hex  [dict get $data hex]
    foreach {r g b} [dict get $data winfo] break
    set r8 [expr {int($r / 256)}]
    set g8 [expr {int($g / 256)}]
    set b8 [expr {int($b / 256)}]
    set rgb8 [format "%3d,%3d,%3d" $r8 $g8 $b8]
    puts [format "%-20s %-10s %-13s %-15s" $name $hex $rgb8 "$r $g $b"]
  }
}

# Convert a list of names into a dict with winfo check
proc colordb::listToDict {namelist} {
  set result {}
  foreach name $namelist {
    set winfo [expr {[catch {winfo rgb . $name} msg] ? {-1 -1 -1} : $msg}]
    set hex ""
    dict set result $name [dict create r -1 g -1 b -1 hex $hex winfo $winfo]
  }
  return $result
}

# Merge multiple color dicts into one
proc colordb::mergeDicts args {
  set result {}
  foreach d $args {
    dict for {k v} $d {
      dict set result $k $v
    }
  }
  return $result
}

# Compare two dicts: keys and hex values
proc colordb::compareColorDicts {dictA dictB} {
  set onlyInA {}
  set onlyInB {}
  set inBothDifferent {}

  foreach name [dict keys $dictA] {
    if {![dict exists $dictB $name]} {
      lappend onlyInA $name
    } elseif {[dict get $dictA $name hex] ne [dict get $dictB $name hex]} {
      lappend inBothDifferent $name
    }
  }

  foreach name [dict keys $dictB] {
    if {![dict exists $dictA $name]} {
      lappend onlyInB $name
    }
  }

  return [dict create onlyInA $onlyInA onlyInB $onlyInB different $inBothDifferent]
}

# Compare only keys of two color dicts
proc colordb::compareDictKeys {d1 d2} {
  set onlyIn1 {}
  set onlyIn2 {}
  foreach key [dict keys $d1] {
    if {![dict exists $d2 $key]} {
      lappend onlyIn1 $key
    }
  }
  foreach key [dict keys $d2] {
    if {![dict exists $d1 $key]} {
      lappend onlyIn2 $key
    }
  }
  return [dict create onlyIn1 $onlyIn1 onlyIn2 $onlyIn2]
}
# Save merged color data in rgb.txt-style format (R G B name)
proc colordb::saveMergedToRgbFormat {mergedDict} {
  set os $::tcl_platform(os)
  set fileName "merged.$os.txt"
  set fh [open $fileName w]
  foreach name [lsort [dict keys $mergedDict]] {
    set data [dict get $mergedDict $name]
    set r [dict get $data r]
    set g [dict get $data g]
    set b [dict get $data b]
    puts $fh [format "%3d %3d %3d %s" $r $g $b $name]
  }
  close $fh
}

# Save merged color data in detailed table format (Name, Hex, RGB, winfo)
proc colordb::saveMergedWithWinfo {mergedDict} {
  set os $::tcl_platform(os)
  set fileName "merged.$os.winfo.txt"
  set fh [open $fileName w]
  puts $fh [format "%-20s %-10s %-13s %-15s" "Name" "Hex" "RGB(8bit)" "winfo rgb"]
  puts $fh [string repeat "-" 65]
  foreach name [lsort [dict keys $mergedDict]] {
    set data [dict get $mergedDict $name]
    set hex  [dict get $data hex]
    foreach {r g b} [dict get $data winfo] break
    set r8 [expr {int($r / 256)}]
    set g8 [expr {int($g / 256)}]
    set b8 [expr {int($b / 256)}]
    set rgb8 [format "%3d,%3d,%3d" $r8 $g8 $b8]
    puts $fh [format "%-20s %-10s %-13s %-15s" $name $hex $rgb8 "$r $g $b"]
  }
  close $fh
}

# Save merged color data in CSV format (name,r,g,b,hex,winfo_r,winfo_g,winfo_b)
proc colordb::saveMergedAsCsv {mergedDict} {
  set os $::tcl_platform(os)
  set fileName "merged.$os.csv"
  set fh [open $fileName w]
  puts $fh "name,r,g,b,hex,winfo_r,winfo_g,winfo_b"
  foreach name [lsort [dict keys $mergedDict]] {
    set data [dict get $mergedDict $name]
    set r [dict get $data r]
    set g [dict get $data g]
    set b [dict get $data b]
    set hex [dict get $data hex]
    foreach {wr wg wb} [dict get $data winfo] break
    puts $fh "$name,$r,$g,$b,$hex,$wr,$wg,$wb"
  }
  close $fh
}
# Show merged color data in a tablelist widget
proc colordb::showInTablelist {mergedDict} {
  package require tablelist_tile
  toplevel .colorTable
  set frt  .colorTable.frt
  ttk::frame $frt
  wm title .colorTable "Merged Color Table"
  set tbl [tablelist::tablelist $frt.tbl \
    -columns {0 "Name" left   0 color right 0 "Hex" left  \
    0 r right  0 g right 0 b right 0 winfo right 0 r256 right 0 g256 right 0 b256 right } \
    -width 100 -height 30 -stretch all -stripebackground #f0f0f0 \
    -labelcommand tablelist::sortByColumn \
    -xscroll [list $frt.h set] -yscroll [list $frt.v set] ]

  # add scrollbar
  set vsb [ttk::scrollbar $frt.v -orient vertical -command [list $tbl yview]]
  set hsb [ttk::scrollbar $frt.h -orient horizontal -command [list $tbl xview]]
  pack $vsb -side right -fill y -expand 0
  pack $hsb -side bottom -fill x -expand 0
  pack $tbl -fill both -expand true
  pack $frt -fill both -side top -expand true


  foreach name [lsort [dict keys $mergedDict]] {
    set data [dict get $mergedDict $name]
    set hex  [dict get $data hex]
    set r  [dict get $data r ]
    set g  [dict get $data g ]
    set b  [dict get $data b ]
    set winfo [dict get $data winfo]
    lassign $winfo r256 g256 b256
    expr {$r256 eq "-1" ? [set winfoBool 0]:[set winfoBool 1]}
    $tbl insert end [list $name "" $hex $r $g $b $winfoBool $r256 $g256 $b256]
    $tbl cellconfigure end,1 -background $hex
  }
}



# Example usage and comparison output
if {[info exists ::argv0] && [info script] eq $::argv0} {
colordb::Init
  # Merge rgb.txt and colors.n into one dictionary
  set merged [colordb::mergeDicts  $colordb::dColorsN $colordb::dRgbTxt]

  # Print merged color table to stdout
  colordb::printTableColors $colordb::dmerged

  # Save merged data in rgb.txt, detailed, and CSV formats
  colordb::saveMergedToRgbFormat $merged
  colordb::saveMergedWithWinfo $merged
  colordb::saveMergedAsCsv $merged

  # Show number of entries in each dataset
  puts "colors.tcl: [dict size $colordb::lColorsTcl]"
  puts "rgb.txt:    [dict size $colordb::dRgbTxt]"
  puts "colors.n:   [dict size $colordb::dColorsN]"
  puts "merged:     [dict size $merged]"

  # Compare dictionary keys between rgb.txt and colors.n
  set diff [colordb::compareDictKeys $colordb::dRgbTxt $colordb::dColorsN]
  puts "Only in rgb.txt: [dict get $diff onlyIn1]"
  puts "Only in colors.n: [dict get $diff onlyIn2]"

  # Compare full color definitions (hex values) between rgb.txt and colors.n
  set diff [colordb::compareColorDicts $colordb::dRgbTxt $colordb::dColorsN]
  puts "Only in rgb.txt: [llength [dict get $diff onlyInA]]"
  puts "Names: [dict get $diff onlyInA]"
  puts "Only in colors.n: [llength [dict get $diff onlyInB]]"
  puts "Names: [dict get $diff onlyInB]"
  puts "In both, but different hex: [llength [dict get $diff different]]"
  foreach name [dict get $diff different] {
    puts "$name:"
    puts "  rgb.txt:   [dict get $colordb::dRgbTxt $name hex]"
    puts "  colors.n:  [dict get $colordb::dColorsN $name hex]"
  }

  # Compare colors.tcl names with colors.n
  set dColorsTcl [colordb::listToDict $colordb::lColorsTcl]
  set diff [colordb::compareDictKeys $dColorsTcl $colordb::dColorsN]
  puts "Only in colors.tcl: [dict get $diff onlyIn1]"

  # Check if a specific color name is valid in the current Tk environment
  puts [colordb::colorExists {x11 green}]
  package require tablelist_tile
  colordb::showInTablelist $merged

}