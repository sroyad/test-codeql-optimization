#!/bin/bash
# Python CodeQL Results Comparison Script

echo "🐍 Python CodeQL Results Comparison"
echo "==================================="
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

echo "🎯 Running Python CodeQL Results Comparison..."
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

echo "📊 Current Python CodeQL Results:"
echo "================================="

# Get baseline results
get_alert_count "baseline-default"
BASELINE_COUNT=$(echo "$ALERTS_JSON" | jq "[.[] | select(.rule.category == \"baseline-default\")] | length" 2>/dev/null || echo "0")

# Get optimized results
get_alert_count "optimized-high-precision"
OPTIMIZED_COUNT=$(echo "$ALERTS_JSON" | jq "[.[] | select(.rule.category == \"optimized-high-precision\")] | length" 2>/dev/null || echo "0")

echo "📈 Comparison Results:"
echo "======================"
echo "Baseline (Default): $BASELINE_COUNT alerts"
echo "Optimized (Custom): $OPTIMIZED_COUNT alerts"
echo ""

# Calculate improvement
if [ "$BASELINE_COUNT" -gt 0 ]; then
    REDUCTION=$(( (BASELINE_COUNT - OPTIMIZED_COUNT) * 100 / BASELINE_COUNT ))
    echo "🎯 Improvement:"
    echo "  Reduction: $REDUCTION%"
    echo "  Alerts reduced: $((BASELINE_COUNT - OPTIMIZED_COUNT))"
    echo ""
    
    if [ "$REDUCTION" -gt 50 ]; then
        echo "  ✅ Excellent! Significant reduction in false positives achieved!"
    elif [ "$REDUCTION" -gt 20 ]; then
        echo "  ✅ Good! Moderate reduction in false positives achieved!"
    else
        echo "  ⚠️  Limited improvement. May need further tuning."
    fi
else
    echo "⚠️  No baseline data available for comparison."
fi

echo ""
echo "🔍 View detailed results:"
echo "  Actions: https://github.com/sroyad/test-codeql-optimization/actions"
echo "  Security: https://github.com/sroyad/test-codeql-optimization/security/code-scanning"
