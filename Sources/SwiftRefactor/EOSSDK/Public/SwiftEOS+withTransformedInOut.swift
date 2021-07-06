
import Foundation

public func withTransformedInOut<Value, Transformed, R>(
    inoutValue: inout Value,
    valueToTransformed: (Value) throws -> Transformed,
    valueFromTransformed: (Transformed) throws -> Value,
    nested: (inout Transformed) throws -> R
) rethrows -> R {
    var transformed: Transformed = try valueToTransformed(inoutValue)
    let result = try nested(&transformed)
    inoutValue = try valueFromTransformed(transformed)
    return result
}




//public func withPointerToInOut2<Value, Pointee, R>(
//    value: inout Value,
//    valueToPointee: (Value) throws -> Pointee,
//    valueFromPointee: (Pointee) throws -> Value,
//    nested: (UnsafeMutablePointer<Pointee>) throws -> R
//) rethrows -> R {
//    var pointee: Pointee = try valueToPointee(value)
//    let result = try nested(&pointee)
//    value = try valueFromPointee(pointee)
//    return result
//}
//
//public func withPointerToInOutSdkObject<SdkObject, SwiftObject: SdkObjectTransformable, R>(
//    _ inoutSwiftObject: inout SwiftObject?,
//    _ nested: (UnsafeMutablePointer<SdkObject>?) throws -> R
//) rethrows -> R {
//    guard var swiftObject = inoutSwiftObject else {
//        return try nested(nil)
//    }
//    let result = try withTransformedInOut(inoutValue: &swiftObject) { value in
//        value.initializedSdkObject()
//    } valueFromTransformed: { transformed in
//        SwiftObject.init(sdkObject: transformed)
//    } nested: { transformed in
//        try withUnsafeMutablePointer(to: &transformed, nested)
//    }
//    inoutSwiftObject = swiftObject
//    return result
//}
//
