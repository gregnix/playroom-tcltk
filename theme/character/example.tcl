
proc decode_unicode {unicode_seq} {
  # Remove the "\u" prefix and convert the remaining hex to a character
  if {[regexp {\\u([0-9a-fA-F]{4})} $unicode_seq -> hex]} {
    return [format "%c" [scan $hex %x]]
  } else {
    return $unicode_seq ;# Return input if it's not a valid Unicode sequence
  }
}
proc hex_to_decimal {hex_value} {
  # Entferne optionales "0x" Präfix
  set clean_hex [string trimleft $hex_value "0x"]
  # Wandle die Hexadezimalzahl in eine Dezimalzahl um
  return [scan $clean_hex %x]
}

# Beispiele
puts [hex_to_decimal "0x1A"]    ;# Gibt 26 aus
puts [hex_to_decimal "F6"]      ;# Gibt 246 aus
puts [hex_to_decimal "0x7F"]    ;# Gibt 127 aus


# Beispiel
puts [decode_unicode "\\u00f6"]  ;# Gibt "ö" aus
puts [decode_unicode "\u00f6"]  ;# Gibt "ö" aus
puts [decode_unicode "Normal"]   ;# Gibt "Normal" aus


puts \u00f6
puts \xf6
puts [encoding convertfrom cp437 \x246]
puts [ encoding system]

puts \u0031
puts \x31
puts [encoding convertfrom cp437 \x31]
puts [encoding system]

