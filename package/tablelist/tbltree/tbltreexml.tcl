#! /usr/bin/env tclsh

#tbltreedict.tcl
#20240729
# tablelist as tree

namespace eval tbl {

package require tdom
package require json
#https://wiki.tcl-lang.org/page/xml2dict
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
}