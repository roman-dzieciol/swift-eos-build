
import Foundation
import SwiftAST

extension SwiftOutputStream {

    public func write(
        withPointer parm: SwiftVarDecl,
        forInitializing type: SwiftType,
        invocation: SwiftInvocation
    ) {
        write(name: "withPointerForInitializing")
        write(nested: "(", ")") {
            write(type)
            write(token: ".")
            write(name: "init")
        }
        write(nested: "{", "}") {
            write(name: parm.name)
            write(name: "in")
            write(textIfNeeded: "\n")
            invocation.write(to: self)
        }
    }

    public func write(
        withPointer parm: SwiftVarDecl,
        forInOut inoutParm: SwiftVarDecl,
        invocation: SwiftInvocation
    ) {
        write(name: "withPointerForInOut")
        write(nested: "(", ")") {
            write(token: "&")
            write(inoutParm.name)
            write(token: ",")
            write(inoutParm.type)
            write(token: ".")
            write(name: "init")
        }
        write(nested: "{", "}") {
            write(name: parm.name)
            write(name: "in")
            write(textIfNeeded: "\n")
            invocation.write(to: self)
        }
    }

    public func write(
        withPointerForInOutArray inoutArrayBufferParm: SwiftVarDecl,
        inOutCount inoutArrayCountParm: SwiftVarDecl,
        arrayPointer arrayBufferParm: SwiftVarDecl,
        countPointer arrayCountParm: SwiftVarDecl,
        invocation: SwiftInvocation
    ) {
        write(name: "withPointerForInOut")
        write(nested: "(", ")") {
            write(name: "array")
            write(token: ":")
            write(token: "&")
            write(inoutArrayBufferParm.name)
            write(token: ",")
            write(name: "count")
            write(token: ":")
            write(token: "&")
            write(inoutArrayCountParm.name)
        }
        write(nested: "{", "}") {
            write(token: "(")
            write(name: arrayBufferParm.name)
            write(token: ":")
            write(arrayBufferParm.type)
            write(token: ",")
            write(name: arrayCountParm.name)
            write(token: ":")
            write(arrayCountParm.type)
            write(token: ")")
            write(name: "in")
            write(textIfNeeded: "\n")
            invocation.write(to: self)
        }
    }

    public func write(
        withPointerForInOutArray inoutArrayBufferParm: SwiftVarDecl,
        arrayPointer arrayBufferParm: SwiftVarDecl,
        countPointer arrayCountParm: SwiftVarDecl,
        invocation: SwiftInvocation
    ) {

        var arrayPtrType = arrayBufferParm.type
        if let ptrType = arrayBufferParm.type.canonical.asPointer, ptrType.pointeeType.isVoid {
            arrayPtrType = SwiftPointerType(pointeeType: SwiftBuiltinType(name: "UInt8"), isMutable: ptrType.isMutable, qual: ptrType.qual)
        }

        write(name: "withPointerForInOut")
        write(nested: "(", ")") {
            write(name: "array")
            write(token: ":")
            write(token: "&")
            write(inoutArrayBufferParm.name)
        }
        write(nested: "{", "}") {
            write(token: "(")
            write(name: arrayBufferParm.name)
            write(token: ":")
            write(arrayPtrType)
            write(token: ",")
            write(name: arrayCountParm.name)
            write(token: ":")
            write(arrayCountParm.type)
            write(token: ")")
            write(name: "in")
            write(textIfNeeded: "\n")
            invocation.write(to: self)
        }
    }


    public func write(
        withPointerForInOutString inoutArrayBufferParm: SwiftVarDecl,
        arrayPointer arrayBufferParm: SwiftVarDecl,
        countPointer arrayCountParm: SwiftVarDecl,
        invocation: SwiftInvocation
    ) {
        write(name: "withPointerForInOutString")
        write(nested: "(", ")") {
            write(token: "&")
            write(inoutArrayBufferParm.name)
        }
        write(nested: "{", "}") {
            write(name: arrayBufferParm.name)
            write(token: ",")
            write(name: arrayCountParm.name)
            write(name: "in")
            write(textIfNeeded: "\n")
            invocation.write(to: self)
        }
    }

