
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

public func withTransformed<Value, Transformed, R>(
    value: Value,
    transform: (Value) throws -> Transformed,
    nested: (Transformed) throws -> R
) rethrows -> R {
    let transformed: Transformed = try transform(value)
    return try nested(transformed)
}

public func returningTransformedResult<Transformed, R>(
    nested: () throws -> R,
    transformedResult: (R) throws -> Transformed
) rethrows -> Transformed {
    let result = try nested()
    let transformedResult = try transformedResult(result)
    return transformedResult
}
