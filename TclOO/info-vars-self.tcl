# Define a class with instance variables and methods
oo::class create GlobalLikeClass {
    # Declare instance variables for the class
    variable var1 var2

    constructor {val1 val2} {
        variable var3
        set var3 3
        set var1 $val1
        set var2 $val2
    }

    method showVars {} {
        my variable var1
        variable var2
        variable var3
        puts "Instance variables:"
        puts "var1: $var1"
        puts "var2: $var2"
        puts "var3: $var3"
    }

    method showInfo {} {
        # Info about the class and the object
        puts "Class name: [info object class [self object]]"
        puts "Methods of the class: [info class methods [info object class [self object]] -all]"
        puts "Instance variables of the class: [info class variables [info object class [self object]]]"
        puts "Namespace of the object: [self namespace]"
        puts "Instance variables of the object: [info object vars [self object]]"
    }

    method showVarLocations {} {
        my variable var1
        variable var2
        variable var3
        puts "Namespace details of the variables:"
        puts "var1: [namespace which -variable var1]"
        puts "var2: [namespace which -variable var2]"
        puts "var3: [namespace which -variable var3]"
    }

    method showSelfDetails {} {
        puts "Self Details:"
        puts "Self call: [self call]"
        if {[catch {self caller} result]} {
            puts "Self caller: Not available"
        } else {
            puts "Self caller: $result"
        }
        puts "Self class: [self class]"
        if {[catch {self filter} result]} {
            puts "Self filter: Not available"
        } else {
            puts "Self filter: $result"
        }
        puts "Self method: [self method]"
        puts "Self namespace: [self namespace]"
        puts "Self next: [self next]"
        puts "Self object: [self object]"
        if {[catch {self target} result]} {
            puts "Self target: Not available"
        } else {
            puts "Self target: $result"
        }
    }
}

# Create and use the object
set obj [GlobalLikeClass new 10 20]
puts "Displaying values of the variables:"
$obj showVars
puts ""

puts "Displaying info about the class and the object:"
$obj showInfo
puts ""

puts "Displaying details of the variable namespaces:"
$obj showVarLocations
puts ""

puts "Displaying self details:"
$obj showSelfDetails
puts ""



#outout:
if {0} {

Displaying values of the variables:
Instance variables:
var1: 10
var2: 20
var3: 3

Displaying info about the class and the object:
Class name: ::GlobalLikeClass
Methods of the class: destroy showInfo showSelfDetails showVarLocations showVars
Instance variables of the class: var1 var2
Namespace of the object: ::oo::Obj12
Instance variables of the object: var3 var1 var2

Displaying details of the variable namespaces:
Namespace details of the variables:
var1: ::oo::Obj12::var1
var2: ::oo::Obj12::var2
var3: ::oo::Obj12::var3

Displaying self details:
Self Details:
Self call: {{method showSelfDetails ::GlobalLikeClass method}} 0
Self caller: Not available
Self class: ::GlobalLikeClass
Self filter: Not available
Self method: showSelfDetails
Self namespace: ::oo::Obj12
Self next: 
Self object: ::oo::Obj12
Self target: Not available

    
}
