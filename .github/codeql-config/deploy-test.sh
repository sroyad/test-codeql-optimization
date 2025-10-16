#!/bin/bash

# CodeQL Optimization Deployment and Testing Script

set -e

echo "🚀 CodeQL Optimization Deployment Script"
echo "========================================"

# Configuration
TEST_REPO_NAME="test-codeql-optimization"
GITHUB_USERNAME=$(gh api user --jq .login)

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check prerequisites
check_prerequisites() {
    print_status "Checking prerequisites..."
    
    if ! command -v gh &> /dev/null; then
        print_error "GitHub CLI (gh) is not installed. Please install it first."
        exit 1
    fi
    
    if ! gh auth status &> /dev/null; then
        print_error "GitHub CLI is not authenticated. Please run 'gh auth login' first."
        exit 1
    fi
    
    print_success "Prerequisites check passed"
}

# Function to create test repository
create_test_repo() {
    print_status "Creating test repository..."
    
    if gh repo view "$GITHUB_USERNAME/$TEST_REPO_NAME" &> /dev/null; then
        print_warning "Test repository already exists. Skipping creation."
        return
    fi
    
    gh repo create "sroyad/$TEST_REPO_NAME" --public --clone
    print_success "Test repository created: https://github.com/$GITHUB_USERNAME/$TEST_REPO_NAME"
}

# Function to setup test code
setup_test_code() {
    print_status "Setting up test code with vulnerabilities..."
    
    cd "$TEST_REPO_NAME"
    
    # Create Go test file
    cat > main.go << 'EOF'
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
EOF

    # Create package.json for Go module
    cat > go.mod << 'EOF'
module test-codeql-optimization

go 1.21

require (
    github.com/lib/pq v1.10.9
)
EOF

    # Create JavaScript test file
    cat > app.js << 'EOF'
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
EOF

    # Create package.json for Node.js
    cat > package.json << 'EOF'
{
  "name": "test-codeql-optimization",
  "version": "1.0.0",
  "description": "Test repository for CodeQL optimization",
  "main": "app.js",
  "dependencies": {
    "express": "^4.18.2"
  }
}
EOF

    print_success "Test code created with intentional vulnerabilities"
}

# Function to setup workflows
setup_workflows() {
    print_status "Setting up optimized workflows..."
    
    # Create .github directory
    mkdir -p .github/workflows
    
    # Copy CodeQL configuration
    cp -r ../.github/codeql-config .github/
    
    # Create optimized workflow for Go
    cat > .github/workflows/call-ci.yml << 'EOF'
name: 'Opinionated'

on:
  pull_request:
  push:
    branches:
      - master
      - main
      - develop

jobs:
  continuous-integration:
    name: 'Continuous Integration'
    uses: AppDirect/actions/.github/workflows/opinionated-ci-go.yml@master
    secrets: inherit
EOF

    print_success "Optimized workflows configured"
}

# Function to deploy and test
deploy_and_test() {
    print_status "Deploying test repository..."
    
    git add .
    git commit -m "Add test code with vulnerabilities and optimized CodeQL config"
    git push origin main
    
    print_success "Test repository deployed"
    
    echo ""
    print_status "Next steps:"
    echo "1. Go to: https://github.com/$GITHUB_USERNAME/$TEST_REPO_NAME/actions"
    echo "2. Wait for the workflow to complete"
    echo "3. Check Security tab for CodeQL alerts: https://github.com/$GITHUB_USERNAME/$TEST_REPO_NAME/security/code-scanning"
    echo "4. Run monitoring script: ./monitor-false-positives.sh $TEST_REPO_NAME"
}

# Function to create baseline comparison
create_baseline() {
    print_status "Creating baseline comparison..."
    
    # Create baseline workflow (old configuration)
    cat > .github/workflows/baseline-ci.yml << 'EOF'
name: 'Baseline CodeQL'

on:
  push:
    branches:
      - baseline

jobs:
  baseline-codeql:
    name: 'Baseline CodeQL Analysis'
    runs-on: ubuntu-latest
    permissions:
      security-events: write
      actions: read
      contents: read
    steps:
      - uses: actions/checkout@v4
      
      - name: Initialize CodeQL (Baseline)
        uses: github/codeql-action/init@v2
        with:
          languages: go
          build-mode: manual
      
      - name: Perform CodeQL Analysis (Baseline)
        uses: github/codeql-action/analyze@v2
        with:
          category: "/language:go/baseline"
EOF

    git add .github/workflows/baseline-ci.yml
    git commit -m "Add baseline CodeQL workflow for comparison"
    git push origin main
    
    print_success "Baseline workflow created. Switch to 'baseline' branch to test old configuration."
}

# Main execution
main() {
    echo "Starting CodeQL optimization deployment test..."
    echo ""
    
    check_prerequisites
    create_test_repo
    setup_test_code
    setup_workflows
    deploy_and_test
    create_baseline
    
    echo ""
    print_success "🎉 Test repository setup complete!"
    echo ""
    echo "📊 To monitor results:"
    echo "   cd $TEST_REPO_NAME"
    echo "   ../monitor-false-positives.sh $TEST_REPO_NAME"
    echo ""
    echo "🔄 To test baseline (old config):"
    echo "   git checkout baseline"
    echo "   git push origin baseline"
    echo ""
    echo "📈 Expected improvements:"
    echo "   - 80-90% reduction in total alerts"
    echo "   - 70-80% reduction in false positives"
    echo "   - Only high-confidence security issues flagged"
}

# Run main function
main "$@"