    public func write(
        withPointerOutString outString: SwiftVarDecl,
        capacity: SwiftInvocation,
        bufferPointer: SwiftVarDecl,
        invocation: SwiftInvocation
    ) {
        write(name: "withPointer")
        write(nested: "(", ")") {
            write(name: "outString")
            write(token: ":")
            write(token: "&")
            write(outString.name)
            write(token: ",")
            write(name: "capacity")
            write(token: ":")
            capacity.write(to: self)
        }
        write(nested: "{", "}") {
            write(name: bufferPointer.name)
            write(name: "in")
            write(textIfNeeded: "\n")
            invocation.write(to: self)
        }
    }
}


extension SwiftOutputStream {


    public func write(objectArray: SwiftVarDecl,
                      objectInit: SwiftFunction,
                      arrayBuffer: SwiftVarDecl,
                      arrayCount: SwiftVarDecl,
                      arrayBufferInvocation: SwiftInvocation,
                      arrayCountInvocation: SwiftInvocation,
                      ptrInvocation: SwiftInvocation? = nil
    ) {

        let ptrInvocation = ptrInvocation ?? SwiftInvocation { swift in swift.write(name: "$0") }

//        write(name: "try")
        arrayBufferInvocation.write(to: self)
        write(textIfNeeded: "\n")
        indent(offset: 4) {
            write(token: ".")
            write(name: "array")
            write(nested: "(", ")") {
                arrayCountInvocation.write(to: self)
            }
            write(textIfNeeded: "\n")
            write(token: ".")
            write(name: "compactMap")
            write(nested: "{", "}") {
                write(name: "$0")
                write(token: ".")
                write(name: "pointee")
            }
            write(textIfNeeded: "\n")
            write(token: ".")
            write(name: "compactMap")
            write(nested: "{", "}") {
                if objectInit.isThrowing {
                    write(name: "try")
                }
                if objectInit.name == "init" {
                    let initName = objectArray.type.asArrayElement?.asDeclRef?.decl.name ?? ".init"
                    write(name: initName)
                } else {
                    write(name: objectInit.name)
                }
                write(nested: "(", ")") {
                    if let label = objectInit.parms.first?.label {
                        write(name: label)
                        write(token: ":")
                    }
                    ptrInvocation.write(to: self)
                }
            }
        }
    }

    public func write(voidArrayBufferInvocation: SwiftInvocation,
                      voidArrayCountInvocation: SwiftInvocation
    ) {
        write(name: "Array")
        write(nested: "(", ")") {
            write(name: "UnsafeRawBufferPointer")
            write(nested: "(", ")") {
                write(textIfNeeded: "\n")
                write(name: "start")
                write(token: ":")
                voidArrayBufferInvocation.write(to: self)
                write(token: ",")
                write(textIfNeeded: "\n")
                write(name: "count")
                write(token: ":")
                voidArrayCountInvocation.write(to: self)
            }
        }
    }

    public func write(arrayBufferInvocation: SwiftInvocation,
                      arrayCountInvocation: SwiftInvocation
    ) {
        write(name: "Array")
        write(nested: "(", ")") {
            write(name: "UnsafeBufferPointer")
            write(nested: "(", ")") {
                write(textIfNeeded: "\n")
                write(name: "start")
                write(token: ":")
                arrayBufferInvocation.write(to: self)
                write(token: ",")
                write(textIfNeeded: "\n")
                write(name: "count")
                write(token: ":")
                arrayCountInvocation.write(to: self)
            }
        }
    }
}

extension SwiftOutputStream {

    func write(pointerToSdkOptions lhs: SwiftVarDecl, invocation: SwiftInvocation) {
        write(name: lhs.name)
        write(token: ".")
        write(name: "withPointerToSdkOptions")
        write(nested: "{", "}") {
            write(name: lhs.name)
            write(name: "in")
            write(textIfNeeded: "\n")
            write(invocation)
        }
    }

    func write(pointerCastingAwayConst lhs: SwiftVarDecl, invocation: SwiftInvocation) {
        write(name: "withPointer")
        write(nested: "(", ")") {
            write(name: "castingAwayConst")
            write(token: ":")
            write(name: lhs.name)
        }
        write(nested: "{", "}") {
            write(name: lhs.name)
            write(name: "in")
            write(textIfNeeded: "\n")
            write(invocation)
        }
    }

