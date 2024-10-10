
#202410102255

# Trim SQL query
proc sqltrim sqltext {
    return [string trim [string map {"\n" ""} $sqltext]]
} 

# Executes a DQL (SELECT) query
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

    if {$return_status} {
        return [list $status $cols $rows $errormsg]
    } else {
        return [list $cols $rows]
    }
}

# Executes a DML (INSERT, UPDATE, DELETE) query
proc sqlcmdDML {dbconn sqlvar {query_values {}} {return_status 0}} {
    set status "OK"
    set errormsg ""

    $dbconn begintransaction
    set stmt [$dbconn prepare $sqlvar]
    try {
        set res [$stmt execute $query_values]
    } on ok {result options} {
        $dbconn commit
    } on error {result options} {
        $dbconn rollback
        set status "ERROR"
        set errormsg $result
    } finally {
        $stmt close
    }

    if {$return_status} {
        return [list $status $errormsg]
    } else {
        return $status
    }
}

# Executes multiple DML (INSERT, UPDATE, DELETE) queries
proc sqlcmdDMLMultiple {dbconn sqlvar query_values_list {return_status 0}} {
    set status "OK"
    set errormsg ""

    $dbconn begintransaction
    set stmt [$dbconn prepare $sqlvar]
    try {
        foreach query_values $query_values_list {
            set res [$stmt execute $query_values]
        }
    } on ok {result options} {
        $dbconn commit
    } on error {result options} {
        $dbconn rollback
        set status "ERROR"
        set errormsg $result
    } finally {
        $stmt close
    }

    if {$return_status} {
        return [list $status $errormsg]
    } else {
        return $status
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

# Executes a DDL (Data Definition Language) operation (CREATE, DROP, ALTER)
# Returns a list containing the status ("OK" or "ERROR") and result (if any)
proc sqlcmdDDL {dbconn sqlvar {debug 0}} {
    set status "OK"
    set errormsg ""

    set stmt [$dbconn prepare $sqlvar]
    try {
        set res [$stmt execute]
    } on ok {result options} {
        # On success: Return "OK" and the result
        return [list $status $result]
    } on error {result options} {
        # On error: Return "ERROR" and the error message
        set status "ERROR"
        set errormsg $result
        if {$debug} {
            puts "Error during DDL execution: $errormsg"  ;# DEBUG: Fehlerausgabe nur bei aktivem Debug
        }
        return [list $status $errormsg]
    } finally {
        $stmt close  ;# Ensure statement is closed
    }
}




######
# Example Usage
if {[info script] eq $argv0} {

    package require tdbc::sqlite3

    # Create an in-memory SQLite database for testing
    set dbconn [tdbc::sqlite3::connection new :memory:]

    # Create the Books table
    set create_table_sql "
        CREATE TABLE Books (
            Title TEXT,
            Author TEXT,
            Year INTEGER
        )
    "
    #    sqlcmdDML $dbconn $create_table_sql 0
    set create_table_result [sqlcmdDDL $dbconn $create_table_sql 1]
puts "Create Table Result: $create_table_result"
    

    # Insert multiple books into the Books table
    set insert_sql "INSERT INTO Books (Title, Author, Year) VALUES (:title, :author, :year)"
    set book_list [list \
        [dict create title "The Catcher in the Rye" author "J.D. Salinger" year 1951] \
        [dict create title "1984" author "George Orwell" year 1949] \
        [dict create title "To Kill a Mockingbird" author "Harper Lee" year 1960]
    ]
    set insert_result [sqlcmdDMLMultiple $dbconn $insert_sql $book_list 1]
    puts "Insert Multiple Books: $insert_result"

    # Select and display all books from the Books table
    set select_sql "SELECT Title, Author, Year FROM Books"
    set select_result [sqlcmdDQL $dbconn $select_sql {} 1]
    puts "Select Books: $select_result"

    # Update a book's year
    set update_sql "UPDATE Books SET Year = :year WHERE Title = :title"
    set update_values [dict create title "1984" year 1950]
    set update_result [sqlcmdDML $dbconn $update_sql $update_values 1]
    puts "Update 1984's Year: $update_result"

    # Select and display updated books
    set select_result [sqlcmdDQL $dbconn $select_sql {} 1]
    puts "Select Updated Books: $select_result"

    # Delete a book from the table
    set delete_sql "DELETE FROM Books WHERE Title = :title"
    set delete_values [dict create title "The Catcher in the Rye"]
    set delete_result [sqlcmdDML $dbconn $delete_sql $delete_values 1]
    puts "Delete The Catcher in the Rye: $delete_result"

    # Select and display books after deletion
    set select_result [sqlcmdDQL $dbconn $select_sql {} 1]
    puts "Select Books After Deletion: $select_result"

    # Close the database connection
    $dbconn close
}
  

#output 
if {0} {


Create Table Result: OK ::oo::Obj18::ResultSet::1
Insert Multiple Books: OK {}
Select Books: OK {Title Author Year} {{{The Catcher in the Rye} {J.D. Salinger} 1951} {1984 {George Orwell} 1949} {{To Kill a Mockingbird} {Harper Lee} 1960}} {}
Update 1984's Year: OK {}
Select Updated Books: OK {Title Author Year} {{{The Catcher in the Rye} {J.D. Salinger} 1951} {1984 {George Orwell} 1950} {{To Kill a Mockingbird} {Harper Lee} 1960}} {}
Delete The Catcher in the Rye: OK {}
Select Books After Deletion: OK {Title Author Year} {{1984 {George Orwell} 1950} {{To Kill a Mockingbird} {Harper Lee} 1960}} {}

Press return to continue

  
}

