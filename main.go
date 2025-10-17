package main

import (
	"database/sql"
	"fmt"
	"log"
	"net/http"
	"os"
)

func main() {
	// This is a test file with intentional vulnerabilities for CodeQL testing
	http.HandleFunc("/", handler)
	log.Fatal(http.ListenAndServe(":8080", nil))
}

func handler(w http.ResponseWriter, r *http.Request) {
	// SQL injection vulnerability - user input directly in query
	userID := r.URL.Query().Get("id")
	
	db, err := sql.Open("sqlite3", "test.db")
	if err != nil {
		http.Error(w, "Database error", 500)
		return
	}
	defer db.Close()
	
	// VULNERABLE: Direct string concatenation with user input
	query := "SELECT * FROM users WHERE id = " + userID
	rows, err := db.Query(query)
	if err != nil {
		http.Error(w, "Query error", 500)
		return
	}
	defer rows.Close()
	
	fmt.Fprintf(w, "User data retrieved")
}

func unsafeFileOperation() {
	// Another vulnerability - path traversal
	filename := os.Getenv("USER_INPUT_FILE")
	
	// VULNERABLE: No validation of filename
	file, err := os.Open(filename)
	if err != nil {
		log.Fatal(err)
	}
	defer file.Close()
}
