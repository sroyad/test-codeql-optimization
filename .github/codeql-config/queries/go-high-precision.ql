/**
 * @name High-Precision Go Security Issues
 * @description Custom queries that focus on real security vulnerabilities with minimal false positives
 * @kind problem
 * @id go/high-precision-security
 * @severity error
 */

import go
import semmle.go.security

// Only flag SQL injection in actual database operations
from CallExpr dbCall, DataFlow::Node source, DataFlow::Node sink
where
  // Real database calls - focus on actual database operations
  (
    dbCall.getTarget().hasQualifiedName("database/sql", "DB", "Query") or
    dbCall.getTarget().hasQualifiedName("database/sql", "DB", "QueryRow") or
    dbCall.getTarget().hasQualifiedName("database/sql", "DB", "Exec") or
    dbCall.getTarget().hasQualifiedName("gorm.io/gorm", "DB", "Raw") or
    dbCall.getTarget().hasQualifiedName("gorm.io/gorm", "DB", "Exec")
  ) and
  // User input flows to SQL query
  TaintTracking::localTaint(source, sink) and
  source.asExpr().(DataFlow::ReadNode) and
  sink.asExpr() = dbCall.getAnArgument() and
  // Exclude test files and generated code
  not source.getFile().getRelativePath().matches("%test%") and
  not source.getFile().getRelativePath().matches("%_test.go") and
  not source.getFile().getRelativePath().matches("%mock%") and
  // Only flag if it's likely user input (not constants or safe values)
  source.asExpr().(CallExpr).getTarget().hasQualifiedName("net/http", "Request", "FormValue") or
  source.asExpr().(CallExpr).getTarget().hasQualifiedName("net/http", "Request", "PostFormValue") or
  source.asExpr().(CallExpr).getTarget().hasQualifiedName("net/http", "Request", "Header", "Get")
select sink, "High-confidence SQL injection from user input: $@", source, "user input"
