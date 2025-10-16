#!/bin/bash

# CodeQL False Positive Monitoring Script
# This script helps track the effectiveness of our high-precision configuration

echo "=== CodeQL False Positive Rate Monitor ==="
echo "Repository: $1"
echo "Date: $(date)"
echo ""

# Get repository name from argument or use current repo
REPO_NAME=${1:-$(basename $(git remote get-url origin 2>/dev/null) .git)}

# Function to get CodeQL alerts from GitHub API
get_codeql_alerts() {
    local repo=$1
    gh api repos/AppDirect/$repo/code-scanning/alerts --jq '.[] | {
        number: .number,
        state: .state,
        severity: .rule.severity,
        rule: .rule.name,
        dismissed_by: .dismissed_by,
        dismissed_reason: .dismissed_reason,
        created_at: .created_at
    }' 2>/dev/null || echo "[]"
}

# Function to calculate false positive rate
calculate_false_positive_rate() {
    local total_alerts=$1
    local dismissed_alerts=$2
    
    if [ "$total_alerts" -eq 0 ]; then
        echo "0"
    else
        echo "scale=1; $dismissed_alerts * 100 / $total_alerts" | bc
    fi
}

echo "Analyzing repository: AppDirect/$REPO_NAME"
echo ""

# Get alerts data
ALERTS_DATA=$(get_codeql_alerts "$REPO_NAME")

# Parse data
TOTAL_ALERTS=$(echo "$ALERTS_DATA" | jq -s 'length')
CRITICAL_ALERTS=$(echo "$ALERTS_DATA" | jq -s '[.[] | select(.severity == "error")] | length')
HIGH_ALERTS=$(echo "$ALERTS_DATA" | jq -s '[.[] | select(.severity == "error" or .severity == "warning")] | length')
DISMISSED_ALERTS=$(echo "$ALERTS_DATA" | jq -s '[.[] | select(.state == "dismissed")] | length')
OPEN_ALERTS=$(echo "$ALERTS_DATA" | jq -s '[.[] | select(.state == "open")] | length')

# Calculate false positive rate
FALSE_POSITIVE_RATE=$(calculate_false_positive_rate "$TOTAL_ALERTS" "$DISMISSED_ALERTS")

echo "📊 CodeQL Alert Statistics:"
echo "  Total Alerts: $TOTAL_ALERTS"
echo "  Critical/Error Alerts: $CRITICAL_ALERTS"
echo "  High Severity Alerts: $HIGH_ALERTS"
echo "  Open Alerts: $OPEN_ALERTS"
echo "  Dismissed Alerts: $DISMISSED_ALERTS"
echo "  False Positive Rate: $FALSE_POSITIVE_RATE%"
echo ""

# Analyze dismissed reasons
echo "🔍 Top Dismissed Alert Reasons:"
echo "$ALERTS_DATA" | jq -s '[.[] | select(.state == "dismissed") | .dismissed_reason] | group_by(.) | map({reason: .[0], count: length}) | sort_by(.count) | reverse | .[0:5] | .[] | "  \(.reason): \(.count) alerts"'

echo ""
echo "🎯 Top Alert Types:"
echo "$ALERTS_DATA" | jq -s '[.[] | .rule] | group_by(.) | map({rule: .[0], count: length}) | sort_by(.count) | reverse | .[0:5] | .[] | "  \(.rule): \(.count) alerts"'

echo ""
echo "📈 Recommendations:"
if (( $(echo "$FALSE_POSITIVE_RATE > 50" | bc -l) )); then
    echo "  ⚠️  High false positive rate detected. Consider:"
    echo "     - Reviewing custom queries for better precision"
    echo "     - Adding more specific path exclusions"
    echo "     - Implementing AI-based filtering (Phase 2)"
elif (( $(echo "$FALSE_POSITIVE_RATE < 20" | bc -l) )); then
    echo "  ✅ Good false positive rate! Configuration is working well."
else
    echo "  📊 Moderate false positive rate. Monitor and fine-tune as needed."
fi

echo ""
echo "🔄 Next Steps:"
echo "  1. Review dismissed alerts for patterns"
echo "  2. Update custom queries based on findings"
echo "  3. Consider implementing AI filtering for remaining false positives"
echo ""
echo "💡 To run this script: ./monitor-false-positives.sh [repository-name]"
