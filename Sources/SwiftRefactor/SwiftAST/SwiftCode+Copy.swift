

import Foundation
import SwiftAST
//
//public func copyingInvocation2(
//    lhs: SwiftVarDecl,
//    rhs: SwiftVarDecl,
//    nested: SwiftExpr,
//    options: SwiftOptions = []
//) throws -> SwiftExpr {
//
//    if lhs === rhs {
//        fatalError()
//    }
//
//    return nested
//
//    let lhs.type = lhs.type
//    let rhs.type = rhs.type
//
//    let lhs.type.canonical = lhs.type.canonical
//    let rhs.type.canonical = rhs.type.canonical
//
////    let rhsInvocation = SwiftInvocation { swift in
////        rhsPrefix?.write(to: swift)
////        swift.write(name: rhs.name)
////    }
//
////    let rhsInvocation = nested
////    return rhsInvocation
//
//
//
//    if let shimmed = try nested.shimmed(.inplaceShims, lhs: lhs, rhs: rhs) {
//        return shimmed
//    }
//
//
//    // Managed `Pointer<Byte>` = `Byte?`, RequestedChannel
////    if options.contains(.withPointerManager),
////       !rhs.isInOutParm,
////       lhs.name == "RequestedChannel",
////       let lhsPointer = lhs.type.canonical.asPointer,
////       let lhsBuiltin = lhsPointer.pointeeType.asBuiltin,
////       lhsBuiltin.isByte,
////       let rhsBuiltin = rhs.type.canonical.asBuiltin,
////       rhsBuiltin.isByte,
////       rhsBuiltin.isOptional == true {
////
////        return SwiftInvocation { swift in
////
////            swift.write(rhsPrefix)
////            swift.write(optRef: rhs)
////            swift.write(token: ".")
////            swift.write(name: "map")
////            swift.write(nested: "{", "}") {
////                swift.write(name: "pointerManager")
////                swift.write(token: ".")
////                if lhsPointer.isMutable {
////                    swift.write(name: "managedMutablePointer")
////                } else {
////                    swift.write(name: "managedPointer")
////                }
////                swift.write(nested: "(", ")") {
////                    swift.write(name: "copyingValue")
////                    swift.write(token: ":")
////                    swift.write(name: "$0")
////                }
////            }
////            swift.write(token: "??")
////            swift.write(name: "nil")
////        }
////    }
//
//    // `Byte?` = `Pointer<Byte>`, RequestedChannel
//    if options.contains(.withPointerManager),
//       !rhs.isInOutParm,
//       lhs.name == "RequestedChannel",
//       let lhsBuiltin = lhs.type.canonical.asBuiltin,
//       lhsBuiltin.isByte,
//       lhsBuiltin.isOptional == true,
//       let rhsPointer = rhs.type.canonical.asPointer,
//       let rhsBuiltin = rhsPointer.pointeeType.asBuiltin,
//       rhsBuiltin.isByte {
//        return nested.member("pointee")
//    }
//
//
//
//    // `Array` = `Pointer array`
//    if let lhsArray = lhs.type.canonical.asArray,
//       let rhsPointer = rhs.type.canonical.asPointer {
//
//        // Ensure pointer array has count specified
//        guard let lhsArrayCount = lhs.linked(.arrayLength) as? SwiftVarDecl,
//              let rhsArrayCount = lhsArrayCount.linked(.sdk) as? SwiftVarDecl,
//              let rhsArrayBuffer = lhs.linked(.sdk) as? SwiftVarDecl,
//              rhs === rhsArrayBuffer else {
//                  fatalError("unknown typecast: \(lhs.name) = \(rhs.name), \nlhs: \(lhs.type), \nrhs: \(rhs.type)")
//              }
//
////        let rhsArrayCountInvocation = SwiftInvocation { swift in
////            rhsPrefix?.write(to: swift)
////            swift.write(rhsArrayCount.name)
////        }
//
//        let arrayCountExpr = rhsArrayCount.expr
////        let arrayCountInvocation = try typecastTo(lhs: lhsArrayCount, from: rhsArrayCount, rhsInvocation: rhsArrayCountInvocation, options: [])
//
//        // `[SwiftObject]` = `Pointer<SdkObject>`
//        if let lhsObject = lhsArray.elementType.asDeclRef?.decl as? SwiftObject,
//           let rhsObject = rhsPointer.pointeeType.asDeclRef?.decl as? SwiftObject,
//           lhsObject.linked(.sdk)?.canonical === rhsObject.canonical {
//            _ = try (lhsObject.canonical as! SwiftObject).functionInitFromSdkObject()
//            return lhs.expr.member(.function.mapBufferToObjects(
//                arrayCount: arrayCountExpr,
//                objectInit: .function.initFromSdkObject(.string("$0"))))
//        }
//
//        // `[String]` = `Pointer<Pointer<CChar>>`
//        if lhsArray.elementType.asString != nil,
//           let rhsInnerPointer = rhsPointer.pointeeType.asPointer,
//           rhsInnerPointer.pointeeType.asCChar != nil {
//
//            return lhs.expr.member(.function.mapBufferToObjects(
//                arrayCount: arrayCountExpr,
//                objectInit: .function.string(cString: .string("$0"))))
//        }
//
//        // `[UInt8]` = `Pointer<Void>`
//        if lhsArray.elementType.asByte != nil,
//           rhsPointer.pointeeType.isVoid {
//            return .function.array(.function.unsafeRawBufferPointer(start: nested, count: arrayCountExpr))
//        }
//
//        // `[Pointer<Opaque>]` = `Pointer<Pointer<Opaque>>`
//        if let lhsOpaquePtr = lhsArray.elementType.asOpaquePointer,
//           let rhsOpaquePtr = rhsPointer.pointeeType.asOpaquePointer,
//           lhsOpaquePtr == rhsOpaquePtr {
//            return .function.array(.function.unsafeBufferPointer(start: nested, count: arrayCountExpr))
//        }
//    }
//
//
//
//    dbgVar(lhs, rhs)
//    throw SwiftyError.unknownCopy(lhs,rhs)
//}
////
////
////
////import Foundation
////import SwiftAST
////
////public func copyingInvocation(
////    lhs: SwiftVarDecl,
////    rhs: SwiftVarDecl,
////    rhsPrefix: SwiftInvocation? = SwiftInvocation { _ in },
////    options: SwiftOptions = []
////) throws -> SwiftInvocation {
////
////    if lhs === rhs {
////        fatalError()
////    }
////
////    let lhs.type = lhs.type
////    let rhs.type = rhs.type
////
////    let lhs.type.canonical = lhs.type.canonical
////    let rhs.type.canonical = rhs.type.canonical
////
////    let rhsInvocation = SwiftInvocation { swift in
////        rhsPrefix?.write(to: swift)
////        swift.write(name: rhs.name)
////    }
////    //    return rhsInvocation
////
////    // *Handle pointers
////    if let lhsPointer = lhs.type.canonical.asPointer,
////       let rhsPointer = rhs.type.canonical.asPointer,
////       lhs.name.hasSuffix("Handle"),
////       rhs.name.hasSuffix("Handle") {
////        return rhsInvocation
////    }
////
////    // Void pointer exceptions
////    if let lhsPointer = lhs.type.canonical.asPointer,
////       let rhsPointer = rhs.type.canonical.asPointer,
////       lhsPointer.pointeeType.isVoid,
////       rhsPointer.pointeeType.isVoid {
////        if (lhs.name == "ClientData" ||
////            lhs.name == "SystemAuthCredentialsOptions" ||
////            lhs.name == "SystemInitializeOptions") {
////            return rhsInvocation
////        }
////        if lhs.name.contains("Reserved") {
////            return SwiftInvocation { swift in
////                swift.write(name: "nil")
////            }
////        }
////    }
////
////    // TODO: Tuples
////    if let lhsBuiltin = lhs.type.canonical.asBuiltin,
////       let rhsBuiltin = rhs.type.canonical.asBuiltin,
////       lhsBuiltin == rhsBuiltin,
////       lhsBuiltin.builtinName.hasPrefix("("),
////       lhsBuiltin.builtinName.hasSuffix(")"),
////       lhs.name == "SocketName" {
////        return rhsInvocation
////    }
////
////    // `String` = `Pointer<CChar>`
////    if lhs.type.canonical.asString != nil,
////       rhs.type.canonical.asPointer?.pointeeType.asCChar != nil {
////        return SwiftInvocation { swift in
////            swift.write(name: "String")
////            swift.write(nested: "(", ")") {
////                swift.write(name: "cString")
////                swift.write(token: ":")
////                rhsInvocation.write(to: swift)
////            }
////        }
////    }
////
////    // Managed `Pointer<CChar>?` = `String?`
////    if options.contains(.withPointerManager),
////       !rhs.isInOutParm,
////       let lhsPointer = lhs.type.canonical.asPointer,
////       lhsPointer.pointeeType.isCChar,
////       rhs.type.canonical.isString
////    {
////        return SwiftInvocation { swift in
////            swift.write(name: "pointerManager")
////            swift.write(token: ".")
////            if lhsPointer.isMutable {
////                swift.write(name: "managedMutablePointerToBuffer")
////            } else {
////                swift.write(name: "managedPointerToBuffer")
////            }
////            swift.write(nested: "(", ")") {
////                swift.write(name: "copyingArray")
////                swift.write(token: ":")
////                swift.write(rhsPrefix)
////                swift.write(optRef: rhs)
////                swift.write(token: ".")
////                swift.write(name: "utf8CString")
////            }
////        }
////    }
////
////    // Managed `Pointer<Pointer<CChar>>` = `[String]`
////    if options.contains(.withPointerManager),
////       !rhs.isInOutParm,
////       let lhsPointer = lhs.type.canonical.asPointer,
////       let lhsInnerPointer = lhsPointer.pointeeType.asPointer,
////       lhsInnerPointer.pointeeType.isCChar,
////       let rhsArray = rhs.type.canonical.asArray,
////       rhsArray.elementType.isString
////    {
////        return SwiftInvocation { swift in
////            swift.write(name: "pointerManager")
////            swift.write(token: ".")
////            swift.write(name: "managedMutablePointerToBufferOfPointers")
////            swift.write(nested: "(", ")") {
////                swift.write(name: "copyingArray")
////                swift.write(token: ":")
////                swift.write(rhsPrefix)
////                swift.write(optRef: rhs)
////                swift.write(token: ".")
////                swift.write(name: "map")
////                swift.write(token: "{")
////                swift.write(name: "$0")
////                swift.write(token: ".")
////                swift.write(name: "utf8CString")
////                swift.write(token: "}")
////            }
////
////        }
////    }
////
////    // Managed `Pointer<Void or UInt8 or Int8>` = `[UInt8 or Int8]`
////    if options.contains(.withPointerManager),
////       !rhs.isInOutParm,
////       let lhsPointer = lhs.type.canonical.asPointer,
////       (lhsPointer.pointeeType.isVoid || lhsPointer.pointeeType.isByte),
////       let rhsArray = rhs.type.canonical.asArray,
////       (rhsArray.elementType.isVoid || rhsArray.elementType.isByte)
////
////    {
////        return SwiftInvocation { swift in
////            swift.write(name: "pointerManager")
////            swift.write(token: ".")
////            if lhsPointer.isMutable {
////                swift.write(name: "managedMutablePointerToBuffer")
////            } else {
////                swift.write(name: "managedPointerToBuffer")
////            }
////            swift.write(nested: "(", ")") {
////                swift.write(name: "copyingArray")
////                swift.write(token: ":")
////                swift.write(rhsInvocation)
////            }
////        }
////    }
////
////    // Managed `Pointer<SdkObject>` = `[SwiftObject]`
////    if options.contains(.withPointerManager),
////       !rhs.isInOutParm,
////       let lhsPointer = lhs.type.canonical.asPointer,
////       let lhsDeclRef = lhsPointer.pointeeType.asDeclRef,
////       let lhsDecl = lhsDeclRef.decl.canonical as? SwiftObject,
////       let rhsArray = rhs.type.canonical.asArray,
////       let rhsDeclRef = rhsArray.elementType.asDeclRef,
////       let rhsDecl = rhsDeclRef.decl.canonical as? SwiftObject,
////       lhsDecl === rhsDecl.sdk,
////       rhsDecl.inSwiftEOS {
////
////        try rhsDecl.addSdkObjectFactory()
////
////        return SwiftInvocation { swift in
////            swift.write(name: "pointerManager")
////            swift.write(token: ".")
////            if lhsPointer.isMutable {
////                swift.write(name: "managedMutablePointerToBuffer")
////            } else {
////                swift.write(name: "managedPointerToBuffer")
////            }
////            swift.write(nested: "(", ")") {
////                swift.write(name: "copyingArray")
////                swift.write(token: ":")
////                swift.write(rhsPrefix)
////                swift.write(optRef: rhs)
////                swift.write(token: ".")
////                swift.write(name: "map")
////                swift.write(token: "{")
////                swift.write(name: "$0")
////                swift.write(token: ".")
////                swift.write(name: SwiftName.buildSdkObject)
////                swift.write(token: "(")
////                swift.write(name: "pointerManager")
////                swift.write(token: ":")
////                swift.write(name: "pointerManager")
////                swift.write(token: ")")
////                swift.write(token: "}")
////            }
////        }
////    }
////
////    // Managed `Pointer<SdkObject>` = `SwiftObject`
////    if options.contains(.withPointerManager),
////       !rhs.isInOutParm,
////       let lhsPointer = lhs.type.canonical.asPointer,
////       let lhsDeclRef = lhsPointer.pointeeType.asDeclRef,
////       let lhsDecl = lhsDeclRef.decl.canonical as? SwiftObject,
////       let rhsDeclRef = rhs.type.canonical.asDeclRef,
////       let rhsDecl = rhsDeclRef.decl.canonical as? SwiftObject,
////       lhsDecl === rhsDecl.sdk,
////       rhsDecl.inSwiftEOS {
////
////        try rhsDecl.addSdkObjectFactory()
////
////        return SwiftInvocation { swift in
////            swift.write(name: "pointerManager")
////            swift.write(token: ".")
////            if lhsPointer.isMutable {
////                swift.write(name: "managedMutablePointer")
////            } else {
////                swift.write(name: "managedPointer")
////            }
////            swift.write(nested: "(", ")") {
////                swift.write(name: "copyingValue")
////                swift.write(token: ":")
////                swift.write(rhsPrefix)
////                swift.write(optRef: rhs)
////                swift.write(token: ".")
////                swift.write(name: SwiftName.buildSdkObject)
////                swift.write(token: "(")
////                swift.write(name: "pointerManager")
////                swift.write(token: ":")
////                swift.write(name: "pointerManager")
////                swift.write(token: ")")
////            }
////        }
////    }
////
////    // Managed `Pointer<Byte>` = `Byte?`, RequestedChannel
////    if options.contains(.withPointerManager),
////       !rhs.isInOutParm,
////       lhs.name == "RequestedChannel",
////       let lhsPointer = lhs.type.canonical.asPointer,
////       let lhsBuiltin = lhsPointer.pointeeType.asBuiltin,
////       lhsBuiltin.isByte,
////       let rhsBuiltin = rhs.type.canonical.asBuiltin,
////       rhsBuiltin.isByte,
////       rhsBuiltin.isOptional == true {
////
////        return SwiftInvocation { swift in
////
////            swift.write(rhsPrefix)
////            swift.write(optRef: rhs)
////            swift.write(token: ".")
////            swift.write(name: "map")
////            swift.write(nested: "{", "}") {
////                swift.write(name: "pointerManager")
////                swift.write(token: ".")
////                if lhsPointer.isMutable {
////                    swift.write(name: "managedMutablePointer")
////                } else {
////                    swift.write(name: "managedPointer")
////                }
////                swift.write(nested: "(", ")") {
////                    swift.write(name: "copyingValue")
////                    swift.write(token: ":")
////                    swift.write(name: "$0")
////                }
////            }
////            swift.write(token: "??")
////            swift.write(name: "nil")
////        }
////    }
////
////    // `Byte?` = `Pointer<Byte>`, RequestedChannel
////    if options.contains(.withPointerManager),
////       !rhs.isInOutParm,
////       lhs.name == "RequestedChannel",
////       let lhsBuiltin = lhs.type.canonical.asBuiltin,
////       lhsBuiltin.isByte,
////       lhsBuiltin.isOptional == true,
////       let rhsPointer = rhs.type.canonical.asPointer,
////       let rhsBuiltin = rhsPointer.pointeeType.asBuiltin,
////       rhsBuiltin.isByte {
////
////        return SwiftInvocation { swift in
////            swift.write(rhsPrefix)
////            swift.write(optRef: rhs)
////            swift.write(token: ".")
////            swift.write(name: "map")
////            swift.write(nested: "{", "}") {
////                swift.write(name: "$0")
////                swift.write(token: ".")
////                swift.write(name: "pointee")
////            }
////        }
////    }
////
////    // `SdkObject` = `SwiftObject`
////    if options.contains(.withPointerManager),
////       !rhs.isInOutParm,
////       let lhsDeclRef = lhs.type.canonical.asDeclRef,
////       let lhsDecl = lhsDeclRef.decl.canonical as? SwiftObject,
////       let rhsDeclRef = rhs.type.canonical.asDeclRef,
////       let rhsDecl = rhsDeclRef.decl.canonical as? SwiftObject,
////       lhsDecl === rhsDecl.sdk,
////       !lhsDecl.inSwiftEOS,
////       rhsDecl.inSwiftEOS {
////
////        try rhsDecl.addSdkObjectFactory()
////
////        return SwiftInvocation { swift in
////            swift.write(rhsPrefix)
////            swift.write(optRef: rhs)
////            swift.write(token: ".")
////            swift.write(name: SwiftName.buildSdkObject)
////            swift.write(token: "(")
////            swift.write(name: "pointerManager")
////            swift.write(token: ":")
////            swift.write(name: "pointerManager")
////            swift.write(token: ")")
////        }
////    }
////
////    // `SwiftObject` = `SdkObject`
////    if options.contains(.withPointerManager),
////       !rhs.isInOutParm,
////       let lhsDeclRef = lhs.type.canonical.asDeclRef,
////       let lhsDecl = lhsDeclRef.decl.canonical as? SwiftObject,
////       let rhsDeclRef = rhs.type.canonical.asDeclRef,
////       let rhsDecl = rhsDeclRef.decl.canonical as? SwiftObject,
////       lhsDecl.sdk === rhsDecl,
////       lhsDecl.inSwiftEOS,
////       !rhsDecl.inSwiftEOS {
////
////        _ = try lhsDecl.functionInitFromSdkObject()
////
////        return SwiftInvocation { swift in
////            swift.write(name: lhsDecl.name)
////            swift.write(token: "(")
////            swift.write(name: "sdkObject")
////            swift.write(token: ":")
////            swift.write(rhsInvocation)
////            swift.write(token: ")")
////        }
////    }
////
////    // Managed `Pointer<Pointer<Opaque>>` = `[Pointer<Opaque>]`
////    if options.contains(.withPointerManager),
////       !rhs.isInOutParm,
////       let lhsPointer = lhs.type.canonical.asPointer,
////       let lhsInnerPointer = lhsPointer.pointeeType.asPointer,
////       let lhsOpaquePtr = lhsInnerPointer.asOpaquePointer,
////       let rhsArray = rhs.type.canonical.asArray,
////       let rhsOpaquePtr = rhsArray.elementType.asOpaquePointer,
////       lhsOpaquePtr == rhsOpaquePtr {
////
////        return SwiftInvocation { swift in
////            swift.write(name: "pointerManager")
////            swift.write(token: ".")
////            if lhsPointer.isMutable {
////                swift.write(name: "managedMutablePointerToBuffer")
////            } else {
////                swift.write(name: "managedPointerToBuffer")
////            }
////            swift.write(nested: "(", ")") {
////                swift.write(name: "copyingArray")
////                swift.write(token: ":")
////                swift.write(rhsInvocation)
////            }
////        }
////
////
////    }
////
////
////    // TODO: `SDK Union` = `Swifty Union`
////    if options.contains(.allowUnions),
////       let lhsBuiltin = lhs.type.canonical.asBuiltin,
////       lhsBuiltin.builtinName.contains("__Unnamed_union"),
////       rhs.type.canonical.asDeclRef?.decl.canonical is SwiftUnion {
////        return rhsInvocation
////    }
////
////    // TODO: `Swifty Union` = `SDK Union`
////    if options.contains(.allowUnions),
////       lhs.type.canonical.asDeclRef?.decl.canonical is SwiftUnion,
////       let rhsBuiltin = rhs.type.canonical.asBuiltin,
////       rhsBuiltin.builtinName.contains("__Unnamed_union") {
////        return rhsInvocation
////    }
////
////    // TODO: `Function pointer` = `Function pointer`
////    if lhs.type.canonical.asFunction != nil,
////       rhs.type.canonical.asFunction != nil,
////       lhs.type.canonical == rhs.type.canonical {
////        return rhsInvocation
////    }
////
////    // `String` = `String`
////    if lhs.type.canonical.asString != nil,
////       rhs.type.canonical.asString != nil {
////        return rhsInvocation
////    }
////
////    // `Float` = `Float`
////    if lhs.type.canonical.asBuiltin?.builtinName == "Float",
////       rhs.type.canonical.asBuiltin?.builtinName == "Float" {
////        return rhsInvocation
////    }
////
////    // `Double` = `Double`
////    if lhs.type.canonical.asBuiltin?.builtinName == "Double",
////       rhs.type.canonical.asBuiltin?.builtinName == "Double" {
////        return rhsInvocation
////    }
////
////    // `Integer` = `Integer`
////    if let lhsInt = lhs.type.canonical.asInt,
////       let rhsInt = rhs.type.canonical.asInt {
////
////        // Integers of same types
////        if lhsInt.builtinName == rhsInt.builtinName {
////            return rhsInvocation
////        }
////
////        // Integers of different types
////        else {
////            switch (lhsInt.builtinName, rhsInt.builtinName) {
////            case ("UInt64", _):
////                fatalError()
////
////            case (_, "UInt64"):
////                fatalError()
////
////            default:
////                return SwiftInvocation { swift in
////                    swift.write(call: lhsInt.builtinName, label: "exactly", with: SwiftCode { swift in rhsInvocation.write(to: swift) })
////                    swift.write(text: "!")
////                }
////            }
////        }
////    }
////
////    // `Enum` = `Enum`
////    if let lhsEnum = lhs.type.canonical.asEnumDecl,
////       let rhsEnum = rhs.type.canonical.asEnumDecl,
////       lhsEnum === rhsEnum {
////        return rhsInvocation
////    }
////
////    // `Swift Object` = `Pointer<SDK Object>`
////    if let lhsObject = lhs.type.canonical.asDeclRef?.decl as? SwiftObject,
////       let rhsObject = rhs.type.canonical.asPointer?.pointeeType.asDeclRef?.decl as? SwiftObject,
////       lhsObject.sdk?.canonical === rhsObject.canonical {
////
////        _ = try lhsObject.functionInitFromSdkObject()
////
////        return SwiftInvocation { swift in
////            //            swift.write(name: "try")
////            swift.write(name: lhsObject.name)
////            swift.write(nested: "(", ")") {
////                swift.write(name: SwiftName.sdkObject)
////                swift.write(token: ":")
////                swift.write(rhsPrefix)
////                swift.write(optRef: rhs)
////                swift.write(token: ".")
////                swift.write(token: "pointee")
////            }
////        }
////    }
////
////    // `Array` = `Pointer array`
////    if let lhsArray = lhs.type.canonical.asArray,
////       let rhsPointer = rhs.type.canonical.asPointer {
////
////        // Ensure pointer array has count specified
////        guard let lhsArrayCount = lhs.linked(.arrayLength) as? SwiftVarDecl,
////              let rhsArrayCount = lhsArrayCount.linked(.sdk) as? SwiftVarDecl,
////              let rhsArrayBuffer = lhs.linked(.sdk) as? SwiftVarDecl,
////              rhs === rhsArrayBuffer else {
////                  fatalError("unknown typecast: \(lhs.name) = \(rhs.name), \nlhs: \(lhs.type), \nrhs: \(rhs.type)")
////              }
////
////        let rhsArrayCountInvocation = SwiftInvocation { swift in
////            rhsPrefix?.write(to: swift)
////            swift.write(rhsArrayCount.name)
////        }
////
////        let arrayCountInvocation = try typecastTo(lhs: lhsArrayCount, from: rhsArrayCount, rhsInvocation: rhsArrayCountInvocation, options: [])
////
////        // `[SwiftObject]` = `Pointer<SdkObject>`
////        if let lhsObject = lhsArray.elementType.asDeclRef?.decl as? SwiftObject,
////           let rhsObject = rhsPointer.pointeeType.asDeclRef?.decl as? SwiftObject,
////           lhsObject.linked(.sdk)?.canonical === rhsObject.canonical {
////
////            let initFunc = try (lhsObject.canonical as! SwiftObject).functionInitFromSdkObject()
////
////            let ptrInvocation = SwiftInvocation { swift in
////                swift.write(name: "$0")
////                //                swift.write(token: ".")
////                //                swift.write(name: "pointee")
////            }
////
////            return SwiftInvocation { swift in
////                swift.write(objectArray: lhs,
////                            objectInit: initFunc,
////                            arrayBuffer: rhsArrayBuffer,
////                            arrayCount: rhsArrayCount,
////                            arrayBufferInvocation: rhsInvocation,
////                            arrayCountInvocation: arrayCountInvocation,
////                            ptrInvocation: ptrInvocation)
////            }
////        }
////
////        // `[String]` = `Pointer<Pointer<CChar>>`
////        if lhsArray.elementType.asString != nil,
////           let rhsInnerPointer = rhsPointer.pointeeType.asPointer,
////           rhsInnerPointer.pointeeType.asCChar != nil {
////
////            let ptrInvocation = SwiftInvocation { swift in
////                swift.write(name: "$0")
////                //                swift.write(token: ".")
////                //                swift.write(name: "pointee")
////            }
////
////            return SwiftInvocation { swift in
////                swift.write(objectArray: lhs,
////                            objectInit: .cString(from: rhsInnerPointer),
////                            arrayBuffer: rhsArrayBuffer,
////                            arrayCount: rhsArrayCount,
////                            arrayBufferInvocation: rhsInvocation,
////                            arrayCountInvocation: arrayCountInvocation,
////                            ptrInvocation: ptrInvocation)
////            }
////        }
////
////        // `[UInt8]` = `Pointer<Void>`
////        if lhsArray.elementType.asByte != nil,
////           rhsPointer.pointeeType.isVoid {
////            return SwiftInvocation { swift in
////                swift.write(voidArrayBufferInvocation: rhsInvocation,
////                            voidArrayCountInvocation: arrayCountInvocation)
////            }
////
////        }
////
////        // `[Pointer<Opaque>]` = `Pointer<Pointer<Opaque>>`
////        if let lhsOpaquePtr = lhsArray.elementType.asOpaquePointer,
////           let rhsOpaquePtr = rhsPointer.pointeeType.asOpaquePointer,
////           lhsOpaquePtr == rhsOpaquePtr {
////            return SwiftInvocation { swift in
////                swift.write(arrayBufferInvocation: rhsInvocation,
////                            arrayCountInvocation: arrayCountInvocation)
////            }
////        }
////    }
////
////
////    // Opaque pointers
////    if let lhsPointer = lhs.type.canonical.asPointer,
////       let rhsPointer = rhs.type.canonical.asPointer,
////       let lhsOpaque = lhsPointer.pointeeType.asOpaque,
////       let rhsOpaque = rhsPointer.pointeeType.asOpaque,
////       lhsOpaque == rhsOpaque {
////        return rhsInvocation
////    }
////
////    dbgVar(lhs, rhs)
////    throw SwiftyError.unknownCopy(lhs,rhs)
////}
//
