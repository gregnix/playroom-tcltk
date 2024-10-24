# Beispielnutzung
package require tdbc::sqlite3
source kvstore.tcl

set dbconn [tdbc::sqlite3::connection create db11 :memory:]

# Setup der Datenbank
kvstore::setupDatabase $dbconn

# Key-Value mit Metadaten und TTL setzen
puts [kvstore::setKeyValueWithExpire $dbconn "project" "Key-Value Store" [expr {[clock seconds] + 60}] "User: Admin"]

# Batch-Inserts
puts [kvstore::setBatchKeyValue $dbconn {project "New Key-Value Store" language "Tcl" version "1.0"}]

# Alle Schlüssel auflisten
puts "All keys: [kvstore::listAllKeys $dbconn]"

# Entferne abgelaufene Schlüssel
after 60000 {puts [kvstore::removeExpiredKeys $dbconn]}

$dbconn close


if {0} {

Key-Value pair with expiration and metadata set
Batch Key-Value pairs set
All keys: language project version

Press return to continue

}