    func write(pointer: SwiftVarDecl, toStringsCopy stringsArray: SwiftVarDecl, invocation: SwiftInvocation) {
        if let arrayCount = stringsArray.linked(.arrayLength) {
            write(name: "withPointers")
            write(nested: "(", ")") {
                write(name: "toStringsCopy")
                write(token: ":")
                write(name: stringsArray.name)
            }
            write(nested: "{", "}") {
                write(name: pointer.name)
                write(token: ",")
                write(name: arrayCount.sdk!.name)
                write(name: "in")
                write(textIfNeeded: "\n")
                write(invocation)
            }
        } else {
            write(name: "withPointer")
            write(nested: "(", ")") {
                write(name: "toStringsCopy")
                write(token: ":")
                write(name: stringsArray.name)
            }
            write(nested: "{", "}") {
                write(name: pointer.name)
                write(name: "in")
                write(textIfNeeded: "\n")
                write(invocation)
            }
        }
    }

    func write(pointer: SwiftVarDecl, to rhs: SwiftVarDecl, invocation: SwiftInvocation) {
        write(name: "withUnsafePointer")
        write(nested: "(", ")") {
            write(name: "to")
            write(token: ":")
            write(name: rhs.name)
        }
        write(nested: "{", "}") {
            write(name: pointer.name)
            write(name: "in")
            write(textIfNeeded: "\n")
            write(invocation)
        }
    }

    func write(pointer: SwiftVarDecl, _ funcName: String, to rhs: SwiftVarDecl, invocation: SwiftInvocation) {
        write(name: funcName)
        write(nested: "(", ")") {
            write(name: "to")
            write(token: ":")
            write(name: rhs.name)
        }
        write(nested: "{", "}") {
            write(name: pointer.name)
            write(name: "in")
            write(textIfNeeded: "\n")
            write(invocation)
        }
    }

    func write(array: SwiftVarDecl, _ funcName: String, pointer: SwiftVarDecl, invocation: SwiftInvocation) {
        write(name: array.name)
        write(token: ".")
        write(name: funcName)
        write(nested: "{", "}") {
            write(name: pointer.name)
            write(name: "in")
            write(textIfNeeded: "\n")
            write(invocation)
        }
    }
}


extension SwiftOutputStream {

    public func write(
        withNotification parm: SwiftVarDecl,
        removeNotifyFunction: SwiftFunction,
        invocation: SwiftInvocation
    ) {
        write(name: "withNotification")
        write(nested: "(", ")") {
            write(name: parm.name)
            write(token: ",")
            write(name: "pointerManager")
        }
        write(nested: "{", "}") {
            write(name: "ClientData")
            write(token: "->")
            write(name: "EOS_NotificationId")
            write(name: "in")
            write(textIfNeeded: "\n")
            invocation.write(to: self)
        }
        write(textIfNeeded: " ")
        write(name: "onDeinit")
        write(token: ":")
        write(nested: "{", "}") {
            indent(offset: 4) {
                write(token: "[")
                write(name: "Handle")
                write(token: "]")
                write(name: "notificationId")
                write(name: "in")
                write(textIfNeeded: "\n")
                write(name: removeNotifyFunction.name)
                write(nested: "(", ")") {
                    //                        write(name: "Handle")
                    //                        write(token: ":")
                    write(name: "Handle")
                    write(token: ",")
                    //                        write(name: "InId")
                    //                        write(token: ":")
                    write(name: "notificationId")
                }
            }
        }
    }
}


extension SwiftOutputStream {

    public func write(callbackInfoObject: SwiftObject,
                      isNotification: Bool) {
        write(nested: "{", "}") {
            write(name: "callbackPtr")
            write(name: "in")
            write(textIfNeeded: "\n")

            if isNotification {
                write(name: "__SwiftEOS__NotificationCallback")
            } else {
                write(name: "__SwiftEOS__CompletionCallbackWithResult")
            }
            write(text: ".")
            write(name: "from")
            write(nested: "(", ")") {
                write(name: "pointer")
                write(token: ":")
                write(name: "callbackPtr")
                write(token: "?")
                write(token: ".")
                write(name: "pointee")
                write(token: ".")
                write(name: "ClientData")
            }
            write(nested: "{", "}") {
                write(textIfNeeded: "\n")
//                write(name: "try")
//                write(token: "!")
//                write(textIfNeeded: " ")
                write(name: callbackInfoObject.name)
                write(nested: "(", ")") {
                    write(name: "sdkObject")
                    write(token: ":")
                    write(name: "callbackPtr")
                    write(token: "?")
                    write(token: ".")
                    write(name: "pointee")
                }
                write(textIfNeeded: "\n")
            }
        }

    }
}



extension SwiftOutputStream {

