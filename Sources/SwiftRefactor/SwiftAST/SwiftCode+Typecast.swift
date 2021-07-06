

import Foundation
import SwiftAST



public func typecastTo(
    lhs: SwiftVarDecl,
    from rhs: SwiftVarDecl,
    rhsInvocation: SwiftInvocation? = nil,
    options: SwiftOptions = [.allowImplicitPointerCasts]
) throws -> SwiftInvocation {

    if lhs === rhs {
        fatalError()
    }

    let lhsType = lhs.type
    let rhsType = rhs.type

    let lhsCanonical = lhsType.canonical
    let rhsCanonical = rhsType.canonical

    let rhsInvocation = rhsInvocation ?? SwiftInvocation { swift in
        swift.write(name: rhs.name)
    }

    // If types are equal, assign without typecast
    if lhsCanonical == rhsCanonical {
        return rhsInvocation
    }

    // `String` from `char *`
    if lhsCanonical.isString && rhsCanonical.asPointer?.pointeeType.isCChar == true {
        return SwiftInvocation { swift in
            swift.write(name: "String")
            swift.write(nested: "(", ")") {
                swift.write(name: "cString: ")
                rhsInvocation.write(to: swift)
            }
        }
    }

    // `const char *` from `String`
    if lhsCanonical.asPointer?.pointeeType.isCChar == true,
       rhsCanonical.isString,
       options.contains(.allowImplicitPointerCasts) {
        if lhsCanonical.asPointer?.isMutable == false {
            return rhsInvocation
        } else {
            //                fatalError()
        }
    }


    // `UnsafePointer<SomeType>` or `UnsafeMutablePointer<SomeType>` from `inout SomeType`
    if let lhsPointee = lhsCanonical.asPointer?.pointeeType,
       lhsPointee == rhsCanonical,
       rhs.isMutable == true,
       options.contains(.allowImplicitPointerCasts)  {
        return SwiftInvocation { swift in
            swift.write(token: "&")
            rhsInvocation.write(to: swift)
        }
    }

    // `UnsafePointer<SomeType>` or `UnsafeMutablePointer<SomeType>` from `inout Array<SomeType>`
    if let lhsPointee = lhsCanonical.asPointer?.pointeeType,
       lhsPointee == rhsCanonical.asArrayElement,
       rhs.isMutable,
       options.contains(.allowImplicitPointerCasts)  {
        return SwiftInvocation { swift in
            swift.write(token: "&")
            rhsInvocation.write(to: swift)
        }
    }

    // `UnsafePointer<SomeType>` from `Array<SomeType>`
    if let lhsPointee = lhsCanonical.asPointer?.pointeeType,
       lhsPointee == rhsCanonical.asArrayElement,
       lhsCanonical.asPointer?.isMutable == false,
       rhs.isMutable == false,
       options.contains(.allowImplicitPointerCasts) {
        return rhsInvocation
    }

    //            // Pass immutable
    //            if lhsPointee == rhsCanonical.asPointer?.pointeeType,
    //               !rhsCanonical.isMutable {
    //                rhsInvocation.write(to: self)
    //            }

    // Integers of different types
    if lhsCanonical.asBuiltin?.isInt == true,
       rhsCanonical.asBuiltin?.isInt == true,
       let lhsBuiltinName = lhsCanonical.asBuiltin?.builtinName,
       let rhsBuiltinName = rhsCanonical.asBuiltin?.builtinName,
       lhsBuiltinName != rhsBuiltinName {
        switch (lhsBuiltinName, rhsBuiltinName) {
        case ("UInt64", _):
            fatalError()

        case (_, "UInt64"):
            fatalError()

        default:
            return SwiftInvocation { swift in
                swift.write(call: lhsBuiltinName, label: "exactly", with: SwiftCode { swift in rhsInvocation.write(to: swift) })
                swift.write(text: "!")
            }
        }
    }


    if let lhsObject = lhsCanonical.asDeclRef?.decl as? SwiftObject,
       let rhsObject = rhsCanonical.asPointer?.pointeeType.asDeclRef?.decl as? SwiftObject,
       lhsObject.sdk === rhsObject {

        if lhsObject.name == "SwiftEOS_Mod_Identifier" {
            
        }

        let initFunc = try lhsObject.functionInitFromSdkObject()

        return SwiftInvocation { swift in
//            swift.write(name: "try")
            swift.write(name: lhsObject.name)
            swift.write(nested: "(", ")") {
                swift.write(name: "sdkObjectPointer")
                swift.write(token: ":")
                rhsInvocation.write(to: swift)
            }
        }
    }

    //        if let lhsObject = lhsCanonical.asPointer?.pointeeType.asDeclRef?.decl as? SwiftObject {
    //            if let rhsObject = rhsCanonical.asDeclRef?.decl as? SwiftObject {
    //                if lhsObject === rhsObject.sourceAST {
    //                    rhsInvocation.write(to: self)
    //                    write(token: ".")
    //                    write(name: "__pointer")
    //                    return
    //                }
    //            }
    //        }

    if let lhsObject = lhsCanonical.asDeclRef?.decl as? SwiftObject {
        if let rhsObject = rhsCanonical.asPointer?.pointeeType.asDeclRef?.decl as? SwiftObject {
            if lhsObject === rhsObject {
                return SwiftInvocation { swift in
                    rhsInvocation.write(to: swift)
                    swift.write(token: ".")
                    swift.write(name: "pointee")
                }
            }
        }
    }


    //        self.StatThresholds = swiftyObjects(from: pointer.pointee.StatThresholds, count: Int(exactly: pointer.pointee.StatThresholdsCount)!)

    //        Cannot assign value of type
    //        'UnsafePointer<EOS_Achievements_StatThresholds>?' (aka 'Optional<UnsafePointer<_tagEOS_Achievements_StatThresholds>>') to type
    //        '[SwiftEOS_Achievements_StatThresholds]?'

    //    } else if let resolvedType = parm.type.withoutTypealias as? SwiftDeclRefType,
    //                          !parm.type.isBuiltin("EOS_Bool"),
    //                          !(resolvedType.decl is SwiftEnum),
    //                          parm.type.isOpaquePointer() != true {
    //
    //                    swift.write(resolvedType)
    //                    swift.write(nested: "(", ")") {
    //                        swift.write(text: "from")
    //                        swift.write(token: ":")
    //                        swift.write(name: sdkObjectParm.name)
    //                        swift.write(text: ".")
    //                        swift.write(name: parm.name)
    //                    }
    //

    // Similar pointers
    if let lhsPointer = lhsCanonical.asPointer, let rhsPointer = rhsCanonical.asPointer,
       lhsPointer.pointeeType == rhsPointer.pointeeType {

        if !lhsPointer.isMutable || (lhsPointer.isMutable && rhsPointer.isMutable) {
            if lhsPointer.isOptional != true {
                return rhsInvocation
            } else {
                dbgVar(lhs, rhs)
            }
        }


    }


    // Union = Union
    if let lhsBuiltin = lhsCanonical.asBuiltin,
       lhsBuiltin.builtinName.contains("__Unnamed_union"),
       rhsCanonical.asDeclRef?.decl.canonical is SwiftUnion {
        return rhsInvocation
    }

    // Actor = actor handle
    if let lhsObject = lhsCanonical.asDeclRef?.decl as? SwiftObject,
       lhsObject.name.hasSuffix("_Actor"),
       let lhsHandle = lhsObject.members.first(where: { $0.name == "Handle" }),
       let lhsOpaque = lhsHandle.type.canonical.asOpaquePointer?.pointeeType.asOpaque,
       let rhsOpaque = rhsCanonical.asOpaquePointer?.pointeeType.asOpaque,
       lhsOpaque == rhsOpaque
    {
        return SwiftInvocation { swift in
            swift.write(name: lhsObject.name)
            swift.write(token: "(")
            swift.write(name: lhsHandle.name)
            swift.write(token: ":")
            rhsInvocation.write(to: swift)
            swift.write(token: ")")
        }
    }

//    if let lhsPointee = lhsPointer?.pointeeType,
//       lhsPointer?.isMutable == true,
//       rhs.isMutable {
//        return rhsInvocation
//    }

    //        if let lhsGeneric = lhsCanonical as? SwiftGenericType,
    //           lhsGeneric.genericType.asBuiltin?.builtinName == "SwiftEOS_Notification",
    //           rhs.type.asDeclRef?.decl.name == "EOS_NotificationId" {
    //
    //            rhsInvocation.write(to: self)
    //            return
    //        }

    //        NSLog("unknown typecast in \(stack.last ?? ""): \(lhs.name) = \(rhs.name), \nlhs: \(lhs.type), \nrhs: \(rhs.type)")
    //        fatalError("unknown typecast in \(stack.last ?? ""): \(lhs.name) = \(rhs.name), \nlhs: \(lhs.type), \nrhs: \(rhs.type)")
    throw SwiftyError.unknownTypecast(lhs,rhs)
}

