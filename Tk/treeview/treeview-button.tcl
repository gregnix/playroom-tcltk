#!/usr/bin/env tclsh

package require Tk
package require scrollutil_tile
#
# A scrolled listbox widget
#
incr row
set l [ttk::label $cf.l$row -text "Tablelist releases:"]
grid $l -row $row -column 0 -sticky w -padx {7p 0} -pady {7p 0}
incr row
set _sa [scrollutil::scrollarea $cf.sa$row]
set lb [listbox $_sa.lb -width 0]
$_sa setwidget $lb
grid $_sa -row $row -rowspan 6 -column 0 -sticky w -padx {7p 0} -pady {3p 0}

#