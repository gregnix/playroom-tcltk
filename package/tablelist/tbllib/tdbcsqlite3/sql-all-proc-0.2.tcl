
#sql-all-proc-0.1.tcl

source sql-sqlite-connect.0.2.tcl
source sql-std-proc-0.2.tcl


proc initDatabase {dbconn} {
    # Tabelle erstellen
    set sqlCreate {
        CREATE TABLE IF NOT EXISTS users (
            ID INTEGER PRIMARY KEY,
            Name TEXT NOT NULL,
            Email TEXT NOT NULL
        )
    }
    set result [sqlcmdDDL $dbconn $sqlCreate]
    # Beispieldaten einfügen
    set insertSql "INSERT INTO users (ID, Name, Email) VALUES (:id, :name, :email)"
    set usersData {
        {id 1 name "Alice" email "alice@example.com"}
        {id 2 name "Bob" email "bob@example.com"}
        {id 3 name "Carol" email "carol@example.com"}
    }

    foreach userData $usersData {
        set insertResult [sqlcmdDML $dbconn $insertSql $userData]
        if {[dict get $insertResult status] eq "error"} {
            error "Fehler beim Einfügen von Daten: [dict get $insertResult message]"
        }
    }
}

proc initDatabase {dbconn} {
    # Tabelle erstellen
    set sqlCreate {
        CREATE TABLE IF NOT EXISTS users (
            ID INTEGER PRIMARY KEY,
            Name TEXT NOT NULL,
            Email TEXT NOT NULL
        )
    }
    set result [sqlcmdDDL $dbconn $sqlCreate]
    # Beispieldaten einfügen oder aktualisieren
    set upsertSql {
        INSERT INTO users (ID, Name, Email)
        VALUES (:id, :name, :email)
        ON CONFLICT(ID) DO UPDATE SET
        Name = excluded.Name,
        Email = excluded.Email
    }
    set usersData {
        {id 1 name "Alice" email "alice@example.com"}
        {id 2 name "Bob" email "bob@example.com"}
        {id 3 name "Carol" email "carol@example.com"}
    }

    foreach userData $usersData {
        set upsertResult [sqlcmdDML $dbconn $upsertSql $userData]
        if {[dict get $upsertResult status] eq "error"} {
            error "Fehler beim Einfügen oder Aktualisieren von Daten: [dict get $upsertResult message]"
        }
    }
}


# Funktion zur Ausführung von SQL-Befehlen
proc executeSQL {dbconn entryWidget outputWidget} {
    set sql [sqltrim [$entryWidget get]]
    set sqlLower [string tolower $sql]

    if {[string match {*select*} $sqlLower] || [string match {*pragma*} $sqlLower]} {
        set result [sqlcmdDQL $dbconn $sql]
        set listresult [dictToListOfLists $result]
        set outputText "Columns: [dict get $result columns]\nRows:\n"
        foreach row [dict get $result rows] {
            append outputText "$row\n"
        }
    } else {
        set result [sqlcmdDML $dbconn $sql]
        set outputText "Status: [dict get $result status]\nAffected Rows: [dict get $result affected_rows]\n"
    }
    # $outputWidget configure -state normal
    $outputWidget delete 1.0 end
    $outputWidget insert end $outputText
    $outputWidget insert end \n
    # $outputWidget configure -state disabled
    listToreport [dictToListOfLists $result]  $outputWidget
}