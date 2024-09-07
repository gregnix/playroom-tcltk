#sqlcmdDQL für select
#sqlcmdDML für update,insert, delete und Transactionen

proc sqltrim sqltext {
  return [string trim [string map {"\n" ""} $sqltext]]
}

proc sqlcmdDQL {dbconn sqlvar {query_values {} } } {
  set rows {}
  set cols [list]
  set stmt [$dbconn prepare $sqlvar]
  try {
    set res [$stmt execute $query_values]
    try {
      set cols [$res columns]
      while {[$res nextlist row]} {
        lappend rows $row
      }
    } finally {
        $res close
    }
  } on ok {result options} {

  } on error {result options} {
      puts "result: $result"
      puts "options: $options"

  } finally {
    $stmt close
  }
return [list $cols $rows]
}


# mit Transaction
proc sqlcmdDML {dbconn sqlvar {query_values {} } } {
  $dbconn begintransaction
  set stmt [$dbconn prepare $sqlvar ]
  try {
    set res [$stmt execute $query_values]
  } on ok {result options} {
    $dbconn commit
    set rueckgabe [list $result $options]
    $res close
  } on error {result options} {
    $dbconn rollback
    set rueckgabe [list $result $options]
  } finally {
    $stmt close
  }
return $rueckgabe
}

# ohne Transaction
proc sqlcmdDMLwo {dbconn sqlvar {query_values {} } } {
  set stmt [$dbconn prepare $sqlvar ]
  try {
    set res [$stmt execute $query_values]
  } on ok {result options} {
    set rueckgabe [list $result $options]
  } on error {result options} {
    set rueckgabe [list $result $options]
  } finally {
    $stmt close
  }
return $rueckgabe
}

proc loadTableListFromSQLite {tbl dbconn tablename condition {value ""}} {
    # SQL-Abfrage erstellen
    set sqlvar "SELECT * FROM $tablename"
    if { $condition ne "" } {
        append sqlvar " WHERE $condition = :value"
    }
    
    # Daten aus SQLite-Tabelle abrufen
    set result [sqlcmdDQL $dbconn [sqltrim $sqlvar] [dict create value $value]]
    
    # Tablelist leeren
    $tbl delete 0 end
    
    # Daten in die Tablelist einfügen
    set rows [lindex $result 1]
    foreach row $rows {
        $tbl insert end $row
    }
    
    puts "Daten aus $tablename wurden erfolgreich in die Tablelist geladen."
}

proc saveTableListToSQLite {tbl dbconn tablename columns unique_keys} {
    set rowCount [$tbl index end]
    
    foreach col $columns {
        lappend col_names [lindex $col 0]
        lappend col_placeholders ":$col"
    }
    
    set sqlvar "INSERT OR REPLACE INTO $tablename ($col_names) VALUES ($col_placeholders)"
    
    for {set i 0} {$i < $rowCount} {incr i} {
        set query_values {}
        foreach col $columns {
            dict set query_values $col [$tbl get $i,[lindex $col 1]]
        }
        
        set result [sqlcmdDMLwo $dbconn [sqltrim $sqlvar] $query_values]
        
        if {[lindex $result 0] != "OK"} {
            puts "Fehler beim Speichern von $tablename: [lindex $result 0]"
        }
    }
    
    puts "Daten wurden erfolgreich in die SQLite-Tabelle '$tablename' eingefügt oder aktualisiert."
}

