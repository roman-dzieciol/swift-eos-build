
import Foundation

public class SwiftFunctionCode: SwiftCode {

    public static func todo(note: String) -> SwiftFunctionCode {
        SwiftFunctionCode {
            $0.write(token: "fatalError(\"TODO: \(note)\")")
        }
    }

    public override func write(to swift: SwiftOutputStream){
        swift.write(nested: "{", "}", {
            swift.write(textIfNeeded: "\n")
            outputs.forEach {
                swift.write(textIfNeeded: "\n")
                $0.write(to: swift)
            }
            swift.write(textIfNeeded: "\n")
        })
    }
}
