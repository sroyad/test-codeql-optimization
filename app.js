// JavaScript test file with intentional vulnerabilities for CodeQL testing

const express = require('express');
const app = express();

app.get('/', (req, res) => {
    // XSS vulnerability - user input directly in response
    const userInput = req.query.name;
    
    // VULNERABLE: Direct output without sanitization
    res.send(`
        <html>
            <body>
                <h1>Hello ${userInput}</h1>
            </body>
        </html>
    `);
});

app.get('/search', (req, res) => {
    // SQL injection vulnerability
    const searchTerm = req.query.q;
    
    // VULNERABLE: Direct string concatenation
    const query = `SELECT * FROM products WHERE name LIKE '%${searchTerm}%'`;
    
    // Simulate database query
    console.log('Executing query:', query);
    res.json({ message: 'Search completed' });
});

app.listen(3000, () => {
    console.log('Server running on port 3000');
});
