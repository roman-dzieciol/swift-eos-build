
import Foundation

/**
 GRAMMAR OF A BINARY EXPRESSION

 binary-expression → binary-operator prefix-expression

 binary-expression → assignment-operator try-operator opt prefix-expression

 binary-expression → conditional-operator try-operator opt prefix-expression

 binary-expression → type-casting-operator

 binary-expressions → binary-expression binary-expressions opt

 */
public class SwiftBinaryExpr: SwiftExpr {

}