extension SwiftOutputStream {

    /**
     In a function call expression, if the argument and parameter have a different type,
     the compiler tries to make their types match by applying one of the implicit conversions in the following list:

     - inout SomeType can become UnsafePointer<SomeType> or UnsafeMutablePointer<SomeType>
     - inout Array<SomeType> can become UnsafePointer<SomeType> or UnsafeMutablePointer<SomeType>
     - Array<SomeType> can become UnsafePointer<SomeType>
     - String can become UnsafePointer<CChar>

     The following two function calls are equivalent:

     func unsafeFunction(pointer: UnsafePointer<Int>) {
     // ...
     }
     var myNumber = 1234

     unsafeFunction(pointer: &myNumber)
     withUnsafePointer(to: myNumber) { unsafeFunction(pointer: $0) }

     A pointer that’s created by these implicit conversions is valid only for the duration of the function call.
     To avoid undefined behavior, ensure that your code never persists the pointer after the function call ends.

     # NOTE
     When implicitly converting an array to an unsafe pointer, Swift ensures that the array’s storage is contiguous by converting or copying the array as needed.
     For example, you can use this syntax with an array that was bridged to Array from an NSArray subclass that makes no API contract about its storage.
     If you need to guarantee that the array’s storage is already contiguous, so the implicit conversion never needs to do this work, use ContiguousArray instead of Array.

     Using & instead of an explicit function like withUnsafePointer(to:) can help make calls to low-level C functions more readable,
     especially when the function takes several pointer arguments.
     However, when calling functions from other Swift code, avoid using & instead of using the unsafe APIs explicitly.

     https://docs.swift.org/swift-book/ReferenceManual/Expressions.html
     */
    //    public func write(typecastTo lhs: SwiftArgument, from rhs: SwiftArgument?, rhsInvocation: @escaping (SwiftOutputStream) -> Void) {
    //        // If one of the types cannot be determined, assign without typecast
    //        guard let lhsType = lhs.type(), let rhsType = rhs?.type() else {
    //            return rhsInvocation.write(to: self)
    //        }
    //        write(typecastTo: lhsType, from: rhsType, rhsInvocation: rhsInvocation)
    //    }

//    public func write(typecastTo lhs: SwiftVarDecl, from rhs: SwiftVarDecl, rhsInvocation: @escaping (SwiftOutputStream) -> Void) {
//        write(typecastTo: lhs, from: rhs, rhsInvocation: SwiftInvocation.init(output: rhsInvocation) )
//    }
//
//
//    public func write(typecastTo lhs: SwiftVarDecl, from rhs: SwiftVarDecl, rhsInvocation: SwiftInvocation) -> Bool {
//        do {
//            try write(throwingTypecastTo: lhs, from: rhs, rhsInvocation: rhsInvocation)
//            return true
//        } catch SwiftyError.unknownTypecast {
////            return false
//
//
//            write(debug: "TODO: unknown typecast:", lhs: lhs, rhs: rhs)
//            return false
////            fatalError("")
//        } catch {
//            fatalError("\(error)")
//        }
//    }

    public func write(debug comment: String, lhs: SwiftVarDecl, rhs: SwiftVarDecl) {
        write(textIfNeeded: "\n")
        write(text: "/* \(comment) -- \(lhs.name) = \(rhs.name)")
        write(textIfNeeded: "\n")
        write(text: "lhs: \(lhs.type)")
        write(textIfNeeded: "\n")
        write(text: "rhs: \(rhs.type)")
        write(textIfNeeded: "\n")
        write(text: "aka lhs: \(lhs.type.canonical)")
        write(textIfNeeded: "\n")
        write(text: "aka rhs: \(rhs.type.canonical)")
        write(textIfNeeded: "\n")
        write(text: "stack: \(stack)")
        write(textIfNeeded: "\n")
        write(text: "*/")
        write(textIfNeeded: "\n")
    }

//    public func write(throwingTypecastTo lhs: SwiftVarDecl, from rhs: SwiftVarDecl, rhsInvocation: SwiftInvocation) throws {
//
//        let invocation = try typecastTo(lhs: lhs, from: rhs, rhsInvocation: rhsInvocation)
//        invocation.write(to: self)
//    }
}

