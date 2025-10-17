#!/bin/bash
# CodeQL Results Comparison Script

echo "🔍 CodeQL Results Comparison Tool"
echo "================================="
echo ""

# Function to get alert count
get_alert_count() {
    local category=$1
    echo "📊 Fetching alerts for $category..."
    
    # Get alerts from GitHub API
    ALERTS_JSON=$(gh api repos/sroyad/test-codeql-optimization/code-scanning/alerts 2>/dev/null)
    
    if [ $? -ne 0 ]; then
        echo "❌ Failed to fetch alerts. Make sure you're authenticated with gh CLI."
        return 1
    fi
    
    # Filter by category and count
    TOTAL_ALERTS=$(echo "$ALERTS_JSON" | jq 'length')
    CATEGORY_ALERTS=$(echo "$ALERTS_JSON" | jq "[.[] | select(.rule.category == \"$category\")] | length")
    
    echo "   Total alerts: $TOTAL_ALERTS"
    echo "   $category alerts: $CATEGORY_ALERTS"
    echo ""
    
    return 0
}

# Function to show alert details
show_alert_details() {
    local category=$1
    echo "📋 Alert details for $category:"
    
    ALERTS_JSON=$(gh api repos/sroyad/test-codeql-optimization/code-scanning/alerts 2>/dev/null)
    
    if [ $? -eq 0 ]; then
        echo "$ALERTS_JSON" | jq -r ".[] | select(.rule.category == \"$category\") | \"  • \(.rule.name) - \(.rule.severity) - \(.state)\""
    fi
    echo ""
}

echo "🎯 Running CodeQL Results Comparison..."
echo ""

# Check if gh CLI is available
if ! command -v gh &> /dev/null; then
    echo "❌ GitHub CLI (gh) not found. Please install it first."
    echo "   Visit: https://cli.github.com/"
    exit 1
fi

# Check if jq is available
if ! command -v jq &> /dev/null; then
    echo "❌ jq not found. Please install it first."
    echo "   Install: brew install jq"
    exit 1
fi

echo "📊 Current CodeQL Results:"
echo "=========================="

# Get baseline results
get_alert_count "baseline-default"
BASELINE_GO=$(echo "$ALERTS_JSON" | jq "[.[] | select(.rule.category == \"baseline-default\" and (.rule.tags[] | contains(\"go\")))] | length" 2>/dev/null || echo "0")
BASELINE_JS=$(echo "$ALERTS_JSON" | jq "[.[] | select(.rule.category == \"baseline-default\" and (.rule.tags[] | contains(\"javascript\")))] | length" 2>/dev/null || echo "0")

# Get optimized results
get_alert_count "optimized-high-precision"
OPTIMIZED_GO=$(echo "$ALERTS_JSON" | jq "[.[] | select(.rule.category == \"optimized-high-precision\" and (.rule.tags[] | contains(\"go\")))] | length" 2>/dev/null || echo "0")
OPTIMIZED_JS=$(echo "$ALERTS_JSON" | jq "[.[] | select(.rule.category == \"optimized-high-precision\" and (.rule.tags[] | contains(\"javascript\")))] | length" 2>/dev/null || echo "0")

echo "📈 Comparison Results:"
echo "======================"
echo "Baseline (Default):"
echo "  Go alerts: $BASELINE_GO"
echo "  JavaScript alerts: $BASELINE_JS"
echo "  Total: $((BASELINE_GO + BASELINE_JS))"
echo ""
echo "Optimized (Custom):"
echo "  Go alerts: $OPTIMIZED_GO"
echo "  JavaScript alerts: $OPTIMIZED_JS"
echo "  Total: $((OPTIMIZED_GO + OPTIMIZED_JS))"
echo ""

# Calculate improvement
if [ "$BASELINE_GO" -gt 0 ] || [ "$BASELINE_JS" -gt 0 ]; then
    BASELINE_TOTAL=$((BASELINE_GO + BASELINE_JS))
    OPTIMIZED_TOTAL=$((OPTIMIZED_GO + OPTIMIZED_JS))
    
    if [ "$BASELINE_TOTAL" -gt 0 ]; then
        REDUCTION=$(( (BASELINE_TOTAL - OPTIMIZED_TOTAL) * 100 / BASELINE_TOTAL ))
        echo "🎯 Improvement:"
        echo "  Reduction: $REDUCTION%"
        echo "  Alerts reduced: $((BASELINE_TOTAL - OPTIMIZED_TOTAL))"
        
        if [ "$REDUCTION" -gt 50 ]; then
            echo "  ✅ Excellent! Significant reduction in false positives achieved!"
        elif [ "$REDUCTION" -gt 20 ]; then
            echo "  ✅ Good! Moderate reduction in false positives achieved!"
        else
            echo "  ⚠️  Limited improvement. May need further tuning."
        fi
    fi
else
    echo "⚠️  No baseline data available for comparison."
fi

echo ""
echo "🔍 View detailed results:"
echo "  Actions: https://github.com/sroyad/test-codeql-optimization/actions"
echo "  Security: https://github.com/sroyad/test-codeql-optimization/security/code-scanning"
