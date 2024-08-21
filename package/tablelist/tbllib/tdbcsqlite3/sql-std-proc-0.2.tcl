
#sql-std-proc-0.2.tcl

#sqlcmdDQL für select
#sqlcmdDML für update,insert, delete und Transactionen

proc sqltrim sqltext {
  return [string trim [string map {"\n" ""} $sqltext]]
}

# Verbesserung der Rückgabestruktur in sqlcmdDQL
proc sqlcmdDQL {dbconn sqlvar {query_values {} }} {
  set data [dict create]
  set stmt [$dbconn prepare $sqlvar]
  try {
    set res [$stmt execute $query_values]
    try {
      set columns [$res columns]
      dict set data columns $columns
      set rows []
      while {[$res nextlist row]} {
        lappend rows $row
      }
      dict set data rows $rows
    } finally {
      $res close
    }
  } finally {
    $stmt close
  }
  return $data
}


# mit Transaction
# Erweiterte Rückgabestruktur in sqlcmdDML
proc sqlcmdDML {dbconn sqlvar {query_values {} }} {
  set rueckgabe [dict create]
  $dbconn begintransaction
  set stmt [$dbconn prepare $sqlvar]
  try {
    set res [$stmt execute $query_values]
    set changes [$res changes]  ;# Anzahl der durch die Transaktion betroffenen Zeilen
    $dbconn commit
    dict set rueckgabe status "success"
    dict set rueckgabe affected_rows $changes
  } on error {msg options} {
    $dbconn rollback
    dict set rueckgabe status "error"
    dict set rueckgabe message $msg
    dict set rueckgabe options $options
  } finally {
    if {[info exists stmt]} {
      $stmt close
    }
  }
  return $rueckgabe
}


# ohne Transaction
# Ohne Transaction, aber mit konsistenter Fehlerbehandlung
proc sqlcmdDMLwo {dbconn sqlvar {query_values {} }} {
  set rueckgabe [dict create]
  set stmt [$dbconn prepare $sqlvar]
  try {
    set res [$stmt execute $query_values]
    dict set rueckgabe status "success"
    dict set rueckgabe affected_rows [$res changes]
  } on error {msg options} {
    dict set rueckgabe status "error"
    dict set rueckgabe message $msg
    dict set rueckgabe options $options
  } finally {
    $stmt close
  }
  return $rueckgabe
}

