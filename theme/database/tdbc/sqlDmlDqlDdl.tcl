# Executes a DQL (Data Query Language) query, typically a SELECT statement
# Returns a list containing the status ("OK" or "ERROR"), column names, rows, and an error message (if any)
proc sqlcmdDQL {dbconn sqlvar {query_values {}}} {
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
      $res close  ;# Ensure result set is closed after processing
    }
  } on ok {result options} {
    # On success: No special handling needed, status remains "OK"
  } on error {result options} {
    # On error: Set status to "ERROR" and store the error message
    set status "ERROR"
    set errormsg $result
  } finally {
    $stmt close  ;# Ensure statement is closed
  }

  # Return status, columns, rows, and any error message
  return [list $status $cols $rows $errormsg]
}

# Executes a DML (Data Manipulation Language) operation (INSERT, UPDATE, DELETE) within a transaction
# Returns a list containing the status ("OK" or "ERROR"), result (if any), and an error message (if any)
proc sqlcmdDML {dbconn sqlvar {query_values {}}} {
  set status "OK"
  set rueckgabe ""
  set errormsg ""

  $dbconn begintransaction  ;# Begin transaction
  set stmt [$dbconn prepare $sqlvar]
  try {
    set res [$stmt execute $query_values]
  } on ok {result options} {
    $dbconn commit  ;# Commit transaction on success
    set rueckgabe $result
  } on error {result options} {
    $dbconn rollback  ;# Rollback transaction on error
    set status "ERROR"
    set errormsg $result
  } finally {
    $stmt close  ;# Ensure statement is closed
  }

  # Return status, result, and any error message
  return [list $status $rueckgabe $errormsg]
}

# Executes a DML (Data Manipulation Language) operation (INSERT, UPDATE, DELETE) without a transaction
# Returns a list containing the status ("OK" or "ERROR"), result (if any), and an error message (if any)
proc sqlcmdDMLwo {dbconn sqlvar {query_values {}}} {
  set status "OK"
  set rueckgabe ""
  set errormsg ""

  set stmt [$dbconn prepare $sqlvar]
  try {
    set res [$stmt execute $query_values]
  } on ok {result options} {
    set rueckgabe $result  ;# Store result on success
  } on error {result options} {
    set status "ERROR"
    set errormsg $result  ;# Store error message on failure
  } finally {
    $stmt close  ;# Ensure statement is closed
  }

  # Return status, result, and any error message
  return [list $status $rueckgabe $errormsg]
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
