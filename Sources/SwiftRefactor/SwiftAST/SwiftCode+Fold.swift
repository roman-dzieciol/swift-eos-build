

import Foundation

typealias SdkObjectPointer<SDK> = UnsafePointer<SDK>

typealias SdkObjectPointersPointer<SDK> = UnsafeBufferPointer<SdkObjectPointer<SDK>>

typealias CompletionWithSdkObjectPointersPointer<R,SDK> = (_ sdkObjectPointersPointer: SdkObjectPointersPointer<SDK>) throws -> R

typealias CompletionWithSdkObjectPointer<R,SDK> = (SdkObjectPointer<SDK>) throws -> R

typealias WithSdkObjectValidWithin<R,SW,SDK> = (_ withSdkObjectValidWithin: @escaping (SdkObjectPointer<SDK>) throws -> R) throws -> R


func fold<R,SW,SDK>(
    swiftyObjects: [SW],
    withSdkObjectPointerFromSwiftyObject: @escaping (_ swiftyObject: SW,
                                                     _ completionWithSdkObjectPointer: @escaping CompletionWithSdkObjectPointer<R,SDK>) throws -> R,
    completionWithSdkObjectPointersPointer: @escaping CompletionWithSdkObjectPointersPointer<R,SDK>
) rethrows -> R {

    var sdkObjectPointers: [SdkObjectPointer<SDK>] = []

    func recursiveFold(
        completion: @escaping CompletionWithSdkObjectPointersPointer<R,SDK>,
        remainingObjects: ArraySlice<SW>
    ) throws -> R {

        guard let nextSwiftyObject = remainingObjects.first else {
            return try sdkObjectPointers.withUnsafeBufferPointer { sdkObjectPointersPointer in
                return try completionWithSdkObjectPointersPointer(sdkObjectPointersPointer)
            }
        }

        return try withSdkObjectPointerFromSwiftyObject(nextSwiftyObject) { (sdkObjectPointer: SdkObjectPointer<SDK>) throws -> R in

            sdkObjectPointers.append(sdkObjectPointer)

            return try recursiveFold(
                completion: completion,
                remainingObjects: remainingObjects.dropFirst()
            )
        }
    }

    return try recursiveFold(
        completion: completionWithSdkObjectPointersPointer,
        remainingObjects: swiftyObjects[swiftyObjects.indices]
    )
}

#if false

func nope() throws {
    let swiftyObjects: [String] = []

    let result: Int = try fold(
        swiftyObjects: swiftyObjects,
        withSdkObjectPointerFromSwiftyObject: { (swiftyObject: String,
                                                 completionWithSdkObjectPointer: (UnsafePointer<CChar>) throws -> Int) throws -> Int in
        return try swiftyObject.withCString { (cString: UnsafePointer<CChar>) throws -> Int in
            return try completionWithSdkObjectPointer(cString)
        }

    }, completionWithSdkObjectPointersPointer: { (sdkObjectPointersPointer: UnsafeBufferPointer<UnsafePointer<CChar>>) throws -> Int in


        return 1
    })
}

#endif
