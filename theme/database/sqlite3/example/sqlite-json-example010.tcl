package req sqlite3
source report-sqlite.tcl
#https://stackoverflow.com/questions/76980561/a-string-that-represents-an-array-using-list-commands-versus-iterating-through/77068478#77068478

sqlite3 db :memory:

db eval {
    DROP TABLE IF EXISTS demo;
    CREATE TABLE demo(rows json);
    INSERT INTO demo values("{'ofInterest': [5,42,14,9]}");
    SELECT rows->'$.ofInterest' as result from demo LIMIT 1 ;
} {
    puts "BEFORE: '$result'"
}


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


set stmt {
	select *
	FROM demo
;}
puts "stmt $stmt\n "
listToreport  [sqlTolist db $stmt]