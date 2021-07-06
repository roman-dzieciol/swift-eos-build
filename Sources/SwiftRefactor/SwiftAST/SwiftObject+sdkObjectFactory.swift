
import Foundation
import SwiftAST


extension SwiftObject {


    func addSdkObjectFactory() throws {
//        _ = try onDeinitMember()
//        _ = try sdkObjectPointerMember()
//        _ = try allocatedSdkObject()
//        _ = try initializeSdkObject()
        _ = try functionBuildSdkObject()
        _ = try functionInitFromSdkObject()

        if !superTypes.contains("SwiftEOSObject") {
            superTypes.append("SwiftEOSObject")
        }

        for member in members {
            if let memberObject = (member.type.canonical.asDeclRef?.decl.canonical as? SwiftObject ??
                                   member.type.canonical.asArrayElement?.canonical.asDeclRef?.decl.canonical as? SwiftObject),
               memberObject.inSwiftEOS,
               memberObject.sdk != nil {
                _ = try memberObject.addSdkObjectFactory()
            }
        }
    }




//    func initializeSdkObject() throws -> SwiftFunction {
//
//        if let initializeSdkObject = findInitializeSdkObject() {
//            return initializeSdkObject
//        }
//
//        let _ = try onDeinitMember()
//        let sdkObjectPointerMember = try sdkObjectPointerMember()
//
//        let sdkObject = sdk as! SwiftObject
//
//        let functionParm = SwiftFunctionParm(
//            label: "at",
//            name: sdkObjectPointerMember.name,
//            type: sdkObjectPointerMember.type
//        )
//
//        let function = SwiftFunction(
//            name: Self.initializeSdkObjectName,
//            isAsync: false,
//            isThrowing: false,
//            returnType: .void,
//            inner: [functionParm],
//            comment: .init("Initialize SDK object pointer at already allocated memory address"))
//
//        let sdkObjectLocalVarName = "sdkObject"
//
//        function.code = SwiftFunctionCode { swift in
//            swift.write(name: "var")
//            swift.write(name: sdkObjectLocalVarName)
//            swift.write(token: "=")
//            swift.write(name: sdkObject.name)
//            swift.write(nested: "(", ")") {}
//        }
//
//        defer {
//            function.code?.append { swift in
//                swift.write(name: functionParm.name)
//                swift.write(token: ".")
//                swift.write(name: "initialize")
//                swift.write(nested: "(", ")") {
//                    swift.write(name: "to")
//                    swift.write(token: ":")
//                    swift.write(name: sdkObjectLocalVarName)
//                }
//            }
//        }
//
//        inner.append(function)
//
//        for member in members {
//            guard let sdkMember = member.sdk as? SwiftMember else { continue }
//            if let decl = member.type.canonical.asDeclRef?.decl.canonical, let memberObject = decl as? SwiftObject, memberObject.inSwiftEOS {
//                try memberObject.addSdkObjectFactory()
//            }
//        }
//
//        for sdkMember in sdkObject.members {
//
//            guard let member = sdkMember.swifty as? SwiftMember else { continue }
//
//            let lhs = sdkMember
//            let rhs = member
//
//            let lhsType = lhs.type
//            let rhsType = rhs.type
//
//            let lhsCanonical = lhsType.canonical
//            let rhsCanonical = rhsType.canonical
//
//            let lhsInvocation = SwiftInvocation { swift in
//                swift.write(name: sdkObjectLocalVarName)
//                swift.write(token: ".")
//                swift.write(name: lhs.name)
//            }
//
//
//
//            //            if let lhsObject = lhsCanonical.asDeclRef?.decl as? SwiftObject,
//            //               let rhsObject = rhsCanonical.asPointer?.pointeeType.asDeclRef?.decl as? SwiftObject,
//            //               lhsObject.sdk === rhsObject {
//            //                try! lhsObject.addInitFromSdkObjectPointer()
//            //            }
//
//
//            do {
//
//                // Basic copy
//                let copyingInvocation = try copyingInvocation(lhs: lhs, rhs: rhs, options: [])
//
//                function.code?.append { swift in
//                    lhsInvocation.write(to: swift)
//                    swift.write(token: "=")
//                    copyingInvocation.write(to: swift)
//                }
//
//            } catch {
//
//                // `Pointer<Void>` = `[Void or Byte]`
//                if let lhsPointer = lhsCanonical.asPointer,
//                   (lhsPointer.pointeeType.isVoid || lhsPointer.pointeeType.isByte),
//                   let rhsArray = rhsCanonical.asArray,
//                   rhsArray.elementType.isByte {
//
//                    function.code?.append { swift in
//                        swift.write(copyBytes: rhs,
//                                    sdkObjectLocalVarName: sdkObjectLocalVarName,
//                                    sdkObjectMember: lhs)
//                    }
//                }
//
//                // `Pointer<CChar>` = `String`
//                else if let lhsPointer = lhsCanonical.asPointer,
//                        lhsPointer.pointeeType.isCChar,
//                        let rhsString = rhsCanonical.asString {
//
//                    function.code?.append { swift in
//                        swift.write(copyString: rhs,
//                                    sdkObjectLocalVarName: sdkObjectLocalVarName,
//                                    sdkObjectMember: lhs)
//                    }
//                }
//
//                // `Pointer<Pointer<CChar>>` = `[String]`
//                else if let lhsPointer = lhsCanonical.asPointer,
//                        lhsPointer.pointeeType.isCChar,
//                        let rhsString = rhsCanonical.asString {
//
//                    function.code?.append { swift in
//                        swift.write(copyString: rhs,
//                                    sdkObjectLocalVarName: sdkObjectLocalVarName,
//                                    sdkObjectMember: lhs)
//                    }
//                }
//                else if let lhsPointer = lhsCanonical.asPointer,
//                        let lhsInnerPointer = lhsPointer.pointeeType.asPointer,
//                        lhsInnerPointer.pointeeType.isCChar,
//                        let rhsArray = rhsCanonical.asArray,
//                        let rhsString = rhsArray.asString {
//
////
////                    function.code?.append { swift in
////                        swift.write(allocateObjectsBuffer: lhs,
////                                    //                                    sdkObjectVarDecl: lhsDeclRef,
////                                    sdkObject: lhsDecl,
////                                    sdkObjectLocalVarName: sdkObjectLocalVarName)
////                    }
//                }
//
//                // TODO: sdkObject.HiddenAchievementIds_DEPRECATED SwiftPointerType(!, SwiftPointerType(?, SwiftBuiltinType(, CChar))) = SwiftArrayType(, SwiftBuiltinType(, String))
//
//                // `Pointer<SdkObject>` = `[SwiftObject]`
//                else if let lhsPointer = lhsCanonical.asPointer,
//                        let rhsArray = rhsCanonical.asArray,
//                        let lhsDeclRef = lhsPointer.pointeeType.asDeclRef,
//                        let rhsDeclRef = rhsArray.elementType.asDeclRef,
//                        let lhsDecl = lhsDeclRef.decl.canonical as? SwiftObject,
//                        let rhsDecl = rhsDeclRef.decl.canonical as? SwiftObject,
//                        lhsDecl === rhsDecl.sdk,
//                        rhsDecl.inSwiftEOS {
//
//                    try rhsDecl.addSdkObjectFactory()
//
//                    function.code?.append { swift in
//                        swift.write(allocateObjectsBuffer: lhs,
////                                    sdkObjectVarDecl: lhsDeclRef,
//                                    sdkObject: lhsDecl,
//                                    sdkObjectLocalVarName: sdkObjectLocalVarName)
//                    }
//                }
//
//                // Unknown
//                else {
//
//                function.code?.append { swift in
//                    swift.write(name: "// TODO: ")
//                    lhsInvocation.write(to: swift)
//                    swift.write(name: "\(lhs.type.canonical) = \(rhs.type.canonical)")
//                }
//
////                fatalError("\(error)")
//                }
//            }
//
//        }
//
//
//
//        return function
//    }

}
