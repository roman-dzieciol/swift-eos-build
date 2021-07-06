
import Foundation
import SwiftAST

public class SwiftOpaquePass: SwiftRefactorPass {

    public override init() {}

    public override func refactor(module: SwiftModule) throws {
        try SwiftOpaquePassVisitor().visit(ast: module)
    }
}

class SwiftOpaquePassVisitor: SwiftVisitor {

    override func visit(type: SwiftType) throws -> SwiftType {

        // Use public typealias name for opaque types
//        if let opaquePointer = type.canonical.asOpaquePointer {
//            if let opaqueTypealias = type.outerTypealias(type: opaquePointer.pointeeType) {
//                return SwiftPointerType(pointeeType: SwiftOpaqueType(name: opaqueTypealias.decl.name,
//                                                                     qual: opaquePointer.qual),
//                                        isMutable: opaquePointer.isMutable,
//                                        qual: opaquePointer.qual)
//            }
//        }
        
        return try super.visit(type: type)
    }
}