    public func write(copyBytes swiftObjectMember: SwiftMember,
                      sdkObjectLocalVarName: String,
                      sdkObjectMember: SwiftMember,
                      bufferAccessor: String = "withUnsafeBytes",
                      bufferElementName: String = "UInt8") {

        write(name: swiftObjectMember.name)
        write(text: ".")
        write(name: bufferAccessor)
        write(nested: "{", "}") {
            write(name: "swiftBufferPtr")
            write(name: "in")
            write(textIfNeeded: "\n")

            write(name: "let")
            write(name: "newAllocationPtr")
            write(token: "=")
            write(name: "UnsafeMutableBufferPointer")
            write(nested: "<", ">") {
                write(name: bufferElementName)
            }
            write(token: ".")
            write(name: "allocate")
            write(nested: "(", ")") {
                write(name: "capacity")
                write(token: ":")
                write(name: "swiftBufferPtr")
                write(token: ".")
                write(name: "count")
            }
            write(textIfNeeded: "\n")

            write(name: "onDeinit")
            write(token: ".")
            write(name: "append")
            write(nested: "{", "}") {
                write(name: "newAllocationPtr")
                write(token: ".")
                write(name: "deallocate")
                write(token: "()")
            }
            write(textIfNeeded: "\n")

            write(name: "swiftBufferPtr")
            write(token: ".")
            write(name: "copyBytes")
            write(nested: "(", ")") {
                write(name: "to")
                write(token: ":")
                write(name: "newAllocationPtr")
            }
            write(textIfNeeded: "\n")

            write(name: sdkObjectLocalVarName)
            write(token: ".")
            write(name: sdkObjectMember.name)
            write(token: "=")
            write(name: "UnsafeRawPointer")
            write(nested: "(", ")") {
                write(name: "newAllocationPtr")
                write(token: ".")
                write(name: "baseAddress")
            }

        }
    }

    public func write(copyString swiftObjectMember: SwiftMember,
                      sdkObjectLocalVarName: String,
                      sdkObjectMember: SwiftMember,
                      bufferAccessor: String = "utf8CString.withUnsafeBytes",
                      bufferElementName: String = "CChar") {

        write(name: swiftObjectMember.name)
        write(text: ".")
        write(name: bufferAccessor)
        write(nested: "{", "}") {
            write(name: "swiftBufferPtr")
            write(name: "in")
            write(textIfNeeded: "\n")

            write(name: "let")
            write(name: "newAllocationPtr")
            write(token: "=")
            write(name: "UnsafeMutableBufferPointer")
            write(nested: "<", ">") {
                write(name: bufferElementName)
            }
            write(token: ".")
            write(name: "allocate")
            write(nested: "(", ")") {
                write(name: "capacity")
                write(token: ":")
                write(name: "swiftBufferPtr")
                write(token: ".")
                write(name: "count")
            }
            write(textIfNeeded: "\n")

            write(name: "onDeinit")
            write(token: ".")
            write(name: "append")
            write(nested: "{", "}") {
                write(name: "newAllocationPtr")
                write(token: ".")
                write(name: "deallocate")
                write(token: "()")
            }
            write(textIfNeeded: "\n")

            write(name: "swiftBufferPtr")
            write(token: ".")
            write(name: "copyBytes")
            write(nested: "(", ")") {
                write(name: "to")
                write(token: ":")
                write(name: "newAllocationPtr")
            }
            write(textIfNeeded: "\n")

            write(name: sdkObjectLocalVarName)
            write(token: ".")
            write(name: sdkObjectMember.name)
            write(token: "=")
            write(name: "UnsafePointer")
            write(nested: "<", ">") {
                write(name: bufferElementName)
            }
            write(nested: "(", ")") {
                write(name: "newAllocationPtr")
                write(token: ".")
                write(name: "baseAddress")
            }

        }
    }

    public func write(allocate: String = "UnsafeMutablePointer",
                      pointerTo sdkObject: SwiftAST,
                      capacity: SwiftInvocation) {
        write(name: allocate)
        write(token: "<")
        write(name: sdkObject.name)
        write(token: ">")
        write(token: ".")
        write(name: "allocate")
        write(nested: "(", ")") {
            write(name: "capacity")
            write(token: ":")
            write(capacity)
        }
    }

