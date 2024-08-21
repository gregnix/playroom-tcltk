package require tdbc::sqlite3

proc initDatabase {dbconn} {
    # Tabelle erstellen, wenn sie nicht existiert
    set createStmt [$dbconn prepare {
        CREATE TABLE IF NOT EXISTS users (
            ID INTEGER PRIMARY KEY,
            Name TEXT NOT NULL,
            Email TEXT NOT NULL
        )
    }]
    $createStmt execute
    $createStmt close

    # Beispieldaten einfügen
    set insertSql "INSERT INTO users (ID, Name, Email) VALUES (:id, :name, :email)"
    set insertStmt [$dbconn prepare $insertSql]

    # Beispieldaten als Liste von Dictionaries
    set usersData {
        {id 1 name "Alice" email "alice@example.com"}
        {id 2 name "Bob" email "bob@example.com"}
        {id 3 name "Carol" email "carol@example.com"}
    }

    foreach userData $usersData {
        $insertStmt execute $userData
    }
    $insertStmt close
}

# Verbindung erstellen
set dbconnS [tdbc::sqlite3::connection create db11 :memory:]

# Datenbank initialisieren
initDatabase $dbconnS

# Rückgabe der Datenbankverbindung
return $dbconnS

