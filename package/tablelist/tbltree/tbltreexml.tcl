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

proc printDict {dict} {
    foreach {key value} $dict {
        if { [dict is_dict $value]} {
            puts "$key:"
            printDict $value
        } else {
            puts "$key: $value"
        }
    }
}

set fp [open cd_catalog.xml r]
fconfigure $fp -encoding utf-8
set XML [read $fp]
close $fp
dict set data  dataXml [tbl::xml2dict $XML]


set fp [open doc.xml r]
fconfigure $fp -encoding utf-8
set XML [read $fp]
close $fp
puts $XML
dict set data datadcXml [tbl::xml2dict $XML]
printDict [dict get $data datadcXml]


#Output
if {0} {
<?xml version="1.0"?>
<document>
     <title>XML to Tk Canvas</title>
     <heading1>1. First Section</heading1>
     <heading2>1.1 Sub section</heading2>
     <text>This is some text. Here is a
         <quote>quote</quote>
     </text>
     <heading2>1.2 Lists</heading2>
     <text>
      This is a list:
      <list>
          <item>Item one</item>
          <item>The second item</item>
      </list>
      </text>
</document>
0 {XML to Tk Canvas} 1 {1. First Section} 2 {1.1 Sub section} 3 {{This is some text. Here is a
         } quote} 4 {1.2 Lists} 5 {{
      This is a list:
      } {{Item one} {The second item}}}
}