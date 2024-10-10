proc sqltrim sqltext {
return [string trim [string map {"\n" ""} $sqltext]]
} 

# Executes a DQL (Data Query Language) query, typically a SELECT statement
# Returns a list containing the status ("OK" or "ERROR"), column names, rows, and an error message (if any)
proc sqlcmdDQL {dbconn sqlvar {query_values {}} {return_status 0}} {
  set rows {}
  set cols [list]
  set status "OK"
  set errormsg ""

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
    set status "ERROR"
    set errormsg $result
  } finally {
    $stmt close
  }

  # Return either extended or basic format based on return_status flag
  if {$return_status} {
    return [list $status $cols $rows $errormsg]
  } else {
    return [list $cols $rows]
  }
}


# Executes a DML (Data Manipulation Language) operation (INSERT, UPDATE, DELETE) within a transaction
# Returns a list containing the status ("OK" or "ERROR"), result (if any), and an error message (if any)
proc sqlcmdDML {dbconn sqlvar {query_values {}} {return_status 0}} {
  set status "OK"
  set rueckgabe ""
  set errormsg ""

  $dbconn begintransaction
  set stmt [$dbconn prepare $sqlvar]
  try {
    set res [$stmt execute $query_values]
  } on ok {result options} {
    $dbconn commit
    set rueckgabe $result
  } on error {result options} {
    $dbconn rollback
    set status "ERROR"
    set errormsg $result
  } finally {
    $stmt close
  }

  # Return either extended or basic format based on return_status flag
  if {$return_status} {
    return [list $status $rueckgabe $errormsg]
  } else {
    return [list $rueckgabe $options]
  }
}


# Executes a DML (Data Manipulation Language) operation (INSERT, UPDATE, DELETE) without a transaction
# Returns a list containing the status ("OK" or "ERROR"), result (if any), and an error message (if any)
proc sqlcmdDMLwo {dbconn sqlvar {query_values {}} {return_status 0}} {
  set status "OK"
  set rueckgabe ""
  set errormsg ""

  set stmt [$dbconn prepare $sqlvar]
  try {
    set res [$stmt execute $query_values]
  } on ok {result options} {
    set rueckgabe $result
  } on error {result options} {
    set status "ERROR"
    set errormsg $result
  } finally {
    $stmt close
  }

  # Return either extended or basic format based on return_status flag
  if {$return_status} {
    return [list $status $rueckgabe $errormsg]
  } else {
    return [list $rueckgabe $options]
  }
}


# Executes a DDL (Data Definition Language) operation (CREATE, DROP, ALTER)
# Returns a list containing the status ("OK" or "ERROR") and result (if any)
proc sqlcmdDDL {dbconn sqlvar} {
  set stmt [$dbconn prepare $sqlvar]
  try {
    set res [$stmt execute]
  } on ok {result options} {
    # On success: Return "OK" and the result
    return [list "OK" $result]
  } on error {result options} {
    # On error: Return "ERROR" and the error message
    return [list "ERROR" $result]
  } finally {
    $stmt close  ;# Ensure statement is closed
  }
}

