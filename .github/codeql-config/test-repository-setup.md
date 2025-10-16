# Testing Strategy for CodeQL Optimization

## Phase 1: Local Validation

### Step 1: Create Test Repository
```bash
# Create a new test repository in your GitHub account
gh repo create test-codeql-optimization --public --clone

# Clone it locally
git clone https://github.com/YOUR_USERNAME/test-codeql-optimization.git
cd test-codeql-optimization
```

### Step 2: Add Test Code with Known Vulnerabilities
Create files with intentional security issues to test our high-precision queries:

**Go Test File** (`main.go`):
```go
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
```

**JavaScript Test File** (`app.js`):
```javascript
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
```

### Step 3: Add Workflow Files
Copy the workflow files from your optimized actions repository:

```bash
# From your local actions repository
cp -r /path/to/actions-master/.github/codeql-config ./test-repository/.github/
cp /path/to/actions-master/.github/workflows/opinionated-ci-go.yml ./test-repository/.github/workflows/
```

## Phase 2: Test Repository Deployment

### Step 1: Push to Test Repository
```bash
cd test-repository
git add .
git commit -m "Add test code with vulnerabilities and optimized CodeQL config"
git push origin main
```

### Step 2: Monitor Results
1. Go to GitHub Actions tab
2. Check if the workflow runs successfully
3. Go to Security tab → Code scanning alerts
4. Count and analyze the alerts

### Step 3: Compare with Baseline
Create a baseline by temporarily using the old configuration:

```yaml
# Temporarily revert to old config in test repo
- name: Initialize CodeQL
  uses: github/codeql-action/init@f443b600d91635bebf5b0d9ebc620189c0d6fba5
  with:
    languages: go
    build-mode: manual
    # Remove the new config lines temporarily
```

## Phase 3: Production Deployment Strategy

### Step 1: Deploy to 1-2 Real Repositories
Choose small, active repositories for initial testing:
- Repository with 10-50 recent commits
- Active development team
- Good communication channel

### Step 2: Monitor for 1 Week
- Check alert counts daily
- Monitor developer feedback
- Track false positive rates

### Step 3: Gradual Rollout
Week 1: 2 repositories
Week 2: 5 repositories  
Week 3: 10 repositories
Week 4: All repositories

## Expected Results

### Before Optimization (Baseline)
- High alert count (200-500 per repo)
- Many false positives
- Developer complaints about noise

### After Optimization (Target)
- Low alert count (20-50 per repo)
- High confidence alerts only
- Positive developer feedback
- Reduced manual validation effort

## Rollback Plan

If issues arise:
1. Revert workflow files to previous version
2. Remove custom configuration
3. Restore original settings
4. Communicate with affected teams
