#! /usr/bin/env tclsh

# tbltreedict.tcl
# 20240729
# tablelist as tree

namespace eval tbl {
    package require tdom
    package require json
    package require dicttool
    
    # Convert XML formatted data to a Tcl dict
    # @param[in] xml the xml text to convert
    # @return data in xml as a Tcl dict
    proc xml2dict {xml} {
        set root [[dom parse $xml] documentElement]
        set res {}
        set i -1
        foreach node [$root childNodes] {
            lappend res [incr i] [::json::json2dict [$node asJSON]]
        }
        return $res
    }
}

if {1} {
set fp [open cd_catalog.xml r]
fconfigure $fp -encoding utf-8
set XML [read $fp]
close $fp
dict set data  dataXml [tbl::xml2dict $XML]

set fp [open doc.xml r]
fconfigure $fp -encoding utf-8
set XML [read $fp]
close $fp
dict set data datadcXml [tbl::xml2dict $XML]
}


