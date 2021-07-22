
import Foundation
import SwiftAST

final public class SwiftToStringPass: SwiftRefactorPass {

    public override init() {}

    public override func refactor(module sdkModule: SwiftModule) throws {

        let module = sdkModule.swifty!

        sdkModule.inner
            .compactMap { $0 as? SwiftEnum }
            .forEach { swiftEnum in

                guard swiftEnum.name != "EOS_EResult" else { return }

                let tag = SwiftObject(name: swiftEnum.name, tagName: "extension", superTypes: ["CustomStringConvertible"])
                tag.access = ""

                let enumCaseStmts: [SwiftStmt] = swiftEnum.inner
                    .compactMap { $0 as? SwiftEnumCase }
                    .map { enumCase in
                        SwiftTempExpr { swift in
                            swift.write(name: "case .\(enumCase.name): return \"\(enumCase.name)\"")
                            swift.write(textIfNeeded: "\n")
                        }
                    }

                let switchStmt = SwiftTempExpr { swift in
                    swift.write(name: "switch self {")
                    swift.write(textIfNeeded: "\n")
                    swift.indent(offset: 4) {
                        swift.write(enumCaseStmts)
                        swift.write(name: "default: return \"\(swiftEnum.name)(rawValue: \\(self.rawValue))\"")
                        swift.write(textIfNeeded: "\n")
                    }
                    swift.write(name: "}")
                }


                let code = SwiftCodeBlock(statements: [switchStmt])
                let member = SwiftMember(name: "description", type: .string.nonOptional, isMutable: true, getter: code, comment: nil)

                tag.append(member)
                module.append(tag)
            }

    }
}
