package require tdbc::sqlite3
source kvstore.tcl

# Verbindung erstellen
set dbconn [tdbc::sqlite3::connection create db11 "my-database.db"]

# Setup der Datenbank
kvstore::setupDatabase $dbconn

# Setze Key-Value mit Versionierung
puts [kvstore::setKeyValueVersioned $dbconn "project" "Key-Value Store V1"]
puts [kvstore::setKeyValueVersioned $dbconn "project" "Key-Value Store V2"]

# Abfrage bestimmter Versionen
puts "Project Version 1: [kvstore::getKeyVersion $dbconn "project" 1]"
puts "Project Version 2: [kvstore::getKeyVersion $dbconn "project" 2]"

# Neueste Version abfragen
puts "Latest Version: [kvstore::getLatestVersion $dbconn "project"]"

# Setze Key mit Ablaufdatum (TTL 5 Sekunden) und Integer-Typ
puts [kvstore::setKeyValueWithExpire $dbconn "tempKey" 12345 [expr {[clock seconds] + 5}] "INTEGER"]

# Warten und dann abgelaufene Schlüssel entfernen
kvstore::startPeriodicCleanup $dbconn 6000

# Batch-Insert mehrerer Schlüssel mit Datentypen
puts [kvstore::setBatchKeyValue $dbconn [list "key1" "Hello" "TEXT" "key2" 789 "INTEGER" "key3" 45.67 "REAL"]]

# Alle Schlüssel auflisten
puts "All keys: [kvstore::listAllKeys $dbconn]"

# Verbindung schließen
$dbconn close


if {0} {
 /usr/bin/tclsh /home/greg/Project/tcl/2024/thema/database/sqlite/kv-exam002.tcl 


Key-Value pair with version 3 set
Key-Value pair with version 4 set
Project Version 1: Key-Value Store V1
Project Version 2: Key-Value Store V2
Latest Version: 4
Key-Value pair with expiration, metadata, and type set
Batch Key-Value pairs set
All keys: key1 key2 key3 tempKey

Press return to continue

 
}