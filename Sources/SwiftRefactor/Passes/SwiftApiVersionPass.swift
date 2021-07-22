
import Foundation
import SwiftAST

final public class SwiftApiVersionPass: SwiftRefactorPass {

    public override func refactor(module: SwiftModule) throws {

        module.inner
            .compactMap { $0 as? SwiftObject }
            .forEach { object in
                object.inner
                    .compactMap { $0 as? SwiftFunction }
                    .filter { $0.name == "init" }
                    .forEach { function in
                        for parm in function.parms {
                            if let member = parm.linked(.member), member.name == "ApiVersion" {

                                let defaultValue: String? = {
                                    if object.sdk!.name.hasSuffix("EOS_IOS_Auth_CredentialsOptions") {
                                        return "EOS_IOS_AUTH_CREDENTIALSOPTIONS_API_LATEST"
                                    }
                                    return latestApiVersionToken(from: member.sdk?.comment)
                                }()

                                parm.defaultValue = defaultValue
                                if let defaultValue = defaultValue {
                                    parm.link(.apiVersion, ref: SwiftExprRef(expr: .string(defaultValue)))
                                    parm.sdk?.link(.apiVersion, ref: SwiftExprRef(expr: .string(defaultValue)))
                                    member.link(.apiVersion, ref: SwiftExprRef(expr: .string(defaultValue)))
                                    member.sdk?.link(.apiVersion, ref: SwiftExprRef(expr: .string(defaultValue)))
                                }
                                return
                            }
                        }
                    }
            }
    }

    /// Returns API_LATEST token for ApiVersion property
    ///
    /// Parses comments as these seem to match the most
    private func latestApiVersionToken(from comment: SwiftComment?) -> String? {
        //swift.write(name: "\(optionsStruct.name.dropLast("Options".count))_API_LATEST".uppercased())
        let commentSubstr = "Set this to "
        if let comment = comment {
            let commentDescription: String = SwiftWriterString.description(for: comment)
            if let substrRange = commentDescription.range(of: commentSubstr) {
                return String(commentDescription[substrRange.upperBound...].prefix(while: { $0.isLetter || $0.isNumber || $0 == "_" }))
            }
        }
        fatalError()
    }
}
