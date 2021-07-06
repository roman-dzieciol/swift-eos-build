
import Foundation
import SwiftAST


public func canAssign(
    lhsType: SwiftType,
    rhsType: SwiftType,
    options: SwiftOptions
) throws -> Bool {

    let lhsCanonical = lhsType.canonical
    let rhsCanonical = rhsType.canonical

    // If types are equal, can assign
    if lhsCanonical == rhsCanonical {
        return true
    }

//    // `Enum` = `Enum`
//    if let lhsEnum = lhsCanonical.asEnumDecl,
//       let rhsEnum = rhsCanonical.asEnumDecl,
//       lhsEnum === rhsEnum {
//        return rhs.expr
//    }

    // Optional lhs accepts any optionality rhs
    if lhsCanonical.isOptional == true,
       rhsCanonical.isOptional != true,
       try canAssign(lhsType: lhsCanonical, rhsType: rhsCanonical.optional, options: options) {
        return true
    }

    // Immutable lhs pointer accepts any mutability rhs pointer
    if let lhsPointer = lhsCanonical.asPointer,
       let rhsPointer = rhsCanonical.asPointer,
       !lhsPointer.isMutable,
       rhsPointer.isMutable,
       try canAssign(lhsType: lhsPointer, rhsType: rhsPointer.immutable, options: options) {

    }
    //       lhsPointer.pointeeType == rhsPointer.pointeeType {
    //
    //        if !lhsPointer.isMutable || (lhsPointer.isMutable && rhsPointer.isMutable) {
    //            if lhsPointer.isOptional != true {
    //                return
    //            } else {
    //                dbgVar(lhs, rhs)
    //            }
    //        }
    //    }

    // Opaque pointers
    if let lhsPointer = lhsCanonical.asPointer,
       let rhsPointer = rhsCanonical.asPointer,
       let lhsOpaque = lhsPointer.pointeeType.asOpaque,
       let rhsOpaque = rhsPointer.pointeeType.asOpaque,
       lhsOpaque == rhsOpaque {
        return true
    }

    // Union = Union
    //    if let lhsBuiltin = lhsCanonical.asBuiltin,
    //       lhsBuiltin.builtinName.contains("__Unnamed_union"),
    //       rhsCanonical.asDeclRef?.decl.canonical is SwiftUnion {
    //        return rhsInvocation
    //    }

    return false
}

public func canAssign(
    lhs: SwiftVarDecl,
    rhs: SwiftVarDecl,
    options: SwiftOptions
) throws -> Bool {

    if lhs === rhs {
        throw SwiftRefactorError.assignmentToSelf(lhs)
    }

    let lhsType = lhs.type
    let rhsType = rhs.type

    return try canAssign(lhsType: lhsType, rhsType: rhsType, options: options)
}

public func canAssign(
    lhsExpr: SwiftExpr,
    rhsExpr: SwiftExpr,
    lhsDeclContext: SwiftDeclContext,
    rhsDeclContext: SwiftDeclContext,
    options: SwiftOptions
) throws -> Bool {

    guard let lhsType = lhsExpr.evaluateType(in: lhsDeclContext) else {
        throw SwiftRefactorError.unknownExprTypeIn(lhsExpr, lhsDeclContext)
    }

    guard let rhsType = rhsExpr.evaluateType(in: rhsDeclContext) else {
        throw SwiftRefactorError.unknownExprTypeIn(rhsExpr, rhsDeclContext)
    }

    return try canAssign(lhsType: lhsType, rhsType: rhsType, options: options)
}
