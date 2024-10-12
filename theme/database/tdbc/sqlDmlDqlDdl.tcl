# Trim SQL query
proc sqltrim sqltext {
  return [string trim [string map {"\n" ""} $sqltext]]
}

# Executes a DQL (SELECT) query
proc sqlcmdDQL {dbconn sqlvar {query_values {}}} {
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
  } on error {result options} {
    return -code error -errorinfo "Error in DQL execution: $result" -errorcode $result
  } finally {
    $stmt close
  }

  return [list $cols $rows]
}

# Executes a DML (INSERT, UPDATE, DELETE) query
proc sqlcmdDML {dbconn sqlvar {query_values {}}} {
  $dbconn begintransaction
  set stmt [$dbconn prepare $sqlvar]
  try {
    set res [$stmt execute $query_values]
    $dbconn commit
  } on error {result options} {
    $dbconn rollback
    return -code error -errorinfo "Error in DML execution: $result" -errorcode $result
  } finally {
    $stmt close
  }

  return "OK"
}

# Executes multiple DML (INSERT, UPDATE, DELETE) queries
proc sqlcmdDMLMultiple {dbconn sqlvar query_values_list} {
  $dbconn begintransaction
  set stmt [$dbconn prepare $sqlvar]
  try {
    foreach query_values $query_values_list {
      set res [$stmt execute $query_values]
    }
    $dbconn commit
  } on error {result options} {
    $dbconn rollback
    return -code error -errorinfo "Error in DML Multiple execution: $result" -errorcode $result
  } finally {
    $stmt close
  }

  return "OK"
}

# Executes a DML (INSERT, UPDATE, DELETE) without a transaction
proc sqlcmdDMLwo {dbconn sqlvar {query_values {}}} {
  set stmt [$dbconn prepare $sqlvar]
  try {
    set res [$stmt execute $query_values]
  } on error {result options} {
    return -code error -errorinfo "Error in DMLwo execution: $result" -errorcode $result
  } finally {
    $stmt close
  }

  return "OK"
}

# Executes a DDL (CREATE, DROP, ALTER) operation
proc sqlcmdDDL {dbconn sqlvar {debug 0}} {
  set stmt [$dbconn prepare $sqlvar]
  try {
    set res [$stmt execute]
  } on error {result options} {
    if {$debug} {
      puts "Error during DDL execution: $result"
    }
    return -code error -errorinfo "Error in DDL execution: $result" -errorcode $result
  } finally {
    $stmt close
  }

  return "OK"
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
  set create_table_result [sqlcmdDDL $dbconn $create_table_sql 0]
  puts "Create Table Result: $create_table_result"

  # Insert multiple books into the Books table
  set insert_sql "INSERT INTO Books (Title, Author, Year) VALUES (:title, :author, :year)"
  set book_list [list \
      [dict create title "The Catcher in the Rye" author "J.D. Salinger" year 1951] \
      [dict create title "1984" author "George Orwell" year 1949] \
      [dict create title "To Kill a Mockingbird" author "Harper Lee" year 1960]
  ]
  puts "book_list: \n[join $book_list "\n"]\n"
  set insert_result [sqlcmdDMLMultiple $dbconn $insert_sql $book_list]
  puts "Insert Multiple Books: $insert_result"

  # Select and display all books from the Books table
  set select_sql "SELECT Title, Author, Year FROM Books"
  set select_result [sqlcmdDQL $dbconn $select_sql {}]
  puts "\nSelect Books:\n[lindex $select_result 0]"
  puts "[join  [lindex $select_result 1] "\n"]\n"

  # Update a book's year
  set update_sql "UPDATE Books SET Year = :year WHERE Title = :title"
  set update_values [dict create title "1984" year 1950]
  set update_result [sqlcmdDML $dbconn $update_sql $update_values]
  puts "Update 1984's Year: $update_result\n"

  # Select and display updated books
  set select_result [sqlcmdDQL $dbconn $select_sql {}]
  puts "Select Updated Books: \n[lindex $select_result 0]"
  puts "[join [lindex $select_result 1] "\n"]\n"
  
  
  # Delete a book from the table
  set delete_sql "DELETE FROM Books WHERE Title = :title"
  set delete_values [dict create title "The Catcher in the Rye"]
  set delete_result [sqlcmdDML $dbconn $delete_sql $delete_values]
  puts "Delete The Catcher in the Rye: $delete_result"

  # Select and display books after deletion
  set select_result [sqlcmdDQL $dbconn $select_sql {}]
  puts "Select Books After Deletion: \n[lindex $select_result 0]"
  puts "\n[join [lindex $select_result 1] "\n"]"

  # Close the database connection
  $dbconn close
}

# output
if {0} {
 Create Table Result: OK
book_list: 
title {The Catcher in the Rye} author {J.D. Salinger} year 1951
title 1984 author {George Orwell} year 1949
title {To Kill a Mockingbird} author {Harper Lee} year 1960

Insert Multiple Books: OK

Select Books:
Title Author Year
{The Catcher in the Rye} {J.D. Salinger} 1951
1984 {George Orwell} 1949
{To Kill a Mockingbird} {Harper Lee} 1960

Update 1984's Year: OK

Select Updated Books: 
Title Author Year
{The Catcher in the Rye} {J.D. Salinger} 1951
1984 {George Orwell} 1950
{To Kill a Mockingbird} {Harper Lee} 1960

Delete The Catcher in the Rye: OK
Select Books After Deletion: 
Title Author Year

1984 {George Orwell} 1950
{To Kill a Mockingbird} {Harper Lee} 1960

Press return to continue
 
}



