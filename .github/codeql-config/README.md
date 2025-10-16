# AppDirect CodeQL High-Precision Configuration

This directory contains optimized CodeQL configurations designed to significantly reduce false positives while maintaining comprehensive security coverage.

## 🎯 Goal

Reduce CodeQL false positive rate from 60-80% to 10-20% while maintaining security coverage.

## 📁 Files

- `codeql-config.yml` - Main configuration file with optimized settings
- `queries/go-high-precision.ql` - Custom high-precision queries for Go
- `queries/javascript-high-precision.ql` - Custom high-precision queries for JavaScript/TypeScript
- `queries/java-high-precision.ql` - Custom high-precision queries for Java
- `monitor-false-positives.sh` - Script to monitor false positive rates
- `README.md` - This documentation

## 🔧 Key Optimizations

### 1. Enhanced Query Suites
- Uses `security-extended` and `security-and-quality` instead of default queries
- Custom high-precision queries for each language

### 2. Path Exclusions
- Excludes test files, mocks, examples, and generated code
- Focuses on production code paths only

### 3. Performance Optimization
- Increased RAM allocation (8GB)
- Optimized thread usage
- Extended timeout (15 minutes)

### 4. Precision Improvements
- Custom queries only flag real vulnerabilities with user input
- Excludes edge cases and theoretical issues
- Context-aware filtering

## 📊 Expected Results

### Before Optimization
- 200-500 alerts per repository
- 60-80% false positive rate
- Manual validation required for every alert

### After Optimization
- 20-50 alerts per repository
- 10-20% false positive rate
- 90% reduction in manual validation effort

## 🚀 Usage

The configuration is automatically applied when using the updated workflows:

1. **Go Projects**: Use `opinionated-ci-go.yml`
2. **Java/JavaScript/TypeScript**: Use `ghas.yml`

No additional setup required in individual repositories.

## 📈 Monitoring

Use the monitoring script to track effectiveness:

```bash
./monitor-false-positives.sh [repository-name]
```

This script provides:
- False positive rate analysis
- Alert statistics by severity
- Top dismissed alert reasons
- Recommendations for further optimization

## 🔄 Maintenance

### Regular Tasks
1. Monitor false positive rates monthly
2. Review and update custom queries quarterly
3. Analyze dismissed alerts for pattern improvements

### Custom Query Updates
When adding new custom queries:
1. Focus on high-confidence vulnerabilities only
2. Include proper context filtering
3. Exclude test and generated code
4. Test on sample repositories first

## 🎯 Next Phase: AI Integration

After implementing this configuration, the next step is to integrate AI-based false positive detection for the remaining 10-20% of alerts.

## 📞 Support

For questions or issues with this configuration:
1. Check the monitoring script output
2. Review GitHub Security tab alerts
3. Contact the DevOps team for assistance
