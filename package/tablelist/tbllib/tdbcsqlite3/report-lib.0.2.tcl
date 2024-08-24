package require struct::matrix
package require report
package require textutil

puts report

proc dictToListOfLists {dataDict} {
    set rows [dict get $dataDict rows]
    set columns [dict get $dataDict columns]
    set result [list $columns]  

    foreach row $rows {
        lappend result $row
    }
    
    return $result
}

proc dictToTableList {dict} {
    set result [list]
    lappend result [list "Table" "Column" "Type" "Not Null" "Primary Key"]

    foreach tableName [dict keys $dict] {
        foreach columnName [dict keys [dict get $dict $tableName]] {
            set colData [dict get $dict $tableName $columnName]
            set type [dict get $colData type]
            set notnull [dict get $colData notnull]
            set pk [dict get $colData pk]
            lappend result [list $tableName $columnName $type $notnull $pk]
        }
    }
    return $result
}

proc listToreport {list {tw .frtext.text}} {
		if {[llength $list] > 1 } {
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

				if {[winfo exists $tw]} {
						$tw insert end [r printmatrix m]
				} else {
						puts [r printmatrix m]
				}
				m destroy
				r destroy
				::report::rmstyle resultlist
		} else {
				puts $list
		}
}

