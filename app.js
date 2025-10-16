const express = require('express');
const app = express();

app.get('/search', (req, res) => {
    // This should be flagged by our high-precision query
    const userInput = req.query.q;
    document.write(`<h1>Search results for: ${userInput}</h1>`); // XSS vulnerability
    
    // This should NOT be flagged (safe constant)
    const safeContent = "<h1>Welcome</h1>";
    document.write(safeContent);
});

app.listen(3000);
