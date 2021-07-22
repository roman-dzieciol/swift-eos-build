
import Foundation
import SwiftAST
import os.log

final public class SwiftRemoveOptionsPass: SwiftRefactorPass {

    public override func refactor(module: SwiftModule) throws {

        var options: [SwiftObject] = []

        module.inner
            .compactMap { $0 as? SwiftFunction }
            .forEach { function in
                function.parms.forEach { parm in
                    if parm.name == "Options",
                       let parmType = parm.type.canonical.asPointer?.pointeeType.asDeclRef,
                       let decl = parmType.decl as? SwiftObject
                    {
                        options.append(decl)
                    }
            }
        }

        let optionNames: Set<String> = Set(options.map {
            $0.name
        })

        module.inner.removeAll {
            if optionNames.contains($0.name) {
                os_log("%{public}s removing %{public}s", log: .disabled, "\(type(of: self))", $0.name)
                return true
            }
            return false
        }
    }
}
