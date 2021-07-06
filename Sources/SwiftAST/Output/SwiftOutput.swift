
import Foundation

public class SwiftCodeAST: SwiftAST {

    public let output: SwiftOutput

    public init(output: SwiftOutput) {
        self.output = output
        super.init(name: "SwiftCodeAST")
    }
}


public class SwiftOutput: SwiftOutputStreamable {

    public var output: ((SwiftOutputStream) -> Void)?

    public init(output: @escaping (SwiftOutputStream) -> Void) {
        self.output = output
    }
    public init(_ expr: SwiftExpr) {
        self.output = { swift in
            swift.write(expr)
        }
    }

    public func write(to swift: SwiftOutputStream) {
        output?(swift)
    }

    @discardableResult
    public func link(_ decl: SwiftAST) -> Self {
        decl.link(.code, ref: SwiftCodeAST(output: self))
        return self
    }
}

public class SwiftCode: SwiftOutputStreamable {

    public var outputs: [SwiftOutput]

    public var withReturn: Bool = false
    public var isThrowing: Bool = false
    public var skipPrefix: Bool = false

    public init(output: @escaping (SwiftOutputStream) -> Void) {
        self.outputs = [SwiftOutput(output: output)]
    }

    public init(outputs: [SwiftOutput] = []) {
        self.outputs = outputs
    }

    public init(_ expr: SwiftExpr) {
        self.outputs = [SwiftOutput(expr)]
    }

    public func append(output: SwiftOutput) {
        self.outputs.append(output)
    }

    @discardableResult
    public func append(_ output: @escaping (SwiftOutputStream) -> Void) -> SwiftOutput {
        let output = SwiftOutput(output: output)
        self.outputs.append(output)
        return output
    }

    public func nested(_ output: @escaping (_ swift: SwiftOutputStream, _ innerCall: @escaping (SwiftOutputStream) -> Void) -> Void) {
        let outputs = self.outputs
        let prefixString = prefixString()
        self.outputs = [SwiftOutput { swift in
            if !prefixString.isEmpty {
                swift.write(name: prefixString)
            }
            output(swift, { swift in outputs.forEach { $0.write(to: swift) } })
        }]
    }

    public func nest(_ output: @escaping (_ swift: SwiftOutputStream, _ invocation: SwiftInvocation) -> Void) {
        let outputs = self.outputs
        let prefixString = prefixString()
        self.outputs = [SwiftOutput { swift in
            if !prefixString.isEmpty {
                swift.write(name: prefixString)
            }
            output(swift, SwiftInvocation { swift in outputs.forEach { $0.write(to: swift) } })
        }]
    }

    public func nest2(_ output: @escaping (_ swift: SwiftOutputStream, _ prefixInvocation: SwiftInvocation?, _ invocation: SwiftInvocation) -> Void) {
        let outputs = self.outputs
        let prefixString = prefixString()
        let prefixInvocation: SwiftInvocation? = prefixString.isEmpty ? nil :  SwiftInvocation { $0.write(name: prefixString) }
        self.outputs = [SwiftOutput { swift in
            output(
                swift,
                prefixInvocation,
                SwiftInvocation { swift in outputs.forEach { $0.write(to: swift) } })
        }]
    }

    func prefixString() -> String {
        if skipPrefix {
            skipPrefix = false
            return ""
        }
        return
        (withReturn ? "return " : "") +
        (isThrowing ? "try " : "") 

    }

    public func write(to swift: SwiftOutputStream) {
        outputs.forEach { $0.write(to: swift) }
    }
}

public typealias SwiftInvocation = SwiftCode
