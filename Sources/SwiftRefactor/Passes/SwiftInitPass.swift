
import Foundation
import SwiftAST

public class SwiftInitPass: SwiftRefactorPass {

    public override init() {}

    public override func refactor(module: SwiftModule) throws {

//        try module.inner
//            .compactMap { $0 as? SwiftObject }
//            .filter { !$0.name.hasSuffix("CallbackInfo") }
//            .forEach {
//                try $0.addWithPointerToSdkObjectIfNeeded()
//            }
//
//
//        module.inner
//            .filter { !$0.name.hasSuffix("Options") }
//            .compactMap { $0 as? SwiftObject }
//            .forEach { _ = $0.addInitFromSourceAST() }

//        try module.inner
//            .filter { $0.name.hasSuffix("CallbackInfo") }
//            .compactMap { $0 as? SwiftObject }
//            .forEach { try $0.addInitFromSdkObjectPointer() }

        try module.inner
            .filter { $0.name.hasSuffix("Options") }
            .compactMap { $0 as? SwiftObject }
            .forEach {
                _ = try $0.functionInitMemberwise()
                _ = try $0.functionInitFromSdkObject()
                _ = try $0.functionBuildSdkObject()
            }
    }
}