    public func write(allocateSdkObject sdkObject: SwiftObject) {

        write(name: "let")
        write(name: "sdkObjectPointer")
        write(token: "=")
        write(allocate: "UnsafeMutablePointer", pointerTo: sdkObject, capacity: SwiftInvocation { $0.write(name: "1") })
        write(textIfNeeded: "\n")

        write(name: "initializeSdkObject")
        write(nested: "(", ")") {
            write(name: "at")
            write(token: ":")
            write(name: "sdkObjectPointer")
        }
        write(textIfNeeded: "\n")

        write(name: "onDeinit")
        write(token: ".")
        write(name: "append")
        write(nested: "{", "}") {
            write(name: "sdkObjectPointer")
            write(token: ".")
            write(name: "deinitialize")
            write(nested: "(", ")") {
                write(name: "count")
                write(token: ":")
                write(name: "1")
            }
            write(textIfNeeded: "\n")
            write(name: "sdkObjectPointer")
            write(token: ".")
            write(name: "deallocate")
            write(token: "()")
            write(textIfNeeded: "\n")
        }
        write(textIfNeeded: "\n")

        write(name: "return")
        write(name: "sdkObjectPointer")
        write(textIfNeeded: "\n")
    }

    public func write(initializeSdkObject sdkObject: SwiftObject) {

        write(name: "let")
        write(name: "sdkObjectPointer")
        write(token: "=")
        write(allocate: "UnsafeMutablePointer", pointerTo: sdkObject, capacity: SwiftInvocation { $0.write(name: "1") })
        write(textIfNeeded: "\n")

        write(name: "initializeSdkObject")
        write(nested: "(", ")") {
            write(name: "at")
            write(token: ":")
            write(name: "sdkObjectPointer")
        }
        write(textIfNeeded: "\n")

        write(name: "onDeinit")
        write(token: ".")
        write(name: "append")
        write(nested: "{", "}") {
            write(name: "sdkObjectPointer")
            write(token: ".")
            write(name: "deinitialize")
            write(nested: "(", ")") {
                write(name: "count")
                write(token: ":")
                write(name: "1")
            }
            write(textIfNeeded: "\n")
            write(name: "sdkObjectPointer")
            write(token: ".")
            write(name: "deallocate")
            write(token: "()")
            write(textIfNeeded: "\n")
        }
        write(textIfNeeded: "\n")
    }


    public func write(
        allocateObjectsBuffer sdkObjectArray: SwiftVarDecl,
        sdkObject: SwiftAST,
        sdkObjectLocalVarName: String
    ) {

        let bufferName = "_\(sdkObjectArray.name)Buffer"

        //    sdkObject.Records = { ... }()
        write(name: sdkObjectLocalVarName)
        write(token: ".")
        write(name: sdkObjectArray.name)
        write(token: "=")
        write(nested: "{", "}") {
            write(textIfNeeded: "\n")

            //    let _RecordsBuffer = UnsafeMutableBufferPointer<EOS_Presence_DataRecord>.allocate(capacity: Records.count)
            write(name: "let")
            write(name: bufferName)
            write(token: "=")
            write(allocate: "UnsafeMutableBufferPointer", pointerTo: sdkObject, capacity: SwiftInvocation { swift in
                swift.write(name: sdkObjectArray.name)
                swift.write(token: ".")
                swift.write(name: "count")
            })
            write(textIfNeeded: "\n")

            //    onDeinit.append {
            //        _RecordsBuffer.baseAddress?.deinitialize(count: _RecordsBuffer.count)
            //        _RecordsBuffer.deallocate()
            //    }
            write(name: "onDeinit")
            write(token: ".")
            write(name: "append")
            write(nested: "{", "}") {
                write(textIfNeeded: "\n")
                write(name: bufferName)
                write(token: ".")
                write(name: "baseAddress")
                write(token: "?")
                write(token: ".")
                write(name: "deinitialize")
                write(nested: "(", ")") {
                    write(name: "count")
                    write(token: ":")
                    write(name: bufferName)
                    write(token: ".")
                    write(name: "count")
                }
                write(textIfNeeded: "\n")

                write(name: bufferName)
                write(token: ".")
                write(name: "deallocate")
                write(token: "()")
                write(textIfNeeded: "\n")
            }
            write(textIfNeeded: "\n")


            //        for index in Records.indices {
            //            if let sdkObjectPointerInBuffer = _RecordsBuffer.baseAddress?.advanced(by: index) {
            //                Records[index].initializeSdkObject(at: sdkObjectPointerInBuffer)
            //            }
            //        }
            write(name: "for")
            write(name: "index")
            write(name: "in")
            write(name: sdkObjectArray.name)
            write(token: ".")
            write(name: "indices")
            write(nested: "{", "}") {
                write(textIfNeeded: "\n")
                write(name: "if")
                write(name: "let")
                write(name: "sdkObjectPointerInBuffer")
                write(token: "=")
                write(name: bufferName)
                write(token: ".")
                write(name: "baseAddress")
                write(token: "?")
                write(token: ".")
                write(name: "advanced")
                write(token: "(")
                write(name: "by")
                write(token: ":")
                write(name: "index")
                write(token: ")")
                write(nested: "{", "}") {
                    write(textIfNeeded: "\n")
                    write(name: sdkObjectArray.name)
                    write(token: "[")
                    write(name: "index")
                    write(token: "]")
                    write(token: ".")
                    write(name: "initializeSdkObject")
                    write(nested: "(", ")") {
                        write(name: "at")
                        write(token: ":")
                        write(name: "sdkObjectPointerInBuffer")
                    }
                    write(textIfNeeded: "\n")
                }
                write(textIfNeeded: "\n")
            }
            write(textIfNeeded: "\n")

            write(name: "return")
            write(name: "UnsafePointer")
            write(nested: "(", ")") {
                write(name: bufferName)
                write(token: ".")
                write(name: "baseAddress")
            }
            write(textIfNeeded: "\n")
        }
        write(token: "()")
    }
}

