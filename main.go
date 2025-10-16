package main

import (
    "database/sql"
    "fmt"
    "net/http"
    _ "github.com/lib/pq"
)

func vulnerableHandler(w http.ResponseWriter, r *http.Request) {
    db, _ := sql.Open("postgres", "user=test dbname=test")
    
    // This should be flagged by our high-precision query
    userInput := r.FormValue("username")
    query := fmt.Sprintf("SELECT * FROM users WHERE username = '%s'", userInput)
    db.Query(query) // SQL injection vulnerability
    
    // This should NOT be flagged (safe constant)
    safeQuery := "SELECT * FROM users WHERE active = true"
    db.Query(safeQuery)
}

func main() {
    http.HandleFunc("/", vulnerableHandler)
    http.ListenAndServe(":8080", nil)
}
