#!/bin/bash
# CodeQL Demo Script: Baseline vs Optimized

echo "🎯 CodeQL Demo: Baseline vs Optimized Results"
echo "=============================================="
echo ""

# Function to check CodeQL alerts
check_alerts() {
    local phase=$1
    echo "📊 Checking $phase CodeQL alerts..."
    
    # Check if gh CLI is available
    if ! command -v gh &> /dev/null; then
        echo "❌ GitHub CLI (gh) not found. Please install it first."
        echo "   Visit: https://cli.github.com/"
        return 1
    fi
    
    # Check if jq is available
    if ! command -v jq &> /dev/null; then
        echo "❌ jq not found. Please install it first."
        echo "   Install: brew install jq"
        return 1
    fi
    
    # Get alerts count
    echo "🔍 Fetching alerts from GitHub..."
    ALERTS_JSON=$(gh api repos/sroyad/test-codeql-optimization/code-scanning/alerts 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        echo "❌ Failed to fetch alerts. Make sure CodeQL scanning is enabled."
        echo "   Go to: https://github.com/sroyad/test-codeql-optimization/settings/security"
        return 1
    fi
    
    TOTAL_ALERTS=$(echo "$ALERTS_JSON" | jq 'length')
    HIGH_SEVERITY=$(echo "$ALERTS_JSON" | jq '[.[] | select(.rule.severity == "error")] | length')
    MEDIUM_SEVERITY=$(echo "$ALERTS_JSON" | jq '[.[] | select(.rule.severity == "warning")] | length')
    LOW_SEVERITY=$(echo "$ALERTS_JSON" | jq '[.[] | select(.rule.severity == "note")] | length')
    
    echo "📈 $phase Results:"
    echo "   Total Alerts: $TOTAL_ALERTS"
    echo "   High Severity: $HIGH_SEVERITY"
    echo "   Medium Severity: $MEDIUM_SEVERITY"
    echo "   Low Severity: $LOW_SEVERITY"
    echo ""
    
    # Save results to file
    echo "$TOTAL_ALERTS" > "results-$phase.txt"
    
    return 0
}

# Function to trigger a new scan
trigger_scan() {
    local message=$1
    echo "🚀 Triggering new scan: $message"
    
    # Make a small change to trigger workflow
    echo "# $message - $(date)" >> README.md
    git add README.md
    git commit -m "$message"
    git push origin main
    
    echo "✅ Changes pushed. Workflow should start in a few seconds."
    echo "🔍 Monitor progress: https://github.com/sroyad/test-codeql-optimization/actions"
    echo ""
}

# Main demo flow
echo "🎬 Starting CodeQL Demo..."
echo ""

# Check current status
echo "📋 Current Status Check:"
echo "Repository: sroyad/test-codeql-optimization"
echo "Current workflow: $(cat .github/workflows/call-ci.yml | grep 'uses:')"
echo ""

# Phase 1: Baseline (if not done yet)
echo "📌 PHASE 1: BASELINE (Default CodeQL)"
echo "====================================="
echo ""
echo "If you haven't enabled default CodeQL yet:"
echo "1. Go to: https://github.com/sroyad/test-codeql-optimization/settings/security"
echo "2. Click 'Set up' under CodeQL analysis"
echo "3. Select 'Default'"
echo "4. Commit the changes"
echo "5. Wait 10-15 minutes for completion"
echo ""
read -p "Press Enter when baseline CodeQL scan is complete..."

echo "📊 Recording baseline results..."
check_alerts "BASELINE"

echo ""
echo "📌 PHASE 2: OPTIMIZED (Custom Configuration)"
echo "============================================="
echo ""

# Check if we need to switch to optimized workflow
CURRENT_WORKFLOW=$(cat .github/workflows/call-ci.yml | grep 'uses:')
if [[ $CURRENT_WORKFLOW == *"sroyad/actions"* ]]; then
    echo "✅ Already using optimized workflow"
else
    echo "🔄 Switching to optimized workflow..."
    # This would be done manually or via script
    echo "Please ensure your workflow references sroyad/actions"
fi

echo "🚀 Triggering optimized scan..."
trigger_scan "Optimized CodeQL Scan - $(date +%H:%M:%S)"

echo ""
echo "⏳ Waiting for optimized scan to complete..."
echo "This may take 10-15 minutes."
echo ""
read -p "Press Enter when optimized CodeQL scan is complete..."

echo "📊 Recording optimized results..."
check_alerts "OPTIMIZED"

echo ""
echo "📈 COMPARISON RESULTS"
echo "===================="
if [ -f "results-BASELINE.txt" ] && [ -f "results-OPTIMIZED.txt" ]; then
    BASELINE_COUNT=$(cat results-BASELINE.txt)
    OPTIMIZED_COUNT=$(cat results-OPTIMIZED.txt)
    
    if [ "$BASELINE_COUNT" -gt 0 ]; then
        REDUCTION=$(( (BASELINE_COUNT - OPTIMIZED_COUNT) * 100 / BASELINE_COUNT ))
        echo "Baseline Alerts: $BASELINE_COUNT"
        echo "Optimized Alerts: $OPTIMIZED_COUNT"
        echo "Reduction: $REDUCTION%"
        echo ""
        
        if [ "$REDUCTION" -gt 50 ]; then
            echo "🎉 SUCCESS! Significant reduction in false positives achieved!"
        else
            echo "⚠️  Moderate improvement. May need further tuning."
        fi
    else
        echo "No baseline data available for comparison."
    fi
else
    echo "❌ Missing result files. Please run the demo steps manually."
fi

echo ""
echo "🔍 View detailed results:"
echo "Actions: https://github.com/sroyad/test-codeql-optimization/actions"
echo "Security: https://github.com/sroyad/test-codeql-optimization/security/code-scanning"
echo ""
echo "✅ Demo completed!"
