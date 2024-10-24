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
