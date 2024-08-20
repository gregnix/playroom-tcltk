package require struct::matrix
package require report
package require textutil

proc listToreport {list} {
# list with element 0 as header	
# changes	
# insert: concat{*}
	::report::defstyle resultlist {{n 1}} {
		set templ_d  [lreplace [lreplace \
               [split "[string repeat "  x" [columns]]  " x] \
                0 0 {}] end end {}]
		set templ_tc [lreplace [lreplace \
               [split "[string repeat "  x=x" [columns]]  " x] \
                0 0 {}] end end {}]
		data        set $templ_d
		topdata     set [data get]
		topcapsep   set $templ_tc
		topcapsep   enable
		tcaption    $n
	}
	
	::struct::matrix m
	set thisrow 0
	set rowheader [lindex $list 0]
	foreach x [lrange $list 1 end] {
		set thiscol 0
		if { $thisrow == 0 } {
			set ncols [llength $rowheader]
			m add columns $ncols
			m add row
			foreach col $rowheader {
				m set cell $thiscol $thisrow $col
				incr thiscol
			}
			incr thisrow
			set thiscol 0
		}
		m add row
		foreach col $x {
			m set cell $thiscol $thisrow [::textutil::untabify2 [concat {*}$col] 4]
			incr thiscol
		}
		incr thisrow
		set nrows $thisrow
	}
	::report::report r $ncols style resultlist
	puts [r printmatrix m]
	m destroy
	r destroy
	::report::rmstyle resultlist
}

