package require tdbc::sqlite3

# Datenbankverbindung erstellen im Filesytem
catch {file delete ./my-database.sqlite3}
#set dbconnS [tdbc::sqlite3::connection create dbS my-database.sqlite3]
set dbconnS [tdbc::sqlite3::connection create dbS chinook.db]


# Verbindung erstellen
#set dbconnS [tdbc::sqlite3::connection create db11 :memory:]


