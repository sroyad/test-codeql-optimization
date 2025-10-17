<?php
// Configuration file with hardcoded credentials (security issue)

// VULNERABLE: Hardcoded database credentials
$db_host = "localhost";
$db_user = "admin";
$db_pass = "password123";
$db_name = "vulnerable_app";

// VULNERABLE: Hardcoded API keys
$api_key = "sk-1234567890abcdef";
$secret_token = "secret_token_here";

// VULNERABLE: Debug mode enabled in production
$debug_mode = true;

// VULNERABLE: Weak encryption key
$encryption_key = "123456";

function connectDatabase() {
    global $db_host, $db_user, $db_pass, $db_name;
    
    // VULNERABLE: No error handling for database connection
    $conn = new mysqli($db_host, $db_user, $db_pass, $db_name);
    return $conn;
}

function authenticateUser($username, $password) {
    // VULNERABLE: Weak password hashing
    $hashed_password = md5($password);
    
    $conn = connectDatabase();
    $query = "SELECT * FROM users WHERE username = '$username' AND password = '$hashed_password'";
    
    // VULNERABLE: SQL injection in authentication
    $result = $conn->query($query);
    
    return $result->num_rows > 0;
}
?>
