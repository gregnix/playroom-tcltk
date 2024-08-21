package require tdbc::sqlite3

#sql-sqlite-connect.tcl

# Datenbankverbindung erstellen im Filesytem
#catch {file delete ./my-database.sqlite3}
#set dbconnS [tdbc::sqlite3::connection create dbS my-database.sqlite3]

# Datenbankverbindung erstellen im speicher
set dbconnS [tdbc::sqlite3::connection create db11 :memory:]


return [info script]
