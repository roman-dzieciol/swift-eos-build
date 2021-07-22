
import Foundation

final public class SwiftFunctionType: SwiftType {

    public let paramTypes: [SwiftType]
    public let returnType: SwiftType
    public let isThrowing: Bool

    public override var canonical: SwiftType {
        SwiftFunctionType(paramTypes: paramTypes.map { $0.canonical },
                          isThrowing: isThrowing,
                          returnType: returnType.canonical,
                          qual: qual)
    }

    public override var debugDescriptionDetails: String {
        "\(super.debugDescriptionDetails), " +
        "(\(paramTypes.map { $0.debugDescription }.joined(separator: ",") ))" +
        (self.isThrowing ? "throws " : "") +
        " -> \(returnType.debugDescription)"
    }

    public init(paramTypes: [SwiftType], isThrowing: Bool = false, returnType: SwiftType, qual: SwiftQual = .none) {
        self.isThrowing = isThrowing
        self.returnType = returnType.isOptional == nil ? returnType.copy { $0.optional } : returnType
        self.paramTypes = paramTypes
        super.init(qual: qual)
    }

    public override func handle(visitor: SwiftVisitor) throws -> SwiftType {
        let newReturnType = try visitor.visit(type: returnType)
        let newParamTypes = try paramTypes.map { try visitor.visit(type: $0) }
        if newReturnType != returnType || newParamTypes != paramTypes {
            return SwiftFunctionType(paramTypes: newParamTypes, returnType: newReturnType, qual: qual)
        }
        return self
    }

    public override func isEqual(rhs: SwiftType) -> Bool {
        guard let rhs = rhs as? Self else { return false }
        return super.isEqual(rhs: rhs) &&
        paramTypes == rhs.paramTypes &&
        returnType == rhs.returnType &&
        isThrowing == rhs.isThrowing
    }

    public override func hash(into hasher: inout Hasher) {
        super.hash(into: &hasher)
        hasher.combine(paramTypes)
        hasher.combine(returnType)
        hasher.combine(isThrowing)
    }

    public override func copy(_ adjust: (SwiftQual) -> SwiftQual) -> SwiftType {
        SwiftFunctionType(paramTypes: paramTypes, isThrowing: isThrowing, returnType: returnType, qual: adjust(qual))
    }

    public override func write(to swift: SwiftOutputStream) {
        let writeBaseType = {
            self.qual.attributes.sorted().forEach { swift.write(name: $0) }
            swift.write(textIfNeeded: " ")
            swift.write(nested: "(", ")") {
                swift.write(self.paramTypes, separated: ",")
            }
            if self.isThrowing {
                swift.write(name: "throws")
            }
            swift.write(token: "->")
            swift.write(self.returnType)
        }
        if isOptional == true {
            swift.write(nested: "(", ")") {
                writeBaseType()
            }
            swift.write(text: Self.token(isOptional: isOptional))
        } else {
            writeBaseType()
        }
    }
}


extension SwiftType {

    public var asFunction: SwiftFunctionType? {
        self as? SwiftFunctionType
    }

    public var isFunction: Bool {
        self is SwiftFunctionType
    }
}
