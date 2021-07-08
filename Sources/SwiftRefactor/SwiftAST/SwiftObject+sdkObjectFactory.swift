
import Foundation
import SwiftAST


extension SwiftObject {


    func addSdkObjectFactory() throws {
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
}
