/**
 * @name High-Precision JavaScript Security Issues
 * @description Focus on real vulnerabilities in JavaScript/TypeScript with minimal false positives
 * @kind problem
 * @id javascript/high-precision-security
 * @severity error
 */

import javascript
import semmle.javascript.security

// Only flag XSS in actual DOM manipulation that could reach users
from DataFlow::Node source, DataFlow::Node sink, CallExpr domCall
where
  // Real DOM operations that could cause XSS
  (
    domCall.getTarget().hasQualifiedName("document", "write") or
    domCall.getTarget().hasQualifiedName("document", "writeln") or
    domCall.getTarget().hasQualifiedName("element", "innerHTML") or
    domCall.getTarget().hasQualifiedName("element", "outerHTML")
  ) and
  // User input flows to DOM
  TaintTracking::localTaint(source, sink) and
  source.asExpr().(DataFlow::ReadNode) and
  sink.asExpr() = domCall.getAnArgument() and
  // Exclude test files and generated code
  not source.getFile().getRelativePath().matches("%test%") and
  not source.getFile().getRelativePath().matches("%spec%") and
  not source.getFile().getRelativePath().matches("%mock%") and
  // Only flag if it's likely user input (not constants or safe values)
  (
    source.asExpr().(CallExpr).getTarget().hasQualifiedName("req", "query") or
    source.asExpr().(CallExpr).getTarget().hasQualifiedName("req", "body") or
    source.asExpr().(CallExpr).getTarget().hasQualifiedName("req", "params") or
    source.asExpr().(CallExpr).getTarget().hasQualifiedName("window", "location", "search")
  )
select sink, "High-confidence XSS from user input: $@", source, "user input"

// Only flag prototype pollution in actual prototype manipulation
from DataFlow::Node source, DataFlow::Node sink, MemberExpr prototypeAccess
where
  // Real prototype manipulation
  (
    prototypeAccess.getObject().getType().getName() = "Object.prototype" or
    prototypeAccess.getObject().getType().getName() = "Array.prototype"
  ) and
  // User input flows to prototype
  TaintTracking::localTaint(source, sink) and
  source.asExpr().(DataFlow::ReadNode) and
  sink.asExpr() = prototypeAccess.getAnArgument() and
  // Exclude test files
  not source.getFile().getRelativePath().matches("%test%") and
  not source.getFile().getRelativePath().matches("%spec%")
select sink, "High-confidence prototype pollution from user input: $@", source, "user input"
