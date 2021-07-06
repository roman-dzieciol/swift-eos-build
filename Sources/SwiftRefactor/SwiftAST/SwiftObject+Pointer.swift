
import Foundation
import SwiftAST
import os.log



extension SwiftObject {

    public func addWithPointerToSdkObjectIfNeeded() throws {
        guard !inner.compactMap({ $0 as? SwiftFunction }).contains(where: { $0.name == "withPointerToSdkOptions" }) else { return }
        try inner.append(withPointerToSdkObject())
    }

    public func withPointerToSdkObject() throws -> SwiftFunction {

        let sdkObject = sdk as! SwiftObject



        let returnType = SwiftBuiltinType(name: "R")

        let functionClosureType = SwiftFunctionType(
            paramTypes: [
                SwiftPointerType(pointeeType: SwiftDeclRefType(decl: sdkObject))
            ],
            isThrowing: true,
            returnType: returnType)

        let functionParm = SwiftFunctionParm(
            label: "_",
            name: "nested",
            type: functionClosureType)

        let function = SwiftFunction(
            name: "withPointerToSdkOptions",
            isAsync: false,
            isThrowing: false,
            returnType: returnType,
            inner: [functionParm],
            comment: .init("Initialize temporary SDK object and pass it to closure"))

        function.genericTypes = [returnType.builtinName]
        function.isRethrowing = true



        let sdkObjectInitCall = SwiftFunctionCallCode { swift in
            swift.write(name: sdkObject.name)
        }

        let nestedCalls = SwiftCode { swift in
//            swift.write(nested: "{", "}") {
                swift.write(name: "let")
                swift.write(name: "sdkObject")
                swift.write(token: "=")
                swift.write(sdkObjectInitCall)
                swift.write(textIfNeeded: "\n")
                swift.write(name: "return")
                swift.write(name: "try")
                swift.write(name: "withUnsafePointer")
                swift.write(nested: "(", ")") {
                    swift.write(name: "to")
                    swift.write(token: ":")
//                    swift.write(token: "&")
                    swift.write(name: "sdkObject")
                    swift.write(token: ",")
                    swift.write(name: "nested")
                }
//            }
//            swift.write(text: "()")
        }

        nestedCalls.isThrowing = true
        nestedCalls.withReturn = true
//        nestedCalls.skipPrefix = true

        function.code = SwiftTempExpr { swift in
            swift.write(nestedCalls)
        }


        sdkObject.members.forEach { sdkMember in

            let member = sdkMember.swifty as! SwiftVarDecl

            let lhs = sdkMember
            let rhs = member

            let lhsInvocation = SwiftInvocation { swift in
                swift.write(name: lhs.name)
                swift.write(token: ":")
            }

            var rhsInvocation = SwiftInvocation { swift in
                swift.write(name: rhs.name)
            }

            do {
                let typecast = try typecastTo(lhs: lhs, from: rhs, rhsInvocation: rhsInvocation, options: [.allowCastingAwayConst])


                sdkObjectInitCall.append { swift in
                    swift.write(lhsInvocation)
                    swift.write(typecast)
                }

            } catch SwiftyError.unknownTypecast {

                do {
                    rhsInvocation = try nested(in: nestedCalls, withPointer: lhs, from: rhs, rhsInvocation: rhsInvocation, options: [.allowCastingAwayConst])
//                } catch let error as SwiftyError {
//                    print(self.name)
//                    dbg(error)
////                    fatalError()
//
////                    sdkObjectInitCall.append { swift in
////                        swift.write(debug: "unknown pointer", lhs: lhs, rhs: rhs)
////                    }
//
                } catch {
                    fatalError()
                }

                sdkObjectInitCall.append { swift in
                    swift.write(lhsInvocation)
                    swift.write(rhsInvocation)
                }

                //                try! swift.write(withPointerTo: lhs, from: rhs, rhsInvocation: rhsInvocation)
                //                    swift.write(debug: "TODO: unknown typecast:", lhs: lhs, rhs: rhs)
            } catch {
                fatalError()
            }

            //                let lhsInvocation = SwiftInvocation { swift in
            //                    swift.write(name: "self")
            //                    swift.write(token: ".")
            //                    //                swift.write(name: member.name)
            //                }
//            sdkObjectInitCall.append { swift in

//
//                do {
//                    try swift.write(throwingTypecastTo: lhs, from: rhs, rhsInvocation: rhsInvocation)
//                    return
//                } catch SwiftyError.unknownTypecast {
//                    swift.write(debug: "TODO: unknown typecast:", lhs: lhs, rhs: rhs)
//                } catch {
//                    fatalError()
//                }


//                swift.write(assignment: sdkMember,
//                            assignmentToken: ":",
//                            from: member,
//                            lhsInvocation: nil,
//                            rhsInvocation: nil)
//            }


            //                guard member !== ptrMember else { return }
            //
            //                guard let sourceMember = member.sourceAST as? SwiftMember else { fatalError() }
            //
            //                let lhsInvocation = SwiftInvocation { swift in
            //                    swift.write(name: "self")
            //                    swift.write(token: ".")
            //                    //                swift.write(name: member.name)
            //                }
            //
            //                let rhsInvocation = SwiftInvocation { swift in
            //                    swift.write(name: objName)
            //                    swift.write(token: ".")
            //                    //                swift.write(name: sourceMember.name)
            //                }
            //
            //                initFunction.code?.append { swift in
            //                    swift.write(assignment: member,
            //                                from: sourceMember,
            //                                lhsInvocation: lhsInvocation,
            //                                rhsInvocation: rhsInvocation)
            //                }
            //                .link(member)
            //                .link(sourceMember)
        }


//        initFunction.code?.append { swift in
//            swift.write(name: "self")
//            swift.write(token: ".")
//            swift.write(name: ptrMember.name)
//            swift.write(token: "=")
//            swift.write(name: "pointer")
//            swift.write(textIfNeeded: "\n")
//        }

        return function

    }

}

