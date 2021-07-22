
import Foundation
import SwiftAST

final public class SwiftDebugPass: SwiftRefactorPass {

    let action: (_ module: SwiftModule) throws -> Void

    public init(_ action: @escaping (_ module: SwiftModule) throws -> Void ) {
        self.action = action
        super.init()
    }

    public override func refactor(module: SwiftModule) throws {
        try action(module)
    }
}
