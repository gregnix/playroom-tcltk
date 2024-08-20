package req sqlite3
package require clock::iso8601

package require struct::matrix
package require report
package require textutil

sqlite3 db :memory:

# sqlite app function sqlite saf
#isoWeek iso8601
proc safisoWeek {date} {
	return [clock format [clock::iso8601 parse_date $date] -format "%V"]
}
proc safclocktcl {date args} {
	return [clock format [clock scan $date] -format "[lindex $args 0]" -locale [lindex $args 1]]
}

db function isoWeek safisoWeek
db function clocktcl safclocktcl

proc sqlTolist {db stmt args} {
	if {[llength $args] != "0" && ([llength $args] %2) == 0} {
		dict for {k v } $args  {set $k $v}
	} elseif {([llength $args] %2) != 0}  {
		puts "Bind Error args: $args"
		return error
	}
	$db eval $stmt value {
		set row [list]
		foreach col $value(*) {
			lappend row $value($col)
		}
		lappend rows $row
	}
	set rows [linsert $rows 0 $value(*)]
	return $rows
}

proc listToreport {list} {
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

#create db
set stmt {
	CREATE TABLE daydata (
	day	TEXT NOT NULL DEFAULT (date('now')),
	dayu	TEXT NOT NULL,
	dataint INTEGER NOT NULL,
	datareal REAL NOT NULL,
	note TEXT,
	PRIMARY KEY(day)
	)
;}
db eval $stmt

#Testdata
proc testdata {{days 30}} {
	set sDate  [clock add [clock scan now]  -$days day]
	for {set i 0 } { $i < [expr {2 * $days }]} { incr i } {
		set d0 [clock format [clock add $sDate $i day ] -format "%Y-%m-%dT%H:%M:%S" ]
		set d1 [clock add $sDate $i day ]
		set d2 [expr {int(rand() * 1000)}]
		set d3 [expr rand()]
		set d4 texte
		lappend r [list $d0 $d1 $d2 $d3]
	}
	return $r
}

proc sqltestdata {db stmt data} {
	set s [string last ( $stmt]
	set e	[string last ) $stmt]
	set cols [split [string map {: ""} [string range $stmt $s+1 $e-1]] ","]
	lmap d $data {
		lassign $d {*}$cols
		$db eval $stmt
	}
}

set stmt {
	INSERT INTO daydata VALUES(:day,:dayu,:dataint,:datareal,:note)
;}
sqltestdata db $stmt [testdata 5]

set stmt {
	select *
	FROM daydata
;}
#puts "$stmt\n "
#listToreport [sqlTolist db $stmt]


set stmt {
	select day,
	datetime(day),
	datetime(dayu,'unixepoch','localtime') as dtdayu,
	datetime(unixepoch(day),'unixepoch') as dtday,
	strftime('%Y.%m.%d.%H.%M.%S',	unixepoch(day),'unixepoch') as sday,
	clocktcl(day,'%V %W %U %u %w %A','de') as '%V %W %U %u %w %A'
	FROM daydata
;}
puts "$stmt\n "
listToreport [sqlTolist db $stmt]