//public func withPointer<R>(strings: [String], _ body: ([UnsafePointer<CChar>?]) throws -> R) rethrows -> R {
//    let charPtrs = strings.map { strdup($0) }
//    defer {
//        charPtrs.forEach { free($0) }
//    }
//    return try body(charPtrs)
//}
//
//
//public func withPointer<R>(toStringsCopy strings: [String], _ body: (UnsafePointer<UnsafePointer<CChar>?>) throws -> R) rethrows -> R {
//    let charPtrs = strings.map { strdup($0) }
//    defer {
//        charPtrs.forEach { free($0) }
//    }
//    return try body(charPtrs.map { UnsafePointer($0) })
//}
//
//
//public func withPointer2<R>(strings: [String], _ body: ([UnsafePointer<CChar>?]) throws -> R) rethrows -> R {
//    let charPtrs = strings.map { strdup($0) }
//    defer {
//        charPtrs.forEach { free($0) }
//    }
//    return try body(charPtrs)
//}

//public func withMutablePointer<R>(strings: inout [String], _ body: ([UnsafePointer<CChar>?]) throws -> R) rethrows -> R {
//    let charPtrs = strings.map { strdup($0) }
//    defer {
//        charPtrs.forEach { free($0) }
//    }
//    return try body(charPtrs)
//}
//
//public func withTempVar<V,R>(_ v: V, _ body: (inout V) throws -> R) rethrows -> R {
//    var temp = v
//    return try body(&temp)
//}
//
//public func withTempPointer<V,R>(_ v: V, _ body: (UnsafeMutablePointer<V>) throws -> R) rethrows -> R {
//    var temp = v
//    return try body(&temp)
//}
//
//
//public func withTempPointer2<V,R>(_ v: UnsafePointer<V>, _ body: (UnsafeMutablePointer<UnsafePointer<V>>) throws -> R) rethrows -> R {
//    var temp = v
//    return try body(&temp)
//}

