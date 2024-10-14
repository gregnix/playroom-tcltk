# 202410140613

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

  # Create the Authors table
  set create_authors_table_sql "
    CREATE TABLE Authors (
        AuthorID INTEGER PRIMARY KEY,
        AuthorName TEXT
    )
  "
  set create_authors_table_result [sqlcmdDDL $dbconn $create_authors_table_sql 0]
  puts "Create Authors Table Result: $create_authors_table_result"

  # Insert authors into the Authors table
  set insert_authors_sql "INSERT INTO Authors (AuthorName) VALUES (:author_name)"
  set authors_list [list \
      [dict create author_name "J.D. Salinger"] \
      [dict create author_name "George Orwell"] \
      [dict create author_name "Harper Lee"]
  ]
  set insert_authors_result [sqlcmdDMLMultiple $dbconn $insert_authors_sql $authors_list]
  puts "Insert Authors: $insert_authors_result"

  # Create the Books table
  set create_books_table_sql "
    CREATE TABLE Books (
        Title TEXT,
        AuthorID INTEGER,
        Year INTEGER,
        FOREIGN KEY(AuthorID) REFERENCES Authors(AuthorID)
    )
  "
  set create_books_table_result [sqlcmdDDL $dbconn $create_books_table_sql 0]
  puts "Create Books Table Result: $create_books_table_result"

  # Insert multiple books into the Books table
  set insert_books_sql "INSERT INTO Books (Title, AuthorID, Year)
                      VALUES (:title, 
                      (SELECT AuthorID FROM Authors WHERE AuthorName = :author_name), 
                      :year)"
  set book_list [list \
    [dict create title "The Catcher in the Rye" author_name "J.D. Salinger" year 1951] \
    [dict create title "1984" author_name "George Orwell" year 1949] \
    [dict create title "To Kill a Mockingbird" author_name "Harper Lee" year 1960]
  ]

  set insert_result [sqlcmdDMLMultiple $dbconn $insert_books_sql $book_list]
  puts "\nbook_list: \n[join $book_list "\n"]\n"
  puts "Insert Multiple Books with Subquery: $insert_result"


  # Use JOIN to select books along with their corresponding authors
  set select_join_sql "
    SELECT Books.Title, Authors.AuthorName, Books.Year
    FROM Books
    JOIN Authors ON Books.AuthorID = Authors.AuthorID
  "
  set select_join_result [sqlcmdDQL $dbconn $select_join_sql {}]
  puts "\nSelect Books with Authors:"
  puts "[lindex $select_join_result 0]"
  puts "[join [lindex $select_join_result 1] \"\n\"]\n"

  # Close the database connection
  $dbconn close

}

# output
if {0} {
/usr/bin/tclsh /home/greg/Project/tcl/2024/thema/database/chinook/lib/sqlDmlDqlDdl.tcl 


Create Authors Table Result: OK
Insert Authors: OK
Create Books Table Result: OK

book_list: 
title {The Catcher in the Rye} author_name {J.D. Salinger} year 1951
title 1984 author_name {George Orwell} year 1949
title {To Kill a Mockingbird} author_name {Harper Lee} year 1960

Insert Multiple Books with Subquery: OK

Select Books with Authors:
Title AuthorName Year
{The Catcher in the Rye} {J.D. Salinger} 1951"
"1984 {George Orwell} 1949"
"{To Kill a Mockingbird} {Harper Lee} 1960


Press return to continue


}


