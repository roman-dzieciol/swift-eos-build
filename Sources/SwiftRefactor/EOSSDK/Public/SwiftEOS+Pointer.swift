
import Foundation

#if canImport(EOSSDK)
import EOSSDK
#endif



extension UnsafePointer {

    public func array(_ count: Int) -> [Self] {
        (0..<count).map { advanced(by: $0) }
    }
}

extension UnsafeMutablePointer {

    public func array(_ count: Int) -> [Self] {
        (0..<count).map { advanced(by: $0) }
    }
}

public func dereferencingPointer<Pointee>(
    _ nested: (UnsafeMutablePointer<Pointee>) throws -> Void
) rethrows -> Pointee {
    let pointer = UnsafeMutablePointer<Pointee>.allocate(capacity: 1)
    try nested(pointer)
    return pointer.pointee
}

public func dereferencingOptionalPointer<Pointee>(
    _ nested: (UnsafeMutablePointer<Pointee?>) throws -> Void
) rethrows -> Pointee {
    let pointer = UnsafeMutablePointer<Pointee?>.allocate(capacity: 1)
    try nested(pointer)
    return pointer.pointee!
}


public func withPointer<P,R>(castingAwayConst pointer: UnsafePointer<P>, _ body: (UnsafeMutablePointer<P>) throws -> R) rethrows -> R {
    return try body(UnsafeMutablePointer(mutating: pointer))
}

public func withPointerForInitializing<Pointee, R>(
    _ factory: (UnsafePointer<Pointee>) throws -> R,
    _ nested: (UnsafeMutablePointer<UnsafeMutablePointer<Pointee>?>) throws -> Void
) rethrows -> R {
    var pointerFromNested: UnsafeMutablePointer<Pointee>? = nil
    try nested(&pointerFromNested)
    return try factory(pointerFromNested!)
}


public func withPointerToInOut<Value, Pointee, R>(
    value: inout Value,
    valueToPointee: (Value) throws -> Pointee,
    valueFromPointee: (Pointee) throws -> Value,
    nested: (UnsafeMutablePointer<Pointee>) throws -> R
) rethrows -> R {
    var pointee: Pointee = try valueToPointee(value)
    let result = try nested(&pointee)
    value = try valueFromPointee(pointee)
    return result
}



public func withPointerForInOut<Pointee, R>(
    _ parm: inout R,
    _ factory: (UnsafePointer<Pointee>) throws -> R,
    _ nested: (UnsafeMutablePointer<UnsafeMutablePointer<Pointee>?>) throws -> Void
) rethrows {
    var pointerFromNested: UnsafeMutablePointer<Pointee>? = nil
    try nested(&pointerFromNested)
    parm = try factory(pointerFromNested!)
}


//public func withPointerForInOut<Pointee, Value, R>(
//    value: inout V,
//    toNested: (Value) throws -> UnsafeMutablePointer<Pointee>,
//    fromNested: (UnsafeMutablePointer<Pointee>) throws -> Value,
//    _ nested: (UnsafeMutablePointer<Pointee>?) throws -> R
//) rethrows -> R {
//
//    var pointerFromNested: UnsafeMutablePointer<Pointee>? = nil
//
//    let returnValue = try nested(&pointerFromNested)
//
//    if let pointerFromNested {
//        value = try factory(pointerFromNested!)
//    }
//
//    return returnValue
//}

//try withPointerForInOut(array: &OutData) { OutData, OutBytesWritten in
//    let __OutSocketIdPointer: UnsafeMutablePointer<_tagEOS_P2P_SocketId>! = .allocate(capacity: 1)
//    try try throwingSdkResult {
//        withPointerManager { pointerManager in
//            EOS_P2P_ReceivePacket(
//                Handle,
//                pointerManager.managedPointer(copyingValue: Options.functionBuildSdkObject(pointerManager: pointerManager)),
//                &OutPeerId,
//                __OutSocketIdPointer,
//                &OutChannel,
//                OutData,
//                OutBytesWritten
//            )
//        }}
//    OutSocketId = SwiftEOS_P2P_SocketId(sdkObject: __OutSocketIdPointer.pointee)
//    }


public func withOutArg<Ptr>(_ nested: (inout Ptr) throws -> Void) rethrows -> Ptr? {
    var OutArg: Ptr! = nil
    try nested(&OutArg)
    return OutArg
}
