
import Foundation

final public class SwiftFunctionCallCode: SwiftCode {

    public let call: SwiftOutput
    public var parms: [SwiftOutput] { outputs }

    public init(call: SwiftOutput, parms: [SwiftOutput] = []) {
        self.call = call
        super.init(outputs: parms)
    }

    public convenience init(function: SwiftFunction, parms: [SwiftOutput] = []) {
        let call = SwiftOutput { swift in
            if function.isThrowing {
                swift.write(name: "try")
            }
            swift.write(name: function.name)
        }
        self.init(call: call, parms: parms)
    }


    public convenience init(call: @escaping (SwiftOutputStream) -> Void) {
        self.init(call: SwiftOutput(output: call))
    }

    public convenience init(name: String, parms: [SwiftOutput] = []) {
        self.init(call: SwiftOutput { $0.write(name: name) }, parms: parms)
    }

    public convenience init(init object: SwiftObject, parms: [SwiftOutput] = []) {
        self.init(call: SwiftOutput { $0.write(name: object.name) }, parms: parms)
    }

    public override func write(to swift: SwiftOutputStream){
        let isMultiline = parms.count > 1
        if let output = call.output {
            output(swift)
            swift.write(nested: "(", ")") {
                if isMultiline {
                    swift.write(textIfNeeded: "\n")
                    swift.write(parms, separated: ",\n")
                    swift.write(textIfNeeded: "\n")
                } else {
                    swift.write(parms, separated: ", ")
                }
            }
        }
    }

}
