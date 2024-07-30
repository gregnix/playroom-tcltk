oo::class create GlobalLikeClass {
    # Declare instance variables for the class
    variable var1 var2

    constructor {val1 val2} {
        variable var3 3
        set var1 $val1
        set var2 $val2
    }

    method showVars {} {
        #my variable var1 ;# works also without it
        #variable var2 ;# works also without it
        variable var3 ;# necessary, otherwise error
        puts "nw: [namespace which -variable var1]"
        puts "nc: [namespace current]"
        puts "nt: [namespace tail var1]"
        puts "nw: [namespace which -variable var2]"
        puts "nc: [namespace current]"
        puts "nt: [namespace tail var2]"
        puts "nw: [namespace which -variable var3]"
        puts "nc: [namespace current]"
        puts "nt: [namespace tail var3]"
        return "var1: $var1, var2: $var2, var3: $var3"
    }
}

# Create and use the object
set obj [GlobalLikeClass new 10 20]
puts [$obj showVars] 


if {0} {
nw: ::oo::Obj12::var1
nc: ::oo::Obj12
nt: var1
nw: ::oo::Obj12::var2
nc: ::oo::Obj12
nt: var2
nw: ::oo::Obj12::var3
nc: ::oo::Obj12
nt: var3
var1: 10, var2: 20, var3: 3
}