///** Initialize SDK object pointer */
//public func allocatedSdkObject() -> UnsafeMutablePointer<_tagEOS_PresenceModification_SetDataOptions> {
//    let sdkObjectPointer = UnsafeMutablePointer<_tagEOS_PresenceModification_SetDataOptions>.allocate(capacity: 1)
//    defer {
//        onDeinit.append {
//            sdkObjectPointer.deallocate()
//        }
//    }
//    initializeSdkObject(at: sdkObjectPointer)
//    return sdkObjectPointer
//}
//
///** Initialize SDK object pointer at already allocated memory address */
//public func initializeSdkObject(
//    at sdkObjectPointer: UnsafeMutablePointer<_tagEOS_PresenceModification_SetDataOptions>
//) {
//    var sdkObject = _tagEOS_PresenceModification_SetDataOptions()
//    sdkObject.ApiVersion = Int32(exactly: ApiVersion)!
//    sdkObject.RecordsCount = Int32(exactly: RecordsCount)!
//    sdkObject.Records = {
//        let _RecordsBuffer = UnsafeMutableBufferPointer<_tagEOS_Presence_DataRecord>.allocate(capacity: Records.count)
//        defer {
//            onDeinit.append {
//                _RecordsBuffer.deallocate()
//            }
//        }
//        for index in Records.indices {
//            if let sdkObjectPointerInBuffer = _RecordsBuffer.baseAddress?.advanced(by: index) {
//                Records[index].initializeSdkObject(at: sdkObjectPointerInBuffer)
//                onDeinit.append {
//                    sdkObjectPointerInBuffer.deinitialize(count: 1)
//                }
//            }
//        }
//        return UnsafePointer(_RecordsBuffer.baseAddress)
//    }()
//    sdkObjectPointer.initialize(to: sdkObject)
//    onDeinit.append {
//        sdkObjectPointer.deinitialize(count: 1)
//    }
//}
//    sdkObject.HiddenAchievementIds_DEPRECATED = {
//        let pointerPointer = UnsafeMutableBufferPointer<UnsafePointer<CChar>?>.allocate(capacity: HiddenAchievementIds_DEPRECATED.count)
//        defer {
//            onDeinit.append {
//                pointerPointer.deallocate()
//            }
//        }
//        for index in HiddenAchievementIds_DEPRECATED.indices {
//            if let pointerInBuffer = pointerPointer.baseAddress?.advanced(by: index) {
//                HiddenAchievementIds_DEPRECATED[index].utf8CString.withUnsafeBytes { swiftBufferPtr in
//
//                    let newAllocationPtr = UnsafeMutableBufferPointer<CChar>.allocate(capacity: swiftBufferPtr.count)
//                    defer {
//                        onDeinit.append {
//                            newAllocationPtr.deallocate()
//                        }
//                    }
//                    swiftBufferPtr.copyBytes(to: newAllocationPtr)
//                    onDeinit.append {
//                        newAllocationPtr.baseAddress?.deinitialize(count: newAllocationPtr.count)
//                    }
//
//                    pointerInBuffer.initialize(to: UnsafePointer(newAllocationPtr.baseAddress))
//                    onDeinit.append {
//                        pointerInBuffer.deinitialize(count: 1)
//                    }
//                }
//            }
//        }
//        return UnsafeMutablePointer<UnsafePointer<CChar>?>(pointerPointer.baseAddress!)
//    }()
