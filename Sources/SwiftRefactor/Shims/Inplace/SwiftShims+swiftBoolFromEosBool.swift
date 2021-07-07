
import Foundation
import SwiftAST

extension SwiftShims {

    /// `(EOS_Bool) -> Bool`
    static func swiftBoolFromEosBool(lhs: SwiftVarDecl, rhs: SwiftVarDecl, nested: SwiftExpr) throws -> SwiftExpr? {

        if let lhsBuiltin = lhs.type.canonical.asBuiltin
            , let rhsDecl = rhs.type.asDeclRef?.decl.canonical
            , lhsBuiltin.builtinName == "Bool"
            , rhsDecl.name == "EOS_Bool"
        {
            return .try(.function.swiftBoolFromEosBool(eosBool: nested))
        }
        return nil
    }
}

extension SwiftExpr.function {

    /// `(EOS_Bool) -> Bool`
    static func swiftBoolFromEosBool(eosBool: SwiftExpr) -> SwiftExpr {
        SwiftFunctionCallExpr.named("swiftBoolFromEosBool", args: [ eosBool.arg(nil) ])
    }
}
