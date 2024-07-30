# Erzeugung des Objekts inst
oo::object create inst 

# Überprüfen, ob die Methoden m1 und m2 existieren
if {[catch {inst m1} err]} {
    puts "Fehler beim Aufruf von inst m1: $err"
}
if {[catch {inst m2} err]} {
    puts "Fehler beim Aufruf von inst m2: $err"
}

# Erzeugung der Klasse A und Definition der Methode m1
oo::class create A {
    method m1 {} {
        puts "red brick"
    }
}

# Hinzufügen von Klasse A als Mixin zu inst
oo::objdefine inst {
    mixin A
}

# Aufruf der Methode m1 von inst
inst m1

# Überprüfen, ob die Methode m2 existiert
if {[catch {inst m2} err]} {
    puts "Fehler beim Aufruf von inst m2: $err"
}

# Erzeugung der Klasse B und Definition der Methode m2
oo::class create B {
    method m2 {} {
        puts "blue brick"
    }
}

# Hinzufügen von Klasse B als Mixin zu inst
oo::objdefine inst {
    mixin -append B
}

# Aufruf der Methoden m1 und m2 von inst
inst m1
inst m2


if {0} {

Fehler beim Aufruf von inst m1: unknown method "m1": must be destroy
Fehler beim Aufruf von inst m2: unknown method "m2": must be destroy
red brick
Fehler beim Aufruf von inst m2: unknown method "m2": must be destroy or m1
red brick
blue brick
}
