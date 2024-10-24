namespace eval kvstore {
  namespace export setupDatabase getKeyValue setKeyValue setKeyValueWithExpire removeExpiredKeys listAllKeys getKeyWithPrefix deleteKey setKeyValueVersioned getLatestVersion getKeyVersion watchKey setBatchKeyValue

  package require tdbc::sqlite3

  # Initialisierung und Setup
  # Erstellt die Tabellen config und config_versioned, falls sie nicht existieren
  proc setupDatabase {dbconn} {
    set create_table_sql "CREATE TABLE IF NOT EXISTS config (
            name TEXT PRIMARY KEY, 
            value TEXT, 
            expire INTEGER, 
            metadata TEXT, 
            value_type TEXT)"
    set create_versioned_table_sql "CREATE TABLE IF NOT EXISTS config_versioned (
            name TEXT, 
            value TEXT, 
            version INTEGER, 
            PRIMARY KEY(name, version))"

    set stmt [$dbconn prepare $create_table_sql]
    try {
      $stmt execute
    } finally {
      $stmt close
    }

    set stmt [$dbconn prepare $create_versioned_table_sql]
    try {
      $stmt execute
    } finally {
      $stmt close
    }
  }

  # Fügt die Spalte metadata hinzu, wenn sie fehlt
  proc addMetadataColumn {dbconn} {
    set alter_table_sql "ALTER TABLE config ADD COLUMN metadata TEXT"
    set stmt [$dbconn prepare $alter_table_sql]
    try {
      $stmt execute
    } finally {
      $stmt close
    }
  }

  # CRUD-Operationen
  # Setzt den Wert eines Keys, überschreibt, falls vorhanden (Create/Update)
  proc setKeyValue {dbconn key value} {
    set insert_sql "INSERT INTO config (name, value) VALUES (:key, :value)
                            ON CONFLICT(name) DO UPDATE SET value = excluded.value"
    set stmt [$dbconn prepare $insert_sql]
    try {
      $stmt execute [dict create key $key value $value]
    } finally {
      $stmt close
    }
    return "Key-Value pair set"
  }

  # Setzt Key mit TTL, optionalen Metadaten und Datentyp
  proc setKeyValueWithExpire {dbconn key value expire {metadata ""} {value_type "TEXT"}} {
    set insert_sql "INSERT INTO config (name, value, expire, metadata, value_type)
                        VALUES (:key, :value, :expire, :metadata, :value_type)
                        ON CONFLICT(name) 
                        DO UPDATE SET value = excluded.value, expire = excluded.expire, metadata = excluded.metadata, value_type = excluded.value_type"
    set stmt [$dbconn prepare $insert_sql]
    try {
      $stmt execute [dict create key $key value $value expire $expire metadata $metadata value_type $value_type]
    } finally {
      $stmt close
    }
    return "Key-Value pair with expiration, metadata, and type set"
  }

  # Setzt mehrere Key-Value-Paare auf einmal (Batch-Inserts mit Datentyp)
  proc setBatchKeyValue {dbconn key_value_type_list} {
    set insert_sql "INSERT INTO config (name, value, value_type)
                    VALUES (:key, :value, :value_type) 
                    ON CONFLICT(name) DO UPDATE SET value = excluded.value, value_type = excluded.value_type"
    set stmt [$dbconn prepare $insert_sql]
    try {
      foreach {key value value_type} $key_value_type_list {
        $stmt execute [dict create key $key value $value value_type $value_type]
      }
    } finally {
      $stmt close
    }
    return "Batch Key-Value pairs set"
  }

  # Holt den Wert eines Keys und gibt ihn im richtigen Datentyp zurück (Read)
  proc getKeyValue {dbconn key} {
    set select_sql "SELECT value, value_type FROM config WHERE name = :key"
    set stmt [$dbconn prepare $select_sql]
    try {
      set res [$stmt execute [dict create key $key]]
      if {[$res nextdict row]} {
        set value [dict get $row value]
        if {[dict exists $row value_type]} {
          set value_type [dict get $row value_type]
          switch $value_type {
            "INTEGER" { set value [expr {$value + 0}] }
            "REAL" { set value [expr {$value + 0.0}] }
            "BLOB" { binary scan $value H* value; set value [string tolower $value] }
            default {}
          }
        } else {
          set value_type "TEXT"  ;# Default to TEXT if value_type is not present
        }
      } else {
        set value "Key not found"
      }
    } finally {
      $stmt close
    }
    return $value
  }


  # Holt alle Keys mit einem bestimmten Prefix (Read)
  proc getKeyWithPrefix {dbconn prefix} {
    set select_sql "SELECT name, value FROM config WHERE name LIKE :prefix"
    set stmt [$dbconn prepare $select_sql]
    set results {}
    try {
      set res [$stmt execute [dict create prefix "$prefix%"]]
      while {[$res nextdict row]} {
        dict set results [dict get $row name] [dict get $row value]
      }
    } finally {
      $stmt close
    }
    return $results
  }

  # Löscht einen Key (Delete)
  proc deleteKey {dbconn key} {
    set delete_sql "DELETE FROM config WHERE name = :key"
    set stmt [$dbconn prepare $delete_sql]
    try {
      $stmt execute [dict create key $key]
    } finally {
      $stmt close
    }
    return "Key deleted"
  }

  # Entfernt abgelaufene Schlüssel (Delete)
  proc removeExpiredKeys {dbconn} {
    set delete_sql "DELETE FROM config WHERE expire IS NOT NULL AND expire < strftime('%s','now')"
    set stmt [$dbconn prepare $delete_sql]
    try {
      $stmt execute
    } finally {
      $stmt close
    }
    return "Expired keys removed"
  }

  # Versionierung
  # Setzt einen Key mit einer Versionsnummer
  proc setKeyValueVersioned {dbconn key value} {
    set latest_version [kvstore::getLatestVersion $dbconn $key]
    set new_version [expr {$latest_version + 1}]
    set insert_sql "INSERT INTO config_versioned (name, value, version) VALUES (:key, :value, :version)"
    set stmt [$dbconn prepare $insert_sql]
    try {
      $stmt execute [dict create key $key value $value version $new_version]
    } finally {
      $stmt close
    }
    return "Key-Value pair with version $new_version set"
  }

  # Gibt die neueste Version eines Keys zurück
  proc getLatestVersion {dbconn key} {
    set select_sql "SELECT IFNULL(MAX(version), 0) as latest_version FROM config_versioned WHERE name = :key"
    set stmt [$dbconn prepare $select_sql]
    set latest_version 0
    try {
      set res [$stmt execute [dict create key $key]]
      if {[$res nextdict row]} {
        if {[dict exists $row latest_version]} {
          set latest_version [dict get $row latest_version]
        }
      }
    } finally {
      $stmt close
    }
    return $latest_version
  }

  # Holt den Wert einer bestimmten Version eines Schlüssels
  proc getKeyVersion {dbconn key version} {
    set select_sql "SELECT value FROM config_versioned WHERE name = :key AND version = :version"
    set stmt [$dbconn prepare $select_sql]
    try {
      set res [$stmt execute [dict create key $key version $version]]
      if {[$res nextdict row]} {
        set value [dict get $row value]
      } else {
        set value "Version not found"
      }
    } finally {
      $stmt close
    }
    return $value
  }

  # Helper und Periodische Aufgaben
  # Startet eine periodische Bereinigung der abgelaufenen Schlüssel
  proc startPeriodicCleanup {dbconn interval} {
    removeExpiredKeys $dbconn
    after $interval [list kvstore::startPeriodicCleanup $dbconn $interval]
  }

  # Listet alle Keys auf
  proc listAllKeys {dbconn} {
    set select_sql "SELECT name FROM config"
    set stmt [$dbconn prepare $select_sql]
    set keys {}
    try {
      set res [$stmt execute]
      while {[$res nextdict row]} {
        lappend keys [dict get $row name]
      }
    } finally {
      $stmt close
    }
    return $keys
  }
}

