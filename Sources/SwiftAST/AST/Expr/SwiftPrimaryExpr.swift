
import Foundation

/**
 GRAMMAR OF A PRIMARY EXPRESSION

 primary-expression → identifier generic-argument-clause opt

 primary-expression → literal-expression

 primary-expression → self-expression

 primary-expression → superclass-expression

 primary-expression → closure-expression

 primary-expression → parenthesized-expression

 primary-expression → tuple-expression

 primary-expression → implicit-member-expression

 primary-expression → wildcard-expression

 primary-expression → key-path-expression

 primary-expression → selector-expression

 primary-expression → key-path-string-expression
 */
public class SwiftPrimaryExpr: SwiftExpr {
}
