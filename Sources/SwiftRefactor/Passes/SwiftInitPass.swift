
import Foundation
import SwiftAST

final public class SwiftInitPass: SwiftRefactorPass {

    public override init() {}

    public override func refactor(module: SwiftModule) throws {

        try module.inner
            .compactMap { $0 as? SwiftObject }
            .filter { $0.inSwiftEOS }
            .forEach {
                _ = try $0.functionInitMemberwise()
//                _ = try $0.functionInitFromSdkObject()
//                _ = try $0.functionBuildSdkObject()
            }
    }
}
