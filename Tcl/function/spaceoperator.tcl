proc spaceship {a b} {
    if {$a < $b} {
        return -1
    } elseif {$a > $b} {
        return 1
    } else {
        return 0
    }
}

# Beispielaufrufe
puts [spaceship 10 20]  ; # Gibt -1 zurück
puts [spaceship 20 10]  ; # Gibt 1 zurück
puts [spaceship 15 15]  ; # Gibt 0 zurück

