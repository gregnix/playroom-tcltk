set invoiceData {
    "header" {
        "company_name" "Musterfirma GmbH"
        "company_address" "Musterstraße 1\n12345 Musterstadt"
        "company_contact" "Tel: 01234/56789\nE-Mail: info@musterfirma.de"
        "invoice_number" "RE-2023-00123"
        "invoice_date" "2023-07-25"
        "due_date" "2023-08-15"
        "customer_number" "K-123456"
        "customer_name" "Herr Max Mustermann"
        "customer_address" "Beispielweg 2\n54321 Beispielstadt"
    }
    "items" {
        1 {
            "description" "Dienstleistung A"
            "quantity" "1"
            "unit_price" "100.00"
            "total_price" "100.00"
        }
        2 {
            "description" "Produkt B"
            "quantity" "5"
            "unit_price" "20.00"
            "total_price" "100.00"
        }
    }
    "summary" {
        "subtotal" "200.00"
        "tax" "19%" 
        "tax_amount" "38.00"
        "total" "238.00"
    }
    "footer" {
        "payment_terms" "Zahlbar innerhalb von 14 Tagen ohne Abzug."
        "bank_details" "Bankname: Musterbank\nIBAN: DE12345678901234567890\nBIC: MUSBDEFFXXX"
        "additional_info" "Bei Fragen zur Rechnung kontaktieren Sie uns bitte unter den oben angegebenen Kontaktdaten."
    }
}


set complex_dict {
    person {
        name "John Doe"
        age 30
        address {
            street "123 Main St"
            city "Anytown"
            postal_code "12345"
            country "Wonderland"
        }
        contacts {
            phone "123-456-7890"
            email "john.doe@example.com"
        }
        interests {reading coding hiking}
    }
    job {
        title "Senior Developer"
        company {
            name "Tech Solutions"
            location "Silicon Valley"
            department {
                name "Research & Development"
                manager "Jane Smith"
            }
        }
        years 5
    }
    education {
        undergraduate {
            institution "State University"
            degree "Bachelor of Science"
            major "Computer Science"
            graduation_year 2012
        }
        graduate {
            institution "Tech University"
            degree "Master of Science"
            major "Software Engineering"
            graduation_year 2015
        }
    }
    certifications {
        {Certified Developer}
        {Project Management Professional}
        {Data Science Specialist}
    }
    projects {
        project1 {
            name "AI Chatbot"
            description "Development of a chatbot using natural language processing"
            status "Completed"
            team_members {Alice Bob Charlie}
        }
        project2 {
            name "Cloud Migration"
            description "Migrating legacy systems to cloud infrastructure"
            status "Ongoing"
            team_members {Dave Eve Frank}
        }
    }
}



set sqlite_info {
    database {
        name "example_db"
        size "10MB"
        last_modified "2024-07-25"
        tables {
            users {
                columns {
                    id {type "INTEGER" primary_key true autoincrement true}
                    username {type "TEXT" unique true not_null true}
                    password_hash {type "TEXT" not_null true}
                    email {type "TEXT" unique true not_null true}
                    created_at {type "DATETIME" default "CURRENT_TIMESTAMP"}
                }
                indices {
                    username_index {columns {username} unique true}
                    email_index {columns {email} unique true}
                }
                foreign_keys {}
                triggers {}
            }
            posts {
                columns {
                    id {type "INTEGER" primary_key true autoincrement true}
                    user_id {type "INTEGER" foreign_key "users(id)" not_null true}
                    title {type "TEXT" not_null true}
                    content {type "TEXT"}
                    created_at {type "DATETIME" default "CURRENT_TIMESTAMP"}
                }
                indices {
                    user_id_index {columns {user_id}}
                }
                foreign_keys {
                    user_id {references "users(id)" on_delete "CASCADE"}
                }
                triggers {}
            }
            comments {
                columns {
                    id {type "INTEGER" primary_key true autoincrement true}
                    post_id {type "INTEGER" foreign_key "posts(id)" not_null true}
                    user_id {type "INTEGER" foreign_key "users(id)" not_null true}
                    content {type "TEXT"}
                    created_at {type "DATETIME" default "CURRENT_TIMESTAMP"}
                }
                indices {
                    post_id_index {columns {post_id}}
                    user_id_index {columns {user_id}}
                }
                foreign_keys {
                    post_id {references "posts(id)" on_delete "CASCADE"}
                    user_id {references "users(id)" on_delete "CASCADE"}
                }
                triggers {}
            }
        }
    }
    sample_queries {
        create_user_table "CREATE TABLE IF NOT EXISTS users (id INTEGER PRIMARY KEY AUTOINCREMENT, username TEXT UNIQUE NOT NULL, password_hash TEXT NOT NULL, email TEXT UNIQUE NOT NULL, created_at DATETIME DEFAULT CURRENT_TIMESTAMP);"
        create_post_table "CREATE TABLE IF NOT EXISTS posts (id INTEGER PRIMARY KEY AUTOINCREMENT, user_id INTEGER NOT NULL, title TEXT NOT NULL, content TEXT, created_at DATETIME DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE);"
        create_comment_table "CREATE TABLE IF NOT EXISTS comments (id INTEGER PRIMARY KEY AUTOINCREMENT, post_id INTEGER NOT NULL, user_id INTEGER NOT NULL, content TEXT, created_at DATETIME DEFAULT CURRENT_TIMESTAMP, FOREIGN KEY(post_id) REFERENCES posts(id) ON DELETE CASCADE, FOREIGN KEY(user_id) REFERENCES users(id) ON DELETE CASCADE);"
        select_users "SELECT * FROM users;"
        select_posts_by_user "SELECT * FROM posts WHERE user_id = ?;"
        insert_user "INSERT INTO users (username, password_hash, email) VALUES (?, ?, ?);"
    }
}
