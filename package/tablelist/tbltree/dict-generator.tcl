#!/usr/bin/env tclsh

#https://wiki.tcl-lang.org/page/xml2dict

package require tdom
package require json



## Convert set XML formatted data to a Tcl dict
# use tdom to convert XML to JSON
# use json to convert JSON to dict
# @param[in] xml        the xml text to convert
# returns data in xml as an enumberated dict
proc xml2dict { xml } {
        set root [[dom parse $xml] documentElement]
        set i -1
        foreach node [$root childNodes] { lappend res [incr i] [::json::json2dict [$node asJSON] ] }
        return $res
}

set fp [open cd_catalog.xml r]
set XML [read $fp]
close $fp
set dataXmlExample1 [xml2dict $XML]


