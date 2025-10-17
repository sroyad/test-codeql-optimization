<?php
// Simple vulnerable PHP application for CodeQL testing

// SQL Injection vulnerability
function getUserData($userId) {
    $conn = new mysqli("localhost", "user", "pass", "database");
    
    // VULNERABLE: Direct string concatenation with user input
    $query = "SELECT * FROM users WHERE id = " . $userId;
    $result = $conn->query($query);
    
    return $result->fetch_assoc();
}

// XSS vulnerability
function displayUser($username) {
    // VULNERABLE: Direct output without sanitization
    echo "<h1>Welcome " . $username . "!</h1>";
}

// File inclusion vulnerability
function includeFile($filename) {
    // VULNERABLE: No validation of filename
    include $filename;
}

// Command injection vulnerability
function executeCommand($command) {
    // VULNERABLE: Direct execution of user input
    system($command);
}

// Path traversal vulnerability
function readFile($filepath) {
    // VULNERABLE: No path validation
    $content = file_get_contents($filepath);
    return $content;
}

// Handle form submissions
if ($_POST) {
    if (isset($_POST['user_id'])) {
        $userData = getUserData($_POST['user_id']);
        echo "<pre>" . print_r($userData, true) . "</pre>";
    }
    
    if (isset($_POST['username'])) {
        displayUser($_POST['username']);
    }
    
    if (isset($_POST['filename'])) {
        includeFile($_POST['filename']);
    }
    
    if (isset($_POST['command'])) {
        executeCommand($_POST['command']);
    }
    
    if (isset($_POST['filepath'])) {
        $content = readFile($_POST['filepath']);
        echo "<pre>" . htmlspecialchars($content) . "</pre>";
    }
}
?>

<!DOCTYPE html>
<html>
<head>
    <title>Vulnerable PHP App - CodeQL Test</title>
</head>
<body>
    <h1>Vulnerable PHP Application</h1>
    <p>This application contains intentional vulnerabilities for CodeQL testing.</p>
    
    <h2>Test Forms</h2>
    
    <form method="POST">
        <h3>SQL Injection Test</h3>
        <input type="text" name="user_id" placeholder="User ID">
        <button type="submit">Get User Data</button>
    </form>
    
    <form method="POST">
        <h3>XSS Test</h3>
        <input type="text" name="username" placeholder="Username">
        <button type="submit">Display Username</button>
    </form>
    
    <form method="POST">
        <h3>File Inclusion Test</h3>
        <input type="text" name="filename" placeholder="Filename">
        <button type="submit">Include File</button>
    </form>
    
    <form method="POST">
        <h3>Command Injection Test</h3>
        <input type="text" name="command" placeholder="Command">
        <button type="submit">Execute Command</button>
    </form>
    
    <form method="POST">
        <h3>Path Traversal Test</h3>
        <input type="text" name="filepath" placeholder="File Path">
        <button type="submit">Read File</button>
    </form>
</body>
</html>
