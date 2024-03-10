#! /usr/bin/env tclsh
#version 20240310-1130
package require struct::set

#Linux, fc-list 
#https://linux.die.net/man/1/fc-list
proc searchFont {list} {
  if {$::tcl_platform(platform) == "unix" } {
    if {[catch {exec which fc-list} result]} {
      puts "fc-list not install."
      return
    }
  } else {
    puts "no unix"
    return
  }

  set langs $list
  foreach lang $langs {
    set command "fc-list :lang=$lang | grep -i '\.ttf'"
    if {[catch {exec sh -c $command} result]} {
      puts "lang: $lang: no Fonts found"
      set uniqueFonts($lang) [list]
    } else {
      set lines [split $result "\n"]
      set fontsForLang {}
      foreach line $lines {
        lappend fontsForLang $line
      }
      set uniqueFonts($lang) [list]
      set uniqueFonts($lang) [lsort -unique $fontsForLang]
    }
  }
  set commonFonts {}
  set first 1
  foreach lang $langs {
    if {$first} {
      set commonFonts $uniqueFonts($lang)
      set first 0
    } else {
      set commonFonts [::struct::set intersect $commonFonts $uniqueFonts($lang)]
    }
  }
  #proc  to identify the best normal font
  proc findBestRegularFont {fonts} {
    foreach font $fonts {
      if {[string match *":style=Regular"* $font] ||
        [string match *":style=Normal"* $font] ||
        [string match *":style=Book"* $font] ||
      ![string match *":style=Bold"* $font] && ![string match *":style=Italic"* $font]} {
        return $font
      }
    }
    return ""
  }
  set bestRegularFont [findBestRegularFont $commonFonts]
  return [list $bestRegularFont  $commonFonts]
}

set bestFont [lindex [searchFont  [list en el pl pt es ru vi]] 0]
puts $bestFont
set sFont [searchFont  [list zh]]
puts $sFont

