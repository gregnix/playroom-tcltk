package require tdbc::sqlite3
source kvstore.tcl

# Verbindung erstellen
set dbconn [tdbc::sqlite3::connection create db11 :memory:]

# Setup der Datenbank
kvstore::setupDatabase $dbconn

# Setze Key-Value-Paare
puts [kvstore::setKeyValue $dbconn "author" "Max Mustermann"]
puts [kvstore::setKeyValueWithExpire $dbconn "project" "Key-Value Store" [clock scan now]]

# Key-Value-Paare abfragen
puts [kvstore::getKeyValue $dbconn "author"]
puts [kvstore::getKeyValue $dbconn "project"]

# Liste aller Keys anzeigen
puts "All keys: [kvstore::listAllKeys $dbconn]"

# Abfrage von Keys mit einem bestimmten Prefix
puts "Keys with prefix 'proj': [kvstore::getKeyWithPrefix $dbconn "proj"]"

# Lösche einen Key
puts [kvstore::deleteKey $dbconn "author"]
puts "All keys after deletion: [kvstore::listAllKeys $dbconn]"

# Abgelaufene Keys entfernen
puts [kvstore::removeExpiredKeys $dbconn]

# Verbindung schließen
$dbconn close



if {0} {

Key-Value pair set
Key-Value pair with expiration, metadata, and type set
Max Mustermann
Key-Value Store
All keys: author project
Keys with prefix 'proj': project {Key-Value Store}
Key deleted
All keys after deletion: project
Expired keys removed

Press return to continue

  
}