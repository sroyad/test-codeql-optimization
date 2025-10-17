#!/usr/bin/env python3
"""
Vulnerable Python Web Application for CodeQL Testing
Contains intentional security vulnerabilities for demonstration
"""

import os
import sqlite3
import subprocess
import urllib.parse
from flask import Flask, request, render_template_string, redirect, url_for

app = Flask(__name__)

# SQL Injection vulnerability
@app.route('/user')
def get_user():
    user_id = request.args.get('id')
    
    # VULNERABLE: Direct string concatenation with user input
    query = "SELECT * FROM users WHERE id = " + user_id
    
    conn = sqlite3.connect('users.db')
    cursor = conn.cursor()
    
    # VULNERABLE: Executing query with user input
    cursor.execute(query)
    result = cursor.fetchone()
    conn.close()
    
    return f"User: {result}"

# Command Injection vulnerability
@app.route('/ping')
def ping_host():
    host = request.args.get('host')
    
    # VULNERABLE: Direct command execution with user input
    command = f"ping -c 4 {host}"
    result = subprocess.run(command, shell=True, capture_output=True, text=True)
    
    return f"Ping result: {result.stdout}"

# Path Traversal vulnerability
@app.route('/file')
def read_file():
    filename = request.args.get('file')
    
    # VULNERABLE: No validation of filename
    with open(filename, 'r') as f:
        content = f.read()
    
    return f"File content: {content}"

# XSS vulnerability
@app.route('/search')
def search():
    query = request.args.get('q')
    
    # VULNERABLE: Direct output without sanitization
    template = f"""
    <html>
        <body>
            <h1>Search Results for: {query}</h1>
            <p>No results found for your query.</p>
        </body>
    </html>
    """
    
    return render_template_string(template)

# Hardcoded credentials
@app.route('/admin')
def admin_login():
    username = request.args.get('username')
    password = request.args.get('password')
    
    # VULNERABLE: Hardcoded credentials
    if username == "admin" and password == "password123":
        return "Admin access granted!"
    else:
        return "Access denied!"

# Insecure deserialization
@app.route('/data')
def process_data():
    import pickle
    data = request.args.get('data')
    
    # VULNERABLE: Insecure deserialization
    obj = pickle.loads(data.encode())
    return f"Processed: {obj}"

# Weak cryptography
@app.route('/encrypt')
def encrypt_data():
    import hashlib
    data = request.args.get('data')
    
    # VULNERABLE: Using weak MD5 hash
    hash_value = hashlib.md5(data.encode()).hexdigest()
    return f"Hash: {hash_value}"

if __name__ == '__main__':
    app.run(debug=True, host='0.0.0.0', port=5000)