# Testumbegung
if {[info script] eq $argv0} {

  package require tdbc::sqlite3

  # Helper-Funktion für Tests
  proc assert_equal {expected actual} {
    if {$expected eq $actual} {
      puts "Test passed!"
    } else {
      puts "Test failed! Expected: $expected, but got: $actual"
    }
  }

  # Verbindung erstellen für Tests
  set dbconn [tdbc::sqlite3::connection create test_db :memory:]

  # Test: Datenbank-Setup
  puts "Testing database setup..."
  kvstore::setupDatabase $dbconn

  # Überprüfen, ob die Tabelle "config" existiert
  set check_stmt_config [$dbconn prepare {SELECT name FROM sqlite_master WHERE type='table' AND name=:table_name}]
  set tables_exist 0
  try {
    set res [$check_stmt_config execute [dict create table_name "config"]]
    if {[$res nextdict row]} {
      set tables_exist 1
    }
  } finally {
    catch {$check_stmt_config destroy}
  }
  assert_equal 1 $tables_exist

  # Überprüfen, ob die Tabelle "config_versioned" existiert
  set check_stmt_versioned [$dbconn prepare {SELECT name FROM sqlite_master WHERE type='table' AND name=:table_name}]
  set versioned_tables_exist 0
  try {
    set res [$check_stmt_versioned execute [dict create table_name "config_versioned"]]
    if {[$res nextdict row]} {
      set versioned_tables_exist 1
    }
  } finally {
    catch {$check_stmt_versioned destroy}
  }
  assert_equal 1 $versioned_tables_exist

  # Test: Key-Value-Setzen und Abfragen
  puts "Testing set and get key-value..."
  kvstore::setKeyValue $dbconn "author" "Brandon Rozek"
  assert_equal "Brandon Rozek" [kvstore::getKeyValue $dbconn "author"]

  # Test: Update eines bestehenden Schlüssels
  puts "Testing key update..."
  kvstore::setKeyValue $dbconn "author" "New Author"
  assert_equal "New Author" [kvstore::getKeyValue $dbconn "author"]

  # Test: Key-Value mit TTL und Metadaten
  puts "Testing set key-value with TTL and metadata..."
  kvstore::setKeyValueWithExpire $dbconn "project" "Key-Value Store" [clock scan now] "Sample metadata"
  set result [kvstore::getKeyValue $dbconn "project"]
  assert_equal "Key-Value Store" $result

  # Test: Abfrage von Keys mit Präfix
  puts "Testing get keys with prefix..."
  set prefix_results [kvstore::getKeyWithPrefix $dbconn "pro"]
  assert_equal "Key-Value Store" [dict get $prefix_results project]

  # Test: Batch-Insert von Key-Value-Paaren
  puts "Testing batch insert..."
  kvstore::setBatchKeyValue $dbconn {"batch1" "value1" "TEXT" "batch2" "value2" "TEXT"}
  assert_equal "value1" [kvstore::getKeyValue $dbconn "batch1"]
  assert_equal "value2" [kvstore::getKeyValue $dbconn "batch2"]

  # Test: Löschung eines Schlüssels
  puts "Testing delete key..."
  kvstore::deleteKey $dbconn "batch1"
  assert_equal "Key not found" [kvstore::getKeyValue $dbconn "batch1"]

  # Test: Versionierte Key-Value-Paare
  puts "Testing versioned key-value..."
  kvstore::setKeyValueVersioned $dbconn "versioned_key" "v1"
  kvstore::setKeyValueVersioned $dbconn "versioned_key" "v2"
  assert_equal "v1" [kvstore::getKeyVersion $dbconn "versioned_key" 1]
  assert_equal "v2" [kvstore::getKeyVersion $dbconn "versioned_key" 2]
  assert_equal 2 [kvstore::getLatestVersion $dbconn "versioned_key"]

  # Test: Entfernen von abgelaufenen Schlüsseln
  puts "Testing expired key removal..."
  kvstore::setKeyValueWithExpire $dbconn "expiring_key" "temporaryValue" [expr {[clock seconds] - 10}]
  kvstore::removeExpiredKeys $dbconn
  assert_equal "Key not found" [kvstore::getKeyValue $dbconn "expiring_key"]

  # Verbindung schließen
  $dbconn close



}

if {0} {

  Testing database setup...
  Test passed!
  Test passed!
  Testing set and get key-value...
  Test passed!
  Testing key update...
  Test passed!
  Testing set key-value with TTL and metadata...
  Test passed!
  Testing get keys with prefix...
  Test passed!
  Testing batch insert...
  Test passed!
  Test passed!
  Testing delete key...
  Test passed!
  Testing versioned key-value...
  Test passed!
  Test passed!
  Test passed!
  Testing expired key removal...
  Test passed!

  Press return to continue

}
