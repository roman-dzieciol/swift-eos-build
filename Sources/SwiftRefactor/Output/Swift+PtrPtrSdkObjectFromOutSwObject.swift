
import Foundation
import SwiftAST


func nestPtrPtrSdkObjectFromOutSwObject(
    nestedCalls: SwiftCode,
    ptrName: String,
    ptrPtrName: String,
    lhsInnerPointer: SwiftType,
    rhs: SwiftVarDecl,
    rhsObject: SwiftObject,
    releaseFuncName: String?
) {
    nestedCalls.nest2 { swift, prefixInvocation, innerCall in
        swift.write(name: "var")
        swift.write(name: ptrName)
        swift.write(token: ":")
        swift.write(lhsInnerPointer)
        swift.write(token: "=")
        swift.write(name: "nil")
        swift.write(textIfNeeded: "\n")

        swift.write(prefixInvocation)
        swift.write(name: "withUnsafeMutablePointer")
        swift.write(token: "(")
        swift.write(name: "to")
        swift.write(token: ":")
        swift.write(token: "&")
        swift.write(name: ptrName)
        swift.write(token: ")")
        swift.write(nested: "{", "}") {
            swift.write(name: ptrPtrName)
            swift.write(name: "in")
            swift.write(textIfNeeded: "\n")
            swift.write(innerCall)
            swift.write(textIfNeeded: "\n")

            swift.write(name: "if")
            swift.write(name: "let")
            swift.write(name: ptrName)
            swift.write(token: "=")
            swift.write(name: ptrPtrName)
            swift.write(token: ".")
            swift.write(name: "pointee")
            swift.write(nested: "{", "}") {
                swift.write(textIfNeeded: "\n")

                swift.write(name: "if")
                swift.write(name: "let")
                swift.write(name: "object")
                swift.write(token: "=")
                swift.write(name: rhsObject.name)
                swift.write(token: "(")
                swift.write(name: SwiftName.sdkObject)
                swift.write(token: ":")
                swift.write(name: ptrName)
                swift.write(token: ".")
                swift.write(name: "pointee")
                swift.write(token: ")")
                swift.write(nested: "{", "}") {
                    swift.write(textIfNeeded: "\n")

                    swift.write(name: rhs.name)
                    swift.write(token: "=")
                    swift.write(name: "object")
                    swift.write(textIfNeeded: "\n")
                }
                swift.write(textIfNeeded: "\n")

                if let releaseFuncName = releaseFuncName {
                    swift.write(name: releaseFuncName)
                    swift.write(token: "(")
                    swift.write(name: ptrName)
                    swift.write(token: ")")
                } else {
                    swift.write(name: "/* TODO: release ")
                    swift.write(name: ptrName)
                    swift.write(name: "*/")
                }

                swift.write(textIfNeeded: "\n")
            }
            swift.write(textIfNeeded: "\n")
        }
        swift.write(textIfNeeded: "\n")
    }
}
