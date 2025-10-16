/**
 * @name High-Precision Java Security Issues
 * @description Focus on real vulnerabilities in Java with minimal false positives
 * @kind problem
 * @id java/high-precision-security
 * @severity error
 */

import java
import semmle.java.security

// Only flag SQL injection in actual JDBC operations
from MethodAccess dbCall, DataFlow::Node source, DataFlow::Node sink
where
  // Real database operations that could be vulnerable
  (
    dbCall.getMethod().hasQualifiedName("java.sql", "Statement", "executeQuery") or
    dbCall.getMethod().hasQualifiedName("java.sql", "Statement", "executeUpdate") or
    dbCall.getMethod().hasQualifiedName("java.sql", "Statement", "execute") or
    dbCall.getMethod().hasQualifiedName("java.sql", "PreparedStatement", "setString") or
    dbCall.getMethod().hasQualifiedName("org.springframework.jdbc", "JdbcTemplate", "query") or
    dbCall.getMethod().hasQualifiedName("org.springframework.jdbc", "JdbcTemplate", "update")
  ) and
  // User input flows to SQL
  TaintTracking::localTaint(source, sink) and
  source.asExpr().(DataFlow::ReadNode) and
  sink.asExpr() = dbCall.getAnArgument() and
  // Exclude test files
  not source.getFile().getRelativePath().matches("%test%") and
  not source.getFile().getRelativePath().matches("%Test%") and
  // Only flag if it's likely user input
  (
    source.asExpr().(CallExpr).getTarget().hasQualifiedName("javax.servlet.http", "HttpServletRequest", "getParameter") or
    source.asExpr().(CallExpr).getTarget().hasQualifiedName("javax.servlet.http", "HttpServletRequest", "getHeader") or
    source.asExpr().(CallExpr).getTarget().hasQualifiedName("org.springframework.web", "MultipartFile", "getOriginalFilename")
  )
select sink, "High-confidence SQL injection from user input: $@", source, "user input"

// Only flag command injection in actual command execution
from MethodAccess cmdCall, DataFlow::Node source, DataFlow::Node sink
where
  // Real command execution methods
  (
    cmdCall.getMethod().hasQualifiedName("java.lang", "Runtime", "exec") or
    cmdCall.getMethod().hasQualifiedName("java.lang", "ProcessBuilder", "start") or
    cmdCall.getMethod().hasQualifiedName("java.lang", "ProcessBuilder", "<init>")
  ) and
  // User input flows to command
  TaintTracking::localTaint(source, sink) and
  source.asExpr().(DataFlow::ReadNode) and
  sink.asExpr() = cmdCall.getAnArgument() and
  // Exclude test files
  not source.getFile().getRelativePath().matches("%test%") and
  not source.getFile().getRelativePath().matches("%Test%")
select sink, "High-confidence command injection from user input: $@", source, "user input"
