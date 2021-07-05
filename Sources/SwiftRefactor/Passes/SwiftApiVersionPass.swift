
import Foundation
import SwiftAST

public class SwiftApiVersionPass: SwiftRefactorPass {

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

                                if object.name.hasSuffix("EOS_IOS_Auth_CredentialsOptions") {
                                    parm.defaultValue = "EOS_IOS_AUTH_CREDENTIALSOPTIONS_API_LATEST"
                                    return
                                }

                                parm.defaultValue = latestApiVersionToken(from: member.comment)
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
        if let comment: String = comment?.description,
           let substrRange = comment.range(of: commentSubstr) {
            return String(comment[substrRange.upperBound...].prefix(while: { $0.isLetter || $0.isNumber || $0 == "_" }))
        } else {
            fatalError()
        }
    }
}
