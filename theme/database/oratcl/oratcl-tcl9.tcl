#!/usr/bin/env tclsh

#  Tcl 8.6.16 and Tcl 9
#   MS Windows
# Oratcl_Init(): Failed loading oci.dll symbols with error 126
#    while executing
# load C:/Tcl/lib/Oratcl4.6.1/Oratcl461.dll
#    (package ifneeded Oratcl 4.6.1" script)
#    invoked from within
# package require Oratcl
# The MSVCR120.dll file is part of the Visual C++ Redistributable
# for Visual Studio 2013 package. To fix the issue, reinstall the
# Microsoft Visual C++ Redistributable 2013 package.
# Linux
# problem with instant client ,Oratcl and a lib
# in oratcl.c is hard-wired to ORACLE_HOME)/lib or ORACLE_LIBRARY
# Tcl 9
# crashes without error message when parsing (oraparse).
# Setting oraconfig $sh utfmode 1 resolves the issue.


# Set the path for the Instant Client before using Oratcl
switch $::tcl_platform(platform) {
    windows {
        set ergPath {C:\\app\\instantclient_19_25}
        set ::env(PATH) "[file nativename $ergPath];$::env(PATH)"
        #set ::env(NLS_LANG) "GERMAN_GERMANY.AL32UTF8"
    }
    unix {
        set env(ORACLE_HOME) "/opt/oracle/instantclient_19_25"
        set env(ORACLE_LIBRARY) [file join $env(ORACLE_HOME) "libclntsh[info sharedlibextension]" ]
    }
}


package require Oratcl

proc oratclinfo {lh sh {output 1}} {
    lappend infoOra "[info nameofexecutable]"
    lappend infoOra "package Oratcl: [package provide Oratcl]"
    lappend infoOra "tcl_platform: $::tcl_platform(os)"
    lappend infoOra "Pointersize (4 -> 32-bit, 8 -> 64-bit): $::tcl_platform(pointerSize)"
    lappend infoOra "patchlevel [info patchlevel]"
    lappend infoOra "orainfo version: [orainfo version]"
    lappend infoOra [orainfo server $lh]
    lappend infoOra "orainfo status [orainfo status $lh]"
    lappend infoOra "logonhandle: [orainfo logonhandle $sh]"
    lappend infoOra "orainfo client [orainfo client]"
    if {$output} {
        puts " Oracle Information"
        puts [join $infoOra \n]
        puts "\n"
    }
    return $infoOra
}

# Login handle: $lh
set lh [oralogon "scott/tiger@(DESCRIPTION=(ADDRESS=(PROTOCOL=TCP)(HOST=oralx)(PORT=1521))(CONNECT_DATA=(SERVICE_NAME=XEPDB1)))"]
#set lh [oralogon "scott/tiger@XEPDB1"]
# Statement handle: $sh
set sh [oraopen $lh]
# Set utfmode; otherwise, Tcl 9.0 crashes without error message
oraconfig $sh utfmode 1

oratclinfo $lh $sh
# SQL Query
set sql {SELECT * FROM v$nls_parameters WHERE parameter LIKE '%CHARACTERSET%'}
puts "sql: $sql"
try {
    puts "Parsing start"
    oraparse $sh $sql
    # Execute statement
    oraexec $sh
    puts "Exec OK!"
    # Fetch results
    puts "\nFetching results:"
    while {[orafetch $sh -datavariable row] == 0} {
        puts $row
    }

} on error {errmsg options} {
    # Error handling
    puts "Error: $errmsg"
    puts "Details: $options"
} finally {
    # Free resources
    if {[info exists sh]} {
        puts [oraclose $sh]
    }
    if {[info exists lh]} {
        puts [oralogoff $lh]
    }
    puts "End"
}


#########
if {0} {
    Output 1
 Oracle Information
/home/greg/opt/Bawt/BawtBuild/Linux/x64/Release/Distribution/opt/Tcl/bin/tclsh9.0
package Oratcl: 4.6.1
tcl_platform: Linux
Pointersize (4 -> 32-bit, 8 -> 64-bit): 8
patchlevel 9.0.1
orainfo version: 4.6.1
Oracle Database 18c Express Edition Release 18.0.0.0.0 - Production
orainfo status 1
logonhandle: oratcl0
orainfo client 19.25.0.0.0


sql: SELECT * FROM v$nls_parameters WHERE parameter LIKE '%CHARACTERSET%'
Parsing start
Exec OK!

Fetching results:
NLS_CHARACTERSET AL32UTF8 3
NLS_NCHAR_CHARACTERSET AL16UTF16 3
0
0
End

    
    
    
    
    
}