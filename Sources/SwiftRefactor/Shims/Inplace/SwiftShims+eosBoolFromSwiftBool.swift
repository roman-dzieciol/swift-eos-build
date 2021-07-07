
import Foundation
import SwiftAST


extension SwiftShims {

    /// `(Bool) -> EOS_Bool`
    static func eosBoolFromSwiftBool(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if let lhsDecl = lhs.type.asDeclRef?.decl.canonical,
           lhsDecl.name == "EOS_Bool",
           let rhsBuiltin = rhs.type.canonical.asBuiltin,
           rhsBuiltin.builtinName == "Bool"
        {
            return .function.eosBoolFromSwiftBool(swiftBool: nested)
        }
        return nil
    }
}

extension SwiftExpr.function {

    /// `(Bool) -> EOS_Bool`
    static func eosBoolFromSwiftBool(swiftBool: SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("eosBoolFromSwiftBool", args: [ swiftBool.arg(nil) ])
    }
}
