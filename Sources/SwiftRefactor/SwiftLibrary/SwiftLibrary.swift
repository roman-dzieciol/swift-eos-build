

import Foundation
import SwiftAST


extension SwiftFunction {


    static func cString(from paramType: SwiftType) -> SwiftFunction {
        SwiftFunction(name: "String", isAsync: false, isThrowing: false, returnType: .string, inner: [
            SwiftFunctionParm(label: "cString", name: "cString", type: paramType, isMutable: false, comment: nil)
        ], comment: nil, code: { _ in })
    }
}



public enum SwiftLibrary {
    
}