public func nested(in nestingCall: SwiftCode, withPointer lhs: SwiftVarDecl, from rhs: SwiftVarDecl, rhsInvocation: SwiftInvocation, options: SwiftOptions = []) throws -> SwiftInvocation {

    if lhs === rhs {
        fatalError()
    }

    func castAwayConstIfNeeded() throws {

        guard options.contains(.allowCastingAwayConst) else {
            throw SwiftyError.unknownPointerCast(lhs, rhs)
        }

        nestingCall.nest { swift, invocation in
            swift.write(pointerCastingAwayConst: lhs, invocation: invocation)
        }
    }

    let lhsType = lhs.type
    let rhsType = rhs.type

    let lhsCanonical = lhsType.canonical
    let rhsCanonical = rhsType.canonical


    let lhsPointer = lhsCanonical.asPointer
    let lhsInnerPointer = lhsPointer?.pointeeType.asPointer

    //    if let declRef = rhs.type.canonical.asDeclRef,
    //       let rhsDecl = declRef.decl as? SwiftObject != nil,
    //       declRef.decl.inSwiftEOS,
    //       !rhs.name.contains("CallbackInfo") {
    //        nestingCall.nest { swift, invocation in
    //            swift.write(pointerToSdkOptions: rhs, invocation: invocation)
    //        }
    //        return rhsInvocation
    //    }

    if let lhsPointer = lhsPointer,
       let lhsInnerPointer = lhsInnerPointer,
       let lhsCChar = lhsInnerPointer.pointeeType.asCChar,
       !lhsInnerPointer.isMutable,
       let rhsArray = rhsCanonical.asArray,
       let rhsString = rhsArray.elementType.asString {

        if lhsPointer.isMutable {
            try castAwayConstIfNeeded()
        }

        nestingCall.nest { swift, invocation in
            swift.write(pointer: lhs, toStringsCopy: rhs, invocation: invocation)
        }
        return rhsInvocation
    }

    if let lhsPointer = lhsPointer,
       let lhsCChar = lhsPointer.pointeeType.asCChar,
       let rhsString = rhsCanonical.asString {

        if lhsPointer.isMutable {
            try castAwayConstIfNeeded()
        }

        nestingCall.nest { swift, invocation in
            swift.write(array: rhs, "withCString", pointer: lhs, invocation: invocation)
        }
        return rhsInvocation

    }


    if let lhsPointer = lhsPointer,
       lhsPointer.pointeeType.isVoid,
       //       !lhsInnerPointer.isMutable,
       let rhsArray = rhsCanonical.asArray,
       rhsArray.elementType.asByte != nil {

        if lhsPointer.isMutable {
            try castAwayConstIfNeeded()
        }

        nestingCall.nest { swift, invocation in
            swift.write(array: rhs, "withUnsafeBufferPointer", pointer: lhs, invocation: invocation)
        }
        return SwiftInvocation { swift in
            swift.write(rhsInvocation)
            swift.write(token: ".")
            swift.write(name: "baseAddress")
        }
    }


    if let lhsPointer = lhsPointer,
       let lhsDeclRef = lhsPointer.pointeeType.asDeclRef,
       let rhsArray = rhsCanonical.asArray,
       let rhsDeclRef = rhsArray.elementType.asDeclRef,
       lhsDeclRef.decl.canonicalType == rhsDeclRef.decl.canonicalType,
       !lhsDeclRef.decl.inSwiftEOS,
       !rhsDeclRef.decl.inSwiftEOS {

        if lhsPointer.isMutable {
            try castAwayConstIfNeeded()
        }

        nestingCall.nest { swift, invocation in
            swift.write(array: rhs, "withUnsafeBufferPointer", pointer: lhs, invocation: invocation)
        }
        return SwiftInvocation { swift in
            swift.write(rhsInvocation)
            swift.write(token: ".")
            swift.write(name: "baseAddress")
        }
    }

    if let lhsPointer = lhsPointer,
       let lhsDeclRef = lhsPointer.pointeeType.asDeclRef,
       let rhsDeclRef = rhsCanonical.asDeclRef,
       lhsDeclRef.decl.canonicalType == rhsDeclRef.decl.canonicalType
    //        ,
    //       !lhsDeclRef.decl.inSwiftEOS,
    //       !rhsDeclRef.decl.inSwiftEOS
    {

        if lhsPointer.isMutable {
            try castAwayConstIfNeeded()
        }

        nestingCall.nest { swift, invocation in
            swift.write(pointer: lhs, "withUnsafePointer", to: rhs, invocation: invocation)
        }
        return rhsInvocation
    }


    if let lhsPointer = lhsPointer,
       let rhsArray = rhsCanonical.asArray,
       lhsPointer.pointeeType == rhsArray.elementType {

        if lhsPointer.isMutable {
            try castAwayConstIfNeeded()
        }

        nestingCall.nest { swift, invocation in
            swift.write(array: rhs, "withUnsafeBufferPointer", pointer: lhs, invocation: invocation)
        }
        return SwiftInvocation { swift in
            swift.write(rhsInvocation)
            swift.write(token: ".")
            swift.write(name: "baseAddress")
        }
    }

    //    ProductUserIds.withUnsafeBufferPointer { ProductUserIds in

    //
    //    if let declRef = parm.type.canonical.asDeclRef,
    //       declRef.decl.canonical is SwiftEnum {
    //        passToSdkCall(parm, typecastedTo: parm.sdkVarDecl)
    //        return true
    //    }
    //
    //    if let inOutArrayCount = parm.linked(.arrayBuffer) as? SwiftVarDecl  {
    //        passToSdkCall(parm)
    //        function.inner.removeAll { $0 === parm }
    //        return true
    //    }
    //
    //    if let inOutArrayCount = parm.linked(.arrayLength) as? SwiftVarDecl,
    //       parm.type.canonical.asString != nil {
    //
    //        // WORKAROUND: array count in options
    //        if let inOutArrayCountInvocationDecl = inOutArrayCount.linked(.invocation) {
    //            let capacityInvocation = SwiftInvocation { swift in
    //                swift.write(name: inOutArrayCountInvocationDecl.name)
    //                swift.write(token: ".")
    //                swift.write(name: inOutArrayCount.name)
    //            }
    //            nestedCalls.nested { swift, innerCall in
    //                swift.write(prefixForCall: self.function)
    //                swift.write(withPointerOutString: parm,
    //                            capacity: capacityInvocation,
    //                            bufferPointer: parm.sdkVarDecl,
    //                            invocation: SwiftInvocation(output: innerCall))
    //            }
    //        }
    //
    //        // Variable length out string
    //        else if inOutArrayCount.isMutable {
    //            nestedCalls.nested { swift, innerCall in
    //                swift.write(prefixForCall: self.function)
    //                swift.write(withPointerForInOutString: parm,
    //                            arrayPointer: parm.sdkVarDecl,
    //                            countPointer: inOutArrayCount.sdkVarDecl,
    //                            invocation: SwiftInvocation(output: innerCall))
    //            }
    //        } else {
    //            fatalError() // TODO
    //        }
    //
    //        passToSdkCall(parm)
    //        return true
    //    }
    //
    //    if let builtin = parm.type.canonical.asBuiltin,
    //       let sdkBuiltin = parm.sdkVarDecl.type.canonical.asPointer?.pointeeType.asBuiltin,
    //       builtin.isInt,
    //       sdkBuiltin.isInt {
    //
    //        if builtin.builtinName == sdkBuiltin.builtinName {
    //            passToSdkCall(parm, typecastedTo: parm.sdkVarDecl)
    //        } else {
    //            let typecastInvocation = SwiftInvocation { swift in
    //                swift.write(token: "{")
    //                swift.write(typecastTo: parm, from: sdkBuiltin.tempVar()) { swift in
    //                    swift.write(name: "$0")
    //                }
    //                swift.write(token: "}")
    //            }
    //
    //            nestedCalls.nested { swift, innerCall in
    //                swift.write(prefixForCall: self.function)
    //                swift.write(withPointerForInOutInteger: parm,
    //                            integerPointer: parm.sdkVarDecl,
    //                            typecastInvocation: typecastInvocation,
    //                            invocation: SwiftInvocation(output: innerCall))
    //            }
    //            passToSdkCall(parm)
    //        }
    //        return true
    //    }
    //
    //
    //
    //
    //    if parm.type.canonical.asOpaque != nil || parm.type.canonical.asOpaquePointer != nil {
    //        passToSdkCall(parm, typecastedTo: parm.sdkVarDecl)
    //        return true
    //    }
    //

    //lhs: SwiftPointerType(!, SwiftDeclRefType(, SwiftTypealias(EOS_Achievements_AddNotifyAchievementsUnlockedOptions sdk: EOS_Achievements_AddNotifyAchievementsUnlockedOptions)))
    //rhs: SwiftDeclRefType(, SwiftStruct(SwiftEOS_Achievements_AddNotifyAchievementsUnlockedOptions sdk: _tagEOS_Achievements_AddNotifyAchievementsUnlockedOptions))

    //        else if declRef.decl.inSwiftEOS {
    ////            nestedCalls.nested { swift, innerCall in
    ////                swift.write(prefixForCall: self.function)
    ////            }
    //
    //            nestingCall.nest { swift, invocation in
    ////                swift.write(pointer: lhs, toStringsCopy: rhs, invocation: invocation)
    //                swift.write(withPointer: rhs.sdkVarDecl,
    //                            forInOut: rhs,
    //                            invocation: invocation)
    //            }
    //
    ////            passToSdkCall(parm)
    //        } else {
    ////            passToSdkCall(parm, typecastedTo: parm.sdkVarDecl)
    //        }
    //
    //        return
    //
    //    if let inOutArrayCount = parm.linked(.arrayLength) as? SwiftVarDecl,
    //       parm.type.canonical.asArray?.elementType.isInt == true {
    //
    //        nestedCalls.nested { swift, innerCall in
    //            swift.write(prefixForCall: self.function)
    //            swift.write(withPointerForInOutArray: parm,
    //                        //                                inOutCount: inOutArrayCount,
    //                        arrayPointer: parm.sdkVarDecl,
    //                        countPointer: inOutArrayCount.sdkVarDecl,
    //                        invocation: SwiftInvocation(output: innerCall))
    //        }
    //
    //        passToSdkCall(parm)
    //        return true
    //    }





    //    nestingCall.nested { swift, innerCall in
    //        swift.write(prefixForCall: self.function)
    //        nestingCall.writeNesting { swift in
    //            innerCall.write(to: swift)
    //        }
    //    }

    //    aka lhs: SwiftPointerType(!, SwiftPointerType(?, SwiftBuiltinType(, CChar)))
    //    aka rhs: SwiftArrayType(, SwiftBuiltinType(, String))

    /*
     annot convert value of type '[String]' to expected argument type 'UnsafeMutablePointer<UnsafePointer<CChar>?>?' (aka 'Optional<UnsafeMutablePointer<Optional<UnsafePointer<Int8>>>>')

     func f(_ arg: UnsafeMutablePointer<UnsafePointer<CChar>?>?) {

     }

     func f2(_ arg: UnsafeMutablePointer<UnsafePointer<CChar>?>?) {

     }
     */

    dbgVar(lhs, rhs)


    throw SwiftyError.unknownPointerCast(lhs,rhs)
}

