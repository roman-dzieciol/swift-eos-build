
import Foundation

public class SwiftEnumCase: SwiftDecl {

    public var valueTokens: [String]

    public var value: String? {
        valueTokens.isEmpty ? nil : valueTokens.joined(separator: "")
    }

    public init(name: String, valueTokens: [String], comment: SwiftComment? = nil) {
        self.valueTokens = valueTokens
        super.init(name: name, inner: [], comment: comment)
    }

    public override func copy() -> SwiftEnumCase {
        let copy = SwiftEnumCase(name: name, valueTokens: valueTokens, comment: comment?.copy())
        linkCopy(from: self, to: copy)
        return copy
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(comment)
        swift.write(name: "case")
        swift.write(name: name)
        if let value = value {
            swift.write(token: "=")
            swift.write(text: value)
        }
    }

}
