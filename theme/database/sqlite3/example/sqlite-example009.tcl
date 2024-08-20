package require sqlite3

source report-sqlite.tcl

sqlite3 db :memory:
db eval {
CREATE TABLE something(key text, value text);
INSERT INTO something(key, value)
VALUES('foo', 'foovalue');
INSERT INTO something(key, value)
VALUES('bar', 'barvalue')
}
set thiskey "bar"

puts [db eval "
SELECT value FROM something
WHERE key = '${thiskey}'
"] 

# statement in "stmt" and variable in '' 