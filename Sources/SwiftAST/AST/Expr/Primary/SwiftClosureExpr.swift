
import Foundation


public final class SwiftClosureExpr: SwiftPrimaryExpr {

    public let signature: SwiftClosureSignatureExpr
    public let statements: SwiftExpr

    public init(
        signature: SwiftClosureSignatureExpr,
        statements: SwiftExpr
    ) {
        self.signature = signature
        self.statements = statements
    }

    public convenience init(
        captures: SwiftCaptureListExpr,
        params: SwiftClosureParameterListExpr,
        omitParams: Bool,
        resultType: SwiftType?,
        omitResultType: Bool,
        isThrowing: Bool,
        statements: SwiftExpr
    ) {
        let signature = SwiftClosureSignatureExpr(captures: captures, params: params, omitParams: omitParams, resultType: resultType, omitResultType: omitResultType, isThrowing: isThrowing)
        self.init(signature: signature, statements: statements)
    }

    public convenience init(
        captures: [String] = [],
        params: [String] = [],
        omitParams: Bool = false,
        resultType: SwiftType? = nil,
        omitResultType: Bool = true,
        isThrowing: Bool = false,
        statements: SwiftExpr
    ) {
        let signature = SwiftClosureSignatureExpr(captures: .init(captures), params: .init(params), omitParams: omitParams, resultType: resultType, omitResultType: omitResultType, isThrowing: isThrowing)
        self.init(signature: signature, statements: statements)
    }

    public override func perform<R>(_ action: (SwiftExpr) -> R?) -> R? {
        return action(self) ?? signature.perform(action) ?? statements.perform(action)
    }

    public override func evaluateThrowing() -> Bool {
        signature.isThrowing || statements.evaluateThrowing()
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(nested: "{", "}") {
            swift.write(signature)
            swift.write(statements)
        }
    }
}

public final class SwiftClosureSignatureExpr: SwiftExpr {

    public let captures: SwiftCaptureListExpr
    public let params: SwiftClosureParameterListExpr
    public let omitParams: Bool
    public let resultType: SwiftType?
    public let omitResultType: Bool
    public let isThrowing: Bool

    public init(
        captures: SwiftCaptureListExpr,
        params: SwiftClosureParameterListExpr,
        omitParams: Bool,
        resultType: SwiftType?,
        omitResultType: Bool,
        isThrowing: Bool
    ) {
        self.captures = captures
        self.omitParams = omitParams
        self.params = params
        self.resultType = resultType
        self.omitResultType = omitResultType
        self.isThrowing = isThrowing
    }

    public convenience init(
        captures: [String] = [],
        params: [String] = [],
        omitParams: Bool = false,
        resultType: SwiftType? = nil,
        omitResultType: Bool = true,
        isThrowing: Bool = false
    ) {
        self.init(captures: .init(captures), params: .init(params), omitParams: omitParams, resultType: resultType, omitResultType: omitResultType, isThrowing: isThrowing)
    }

    public override func perform<R>(_ action: (SwiftExpr) -> R?) -> R? {
        return action(self) ?? captures.perform(action) ?? params.perform(action)
    }

    public override func evaluateThrowing() -> Bool {
        self.isThrowing
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(captures)
        if !omitParams {
            swift.write(params)
        }
        if isThrowing {
            //            swift.write(name: "throws")
        }
        if !omitResultType, let resultType = resultType {
            swift.write(token: "->")
            swift.write(resultType)
        }
        if !params.items.isEmpty || !captures.items.isEmpty {
            swift.write(name: "in")
        }
    }
}

public final class SwiftClosureParameterListExpr: SwiftExpr {

    public static let none = SwiftClosureParameterListExpr(items: [])

    public let items: [SwiftClosureParameterExpr]

    public init(items: [SwiftClosureParameterExpr]) {
        self.items = items
    }

    public convenience init(_ items: [String]) {
        self.init(items: items.map { .init($0) })
    }

    public override func perform<R>(_ action: (SwiftExpr) -> R?) -> R? {
        return action(self) ?? items.firstNonNil { $0.perform(action) }
    }

    public override func write(to swift: SwiftOutputStream) {
        guard !items.isEmpty else { return }
//        swift.write(token: "(")
        swift.write(items, separated: ",")
//        swift.write(token: ")")
    }
}


public final class SwiftClosureParameterExpr: SwiftExpr {

    public let identifier: SwiftIdentifier
    public let type: SwiftType?
    public let omitType: Bool

    public init(identifier: SwiftIdentifier, type: SwiftType?, omitType: Bool) {
        self.identifier = identifier
        self.type = type
        self.omitType = omitType
    }

    public convenience init(_ named: String, type: SwiftType? = nil, omitType: Bool = true) {
        self.init(identifier: .string(named), type: type, omitType: omitType)
    }

    public override func perform<R>(_ action: (SwiftExpr) -> R?) -> R? {
        return action(self) ?? identifier.perform(action)
    }

    public override func write(to swift: SwiftOutputStream) {
        swift.write(identifier)
        if !omitType, let type = type {
            swift.write(token: ":")
            swift.write(type)
        }
    }
}

public final class SwiftCaptureListExpr: SwiftExpr {

    public static let none = SwiftCaptureListExpr(items: [])

    public let items: [SwiftCaptureItemExpr]

    public init(items: [SwiftCaptureItemExpr]) {
        self.items = items
    }

    public convenience init(_ items: [String]) {
        self.init(items: items.map { .init($0) })
    }

    public override func perform<R>(_ action: (SwiftExpr) -> R?) -> R? {
        return action(self) ?? items.firstNonNil { $0.perform(action) }
    }

    public override func write(to swift: SwiftOutputStream) {
        guard !items.isEmpty else { return }
        swift.write(token: "[")
        swift.write(items, separated: ",")
        swift.write(token: "]")
    }
}

public final class SwiftCaptureItemExpr: SwiftExpr {

    public let identifier: SwiftIdentifier
    public let specifier: String

    public init(identifier: SwiftIdentifier, specifier: String) {
        self.identifier = identifier
        self.specifier = specifier
    }

    public convenience init(_ named: String) {
        self.init(identifier: .string(named), specifier: "")
    }

    public override func perform<R>(_ action: (SwiftExpr) -> R?) -> R? {
        return action(self) ?? identifier.perform(action)
    }

    public override func write(to swift: SwiftOutputStream) {
        if !specifier.isEmpty {
            swift.write(name: specifier)
        }
        swift.write(identifier)
    }
}

